IF OBJECT_ID('dbo.spDCAuto_CreateHighDollarClaimRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateHighDollarClaimRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateHighDollarClaimRules
Purpose:    Create high-dollarclaimrules data from CorderAutomation

Screen:     4800
Method:     High-DollarClaimRules
Procedure:  dbo.prMaxDollarAddModify
Entity:     Max_Dollar

Date        User            Change
---------------------------------------------------------------------------------------------
06/03/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateHighDollarClaimRules 'IC%', 22, 'ImportConfiguration', 'High-DollarClaimRules', 'ImportConfig'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateHighDollarClaimRules
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

DECLARE @iEntityName         VARCHAR(80)
       ,@iRuleGid            VARCHAR(120)
       ,@iKey_2_field        VARCHAR(80)
       ,@iKey_3_field        VARCHAR(50)
       ,@iKey_4_field        VARCHAR(100)
       ,@iKey_5_field        VARCHAR(50)
       ,@iKey_6_field        VARCHAR(50)
       ,@iKey_7_field        VARCHAR(50)
       ,@iKey_8_field        VARCHAR(50)
       ,@iKey_9_field        VARCHAR(50)
       ,@iRuleSid            VARCHAR(50)
       ,@iAction             VARCHAR(10)
       ,@iDate_Time_Modified VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iRuleID             VARCHAR(50)
       ,@iRuleDesc           VARCHAR(100)
       ,@iCopyRuleID         VARCHAR(50)
       ,@iCopyRuleDesc       VARCHAR(100)
       ,@iStageReason        VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#HighDollarClaimRules') IS NOT NULL
	DROP TABLE #HighDollarClaimRules

CREATE TABLE #HighDollarClaimRules
      (SearchID            VARCHAR(200)
      ,iEntityName         VARCHAR(80)       DEFAULT('Max_Dollar')
      ,iRuleGid            VARCHAR(120)       DEFAULT('0')
      ,iKey_2_field        VARCHAR(80)       DEFAULT('0')
      ,iKey_3_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_4_field        VARCHAR(100)       DEFAULT('0')
      ,iKey_5_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_7_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_9_field        VARCHAR(50)       DEFAULT('0')
      ,iRuleSid            VARCHAR(50)       DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iRuleID             VARCHAR(50)
      ,iRuleDesc           VARCHAR(100)
      ,iCopyRuleID         VARCHAR(50)
      ,iCopyRuleDesc       VARCHAR(100)
      ,iStageReason        VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(255)
      ,record_id           INT
      ,static_gid          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #HighDollarClaimRules
          (SearchID
          ,iRuleID
          ,iRuleDesc
          ,iCopyRuleID
          ,iStageReason
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*RuleID], '')
          ,ISNULL([*RuleDesc], '')
          ,ISNULL([CopyfromRuleID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([StagingReason]), 'HDCLM')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_HighDollarClaimRules
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #HighDollarClaimRules
       SET iUserID  = @user

	   SELECT * FROM #HighDollarClaimRules
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
DECLARE HighDollarClaimRules_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iRuleGid
       ,iKey_2_field
       ,iKey_3_field
       ,iKey_4_field
       ,iKey_5_field
       ,iKey_6_field
       ,iKey_7_field
       ,iKey_8_field
       ,iKey_9_field
       ,iRuleSid
       ,iAction
       ,iDate_Time_Modified
       ,iUserID
       ,iRuleID
       ,iRuleDesc
       ,iCopyRuleID
       ,iCopyRuleDesc
       ,iStageReason
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #HighDollarClaimRules

   OPEN HighDollarClaimRules_Cursor
  FETCH NEXT FROM HighDollarClaimRules_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iRuleGid
       ,@iKey_2_field
       ,@iKey_3_field
       ,@iKey_4_field
       ,@iKey_5_field
       ,@iKey_6_field
       ,@iKey_7_field
       ,@iKey_8_field
       ,@iKey_9_field
       ,@iRuleSid
       ,@iAction
       ,@iDate_Time_Modified
       ,@iUserID
       ,@iRuleID
       ,@iRuleDesc
       ,@iCopyRuleID
       ,@iCopyRuleDesc
       ,@iStageReason
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

			EXEC dbo.prMaxDollarAddModify
                 @iEntityName
                ,@iRuleGid
                ,@iKey_2_field
                ,@iKey_3_field
                ,@iKey_4_field
                ,@iKey_5_field
                ,@iKey_6_field
                ,@iKey_7_field
                ,@iKey_8_field
                ,@iKey_9_field
                ,@iRuleSid
                ,@iAction
                ,@iDate_Time_Modified
                ,@iUserID
                ,@iRuleID
                ,@iRuleDesc
                ,@iCopyRuleID
                ,@iCopyRuleDesc
                ,@iStageReason
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.MaxDollarPendRules
				   SET RuleGid					= @static_gid 
				 WHERE record_status			= 'A'
				   AND RuleId					= @iRuleID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRuleID, @iRuleDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM HighDollarClaimRules_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iRuleGid
             ,@iKey_2_field
             ,@iKey_3_field
             ,@iKey_4_field
             ,@iKey_5_field
             ,@iKey_6_field
             ,@iKey_7_field
             ,@iKey_8_field
             ,@iKey_9_field
             ,@iRuleSid
             ,@iAction
             ,@iDate_Time_Modified
             ,@iUserID
             ,@iRuleID
             ,@iRuleDesc
             ,@iCopyRuleID
             ,@iCopyRuleDesc
             ,@iStageReason
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE HighDollarClaimRules_Cursor
DEALLOCATE HighDollarClaimRules_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#HighDollarClaimRules') IS NOT NULL
	DROP TABLE #HighDollarClaimRules

END
GO

