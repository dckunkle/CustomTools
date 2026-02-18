IF OBJECT_ID('dbo.spDCAuto_CreateGroupSubGroups') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupSubGroups AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupSubGroups
Purpose:    Create groupsubgroups data from CorderAutomation
Method:     GroupSubGroups
Screen GID: 14
Procedure:  dbo.prGroupInfoAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/18/2019	DK				Original procedure
12/29/2021	DK				When searching for the parent group, search groups in EC and the LOB
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupSubGroups '500-TestCase-250%', 22, '500-TestCase-250', 'GroupSubGroups', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupSubGroups
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
	   ,@child_gid					INT
	   ,@parent_gid					INT
	   ,@demographic_gid			INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name               VARCHAR(50)
       ,@i_group_gid                 VARCHAR(50)
       ,@i_key_2_field               VARCHAR(50)
       ,@i_key_3_field               VARCHAR(50)
       ,@i_key_4_field               VARCHAR(50)
       ,@i_key_5_field               VARCHAR(50)
       ,@i_key_6_field               VARCHAR(50)
       ,@i_key_7_field               VARCHAR(50)
       ,@i_key_8_field               VARCHAR(50)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_key_10_field              VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_Date_Time_Modified        VARCHAR(30)
       ,@iUserid                     VARCHAR(25)
       ,@i_group_id                  VARCHAR(50)
       ,@i_group_name                VARCHAR(180)
       ,@i_group_short_name          VARCHAR(50)
       ,@i_group_sort_name           VARCHAR(50)
       ,@i_extern_id                 VARCHAR(50)
       ,@i_prior_id                  VARCHAR(50)
       ,@i_effective_date            VARCHAR(50)
       ,@i_termination_date          VARCHAR(50)
       ,@i_Group_status              VARCHAR(50)
       ,@i_termination_reason        VARCHAR(50)
       ,@i_additional_term_data      VARCHAR(50)
       ,@i_ein_number                VARCHAR(50)
       ,@i_organization_type         VARCHAR(50)
       ,@i_address_1                 VARCHAR(55)
       ,@i_address_2                 VARCHAR(55)
       ,@i_zip_Code                  VARCHAR(50)
       ,@i_city                      VARCHAR(50)
       ,@i_state                     VARCHAR(50)
       ,@i_county                    VARCHAR(50)
       ,@i_country                   VARCHAR(50)
       ,@i_phone_Number              VARCHAR(50)
       ,@i_fax_Number                VARCHAR(50)
       ,@i_Website_url               VARCHAR(50)
       ,@i_COB_valid_days            VARCHAR(50)
       ,@i_renewal_notification      VARCHAR(50)
       ,@i_Industry_code             VARCHAR(50)
       ,@i_Industry_code_desc        VARCHAR(200)
       ,@i_Default_lob               VARCHAR(50)
       ,@i_Estimated_Enrollees       VARCHAR(50)
       ,@i_Service_Info              VARCHAR(50)
       ,@i_marketer                  VARCHAR(50)
       ,@i_division                  VARCHAR(50)
       ,@i_program_id                VARCHAR(50)
       ,@i_eligibility_required      VARCHAR(50)
       ,@i_auto_gen_dependents       VARCHAR(50)
       ,@i_sub_address_change        VARCHAR(50)
       ,@i_dep_address_change        VARCHAR(50)
       ,@i_verification_source       VARCHAR(50)
       ,@i_verification_frequency    VARCHAR(50)
       ,@i_elig_media                VARCHAR(50)
       ,@i_elig_type                 VARCHAR(50)
       ,@i_elig_receipt_frequency    VARCHAR(50)
       ,@i_do_not_send_late_let      VARCHAR(50)
       ,@i_elig_grace_days           VARCHAR(50)
       ,@i_claim_payment_hold_days   VARCHAR(50)
       ,@i_claim_census_hold_days    VARCHAR(50)
       ,@i_retro_time                VARCHAR(50)
       ,@i_retro_num                 INT
       ,@i_run_out_days              VARCHAR(50)
       ,@i_bene_extension_days       VARCHAR(50)
       ,@i_Cascade_Group             VARCHAR(50)
       ,@i_Cascade_Member            VARCHAR(50)
       ,@i_tba_by_lob                VARCHAR(50)
       ,@i_sync_member_flags         VARCHAR(50)
       ,@i_sync_effective_date       VARCHAR(50)
       ,@i_sync_lob_date_compare     VARCHAR(50)
       ,@i_sync_ptd_date_compare     VARCHAR(50)
       ,@i_sync_lob_grouper_id       VARCHAR(50)
       ,@i_sync_lob_grouper_desc     VARCHAR(100)
       ,@i_business_level            VARCHAR(50)
       ,@i_coverage_code_calc        VARCHAR(50)
       ,@i_ortho_payment_type        VARCHAR(50)
       ,@i_ortho_max_initial_payment DECIMAL(5)
       ,@i_ortho_max_addl_payments   DECIMAL(5)
       ,@i_ortho_initial_pmnt_rule   VARCHAR(50)
       ,@i_letter_option             VARCHAR(50)
       ,@i_dedicated_business_unit   VARCHAR(50)
       ,@i_ext_processing_policy     VARCHAR(50)
       ,@i_grp_cross_checking        VARCHAR(50)
       ,@i_grp_deductible            VARCHAR(50)
       ,@i_grp_ortho_maximum         VARCHAR(50)
       ,@i_grp_maximum               VARCHAR(50)
       ,@i_filed_fee_id              VARCHAR(50)
       ,@i_filed_fee_desc            VARCHAR(100)
       ,@i_portal_access             VARCHAR(50)
       ,@i_portal_insurer            VARCHAR(50)
       ,@i_elig_auto                 VARCHAR(50)
       ,@i_send_834                  VARCHAR(50)
       ,@i_last_renew_date           VARCHAR(50)
       ,@i_next_renew_date           VARCHAR(50)
       ,@i_cms_group_size            VARCHAR(50)
       ,@i_preferred_lang            VARCHAR(50)
       ,@i_allow_batch_update_of_ptd VARCHAR(50)
       ,@i_external_bill_type        VARCHAR(50)
       ,@i_MaxDollarID               VARCHAR(50)
       ,@i_MaxDollarDescr            VARCHAR(100)
       ,@i_Acct_Type                 VARCHAR(50)
       ,@i_Acct_Name                 VARCHAR(100)
       ,@i_ABA_Number                VARCHAR(50)
       ,@i_Institution_Name          VARCHAR(50)
       ,@i_Acct_Number               VARCHAR(50)
       ,@i_CC_Auth_Number            VARCHAR(50)
       ,@i_CC_Month                  VARCHAR(50)
       ,@i_CC_Year                   VARCHAR(50)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(500)
       ,@return_xml                  XML
       ,@i_Batch                     VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupSubGroups') IS NOT NULL
	DROP TABLE #GroupSubGroups

