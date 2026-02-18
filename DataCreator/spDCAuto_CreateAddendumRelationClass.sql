IF OBJECT_ID('dbo.spDCAuto_CreateAddendumRelationClass') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAddendumRelationClass AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAddendumRelationClass
Purpose:    Create addendumrelationclass data from CorderAutomation
Method:     AddendumRelationClass
Screen GID: 6072
Procedure:  dbo.prContractAddendumLinkAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAddendumRelationClass '100-Config%', 22, 'AddendumRelationClass'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAddendumRelationClass
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
	   ,@addendum_gid				INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(80)
       ,@i_entity_gid         VARCHAR(100)
       ,@i_key_2_field        VARCHAR(80)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_class_id           VARCHAR(50)
       ,@i_class_desc         VARCHAR(100)
       ,@i_addendum_id        VARCHAR(50)
       ,@i_addendum_desc      VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AddendumRelationClass') IS NOT NULL
	DROP TABLE #AddendumRelationClass

CREATE TABLE #AddendumRelationClass
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(80)       DEFAULT('ADDENDUM_LINK')
      ,i_entity_gid         VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field        VARCHAR(80)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_class_id           VARCHAR(50)
      ,i_class_desc         VARCHAR(100)
      ,i_addendum_id        VARCHAR(50)
      ,i_addendum_desc      VARCHAR(100)
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
INSERT INTO #AddendumRelationClass
      (SearchID
      ,i_class_id
      ,i_class_desc
      ,i_addendum_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*ClassID], '')
      ,ISNULL([*ClassDesc], '')
      ,ISNULL([*AddendumID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AddendumRelationClass
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AddendumRelationClass
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AddendumRelationClass_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_entity_gid
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
       ,i_date_time_modified
       ,iUserID
       ,i_class_id
       ,i_class_desc
       ,i_addendum_id
       ,i_addendum_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AddendumRelationClass

   OPEN AddendumRelationClass_Cursor
  FETCH NEXT FROM AddendumRelationClass_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_entity_gid
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
       ,@i_date_time_modified
       ,@iUserID
       ,@i_class_id
       ,@i_class_desc
       ,@i_addendum_id
       ,@i_addendum_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the Auth Match
			SELECT @i_entity_gid			= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'ADDENDUM_RELATE'

			-- Get the addendum description 
			SELECT @i_addendum_desc			= CA.addendum_desc
			  FROM Contract_Addendum		CA
			 WHERE CA.addendum_id			= @i_addendum_id
			   AND record_status			= 'A'

			EXEC dbo.prContractAddendumLinkAdd
             @i_entity_name
            ,@i_entity_gid
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
            ,@i_date_time_modified
            ,@iUserID
            ,@i_class_id
            ,@i_class_desc
            ,@i_addendum_id
            ,@i_addendum_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		-- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN
				   
				SELECT @addendum_gid			= addendum_gid
				  FROM dbo.Contract_Addendum	CA
				 WHERE CA.record_status			= 'A'
				   AND CA.addendum_id			= @i_addendum_id
				   AND CA.addendum_desc			= @i_addendum_desc

				UPDATE dbo.Contract_Addendum_Link 
				   SET contract_link_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND addendum_gid				= @addendum_gid
				   AND entity_gid				= @i_entity_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_class_id, @i_class_desc, @status, @err_num, @err_msg

        FETCH NEXT FROM AddendumRelationClass_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_entity_gid
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
             ,@i_date_time_modified
             ,@iUserID
             ,@i_class_id
             ,@i_class_desc
             ,@i_addendum_id
             ,@i_addendum_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AddendumRelationClass_Cursor
DEALLOCATE AddendumRelationClass_Cursor

END
GO