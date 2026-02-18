/**************************************************************************************************
Name:       spDCAuto_CreateRFFClaimInsert
Purpose:    Create rffclaiminsert data from CorderAutomation

Screen:     0
Method:     RFFClaimInsert
Procedure:  dbo.prOLTPInsertClaimRecords
Entity:     

Date        User            Change
---------------------------------------------------------------------------------------------
09/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRFFClaimInsert 'RFF-Int-Run2-Claim%','7639', 'RFF-Int-Run2-Claim', 'RFFClaimInsert', 'RFF-Int-Run2-Claim'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateRFFClaimInsert
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
	   ,@claim_sid					INT
	   ,@is_paper					CHAR(1)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_claim_number              VARCHAR(15)
       ,@i_line_number               INT
       ,@i_service_date              VARCHAR(50)
       ,@i_date_submitted            DATETIME
       ,@i_receive_date              DATETIME
       ,@i_default_status            CHAR(1)
       ,@i_group_gid                 INT
       ,@i_contact_gid               INT
       ,@i_provider_gid              INT
       ,@i_location_gid              INT
       ,@i_business_gid              INT
       ,@i_specialty_id              VARCHAR(10)
       ,@i_claim_type                CHAR(1)
       ,@i_submitted_procedure_id    VARCHAR(20)
       ,@i_adjudicated_procedure_id  VARCHAR(50)
       ,@i_payment_procedure_id      VARCHAR(50)
       ,@i_incentive_requirement     VARCHAR(50)
       ,@i_modifier_1                VARCHAR(50)
       ,@i_modifier_2                VARCHAR(50)
       ,@i_modifier_3                VARCHAR(50)
       ,@i_modifier_4                VARCHAR(50)
       ,@i_modifier_5                VARCHAR(50)
       ,@i_modifier_6                VARCHAR(50)
       ,@i_modifier_7                VARCHAR(50)
       ,@i_modifier_8                VARCHAR(50)
       ,@i_modifier_9                VARCHAR(50)
       ,@i_modifier_10               VARCHAR(50)
       ,@i_submitted_cost            DECIMAL(9)
       ,@i_submitted_fee             DECIMAL(9)
       ,@i_submitted_tax             DECIMAL(9)
       ,@i_submitted_copay           DECIMAL(9)
       ,@i_approved_cost             DECIMAL(9)
       ,@i_approved_fee              DECIMAL(9)
       ,@i_approved_tax              DECIMAL(9)
       ,@i_approved_copay            DECIMAL(9)
       ,@i_allowed_cost              DECIMAL(9)
       ,@i_allowed_fee               DECIMAL(9)
       ,@i_allowed_tax               DECIMAL(9)
       ,@i_allowed_copay             DECIMAL(9)
       ,@i_payable_cost              DECIMAL(9)
       ,@i_payable_fee               DECIMAL(9)
       ,@i_payable_tax               DECIMAL(9)
       ,@i_payable_copay             DECIMAL(9)
       ,@i_billable_cost             DECIMAL(9)
       ,@i_billable_fee              DECIMAL(9)
       ,@i_billable_tax              DECIMAL(9)
       ,@i_billable_copay            DECIMAL(9)
       ,@i_gross_amount_due          DECIMAL(9)
       ,@i_usual_and_customary       DECIMAL(9)
       ,@i_product_type              VARCHAR(50)
       ,@i_amt_app_per_ded           MONEY
       ,@i_amt_app_per_mop           MONEY
       ,@i_amt_app_per_max           MONEY
       ,@i_document_number           VARCHAR(50)
       ,@i_network_search_gid        INT
       ,@i_network_gid               INT
       ,@i_plan_strategy_gid         INT
       ,@i_coverage_type             VARCHAR(50)
       ,@i_claim_source_flag         VARCHAR(50)
       ,@i_other_carrier_gid         INT
       ,@i_cob_subscriber            VARCHAR(50)
       ,@i_routing_number            VARCHAR(50)
       ,@i_version_number            VARCHAR(50)
       ,@i_transaction_code          VARCHAR(50)
       ,@i_prov_number               VARCHAR(60)
       ,@i_prov_ssn                  VARCHAR(50)
       ,@i_prov_state                VARCHAR(50)
       ,@i_group_number              VARCHAR(50)
       ,@i_member_id                 VARCHAR(50)
       ,@i_birth_date                VARCHAR(50)
       ,@i_first_name                VARCHAR(50)
       ,@i_last_name                 VARCHAR(60)
       ,@i_relationship_code         VARCHAR(50)
       ,@i_sex_of_patient            VARCHAR(50)
       ,@i_other_cov_code            VARCHAR(50)
       ,@i_other_cov_group           VARCHAR(50)
       ,@i_other_cov_id              VARCHAR(50)
       ,@i_other_cov_birth_date      VARCHAR(50)
       ,@i_prior_auth_gid            INT
       ,@i_plan_strategy_sid         INT
       ,@i_price_strategy_sid        INT
       ,@i_price_schedule_sid        INT
       ,@i_copay_strategy_sid        INT
       ,@i_copay_schedule_sid        INT
       ,@i_benefit_strategy_sid      INT
       ,@i_max_rules_sid             INT
       ,@i_ded_rules_sid             INT
       ,@i_mop_rules_sid             INT
       ,@i_proc_exclusion_sid        INT
       ,@i_coverage_strategy_sid     INT
       ,@i_proc_class_relation_sid   INT
       ,@i_proc_payment_sid          INT
       ,@i_proc_rules_sid            INT
       ,@i_proc_step_therapy_sid     INT
       ,@i_proc_xcheck_sid           INT
       ,@i_assignment_code           VARCHAR(50)
       ,@i_prime_pays_amount         MONEY
       ,@i_amt_remain_max            MONEY
       ,@i_amt_over_max              MONEY
       ,@i_incentive_level           FLOAT(8)
       ,@i_input_diagnosis_code      VARCHAR(50)
       ,@i_internal_diagnosis_code   VARCHAR(50)
       ,@i_prep_date                 VARCHAR(50)
       ,@i_seat_date                 VARCHAR(50)
       ,@i_fee_override              VARCHAR(50)
       ,@i_cob_indicated             VARCHAR(50)
       ,@i_comments_on_claim         VARCHAR(50)
       ,@i_member_referral           VARCHAR(50)
       ,@i_banding_date              VARCHAR(50)
       ,@i_case_fee                  MONEY
       ,@i_initial_down_payment      MONEY
       ,@i_treatment_months          INT
       ,@i_monthly_payment           MONEY
       ,@i_end_date                  VARCHAR(50)
       ,@i_initial_payment_amt       MONEY
       ,@i_additional_payments       INT
       ,@i_amount_of_each_payment    MONEY
       ,@i_total_to_be_paid          MONEY
       ,@i_subscriber_gid            INT
       ,@i_penalty_codes             VARCHAR(50)
       ,@i_ovrd_approved             MONEY
       ,@i_ovrd_allowed              MONEY
       ,@i_processing_policies       VARCHAR(50)
       ,@i_pay_as_class              VARCHAR(50)
       ,@i_pend_code                 VARCHAR(50)
       ,@i_final_flag                VARCHAR(50)
       ,@i_class_id                  INT
       ,@i_chart_date                VARCHAR(50)
       ,@i_accident_ind              VARCHAR(50)
       ,@i_cob_savings               MONEY
       ,@i_predet_number             VARCHAR(50)
       ,@i_clearing_number           VARCHAR(50)
       ,@i_user_id                   VARCHAR(50)
       ,@i_network_flag              VARCHAR(50)
       ,@i_status_code               VARCHAR(50)
       ,@i_site_id                   VARCHAR(50)
       ,@i_pro_rate                  VARCHAR(50)
       ,@i_benefit_type              VARCHAR(50)
       ,@i_claim_entry_update        VARCHAR(50)
       ,@o_insert_upd_flag           VARCHAR(50)
       ,@o_return_code               INT
       ,@o_num_rejects               INT
       ,@o_reject_codes              VARCHAR(80)
       ,@o_num_msgs                  INT
       ,@o_msgs                      VARCHAR(400)
       ,@l_Create_Resub_Recs         VARCHAR(50)
       ,@i_user_lob                  VARCHAR(50)
       ,@i_pos_claim_id              VARCHAR(50)
       ,@i_type_of_bill              VARCHAR(50)
       ,@i_diag_code_1               VARCHAR(50)
       ,@i_diag_code_2               VARCHAR(50)
       ,@i_diag_code_3               VARCHAR(50)
       ,@i_diag_code_4               VARCHAR(50)
       ,@i_diag_code_5               VARCHAR(50)
       ,@i_diag_code_6               VARCHAR(50)
       ,@i_diag_code_7               VARCHAR(50)
       ,@i_diag_code_8               VARCHAR(50)
       ,@i_diag_code_9               VARCHAR(50)
       ,@i_acc_code                  VARCHAR(50)
       ,@i_drg                       VARCHAR(50)
       ,@i_dischrg_status            VARCHAR(50)
       ,@i_prin_proc_code            VARCHAR(50)
       ,@i_claim_form_type           VARCHAR(50)
       ,@i_rev                       VARCHAR(50)
       ,@i_pos                       VARCHAR(50)
       ,@i_tos                       VARCHAR(50)
       ,@i_service_date_to           VARCHAR(50)
       ,@i_diag_ptr                  VARCHAR(128)
       ,@i_nc_chr                    DECIMAL(9)
       ,@i_ref_provider_gid          INT
       ,@i_ref_location_gid          INT
       ,@i_ref_business_gid          INT
       ,@i_atn_provider_gid          INT
       ,@i_atn_location_gid          INT
       ,@i_atn_business_gid          INT
       ,@iCodeParingGID              INT
       ,@iPrimaryDiagCode            VARCHAR(50)
       ,@iSecDiagCode                VARCHAR(50)
       ,@iDiagGrouper                VARCHAR(50)
       ,@iReportClass                VARCHAR(50)
       ,@iPatientCopay               MONEY
       ,@iTrueAllowed                MONEY
       ,@i_other_proc_code_A         VARCHAR(50)
       ,@i_other_proc_code_B         VARCHAR(50)
       ,@i_other_proc_code_C         VARCHAR(50)
       ,@i_other_proc_code_D         VARCHAR(50)
       ,@i_other_proc_code_E         VARCHAR(50)
       ,@i_person_code               VARCHAR(50)
       ,@iPatCoins                   MONEY
       ,@iPatNotCovered              MONEY
       ,@o_claim_sid                 INT
       ,@iAffiliationID              VARCHAR(50)
       ,@iManualIntAmt               MONEY
       ,@iFileSID                    INT
       ,@iEligCovSID                 DECIMAL(9)
       ,@iFeeScheduleID              VARCHAR(50)
       ,@iCopayDifferential          MONEY
       ,@i_inform_text               VARCHAR(61)
       ,@i_fill_num                  INT
       ,@i_diag_code_10              VARCHAR(50)
       ,@i_diag_code_11              VARCHAR(50)
       ,@i_diag_code_12              VARCHAR(50)
       ,@i_diag_code_13              VARCHAR(50)
       ,@i_diag_code_14              VARCHAR(50)
       ,@i_diag_code_15              VARCHAR(50)
       ,@i_diag_code_16              VARCHAR(50)
       ,@i_diag_code_17              VARCHAR(50)
       ,@i_diag_code_18              VARCHAR(50)
       ,@i_other_proc_code_date_a    VARCHAR(50)
       ,@i_other_proc_code_date_b    VARCHAR(50)
       ,@i_other_proc_code_date_c    VARCHAR(50)
       ,@i_other_proc_code_date_d    VARCHAR(50)
       ,@i_other_proc_code_date_e    VARCHAR(50)
       ,@i_cond_code_1               VARCHAR(50)
       ,@i_cond_code_2               VARCHAR(50)
       ,@i_cond_code_3               VARCHAR(50)
       ,@i_cond_code_4               VARCHAR(50)
       ,@i_cond_code_5               VARCHAR(50)
       ,@i_cond_code_6               VARCHAR(50)
       ,@i_cond_code_7               VARCHAR(50)
       ,@i_cond_code_8               VARCHAR(50)
       ,@i_cond_code_9               VARCHAR(50)
       ,@i_cond_code_10              VARCHAR(50)
       ,@i_cond_code_11              VARCHAR(50)
       ,@i_type_admn                 VARCHAR(50)
       ,@i_admit_dx                  VARCHAR(50)
       ,@i_pat_reason_dx_1           VARCHAR(50)
       ,@i_pat_reason_dx_2           VARCHAR(50)
       ,@i_pat_reason_dx_3           VARCHAR(50)
       ,@i_pps_code                  VARCHAR(50)
       ,@i_prin_proc_code_date       VARCHAR(50)
       ,@iCOBSavingsApplied          DECIMAL(9)
       ,@iCOBSavingsAccrued          DECIMAL(9)
       ,@i_member_address            VARCHAR(55)
       ,@i_member_address2           VARCHAR(55)
       ,@i_member_city               VARCHAR(50)
       ,@i_member_state              VARCHAR(50)
       ,@i_member_zip_code           VARCHAR(50)
       ,@i_member_middle_name        VARCHAR(50)
       ,@i_member_country            VARCHAR(50)
       ,@i_ben_code_837              VARCHAR(50)
       ,@i_special_prog_code         VARCHAR(50)
       ,@i_EPSDT                     VARCHAR(50)
       ,@i_other_proc_code_f         VARCHAR(50)
       ,@i_other_proc_code_date_f    VARCHAR(50)
       ,@i_other_proc_code_g         VARCHAR(50)
       ,@i_other_proc_code_date_g    VARCHAR(50)
       ,@i_other_proc_code_h         VARCHAR(50)
       ,@i_other_proc_code_date_h    VARCHAR(50)
       ,@i_other_proc_code_i         VARCHAR(50)
       ,@i_other_proc_code_date_i    VARCHAR(50)
       ,@i_other_proc_code_j         VARCHAR(50)
       ,@i_other_proc_code_date_j    VARCHAR(50)
       ,@i_other_proc_code_k         VARCHAR(50)
       ,@i_other_proc_code_date_k    VARCHAR(50)
       ,@i_other_proc_code_l         VARCHAR(50)
       ,@i_other_proc_code_date_l    VARCHAR(50)
       ,@i_other_proc_code_m         VARCHAR(50)
       ,@i_other_proc_code_date_m    VARCHAR(50)
       ,@i_other_proc_code_n         VARCHAR(50)
       ,@i_other_proc_code_date_n    VARCHAR(50)
       ,@i_other_proc_code_o         VARCHAR(50)
       ,@i_other_proc_code_date_o    VARCHAR(50)
       ,@i_other_proc_code_p         VARCHAR(50)
       ,@i_other_proc_code_date_p    VARCHAR(50)
       ,@i_other_proc_code_q         VARCHAR(50)
       ,@i_other_proc_code_date_q    VARCHAR(50)
       ,@i_other_proc_code_r         VARCHAR(50)
       ,@i_other_proc_code_date_r    VARCHAR(50)
       ,@i_other_proc_code_s         VARCHAR(50)
       ,@i_other_proc_code_date_s    VARCHAR(50)
       ,@i_other_proc_code_t         VARCHAR(50)
       ,@i_other_proc_code_date_t    VARCHAR(50)
       ,@i_other_proc_code_u         VARCHAR(50)
       ,@i_other_proc_code_date_u    VARCHAR(50)
       ,@i_other_proc_code_v         VARCHAR(50)
       ,@i_other_proc_code_date_v    VARCHAR(50)
       ,@i_other_proc_code_w         VARCHAR(50)
       ,@i_other_proc_code_date_w    VARCHAR(50)
       ,@i_other_proc_code_x         VARCHAR(50)
       ,@i_other_proc_code_date_x    VARCHAR(50)
       ,@i_diag_code_19              VARCHAR(50)
       ,@i_diag_code_20              VARCHAR(50)
       ,@i_diag_code_21              VARCHAR(50)
       ,@i_diag_code_22              VARCHAR(50)
       ,@i_diag_code_23              VARCHAR(50)
       ,@i_diag_code_24              VARCHAR(50)
       ,@i_diag_code_25              VARCHAR(50)
       ,@i_repricer_amount           DECIMAL(9)
       ,@IsPended                    VARCHAR(50)
       ,@StopLossClaim               VARCHAR(50)
       ,@iCleanClaimIndicator        VARCHAR(50)
       ,@iInitialEntry               VARCHAR(50)
       ,@bill_prov_gid               INT
       ,@bill_prov_loc_gid           INT
       ,@bill_prov_bus_gid           INT
       ,@pay_prov_gid                INT
       ,@pay_prov_loc_gid            INT
       ,@pay_prov_bus_gid            INT
       ,@i_submitted_drg             VARCHAR(50)
       ,@iDaysUsed                   INT
       ,@iAllowBonus                 VARCHAR(50)
       ,@iPrimaryBeneAmt             MONEY
       ,@poa                         VARCHAR(50)
       ,@other_sub_first_name        VARCHAR(50)
       ,@other_sub_last_name         VARCHAR(60)
       ,@other_sub_middle_name       VARCHAR(50)
       ,@other_sub_suffix            VARCHAR(50)
       ,@other_sub_id_code           VARCHAR(80)
       ,@other_sub_seq_num_code      VARCHAR(50)
       ,@other_sub_relationship      VARCHAR(50)
       ,@other_sub_policy_number     VARCHAR(50)
       ,@other_sub_type_code         VARCHAR(50)
       ,@other_sub_ins_type          VARCHAR(50)
       ,@other_sub_address           VARCHAR(55)
       ,@other_sub_address_2         VARCHAR(55)
       ,@other_sub_city              VARCHAR(50)
       ,@other_sub_state             VARCHAR(50)
       ,@other_sub_zip_code          VARCHAR(50)
       ,@other_sub_ssn               VARCHAR(50)
       ,@other_payer_last_name       VARCHAR(60)
       ,@other_payer_address         VARCHAR(55)
       ,@other_payer_address_2       VARCHAR(55)
       ,@other_payer_city            VARCHAR(50)
       ,@other_payer_state           VARCHAR(50)
       ,@other_payer_zip_code        VARCHAR(50)
       ,@cap_write_off               DECIMAL(9)
       ,@condition_date              DATETIME
       ,@condition_diagnosis         VARCHAR(50)
       ,@CLM11_RelCause1             VARCHAR(50)
       ,@CLM11_RelCause2             VARCHAR(50)
       ,@sub_pa_number               VARCHAR(50)
       ,@sub_ref_number              VARCHAR(50)
       ,@similar_date                DATETIME
       ,@acc_amt_app_per_ded         MONEY
       ,@acc_amt_app_per_mop         MONEY
       ,@acc_amt_app_per_max         MONEY
       ,@acc_max_rules_sid           INT
       ,@acc_ded_rules_sid           INT
       ,@acc_mop_rules_sid           INT
       ,@acc_amt_remain_max          MONEY
       ,@sec_bene_base_amt           MONEY
       ,@acc_DaysUsed                INT
       ,@IsAccident                  VARCHAR(50)
       ,@acc_state                   VARCHAR(50)
       ,@source_code                 VARCHAR(50)
       ,@FacilityName                VARCHAR(60)
       ,@FacilityNPI                 VARCHAR(80)
       ,@ClaimFrequencyCode          VARCHAR(50)
       ,@i_opr_provider_gid          INT
       ,@i_opr_location_gid          INT
       ,@i_opr_business_gid          INT
       ,@PurchasedServiceAmount      DECIMAL(9)
       ,@PurchasedServiceNPI         VARCHAR(80)
       ,@EmergencyIndicator          VARCHAR(50)
       ,@MJ_vs_UN                    VARCHAR(50)
       ,@LinePrimePaid               DECIMAL(9)
       ,@i_form_id                   VARCHAR(50)
       ,@i_sub_drg_soi               VARCHAR(50)
       ,@i_drg_soi                   VARCHAR(50)
       ,@i_drg_rom                   VARCHAR(50)
       ,@iOnOrigSubmission           VARCHAR(50)
       ,@iAuthMatchRuleSID           INT
       ,@iTradingPartnerGID          INT
       ,@i_icd_code_type             NVARCHAR(4)
       ,@i_provMatchingUsedBL_SHL    VARCHAR(50)
       ,@i_ProcessType               VARCHAR(50)
       ,@iAdjudicationOrder          INT
       ,@iPaymentIntegrityRemarkCode VARCHAR(50)
       ,@iAlternativeMemberResp      DECIMAL(9)
       ,@iGroupPricingSID            INT
       ,@iManualOverride             VARCHAR(50)
       ,@iManualOvrAllow             MONEY
       ,@iManualOvrApprove           MONEY
       ,@iManualRemarkCode           VARCHAR(50)
       ,@iManualNetwork              VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RFFClaimInsert') IS NOT NULL
	DROP TABLE #RFFClaimInsert

CREATE TABLE #RFFClaimInsert
      (SearchID                    VARCHAR(200)
      ,i_claim_number              VARCHAR(15)
      ,i_line_number               INT
      ,i_service_date              VARCHAR(50)
      ,i_date_submitted            DATETIME
      ,i_receive_date              DATETIME
      ,i_default_status            CHAR(1)
      ,i_group_gid                 INT
      ,i_contact_gid               INT
      ,i_provider_gid              INT
      ,i_location_gid              INT
      ,i_business_gid              INT
      ,i_specialty_id              VARCHAR(10)
      ,i_claim_type                CHAR(1)
      ,i_submitted_procedure_id    VARCHAR(20)
      ,i_adjudicated_procedure_id  VARCHAR(50)
      ,i_payment_procedure_id      VARCHAR(50)
      ,i_incentive_requirement     VARCHAR(50)
      ,i_modifier_1                VARCHAR(50)
      ,i_modifier_2                VARCHAR(50)
      ,i_modifier_3                VARCHAR(50)
      ,i_modifier_4                VARCHAR(50)
      ,i_modifier_5                VARCHAR(50)
      ,i_modifier_6                VARCHAR(50)
      ,i_modifier_7                VARCHAR(50)
      ,i_modifier_8                VARCHAR(50)
      ,i_modifier_9                VARCHAR(50)
      ,i_modifier_10               VARCHAR(50)
      ,i_submitted_cost            DECIMAL(9)
      ,i_submitted_fee             DECIMAL(9)
      ,i_submitted_tax             DECIMAL(9)
      ,i_submitted_copay           DECIMAL(9)
      ,i_approved_cost             DECIMAL(9)
      ,i_approved_fee              DECIMAL(9)
      ,i_approved_tax              DECIMAL(9)
      ,i_approved_copay            DECIMAL(9)
      ,i_allowed_cost              DECIMAL(9)
      ,i_allowed_fee               DECIMAL(9)
      ,i_allowed_tax               DECIMAL(9)
      ,i_allowed_copay             DECIMAL(9)
      ,i_payable_cost              DECIMAL(9)
      ,i_payable_fee               DECIMAL(9)
      ,i_payable_tax               DECIMAL(9)
      ,i_payable_copay             DECIMAL(9)
      ,i_billable_cost             DECIMAL(9)
      ,i_billable_fee              DECIMAL(9)
      ,i_billable_tax              DECIMAL(9)
      ,i_billable_copay            DECIMAL(9)
      ,i_gross_amount_due          DECIMAL(9)
      ,i_usual_and_customary       DECIMAL(9)
      ,i_product_type              VARCHAR(50)
      ,i_amt_app_per_ded           MONEY
      ,i_amt_app_per_mop           MONEY
      ,i_amt_app_per_max           MONEY
      ,i_document_number           VARCHAR(50)
      ,i_network_search_gid        INT
      ,i_network_gid               INT
      ,i_plan_strategy_gid         INT
      ,i_coverage_type             VARCHAR(50)
      ,i_claim_source_flag         VARCHAR(50)
      ,i_other_carrier_gid         INT
      ,i_cob_subscriber            VARCHAR(50)
      ,i_routing_number            VARCHAR(50)
      ,i_version_number            VARCHAR(50)
      ,i_transaction_code          VARCHAR(50)
      ,i_prov_number               VARCHAR(60)
      ,i_prov_ssn                  VARCHAR(50)
      ,i_prov_state                VARCHAR(50)
      ,i_group_number              VARCHAR(50)
      ,i_member_id                 VARCHAR(50)
      ,i_birth_date                VARCHAR(50)
      ,i_first_name                VARCHAR(50)
      ,i_last_name                 VARCHAR(60)
      ,i_relationship_code         VARCHAR(50)
      ,i_sex_of_patient            VARCHAR(50)
      ,i_other_cov_code            VARCHAR(50)
      ,i_other_cov_group           VARCHAR(50)
      ,i_other_cov_id              VARCHAR(50)
      ,i_other_cov_birth_date      VARCHAR(50)
      ,i_prior_auth_gid            INT
      ,i_plan_strategy_sid         INT
      ,i_price_strategy_sid        INT
      ,i_price_schedule_sid        INT
      ,i_copay_strategy_sid        INT
      ,i_copay_schedule_sid        INT
      ,i_benefit_strategy_sid      INT
      ,i_max_rules_sid             INT
      ,i_ded_rules_sid             INT
      ,i_mop_rules_sid             INT
      ,i_proc_exclusion_sid        INT
      ,i_coverage_strategy_sid     INT
      ,i_proc_class_relation_sid   INT
      ,i_proc_payment_sid          INT
      ,i_proc_rules_sid            INT
      ,i_proc_step_therapy_sid     INT
      ,i_proc_xcheck_sid           INT
      ,i_assignment_code           VARCHAR(50)
      ,i_prime_pays_amount         MONEY
      ,i_amt_remain_max            MONEY
      ,i_amt_over_max              MONEY
      ,i_incentive_level           FLOAT(8)
      ,i_input_diagnosis_code      VARCHAR(50)
      ,i_internal_diagnosis_code   VARCHAR(50)
      ,i_prep_date                 VARCHAR(50)
      ,i_seat_date                 VARCHAR(50)
      ,i_fee_override              VARCHAR(50)
      ,i_cob_indicated             VARCHAR(50)
      ,i_comments_on_claim         VARCHAR(50)
      ,i_member_referral           VARCHAR(50)
      ,i_banding_date              VARCHAR(50)
      ,i_case_fee                  MONEY
      ,i_initial_down_payment      MONEY
      ,i_treatment_months          INT
      ,i_monthly_payment           MONEY
      ,i_end_date                  VARCHAR(50)
      ,i_initial_payment_amt       MONEY
      ,i_additional_payments       INT
      ,i_amount_of_each_payment    MONEY
      ,i_total_to_be_paid          MONEY
      ,i_subscriber_gid            INT
      ,i_penalty_codes             VARCHAR(50)
      ,i_ovrd_approved             MONEY
      ,i_ovrd_allowed              MONEY
      ,i_processing_policies       VARCHAR(50)
      ,i_pay_as_class              VARCHAR(50)
      ,i_pend_code                 VARCHAR(50)
      ,i_final_flag                VARCHAR(50)
      ,i_class_id                  INT
      ,i_chart_date                VARCHAR(50)
      ,i_accident_ind              VARCHAR(50)
      ,i_cob_savings               MONEY
      ,i_predet_number             VARCHAR(50)
      ,i_clearing_number           VARCHAR(50)
      ,i_user_id                   VARCHAR(50)
      ,i_network_flag              VARCHAR(50)
      ,i_status_code               VARCHAR(50)
      ,i_site_id                   VARCHAR(50)
      ,i_pro_rate                  VARCHAR(50)
      ,i_benefit_type              VARCHAR(50)
      ,i_claim_entry_update        VARCHAR(50)
      ,o_insert_upd_flag           VARCHAR(50)
      ,o_return_code               INT
      ,o_num_rejects               INT
      ,o_reject_codes              VARCHAR(80)
      ,o_num_msgs                  INT
      ,o_msgs                      VARCHAR(400)
      ,l_Create_Resub_Recs         VARCHAR(50)
      ,i_user_lob                  VARCHAR(50)
      ,i_pos_claim_id              VARCHAR(50)
      ,i_type_of_bill              VARCHAR(50)
      ,i_diag_code_1               VARCHAR(50)
      ,i_diag_code_2               VARCHAR(50)
      ,i_diag_code_3               VARCHAR(50)
      ,i_diag_code_4               VARCHAR(50)
      ,i_diag_code_5               VARCHAR(50)
      ,i_diag_code_6               VARCHAR(50)
      ,i_diag_code_7               VARCHAR(50)
      ,i_diag_code_8               VARCHAR(50)
      ,i_diag_code_9               VARCHAR(50)
      ,i_acc_code                  VARCHAR(50)
      ,i_drg                       VARCHAR(50)
      ,i_dischrg_status            VARCHAR(50)
      ,i_prin_proc_code            VARCHAR(50)
      ,i_claim_form_type           VARCHAR(50)
      ,i_rev                       VARCHAR(50)
      ,i_pos                       VARCHAR(50)
      ,i_tos                       VARCHAR(50)
      ,i_service_date_to           VARCHAR(50)
      ,i_diag_ptr                  VARCHAR(128)
      ,i_nc_chr                    DECIMAL(9)
      ,i_ref_provider_gid          INT
      ,i_ref_location_gid          INT
      ,i_ref_business_gid          INT
      ,i_atn_provider_gid          INT
      ,i_atn_location_gid          INT
      ,i_atn_business_gid          INT
      ,iCodeParingGID              INT
      ,iPrimaryDiagCode            VARCHAR(50)
      ,iSecDiagCode                VARCHAR(50)
      ,iDiagGrouper                VARCHAR(50)
      ,iReportClass                VARCHAR(50)
      ,iPatientCopay               MONEY
      ,iTrueAllowed                MONEY
      ,i_other_proc_code_A         VARCHAR(50)
      ,i_other_proc_code_B         VARCHAR(50)
      ,i_other_proc_code_C         VARCHAR(50)
      ,i_other_proc_code_D         VARCHAR(50)
      ,i_other_proc_code_E         VARCHAR(50)
      ,i_person_code               VARCHAR(50)
      ,iPatCoins                   MONEY
      ,iPatNotCovered              MONEY
      ,o_claim_sid                 INT
      ,iAffiliationID              VARCHAR(50)
      ,iManualIntAmt               MONEY
      ,iFileSID                    INT
      ,iEligCovSID                 DECIMAL(9)
      ,iFeeScheduleID              VARCHAR(50)
      ,iCopayDifferential          MONEY
      ,i_inform_text               VARCHAR(61)
      ,i_fill_num                  INT
      ,i_diag_code_10              VARCHAR(50)
      ,i_diag_code_11              VARCHAR(50)
      ,i_diag_code_12              VARCHAR(50)
      ,i_diag_code_13              VARCHAR(50)
      ,i_diag_code_14              VARCHAR(50)
      ,i_diag_code_15              VARCHAR(50)
      ,i_diag_code_16              VARCHAR(50)
      ,i_diag_code_17              VARCHAR(50)
      ,i_diag_code_18              VARCHAR(50)
      ,i_other_proc_code_date_a    VARCHAR(50)
      ,i_other_proc_code_date_b    VARCHAR(50)
      ,i_other_proc_code_date_c    VARCHAR(50)
      ,i_other_proc_code_date_d    VARCHAR(50)
      ,i_other_proc_code_date_e    VARCHAR(50)
      ,i_cond_code_1               VARCHAR(50)
      ,i_cond_code_2               VARCHAR(50)
      ,i_cond_code_3               VARCHAR(50)
      ,i_cond_code_4               VARCHAR(50)
      ,i_cond_code_5               VARCHAR(50)
      ,i_cond_code_6               VARCHAR(50)
      ,i_cond_code_7               VARCHAR(50)
      ,i_cond_code_8               VARCHAR(50)
      ,i_cond_code_9               VARCHAR(50)
      ,i_cond_code_10              VARCHAR(50)
      ,i_cond_code_11              VARCHAR(50)
      ,i_type_admn                 VARCHAR(50)
      ,i_admit_dx                  VARCHAR(50)
      ,i_pat_reason_dx_1           VARCHAR(50)
      ,i_pat_reason_dx_2           VARCHAR(50)
      ,i_pat_reason_dx_3           VARCHAR(50)
      ,i_pps_code                  VARCHAR(50)
      ,i_prin_proc_code_date       VARCHAR(50)
      ,iCOBSavingsApplied          DECIMAL(9)
      ,iCOBSavingsAccrued          DECIMAL(9)
      ,i_member_address            VARCHAR(55)
      ,i_member_address2           VARCHAR(55)
      ,i_member_city               VARCHAR(50)
      ,i_member_state              VARCHAR(50)
      ,i_member_zip_code           VARCHAR(50)
      ,i_member_middle_name        VARCHAR(50)
      ,i_member_country            VARCHAR(50)
      ,i_ben_code_837              VARCHAR(50)
      ,i_special_prog_code         VARCHAR(50)
      ,i_EPSDT                     VARCHAR(50)
      ,i_other_proc_code_f         VARCHAR(50)
      ,i_other_proc_code_date_f    VARCHAR(50)
      ,i_other_proc_code_g         VARCHAR(50)
      ,i_other_proc_code_date_g    VARCHAR(50)
      ,i_other_proc_code_h         VARCHAR(50)
      ,i_other_proc_code_date_h    VARCHAR(50)
      ,i_other_proc_code_i         VARCHAR(50)
      ,i_other_proc_code_date_i    VARCHAR(50)
      ,i_other_proc_code_j         VARCHAR(50)
      ,i_other_proc_code_date_j    VARCHAR(50)
      ,i_other_proc_code_k         VARCHAR(50)
      ,i_other_proc_code_date_k    VARCHAR(50)
      ,i_other_proc_code_l         VARCHAR(50)
      ,i_other_proc_code_date_l    VARCHAR(50)
      ,i_other_proc_code_m         VARCHAR(50)
      ,i_other_proc_code_date_m    VARCHAR(50)
      ,i_other_proc_code_n         VARCHAR(50)
      ,i_other_proc_code_date_n    VARCHAR(50)
      ,i_other_proc_code_o         VARCHAR(50)
      ,i_other_proc_code_date_o    VARCHAR(50)
      ,i_other_proc_code_p         VARCHAR(50)
      ,i_other_proc_code_date_p    VARCHAR(50)
      ,i_other_proc_code_q         VARCHAR(50)
      ,i_other_proc_code_date_q    VARCHAR(50)
      ,i_other_proc_code_r         VARCHAR(50)
      ,i_other_proc_code_date_r    VARCHAR(50)
      ,i_other_proc_code_s         VARCHAR(50)
      ,i_other_proc_code_date_s    VARCHAR(50)
      ,i_other_proc_code_t         VARCHAR(50)
      ,i_other_proc_code_date_t    VARCHAR(50)
      ,i_other_proc_code_u         VARCHAR(50)
      ,i_other_proc_code_date_u    VARCHAR(50)
      ,i_other_proc_code_v         VARCHAR(50)
      ,i_other_proc_code_date_v    VARCHAR(50)
      ,i_other_proc_code_w         VARCHAR(50)
      ,i_other_proc_code_date_w    VARCHAR(50)
      ,i_other_proc_code_x         VARCHAR(50)
      ,i_other_proc_code_date_x    VARCHAR(50)
      ,i_diag_code_19              VARCHAR(50)
      ,i_diag_code_20              VARCHAR(50)
      ,i_diag_code_21              VARCHAR(50)
      ,i_diag_code_22              VARCHAR(50)
      ,i_diag_code_23              VARCHAR(50)
      ,i_diag_code_24              VARCHAR(50)
      ,i_diag_code_25              VARCHAR(50)
      ,i_repricer_amount           DECIMAL(9)
      ,IsPended                    VARCHAR(50)
      ,StopLossClaim               VARCHAR(50)
      ,iCleanClaimIndicator        VARCHAR(50)
      ,iInitialEntry               VARCHAR(50)
      ,bill_prov_gid               INT
      ,bill_prov_loc_gid           INT
      ,bill_prov_bus_gid           INT
      ,pay_prov_gid                INT
      ,pay_prov_loc_gid            INT
      ,pay_prov_bus_gid            INT
      ,i_submitted_drg             VARCHAR(50)
      ,iDaysUsed                   INT
      ,iAllowBonus                 VARCHAR(50)
      ,iPrimaryBeneAmt             MONEY
      ,poa                         VARCHAR(50)
      ,other_sub_first_name        VARCHAR(50)
      ,other_sub_last_name         VARCHAR(60)
      ,other_sub_middle_name       VARCHAR(50)
      ,other_sub_suffix            VARCHAR(50)
      ,other_sub_id_code           VARCHAR(80)
      ,other_sub_seq_num_code      VARCHAR(50)
      ,other_sub_relationship      VARCHAR(50)
      ,other_sub_policy_number     VARCHAR(50)
      ,other_sub_type_code         VARCHAR(50)
      ,other_sub_ins_type          VARCHAR(50)
      ,other_sub_address           VARCHAR(55)
      ,other_sub_address_2         VARCHAR(55)
      ,other_sub_city              VARCHAR(50)
      ,other_sub_state             VARCHAR(50)
      ,other_sub_zip_code          VARCHAR(50)
      ,other_sub_ssn               VARCHAR(50)
      ,other_payer_last_name       VARCHAR(60)
      ,other_payer_address         VARCHAR(55)
      ,other_payer_address_2       VARCHAR(55)
      ,other_payer_city            VARCHAR(50)
      ,other_payer_state           VARCHAR(50)
      ,other_payer_zip_code        VARCHAR(50)
      ,cap_write_off               DECIMAL(9)
      ,condition_date              DATETIME
      ,condition_diagnosis         VARCHAR(50)
      ,CLM11_RelCause1             VARCHAR(50)
      ,CLM11_RelCause2             VARCHAR(50)
      ,sub_pa_number               VARCHAR(50)
      ,sub_ref_number              VARCHAR(50)
      ,similar_date                DATETIME
      ,acc_amt_app_per_ded         MONEY
      ,acc_amt_app_per_mop         MONEY
      ,acc_amt_app_per_max         MONEY
      ,acc_max_rules_sid           INT
      ,acc_ded_rules_sid           INT
      ,acc_mop_rules_sid           INT
      ,acc_amt_remain_max          MONEY
      ,sec_bene_base_amt           MONEY
      ,acc_DaysUsed                INT
      ,IsAccident                  VARCHAR(50)
      ,acc_state                   VARCHAR(50)
      ,source_code                 VARCHAR(50)
      ,FacilityName                VARCHAR(60)
      ,FacilityNPI                 VARCHAR(80)
      ,ClaimFrequencyCode          VARCHAR(50)
      ,i_opr_provider_gid          INT
      ,i_opr_location_gid          INT
      ,i_opr_business_gid          INT
      ,PurchasedServiceAmount      DECIMAL(9)
      ,PurchasedServiceNPI         VARCHAR(80)
      ,EmergencyIndicator          VARCHAR(50)
      ,MJ_vs_UN                    VARCHAR(50)
      ,LinePrimePaid               DECIMAL(9)
      ,i_form_id                   VARCHAR(50)
      ,i_sub_drg_soi               VARCHAR(50)
      ,i_drg_soi                   VARCHAR(50)
      ,i_drg_rom                   VARCHAR(50)
      ,iOnOrigSubmission           VARCHAR(50)
      ,iAuthMatchRuleSID           INT
      ,iTradingPartnerGID          INT
      ,i_icd_code_type             NVARCHAR(4)
      ,i_provMatchingUsedBL_SHL    VARCHAR(50)
      ,i_ProcessType               VARCHAR(50)
      ,iAdjudicationOrder          INT
      ,iPaymentIntegrityRemarkCode VARCHAR(50)
      ,iAlternativeMemberResp      DECIMAL(9)
      ,iGroupPricingSID            INT
      ,iManualOverride             VARCHAR(50)
      ,iManualOvrAllow             MONEY
      ,iManualOvrApprove           MONEY
      ,iManualRemarkCode           VARCHAR(50)
      ,iManualNetwork              VARCHAR(50)
      ,record_id                   INT
      ,static_gid                  INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

IF OBJECT_ID('tempdb.dbo.#Claim_Dates') IS NOT NULL
	DROP TABLE #Claim_Dates

CREATE TABLE #Claim_Dates
      (claim_number			VARCHAR(15)
	  ,date_submitted		DATETIME)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #RFFClaimInsert
          (SearchID
		  ,i_claim_number 
          ,i_line_number
          ,i_service_date
          ,i_date_submitted
          ,i_receive_date 
          ,i_default_status  
          ,i_group_gid  
          ,i_contact_gid 
          ,i_provider_gid 
          ,i_location_gid 
          ,i_business_gid 
          ,i_specialty_id 
          ,i_claim_type  
          ,i_submitted_procedure_id 
          ,i_adjudicated_procedure_id
          ,i_payment_procedure_id
          ,i_incentive_requirement
          ,i_modifier_1
          ,i_modifier_2
          ,i_modifier_3
          ,i_modifier_4
          ,i_modifier_5
          ,i_modifier_6
          ,i_modifier_7
          ,i_modifier_8
          ,i_modifier_9
          ,i_modifier_10
          ,i_submitted_cost
          ,i_submitted_fee
          ,i_submitted_tax
          ,i_submitted_copay
          ,i_approved_cost
          ,i_approved_fee
          ,i_approved_tax
          ,i_approved_copay
          ,i_allowed_cost
          ,i_allowed_fee
          ,i_allowed_tax
          ,i_allowed_copay
          ,i_payable_cost
          ,i_payable_fee
          ,i_payable_tax
          ,i_payable_copay
          ,i_billable_cost
          ,i_billable_fee
          ,i_billable_tax
          ,i_billable_copay
          ,i_gross_amount_due
          ,i_usual_and_customary
          ,i_product_type
          ,i_amt_app_per_ded
          ,i_amt_app_per_mop
          ,i_amt_app_per_max
          ,i_document_number
          ,i_network_search_gid
          ,i_network_gid
          ,i_plan_strategy_gid
          ,i_coverage_type
          ,i_claim_source_flag
          ,i_other_carrier_gid
          ,i_cob_subscriber
          ,i_routing_number
          ,i_version_number
          ,i_transaction_code
          ,i_prov_number
          ,i_prov_ssn
          ,i_prov_state
          ,i_group_number
          ,i_member_id
          ,i_birth_date
          ,i_first_name
          ,i_last_name
          ,i_relationship_code
          ,i_sex_of_patient
          ,i_other_cov_code
          ,i_other_cov_group
          ,i_other_cov_id
          ,i_other_cov_birth_date
          ,i_prior_auth_gid
          ,i_plan_strategy_sid
          ,i_price_strategy_sid
          ,i_price_schedule_sid
          ,i_copay_strategy_sid
          ,i_copay_schedule_sid
          ,i_benefit_strategy_sid
          ,i_max_rules_sid
          ,i_ded_rules_sid
          ,i_mop_rules_sid
          ,i_proc_exclusion_sid
          ,i_coverage_strategy_sid
          ,i_proc_class_relation_sid
          ,i_proc_payment_sid
          ,i_proc_rules_sid
          ,i_proc_step_therapy_sid
          ,i_proc_xcheck_sid
          ,i_assignment_code
          ,i_prime_pays_amount
          ,i_amt_remain_max
          ,i_amt_over_max
          ,i_incentive_level
          ,i_input_diagnosis_code
          ,i_internal_diagnosis_code
          ,i_prep_date
          ,i_seat_date
          ,i_fee_override
          ,i_cob_indicated
          ,i_comments_on_claim
          ,i_member_referral
          ,i_banding_date
          ,i_case_fee
          ,i_initial_down_payment
          ,i_treatment_months
          ,i_monthly_payment
          ,i_end_date
          ,i_initial_payment_amt
          ,i_additional_payments
          ,i_amount_of_each_payment
          ,i_total_to_be_paid
          ,i_subscriber_gid
          ,i_penalty_codes
          ,i_ovrd_approved
          ,i_ovrd_allowed
          ,i_processing_policies
          ,i_pay_as_class
          ,i_pend_code
          ,i_final_flag
          ,i_class_id
          ,i_chart_date
          ,i_accident_ind
          ,i_cob_savings
          ,i_predet_number
          ,i_clearing_number
          ,i_user_id
          ,i_network_flag
          ,i_status_code
          ,i_site_id
          ,i_pro_rate
          ,i_benefit_type
          ,i_claim_entry_update
          ,o_insert_upd_flag
          ,o_return_code
          ,o_num_rejects
          ,o_reject_codes
          ,o_num_msgs
          ,o_msgs
          ,l_Create_Resub_Recs
          ,i_user_lob
          ,i_pos_claim_id
          ,i_type_of_bill
          ,i_diag_code_1
          ,i_diag_code_2
          ,i_diag_code_3
          ,i_diag_code_4
          ,i_diag_code_5
          ,i_diag_code_6
          ,i_diag_code_7
          ,i_diag_code_8
          ,i_diag_code_9
          ,i_acc_code
          ,i_drg
          ,i_dischrg_status
          ,i_prin_proc_code
          ,i_claim_form_type
          ,i_rev
          ,i_pos
          ,i_tos
          ,i_service_date_to
          ,i_diag_ptr
          ,i_nc_chr
          ,i_ref_provider_gid
          ,i_ref_location_gid
          ,i_ref_business_gid
          ,i_atn_provider_gid
          ,i_atn_location_gid
          ,i_atn_business_gid
          ,iCodeParingGID
          ,iPrimaryDiagCode
          ,iSecDiagCode
          ,iDiagGrouper
          ,iReportClass
          ,iPatientCopay
          ,iTrueAllowed
          ,i_other_proc_code_A
          ,i_other_proc_code_B
          ,i_other_proc_code_C
          ,i_other_proc_code_D
          ,i_other_proc_code_E
          ,i_person_code
          ,iPatCoins
          ,iPatNotCovered
          ,o_claim_sid
          ,iAffiliationID
          ,iManualIntAmt
          ,iFileSID
          ,iEligCovSID
          ,iFeeScheduleID
          ,iCopayDifferential
          ,i_inform_text
          ,i_fill_num
          ,i_diag_code_10
          ,i_diag_code_11
          ,i_diag_code_12
          ,i_diag_code_13
          ,i_diag_code_14
          ,i_diag_code_15
          ,i_diag_code_16
          ,i_diag_code_17
          ,i_diag_code_18
          ,i_other_proc_code_date_a
          ,i_other_proc_code_date_b
          ,i_other_proc_code_date_c
          ,i_other_proc_code_date_d
          ,i_other_proc_code_date_e
          ,i_cond_code_1
          ,i_cond_code_2
          ,i_cond_code_3
          ,i_cond_code_4
          ,i_cond_code_5
          ,i_cond_code_6
          ,i_cond_code_7
          ,i_cond_code_8
          ,i_cond_code_9
          ,i_cond_code_10
          ,i_cond_code_11
          ,i_type_admn
          ,i_admit_dx
          ,i_pat_reason_dx_1
          ,i_pat_reason_dx_2
          ,i_pat_reason_dx_3
          ,i_pps_code
          ,i_prin_proc_code_date
          ,iCOBSavingsApplied
          ,iCOBSavingsAccrued
          ,i_member_address
          ,i_member_address2
          ,i_member_city
          ,i_member_state
          ,i_member_zip_code
          ,i_member_middle_name
          ,i_member_country
          ,i_ben_code_837
          ,i_special_prog_code
          ,i_EPSDT
          ,i_other_proc_code_f
          ,i_other_proc_code_date_f
          ,i_other_proc_code_g
          ,i_other_proc_code_date_g
          ,i_other_proc_code_h
          ,i_other_proc_code_date_h
          ,i_other_proc_code_i
          ,i_other_proc_code_date_i
          ,i_other_proc_code_j
          ,i_other_proc_code_date_j
          ,i_other_proc_code_k
          ,i_other_proc_code_date_k
          ,i_other_proc_code_l
          ,i_other_proc_code_date_l
          ,i_other_proc_code_m
          ,i_other_proc_code_date_m
          ,i_other_proc_code_n
          ,i_other_proc_code_date_n
          ,i_other_proc_code_o
          ,i_other_proc_code_date_o
          ,i_other_proc_code_p
          ,i_other_proc_code_date_p
          ,i_other_proc_code_q
          ,i_other_proc_code_date_q
          ,i_other_proc_code_r
          ,i_other_proc_code_date_r
          ,i_other_proc_code_s
          ,i_other_proc_code_date_s
          ,i_other_proc_code_t
          ,i_other_proc_code_date_t
          ,i_other_proc_code_u
          ,i_other_proc_code_date_u
          ,i_other_proc_code_v
          ,i_other_proc_code_date_v
          ,i_other_proc_code_w
          ,i_other_proc_code_date_w
          ,i_other_proc_code_x
          ,i_other_proc_code_date_x
          ,i_diag_code_19
          ,i_diag_code_20
          ,i_diag_code_21
          ,i_diag_code_22
          ,i_diag_code_23
          ,i_diag_code_24
          ,i_diag_code_25
          ,i_repricer_amount
          ,IsPended
          ,StopLossClaim
          ,iCleanClaimIndicator
          ,iInitialEntry
          ,bill_prov_gid
          ,bill_prov_loc_gid
          ,bill_prov_bus_gid
          ,pay_prov_gid
          ,pay_prov_loc_gid
          ,pay_prov_bus_gid
          ,i_submitted_drg
          ,iDaysUsed
          ,iAllowBonus
          ,iPrimaryBeneAmt
          ,poa
          ,other_sub_first_name
          ,other_sub_last_name
          ,other_sub_middle_name
          ,other_sub_suffix
          ,other_sub_id_code
          ,other_sub_seq_num_code
          ,other_sub_relationship
          ,other_sub_policy_number
          ,other_sub_type_code
          ,other_sub_ins_type
          ,other_sub_address
          ,other_sub_address_2
          ,other_sub_city
          ,other_sub_state
          ,other_sub_zip_code
          ,other_sub_ssn
          ,other_payer_last_name
          ,other_payer_address
          ,other_payer_address_2
          ,other_payer_city
          ,other_payer_state
          ,other_payer_zip_code
          ,cap_write_off
          ,condition_date
          ,condition_diagnosis
          ,CLM11_RelCause1
          ,CLM11_RelCause2
          ,sub_pa_number
          ,sub_ref_number
          ,similar_date
          ,acc_amt_app_per_ded
          ,acc_amt_app_per_mop
          ,acc_amt_app_per_max
          ,acc_max_rules_sid
          ,acc_ded_rules_sid
          ,acc_mop_rules_sid
          ,acc_amt_remain_max
          ,sec_bene_base_amt
          ,acc_DaysUsed
          ,IsAccident
          ,acc_state
          ,source_code
          ,FacilityName
          ,FacilityNPI
          ,ClaimFrequencyCode
          ,i_opr_provider_gid
          ,i_opr_location_gid
          ,i_opr_business_gid
          ,PurchasedServiceAmount
          ,PurchasedServiceNPI
          ,EmergencyIndicator
          ,MJ_vs_UN
          ,LinePrimePaid
          ,i_form_id
          ,i_sub_drg_soi
          ,i_drg_soi
          ,i_drg_rom
          ,iOnOrigSubmission
          ,iAuthMatchRuleSID
          ,iTradingPartnerGID
          ,i_icd_code_type
          ,i_provMatchingUsedBL_SHL
          ,i_ProcessType
          ,iAdjudicationOrder
          ,iPaymentIntegrityRemarkCode
          ,iAlternativeMemberResp
          ,iGroupPricingSID
          ,iManualOverride
          ,iManualOvrAllow
          ,iManualOvrApprove
          ,iManualRemarkCode
          ,iManualNetwork
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,[i_claim_number]
          ,[i_line_number]
          ,[i_service_date]
          ,[i_date_submitted]
          ,[i_receive_date]
          ,[i_default_status]
          ,[i_group_gid]
          ,[i_contact_gid]
          ,[i_provider_gid]
          ,[i_location_gid]
          ,[i_business_gid]
          ,[i_specialty_id]
          ,[i_claim_type]
          ,[i_submitted_procedure_id]
          ,[i_adjudicated_procedure_id]
          ,[i_payment_procedure_id]
          ,[i_incentive_requirement]
          ,[i_modifier_1]
          ,[i_modifier_2]
          ,[i_modifier_3]
          ,[i_modifier_4]
          ,[i_modifier_5]
          ,[i_modifier_6]
          ,[i_modifier_7]
          ,[i_modifier_8]
          ,[i_modifier_9]
          ,[i_modifier_10]
          ,[i_submitted_cost]
          ,[i_submitted_fee]
          ,[i_submitted_tax]
          ,[i_submitted_copay]
          ,[i_approved_cost]
          ,[i_approved_fee]
          ,[i_approved_tax]
          ,[i_approved_copay]
          ,[i_allowed_cost]
          ,[i_allowed_fee]
          ,[i_allowed_tax]
          ,[i_allowed_copay]
          ,[i_payable_cost]
          ,[i_payable_fee]
          ,[i_payable_tax]
          ,[i_payable_copay]
          ,[i_billable_cost]
          ,[i_billable_fee]
          ,[i_billable_tax]
          ,[i_billable_copay]
          ,[i_gross_amount_due]
          ,[i_usual_and_customary]
          ,[i_product_type]
          ,[i_amt_app_per_ded]
          ,[i_amt_app_per_mop]
          ,[i_amt_app_per_max]
          ,[i_document_number]
          ,[i_network_search_gid]
          ,[i_network_gid]
          ,[i_plan_strategy_gid]
          ,[i_coverage_type]
          ,[i_claim_source_flag]
          ,[i_other_carrier_gid]
          ,[i_cob_subscriber]
          ,[i_routing_number]
          ,[i_version_number]
          ,[i_transaction_code]
          ,[i_prov_number]
          ,[i_prov_ssn]
          ,[i_prov_state]
          ,[i_group_number]
          ,[i_member_id]
          ,[i_birth_date]
          ,[i_first_name]
          ,[i_last_name]
          ,[i_relationship_code]
          ,[i_sex_of_patient]
          ,[i_other_cov_code]
          ,[i_other_cov_group]
          ,[i_other_cov_id]
          ,[i_other_cov_birth_date]
          ,[i_prior_auth_gid]
          ,[i_plan_strategy_sid]
          ,[i_price_strategy_sid]
          ,[i_price_schedule_sid]
          ,[i_copay_strategy_sid]
          ,[i_copay_schedule_sid]
          ,[i_benefit_strategy_sid]
          ,[i_max_rules_sid]
          ,[i_ded_rules_sid]
          ,[i_mop_rules_sid]
          ,[i_proc_exclusion_sid]
          ,[i_coverage_strategy_sid]
          ,[i_proc_class_relation_sid]
          ,[i_proc_payment_sid]
          ,[i_proc_rules_sid]
          ,[i_proc_step_therapy_sid]
          ,[i_proc_xcheck_sid]
          ,[i_assignment_code]
          ,[i_prime_pays_amount]
          ,[i_amt_remain_max]
          ,[i_amt_over_max]
          ,[i_incentive_level]
          ,[i_input_diagnosis_code]
          ,[i_internal_diagnosis_code]
          ,[i_prep_date]
          ,[i_seat_date]
          ,[i_fee_override]
          ,[i_cob_indicated]
          ,[i_comments_on_claim]
          ,[i_member_referral]
          ,[i_banding_date]
          ,[i_case_fee]
          ,[i_initial_down_payment]
          ,[i_treatment_months]
          ,[i_monthly_payment]
          ,[i_end_date]
          ,[i_initial_payment_amt]
          ,[i_additional_payments]
          ,[i_amount_of_each_payment]
          ,[i_total_to_be_paid]
          ,[i_subscriber_gid]
          ,[i_penalty_codes]
          ,[i_ovrd_approved]
          ,[i_ovrd_allowed]
          ,[i_processing_policies]
          ,[i_pay_as_class]
          ,[i_pend_code]
          ,[i_final_flag]
          ,[i_class_id]
          ,[i_chart_date]
          ,[i_accident_ind]
          ,[i_cob_savings]
          ,[i_predet_number]
          ,[i_clearing_number]
          ,[i_user_id]
          ,[i_network_flag]
          ,[i_status_code]
          ,[i_site_id]
          ,[i_pro_rate]
          ,[i_benefit_type]
          ,[i_claim_entry_update]
          ,[o_insert_upd_flag]
          ,[o_return_code]
          ,[o_num_rejects]
          ,[o_reject_codes]
          ,[o_num_msgs]
          ,[o_msgs]
          ,[l_Create_Resub_Recs]
          ,[i_user_lob]
          ,[i_pos_claim_id]
          ,[i_type_of_bill]
          ,[i_diag_code_1]
          ,[i_diag_code_2]
          ,[i_diag_code_3]
          ,[i_diag_code_4]
          ,[i_diag_code_5]
          ,[i_diag_code_6]
          ,[i_diag_code_7]
          ,[i_diag_code_8]
          ,[i_diag_code_9]
          ,[i_acc_code]
          ,[i_drg]
          ,[i_dischrg_status]
          ,[i_prin_proc_code]
          ,[i_claim_form_type]
          ,[i_rev]
          ,[i_pos]
          ,[i_tos]
          ,[i_service_date_to]
          ,[i_diag_ptr]
          ,[i_nc_chr]
          ,[i_ref_provider_gid]
          ,[i_ref_location_gid]
          ,[i_ref_business_gid]
          ,[i_atn_provider_gid]
          ,[i_atn_location_gid]
          ,[i_atn_business_gid]
          ,[iCodeParingGID]
          ,[iPrimaryDiagCode]
          ,[iSecDiagCode]
          ,[iDiagGrouper]
          ,[iReportClass]
          ,[iPatientCopay]
          ,[iTrueAllowed]
          ,[i_other_proc_code_A]
          ,[i_other_proc_code_B]
          ,[i_other_proc_code_C]
          ,[i_other_proc_code_D]
          ,[i_other_proc_code_E]
          ,[i_person_code]
          ,[iPatCoins]
          ,[iPatNotCovered]
          ,[o_claim_sid]
          ,[iAffiliationID]
          ,[iManualIntAmt]
          ,[iFileSID]
          ,[iEligCovSID]
          ,[iFeeScheduleID]
          ,[iCopayDifferential]
          ,[i_inform_text]
          ,[i_fill_num]
          ,[i_diag_code_10]
          ,[i_diag_code_11]
          ,[i_diag_code_12]
          ,[i_diag_code_13]
          ,[i_diag_code_14]
          ,[i_diag_code_15]
          ,[i_diag_code_16]
          ,[i_diag_code_17]
          ,[i_diag_code_18]
          ,[i_other_proc_code_date_a]
          ,[i_other_proc_code_date_b]
          ,[i_other_proc_code_date_c]
          ,[i_other_proc_code_date_d]
          ,[i_other_proc_code_date_e]
          ,[i_cond_code_1]
          ,[i_cond_code_2]
          ,[i_cond_code_3]
          ,[i_cond_code_4]
          ,[i_cond_code_5]
          ,[i_cond_code_6]
          ,[i_cond_code_7]
          ,[i_cond_code_8]
          ,[i_cond_code_9]
          ,[i_cond_code_10]
          ,[i_cond_code_11]
          ,[i_type_admn]
          ,[i_admit_dx]
          ,[i_pat_reason_dx_1]
          ,[i_pat_reason_dx_2]
          ,[i_pat_reason_dx_3]
          ,[i_pps_code]
          ,[i_prin_proc_code_date]
          ,[iCOBSavingsApplied]
          ,[iCOBSavingsAccrued]
          ,[i_member_address]
          ,[i_member_address2]
          ,[i_member_city]
          ,[i_member_state]
          ,[i_member_zip_code]
          ,[i_member_middle_name]
          ,[i_member_country]
          ,[i_ben_code_837]
          ,[i_special_prog_code]
          ,[i_EPSDT]
          ,[i_other_proc_code_f]
          ,[i_other_proc_code_date_f]
          ,[i_other_proc_code_g]
          ,[i_other_proc_code_date_g]
          ,[i_other_proc_code_h]
          ,[i_other_proc_code_date_h]
          ,[i_other_proc_code_i]
          ,[i_other_proc_code_date_i]
          ,[i_other_proc_code_j]
          ,[i_other_proc_code_date_j]
          ,[i_other_proc_code_k]
          ,[i_other_proc_code_date_k]
          ,[i_other_proc_code_l]
          ,[i_other_proc_code_date_l]
          ,[i_other_proc_code_m]
          ,[i_other_proc_code_date_m]
          ,[i_other_proc_code_n]
          ,[i_other_proc_code_date_n]
          ,[i_other_proc_code_o]
          ,[i_other_proc_code_date_o]
          ,[i_other_proc_code_p]
          ,[i_other_proc_code_date_p]
          ,[i_other_proc_code_q]
          ,[i_other_proc_code_date_q]
          ,[i_other_proc_code_r]
          ,[i_other_proc_code_date_r]
          ,[i_other_proc_code_s]
          ,[i_other_proc_code_date_s]
          ,[i_other_proc_code_t]
          ,[i_other_proc_code_date_t]
          ,[i_other_proc_code_u]
          ,[i_other_proc_code_date_u]
          ,[i_other_proc_code_v]
          ,[i_other_proc_code_date_v]
          ,[i_other_proc_code_w]
          ,[i_other_proc_code_date_w]
          ,[i_other_proc_code_x]
          ,[i_other_proc_code_date_x]
          ,[i_diag_code_19]
          ,[i_diag_code_20]
          ,[i_diag_code_21]
          ,[i_diag_code_22]
          ,[i_diag_code_23]
          ,[i_diag_code_24]
          ,[i_diag_code_25]
          ,[i_repricer_amount]
          ,[IsPended]
          ,[StopLossClaim]
          ,[iCleanClaimIndicator]
          ,[iInitialEntry]
          ,[bill_prov_gid]
          ,[bill_prov_loc_gid]
          ,[bill_prov_bus_gid]
          ,[pay_prov_gid]
          ,[pay_prov_loc_gid]
          ,[pay_prov_bus_gid]
          ,[i_submitted_drg]
          ,[iDaysUsed]
          ,[iAllowBonus]
          ,[iPrimaryBeneAmt]
          ,[poa]
          ,[other_sub_first_name]
          ,[other_sub_last_name]
          ,[other_sub_middle_name]
          ,[other_sub_suffix]
          ,[other_sub_id_code]
          ,[other_sub_seq_num_code]
          ,[other_sub_relationship]
          ,[other_sub_policy_number]
          ,[other_sub_type_code]
          ,[other_sub_ins_type]
          ,[other_sub_address]
          ,[other_sub_address_2]
          ,[other_sub_city]
          ,[other_sub_state]
          ,[other_sub_zip_code]
          ,[other_sub_ssn]
          ,[other_payer_last_name]
          ,[other_payer_address]
          ,[other_payer_address_2]
          ,[other_payer_city]
          ,[other_payer_state]
          ,[other_payer_zip_code]
          ,[cap_write_off]
          ,[condition_date]
          ,[condition_diagnosis]
          ,[CLM11_RelCause1]
          ,[CLM11_RelCause2]
          ,[sub_pa_number]
          ,[sub_ref_number]
          ,[similar_date]
          ,[acc_amt_app_per_ded]
          ,[acc_amt_app_per_mop]
          ,[acc_amt_app_per_max]
          ,[acc_max_rules_sid]
          ,[acc_ded_rules_sid]
          ,[acc_mop_rules_sid]
          ,[acc_amt_remain_max]
          ,[sec_bene_base_amt]
          ,[acc_DaysUsed]
          ,[IsAccident]
          ,[acc_state]
          ,[source_code]
          ,[FacilityName]
          ,[FacilityNPI]
          ,[ClaimFrequencyCode]
          ,[i_opr_provider_gid]
          ,[i_opr_location_gid]
          ,[i_opr_business_gid]
          ,[PurchasedServiceAmount]
          ,[PurchasedServiceNPI]
          ,[EmergencyIndicator]
          ,[MJ_vs_UN]
          ,[LinePrimePaid]
          ,[i_form_id]
          ,[i_sub_drg_soi]
          ,[i_drg_soi]
          ,[i_drg_rom]
          ,[iOnOrigSubmission]
          ,[iAuthMatchRuleSID]
          ,[iTradingPartnerGID]
          ,[i_icd_code_type]
          ,[i_provMatchingUsedBL_SHL]
          ,[i_ProcessType]
          ,[iAdjudicationOrder]
          ,[iPaymentIntegrityRemarkCode]
          ,[iAlternativeMemberResp]
          ,[iGroupPricingSID]
          ,[iManualOverride]
          ,[iManualOvrAllow]
          ,[iManualOvrApprove]
          ,[iManualRemarkCode]
          ,[iManualNetwork]
          ,[RecordID]
          ,[gid]
      FROM COREAUTO.CoreAutomation.dbo.TD_RFFClaimInsert
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #RFFClaimInsert
       SET i_user_id  = @user

	SELECT * FROM #RFFClaimInsert

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()
    PRINT @err_msg
	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE RFFClaimInsert_Cursor CURSOR FOR
 SELECT SearchID
       ,i_claim_number
       ,i_line_number
       ,i_service_date
       ,i_date_submitted
       ,i_receive_date
       ,i_default_status
       ,i_group_gid
       ,i_contact_gid
       ,i_provider_gid
       ,i_location_gid
       ,i_business_gid
       ,i_specialty_id
       ,i_claim_type
       ,i_submitted_procedure_id
       ,i_adjudicated_procedure_id
       ,i_payment_procedure_id
       ,i_incentive_requirement
       ,i_modifier_1
       ,i_modifier_2
       ,i_modifier_3
       ,i_modifier_4
       ,i_modifier_5
       ,i_modifier_6
       ,i_modifier_7
       ,i_modifier_8
       ,i_modifier_9
       ,i_modifier_10
       ,i_submitted_cost
       ,i_submitted_fee
       ,i_submitted_tax
       ,i_submitted_copay
       ,i_approved_cost
       ,i_approved_fee
       ,i_approved_tax
       ,i_approved_copay
       ,i_allowed_cost
       ,i_allowed_fee
       ,i_allowed_tax
       ,i_allowed_copay
       ,i_payable_cost
       ,i_payable_fee
       ,i_payable_tax
       ,i_payable_copay
       ,i_billable_cost
       ,i_billable_fee
       ,i_billable_tax
       ,i_billable_copay
       ,i_gross_amount_due
       ,i_usual_and_customary
       ,i_product_type
       ,i_amt_app_per_ded
       ,i_amt_app_per_mop
       ,i_amt_app_per_max
       ,i_document_number
       ,i_network_search_gid
       ,i_network_gid
       ,i_plan_strategy_gid
       ,i_coverage_type
       ,i_claim_source_flag
       ,i_other_carrier_gid
       ,i_cob_subscriber
       ,i_routing_number
       ,i_version_number
       ,i_transaction_code
       ,i_prov_number
       ,i_prov_ssn
       ,i_prov_state
       ,i_group_number
       ,i_member_id
       ,i_birth_date
       ,i_first_name
       ,i_last_name
       ,i_relationship_code
       ,i_sex_of_patient
       ,i_other_cov_code
       ,i_other_cov_group
       ,i_other_cov_id
       ,i_other_cov_birth_date
       ,i_prior_auth_gid
       ,i_plan_strategy_sid
       ,i_price_strategy_sid
       ,i_price_schedule_sid
       ,i_copay_strategy_sid
       ,i_copay_schedule_sid
       ,i_benefit_strategy_sid
       ,i_max_rules_sid
       ,i_ded_rules_sid
       ,i_mop_rules_sid
       ,i_proc_exclusion_sid
       ,i_coverage_strategy_sid
       ,i_proc_class_relation_sid
       ,i_proc_payment_sid
       ,i_proc_rules_sid
       ,i_proc_step_therapy_sid
       ,i_proc_xcheck_sid
       ,i_assignment_code
       ,i_prime_pays_amount
       ,i_amt_remain_max
       ,i_amt_over_max
       ,i_incentive_level
       ,i_input_diagnosis_code
       ,i_internal_diagnosis_code
       ,i_prep_date
       ,i_seat_date
       ,i_fee_override
       ,i_cob_indicated
       ,i_comments_on_claim
       ,i_member_referral
       ,i_banding_date
       ,i_case_fee
       ,i_initial_down_payment
       ,i_treatment_months
       ,i_monthly_payment
       ,i_end_date
       ,i_initial_payment_amt
       ,i_additional_payments
       ,i_amount_of_each_payment
       ,i_total_to_be_paid
       ,i_subscriber_gid
       ,i_penalty_codes
       ,i_ovrd_approved
       ,i_ovrd_allowed
       ,i_processing_policies
       ,i_pay_as_class
       ,i_pend_code
       ,i_final_flag
       ,i_class_id
       ,i_chart_date
       ,i_accident_ind
       ,i_cob_savings
       ,i_predet_number
       ,i_clearing_number
       ,i_user_id
       ,i_network_flag
       ,i_status_code
       ,i_site_id
       ,i_pro_rate
       ,i_benefit_type
       ,i_claim_entry_update
       ,o_insert_upd_flag
       ,o_return_code
       ,o_num_rejects
       ,o_reject_codes
       ,o_num_msgs
       ,o_msgs
       ,l_Create_Resub_Recs
       ,i_user_lob
       ,i_pos_claim_id
       ,i_type_of_bill
       ,i_diag_code_1
       ,i_diag_code_2
       ,i_diag_code_3
       ,i_diag_code_4
       ,i_diag_code_5
       ,i_diag_code_6
       ,i_diag_code_7
       ,i_diag_code_8
       ,i_diag_code_9
       ,i_acc_code
       ,i_drg
       ,i_dischrg_status
       ,i_prin_proc_code
       ,i_claim_form_type
       ,i_rev
       ,i_pos
       ,i_tos
       ,i_service_date_to
       ,i_diag_ptr
       ,i_nc_chr
       ,i_ref_provider_gid
       ,i_ref_location_gid
       ,i_ref_business_gid
       ,i_atn_provider_gid
       ,i_atn_location_gid
       ,i_atn_business_gid
       ,iCodeParingGID
       ,iPrimaryDiagCode
       ,iSecDiagCode
       ,iDiagGrouper
       ,iReportClass
       ,iPatientCopay
       ,iTrueAllowed
       ,i_other_proc_code_A
       ,i_other_proc_code_B
       ,i_other_proc_code_C
       ,i_other_proc_code_D
       ,i_other_proc_code_E
       ,i_person_code
       ,iPatCoins
       ,iPatNotCovered
       ,o_claim_sid
       ,iAffiliationID
       ,iManualIntAmt
       ,iFileSID
       ,iEligCovSID
       ,iFeeScheduleID
       ,iCopayDifferential
       ,i_inform_text
       ,i_fill_num
       ,i_diag_code_10
       ,i_diag_code_11
       ,i_diag_code_12
       ,i_diag_code_13
       ,i_diag_code_14
       ,i_diag_code_15
       ,i_diag_code_16
       ,i_diag_code_17
       ,i_diag_code_18
       ,i_other_proc_code_date_a
       ,i_other_proc_code_date_b
       ,i_other_proc_code_date_c
       ,i_other_proc_code_date_d
       ,i_other_proc_code_date_e
       ,i_cond_code_1
       ,i_cond_code_2
       ,i_cond_code_3
       ,i_cond_code_4
       ,i_cond_code_5
       ,i_cond_code_6
       ,i_cond_code_7
       ,i_cond_code_8
       ,i_cond_code_9
       ,i_cond_code_10
       ,i_cond_code_11
       ,i_type_admn
       ,i_admit_dx
       ,i_pat_reason_dx_1
       ,i_pat_reason_dx_2
       ,i_pat_reason_dx_3
       ,i_pps_code
       ,i_prin_proc_code_date
       ,iCOBSavingsApplied
       ,iCOBSavingsAccrued
       ,i_member_address
       ,i_member_address2
       ,i_member_city
       ,i_member_state
       ,i_member_zip_code
       ,i_member_middle_name
       ,i_member_country
       ,i_ben_code_837
       ,i_special_prog_code
       ,i_EPSDT
       ,i_other_proc_code_f
       ,i_other_proc_code_date_f
       ,i_other_proc_code_g
       ,i_other_proc_code_date_g
       ,i_other_proc_code_h
       ,i_other_proc_code_date_h
       ,i_other_proc_code_i
       ,i_other_proc_code_date_i
       ,i_other_proc_code_j
       ,i_other_proc_code_date_j
       ,i_other_proc_code_k
       ,i_other_proc_code_date_k
       ,i_other_proc_code_l
       ,i_other_proc_code_date_l
       ,i_other_proc_code_m
       ,i_other_proc_code_date_m
       ,i_other_proc_code_n
       ,i_other_proc_code_date_n
       ,i_other_proc_code_o
       ,i_other_proc_code_date_o
       ,i_other_proc_code_p
       ,i_other_proc_code_date_p
       ,i_other_proc_code_q
       ,i_other_proc_code_date_q
       ,i_other_proc_code_r
       ,i_other_proc_code_date_r
       ,i_other_proc_code_s
       ,i_other_proc_code_date_s
       ,i_other_proc_code_t
       ,i_other_proc_code_date_t
       ,i_other_proc_code_u
       ,i_other_proc_code_date_u
       ,i_other_proc_code_v
       ,i_other_proc_code_date_v
       ,i_other_proc_code_w
       ,i_other_proc_code_date_w
       ,i_other_proc_code_x
       ,i_other_proc_code_date_x
       ,i_diag_code_19
       ,i_diag_code_20
       ,i_diag_code_21
       ,i_diag_code_22
       ,i_diag_code_23
       ,i_diag_code_24
       ,i_diag_code_25
       ,i_repricer_amount
       ,IsPended
       ,StopLossClaim
       ,iCleanClaimIndicator
       ,iInitialEntry
       ,bill_prov_gid
       ,bill_prov_loc_gid
       ,bill_prov_bus_gid
       ,pay_prov_gid
       ,pay_prov_loc_gid
       ,pay_prov_bus_gid
       ,i_submitted_drg
       ,iDaysUsed
       ,iAllowBonus
       ,iPrimaryBeneAmt
       ,poa
       ,other_sub_first_name
       ,other_sub_last_name
       ,other_sub_middle_name
       ,other_sub_suffix
       ,other_sub_id_code
       ,other_sub_seq_num_code
       ,other_sub_relationship
       ,other_sub_policy_number
       ,other_sub_type_code
       ,other_sub_ins_type
       ,other_sub_address
       ,other_sub_address_2
       ,other_sub_city
       ,other_sub_state
       ,other_sub_zip_code
       ,other_sub_ssn
       ,other_payer_last_name
       ,other_payer_address
       ,other_payer_address_2
       ,other_payer_city
       ,other_payer_state
       ,other_payer_zip_code
       ,cap_write_off
       ,condition_date
       ,condition_diagnosis
       ,CLM11_RelCause1
       ,CLM11_RelCause2
       ,sub_pa_number
       ,sub_ref_number
       ,similar_date
       ,acc_amt_app_per_ded
       ,acc_amt_app_per_mop
       ,acc_amt_app_per_max
       ,acc_max_rules_sid
       ,acc_ded_rules_sid
       ,acc_mop_rules_sid
       ,acc_amt_remain_max
       ,sec_bene_base_amt
       ,acc_DaysUsed
       ,IsAccident
       ,acc_state
       ,source_code
       ,FacilityName
       ,FacilityNPI
       ,ClaimFrequencyCode
       ,i_opr_provider_gid
       ,i_opr_location_gid
       ,i_opr_business_gid
       ,PurchasedServiceAmount
       ,PurchasedServiceNPI
       ,EmergencyIndicator
       ,MJ_vs_UN
       ,LinePrimePaid
       ,i_form_id
       ,i_sub_drg_soi
       ,i_drg_soi
       ,i_drg_rom
       ,iOnOrigSubmission
       ,iAuthMatchRuleSID
       ,iTradingPartnerGID
       ,i_icd_code_type
       ,i_provMatchingUsedBL_SHL
       ,i_ProcessType
       ,iAdjudicationOrder
       ,iPaymentIntegrityRemarkCode
       ,iAlternativeMemberResp
       ,iGroupPricingSID
       ,iManualOverride
       ,iManualOvrAllow
       ,iManualOvrApprove
       ,iManualRemarkCode
       ,iManualNetwork
       ,record_id
       ,static_gid
   FROM #RFFClaimInsert

   OPEN RFFClaimInsert_Cursor
  FETCH NEXT FROM RFFClaimInsert_Cursor
   INTO @SearchID
       ,@i_claim_number
       ,@i_line_number
       ,@i_service_date
       ,@i_date_submitted
       ,@i_receive_date
       ,@i_default_status
       ,@i_group_gid
       ,@i_contact_gid
       ,@i_provider_gid
       ,@i_location_gid
       ,@i_business_gid
       ,@i_specialty_id
       ,@i_claim_type
       ,@i_submitted_procedure_id
       ,@i_adjudicated_procedure_id
       ,@i_payment_procedure_id
       ,@i_incentive_requirement
       ,@i_modifier_1
       ,@i_modifier_2
       ,@i_modifier_3
       ,@i_modifier_4
       ,@i_modifier_5
       ,@i_modifier_6
       ,@i_modifier_7
       ,@i_modifier_8
       ,@i_modifier_9
       ,@i_modifier_10
       ,@i_submitted_cost
       ,@i_submitted_fee
       ,@i_submitted_tax
       ,@i_submitted_copay
       ,@i_approved_cost
       ,@i_approved_fee
       ,@i_approved_tax
       ,@i_approved_copay
       ,@i_allowed_cost
       ,@i_allowed_fee
       ,@i_allowed_tax
       ,@i_allowed_copay
       ,@i_payable_cost
       ,@i_payable_fee
       ,@i_payable_tax
       ,@i_payable_copay
       ,@i_billable_cost
       ,@i_billable_fee
       ,@i_billable_tax
       ,@i_billable_copay
       ,@i_gross_amount_due
       ,@i_usual_and_customary
       ,@i_product_type
       ,@i_amt_app_per_ded
       ,@i_amt_app_per_mop
       ,@i_amt_app_per_max
       ,@i_document_number
       ,@i_network_search_gid
       ,@i_network_gid
       ,@i_plan_strategy_gid
       ,@i_coverage_type
       ,@i_claim_source_flag
       ,@i_other_carrier_gid
       ,@i_cob_subscriber
       ,@i_routing_number
       ,@i_version_number
       ,@i_transaction_code
       ,@i_prov_number
       ,@i_prov_ssn
       ,@i_prov_state
       ,@i_group_number
       ,@i_member_id
       ,@i_birth_date
       ,@i_first_name
       ,@i_last_name
       ,@i_relationship_code
       ,@i_sex_of_patient
       ,@i_other_cov_code
       ,@i_other_cov_group
       ,@i_other_cov_id
       ,@i_other_cov_birth_date
       ,@i_prior_auth_gid
       ,@i_plan_strategy_sid
       ,@i_price_strategy_sid
       ,@i_price_schedule_sid
       ,@i_copay_strategy_sid
       ,@i_copay_schedule_sid
       ,@i_benefit_strategy_sid
       ,@i_max_rules_sid
       ,@i_ded_rules_sid
       ,@i_mop_rules_sid
       ,@i_proc_exclusion_sid
       ,@i_coverage_strategy_sid
       ,@i_proc_class_relation_sid
       ,@i_proc_payment_sid
       ,@i_proc_rules_sid
       ,@i_proc_step_therapy_sid
       ,@i_proc_xcheck_sid
       ,@i_assignment_code
       ,@i_prime_pays_amount
       ,@i_amt_remain_max
       ,@i_amt_over_max
       ,@i_incentive_level
       ,@i_input_diagnosis_code
       ,@i_internal_diagnosis_code
       ,@i_prep_date
       ,@i_seat_date
       ,@i_fee_override
       ,@i_cob_indicated
       ,@i_comments_on_claim
       ,@i_member_referral
       ,@i_banding_date
       ,@i_case_fee
       ,@i_initial_down_payment
       ,@i_treatment_months
       ,@i_monthly_payment
       ,@i_end_date
       ,@i_initial_payment_amt
       ,@i_additional_payments
       ,@i_amount_of_each_payment
       ,@i_total_to_be_paid
       ,@i_subscriber_gid
       ,@i_penalty_codes
       ,@i_ovrd_approved
       ,@i_ovrd_allowed
       ,@i_processing_policies
       ,@i_pay_as_class
       ,@i_pend_code
       ,@i_final_flag
       ,@i_class_id
       ,@i_chart_date
       ,@i_accident_ind
       ,@i_cob_savings
       ,@i_predet_number
       ,@i_clearing_number
       ,@i_user_id
       ,@i_network_flag
       ,@i_status_code
       ,@i_site_id
       ,@i_pro_rate
       ,@i_benefit_type
       ,@i_claim_entry_update
       ,@o_insert_upd_flag
       ,@o_return_code
       ,@o_num_rejects
       ,@o_reject_codes
       ,@o_num_msgs
       ,@o_msgs
       ,@l_Create_Resub_Recs
       ,@i_user_lob
       ,@i_pos_claim_id
       ,@i_type_of_bill
       ,@i_diag_code_1
       ,@i_diag_code_2
       ,@i_diag_code_3
       ,@i_diag_code_4
       ,@i_diag_code_5
       ,@i_diag_code_6
       ,@i_diag_code_7
       ,@i_diag_code_8
       ,@i_diag_code_9
       ,@i_acc_code
       ,@i_drg
       ,@i_dischrg_status
       ,@i_prin_proc_code
       ,@i_claim_form_type
       ,@i_rev
       ,@i_pos
       ,@i_tos
       ,@i_service_date_to
       ,@i_diag_ptr
       ,@i_nc_chr
       ,@i_ref_provider_gid
       ,@i_ref_location_gid
       ,@i_ref_business_gid
       ,@i_atn_provider_gid
       ,@i_atn_location_gid
       ,@i_atn_business_gid
       ,@iCodeParingGID
       ,@iPrimaryDiagCode
       ,@iSecDiagCode
       ,@iDiagGrouper
       ,@iReportClass
       ,@iPatientCopay
       ,@iTrueAllowed
       ,@i_other_proc_code_A
       ,@i_other_proc_code_B
       ,@i_other_proc_code_C
       ,@i_other_proc_code_D
       ,@i_other_proc_code_E
       ,@i_person_code
       ,@iPatCoins
       ,@iPatNotCovered
       ,@o_claim_sid
       ,@iAffiliationID
       ,@iManualIntAmt
       ,@iFileSID
       ,@iEligCovSID
       ,@iFeeScheduleID
       ,@iCopayDifferential
       ,@i_inform_text
       ,@i_fill_num
       ,@i_diag_code_10
       ,@i_diag_code_11
       ,@i_diag_code_12
       ,@i_diag_code_13
       ,@i_diag_code_14
       ,@i_diag_code_15
       ,@i_diag_code_16
       ,@i_diag_code_17
       ,@i_diag_code_18
       ,@i_other_proc_code_date_a
       ,@i_other_proc_code_date_b
       ,@i_other_proc_code_date_c
       ,@i_other_proc_code_date_d
       ,@i_other_proc_code_date_e
       ,@i_cond_code_1
       ,@i_cond_code_2
       ,@i_cond_code_3
       ,@i_cond_code_4
       ,@i_cond_code_5
       ,@i_cond_code_6
       ,@i_cond_code_7
       ,@i_cond_code_8
       ,@i_cond_code_9
       ,@i_cond_code_10
       ,@i_cond_code_11
       ,@i_type_admn
       ,@i_admit_dx
       ,@i_pat_reason_dx_1
       ,@i_pat_reason_dx_2
       ,@i_pat_reason_dx_3
       ,@i_pps_code
       ,@i_prin_proc_code_date
       ,@iCOBSavingsApplied
       ,@iCOBSavingsAccrued
       ,@i_member_address
       ,@i_member_address2
       ,@i_member_city
       ,@i_member_state
       ,@i_member_zip_code
       ,@i_member_middle_name
       ,@i_member_country
       ,@i_ben_code_837
       ,@i_special_prog_code
       ,@i_EPSDT
       ,@i_other_proc_code_f
       ,@i_other_proc_code_date_f
       ,@i_other_proc_code_g
       ,@i_other_proc_code_date_g
       ,@i_other_proc_code_h
       ,@i_other_proc_code_date_h
       ,@i_other_proc_code_i
       ,@i_other_proc_code_date_i
       ,@i_other_proc_code_j
       ,@i_other_proc_code_date_j
       ,@i_other_proc_code_k
       ,@i_other_proc_code_date_k
       ,@i_other_proc_code_l
       ,@i_other_proc_code_date_l
       ,@i_other_proc_code_m
       ,@i_other_proc_code_date_m
       ,@i_other_proc_code_n
       ,@i_other_proc_code_date_n
       ,@i_other_proc_code_o
       ,@i_other_proc_code_date_o
       ,@i_other_proc_code_p
       ,@i_other_proc_code_date_p
       ,@i_other_proc_code_q
       ,@i_other_proc_code_date_q
       ,@i_other_proc_code_r
       ,@i_other_proc_code_date_r
       ,@i_other_proc_code_s
       ,@i_other_proc_code_date_s
       ,@i_other_proc_code_t
       ,@i_other_proc_code_date_t
       ,@i_other_proc_code_u
       ,@i_other_proc_code_date_u
       ,@i_other_proc_code_v
       ,@i_other_proc_code_date_v
       ,@i_other_proc_code_w
       ,@i_other_proc_code_date_w
       ,@i_other_proc_code_x
       ,@i_other_proc_code_date_x
       ,@i_diag_code_19
       ,@i_diag_code_20
       ,@i_diag_code_21
       ,@i_diag_code_22
       ,@i_diag_code_23
       ,@i_diag_code_24
       ,@i_diag_code_25
       ,@i_repricer_amount
       ,@IsPended
       ,@StopLossClaim
       ,@iCleanClaimIndicator
       ,@iInitialEntry
       ,@bill_prov_gid
       ,@bill_prov_loc_gid
       ,@bill_prov_bus_gid
       ,@pay_prov_gid
       ,@pay_prov_loc_gid
       ,@pay_prov_bus_gid
       ,@i_submitted_drg
       ,@iDaysUsed
       ,@iAllowBonus
       ,@iPrimaryBeneAmt
       ,@poa
       ,@other_sub_first_name
       ,@other_sub_last_name
       ,@other_sub_middle_name
       ,@other_sub_suffix
       ,@other_sub_id_code
       ,@other_sub_seq_num_code
       ,@other_sub_relationship
       ,@other_sub_policy_number
       ,@other_sub_type_code
       ,@other_sub_ins_type
       ,@other_sub_address
       ,@other_sub_address_2
       ,@other_sub_city
       ,@other_sub_state
       ,@other_sub_zip_code
       ,@other_sub_ssn
       ,@other_payer_last_name
       ,@other_payer_address
       ,@other_payer_address_2
       ,@other_payer_city
       ,@other_payer_state
       ,@other_payer_zip_code
       ,@cap_write_off
       ,@condition_date
       ,@condition_diagnosis
       ,@CLM11_RelCause1
       ,@CLM11_RelCause2
       ,@sub_pa_number
       ,@sub_ref_number
       ,@similar_date
       ,@acc_amt_app_per_ded
       ,@acc_amt_app_per_mop
       ,@acc_amt_app_per_max
       ,@acc_max_rules_sid
       ,@acc_ded_rules_sid
       ,@acc_mop_rules_sid
       ,@acc_amt_remain_max
       ,@sec_bene_base_amt
       ,@acc_DaysUsed
       ,@IsAccident
       ,@acc_state
       ,@source_code
       ,@FacilityName
       ,@FacilityNPI
       ,@ClaimFrequencyCode
       ,@i_opr_provider_gid
       ,@i_opr_location_gid
       ,@i_opr_business_gid
       ,@PurchasedServiceAmount
       ,@PurchasedServiceNPI
       ,@EmergencyIndicator
       ,@MJ_vs_UN
       ,@LinePrimePaid
       ,@i_form_id
       ,@i_sub_drg_soi
       ,@i_drg_soi
       ,@i_drg_rom
       ,@iOnOrigSubmission
       ,@iAuthMatchRuleSID
       ,@iTradingPartnerGID
       ,@i_icd_code_type
       ,@i_provMatchingUsedBL_SHL
       ,@i_ProcessType
       ,@iAdjudicationOrder
       ,@iPaymentIntegrityRemarkCode
       ,@iAlternativeMemberResp
       ,@iGroupPricingSID
       ,@iManualOverride
       ,@iManualOvrAllow
       ,@iManualOvrApprove
       ,@iManualRemarkCode
       ,@iManualNetwork
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			SELECT @err_num = 0
			      ,@err_msg = ''

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @is_paper = @SearchID

			IF @i_date_submitted IS NULL
				BEGIN

					-- If a claim already has a date_submitted, then look it up and use it
					IF EXISTS(SELECT claim_number FROM #Claim_Dates WHERE claim_number = @i_claim_number)
						BEGIN
							SELECT @i_date_submitted	= date_submitted
							  FROM #Claim_Dates
							 WHERE claim_number			= @i_claim_number
						END
					ELSE
						BEGIN
							SELECT @i_date_submitted = ISNULL(@i_date_submitted, GETDATE())
							INSERT INTO #Claim_Dates(claim_number, date_submitted) VALUES (@i_claim_number, @i_date_submitted)
						END
				END

			IF @i_group_gid = -1
				BEGIN
					SELECT @i_group_gid		= ISNULL(G.group_gid, -1)
					  FROM Groups			G
					 WHERE G.record_status	= 'A'
					   AND G.group_id		= @i_group_number
				END

			IF @i_group_gid = -1
				BEGIN
					SELECT @err_num = 100
					      ,@err_msg = 'Could not find the group_gid for group, ' + @i_group_number + '.'
				END

			IF @err_num = 0
				BEGIN

					EXEC dbo.prOLTPInsertClaimRecords
					--SELECT
						 @i_claim_number
						,@i_line_number
						,@i_service_date
						,@i_date_submitted
						,@i_receive_date
						,@i_default_status
						,@i_group_gid
						,@i_contact_gid
						,@i_provider_gid
						,@i_location_gid
						,@i_business_gid
						,@i_specialty_id
						,@i_claim_type
						,@i_submitted_procedure_id
						,@i_adjudicated_procedure_id
						,@i_payment_procedure_id
						,@i_incentive_requirement
						,@i_modifier_1
						,@i_modifier_2
						,@i_modifier_3
						,@i_modifier_4
						,@i_modifier_5
						,@i_modifier_6
						,@i_modifier_7
						,@i_modifier_8
						,@i_modifier_9
						,@i_modifier_10
						,@i_submitted_cost
						,@i_submitted_fee
						,@i_submitted_tax
						,@i_submitted_copay
						,@i_approved_cost
						,@i_approved_fee
						,@i_approved_tax
						,@i_approved_copay
						,@i_allowed_cost
						,@i_allowed_fee
						,@i_allowed_tax
						,@i_allowed_copay
						,@i_payable_cost
						,@i_payable_fee
						,@i_payable_tax
						,@i_payable_copay
						,@i_billable_cost
						,@i_billable_fee
						,@i_billable_tax
						,@i_billable_copay
						,@i_gross_amount_due
						,@i_usual_and_customary
						,@i_product_type
						,@i_amt_app_per_ded
						,@i_amt_app_per_mop
						,@i_amt_app_per_max
						,@i_document_number
						,@i_network_search_gid
						,@i_network_gid
						,@i_plan_strategy_gid
						,@i_coverage_type
						,@i_claim_source_flag
						,@i_other_carrier_gid
						,@i_cob_subscriber
						,@i_routing_number
						,@i_version_number
						,@i_transaction_code
						,@i_prov_number
						,@i_prov_ssn
						,@i_prov_state
						,@i_group_number
						,@i_member_id
						,@i_birth_date
						,@i_first_name
						,@i_last_name
						,@i_relationship_code
						,@i_sex_of_patient
						,@i_other_cov_code
						,@i_other_cov_group
						,@i_other_cov_id
						,@i_other_cov_birth_date
						,@i_prior_auth_gid
						,@i_plan_strategy_sid
						,@i_price_strategy_sid
						,@i_price_schedule_sid
						,@i_copay_strategy_sid
						,@i_copay_schedule_sid
						,@i_benefit_strategy_sid
						,@i_max_rules_sid
						,@i_ded_rules_sid
						,@i_mop_rules_sid
						,@i_proc_exclusion_sid
						,@i_coverage_strategy_sid
						,@i_proc_class_relation_sid
						,@i_proc_payment_sid
						,@i_proc_rules_sid
						,@i_proc_step_therapy_sid
						,@i_proc_xcheck_sid
						,@i_assignment_code
						,@i_prime_pays_amount
						,@i_amt_remain_max
						,@i_amt_over_max
						,@i_incentive_level
						,@i_input_diagnosis_code
						,@i_internal_diagnosis_code
						,@i_prep_date
						,@i_seat_date
						,@i_fee_override
						,@i_cob_indicated
						,@i_comments_on_claim
						,@i_member_referral
						,@i_banding_date
						,@i_case_fee
						,@i_initial_down_payment
						,@i_treatment_months
						,@i_monthly_payment
						,@i_end_date
						,@i_initial_payment_amt
						,@i_additional_payments
						,@i_amount_of_each_payment
						,@i_total_to_be_paid
						,@i_subscriber_gid
						,@i_penalty_codes
						,@i_ovrd_approved
						,@i_ovrd_allowed
						,@i_processing_policies
						,@i_pay_as_class
						,@i_pend_code
						,@i_final_flag
						,@i_class_id
						,@i_chart_date
						,@i_accident_ind
						,@i_cob_savings
						,@i_predet_number
						,@i_clearing_number
						,@i_user_id
						,@i_network_flag
						,@i_status_code
						,@i_site_id
						,@i_pro_rate
						,@i_benefit_type
						,@i_claim_entry_update
						,@o_insert_upd_flag
						,@o_return_code
						,@o_num_rejects
						,@o_reject_codes
						,@o_num_msgs
						,@o_msgs
						,@l_Create_Resub_Recs
						,@i_user_lob
						,@i_pos_claim_id
						,@i_type_of_bill
						,@i_diag_code_1
						,@i_diag_code_2
						,@i_diag_code_3
						,@i_diag_code_4
						,@i_diag_code_5
						,@i_diag_code_6
						,@i_diag_code_7
						,@i_diag_code_8
						,@i_diag_code_9
						,@i_acc_code
						,@i_drg
						,@i_dischrg_status
						,@i_prin_proc_code
						,@i_claim_form_type
						,@i_rev
						,@i_pos
						,@i_tos
						,@i_service_date_to
						,@i_diag_ptr
						,@i_nc_chr
						,@i_ref_provider_gid
						,@i_ref_location_gid
						,@i_ref_business_gid
						,@i_atn_provider_gid
						,@i_atn_location_gid
						,@i_atn_business_gid
						,@iCodeParingGID
						,@iPrimaryDiagCode
						,@iSecDiagCode
						,@iDiagGrouper
						,@iReportClass
						,@iPatientCopay
						,@iTrueAllowed
						,@i_other_proc_code_A
						,@i_other_proc_code_B
						,@i_other_proc_code_C
						,@i_other_proc_code_D
						,@i_other_proc_code_E
						,@i_person_code
						,@iPatCoins
						,@iPatNotCovered
						,@o_claim_sid
						,@iAffiliationID
						,@iManualIntAmt
						,@iFileSID
						,@iEligCovSID
						,@iFeeScheduleID
						,@iCopayDifferential
						,@i_inform_text
						,@i_fill_num
						,@i_diag_code_10
						,@i_diag_code_11
						,@i_diag_code_12
						,@i_diag_code_13
						,@i_diag_code_14
						,@i_diag_code_15
						,@i_diag_code_16
						,@i_diag_code_17
						,@i_diag_code_18
						,@i_other_proc_code_date_a
						,@i_other_proc_code_date_b
						,@i_other_proc_code_date_c
						,@i_other_proc_code_date_d
						,@i_other_proc_code_date_e
						,@i_cond_code_1
						,@i_cond_code_2
						,@i_cond_code_3
						,@i_cond_code_4
						,@i_cond_code_5
						,@i_cond_code_6
						,@i_cond_code_7
						,@i_cond_code_8
						,@i_cond_code_9
						,@i_cond_code_10
						,@i_cond_code_11
						,@i_type_admn
						,@i_admit_dx
						,@i_pat_reason_dx_1
						,@i_pat_reason_dx_2
						,@i_pat_reason_dx_3
						,@i_pps_code
						,@i_prin_proc_code_date
						,@iCOBSavingsApplied
						,@iCOBSavingsAccrued
						,@i_member_address
						,@i_member_address2
						,@i_member_city
						,@i_member_state
						,@i_member_zip_code
						,@i_member_middle_name
						,@i_member_country
						,@i_ben_code_837
						,@i_special_prog_code
						,@i_EPSDT
						,@i_other_proc_code_f
						,@i_other_proc_code_date_f
						,@i_other_proc_code_g
						,@i_other_proc_code_date_g
						,@i_other_proc_code_h
						,@i_other_proc_code_date_h
						,@i_other_proc_code_i
						,@i_other_proc_code_date_i
						,@i_other_proc_code_j
						,@i_other_proc_code_date_j
						,@i_other_proc_code_k
						,@i_other_proc_code_date_k
						,@i_other_proc_code_l
						,@i_other_proc_code_date_l
						,@i_other_proc_code_m
						,@i_other_proc_code_date_m
						,@i_other_proc_code_n
						,@i_other_proc_code_date_n
						,@i_other_proc_code_o
						,@i_other_proc_code_date_o
						,@i_other_proc_code_p
						,@i_other_proc_code_date_p
						,@i_other_proc_code_q
						,@i_other_proc_code_date_q
						,@i_other_proc_code_r
						,@i_other_proc_code_date_r
						,@i_other_proc_code_s
						,@i_other_proc_code_date_s
						,@i_other_proc_code_t
						,@i_other_proc_code_date_t
						,@i_other_proc_code_u
						,@i_other_proc_code_date_u
						,@i_other_proc_code_v
						,@i_other_proc_code_date_v
						,@i_other_proc_code_w
						,@i_other_proc_code_date_w
						,@i_other_proc_code_x
						,@i_other_proc_code_date_x
						,@i_diag_code_19
						,@i_diag_code_20
						,@i_diag_code_21
						,@i_diag_code_22
						,@i_diag_code_23
						,@i_diag_code_24
						,@i_diag_code_25
						,@i_repricer_amount
						,@IsPended
						,@StopLossClaim
						,@iCleanClaimIndicator
						,@iInitialEntry
						,@bill_prov_gid
						,@bill_prov_loc_gid
						,@bill_prov_bus_gid
						,@pay_prov_gid
						,@pay_prov_loc_gid
						,@pay_prov_bus_gid
						,@i_submitted_drg
						,@iDaysUsed
						,@iAllowBonus
						,@iPrimaryBeneAmt
						,@poa
						,@other_sub_first_name
						,@other_sub_last_name
						,@other_sub_middle_name
						,@other_sub_suffix
						,@other_sub_id_code
						,@other_sub_seq_num_code
						,@other_sub_relationship
						,@other_sub_policy_number
						,@other_sub_type_code
						,@other_sub_ins_type
						,@other_sub_address
						,@other_sub_address_2
						,@other_sub_city
						,@other_sub_state
						,@other_sub_zip_code
						,@other_sub_ssn
						,@other_payer_last_name
						,@other_payer_address
						,@other_payer_address_2
						,@other_payer_city
						,@other_payer_state
						,@other_payer_zip_code
						,@cap_write_off
						,@condition_date
						,@condition_diagnosis
						,@CLM11_RelCause1
						,@CLM11_RelCause2
						,@sub_pa_number
						,@sub_ref_number
						,@similar_date
						,@acc_amt_app_per_ded
						,@acc_amt_app_per_mop
						,@acc_amt_app_per_max
						,@acc_max_rules_sid
						,@acc_ded_rules_sid
						,@acc_mop_rules_sid
						,@acc_amt_remain_max
						,@sec_bene_base_amt
						,@acc_DaysUsed
						,@IsAccident
						,@acc_state
						,@source_code
						,@FacilityName
						,@FacilityNPI
						,@ClaimFrequencyCode
						,@i_opr_provider_gid
						,@i_opr_location_gid
						,@i_opr_business_gid
						,@PurchasedServiceAmount
						,@PurchasedServiceNPI
						,@EmergencyIndicator
						,@MJ_vs_UN
						,@LinePrimePaid
						,@i_form_id
						,@i_sub_drg_soi
						,@i_drg_soi
						,@i_drg_rom
						,@iOnOrigSubmission
						,@iAuthMatchRuleSID
						,@iTradingPartnerGID
						,@i_icd_code_type
						,@i_provMatchingUsedBL_SHL
						,@i_ProcessType
						,@iAdjudicationOrder
						,@iPaymentIntegrityRemarkCode
						,@iAlternativeMemberResp
						,@iGroupPricingSID
						,@iManualOverride
						,@iManualOvrAllow
						,@iManualOvrApprove
						,@iManualRemarkCode
						,@iManualNetwork

					SELECT @claim_sid = 0

					SELECT TOP 1
						   @claim_sid			= ISNULL(CL.claim_sid, 0)
					  FROM dbo.Claims_Log_V2	CL
					 WHERE CL.claim_number		= @i_claim_number
					   AND CL.line_number		= @i_line_number
					   AND CL.date_submitted	= @i_date_submitted

					IF @claim_sid <> 0
						BEGIN
							UPDATE Claims_Log_V2
							   SET process_code		= 1
								  ,support_codes	= SUBSTRING(support_codes, 1, 27) + @is_paper + SUBSTRING(support_codes, 29, 9999)
							 WHERE claim_sid		= @claim_sid

						END
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_claim_number, @i_line_number, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM RFFClaimInsert_Cursor
         INTO @SearchID
             ,@i_claim_number
             ,@i_line_number
             ,@i_service_date
             ,@i_date_submitted
             ,@i_receive_date
             ,@i_default_status
             ,@i_group_gid
             ,@i_contact_gid
             ,@i_provider_gid
             ,@i_location_gid
             ,@i_business_gid
             ,@i_specialty_id
             ,@i_claim_type
             ,@i_submitted_procedure_id
             ,@i_adjudicated_procedure_id
             ,@i_payment_procedure_id
             ,@i_incentive_requirement
             ,@i_modifier_1
             ,@i_modifier_2
             ,@i_modifier_3
             ,@i_modifier_4
             ,@i_modifier_5
             ,@i_modifier_6
             ,@i_modifier_7
             ,@i_modifier_8
             ,@i_modifier_9
             ,@i_modifier_10
             ,@i_submitted_cost
             ,@i_submitted_fee
             ,@i_submitted_tax
             ,@i_submitted_copay
             ,@i_approved_cost
             ,@i_approved_fee
             ,@i_approved_tax
             ,@i_approved_copay
             ,@i_allowed_cost
             ,@i_allowed_fee
             ,@i_allowed_tax
             ,@i_allowed_copay
             ,@i_payable_cost
             ,@i_payable_fee
             ,@i_payable_tax
             ,@i_payable_copay
             ,@i_billable_cost
             ,@i_billable_fee
             ,@i_billable_tax
             ,@i_billable_copay
             ,@i_gross_amount_due
             ,@i_usual_and_customary
             ,@i_product_type
             ,@i_amt_app_per_ded
             ,@i_amt_app_per_mop
             ,@i_amt_app_per_max
             ,@i_document_number
             ,@i_network_search_gid
             ,@i_network_gid
             ,@i_plan_strategy_gid
             ,@i_coverage_type
             ,@i_claim_source_flag
             ,@i_other_carrier_gid
             ,@i_cob_subscriber
             ,@i_routing_number
             ,@i_version_number
             ,@i_transaction_code
             ,@i_prov_number
             ,@i_prov_ssn
             ,@i_prov_state
             ,@i_group_number
             ,@i_member_id
             ,@i_birth_date
             ,@i_first_name
             ,@i_last_name
             ,@i_relationship_code
             ,@i_sex_of_patient
             ,@i_other_cov_code
             ,@i_other_cov_group
             ,@i_other_cov_id
             ,@i_other_cov_birth_date
             ,@i_prior_auth_gid
             ,@i_plan_strategy_sid
             ,@i_price_strategy_sid
             ,@i_price_schedule_sid
             ,@i_copay_strategy_sid
             ,@i_copay_schedule_sid
             ,@i_benefit_strategy_sid
             ,@i_max_rules_sid
             ,@i_ded_rules_sid
             ,@i_mop_rules_sid
             ,@i_proc_exclusion_sid
             ,@i_coverage_strategy_sid
             ,@i_proc_class_relation_sid
             ,@i_proc_payment_sid
             ,@i_proc_rules_sid
             ,@i_proc_step_therapy_sid
             ,@i_proc_xcheck_sid
             ,@i_assignment_code
             ,@i_prime_pays_amount
             ,@i_amt_remain_max
             ,@i_amt_over_max
             ,@i_incentive_level
             ,@i_input_diagnosis_code
             ,@i_internal_diagnosis_code
             ,@i_prep_date
             ,@i_seat_date
             ,@i_fee_override
             ,@i_cob_indicated
             ,@i_comments_on_claim
             ,@i_member_referral
             ,@i_banding_date
             ,@i_case_fee
             ,@i_initial_down_payment
             ,@i_treatment_months
             ,@i_monthly_payment
             ,@i_end_date
             ,@i_initial_payment_amt
             ,@i_additional_payments
             ,@i_amount_of_each_payment
             ,@i_total_to_be_paid
             ,@i_subscriber_gid
             ,@i_penalty_codes
             ,@i_ovrd_approved
             ,@i_ovrd_allowed
             ,@i_processing_policies
             ,@i_pay_as_class
             ,@i_pend_code
             ,@i_final_flag
             ,@i_class_id
             ,@i_chart_date
             ,@i_accident_ind
             ,@i_cob_savings
             ,@i_predet_number
             ,@i_clearing_number
             ,@i_user_id
             ,@i_network_flag
             ,@i_status_code
             ,@i_site_id
             ,@i_pro_rate
             ,@i_benefit_type
             ,@i_claim_entry_update
             ,@o_insert_upd_flag
             ,@o_return_code
             ,@o_num_rejects
             ,@o_reject_codes
             ,@o_num_msgs
             ,@o_msgs
             ,@l_Create_Resub_Recs
             ,@i_user_lob
             ,@i_pos_claim_id
             ,@i_type_of_bill
             ,@i_diag_code_1
             ,@i_diag_code_2
             ,@i_diag_code_3
             ,@i_diag_code_4
             ,@i_diag_code_5
             ,@i_diag_code_6
             ,@i_diag_code_7
             ,@i_diag_code_8
             ,@i_diag_code_9
             ,@i_acc_code
             ,@i_drg
             ,@i_dischrg_status
             ,@i_prin_proc_code
             ,@i_claim_form_type
             ,@i_rev
             ,@i_pos
             ,@i_tos
             ,@i_service_date_to
             ,@i_diag_ptr
             ,@i_nc_chr
             ,@i_ref_provider_gid
             ,@i_ref_location_gid
             ,@i_ref_business_gid
             ,@i_atn_provider_gid
             ,@i_atn_location_gid
             ,@i_atn_business_gid
             ,@iCodeParingGID
             ,@iPrimaryDiagCode
             ,@iSecDiagCode
             ,@iDiagGrouper
             ,@iReportClass
             ,@iPatientCopay
             ,@iTrueAllowed
             ,@i_other_proc_code_A
             ,@i_other_proc_code_B
             ,@i_other_proc_code_C
             ,@i_other_proc_code_D
             ,@i_other_proc_code_E
             ,@i_person_code
             ,@iPatCoins
             ,@iPatNotCovered
             ,@o_claim_sid
             ,@iAffiliationID
             ,@iManualIntAmt
             ,@iFileSID
             ,@iEligCovSID
             ,@iFeeScheduleID
             ,@iCopayDifferential
             ,@i_inform_text
             ,@i_fill_num
             ,@i_diag_code_10
             ,@i_diag_code_11
             ,@i_diag_code_12
             ,@i_diag_code_13
             ,@i_diag_code_14
             ,@i_diag_code_15
             ,@i_diag_code_16
             ,@i_diag_code_17
             ,@i_diag_code_18
             ,@i_other_proc_code_date_a
             ,@i_other_proc_code_date_b
             ,@i_other_proc_code_date_c
             ,@i_other_proc_code_date_d
             ,@i_other_proc_code_date_e
             ,@i_cond_code_1
             ,@i_cond_code_2
             ,@i_cond_code_3
             ,@i_cond_code_4
             ,@i_cond_code_5
             ,@i_cond_code_6
             ,@i_cond_code_7
             ,@i_cond_code_8
             ,@i_cond_code_9
             ,@i_cond_code_10
             ,@i_cond_code_11
             ,@i_type_admn
             ,@i_admit_dx
             ,@i_pat_reason_dx_1
             ,@i_pat_reason_dx_2
             ,@i_pat_reason_dx_3
             ,@i_pps_code
             ,@i_prin_proc_code_date
             ,@iCOBSavingsApplied
             ,@iCOBSavingsAccrued
             ,@i_member_address
             ,@i_member_address2
             ,@i_member_city
             ,@i_member_state
             ,@i_member_zip_code
             ,@i_member_middle_name
             ,@i_member_country
             ,@i_ben_code_837
             ,@i_special_prog_code
             ,@i_EPSDT
             ,@i_other_proc_code_f
             ,@i_other_proc_code_date_f
             ,@i_other_proc_code_g
             ,@i_other_proc_code_date_g
             ,@i_other_proc_code_h
             ,@i_other_proc_code_date_h
             ,@i_other_proc_code_i
             ,@i_other_proc_code_date_i
             ,@i_other_proc_code_j
             ,@i_other_proc_code_date_j
             ,@i_other_proc_code_k
             ,@i_other_proc_code_date_k
             ,@i_other_proc_code_l
             ,@i_other_proc_code_date_l
             ,@i_other_proc_code_m
             ,@i_other_proc_code_date_m
             ,@i_other_proc_code_n
             ,@i_other_proc_code_date_n
             ,@i_other_proc_code_o
             ,@i_other_proc_code_date_o
             ,@i_other_proc_code_p
             ,@i_other_proc_code_date_p
             ,@i_other_proc_code_q
             ,@i_other_proc_code_date_q
             ,@i_other_proc_code_r
             ,@i_other_proc_code_date_r
             ,@i_other_proc_code_s
             ,@i_other_proc_code_date_s
             ,@i_other_proc_code_t
             ,@i_other_proc_code_date_t
             ,@i_other_proc_code_u
             ,@i_other_proc_code_date_u
             ,@i_other_proc_code_v
             ,@i_other_proc_code_date_v
             ,@i_other_proc_code_w
             ,@i_other_proc_code_date_w
             ,@i_other_proc_code_x
             ,@i_other_proc_code_date_x
             ,@i_diag_code_19
             ,@i_diag_code_20
             ,@i_diag_code_21
             ,@i_diag_code_22
             ,@i_diag_code_23
             ,@i_diag_code_24
             ,@i_diag_code_25
             ,@i_repricer_amount
             ,@IsPended
             ,@StopLossClaim
             ,@iCleanClaimIndicator
             ,@iInitialEntry
             ,@bill_prov_gid
             ,@bill_prov_loc_gid
             ,@bill_prov_bus_gid
             ,@pay_prov_gid
             ,@pay_prov_loc_gid
             ,@pay_prov_bus_gid
             ,@i_submitted_drg
             ,@iDaysUsed
             ,@iAllowBonus
             ,@iPrimaryBeneAmt
             ,@poa
             ,@other_sub_first_name
             ,@other_sub_last_name
             ,@other_sub_middle_name
             ,@other_sub_suffix
             ,@other_sub_id_code
             ,@other_sub_seq_num_code
             ,@other_sub_relationship
             ,@other_sub_policy_number
             ,@other_sub_type_code
             ,@other_sub_ins_type
             ,@other_sub_address
             ,@other_sub_address_2
             ,@other_sub_city
             ,@other_sub_state
             ,@other_sub_zip_code
             ,@other_sub_ssn
             ,@other_payer_last_name
             ,@other_payer_address
             ,@other_payer_address_2
             ,@other_payer_city
             ,@other_payer_state
             ,@other_payer_zip_code
             ,@cap_write_off
             ,@condition_date
             ,@condition_diagnosis
             ,@CLM11_RelCause1
             ,@CLM11_RelCause2
             ,@sub_pa_number
             ,@sub_ref_number
             ,@similar_date
             ,@acc_amt_app_per_ded
             ,@acc_amt_app_per_mop
             ,@acc_amt_app_per_max
             ,@acc_max_rules_sid
             ,@acc_ded_rules_sid
             ,@acc_mop_rules_sid
             ,@acc_amt_remain_max
             ,@sec_bene_base_amt
             ,@acc_DaysUsed
             ,@IsAccident
             ,@acc_state
             ,@source_code
             ,@FacilityName
             ,@FacilityNPI
             ,@ClaimFrequencyCode
             ,@i_opr_provider_gid
             ,@i_opr_location_gid
             ,@i_opr_business_gid
             ,@PurchasedServiceAmount
             ,@PurchasedServiceNPI
             ,@EmergencyIndicator
             ,@MJ_vs_UN
             ,@LinePrimePaid
             ,@i_form_id
             ,@i_sub_drg_soi
             ,@i_drg_soi
             ,@i_drg_rom
             ,@iOnOrigSubmission
             ,@iAuthMatchRuleSID
             ,@iTradingPartnerGID
             ,@i_icd_code_type
             ,@i_provMatchingUsedBL_SHL
             ,@i_ProcessType
             ,@iAdjudicationOrder
             ,@iPaymentIntegrityRemarkCode
             ,@iAlternativeMemberResp
             ,@iGroupPricingSID
             ,@iManualOverride
             ,@iManualOvrAllow
             ,@iManualOvrApprove
             ,@iManualRemarkCode
             ,@iManualNetwork
             ,@record_id
             ,@static_gid
	END

CLOSE RFFClaimInsert_Cursor
DEALLOCATE RFFClaimInsert_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#RFFClaimInsert') IS NOT NULL
	DROP TABLE #RFFClaimInsert

IF OBJECT_ID('tempdb.dbo.#Claim_Dates') IS NOT NULL
	DROP TABLE #Claim_Dates

END
GO

