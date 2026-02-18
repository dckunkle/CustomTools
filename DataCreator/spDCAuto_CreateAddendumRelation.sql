IF OBJECT_ID('dbo.spDCAuto_CreateAddendumRelation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAddendumRelation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAddendumRelation
Purpose:    Create addendumrelation data from CorderAutomation

Screen:     6073
Method:     AddendumRelation
Procedure:  dbo.prAddendumRelateAdd
Entity:     ADDENDUM_RELATE

Date        User            Change
---------------------------------------------------------------------------------------------
04/20/2020	DK				Original procedure
12/21/2020	DK				Fix code that was updating gids for other objects in Entity_Names
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAddendumRelation '100-Config%', 22, 'AddendumRelation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAddendumRelation
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern					VARCHAR(200)
	   ,@log_id						INT
	   ,@test_case_name				VARCHAR(200)
	   ,@method						VARCHAR(200)
	   ,@user						VARCHAR(200)

	   ,@record_id					INT
	   ,@gid						INT
	   ,@err_msg					VARCHAR(4000)
       ,@err_num					INT
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_Rule_gid           VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(50)
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserID              VARCHAR(50)
       ,@i_New_AddenRel_id    VARCHAR(50)
       ,@i_New_AddenRel_name  VARCHAR(100)
       ,@i_Org_AddenRel_id    VARCHAR(50)
       ,@i_Org_AddenRel_name  VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AddendumRelation') IS NOT NULL
	DROP TABLE #AddendumRelation

CREATE TABLE #AddendumRelation
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('ADDENDUM_RELATE')
      ,i_Rule_gid           VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(50)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(200)      DEFAULT('')
      ,iUserID              VARCHAR(50)       DEFAULT('')
      ,i_New_AddenRel_id    VARCHAR(50)
      ,i_New_AddenRel_name  VARCHAR(100)
      ,i_Org_AddenRel_id    VARCHAR(50)
      ,i_Org_AddenRel_name  VARCHAR(100)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #AddendumRelation
          (SearchID
          ,i_New_AddenRel_id
          ,i_New_AddenRel_name
          ,i_Org_AddenRel_id
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*AddendumRelID], '')
          ,ISNULL([*AddendumRelDesc], '')
          ,ISNULL([CopyFrmAddendumRelID], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_AddendumRelation
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #AddendumRelation
       SET iUserID  = @user


END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AddendumRelation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Rule_gid
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_New_AddenRel_id
       ,i_New_AddenRel_name
       ,i_Org_AddenRel_id
       ,i_Org_AddenRel_name
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AddendumRelation

   OPEN AddendumRelation_Cursor
  FETCH NEXT FROM AddendumRelation_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Rule_gid
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_New_AddenRel_id
       ,@i_New_AddenRel_name
       ,@i_Org_AddenRel_id
       ,@i_Org_AddenRel_name
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prAddendumRelateAdd
                 @i_entity_name
                ,@i_Rule_gid
                ,@i_key_2_field
                ,@i_key_3_field
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@i_New_AddenRel_id
                ,@i_New_AddenRel_name
                ,@i_Org_AddenRel_id
                ,@i_Org_AddenRel_name
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				SELECT @current_gid				= EN.entity_gid
				  FROM Entity_Names				EN
				 WHERE EN.entity_identifier		= 'ADDENDUM_RELATE'
				   AND EN.record_status			= 'A'
				   AND EN.entity_user_id		= @i_New_AddenRel_id
				   
				UPDATE dbo.Contract_Addendum_Link 
				   SET contract_link_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND contract_link_gid		= @current_gid

				UPDATE EN
				   SET EN.entity_gid			= @static_gid
				  FROM dbo.Entity_Names			EN
				 WHERE EN.record_status			= 'A'
				   AND EN.entity_identifier		= 'ADDENDUM_RELATE'
				   AND EN.entity_gid			= @current_gid

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_New_AddenRel_id, @i_New_AddenRel_name, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM AddendumRelation_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Rule_gid
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_New_AddenRel_id
             ,@i_New_AddenRel_name
             ,@i_Org_AddenRel_id
             ,@i_Org_AddenRel_name
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AddendumRelation_Cursor
DEALLOCATE AddendumRelation_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#AddendumRelation') IS NOT NULL
	DROP TABLE #AddendumRelation

END
GO