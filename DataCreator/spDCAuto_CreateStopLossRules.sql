/**************************************************************************************************
Name:       spDCAuto_CreateStopLossRules
Purpose:    Create stoplossrules data from CorderAutomation

Screen:     850
Method:     StopLossRules
Procedure:  dbo.prStopLossRulesAddModify
Entity:     Stop_Loss

Date        User            Change
---------------------------------------------------------------------------------------------
10/09/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateStopLossRules 'Setup%', 999, 'StopLossRules', 'StopLossRules', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateStopLossRules
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

DECLARE @i_entity_name        VARCHAR(20)
       ,@i_key_sl_gid         VARCHAR(50)
       ,@i_key_sl_id          VARCHAR(10)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(10)
       ,@i_key_5_field        VARCHAR(10)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(10)
       ,@i_key_8_field        VARCHAR(10)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@iRuleID              VARCHAR(50)
       ,@iRuleDesc            VARCHAR(50)
       ,@iGroupAggrAmt        VARCHAR(50)
       ,@iMemberGroupAggrAmt  VARCHAR(50)
       ,@iMemberAggrAmt       VARCHAR(50)
       ,@iTolerancePercnt     VARCHAR(50)
       ,@iTimePeriod          VARCHAR(50)
       ,@iPeriodBasis         INT
       ,@iExceedRemarkCode    VARCHAR(50)
       ,@iExceedRemarkDesc    VARCHAR(500)
       ,@iToleranceRemarkCode VARCHAR(50)
       ,@iToleranceRemarkDesc VARCHAR(500)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#StopLossRules') IS NOT NULL
	DROP TABLE #StopLossRules

CREATE TABLE #StopLossRules
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(20)       DEFAULT('Stop_Loss')
      ,i_key_sl_gid         VARCHAR(50)       DEFAULT('0')
      ,i_key_sl_id          VARCHAR(10)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(10)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(10)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(10)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(10)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iRuleID              VARCHAR(50)
      ,iRuleDesc            VARCHAR(50)
      ,iGroupAggrAmt        VARCHAR(50)
      ,iMemberGroupAggrAmt  VARCHAR(50)
      ,iMemberAggrAmt       VARCHAR(50)
      ,iTolerancePercnt     VARCHAR(50)
      ,iTimePeriod          VARCHAR(50)
      ,iPeriodBasis         INT
      ,iExceedRemarkCode    VARCHAR(50)
      ,iExceedRemarkDesc    VARCHAR(500)
      ,iToleranceRemarkCode VARCHAR(50)
      ,iToleranceRemarkDesc VARCHAR(500)
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

    INSERT INTO #StopLossRules
          (SearchID
          ,iRuleID
          ,iRuleDesc
          ,iGroupAggrAmt
          ,iMemberGroupAggrAmt
          ,iMemberAggrAmt
          ,iTolerancePercnt
          ,iTimePeriod
          ,iPeriodBasis
          ,iExceedRemarkCode
          ,iToleranceRemarkCode
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*StopLossRulesID], '')
          ,ISNULL([*StopLossRulesDesc], '')
          ,ISNULL([*GroupSLAggregateAmt], '0')
          ,ISNULL([*Member/GroupSLAggregateAmt], '0')
          ,ISNULL([*MemberSLAggregateAmt], '0')
          ,ISNULL([*SLTolerancePercentage], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*StopLossTimePeriod]), 'C')
          ,ISNULL([*StopLossPeriodBasis], '1')
          ,ISNULL([SLExceedRemarkCode], '')
          ,ISNULL([SLwithToleranceRemarkCode], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_StopLossRules
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #StopLossRules
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
DECLARE StopLossRules_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_sl_gid
       ,i_key_sl_id
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
       ,iRuleID
       ,iRuleDesc
       ,iGroupAggrAmt
       ,iMemberGroupAggrAmt
       ,iMemberAggrAmt
       ,iTolerancePercnt
       ,iTimePeriod
       ,iPeriodBasis
       ,iExceedRemarkCode
       ,iExceedRemarkDesc
       ,iToleranceRemarkCode
       ,iToleranceRemarkDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #StopLossRules

   OPEN StopLossRules_Cursor
  FETCH NEXT FROM StopLossRules_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_sl_gid
       ,@i_key_sl_id
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
       ,@iRuleID
       ,@iRuleDesc
       ,@iGroupAggrAmt
       ,@iMemberGroupAggrAmt
       ,@iMemberAggrAmt
       ,@iTolerancePercnt
       ,@iTimePeriod
       ,@iPeriodBasis
       ,@iExceedRemarkCode
       ,@iExceedRemarkDesc
       ,@iToleranceRemarkCode
       ,@iToleranceRemarkDesc
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

			EXEC dbo.prStopLossRulesAddModify
                 @i_entity_name
                ,@i_key_sl_gid
                ,@i_key_sl_id
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
                ,@iRuleID
                ,@iRuleDesc
                ,@iGroupAggrAmt
                ,@iMemberGroupAggrAmt
                ,@iMemberAggrAmt
                ,@iTolerancePercnt
                ,@iTimePeriod
                ,@iPeriodBasis
                ,@iExceedRemarkCode
                ,@iExceedRemarkDesc
                ,@iToleranceRemarkCode
                ,@iToleranceRemarkDesc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Stop_Loss_Rules 
				   SET stop_loss_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND stop_loss_rule_id		= @iRuleID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRuleID, @iRuleDesc, @iTimePeriod, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM StopLossRules_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_sl_gid
             ,@i_key_sl_id
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
             ,@iRuleID
             ,@iRuleDesc
             ,@iGroupAggrAmt
             ,@iMemberGroupAggrAmt
             ,@iMemberAggrAmt
             ,@iTolerancePercnt
             ,@iTimePeriod
             ,@iPeriodBasis
             ,@iExceedRemarkCode
             ,@iExceedRemarkDesc
             ,@iToleranceRemarkCode
             ,@iToleranceRemarkDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE StopLossRules_Cursor
DEALLOCATE StopLossRules_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#StopLossRules') IS NOT NULL
	DROP TABLE #StopLossRules

END
GO

