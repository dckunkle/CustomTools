IF OBJECT_ID('dbo.spDCAuto_CreateTerminationReasons') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTerminationReasons AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTerminationReasons
Purpose:    Create terminationreasons data from CorderAutomation
Method:     TerminationReasons
Screen GID: 3301
Procedure:  dbo.prTerm_Reasons_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTerminationReasons '100-Config%', 22, 'TerminationReasons'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTerminationReasons
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_Entity_name                 VARCHAR(20)
       ,@i_old_Termination_Reason_Code VARCHAR(100)
       ,@i_Term_Reasons_sid            VARCHAR(50)
       ,@i_old_Term_entity             VARCHAR(50)
       ,@i_TermReasonGID               VARCHAR(50)
       ,@i_key_5_field                 VARCHAR(50)
       ,@i_key_6_field                 VARCHAR(50)
       ,@i_key_7_field                 VARCHAR(50)
       ,@i_key_8_field                 VARCHAR(50)
       ,@i_key_9_field                 VARCHAR(50)
       ,@i_key_10_field                VARCHAR(50)
       ,@i_action                      VARCHAR(10)
       ,@l_modified_date               VARCHAR(30)
       ,@iUserID                       VARCHAR(25)
       ,@i_Term_Reason_Code            VARCHAR(6)
       ,@i_Term_Reason                 VARCHAR(50)
       ,@i_entityType                  CHAR(1)
       ,@i_Cov_Term_Period             CHAR(1)
       ,@i_LapseHold                   CHAR(1)
       ,@i_Manual_Adj                  CHAR(1)
       ,@i_ChangeFunding_Dbill         CHAR(1)
       ,@i_Resubmit_Claim              CHAR(1)
       ,@i_Maint_Reason_Code           VARCHAR(6)
       ,@i_Maint_Reason_Desc           VARCHAR(50)
       ,@iAMRC                         VARCHAR(1)
	   ,@iFFM						   VARCHAR(2)
       ,@i_terminate_future_coverages  CHAR(1)
       ,@i_policy_Level_Terminate      CHAR(1)
       ,@i_non_payment_exception       CHAR(1)
       ,@o_status                      INT
       ,@o_message                     VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TerminationReasons') IS NOT NULL
	DROP TABLE #TerminationReasons

