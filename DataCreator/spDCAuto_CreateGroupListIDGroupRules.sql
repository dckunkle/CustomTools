/**************************************************************************************************
Name:       spDCAuto_CreateGroupListIDGroupRules
Purpose:    Create grouplistidgrouprules data from CorderAutomation

Screen:     212
Method:     GroupListIDGroupRules
Procedure:  dbo.prTxGroupListRuleAddModify
Entity:     TX_GROUP_LIST_RULES

Date        User            Change
---------------------------------------------------------------------------------------------
09/02/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupListIDGroupRules 'RFF-Config-2203%', 22, 'RFF-Config-2203', 'GroupListIDGroupRules', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateGroupListIDGroupRules
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
       ,@i_tx_gid             VARCHAR(50)
       ,@i_tx_sid             VARCHAR(50)
       ,@i_tx_list_type       VARCHAR(50)
       ,@i_key_4_field        VARCHAR(80)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(20)
       ,@i_key_7_field        VARCHAR(20)
       ,@i_key_8_field        VARCHAR(20)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@iEffDate             VARCHAR(50)
       ,@iTermDate            VARCHAR(50)
       ,@iGroupID             VARCHAR(50)
       ,@iGroupDesc           VARCHAR(100)
       ,@iMatchType           VARCHAR(50)
       ,@iIncludeSubGroups    VARCHAR(50)
       ,@iExclude             VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(1000)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupListIDGroupRules') IS NOT NULL
	DROP TABLE #GroupListIDGroupRules

CREATE TABLE #GroupListIDGroupRules
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('TX_GROUP_LIST_RULES')
      ,i_tx_gid             VARCHAR(50)       DEFAULT('0')
      ,i_tx_sid             VARCHAR(50)       DEFAULT('0')
      ,i_tx_list_type       VARCHAR(50)       DEFAULT('G')
      ,i_key_4_field        VARCHAR(80)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iEffDate             VARCHAR(50)
      ,iTermDate            VARCHAR(50)
      ,iGroupID             VARCHAR(50)
      ,iGroupDesc           VARCHAR(100)
      ,iMatchType           VARCHAR(50)
      ,iIncludeSubGroups    VARCHAR(50)
      ,iExclude             VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(1000)
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

    INSERT INTO #GroupListIDGroupRules
          (SearchID
          ,iEffDate
          ,iTermDate
          ,iGroupID
          ,iMatchType
          ,iIncludeSubGroups
          ,iExclude
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([*GroupID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MatchType]), 'E')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IncludeSubGroups]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Exclude]), 'N')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_GroupListIDGroupRules
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #GroupListIDGroupRules
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
DECLARE GroupListIDGroupRules_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_tx_gid
       ,i_tx_sid
       ,i_tx_list_type
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
       ,iEffDate
       ,iTermDate
       ,iGroupID
       ,iGroupDesc
       ,iMatchType
       ,iIncludeSubGroups
       ,iExclude
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupListIDGroupRules

   OPEN GroupListIDGroupRules_Cursor
  FETCH NEXT FROM GroupListIDGroupRules_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_tx_gid
       ,@i_tx_sid
       ,@i_tx_list_type
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
       ,@iEffDate
       ,@iTermDate
       ,@iGroupID
       ,@iGroupDesc
       ,@iMatchType
       ,@iIncludeSubGroups
       ,@iExclude
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

			SELECT @i_tx_gid				= EN.entity_gid
			  FROM dbo.Entity_Names			EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_identifier		= 'TX_GROUP_LIST'
			   AND EN.entity_user_id		= @SearchID		

			IF ISNULL(@i_tx_gid, 0) = 0
				BEGIN
					SELECT @err_num = 100
					      ,@err_msg = 'The Group List, ' + ISNULL(@SearchID, 'not defined') + ', could not be found in the database.'
				END
			ELSE
				BEGIN

					EXEC dbo.prTxGroupListRuleAddModify
						 @i_entity_name
						,@i_tx_gid
						,@i_tx_sid
						,@i_tx_list_type
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
						,@iEffDate
						,@iTermDate
						,@iGroupID
						,@iGroupDesc
						,@iMatchType
						,@iIncludeSubGroups
						,@iExclude
						,@o_status     = @err_num OUTPUT
						,@o_message    = @err_msg OUTPUT
				END

		END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
					,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iGroupID, @iEffDate, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM GroupListIDGroupRules_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_tx_gid
             ,@i_tx_sid
             ,@i_tx_list_type
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
             ,@iEffDate
             ,@iTermDate
             ,@iGroupID
             ,@iGroupDesc
             ,@iMatchType
             ,@iIncludeSubGroups
             ,@iExclude
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupListIDGroupRules_Cursor
DEALLOCATE GroupListIDGroupRules_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#GroupListIDGroupRules') IS NOT NULL
	DROP TABLE #GroupListIDGroupRules

END
GO