CREATE TABLE #GroupSubGroups
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Sub_Groups')
      ,i_group_gid                 VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified        VARCHAR(30)       DEFAULT('')
      ,iUserid                     VARCHAR(25)       DEFAULT('')
      ,i_group_id                  VARCHAR(50)
      ,i_group_name                VARCHAR(180)
      ,i_group_short_name          VARCHAR(50)
      ,i_group_sort_name           VARCHAR(50)
      ,i_extern_id                 VARCHAR(50)
      ,i_prior_id                  VARCHAR(50)
      ,i_effective_date            VARCHAR(50)
      ,i_termination_date          VARCHAR(50)
      ,i_Group_status              VARCHAR(50)
      ,i_termination_reason        VARCHAR(50)
      ,i_additional_term_data      VARCHAR(50)
      ,i_ein_number                VARCHAR(50)
      ,i_organization_type         VARCHAR(50)
      ,i_address_1                 VARCHAR(55)
      ,i_address_2                 VARCHAR(55)
      ,i_zip_Code                  VARCHAR(50)
      ,i_city                      VARCHAR(50)
      ,i_state                     VARCHAR(50)
      ,i_county                    VARCHAR(50)
      ,i_country                   VARCHAR(50)
      ,i_phone_Number              VARCHAR(50)
      ,i_fax_Number                VARCHAR(50)
      ,i_Website_url               VARCHAR(50)
      ,i_COB_valid_days            VARCHAR(50)
      ,i_renewal_notification      VARCHAR(50)
      ,i_Industry_code             VARCHAR(50)
      ,i_Industry_code_desc        VARCHAR(200)
      ,i_Default_lob               VARCHAR(50)
      ,i_Estimated_Enrollees       VARCHAR(50)
      ,i_Service_Info              VARCHAR(50)
      ,i_marketer                  VARCHAR(50)
      ,i_division                  VARCHAR(50)
      ,i_program_id                VARCHAR(50)
      ,i_eligibility_required      VARCHAR(50)
      ,i_auto_gen_dependents       VARCHAR(50)
      ,i_sub_address_change        VARCHAR(50)
      ,i_dep_address_change        VARCHAR(50)
      ,i_verification_source       VARCHAR(50)
      ,i_verification_frequency    VARCHAR(50)
      ,i_elig_media                VARCHAR(50)
      ,i_elig_type                 VARCHAR(50)
      ,i_elig_receipt_frequency    VARCHAR(50)
      ,i_do_not_send_late_let      VARCHAR(50)
      ,i_elig_grace_days           VARCHAR(50)
      ,i_claim_payment_hold_days   VARCHAR(50)
      ,i_claim_census_hold_days    VARCHAR(50)
      ,i_retro_time                VARCHAR(50)
      ,i_retro_num                 INT
      ,i_run_out_days              VARCHAR(50)
      ,i_bene_extension_days       VARCHAR(50)
      ,i_Cascade_Group             VARCHAR(50)
      ,i_Cascade_Member            VARCHAR(50)
      ,i_tba_by_lob                VARCHAR(50)
      ,i_sync_member_flags         VARCHAR(50)
      ,i_sync_effective_date       VARCHAR(50)       DEFAULT('N')
      ,i_sync_lob_date_compare     VARCHAR(50)       DEFAULT('N')
      ,i_sync_ptd_date_compare     VARCHAR(50)       DEFAULT('N')
      ,i_sync_lob_grouper_id       VARCHAR(50)
      ,i_sync_lob_grouper_desc     VARCHAR(100)
      ,i_business_level            VARCHAR(50)
      ,i_coverage_code_calc        VARCHAR(50)
      ,i_ortho_payment_type        VARCHAR(50)
      ,i_ortho_max_initial_payment DECIMAL(5)
      ,i_ortho_max_addl_payments   DECIMAL(5)
      ,i_ortho_initial_pmnt_rule   VARCHAR(50)
      ,i_letter_option             VARCHAR(50)
      ,i_dedicated_business_unit   VARCHAR(50)
      ,i_ext_processing_policy     VARCHAR(50)
      ,i_grp_cross_checking        VARCHAR(50)
      ,i_grp_deductible            VARCHAR(50)
      ,i_grp_ortho_maximum         VARCHAR(50)
      ,i_grp_maximum               VARCHAR(50)
      ,i_filed_fee_id              VARCHAR(50)
      ,i_filed_fee_desc            VARCHAR(100)
      ,i_portal_access             VARCHAR(50)
      ,i_portal_insurer            VARCHAR(50)
      ,i_elig_auto                 VARCHAR(50)
      ,i_send_834                  VARCHAR(50)
      ,i_last_renew_date           VARCHAR(50)
      ,i_next_renew_date           VARCHAR(50)
      ,i_cms_group_size            VARCHAR(50)
      ,i_preferred_lang            VARCHAR(50)
      ,i_allow_batch_update_of_ptd VARCHAR(50)
      ,i_external_bill_type        VARCHAR(50)
      ,i_MaxDollarID               VARCHAR(50)
      ,i_MaxDollarDescr            VARCHAR(100)
      ,i_Acct_Type                 VARCHAR(50)
      ,i_Acct_Name                 VARCHAR(100)
      ,i_ABA_Number                VARCHAR(50)
      ,i_Institution_Name          VARCHAR(50)
      ,i_Acct_Number               VARCHAR(50)
      ,i_CC_Auth_Number            VARCHAR(50)
      ,i_CC_Month                  VARCHAR(50)
      ,i_CC_Year                   VARCHAR(50)
      ,o_status                    INT
      ,o_message                   VARCHAR(500)
      ,return_xml                  XML
      ,i_Batch                     VARCHAR(50)
      ,record_id                   INT
      ,static_gid                  INT)

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (address1			VARCHAR(200)
      ,address2   		VARCHAR(200)
      ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
      ,County  			VARCHAR(200)
      ,Country 			VARCHAR(200) 
      ,status  			INT
      ,Message			VARCHAR(200))  