CREATE TABLE #TerminationReasons
      (i_Entity_name                 VARCHAR(20)       DEFAULT('Term_Reasons')
      ,i_old_Termination_Reason_Code VARCHAR(100)      DEFAULT('0')
      ,i_Term_Reasons_sid            VARCHAR(50)       DEFAULT('0')
      ,i_old_Term_entity             VARCHAR(50)       DEFAULT('0')
      ,i_TermReasonGID               VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                VARCHAR(50)       DEFAULT('0')
      ,i_action                      VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date               VARCHAR(30)       DEFAULT('')
      ,iUserID                       VARCHAR(25)       DEFAULT('')
      ,i_Term_Reason_Code            VARCHAR(50)
      ,i_Term_Reason                 VARCHAR(100)
      ,i_entityType                  VARCHAR(50)
      ,i_Cov_Term_Period             VARCHAR(50)
      ,i_LapseHold                   VARCHAR(50)
      ,i_Manual_Adj                  VARCHAR(50)
      ,i_ChangeFunding_Dbill         VARCHAR(50)
      ,i_Resubmit_Claim              VARCHAR(50)
      ,i_Maint_Reason_Code           VARCHAR(50)
      ,i_Maint_Reason_Desc           VARCHAR(50)
      ,iAMRC                         VARCHAR(50)
	  ,iFFM							 VARCHAR(50)
      ,i_terminate_future_coverages  VARCHAR(50)
      ,i_policy_Level_Terminate      VARCHAR(50)
      ,i_non_payment_exception       VARCHAR(50)
      ,o_status                      INT
      ,o_message                     VARCHAR(200)
      ,record_id                     INT
      ,static_gid                    INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TerminationReasons
      (i_Term_Reason_Code
      ,i_Term_Reason
      ,i_entityType
      ,i_Cov_Term_Period
      ,i_LapseHold
      ,i_Manual_Adj
      ,i_ChangeFunding_Dbill
      ,i_Resubmit_Claim
      ,i_Maint_Reason_Code
      ,iAMRC
	  ,iFFM
      ,i_terminate_future_coverages
      ,i_policy_Level_Terminate
      ,i_non_payment_exception
      ,record_id
      ,static_gid)
SELECT ISNULL([*TermReasonCode], '')
      ,ISNULL([*TermReasonDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Entity]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CovTermPeriod]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AcctStatusInLapse]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RefundWManualAdj]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ChangeFundDirectBill]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ResubmitClaims]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([834MaintReasonCode]), '')
      ,ISNULL([834AMRC], '0')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FFMBaselineTermCancelReason]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TermFutureCov]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PolicyLevelTerm]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NonPayException]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TerminationReason
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TerminationReasons
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TerminationReasons_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_old_Termination_Reason_Code
       ,i_Term_Reasons_sid
       ,i_old_Term_entity
       ,i_TermReasonGID
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_Term_Reason_Code
       ,i_Term_Reason
       ,i_entityType
       ,i_Cov_Term_Period
       ,i_LapseHold
       ,i_Manual_Adj
       ,i_ChangeFunding_Dbill
       ,i_Resubmit_Claim
       ,i_Maint_Reason_Code
       ,i_Maint_Reason_Desc
       ,iAMRC
	   ,iFFM
       ,i_terminate_future_coverages
       ,i_policy_Level_Terminate
       ,i_non_payment_exception
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TerminationReasons

   OPEN TerminationReasons_Cursor
  FETCH NEXT FROM TerminationReasons_Cursor
   INTO @i_Entity_name
       ,@i_old_Termination_Reason_Code
       ,@i_Term_Reasons_sid
       ,@i_old_Term_entity
       ,@i_TermReasonGID
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_Term_Reason_Code
       ,@i_Term_Reason
       ,@i_entityType
       ,@i_Cov_Term_Period
       ,@i_LapseHold
       ,@i_Manual_Adj
       ,@i_ChangeFunding_Dbill
       ,@i_Resubmit_Claim
       ,@i_Maint_Reason_Code
       ,@i_Maint_Reason_Desc
       ,@iAMRC
	   ,@iFFM
       ,@i_terminate_future_coverages
       ,@i_policy_Level_Terminate
       ,@i_non_payment_exception
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prTerm_Reasons_Add_Modify
             @i_Entity_name
            ,@i_old_Termination_Reason_Code
            ,@i_Term_Reasons_sid
            ,@i_old_Term_entity
            ,@i_TermReasonGID
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@i_Term_Reason_Code
            ,@i_Term_Reason
            ,@i_entityType
            ,@i_Cov_Term_Period
            ,@i_LapseHold
            ,@i_Manual_Adj
            ,@i_ChangeFunding_Dbill
            ,@i_Resubmit_Claim
            ,@i_Maint_Reason_Code
            ,@i_Maint_Reason_Desc
            ,@iAMRC
			,@iFFM
            ,@i_terminate_future_coverages
            ,@i_policy_Level_Terminate
            ,@i_non_payment_exception
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Get the current gid
				SELECT @current_gid				= term_Reasons_gid
				  FROM dbo.Term_Reasons
				 WHERE record_status			= 'A'
				   AND term_reasons_code		= @i_Term_Reason_Code

				-- Update to the static gid
				UPDATE dbo.Term_Reasons 
				   SET term_Reasons_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND term_reasons_code		= @i_Term_Reason_Code

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Term_Reason_Code, @i_Term_Reason, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TerminationReasons_Cursor
         INTO @i_Entity_name
             ,@i_old_Termination_Reason_Code
             ,@i_Term_Reasons_sid
             ,@i_old_Term_entity
             ,@i_TermReasonGID
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_Term_Reason_Code
             ,@i_Term_Reason
             ,@i_entityType
             ,@i_Cov_Term_Period
             ,@i_LapseHold
             ,@i_Manual_Adj
             ,@i_ChangeFunding_Dbill
             ,@i_Resubmit_Claim
             ,@i_Maint_Reason_Code
             ,@i_Maint_Reason_Desc
             ,@iAMRC
			 ,@iFFM
             ,@i_terminate_future_coverages
             ,@i_policy_Level_Terminate
             ,@i_non_payment_exception
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TerminationReasons_Cursor
DEALLOCATE TerminationReasons_Cursor

END
GO