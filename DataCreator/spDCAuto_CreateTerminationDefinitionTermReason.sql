IF OBJECT_ID('dbo.spDCAuto_CreateTerminationDefinitionTermReason') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTerminationDefinitionTermReason AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTerminationDefinitionTermReason
Purpose:    Create terminationdefinitiontermreason data from CorderAutomation
Method:     TerminationDefinitionTermReason
Screen GID: 3300
Procedure:  dbo.prTerm_Rules_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTerminationDefinitionTermReason '100-Config%', 22, 'TerminationDefinitionTermReason'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTerminationDefinitionTermReason
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

DECLARE @i_Entity_name                VARCHAR(50)
       ,@i_Term_rules_gid             VARCHAR(50)
       ,@i_Term_rules_sid             VARCHAR(50)
       ,@i_old_term_entity            VARCHAR(50)
       ,@i_key_4_field                VARCHAR(50)
       ,@i_key_5_field                VARCHAR(100)
       ,@i_key_6_field                VARCHAR(50)
       ,@i_key_7_field                VARCHAR(50)
       ,@i_key_8_field                VARCHAR(50)
       ,@i_key_9_field                VARCHAR(50)
       ,@i_key_10_field               VARCHAR(50)
       ,@i_action                     VARCHAR(10)
       ,@l_modified_date              VARCHAR(30)
       ,@iUserID                      VARCHAR(25)
       ,@i_Term_Rules_ID              VARCHAR(25)
       ,@i_Term_Rules_Desc            VARCHAR(50)
       ,@i_Term_Reason_Code           VARCHAR(6)
       ,@i_Term_Reason                VARCHAR(50)
       ,@i_entityType                 CHAR(1)
       ,@i_Cov_Term_Period            CHAR(1)
       ,@i_LapseHold                  CHAR(1)
       ,@i_Manual_Adj                 CHAR(1)
       ,@i_ChangeFunding_Dbill        CHAR(1)
       ,@i_Resubmit_Claim             CHAR(1)
       ,@i_Maint_Reason_Code          VARCHAR(6)
       ,@i_Maint_Reason_Desc          VARCHAR(50)
       ,@i_terminate_future_coverages CHAR(1)
       ,@i_policy_Level_Terminate     CHAR(1)
       ,@o_status                     INT
       ,@o_message                    VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TerminationDefinitionTermReason') IS NOT NULL
	DROP TABLE #TerminationDefinitionTermReason

CREATE TABLE #TerminationDefinitionTermReason
      (i_Entity_name                VARCHAR(50)       DEFAULT('Term_Rules_Details')
      ,i_Term_rules_gid             VARCHAR(50)       DEFAULT('0')
      ,i_Term_rules_sid             VARCHAR(50)       DEFAULT('0')
      ,i_old_term_entity            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field               VARCHAR(50)       DEFAULT('0')
      ,i_action                     VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date              VARCHAR(30)       DEFAULT('')
      ,iUserID                      VARCHAR(25)       DEFAULT('')
      ,i_Term_Rules_ID              VARCHAR(25)
      ,i_Term_Rules_Desc            VARCHAR(50)
      ,i_Term_Reason_Code           VARCHAR(6)
      ,i_Term_Reason                VARCHAR(50)
      ,i_entityType                 VARCHAR(50)		  DEFAULT('M')
      ,i_Cov_Term_Period            VARCHAR(50)
      ,i_LapseHold                  VARCHAR(50)
      ,i_Manual_Adj                 VARCHAR(50)
      ,i_ChangeFunding_Dbill        VARCHAR(50)
      ,i_Resubmit_Claim             VARCHAR(50)
      ,i_Maint_Reason_Code          VARCHAR(6)
      ,i_Maint_Reason_Desc          VARCHAR(50)
      ,i_terminate_future_coverages VARCHAR(50)
      ,i_policy_Level_Terminate     VARCHAR(50)
      ,o_status                     INT
      ,o_message                    VARCHAR(200)
      ,record_id                    INT
      ,static_gid                   INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TerminationDefinitionTermReason
      (i_Term_Rules_ID
      ,i_Term_Reason_Code
      ,i_Cov_Term_Period
      ,i_LapseHold
      ,i_Manual_Adj
      ,i_ChangeFunding_Dbill
      ,i_Resubmit_Claim
      ,i_Maint_Reason_Code
      ,i_terminate_future_coverages
      ,record_id
      ,static_gid)
SELECT ISNULL([*SearchTermDefID], '')
      ,ISNULL([*TermReasonCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CoverageTermPeriod]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AccountStatusLapseHold]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RefundManualAdj]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ChangeFundingDirectBill]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ResubmitClaims]), 'N')
      ,ISNULL([834MaintReasonCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TermFutureCoverages]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TerminationDefinitionTermReason
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TerminationDefinitionTermReason
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TerminationDefinitionTermReason_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Term_rules_gid
       ,i_Term_rules_sid
       ,i_old_term_entity
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_Term_Rules_ID
       ,i_Term_Rules_Desc
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
       ,i_terminate_future_coverages
       ,i_policy_Level_Terminate
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TerminationDefinitionTermReason

   OPEN TerminationDefinitionTermReason_Cursor
  FETCH NEXT FROM TerminationDefinitionTermReason_Cursor
   INTO @i_Entity_name
       ,@i_Term_rules_gid
       ,@i_Term_rules_sid
       ,@i_old_term_entity
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_Term_Rules_ID
       ,@i_Term_Rules_Desc
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
       ,@i_terminate_future_coverages
       ,@i_policy_Level_Terminate
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Need to lookup the current gid to pass into the stored procedure call
		SELECT @current_gid			= EN.entity_gid
		  FROM Entity_Names			EN
		 WHERE EN.record_status		= 'A'
		   AND EN.entity_identifier	= 'Term_Rules_Name'
		   AND EN.entity_user_id	= @i_Term_Rules_ID

		EXEC dbo.prTerm_Rules_Add_Modify
             @i_Entity_name
            ,@current_gid                     -- @i_Term_rules_gid
            ,@i_Term_rules_sid
            ,@i_old_term_entity
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@i_Term_Rules_ID
            ,@i_Term_Rules_Desc
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
            ,@i_terminate_future_coverages
            ,@i_policy_Level_Terminate
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		--IF ISNULL(@static_gid, 0) > 0
		--	BEGIN

		--		-- Get the current gid
		--		SELECT @current_gid				= current_gid
		--		  FROM dbo.SomeTable
		--		 WHERE record_status			= 'A'

		--		-- Update to the static gid
		--		UPDATE dbo.SomeTable 
		--		   SET entity_gid				= @static_gid 
		--		 WHERE record_status			= 'A'

		--	END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Term_Rules_ID, @i_Term_Reason_Code, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TerminationDefinitionTermReason_Cursor
         INTO @i_Entity_name
             ,@i_Term_rules_gid
             ,@i_Term_rules_sid
             ,@i_old_term_entity
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_Term_Rules_ID
             ,@i_Term_Rules_Desc
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
             ,@i_terminate_future_coverages
             ,@i_policy_Level_Terminate
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TerminationDefinitionTermReason_Cursor
DEALLOCATE TerminationDefinitionTermReason_Cursor

END
GO