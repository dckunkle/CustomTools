IF OBJECT_ID('dbo.spDCAuto_CreateRemarkCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRemarkCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRemarkCodes
Purpose:    Create remarkcodes data from CorderAutomation

Screen:     390
Method:     RemarkCodes
Procedure:  dbo.prProcessingPolicyAdd_Modify
Entity:     Processing_Policies

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2021	DK				Original procedure
08/30/2022	DK				Added EOB SVC Denail Flag
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRemarkCodes 'Accums-Config-1%', 22, 'Accums-Config', 'RemarkCodes', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRemarkCodes
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

DECLARE @i_entity_name          VARCHAR(50)
       ,@i_Key_Policy_Number    VARCHAR(50)
       ,@i_Key_Effective_date   VARCHAR(50)
       ,@i_Key_Termination_date VARCHAR(50)
       ,@i_key_4_field          VARCHAR(50)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(50)
       ,@i_date_time_modified   VARCHAR(50)
       ,@iUserID                VARCHAR(50)
       ,@i_Policy_Number        VARCHAR(50)
       ,@i_Policy_Type          VARCHAR(50)
       ,@i_Effective_Date       VARCHAR(50)
       ,@i_Termination_Date     VARCHAR(50)
       ,@i_Savings_Category     VARCHAR(50)
       ,@i_Deny_Whole_Claim     VARCHAR(50)
       ,@i_Message              VARCHAR(600)
       ,@i_EOB_Message          VARCHAR(600)
       ,@i_display_code         VARCHAR(50)
       ,@i_penalty_exempt_code  VARCHAR(50)
       ,@i_offset_code          VARCHAR(50)
       ,@i_offset_desc          VARCHAR(600)
       ,@i_in_finance_response  VARCHAR(50)
       ,@i_out_finance_response VARCHAR(50)
       ,@i_remark_security      VARCHAR(50)
       ,@i_clean_claim          VARCHAR(50)
       ,@i_funding_exc          VARCHAR(50)
	   ,@i_SVC_flag             VARCHAR(50)
       ,@i_277_status           VARCHAR(50)
       ,@i_277_status_desc      VARCHAR(50)
       ,@i_277_pend             VARCHAR(50)
       ,@i_277_pend_desc        VARCHAR(50)
       ,@i_277_nonpend          VARCHAR(50)
       ,@i_277_nonpend_desc     VARCHAR(50)
       ,@i_835_remark           VARCHAR(50)
       ,@i_835_remark_desc      VARCHAR(50)
       ,@i_835_group            VARCHAR(50)
       ,@i_835_group_desc       VARCHAR(50)
       ,@i_835_reason           VARCHAR(50)
       ,@i_835_reason_desc      VARCHAR(50)
       ,@i_ncdpdp_reject        VARCHAR(50)
       ,@i_ncpdp_desc           VARCHAR(100)
       ,@i_cda_resp_code        VARCHAR(50)
       ,@i_cda_desc             VARCHAR(100)
       ,@i_cpa_resp_code        VARCHAR(50)
       ,@i_cpa_desc             VARCHAR(100)
       ,@o_status               INT
       ,@o_message              VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RemarkCodes') IS NOT NULL
	DROP TABLE #RemarkCodes

CREATE TABLE #RemarkCodes
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(50)       DEFAULT('Processing_Policies')
      ,i_Key_Policy_Number    VARCHAR(50)       DEFAULT('0')
      ,i_Key_Effective_date   VARCHAR(50)       DEFAULT('0')
      ,i_Key_Termination_date VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,i_Policy_Number        VARCHAR(50)
      ,i_Policy_Type          VARCHAR(50)
      ,i_Effective_Date       VARCHAR(50)
      ,i_Termination_Date     VARCHAR(50)
      ,i_Savings_Category     VARCHAR(50)
      ,i_Deny_Whole_Claim     VARCHAR(50)
      ,i_Message              VARCHAR(600)
      ,i_EOB_Message          VARCHAR(600)
      ,i_display_code         VARCHAR(50)
      ,i_penalty_exempt_code  VARCHAR(50)
      ,i_offset_code          VARCHAR(50)
      ,i_offset_desc          VARCHAR(600)
      ,i_in_finance_response  VARCHAR(50)
      ,i_out_finance_response VARCHAR(50)
      ,i_remark_security      VARCHAR(50)
      ,i_clean_claim          VARCHAR(50)
      ,i_funding_exc          VARCHAR(50)
	  ,i_SVC_flag             VARCHAR(50)
      ,i_277_status           VARCHAR(50)
      ,i_277_status_desc      VARCHAR(50)
      ,i_277_pend             VARCHAR(50)
      ,i_277_pend_desc        VARCHAR(50)
      ,i_277_nonpend          VARCHAR(50)
      ,i_277_nonpend_desc     VARCHAR(50)
      ,i_835_remark           VARCHAR(50)
      ,i_835_remark_desc      VARCHAR(50)
      ,i_835_group            VARCHAR(50)
      ,i_835_group_desc       VARCHAR(50)
      ,i_835_reason           VARCHAR(50)
      ,i_835_reason_desc      VARCHAR(50)
      ,i_ncdpdp_reject        VARCHAR(50)
      ,i_ncpdp_desc           VARCHAR(100)
      ,i_cda_resp_code        VARCHAR(50)
      ,i_cda_desc             VARCHAR(100)
      ,i_cpa_resp_code        VARCHAR(50)
      ,i_cpa_desc             VARCHAR(100)
      ,o_status               INT
      ,o_message              VARCHAR(100)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #RemarkCodes
          (SearchID
          ,i_Policy_Number
          ,i_Policy_Type
          ,i_Effective_Date
          ,i_Termination_Date
          ,i_Savings_Category
          ,i_Deny_Whole_Claim
          ,i_Message
          ,i_EOB_Message
          ,i_display_code
          ,i_penalty_exempt_code
          ,i_offset_code
          ,i_in_finance_response
          ,i_out_finance_response
          ,i_remark_security
          ,i_clean_claim
          ,i_funding_exc
		  ,i_SVC_flag
          ,i_277_status
          ,i_277_pend
          ,i_277_nonpend
          ,i_835_remark
          ,i_835_group
          ,i_835_reason
          ,i_ncdpdp_reject
          ,i_cda_resp_code
          ,i_cpa_resp_code
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*Common_RemarkCode], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_RemarkCodeType]), 'C')
      	  ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      	  ,ISNULL([*Common_TerminationDate], '12/31/9999')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TrackingCategory]), '1')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DenyAllClaimLines]), 'N')
      	  ,ISNULL([*Common_DefaultMessage], '')
      	  ,ISNULL([Common_EOBMessage], '')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DisplayCode]), 'Y')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PenaltyExempt]), '')
      	  ,ISNULL([Common_OffsetCode], '')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_InNetworkFinResp]), 'D')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_OutNetworkFinResp]), 'D')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_RemarkCodeSecurityLevel]), 'N/A')
      	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CleanClaimStatusOverride]), 'D')
     	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ExcludeFromFundingReimburse]), 'N')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EOBSVCDenialFlag]), '')
      	  ,ISNULL([HIPPAMAP_277StatusCodeID], '')
      	  ,ISNULL([HIPPAMAP_277PendCategoryID], '')
      	  ,ISNULL([HIPPAMAP_277NonPendCategoryID], '')
      	  ,ISNULL([HIPPAMAP_835RemarkCodeID], '')
      	  ,ISNULL([HIPPAMAP_835AdjustmentGroupID], '')
      	  ,ISNULL([HIPPAMAP_835AdjustmentReasonID], '')
      	  ,ISNULL([HIPPAMAP_NCPDPRejectCode], '')
      	  ,ISNULL([HIPPAMAP_CDAResponseCode], '')
      	  ,ISNULL([HIPPAMAP_CPAResponseCode], '')
      	  ,ISNULL([RecordID], '')
      	  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_RemarkCodes
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #RemarkCodes
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
DECLARE RemarkCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Key_Policy_Number
       ,i_Key_Effective_date
       ,i_Key_Termination_date
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
       ,i_Policy_Number
       ,i_Policy_Type
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Savings_Category
       ,i_Deny_Whole_Claim
       ,i_Message
       ,i_EOB_Message
       ,i_display_code
       ,i_penalty_exempt_code
       ,i_offset_code
       ,i_offset_desc
       ,i_in_finance_response
       ,i_out_finance_response
       ,i_remark_security
       ,i_clean_claim
       ,i_funding_exc
	   ,i_SVC_flag
       ,i_277_status
       ,i_277_status_desc
       ,i_277_pend
       ,i_277_pend_desc
       ,i_277_nonpend
       ,i_277_nonpend_desc
       ,i_835_remark
       ,i_835_remark_desc
       ,i_835_group
       ,i_835_group_desc
       ,i_835_reason
       ,i_835_reason_desc
       ,i_ncdpdp_reject
       ,i_ncpdp_desc
       ,i_cda_resp_code
       ,i_cda_desc
       ,i_cpa_resp_code
       ,i_cpa_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #RemarkCodes

   OPEN RemarkCodes_Cursor
  FETCH NEXT FROM RemarkCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Key_Policy_Number
       ,@i_Key_Effective_date
       ,@i_Key_Termination_date
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
       ,@i_Policy_Number
       ,@i_Policy_Type
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Savings_Category
       ,@i_Deny_Whole_Claim
       ,@i_Message
       ,@i_EOB_Message
       ,@i_display_code
       ,@i_penalty_exempt_code
       ,@i_offset_code
       ,@i_offset_desc
       ,@i_in_finance_response
       ,@i_out_finance_response
       ,@i_remark_security
       ,@i_clean_claim
       ,@i_funding_exc
	   ,@i_SVC_flag
       ,@i_277_status
       ,@i_277_status_desc
       ,@i_277_pend
       ,@i_277_pend_desc
       ,@i_277_nonpend
       ,@i_277_nonpend_desc
       ,@i_835_remark
       ,@i_835_remark_desc
       ,@i_835_group
       ,@i_835_group_desc
       ,@i_835_reason
       ,@i_835_reason_desc
       ,@i_ncdpdp_reject
       ,@i_ncpdp_desc
       ,@i_cda_resp_code
       ,@i_cda_desc
       ,@i_cpa_resp_code
       ,@i_cpa_desc
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

			EXEC dbo.prProcessingPolicyAdd_Modify
                 @i_entity_name
                ,@i_Key_Policy_Number
                ,@i_Key_Effective_date
                ,@i_Key_Termination_date
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
                ,@i_Policy_Number
                ,@i_Policy_Type
                ,@i_Effective_Date
                ,@i_Termination_Date
                ,@i_Savings_Category
                ,@i_Deny_Whole_Claim
                ,@i_Message
                ,@i_EOB_Message
                ,@i_display_code
                ,@i_penalty_exempt_code
                ,@i_offset_code
                ,@i_offset_desc
                ,@i_in_finance_response
                ,@i_out_finance_response
                ,@i_remark_security
                ,@i_clean_claim
                ,@i_funding_exc
				,@i_SVC_flag				-- SP48
                ,@i_277_status
                ,@i_277_status_desc
                ,@i_277_pend
                ,@i_277_pend_desc
                ,@i_277_nonpend
                ,@i_277_nonpend_desc
                ,@i_835_remark
                ,@i_835_remark_desc
                ,@i_835_group
                ,@i_835_group_desc
                ,@i_835_reason
                ,@i_835_reason_desc
                ,@i_ncdpdp_reject
                ,@i_ncpdp_desc
                ,@i_cda_resp_code
                ,@i_cda_desc
                ,@i_cpa_resp_code
                ,@i_cpa_desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Policy_Number, @i_Policy_Type, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM RemarkCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Key_Policy_Number
             ,@i_Key_Effective_date
             ,@i_Key_Termination_date
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
             ,@i_Policy_Number
             ,@i_Policy_Type
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Savings_Category
             ,@i_Deny_Whole_Claim
             ,@i_Message
             ,@i_EOB_Message
             ,@i_display_code
             ,@i_penalty_exempt_code
             ,@i_offset_code
             ,@i_offset_desc
             ,@i_in_finance_response
             ,@i_out_finance_response
             ,@i_remark_security
             ,@i_clean_claim
             ,@i_funding_exc
			 ,@i_SVC_flag
             ,@i_277_status
             ,@i_277_status_desc
             ,@i_277_pend
             ,@i_277_pend_desc
             ,@i_277_nonpend
             ,@i_277_nonpend_desc
             ,@i_835_remark
             ,@i_835_remark_desc
             ,@i_835_group
             ,@i_835_group_desc
             ,@i_835_reason
             ,@i_835_reason_desc
             ,@i_ncdpdp_reject
             ,@i_ncpdp_desc
             ,@i_cda_resp_code
             ,@i_cda_desc
             ,@i_cpa_resp_code
             ,@i_cpa_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE RemarkCodes_Cursor
DEALLOCATE RemarkCodes_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#RemarkCodes') IS NOT NULL
	DROP TABLE #RemarkCodes

END
GO

