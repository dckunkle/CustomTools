IF OBJECT_ID('dbo.spDCAuto_CreateModifier') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateModifier AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateModifier
Purpose:    Create modifier data from CorderAutomation

Screen:     3112
Method:     Modifier
Procedure:  dbo.prModifier_AddModify
Entity:     Modifier

Date        User            Change
---------------------------------------------------------------------------------------------
01/10/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateModifier '100-Config%', 22, '100-Config','Modifier','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateModifier
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

DECLARE @i_Entity_name  VARCHAR(50)
       ,@i_modifier_gid VARCHAR(100)
       ,@i_key_2_field  VARCHAR(50)
       ,@i_key_3_field  VARCHAR(50)
       ,@i_key_4_field  VARCHAR(50)
       ,@i_key_5_field  VARCHAR(50)
       ,@i_key_6_field  VARCHAR(50)
       ,@i_key_7_field  VARCHAR(50)
       ,@i_key_8_field  VARCHAR(50)
       ,@i_key_9_field  VARCHAR(50)
       ,@i_key_10_field VARCHAR(50)
       ,@iAction        VARCHAR(10)
       ,@iModifiedDate  VARCHAR(50)
       ,@iUserID        VARCHAR(25)
       ,@iCode          VARCHAR(50)
       ,@iDescription   VARCHAR(200)
       ,@iEffDate       VARCHAR(50)
       ,@iTermDate      VARCHAR(50)
       ,@iModifierType  VARCHAR(50)
       ,@oStatus        INT
       ,@oMessage       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Modifier') IS NOT NULL
	DROP TABLE #Modifier

CREATE TABLE #Modifier
      (SearchID       VARCHAR(200)
      ,i_Entity_name  VARCHAR(50)       DEFAULT('Modifier')
      ,i_modifier_gid VARCHAR(100)       DEFAULT('0')
      ,i_key_2_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field VARCHAR(50)       DEFAULT('0')
      ,iAction        VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate  VARCHAR(50)       DEFAULT('')
      ,iUserID        VARCHAR(25)       DEFAULT('')
      ,iCode          VARCHAR(50)
      ,iDescription   VARCHAR(200)
      ,iEffDate       VARCHAR(50)
      ,iTermDate      VARCHAR(50)
      ,iModifierType  VARCHAR(50)
      ,oStatus        INT
      ,oMessage       VARCHAR(100)
      ,record_id      INT
      ,static_gid     INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #Modifier
          (SearchID
          ,iCode
          ,iDescription
          ,iEffDate
          ,iTermDate
          ,iModifierType
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*Modifier_Code], '')
          ,ISNULL([*Description], '')
          ,ISNULL([*Effective_Date], '01/01/1900')
          ,ISNULL([*Termination_Date], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Code_Qualifier]), '******')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_Modifier
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #Modifier
       SET iUserID  = @user

	SELECT * FROM #Modifier

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
DECLARE Modifier_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_modifier_gid
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iCode
       ,iDescription
       ,iEffDate
       ,iTermDate
       ,iModifierType
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #Modifier

   OPEN Modifier_Cursor
  FETCH NEXT FROM Modifier_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_modifier_gid
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iCode
       ,@iDescription
       ,@iEffDate
       ,@iTermDate
       ,@iModifierType
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			EXEC dbo.prModifier_AddModify
                 @i_Entity_name
                ,@i_modifier_gid
                ,@i_key_2_field
                ,@i_key_3_field
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@iAction
                ,@iModifiedDate
                ,@iUserID
                ,@iCode
                ,@iDescription
                ,@iEffDate
                ,@iTermDate
                ,@iModifierType
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				SELECT @current_gid				= MD.modifier_gid
				  FROM dbo.Modifier_Definition	MD
				 WHERE MD.record_status			= 'A'
				   AND MD.code					= @iCode
				   AND MD.effective_date		= @iEffDate

				UPDATE MD
				   SET MD.modifier_gid			= @static_gid
				  FROM dbo.Modifier_Definition	MD
				 WHERE MD.record_status			= 'A'
				   AND MD.modifier_gid			= @current_gid

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iCode, @iEffDate, @iModifierType, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Modifier_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_modifier_gid
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iCode
             ,@iDescription
             ,@iEffDate
             ,@iTermDate
             ,@iModifierType
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE Modifier_Cursor
DEALLOCATE Modifier_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#Modifier') IS NOT NULL
	DROP TABLE #Modifier

END
GO