IF OBJECT_ID('tempdb.dbo.#City') IS NOT NULL
	DROP TABLE #City

CREATE TABLE #City
      (FieldNumber		VARCHAR(200)  
      ,Reference_Type 	VARCHAR(200)
      ,Short_Desc		VARCHAR(200)
      ,Description   	VARCHAR(200)
      ,Seq_Num			VARCHAR(200))  

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupSubGroups
      (SearchID
      ,i_group_id
      ,i_group_name
      ,i_group_short_name
      ,i_group_sort_name
      ,i_extern_id
      ,i_prior_id
      ,i_effective_date
      ,i_termination_date
      ,i_Group_status
      ,i_termination_reason
      ,i_additional_term_data
      ,i_ein_number
      ,i_organization_type
      ,i_address_1
      ,i_address_2
      ,i_zip_Code
      ,i_city
      ,i_state
      ,i_county
      ,i_country
      ,i_phone_Number
      ,i_fax_Number
      ,i_Website_url
      ,i_COB_valid_days
      ,i_renewal_notification
      ,i_Industry_code
      ,i_Default_lob
      ,i_Estimated_Enrollees
      ,i_Service_Info
      ,i_marketer
      ,i_division
      ,i_program_id
      ,i_eligibility_required
      ,i_auto_gen_dependents
      ,i_sub_address_change
      ,i_dep_address_change
      ,i_verification_source
      ,i_verification_frequency
      ,i_elig_media
      ,i_elig_type
      ,i_elig_receipt_frequency
      ,i_do_not_send_late_let
      ,i_elig_grace_days
      ,i_claim_payment_hold_days
      ,i_claim_census_hold_days
      ,i_retro_time
      ,i_retro_num
      ,i_run_out_days
      ,i_bene_extension_days
      ,i_Cascade_Group
      ,i_Cascade_Member
      ,i_tba_by_lob
      ,i_sync_member_flags
      ,i_sync_lob_grouper_id
      ,i_business_level
      ,i_coverage_code_calc
      ,i_ortho_payment_type
      ,i_ortho_max_initial_payment
      ,i_ortho_max_addl_payments
      ,i_ortho_initial_pmnt_rule
      ,i_letter_option
      ,i_dedicated_business_unit
      ,i_ext_processing_policy
      ,i_grp_cross_checking
      ,i_grp_deductible
      ,i_grp_ortho_maximum
      ,i_grp_maximum
      ,i_filed_fee_id
      ,i_portal_access
      ,i_portal_insurer
      ,i_elig_auto
      ,i_send_834
      ,i_last_renew_date
      ,i_next_renew_date
      ,i_cms_group_size
      ,i_preferred_lang
      ,i_allow_batch_update_of_ptd
      ,i_external_bill_type
      ,i_MaxDollarID
      ,i_Acct_Type
      ,i_Acct_Name
      ,i_ABA_Number
      ,i_Acct_Number
      ,i_CC_Auth_Number
      ,i_CC_Month
      ,i_CC_Year
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_GroupID], '')
      ,ISNULL([*Common_GroupName], '')
      ,ISNULL([*Common_ShortName], '')
      ,ISNULL([Common_SortName], '')
      ,ISNULL([Common_ExternalID], '')
      ,ISNULL([Common_PriorID], '')
      ,ISNULL([*Common_EffectiveDate], '00/00/0000')
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Status]), '02')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TerminationReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AdditionalTermData]), '')
      ,ISNULL([Common_EIN], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_OrgType]), '')
      ,ISNULL([Common_AddrLine1], '')
      ,ISNULL([Common_AddrLine2], '')
      ,ISNULL([Common_ZipCode], '')
      ,ISNULL([Common_City], '')
      ,ISNULL([Common_State], '')
      ,ISNULL([Common_County], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Country]), 'US')
      ,ISNULL([Common_PhoneNumber], '0000000000')
      ,ISNULL([Common_FaxNumber], '0000000000')
      ,ISNULL([Common_InternetAddr], '')
      ,ISNULL([Common_COBValidDays], '365')
      ,ISNULL([Common_RenewalNotification], '90')
      ,ISNULL([Common_Industry], '9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_LOB]), 'CBCOB')
      ,ISNULL([Common_EstEnrollees], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ServiceInfo]), '')
      ,ISNULL([Common_Marketer], '')
      ,ISNULL([Common_Division], '')
      ,ISNULL([Common_ProgNumberID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_EligibilityReq]), 'R')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_AutoGenDependents]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_SubAddrChg]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_DepAddrChg]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_MemberVerSource]), '1')
      ,ISNULL([Elig_MemberVerFreq], '365')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_EligMedia]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_EligType]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_EligFreq]), '4')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_DoNotSendLateLtr]), 'N')
      ,ISNULL([Elig_PmtGraceDays], '0')
      ,ISNULL([Elig_PaymentHoldDays], '30')
      ,ISNULL([Elig_CensusHoldDays], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_RetroTermPeriod]), 'D')
      ,ISNULL([Elig_RetroNumPeriods], '90')
      ,ISNULL([Elig_RunOutDays], '365')
      ,ISNULL([Elig_MemberBnftExtDays], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_CascadeTermToSubGrps]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_CascadeTermToMembers]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_TBAByLOB]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Elig_SynchMemberBillCobra]), 'N')
      ,ISNULL([Elig_LOBGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_BusinessLevel]), 'G')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_CoverageCodeCalc]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_OrthoPaymType]), 'R')
      ,ISNULL([Misc_OrthoMaxInitialPmnt], '0.00')
      ,ISNULL([Misc_OrthoMaxAddlPmnt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_OrthoInitialPmntRule]), '2')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_NonParLetter]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_DedicatedBusUnit]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_ExternalProcessPol]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_GroupForCrossChecking]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_GroupForDeductible]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_LifetimeMax]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_GroupForMaximum]), 'Y')
      ,ISNULL([Misc_GroupSchedFeeID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PortalAccessRestricted]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PortalInsurer]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_EligLoadAutoGenMember]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_IncludeIn834Outbound]), 'Y')
      ,ISNULL([Misc_LastRenewalDate], '01/01/1900')
      ,ISNULL([Misc_NextRenewalDate], '01/01/1900')
      ,ISNULL([Misc_CMSGroupSizeCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PreferredLanguage]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_AllowBatchUpdateofPTD]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_ExternalBillType]), '')
      ,ISNULL([Misc_HighDollarClaimRuleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BCCInfo_AcctType]), '')
      ,ISNULL([BCCInfo_NameOnAcct], '')
      ,ISNULL([BCCInfo_ABANumber], '')
      ,ISNULL([BCCInfo_AcctNumber], '')
      ,ISNULL([BCCInfo_CardAuthNumber], '')
      ,ISNULL([BCCInfo_CardExpMonth], '')
      ,ISNULL([BCCInfo_CardExpYear], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Group_Subgroup
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupSubGroups
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupSubGroups_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_group_gid
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
       ,iUserid
       ,i_group_id
       ,i_group_name
       ,i_group_short_name
       ,i_group_sort_name
       ,i_extern_id
       ,i_prior_id
       ,i_effective_date
       ,i_termination_date
       ,i_Group_status
       ,i_termination_reason
       ,i_additional_term_data
       ,i_ein_number
       ,i_organization_type
       ,i_address_1
       ,i_address_2
       ,i_zip_Code
       ,i_city
       ,i_state
       ,i_county
       ,i_country
       ,i_phone_Number
       ,i_fax_Number
       ,i_Website_url
       ,i_COB_valid_days
       ,i_renewal_notification
       ,i_Industry_code
       ,i_Industry_code_desc
       ,i_Default_lob
       ,i_Estimated_Enrollees
       ,i_Service_Info
       ,i_marketer
       ,i_division
       ,i_program_id
       ,i_eligibility_required
       ,i_auto_gen_dependents
       ,i_sub_address_change
       ,i_dep_address_change
       ,i_verification_source
       ,i_verification_frequency
       ,i_elig_media
       ,i_elig_type
       ,i_elig_receipt_frequency
       ,i_do_not_send_late_let
       ,i_elig_grace_days
       ,i_claim_payment_hold_days
       ,i_claim_census_hold_days
       ,i_retro_time
       ,i_retro_num
       ,i_run_out_days
       ,i_bene_extension_days
       ,i_Cascade_Group
       ,i_Cascade_Member
       ,i_tba_by_lob
       ,i_sync_member_flags
       ,i_sync_effective_date
       ,i_sync_lob_date_compare
       ,i_sync_ptd_date_compare
       ,i_sync_lob_grouper_id
       ,i_sync_lob_grouper_desc
       ,i_business_level
       ,i_coverage_code_calc
       ,i_ortho_payment_type
       ,i_ortho_max_initial_payment
       ,i_ortho_max_addl_payments
       ,i_ortho_initial_pmnt_rule
       ,i_letter_option
       ,i_dedicated_business_unit
       ,i_ext_processing_policy
       ,i_grp_cross_checking
       ,i_grp_deductible
       ,i_grp_ortho_maximum
       ,i_grp_maximum
       ,i_filed_fee_id
       ,i_filed_fee_desc
       ,i_portal_access
       ,i_portal_insurer
       ,i_elig_auto
       ,i_send_834
       ,i_last_renew_date
       ,i_next_renew_date
       ,i_cms_group_size
       ,i_preferred_lang
       ,i_allow_batch_update_of_ptd
       ,i_external_bill_type
       ,i_MaxDollarID
       ,i_MaxDollarDescr
       ,i_Acct_Type
       ,i_Acct_Name
       ,i_ABA_Number
       ,i_Institution_Name
       ,i_Acct_Number
       ,i_CC_Auth_Number
       ,i_CC_Month
       ,i_CC_Year
       ,o_status
       ,o_message
       ,return_xml
       ,i_Batch
       ,record_id
       ,static_gid
   FROM #GroupSubGroups

   OPEN GroupSubGroups_Cursor
  FETCH NEXT FROM GroupSubGroups_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_group_gid
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
       ,@iUserid
       ,@i_group_id
       ,@i_group_name
       ,@i_group_short_name
       ,@i_group_sort_name
       ,@i_extern_id
       ,@i_prior_id
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Group_status
       ,@i_termination_reason
       ,@i_additional_term_data
       ,@i_ein_number
       ,@i_organization_type
       ,@i_address_1
       ,@i_address_2
       ,@i_zip_Code
       ,@i_city
       ,@i_state
       ,@i_county
       ,@i_country
       ,@i_phone_Number
       ,@i_fax_Number
       ,@i_Website_url
       ,@i_COB_valid_days
       ,@i_renewal_notification
       ,@i_Industry_code
       ,@i_Industry_code_desc
       ,@i_Default_lob
       ,@i_Estimated_Enrollees
       ,@i_Service_Info
       ,@i_marketer
       ,@i_division
       ,@i_program_id
       ,@i_eligibility_required
       ,@i_auto_gen_dependents
       ,@i_sub_address_change
       ,@i_dep_address_change
       ,@i_verification_source
       ,@i_verification_frequency
       ,@i_elig_media
       ,@i_elig_type
       ,@i_elig_receipt_frequency
       ,@i_do_not_send_late_let
       ,@i_elig_grace_days
       ,@i_claim_payment_hold_days
       ,@i_claim_census_hold_days
       ,@i_retro_time
       ,@i_retro_num
       ,@i_run_out_days
       ,@i_bene_extension_days
       ,@i_Cascade_Group
       ,@i_Cascade_Member
       ,@i_tba_by_lob
       ,@i_sync_member_flags
       ,@i_sync_effective_date
       ,@i_sync_lob_date_compare
       ,@i_sync_ptd_date_compare
       ,@i_sync_lob_grouper_id
       ,@i_sync_lob_grouper_desc
       ,@i_business_level
       ,@i_coverage_code_calc
       ,@i_ortho_payment_type
       ,@i_ortho_max_initial_payment
       ,@i_ortho_max_addl_payments
       ,@i_ortho_initial_pmnt_rule
       ,@i_letter_option
       ,@i_dedicated_business_unit
       ,@i_ext_processing_policy
       ,@i_grp_cross_checking
       ,@i_grp_deductible
       ,@i_grp_ortho_maximum
       ,@i_grp_maximum
       ,@i_filed_fee_id
       ,@i_filed_fee_desc
       ,@i_portal_access
       ,@i_portal_insurer
       ,@i_elig_auto
       ,@i_send_834
       ,@i_last_renew_date
       ,@i_next_renew_date
       ,@i_cms_group_size
       ,@i_preferred_lang
       ,@i_allow_batch_update_of_ptd
       ,@i_external_bill_type
       ,@i_MaxDollarID
       ,@i_MaxDollarDescr
       ,@i_Acct_Type
       ,@i_Acct_Name
       ,@i_ABA_Number
       ,@i_Institution_Name
       ,@i_Acct_Number
       ,@i_CC_Auth_Number
       ,@i_CC_Month
       ,@i_CC_Year
       ,@o_status
       ,@o_message
       ,@return_xml
       ,@i_Batch
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get any missing pieces of the address that would normally be populated in the UI
			TRUNCATE TABLE #Addresses
			INSERT INTO #Addresses
			  EXEC prGroupAddressTabOff 'Address', '', '', '', '', '', '', '', '', '', '', '', '', '', @i_address_1, @i_address_2, @i_zip_Code, @i_city, @i_State, '', @i_Country, '', '', '', '', '', '', '', '', '0', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'ADD', 0, 0, ''

			--Get the preferred city name
			TRUNCATE TABLE #City
			INSERT INTO #City
			  EXEC prCityVaryCombo 'CITY', '18', @i_zip_Code

			SELECT TOP 1
				   @i_address_1			= A.address1
				  ,@i_address_2			= A.address2
			 	  ,@i_zip_Code			= A.zip
				  ,@i_State				= CASE WHEN ISNULL(@i_state, '') = '' THEN A.state ELSE @i_state END
				  ,@i_county			= CASE WHEN ISNULL(@i_county, '') = '' THEN A.county ELSE @i_county END
				  ,@i_Country			= CASE WHEN ISNULL(@i_Country, '') = '' THEN A.country ELSE @i_Country END
			FROM #Addresses				A

			SELECT TOP 1
				  @i_city				= CASE WHEN ISNULL(@i_city, '') = '' THEN C.Short_Desc ELSE @i_city END
			  FROM #City				C

			-- Get the group information to pass to the populate stored procedure
			SELECT @i_group_gid				= EC.child_gid
				  ,@i_key_2_field			= EC.child_identifier
			      ,@i_key_3_field			= EC.parent_gid
				  ,@i_key_4_field			= EC.parent_identifier
				  ,@i_key_5_field			= ''
				  ,@i_key_6_field			= ''
				  ,@i_key_7_field			= 0
				  ,@i_key_8_field			= 'SUB_GROUP:N'
				  ,@i_key_9_field			= ''
			  FROM Groups					G
			  JOIN Eligibility_Coverage		EC
			    ON G.group_gid				= EC.group_gid
			 WHERE G.group_id				= @SearchID
			   AND G.record_status			= 'A'
			   AND EC.record_status			= 'A'
			   AND EC.parent_identifier		= 'G'
			   AND EC.child_identifier		= 'G'
			   AND EC.default_lob			= @i_Default_lob

			EXEC dbo.prGroupInfoAddModify
				 @i_entity_name
				,@i_group_gid
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
				,@iUserid
				,@i_group_id
				,@i_group_name
				,@i_group_short_name
				,@i_group_sort_name
				,@i_extern_id
				,@i_prior_id
				,@i_effective_date
				,@i_termination_date
				,@i_Group_status
				,@i_termination_reason
				,@i_additional_term_data
				,@i_ein_number
				,@i_organization_type
				,@i_address_1
				,@i_address_2
				,@i_zip_Code
				,@i_city
				,@i_state
				,@i_county
				,@i_country
				,@i_phone_Number
				,@i_fax_Number
				,@i_Website_url
				,@i_COB_valid_days
				,@i_renewal_notification
				,@i_Industry_code
				,@i_Industry_code_desc
				,@i_Default_lob
				,@i_Estimated_Enrollees
				,@i_Service_Info
				,@i_marketer
				,@i_division
				,@i_program_id
				,@i_eligibility_required
				,@i_auto_gen_dependents
				,@i_sub_address_change
				,@i_dep_address_change
				,@i_verification_source
				,@i_verification_frequency
				,@i_elig_media
				,@i_elig_type
				,@i_elig_receipt_frequency
				,@i_do_not_send_late_let
				,@i_elig_grace_days
				,@i_claim_payment_hold_days
				,@i_claim_census_hold_days
				,@i_retro_time
				,@i_retro_num
				,@i_run_out_days
				,@i_bene_extension_days
				,@i_Cascade_Group
				,@i_Cascade_Member
				,@i_tba_by_lob
				,@i_sync_member_flags
				,@i_sync_effective_date
				,@i_sync_lob_date_compare
				,@i_sync_ptd_date_compare
				,@i_sync_lob_grouper_id
				,@i_sync_lob_grouper_desc
				,@i_business_level
				,@i_coverage_code_calc
				,@i_ortho_payment_type
				,@i_ortho_max_initial_payment
				,@i_ortho_max_addl_payments
				,@i_ortho_initial_pmnt_rule
				,@i_letter_option
				,@i_dedicated_business_unit
				,@i_ext_processing_policy
				,@i_grp_cross_checking
				,@i_grp_deductible
				,@i_grp_ortho_maximum
				,@i_grp_maximum
				,@i_filed_fee_id
				,@i_filed_fee_desc
				,@i_portal_access
				,@i_portal_insurer
				,@i_elig_auto
				,@i_send_834
				,@i_last_renew_date
				,@i_next_renew_date
				,@i_cms_group_size
				,@i_preferred_lang
				,@i_allow_batch_update_of_ptd
				,@i_external_bill_type
				,@i_MaxDollarID
				,@i_MaxDollarDescr
				,@i_Acct_Type
				,@i_Acct_Name
				,@i_ABA_Number
				,@i_Institution_Name
				,@i_Acct_Number
				,@i_CC_Auth_Number
				,@i_CC_Month
				,@i_CC_Year
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

				-- Update to the static gid
				SELECT @current_gid				= G.group_gid
				  FROM Groups					G
				 WHERE G.record_status			= 'A'
				   AND G.group_id				= @i_group_id

				SELECT @child_gid				= EC.child_gid
				      ,@parent_gid				= EC.parent_gid
				  FROM dbo.Eligibility_Coverage	EC
				 WHERE EC.record_status			= 'A'
				   AND EC.group_gid				= @current_gid
				   AND EC.child_identifier		= 'G'
				   AND EC.parent_identifier		= 'G'

				UPDATE dbo.Groups 
				   SET group_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND group_gid				= @current_gid

				UPDATE dbo.Eligibility_Coverage	
				   SET group_gid				= @static_gid
					  ,child_gid				= @static_gid
				 WHERE group_gid				= @current_gid
				   AND parent_identifier		= 'G'
				   AND child_identifier			= 'G'
				   AND child_gid				= @child_gid
				   AND parent_gid				= @parent_gid

				UPDATE dbo.Entity_Paid_Thru	
				   SET group_gid				= @static_gid
					  ,child_gid				= @static_gid
				 WHERE group_gid				= @current_gid
				   AND child_gid				= @child_gid
				   AND parent_gid				= @parent_gid
				   AND record_status			= 'A'
				      
				UPDATE dbo.Context_Relation
				   SET entity_gid				= @static_gid
				 WHERE entity_type				= 'GROUP'
				   AND entity_gid				= @current_gid
				   AND record_status			= 'A'

				SELECT @demographic_gid			= CR.demographic_gid
				  FROM Contact_Relation			CR
				 WHERE CR.record_status			= 'A'
				   AND CR.entity_gid			= @current_gid

				UPDATE dbo.Contact_Relation		
				   SET entity_gid				= @static_gid
				      ,contact_relation_gid		= @static_gid
					  ,demographic_gid			= @static_gid
				 WHERE entity_identifier		= 'GROUPS'
				   AND record_status			= 'A'
				   AND entity_gid				= @current_gid

				UPDATE dbo.Demographics
				   SET demographic_gid			= @static_gid
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @demographic_gid

				UPDATE dbo.GroupTree
				   SET Child_gid				= @static_gid
					  ,Parent_gid				= @static_gid
				 WHERE Child_gid				= @child_gid
				   AND Parent_gid				= @child_gid
				   AND Super_gid				= @parent_gid
				   AND level					= 0

				UPDATE dbo.GroupTree
				   SET Child_gid				= @static_gid
				 WHERE Child_gid				= @child_gid
				   AND Parent_gid				= @parent_gid
				   AND Super_gid				= @parent_gid
				   AND level					= 1
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_group_id, @i_group_name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupSubGroups_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_group_gid
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
             ,@iUserid
             ,@i_group_id
             ,@i_group_name
             ,@i_group_short_name
             ,@i_group_sort_name
             ,@i_extern_id
             ,@i_prior_id
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Group_status
             ,@i_termination_reason
             ,@i_additional_term_data
             ,@i_ein_number
             ,@i_organization_type
             ,@i_address_1
             ,@i_address_2
             ,@i_zip_Code
             ,@i_city
             ,@i_state
             ,@i_county
             ,@i_country
             ,@i_phone_Number
             ,@i_fax_Number
             ,@i_Website_url
             ,@i_COB_valid_days
             ,@i_renewal_notification
             ,@i_Industry_code
             ,@i_Industry_code_desc
             ,@i_Default_lob
             ,@i_Estimated_Enrollees
             ,@i_Service_Info
             ,@i_marketer
             ,@i_division
             ,@i_program_id
             ,@i_eligibility_required
             ,@i_auto_gen_dependents
             ,@i_sub_address_change
             ,@i_dep_address_change
             ,@i_verification_source
             ,@i_verification_frequency
             ,@i_elig_media
             ,@i_elig_type
             ,@i_elig_receipt_frequency
             ,@i_do_not_send_late_let
             ,@i_elig_grace_days
             ,@i_claim_payment_hold_days
             ,@i_claim_census_hold_days
             ,@i_retro_time
             ,@i_retro_num
             ,@i_run_out_days
             ,@i_bene_extension_days
             ,@i_Cascade_Group
             ,@i_Cascade_Member
             ,@i_tba_by_lob
             ,@i_sync_member_flags
             ,@i_sync_effective_date
             ,@i_sync_lob_date_compare
             ,@i_sync_ptd_date_compare
             ,@i_sync_lob_grouper_id
             ,@i_sync_lob_grouper_desc
             ,@i_business_level
             ,@i_coverage_code_calc
             ,@i_ortho_payment_type
             ,@i_ortho_max_initial_payment
             ,@i_ortho_max_addl_payments
             ,@i_ortho_initial_pmnt_rule
             ,@i_letter_option
             ,@i_dedicated_business_unit
             ,@i_ext_processing_policy
             ,@i_grp_cross_checking
             ,@i_grp_deductible
             ,@i_grp_ortho_maximum
             ,@i_grp_maximum
             ,@i_filed_fee_id
             ,@i_filed_fee_desc
             ,@i_portal_access
             ,@i_portal_insurer
             ,@i_elig_auto
             ,@i_send_834
             ,@i_last_renew_date
             ,@i_next_renew_date
             ,@i_cms_group_size
             ,@i_preferred_lang
             ,@i_allow_batch_update_of_ptd
             ,@i_external_bill_type
             ,@i_MaxDollarID
             ,@i_MaxDollarDescr
             ,@i_Acct_Type
             ,@i_Acct_Name
             ,@i_ABA_Number
             ,@i_Institution_Name
             ,@i_Acct_Number
             ,@i_CC_Auth_Number
             ,@i_CC_Month
             ,@i_CC_Year
             ,@o_status
             ,@o_message
             ,@return_xml
             ,@i_Batch
             ,@record_id
             ,@static_gid
	END

CLOSE GroupSubGroups_Cursor
DEALLOCATE GroupSubGroups_Cursor

END
GO