IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocations
Purpose:    Create servicelocations data from CorderAutomation
Method:     ServiceLocations
Screen GID: 2000
Procedure:  dbo.prPMBulkAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2019	DK				Original procedure
12/10/2019	DK				Add field i_board_cert_url
02/07/2020	DK				Renamed Temp table to avoid naming conflicts
03/24/2021	DK				Added Payment Destination (SP45)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocations '100-Config%', 22, 'ServiceLocations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocations
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

DECLARE @i_entity_name                              VARCHAR(50)
       ,@i_key_1_field                              VARCHAR(50)
       ,@i_key_2_field                              VARCHAR(50)
       ,@i_key_3_field                              VARCHAR(50)
       ,@i_key_4_field                              VARCHAR(50)
       ,@i_key_5_field                              VARCHAR(50)
       ,@i_key_6_field                              VARCHAR(50)
       ,@i_eDATE                                    VARCHAR(50)
       ,@i_tDate                                    VARCHAR(50)
       ,@i_key_9_field                              VARCHAR(50)
       ,@i_key_10_field                             VARCHAR(50)
       ,@i_action                                   VARCHAR(10)
       ,@i_date_time_modified                       VARCHAR(20)
       ,@iUserID                                    VARCHAR(25)
       ,@i_P_Provider_id                            VARCHAR(60)
       ,@i_P_Practice_As                            VARCHAR(50)
       ,@i_P_HIPPA_id                               VARCHAR(50)
       ,@i_NPI_Verif                                VARCHAR(50)
       ,@i_Medicaid_Participatient                  VARCHAR(50)
       ,@i_P_Medicaid_id                            VARCHAR(50)
       ,@i_Medicaid_Requested                       VARCHAR(50)
       ,@i_Medicaid_Received                        VARCHAR(50)
       ,@i_Medicare_Participatient                  VARCHAR(50)
       ,@i_P_Medicare_id                            VARCHAR(50)
       ,@i_Medicare_Requested                       VARCHAR(50)
       ,@i_Medicare_Received                        VARCHAR(50)
       ,@i_P_name_prefix                            VARCHAR(50)
       ,@i_P_first_name                             VARCHAR(50)
       ,@i_P_last_name                              VARCHAR(100)
       ,@i_P_middle_name                            VARCHAR(50)
       ,@i_Prof_desg_1                              VARCHAR(50)
       ,@i_Prof_desg_2                              VARCHAR(50)
       ,@i_Prof_desg_3                              VARCHAR(50)
       ,@i_P_name_suffix                            VARCHAR(50)
       ,@i_P_soc_sec_number                         VARCHAR(50)
       ,@i_P_date_of_birth                          VARCHAR(50)
       ,@i_P_Gender                                 VARCHAR(50)
       ,@i_P_health_impairment                      VARCHAR(50)
       ,@i_P_email                                  VARCHAR(100)
       ,@i_P_lang1                                  VARCHAR(50)
       ,@i_P_lang2                                  VARCHAR(50)
       ,@i_P_ethnicity                              VARCHAR(50)
       ,@i_US_citizen                               VARCHAR(50)
       ,@i_VisaNo                                   VARCHAR(50)
       ,@i_Agree_version                            VARCHAR(50)
       ,@i_Agree_Signee                             VARCHAR(80)
       ,@i_Agree_Sign_date                          VARCHAR(50)
       ,@i_UPIN                                     VARCHAR(50)
       ,@i_H_loc_id                                 VARCHAR(50)
       ,@i_H_loc_name                               VARCHAR(100)
       ,@i_H_address1                               VARCHAR(50)
       ,@i_H_address2                               VARCHAR(50)
       ,@i_H_zip                                    VARCHAR(50)
       ,@i_H_city                                   VARCHAR(50)
       ,@i_H_state                                  VARCHAR(50)
       ,@i_H_County                                 VARCHAR(50)
       ,@i_H_Country                                VARCHAR(50)
       ,@i_O_loc_id                                 VARCHAR(50)
       ,@i_O_loc_name                               VARCHAR(100)
       ,@i_O_address1                               VARCHAR(50)
       ,@i_O_address2                               VARCHAR(50)
       ,@i_O_zip                                    VARCHAR(50)
       ,@i_O_city                                   VARCHAR(50)
       ,@i_O_state                                  VARCHAR(50)
       ,@i_O_County                                 VARCHAR(50)
       ,@i_O_Country                                VARCHAR(50)
       ,@i_BU_business_unit_id                      VARCHAR(50)
       ,@i_BU_npi_id                                VARCHAR(50)
       ,@i_BU_npi_verif                             VARCHAR(50)
       ,@i_BU_business_name                         VARCHAR(100)
       ,@i_BU_business_type                         VARCHAR(50)
       ,@i_T_tax_id_number                          VARCHAR(50)
       ,@i_T_tax_id_type                            VARCHAR(50)
       ,@i_BU_doing_business_as                     VARCHAR(50)
	   ,@iPaymentDestination						VARCHAR(50)	--SP45
       ,@i_BU_location_id                           VARCHAR(50)
       ,@i_BU_location_name                         VARCHAR(100)
       ,@i_BU_address_1                             VARCHAR(55)
       ,@i_BU_address_2                             VARCHAR(55)
       ,@i_BU_zip_code                              VARCHAR(50)
       ,@i_BU_city                                  VARCHAR(50)
       ,@i_BU_state                                 VARCHAR(50)
       ,@i_BU_county                                VARCHAR(50)
       ,@i_BU_country                               VARCHAR(50)
       ,@i_BU_email_address                         VARCHAR(100)
       ,@i_BU_phone_number                          VARCHAR(50)
       ,@i_BU_fax_number                            VARCHAR(50)
       ,@i_BU_owner_name                            VARCHAR(50)
       ,@i_BU_owner_license                         VARCHAR(50)
       ,@i_BUMA_location_id                         VARCHAR(50)
       ,@i_BUMA_location_name                       VARCHAR(100)
       ,@i_BUMA_address_1                           VARCHAR(55)
       ,@i_BUMA_address_2                           VARCHAR(55)
       ,@i_BUMA_zip_code                            VARCHAR(50)
       ,@i_BUMA_city                                VARCHAR(50)
       ,@i_BUMA_state                               VARCHAR(50)
       ,@i_BUMA_county                              VARCHAR(50)
       ,@i_BUMA_country                             VARCHAR(50)
       ,@i_BUMA_payment_center                      VARCHAR(50)
       ,@i_T_tin_effective_date                     VARCHAR(50)
       ,@i_T_tin_end_date                           VARCHAR(50)
       ,@i_T_w9_onfile                              VARCHAR(50)
       ,@i_T_W9_Completed                           VARCHAR(50)
       ,@i_T_W9_Date_Requested                      VARCHAR(50)
       ,@i_T_w9_rec_date                            VARCHAR(50)
       ,@i_T_w9_business_type                       VARCHAR(50)
       ,@i_T_name_1099                              VARCHAR(55)
       ,@i_T_name_1099_2                            VARCHAR(50)
       ,@i_B_waiver                                 VARCHAR(50)
       ,@i_B_waiver_percentage                      VARCHAR(50)
       ,@i_T_location_id                            VARCHAR(50)
       ,@i_T_location_name                          VARCHAR(100)
       ,@i_T_address_1                              VARCHAR(55)
       ,@i_T_address_2                              VARCHAR(55)
       ,@i_T_zip_code                               VARCHAR(50)
       ,@i_T_city                                   VARCHAR(50)
       ,@i_T_state                                  VARCHAR(50)
       ,@i_T_county                                 VARCHAR(50)
       ,@i_T_country                                VARCHAR(50)
       ,@i_B_aba_number                             VARCHAR(50)
       ,@i_B_bank_name                              VARCHAR(50)
       ,@i_B_branch_phone_number                    VARCHAR(50)
       ,@i_B_account_type                           VARCHAR(50)
       ,@i_B_account_number                         VARCHAR(50)
       ,@i_B_eft_status                             VARCHAR(50)
       ,@i_B_eft_effective_date                     VARCHAR(50)
       ,@i_B_eft_decline_code                       VARCHAR(50)
       ,@i_B_eft_decline_start_date                 VARCHAR(50)
       ,@i_B_eft_decline_end_date                   VARCHAR(50)
       ,@i_C_cap_pcp_roster                         VARCHAR(50)
       ,@i_SL_location_id                           VARCHAR(50)
       ,@i_SL_location_name                         VARCHAR(100)
       ,@i_SL_address_1                             VARCHAR(55)
       ,@i_SL_address_2                             VARCHAR(55)
       ,@i_SL_zip_code                              VARCHAR(50)
       ,@i_SL_city                                  VARCHAR(50)
       ,@i_SL_state                                 VARCHAR(50)
       ,@i_SL_county                                VARCHAR(50)
       ,@i_SL_country                               VARCHAR(50)
       ,@i_MA_location_id                           VARCHAR(50)
       ,@i_MA_location_name                         VARCHAR(100)
       ,@i_MA_address_1                             VARCHAR(55)
       ,@i_MA_address_2                             VARCHAR(55)
       ,@i_MA_zip_code                              VARCHAR(50)
       ,@i_MA_city                                  VARCHAR(50)
       ,@i_MA_state                                 VARCHAR(50)
       ,@i_MA_county                                VARCHAR(50)
       ,@i_MA_country                               VARCHAR(50)
       ,@i_SL_contact_fname                         VARCHAR(50)
       ,@i_SL_contact_lname                         VARCHAR(60)
       ,@i_SL_contact_phone                         VARCHAR(50)
       ,@i_SL_contact_fax                           VARCHAR(50)
       ,@i_SL_contact_email                         VARCHAR(100)
       ,@i_SL_emerg_phone                           VARCHAR(50)
       ,@i_Alt_fax_number                           VARCHAR(50)
       ,@i_SL_website_url                           VARCHAR(255)
       ,@i_primary_location_indicator               VARCHAR(50)
       ,@i_SL_status_code                           VARCHAR(50)
       ,@i_SL_assign_override_flag                  VARCHAR(50)
       ,@i_SL_cust_prov_id                          VARCHAR(50)
       ,@i_SL_npf_site_id                           VARCHAR(50)
       ,@i_SL_add_override_code                     VARCHAR(50)
       ,@i_SL_filed_fee_id                          VARCHAR(50)
       ,@i_SL_default_deliv_method                  VARCHAR(50)
       ,@i_show_in_directory                        VARCHAR(50)
       ,@i_handicap_accessible                      VARCHAR(50)
       ,@i_handicap_acc_date                        VARCHAR(50)
       ,@i_accept_new_patient                       VARCHAR(50)
       ,@i_appt_wait_days                           VARCHAR(50)
       ,@i_min_patient_age                          INT
       ,@i_max_patient_age                          INT
       ,@i_Accept_Dis                               VARCHAR(50)
       ,@i_TranslationServices                      VARCHAR(50)
       ,@i_TTYService                               VARCHAR(50)
       ,@i_WheelAccess_ExamRoom                     VARCHAR(50)
       ,@i_WheelAccess_RestRoom                     VARCHAR(50)
       ,@i_WheelAccess_Ramp                         VARCHAR(50)
       ,@i_PublicTrans_Access                       VARCHAR(50)
       ,@i_accepts_hiv_aids_patients                VARCHAR(50)
       ,@i_accepts_co_occuring_disorders_patients   VARCHAR(50)
       ,@i_accepts_chronic_illness_patients         VARCHAR(50)
       ,@i_accepts_physical_disabilities_patients   VARCHAR(50)
       ,@i_accepts_serious_mental_illness_patients  VARCHAR(50)
       ,@i_accepts_homeless_patients                VARCHAR(50)
       ,@i_accepts_blind_visually_impaired_patients VARCHAR(50)
       ,@i_accepts_deaf_hearing_impaired_patients   VARCHAR(50)
       ,@i_adjustable_exam_table                    VARCHAR(50)
       ,@i_handicap_parking                         VARCHAR(50)
       ,@i_hour_24                                  VARCHAR(50)
       ,@i_mon                                      VARCHAR(50)
       ,@i_language_1                               VARCHAR(50)
       ,@i_tue                                      VARCHAR(50)
       ,@i_language_2                               VARCHAR(50)
       ,@i_wed                                      VARCHAR(50)
       ,@i_language_3                               VARCHAR(50)
       ,@i_thu                                      VARCHAR(50)
       ,@i_language_4                               VARCHAR(50)
       ,@i_fri                                      VARCHAR(50)
       ,@i_sat                                      VARCHAR(50)
       ,@i_sun                                      VARCHAR(50)
       ,@i_drg_version                              VARCHAR(50)
       ,@i_SL_new_effective_date                    VARCHAR(50)
       ,@i_SL_new_termination_date                  VARCHAR(50)
       ,@i_npi_id                                   VARCHAR(50)
       ,@i_SL_npi_verif                             VARCHAR(50)
       ,@i_Loc_Category                             VARCHAR(50)
       ,@i_SL_termination_reason                    VARCHAR(50)
       ,@iServiceLocationName                       VARCHAR(100)	
       ,@i_chain_code                               VARCHAR(50)
       ,@i_chain_name                               VARCHAR(255)
       ,@i_dispenser_class                          VARCHAR(50)
       ,@i_dispenser_type                           VARCHAR(50)
       ,@i_license_id                               VARCHAR(50)
       ,@i_license_type                             VARCHAR(50)
       ,@i_license_date                             VARCHAR(50)
       ,@i_license_term_date                        VARCHAR(50)
       ,@i_license_state                            VARCHAR(50)
       ,@i_practice_in                              VARCHAR(50)
       ,@i_verify_start_date                        VARCHAR(50)
       ,@i_verify_date                              VARCHAR(50)
       ,@i_verifier_name                            VARCHAR(50)
       ,@i_verifier_phone                           VARCHAR(50)
       ,@i_BAC                                      VARCHAR(50)
       ,@i_Bus_Code                                 VARCHAR(50)
       ,@i_Schedule                                 VARCHAR(50)
       ,@i_location_id                              VARCHAR(55)
       ,@i_location_desc                            VARCHAR(55)
       ,@i_address_1                                VARCHAR(55)
       ,@i_address_2                                VARCHAR(55)
       ,@i_zip_code                                 VARCHAR(50)
       ,@i_city                                     VARCHAR(50)
       ,@i_state                                    VARCHAR(50)
       ,@i_county                                   VARCHAR(50)
       ,@i_country                                  VARCHAR(50)
       ,@i_P_malprac_carrier                        VARCHAR(50)
       ,@i_P_malprac_policy                         VARCHAR(50)
       ,@i_P_malprac_eff_date                       VARCHAR(50)
       ,@i_P_malprac_term_date                      VARCHAR(50)
       ,@i_P_Verif_Date_Started                     VARCHAR(50)
       ,@i_P_Verif_Date_Completed                   VARCHAR(50)
       ,@i_P_malprac_limit_occur                    VARCHAR(50)
       ,@i_P_malprac_limit_year                     VARCHAR(50)
       ,@i_P_Aggregate_Amount                       VARCHAR(50)
       ,@i_P_Coverage_Type                          VARCHAR(50)
       ,@i_P_Carrier_Time                           VARCHAR(50)
       ,@i_P_Carrier_span                           VARCHAR(50)
       ,@i_P_Notes                                  VARCHAR(100)
       ,@i_P_Carrier_Loc_ID                         VARCHAR(50)
       ,@i_P_Carrier_Location_Desc                  VARCHAR(50)
       ,@i_P_Carrier_Address1                       VARCHAR(50)
       ,@i_P_Carrier_Address2                       VARCHAR(50)
       ,@i_P_Carrier_Zip                            VARCHAR(50)
       ,@i_P_Carrier_City                           VARCHAR(50)
       ,@i_P_Carrier_State                          VARCHAR(50)
       ,@i_P_Carrier_County                         VARCHAR(50)
       ,@i_P_Carrier_Country                        VARCHAR(50)
       ,@i_P_Verifer_Name                           VARCHAR(50)
       ,@i_P_Verifer_Phone                          VARCHAR(50)
       ,@i_S_specialty                              VARCHAR(50)
       ,@i_S_specialty_desc                         VARCHAR(100)
       ,@i_S_treat_as_specialty                     VARCHAR(50)
       ,@i_S_treat_specialty_desc                   VARCHAR(100)
       ,@i_primary_indicator                        VARCHAR(50)
       ,@i_S_school                                 VARCHAR(50)
       ,@i_S_grad_year                              VARCHAR(50)
       ,@i_S_res_comp_date                          VARCHAR(50)
       ,@i_S_board_elig_date                        VARCHAR(50)
       ,@i_S_board_cert                             VARCHAR(50)
       ,@i_board_name                               VARCHAR(50)
	   ,@i_board_cert_url							VARCHAR(300)
       ,@i_S_print_as_spec                          VARCHAR(50)
       ,@i_spi_id                                   VARCHAR(60)
       ,@i_sp_npi_id                                VARCHAR(50)
       ,@i_sp_npi_verif                             VARCHAR(50)
       ,@i_scheduled_date                           VARCHAR(50)
       ,@i_experation_date                          VARCHAR(50)
       ,@i_Recertification_date                     VARCHAR(50)
       ,@i_reporting_type                           VARCHAR(50)
       ,@i_S_State_Rpt_type                         VARCHAR(50)
       ,@i_HMS_Specialty_ID                         VARCHAR(50)
       ,@o_status                                   INT
       ,@o_message                                  VARCHAR(100)
       ,@i_DisplayResults                           VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsData') IS NOT NULL
	DROP TABLE #ServiceLocationsData

CREATE TABLE #ServiceLocationsData
      (SearchID                                   VARCHAR(200)
      ,i_entity_name                              VARCHAR(50)       DEFAULT('Prov_Inc1')
      ,i_key_1_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                              VARCHAR(50)       DEFAULT('0')
      ,i_eDATE                                    VARCHAR(50)       DEFAULT('0')
      ,i_tDate                                    VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                             VARCHAR(50)       DEFAULT('0')
      ,i_action                                   VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified                       VARCHAR(20)       DEFAULT('')
      ,iUserID                                    VARCHAR(25)       DEFAULT('')
      ,i_P_Provider_id                            VARCHAR(60)
      ,i_P_Practice_As                            VARCHAR(50)
      ,i_P_HIPPA_id                               VARCHAR(50)
      ,i_NPI_Verif                                VARCHAR(50)
      ,i_Medicaid_Participatient                  VARCHAR(50)
      ,i_P_Medicaid_id                            VARCHAR(50)
      ,i_Medicaid_Requested                       VARCHAR(50)
      ,i_Medicaid_Received                        VARCHAR(50)
      ,i_Medicare_Participatient                  VARCHAR(50)
      ,i_P_Medicare_id                            VARCHAR(50)
      ,i_Medicare_Requested                       VARCHAR(50)
      ,i_Medicare_Received                        VARCHAR(50)
      ,i_P_name_prefix                            VARCHAR(50)
      ,i_P_first_name                             VARCHAR(50)
      ,i_P_last_name                              VARCHAR(100)
      ,i_P_middle_name                            VARCHAR(50)
      ,i_Prof_desg_1                              VARCHAR(50)
      ,i_Prof_desg_2                              VARCHAR(50)
      ,i_Prof_desg_3                              VARCHAR(50)
      ,i_P_name_suffix                            VARCHAR(50)
      ,i_P_soc_sec_number                         VARCHAR(50)
      ,i_P_date_of_birth                          VARCHAR(50)
      ,i_P_Gender                                 VARCHAR(50)
      ,i_P_health_impairment                      VARCHAR(50)
      ,i_P_email                                  VARCHAR(100)
      ,i_P_lang1                                  VARCHAR(50)
      ,i_P_lang2                                  VARCHAR(50)
      ,i_P_ethnicity                              VARCHAR(50)
      ,i_US_citizen                               VARCHAR(50)
      ,i_VisaNo                                   VARCHAR(50)
      ,i_Agree_version                            VARCHAR(50)
      ,i_Agree_Signee                             VARCHAR(80)
      ,i_Agree_Sign_date                          VARCHAR(50)
      ,i_UPIN                                     VARCHAR(50)
      ,i_H_loc_id                                 VARCHAR(50)
      ,i_H_loc_name                               VARCHAR(100)
      ,i_H_address1                               VARCHAR(50)
      ,i_H_address2                               VARCHAR(50)
      ,i_H_zip                                    VARCHAR(50)
      ,i_H_city                                   VARCHAR(50)
      ,i_H_state                                  VARCHAR(50)
      ,i_H_County                                 VARCHAR(50)
      ,i_H_Country                                VARCHAR(50)
      ,i_O_loc_id                                 VARCHAR(50)
      ,i_O_loc_name                               VARCHAR(100)
      ,i_O_address1                               VARCHAR(50)
      ,i_O_address2                               VARCHAR(50)
      ,i_O_zip                                    VARCHAR(50)
      ,i_O_city                                   VARCHAR(50)
      ,i_O_state                                  VARCHAR(50)
      ,i_O_County                                 VARCHAR(50)
      ,i_O_Country                                VARCHAR(50)
      ,i_BU_business_unit_id                      VARCHAR(50)
      ,i_BU_npi_id                                VARCHAR(50)
      ,i_BU_npi_verif                             VARCHAR(50)
      ,i_BU_business_name                         VARCHAR(100)
      ,i_BU_business_type                         VARCHAR(50)
      ,i_T_tax_id_number                          VARCHAR(50)
      ,i_T_tax_id_type                            VARCHAR(50)
      ,i_BU_doing_business_as                     VARCHAR(50)
	  ,iPaymentDestination						  VARCHAR(50)	--SP45
      ,i_BU_location_id                           VARCHAR(50)
      ,i_BU_location_name                         VARCHAR(100)
      ,i_BU_address_1                             VARCHAR(55)
      ,i_BU_address_2                             VARCHAR(55)
      ,i_BU_zip_code                              VARCHAR(50)
      ,i_BU_city                                  VARCHAR(50)
      ,i_BU_state                                 VARCHAR(50)
      ,i_BU_county                                VARCHAR(50)
      ,i_BU_country                               VARCHAR(50)
      ,i_BU_email_address                         VARCHAR(100)
      ,i_BU_phone_number                          VARCHAR(50)
      ,i_BU_fax_number                            VARCHAR(50)
      ,i_BU_owner_name                            VARCHAR(50)
      ,i_BU_owner_license                         VARCHAR(50)
      ,i_BUMA_location_id                         VARCHAR(50)
      ,i_BUMA_location_name                       VARCHAR(100)
      ,i_BUMA_address_1                           VARCHAR(55)
      ,i_BUMA_address_2                           VARCHAR(55)
      ,i_BUMA_zip_code                            VARCHAR(50)
      ,i_BUMA_city                                VARCHAR(50)
      ,i_BUMA_state                               VARCHAR(50)
      ,i_BUMA_county                              VARCHAR(50)
      ,i_BUMA_country                             VARCHAR(50)
      ,i_BUMA_payment_center                      VARCHAR(50)
      ,i_T_tin_effective_date                     VARCHAR(50)
      ,i_T_tin_end_date                           VARCHAR(50)
      ,i_T_w9_onfile                              VARCHAR(50)
      ,i_T_W9_Completed                           VARCHAR(50)
      ,i_T_W9_Date_Requested                      VARCHAR(50)
      ,i_T_w9_rec_date                            VARCHAR(50)
      ,i_T_w9_business_type                       VARCHAR(50)
      ,i_T_name_1099                              VARCHAR(55)
      ,i_T_name_1099_2                            VARCHAR(50)
      ,i_B_waiver                                 VARCHAR(50)
      ,i_B_waiver_percentage                      VARCHAR(50)
      ,i_T_location_id                            VARCHAR(50)
      ,i_T_location_name                          VARCHAR(100)
      ,i_T_address_1                              VARCHAR(55)
      ,i_T_address_2                              VARCHAR(55)
      ,i_T_zip_code                               VARCHAR(50)
      ,i_T_city                                   VARCHAR(50)
      ,i_T_state                                  VARCHAR(50)
      ,i_T_county                                 VARCHAR(50)
      ,i_T_country                                VARCHAR(50)
      ,i_B_aba_number                             VARCHAR(50)
      ,i_B_bank_name                              VARCHAR(50)
      ,i_B_branch_phone_number                    VARCHAR(50)
      ,i_B_account_type                           VARCHAR(50)
      ,i_B_account_number                         VARCHAR(50)
      ,i_B_eft_status                             VARCHAR(50)
      ,i_B_eft_effective_date                     VARCHAR(50)
      ,i_B_eft_decline_code                       VARCHAR(50)
      ,i_B_eft_decline_start_date                 VARCHAR(50)
      ,i_B_eft_decline_end_date                   VARCHAR(50)
      ,i_C_cap_pcp_roster                         VARCHAR(50)
      ,i_SL_location_id                           VARCHAR(50)
      ,i_SL_location_name                         VARCHAR(100)	DEFAULT('')
      ,i_SL_address_1                             VARCHAR(55)
      ,i_SL_address_2                             VARCHAR(55)
      ,i_SL_zip_code                              VARCHAR(50)
      ,i_SL_city                                  VARCHAR(50)
      ,i_SL_state                                 VARCHAR(50)
      ,i_SL_county                                VARCHAR(50)
      ,i_SL_country                               VARCHAR(50)
      ,i_MA_location_id                           VARCHAR(50)
      ,i_MA_location_name                         VARCHAR(100)
      ,i_MA_address_1                             VARCHAR(55)
      ,i_MA_address_2                             VARCHAR(55)
      ,i_MA_zip_code                              VARCHAR(50)
      ,i_MA_city                                  VARCHAR(50)
      ,i_MA_state                                 VARCHAR(50)
      ,i_MA_county                                VARCHAR(50)
      ,i_MA_country                               VARCHAR(50)
      ,i_SL_contact_fname                         VARCHAR(50)
      ,i_SL_contact_lname                         VARCHAR(60)
      ,i_SL_contact_phone                         VARCHAR(50)
      ,i_SL_contact_fax                           VARCHAR(50)
      ,i_SL_contact_email                         VARCHAR(100)
      ,i_SL_emerg_phone                           VARCHAR(50)
      ,i_Alt_fax_number                           VARCHAR(50)
      ,i_SL_website_url                           VARCHAR(255)
      ,i_primary_location_indicator               VARCHAR(50)
      ,i_SL_status_code                           VARCHAR(50)
      ,i_SL_assign_override_flag                  VARCHAR(50)
      ,i_SL_cust_prov_id                          VARCHAR(50)
      ,i_SL_npf_site_id                           VARCHAR(50)
      ,i_SL_add_override_code                     VARCHAR(50)
      ,i_SL_filed_fee_id                          VARCHAR(50)
      ,i_SL_default_deliv_method                  VARCHAR(50)
      ,i_show_in_directory                        VARCHAR(50)
      ,i_handicap_accessible                      VARCHAR(50)
      ,i_handicap_acc_date                        VARCHAR(50)
      ,i_accept_new_patient                       VARCHAR(50)
      ,i_appt_wait_days                           VARCHAR(50)
      ,i_min_patient_age                          INT
      ,i_max_patient_age                          INT
      ,i_Accept_Dis                               VARCHAR(50)
      ,i_TranslationServices                      VARCHAR(50)
      ,i_TTYService                               VARCHAR(50)
      ,i_WheelAccess_ExamRoom                     VARCHAR(50)
      ,i_WheelAccess_RestRoom                     VARCHAR(50)
      ,i_WheelAccess_Ramp                         VARCHAR(50)
      ,i_PublicTrans_Access                       VARCHAR(50)
      ,i_accepts_hiv_aids_patients                VARCHAR(50)
      ,i_accepts_co_occuring_disorders_patients   VARCHAR(50)
      ,i_accepts_chronic_illness_patients         VARCHAR(50)
      ,i_accepts_physical_disabilities_patients   VARCHAR(50)
      ,i_accepts_serious_mental_illness_patients  VARCHAR(50)
      ,i_accepts_homeless_patients                VARCHAR(50)
      ,i_accepts_blind_visually_impaired_patients VARCHAR(50)
      ,i_accepts_deaf_hearing_impaired_patients   VARCHAR(50)
      ,i_adjustable_exam_table                    VARCHAR(50)
      ,i_handicap_parking                         VARCHAR(50)
      ,i_hour_24                                  VARCHAR(50)
      ,i_mon                                      VARCHAR(50)
      ,i_language_1                               VARCHAR(50)
      ,i_tue                                      VARCHAR(50)
      ,i_language_2                               VARCHAR(50)
      ,i_wed                                      VARCHAR(50)
      ,i_language_3                               VARCHAR(50)
      ,i_thu                                      VARCHAR(50)
      ,i_language_4                               VARCHAR(50)
      ,i_fri                                      VARCHAR(50)
      ,i_sat                                      VARCHAR(50)
      ,i_sun                                      VARCHAR(50)
      ,i_drg_version                              VARCHAR(50)
      ,i_SL_new_effective_date                    VARCHAR(50)
      ,i_SL_new_termination_date                  VARCHAR(50)
      ,i_npi_id                                   VARCHAR(50)
      ,i_SL_npi_verif                             VARCHAR(50)
      ,i_Loc_Category                             VARCHAR(50)
      ,i_SL_termination_reason                    VARCHAR(50)
      ,iServiceLocationName                       VARCHAR(100)	DEFAULT('')
      ,i_chain_code                               VARCHAR(50)
      ,i_chain_name                               VARCHAR(255)
      ,i_dispenser_class                          VARCHAR(50)
      ,i_dispenser_type                           VARCHAR(50)
      ,i_license_id                               VARCHAR(50)
      ,i_license_type                             VARCHAR(50)
      ,i_license_date                             VARCHAR(50)
      ,i_license_term_date                        VARCHAR(50)
      ,i_license_state                            VARCHAR(50)
      ,i_practice_in                              VARCHAR(50)
      ,i_verify_start_date                        VARCHAR(50)
      ,i_verify_date                              VARCHAR(50)
      ,i_verifier_name                            VARCHAR(50)
      ,i_verifier_phone                           VARCHAR(50)
      ,i_BAC                                      VARCHAR(50)
      ,i_Bus_Code                                 VARCHAR(50)
      ,i_Schedule                                 VARCHAR(50)
      ,i_location_id                              VARCHAR(55)
      ,i_location_desc                            VARCHAR(55)
      ,i_address_1                                VARCHAR(55)
      ,i_address_2                                VARCHAR(55)
      ,i_zip_code                                 VARCHAR(50)
      ,i_city                                     VARCHAR(50)
      ,i_state                                    VARCHAR(50)
      ,i_county                                   VARCHAR(50)
      ,i_country                                  VARCHAR(50)
      ,i_P_malprac_carrier                        VARCHAR(50)
      ,i_P_malprac_policy                         VARCHAR(50)
      ,i_P_malprac_eff_date                       VARCHAR(50)
      ,i_P_malprac_term_date                      VARCHAR(50)
      ,i_P_Verif_Date_Started                     VARCHAR(50)
      ,i_P_Verif_Date_Completed                   VARCHAR(50)
      ,i_P_malprac_limit_occur                    VARCHAR(50)
      ,i_P_malprac_limit_year                     VARCHAR(50)
      ,i_P_Aggregate_Amount                       VARCHAR(50)
      ,i_P_Coverage_Type                          VARCHAR(50)
      ,i_P_Carrier_Time                           VARCHAR(50)
      ,i_P_Carrier_span                           VARCHAR(50)
      ,i_P_Notes                                  VARCHAR(100)
      ,i_P_Carrier_Loc_ID                         VARCHAR(50)
      ,i_P_Carrier_Location_Desc                  VARCHAR(50)
      ,i_P_Carrier_Address1                       VARCHAR(50)
      ,i_P_Carrier_Address2                       VARCHAR(50)
      ,i_P_Carrier_Zip                            VARCHAR(50)
      ,i_P_Carrier_City                           VARCHAR(50)
      ,i_P_Carrier_State                          VARCHAR(50)
      ,i_P_Carrier_County                         VARCHAR(50)
      ,i_P_Carrier_Country                        VARCHAR(50)
      ,i_P_Verifer_Name                           VARCHAR(50)
      ,i_P_Verifer_Phone                          VARCHAR(50)
      ,i_S_specialty                              VARCHAR(50)
      ,i_S_specialty_desc                         VARCHAR(100)
      ,i_S_treat_as_specialty                     VARCHAR(50)
      ,i_S_treat_specialty_desc                   VARCHAR(100)
      ,i_primary_indicator                        VARCHAR(50)
      ,i_S_school                                 VARCHAR(50)
      ,i_S_grad_year                              VARCHAR(50)
      ,i_S_res_comp_date                          VARCHAR(50)
      ,i_S_board_elig_date                        VARCHAR(50)
      ,i_S_board_cert                             VARCHAR(50)
      ,i_board_name                               VARCHAR(50)
	  ,i_board_cert_url							  VARCHAR(300)
      ,i_S_print_as_spec                          VARCHAR(50)
      ,i_spi_id                                   VARCHAR(60)
      ,i_sp_npi_id                                VARCHAR(50)
      ,i_sp_npi_verif                             VARCHAR(50)
      ,i_scheduled_date                           VARCHAR(50)
      ,i_experation_date                          VARCHAR(50)
      ,i_Recertification_date                     VARCHAR(50)
      ,i_reporting_type                           VARCHAR(50)
      ,i_S_State_Rpt_type                         VARCHAR(50)
      ,i_HMS_Specialty_ID                         VARCHAR(50)
      ,o_status                                   INT
      ,o_message                                  VARCHAR(100)
      ,i_DisplayResults                           VARCHAR(50)
      ,record_id                                  INT
      ,static_gid                                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ServiceLocationsData
      (SearchID
      ,i_P_Provider_id
      ,i_BU_business_unit_id
      ,i_SL_location_id
      ,i_MA_location_id
      ,i_SL_contact_fname
      ,i_SL_contact_lname
      ,i_SL_contact_phone
      ,i_SL_contact_fax
      ,i_SL_contact_email
      ,i_SL_emerg_phone
      ,i_Alt_fax_number
      ,i_SL_website_url
      ,i_primary_location_indicator
      ,i_SL_status_code
      ,i_SL_assign_override_flag
      ,i_SL_cust_prov_id
      ,i_SL_npf_site_id
      ,i_SL_add_override_code
      ,i_SL_filed_fee_id
      ,i_SL_default_deliv_method
      ,i_show_in_directory
      ,i_handicap_accessible
      ,i_handicap_acc_date
      ,i_accept_new_patient
      ,i_appt_wait_days
      ,i_min_patient_age
      ,i_max_patient_age
      ,i_Accept_Dis
      ,i_TranslationServices
      ,i_TTYService
      ,i_WheelAccess_ExamRoom
      ,i_WheelAccess_RestRoom
      ,i_WheelAccess_Ramp
      ,i_PublicTrans_Access
      ,i_accepts_hiv_aids_patients
      ,i_accepts_co_occuring_disorders_patients
      ,i_accepts_chronic_illness_patients
      ,i_accepts_physical_disabilities_patients
      ,i_accepts_serious_mental_illness_patients
      ,i_accepts_homeless_patients
      ,i_accepts_blind_visually_impaired_patients
      ,i_accepts_deaf_hearing_impaired_patients
      ,i_adjustable_exam_table
      ,i_handicap_parking
      ,i_hour_24
      ,i_mon
      ,i_language_1
      ,i_tue
      ,i_language_2
      ,i_wed
      ,i_language_3
      ,i_thu
      ,i_language_4
      ,i_fri
      ,i_sat
      ,i_sun
      ,i_drg_version
      ,i_SL_new_effective_date
      ,i_SL_new_termination_date
      ,i_npi_id
      ,i_SL_npi_verif
      ,i_Loc_Category
      ,i_SL_termination_reason
      ,i_chain_code
      ,i_dispenser_class
      ,i_dispenser_type
      ,i_BAC
      ,i_Bus_Code
      ,i_Schedule
      ,i_S_specialty
      ,i_S_treat_as_specialty
      ,i_primary_indicator
      ,i_S_school
      ,i_S_grad_year
      ,i_S_res_comp_date
      ,i_S_board_elig_date
      ,i_S_board_cert
      ,i_board_name
	  ,i_board_cert_url
      ,i_S_print_as_spec
      ,i_spi_id
      ,i_sp_npi_id
      ,i_sp_npi_verif
      ,i_scheduled_date
      ,i_experation_date
      ,i_Recertification_date
      ,i_reporting_type
      ,i_S_State_Rpt_type
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_ProviderID], '')
      ,ISNULL([*BusUnit_BusinessUnitID], '')
      ,ISNULL([*ServLoc_PhysAddrLocationID], '')
      ,ISNULL([*ServLoc_MailAddrLocationID], '')
      ,ISNULL([ServLoc_CI_FirstName], '')
      ,ISNULL([ServLoc_CI_LastName], '')
      ,ISNULL([ServLoc_CI_Phone], '0000000000')
      ,ISNULL([ServLoc_CI_Fax], '0000000000')
      ,ISNULL([ServLoc_CI_Email], '')
      ,ISNULL([ServLoc_CI_EmergencyPhone], '0000000000')
      ,ISNULL([ServLoc_CI_AltFax], '0000000000')
      ,ISNULL([ServLoc_WebSiteURL], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_PrimaryProvLocation]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ServLoc_SLI_StatusCode]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_Assignable]), 'U')
      ,ISNULL([ServLoc_SLI_PriorID], '')
      ,ISNULL([ServLoc_SLI_SiteID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_AddrOverrideCode]), '')
      ,ISNULL([ServLoc_SLI_FiledFeeID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_DefltDelivery]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_ShowInDir]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_HandicAccess]), 'U')
      ,ISNULL([ServLoc_SLI_HandicAccDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_AcceptNewPatients]), 'Y')
      ,ISNULL([ServLoc_SLI_ApptWaitDays], '0')
      ,ISNULL([ServLoc_SLI_PatientMinAge], '0')
      ,ISNULL([ServLoc_SLI_PatientMaxAge], '999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_AcceptDevDisabilities]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_TranslationServ]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_TTYServices]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_WheelchairAccessExam]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_WheelchairAccessRestR]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_WheelchairRamp]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_SLI_AccessPublicTrans]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsHIVPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsCoOccurring]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsChronicIllness]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsPhysDisPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsSeriousMentalPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsHomelessPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsBlindPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AcceptsDeafPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_AdjustableExam]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_HandicapParking]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_GH_24hrOperation]), 'N')
      ,ISNULL([ServLoc_GH_Monday], '')
      ,ISNULL([ServLoc_L_Language1], '')
      ,ISNULL([ServLoc_GH_Tuesday], '')
      ,ISNULL([ServLoc_L_Language2], '')
      ,ISNULL([ServLoc_GH_Wednesday], '')
      ,ISNULL([ServLoc_L_Language3], '')
      ,ISNULL([ServLoc_GH_Thursday], '')
      ,ISNULL([ServLoc_L_Language4], '')
      ,ISNULL([ServLoc_GH_Friday], '')
      ,ISNULL([ServLoc_GH_Saturday], '')
      ,ISNULL([ServLoc_GH_Sunday], '')
      ,ISNULL([ServLoc_DRGVersion], '')
      ,ISNULL([ServLoc_EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([ServLoc_TermDate], '12/31/9999')
      ,ISNULL([ServLoc_NPIID], '')
      ,ISNULL([ServLoc_NPIVerification], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_LocationCategory]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_TermReason]), '')
      ,ISNULL([ServLoc_PI_ChainID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_DispenserClassCode]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServLoc_DispenserTypeCode]), '')
      ,ISNULL([Credentialing_BAC], '')
      ,ISNULL([Credentialing_SubBAC], '')
      ,ISNULL([Credentialing_Schedule], '')
      ,ISNULL([Specialty_SpecialtyID], '')
      ,ISNULL([Specialty_SpecializingIn], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialty_PrimaryIndicator]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialty_School]), '')
      ,ISNULL([Specialty_GraduationYr], '1900')
      ,ISNULL([Specialty_ResidencyCompDate], '01/01/1900')
      ,ISNULL([Specialty_BoardEligDate], '01/01/1900')
      ,ISNULL([Specialty_BoardCertDate], '12/31/9999')
      ,ISNULL([Specialty_NameOfCertBoard], '')
      ,ISNULL([Specialty_BoardCertURL], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialty_UseSpecInDir]), '')
      ,ISNULL([Specialty_SPIID], '')
      ,ISNULL([Specialty_NPIID], '')
      ,ISNULL([Specialty_NPIVerificationDate], '01/01/1900')
      ,ISNULL([Specialty_SchedForSpecBoardDate], '01/01/1900')
      ,ISNULL([Specialty_ExpirationDate], '01/01/1900')
      ,ISNULL([Specialty_ReCertDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialty_ReportingType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialty_StateReporting]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user and languages
--*************************************************************************************************
UPDATE #ServiceLocationsData
   SET iUserID  = @user

-- Lookup and use the code for each language (E.g. English --> EN)
;WITH Languages_CTE
   AS(SELECT SL.i_language_1
            ,X1.Short_Desc1
			,SL.i_language_2
			,X2.Short_Desc2
			,SL.i_language_3
			,X3.Short_Desc3
			,SL.i_language_4
			,X4.Short_Desc4
			,SL.record_id
         FROM #ServiceLocationsData SL
	    CROSS APPLY
	         (SELECT Short_Desc				AS Short_Desc1
			    FROM System_Action_Values	SAV
			   WHERE SAV.Reference_Type		= 'LANG'
			     AND SAV.record_status		= 'A'
				 AND SAV.Description			= SL.i_language_1) X1
	    CROSS APPLY
	         (SELECT Short_Desc				AS Short_Desc2
			    FROM System_Action_Values	SAV
			   WHERE SAV.Reference_Type		= 'LANG'
			     AND SAV.record_status		= 'A'
				 AND SAV.Description			= SL.i_language_2) X2
	    CROSS APPLY
	         (SELECT Short_Desc				AS Short_Desc3
			    FROM System_Action_Values	SAV
			   WHERE SAV.Reference_Type		= 'LANG'
			     AND SAV.record_status		= 'A'
				 AND SAV.Description			= SL.i_language_3) X3
	    CROSS APPLY
	         (SELECT Short_Desc				AS Short_Desc4
			    FROM System_Action_Values	SAV
			   WHERE SAV.Reference_Type		= 'LANG'
			     AND SAV.record_status		= 'A'
				 AND SAV.Description			= SL.i_language_4) X4)
UPDATE SL
   SET SL.i_language_1		= L.Short_Desc1
      ,SL.i_language_2		= L.Short_Desc2
	  ,SL.i_language_3		= L.Short_Desc3
	  ,SL.i_language_4		= L.Short_Desc4
  FROM #ServiceLocationsData	SL
  JOIN Languages_CTE		L
    ON SL.record_id			= L.record_id

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_field
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_eDATE
       ,i_tDate
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_P_Provider_id
       ,i_P_Practice_As
       ,i_P_HIPPA_id
       ,i_NPI_Verif
       ,i_Medicaid_Participatient
       ,i_P_Medicaid_id
       ,i_Medicaid_Requested
       ,i_Medicaid_Received
       ,i_Medicare_Participatient
       ,i_P_Medicare_id
       ,i_Medicare_Requested
       ,i_Medicare_Received
       ,i_P_name_prefix
       ,i_P_first_name
       ,i_P_last_name
       ,i_P_middle_name
       ,i_Prof_desg_1
       ,i_Prof_desg_2
       ,i_Prof_desg_3
       ,i_P_name_suffix
       ,i_P_soc_sec_number
       ,i_P_date_of_birth
       ,i_P_Gender
       ,i_P_health_impairment
       ,i_P_email
       ,i_P_lang1
       ,i_P_lang2
       ,i_P_ethnicity
       ,i_US_citizen
       ,i_VisaNo
       ,i_Agree_version
       ,i_Agree_Signee
       ,i_Agree_Sign_date
       ,i_UPIN
       ,i_H_loc_id
       ,i_H_loc_name
       ,i_H_address1
       ,i_H_address2
       ,i_H_zip
       ,i_H_city
       ,i_H_state
       ,i_H_County
       ,i_H_Country
       ,i_O_loc_id
       ,i_O_loc_name
       ,i_O_address1
       ,i_O_address2
       ,i_O_zip
       ,i_O_city
       ,i_O_state
       ,i_O_County
       ,i_O_Country
       ,i_BU_business_unit_id
       ,i_BU_npi_id
       ,i_BU_npi_verif
       ,i_BU_business_name
       ,i_BU_business_type
       ,i_T_tax_id_number
       ,i_T_tax_id_type
       ,i_BU_doing_business_as
	   ,iPaymentDestination		--SP45
       ,i_BU_location_id
       ,i_BU_location_name
       ,i_BU_address_1
       ,i_BU_address_2
       ,i_BU_zip_code
       ,i_BU_city
       ,i_BU_state
       ,i_BU_county
       ,i_BU_country
       ,i_BU_email_address
       ,i_BU_phone_number
       ,i_BU_fax_number
       ,i_BU_owner_name
       ,i_BU_owner_license
       ,i_BUMA_location_id
       ,i_BUMA_location_name
       ,i_BUMA_address_1
       ,i_BUMA_address_2
       ,i_BUMA_zip_code
       ,i_BUMA_city
       ,i_BUMA_state
       ,i_BUMA_county
       ,i_BUMA_country
       ,i_BUMA_payment_center
       ,i_T_tin_effective_date
       ,i_T_tin_end_date
       ,i_T_w9_onfile
       ,i_T_W9_Completed
       ,i_T_W9_Date_Requested
       ,i_T_w9_rec_date
       ,i_T_w9_business_type
       ,i_T_name_1099
       ,i_T_name_1099_2
       ,i_B_waiver
       ,i_B_waiver_percentage
       ,i_T_location_id
       ,i_T_location_name
       ,i_T_address_1
       ,i_T_address_2
       ,i_T_zip_code
       ,i_T_city
       ,i_T_state
       ,i_T_county
       ,i_T_country
       ,i_B_aba_number
       ,i_B_bank_name
       ,i_B_branch_phone_number
       ,i_B_account_type
       ,i_B_account_number
       ,i_B_eft_status
       ,i_B_eft_effective_date
       ,i_B_eft_decline_code
       ,i_B_eft_decline_start_date
       ,i_B_eft_decline_end_date
       ,i_C_cap_pcp_roster
       ,i_SL_location_id
       ,i_SL_location_name
       ,i_SL_address_1
       ,i_SL_address_2
       ,i_SL_zip_code
       ,i_SL_city
       ,i_SL_state
       ,i_SL_county
       ,i_SL_country
       ,i_MA_location_id
       ,i_MA_location_name
       ,i_MA_address_1
       ,i_MA_address_2
       ,i_MA_zip_code
       ,i_MA_city
       ,i_MA_state
       ,i_MA_county
       ,i_MA_country
       ,i_SL_contact_fname
       ,i_SL_contact_lname
       ,i_SL_contact_phone
       ,i_SL_contact_fax
       ,i_SL_contact_email
       ,i_SL_emerg_phone
       ,i_Alt_fax_number
       ,i_SL_website_url
       ,i_primary_location_indicator
       ,i_SL_status_code
       ,i_SL_assign_override_flag
       ,i_SL_cust_prov_id
       ,i_SL_npf_site_id
       ,i_SL_add_override_code
       ,i_SL_filed_fee_id
       ,i_SL_default_deliv_method
       ,i_show_in_directory
       ,i_handicap_accessible
       ,i_handicap_acc_date
       ,i_accept_new_patient
       ,i_appt_wait_days
       ,i_min_patient_age
       ,i_max_patient_age
       ,i_Accept_Dis
       ,i_TranslationServices
       ,i_TTYService
       ,i_WheelAccess_ExamRoom
       ,i_WheelAccess_RestRoom
       ,i_WheelAccess_Ramp
       ,i_PublicTrans_Access
       ,i_accepts_hiv_aids_patients
       ,i_accepts_co_occuring_disorders_patients
       ,i_accepts_chronic_illness_patients
       ,i_accepts_physical_disabilities_patients
       ,i_accepts_serious_mental_illness_patients
       ,i_accepts_homeless_patients
       ,i_accepts_blind_visually_impaired_patients
       ,i_accepts_deaf_hearing_impaired_patients
       ,i_adjustable_exam_table
       ,i_handicap_parking
       ,i_hour_24
       ,i_mon
       ,i_language_1
       ,i_tue
       ,i_language_2
       ,i_wed
       ,i_language_3
       ,i_thu
       ,i_language_4
       ,i_fri
       ,i_sat
       ,i_sun
       ,i_drg_version
       ,i_SL_new_effective_date
       ,i_SL_new_termination_date
       ,i_npi_id
       ,i_SL_npi_verif
       ,i_Loc_Category
       ,i_SL_termination_reason
       ,iServiceLocationName
       ,i_chain_code
       ,i_chain_name
       ,i_dispenser_class
       ,i_dispenser_type
       ,i_license_id
       ,i_license_type
       ,i_license_date
       ,i_license_term_date
       ,i_license_state
       ,i_practice_in
       ,i_verify_start_date
       ,i_verify_date
       ,i_verifier_name
       ,i_verifier_phone
       ,i_BAC
       ,i_Bus_Code
       ,i_Schedule
       ,i_location_id
       ,i_location_desc
       ,i_address_1
       ,i_address_2
       ,i_zip_code
       ,i_city
       ,i_state
       ,i_county
       ,i_country
       ,i_P_malprac_carrier
       ,i_P_malprac_policy
       ,i_P_malprac_eff_date
       ,i_P_malprac_term_date
       ,i_P_Verif_Date_Started
       ,i_P_Verif_Date_Completed
       ,i_P_malprac_limit_occur
       ,i_P_malprac_limit_year
       ,i_P_Aggregate_Amount
       ,i_P_Coverage_Type
       ,i_P_Carrier_Time
       ,i_P_Carrier_span
       ,i_P_Notes
       ,i_P_Carrier_Loc_ID
       ,i_P_Carrier_Location_Desc
       ,i_P_Carrier_Address1
       ,i_P_Carrier_Address2
       ,i_P_Carrier_Zip
       ,i_P_Carrier_City
       ,i_P_Carrier_State
       ,i_P_Carrier_County
       ,i_P_Carrier_Country
       ,i_P_Verifer_Name
       ,i_P_Verifer_Phone
       ,i_S_specialty
       ,i_S_specialty_desc
       ,i_S_treat_as_specialty
       ,i_S_treat_specialty_desc
       ,i_primary_indicator
       ,i_S_school
       ,i_S_grad_year
       ,i_S_res_comp_date
       ,i_S_board_elig_date
       ,i_S_board_cert
       ,i_board_name
	   ,i_board_cert_url
       ,i_S_print_as_spec
       ,i_spi_id
       ,i_sp_npi_id
       ,i_sp_npi_verif
       ,i_scheduled_date
       ,i_experation_date
       ,i_Recertification_date
       ,i_reporting_type
       ,i_S_State_Rpt_type
       ,i_HMS_Specialty_ID
       ,o_status
       ,o_message
       ,i_DisplayResults
       ,record_id
       ,static_gid
   FROM #ServiceLocationsData

   OPEN ServiceLocations_Cursor
  FETCH NEXT FROM ServiceLocations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_field
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_eDATE
       ,@i_tDate
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_P_Provider_id
       ,@i_P_Practice_As
       ,@i_P_HIPPA_id
       ,@i_NPI_Verif
       ,@i_Medicaid_Participatient
       ,@i_P_Medicaid_id
       ,@i_Medicaid_Requested
       ,@i_Medicaid_Received
       ,@i_Medicare_Participatient
       ,@i_P_Medicare_id
       ,@i_Medicare_Requested
       ,@i_Medicare_Received
       ,@i_P_name_prefix
       ,@i_P_first_name
       ,@i_P_last_name
       ,@i_P_middle_name
       ,@i_Prof_desg_1
       ,@i_Prof_desg_2
       ,@i_Prof_desg_3
       ,@i_P_name_suffix
       ,@i_P_soc_sec_number
       ,@i_P_date_of_birth
       ,@i_P_Gender
       ,@i_P_health_impairment
       ,@i_P_email
       ,@i_P_lang1
       ,@i_P_lang2
       ,@i_P_ethnicity
       ,@i_US_citizen
       ,@i_VisaNo
       ,@i_Agree_version
       ,@i_Agree_Signee
       ,@i_Agree_Sign_date
       ,@i_UPIN
       ,@i_H_loc_id
       ,@i_H_loc_name
       ,@i_H_address1
       ,@i_H_address2
       ,@i_H_zip
       ,@i_H_city
       ,@i_H_state
       ,@i_H_County
       ,@i_H_Country
       ,@i_O_loc_id
       ,@i_O_loc_name
       ,@i_O_address1
       ,@i_O_address2
       ,@i_O_zip
       ,@i_O_city
       ,@i_O_state
       ,@i_O_County
       ,@i_O_Country
       ,@i_BU_business_unit_id
       ,@i_BU_npi_id
       ,@i_BU_npi_verif
       ,@i_BU_business_name
       ,@i_BU_business_type
       ,@i_T_tax_id_number
       ,@i_T_tax_id_type
       ,@i_BU_doing_business_as
	   ,@iPaymentDestination		--SP45
       ,@i_BU_location_id
       ,@i_BU_location_name
       ,@i_BU_address_1
       ,@i_BU_address_2
       ,@i_BU_zip_code
       ,@i_BU_city
       ,@i_BU_state
       ,@i_BU_county
       ,@i_BU_country
       ,@i_BU_email_address
       ,@i_BU_phone_number
       ,@i_BU_fax_number
       ,@i_BU_owner_name
       ,@i_BU_owner_license
       ,@i_BUMA_location_id
       ,@i_BUMA_location_name
       ,@i_BUMA_address_1
       ,@i_BUMA_address_2
       ,@i_BUMA_zip_code
       ,@i_BUMA_city
       ,@i_BUMA_state
       ,@i_BUMA_county
       ,@i_BUMA_country
       ,@i_BUMA_payment_center
       ,@i_T_tin_effective_date
       ,@i_T_tin_end_date
       ,@i_T_w9_onfile
       ,@i_T_W9_Completed
       ,@i_T_W9_Date_Requested
       ,@i_T_w9_rec_date
       ,@i_T_w9_business_type
       ,@i_T_name_1099
       ,@i_T_name_1099_2
       ,@i_B_waiver
       ,@i_B_waiver_percentage
       ,@i_T_location_id
       ,@i_T_location_name
       ,@i_T_address_1
       ,@i_T_address_2
       ,@i_T_zip_code
       ,@i_T_city
       ,@i_T_state
       ,@i_T_county
       ,@i_T_country
       ,@i_B_aba_number
       ,@i_B_bank_name
       ,@i_B_branch_phone_number
       ,@i_B_account_type
       ,@i_B_account_number
       ,@i_B_eft_status
       ,@i_B_eft_effective_date
       ,@i_B_eft_decline_code
       ,@i_B_eft_decline_start_date
       ,@i_B_eft_decline_end_date
       ,@i_C_cap_pcp_roster
       ,@i_SL_location_id
       ,@i_SL_location_name
       ,@i_SL_address_1
       ,@i_SL_address_2
       ,@i_SL_zip_code
       ,@i_SL_city
       ,@i_SL_state
       ,@i_SL_county
       ,@i_SL_country
       ,@i_MA_location_id
       ,@i_MA_location_name
       ,@i_MA_address_1
       ,@i_MA_address_2
       ,@i_MA_zip_code
       ,@i_MA_city
       ,@i_MA_state
       ,@i_MA_county
       ,@i_MA_country
       ,@i_SL_contact_fname
       ,@i_SL_contact_lname
       ,@i_SL_contact_phone
       ,@i_SL_contact_fax
       ,@i_SL_contact_email
       ,@i_SL_emerg_phone
       ,@i_Alt_fax_number
       ,@i_SL_website_url
       ,@i_primary_location_indicator
       ,@i_SL_status_code
       ,@i_SL_assign_override_flag
       ,@i_SL_cust_prov_id
       ,@i_SL_npf_site_id
       ,@i_SL_add_override_code
       ,@i_SL_filed_fee_id
       ,@i_SL_default_deliv_method
       ,@i_show_in_directory
       ,@i_handicap_accessible
       ,@i_handicap_acc_date
       ,@i_accept_new_patient
       ,@i_appt_wait_days
       ,@i_min_patient_age
       ,@i_max_patient_age
       ,@i_Accept_Dis
       ,@i_TranslationServices
       ,@i_TTYService
       ,@i_WheelAccess_ExamRoom
       ,@i_WheelAccess_RestRoom
       ,@i_WheelAccess_Ramp
       ,@i_PublicTrans_Access
       ,@i_accepts_hiv_aids_patients
       ,@i_accepts_co_occuring_disorders_patients
       ,@i_accepts_chronic_illness_patients
       ,@i_accepts_physical_disabilities_patients
       ,@i_accepts_serious_mental_illness_patients
       ,@i_accepts_homeless_patients
       ,@i_accepts_blind_visually_impaired_patients
       ,@i_accepts_deaf_hearing_impaired_patients
       ,@i_adjustable_exam_table
       ,@i_handicap_parking
       ,@i_hour_24
       ,@i_mon
       ,@i_language_1
       ,@i_tue
       ,@i_language_2
       ,@i_wed
       ,@i_language_3
       ,@i_thu
       ,@i_language_4
       ,@i_fri
       ,@i_sat
       ,@i_sun
       ,@i_drg_version
       ,@i_SL_new_effective_date
       ,@i_SL_new_termination_date
       ,@i_npi_id
       ,@i_SL_npi_verif
       ,@i_Loc_Category
       ,@i_SL_termination_reason
       ,@iServiceLocationName
       ,@i_chain_code
       ,@i_chain_name
       ,@i_dispenser_class
       ,@i_dispenser_type
       ,@i_license_id
       ,@i_license_type
       ,@i_license_date
       ,@i_license_term_date
       ,@i_license_state
       ,@i_practice_in
       ,@i_verify_start_date
       ,@i_verify_date
       ,@i_verifier_name
       ,@i_verifier_phone
       ,@i_BAC
       ,@i_Bus_Code
       ,@i_Schedule
       ,@i_location_id
       ,@i_location_desc
       ,@i_address_1
       ,@i_address_2
       ,@i_zip_code
       ,@i_city
       ,@i_state
       ,@i_county
       ,@i_country
       ,@i_P_malprac_carrier
       ,@i_P_malprac_policy
       ,@i_P_malprac_eff_date
       ,@i_P_malprac_term_date
       ,@i_P_Verif_Date_Started
       ,@i_P_Verif_Date_Completed
       ,@i_P_malprac_limit_occur
       ,@i_P_malprac_limit_year
       ,@i_P_Aggregate_Amount
       ,@i_P_Coverage_Type
       ,@i_P_Carrier_Time
       ,@i_P_Carrier_span
       ,@i_P_Notes
       ,@i_P_Carrier_Loc_ID
       ,@i_P_Carrier_Location_Desc
       ,@i_P_Carrier_Address1
       ,@i_P_Carrier_Address2
       ,@i_P_Carrier_Zip
       ,@i_P_Carrier_City
       ,@i_P_Carrier_State
       ,@i_P_Carrier_County
       ,@i_P_Carrier_Country
       ,@i_P_Verifer_Name
       ,@i_P_Verifer_Phone
       ,@i_S_specialty
       ,@i_S_specialty_desc
       ,@i_S_treat_as_specialty
       ,@i_S_treat_specialty_desc
       ,@i_primary_indicator
       ,@i_S_school
       ,@i_S_grad_year
       ,@i_S_res_comp_date
       ,@i_S_board_elig_date
       ,@i_S_board_cert
       ,@i_board_name
	   ,@i_board_cert_url
       ,@i_S_print_as_spec
       ,@i_spi_id
       ,@i_sp_npi_id
       ,@i_sp_npi_verif
       ,@i_scheduled_date
       ,@i_experation_date
       ,@i_Recertification_date
       ,@i_reporting_type
       ,@i_S_State_Rpt_type
       ,@i_HMS_Specialty_ID
       ,@o_status
       ,@o_message
       ,@i_DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Check to see if the user is expecting the screen to default the location ID to the business unit's location ID
			IF @i_SL_location_id = '' OR @i_MA_location_id = ''
				BEGIN
					
					--Default the location ID to the Business Unit location ID
					SELECT @i_SL_location_id		= CASE WHEN @i_SL_location_id = '' THEN L.location_id ELSE @i_SL_location_id END
					      ,@i_MA_location_id		= CASE WHEN @i_MA_location_id = '' THEN L.location_id ELSE @i_MA_location_id END
					  FROM Business_Units			BU
					  JOIN Locations				L
					    ON BU.payment_location_gid	= L.location_gid
					 WHERE BU.record_status			= 'A'
					   AND L.record_status			= 'A'
					   AND BU.business_unit_id		= @i_BU_business_unit_id
				END

			EXEC dbo.prPMBulkAdd
             @i_entity_name
            ,@i_key_1_field
            ,@i_key_2_field
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_eDATE
            ,@i_tDate
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_P_Provider_id
            ,@i_P_Practice_As
            ,@i_P_HIPPA_id
            ,@i_NPI_Verif
            ,@i_Medicaid_Participatient
            ,@i_P_Medicaid_id
            ,@i_Medicaid_Requested
            ,@i_Medicaid_Received
            ,@i_Medicare_Participatient
            ,@i_P_Medicare_id
            ,@i_Medicare_Requested
            ,@i_Medicare_Received
            ,@i_P_name_prefix
            ,@i_P_first_name
            ,@i_P_last_name
            ,@i_P_middle_name
            ,@i_Prof_desg_1
            ,@i_Prof_desg_2
            ,@i_Prof_desg_3
            ,@i_P_name_suffix
            ,@i_P_soc_sec_number
            ,@i_P_date_of_birth
            ,@i_P_Gender
            ,@i_P_health_impairment
            ,@i_P_email
            ,@i_P_lang1
            ,@i_P_lang2
            ,@i_P_ethnicity
            ,@i_US_citizen
            ,@i_VisaNo
            ,@i_Agree_version
            ,@i_Agree_Signee
            ,@i_Agree_Sign_date
            ,@i_UPIN
            ,@i_H_loc_id
            ,@i_H_loc_name
            ,@i_H_address1
            ,@i_H_address2
            ,@i_H_zip
            ,@i_H_city
            ,@i_H_state
            ,@i_H_County
            ,@i_H_Country
            ,@i_O_loc_id
            ,@i_O_loc_name
            ,@i_O_address1
            ,@i_O_address2
            ,@i_O_zip
            ,@i_O_city
            ,@i_O_state
            ,@i_O_County
            ,@i_O_Country
            ,@i_BU_business_unit_id
            ,@i_BU_npi_id
            ,@i_BU_npi_verif
            ,@i_BU_business_name
            ,@i_BU_business_type
            ,@i_T_tax_id_number
            ,@i_T_tax_id_type
            ,@i_BU_doing_business_as
			,@iPaymentDestination		--SP45
            ,@i_BU_location_id
            ,@i_BU_location_name
            ,@i_BU_address_1
            ,@i_BU_address_2
            ,@i_BU_zip_code
            ,@i_BU_city
            ,@i_BU_state
            ,@i_BU_county
            ,@i_BU_country
            ,@i_BU_email_address
            ,@i_BU_phone_number
            ,@i_BU_fax_number
            ,@i_BU_owner_name
            ,@i_BU_owner_license
            ,@i_BUMA_location_id
            ,@i_BUMA_location_name
            ,@i_BUMA_address_1
            ,@i_BUMA_address_2
            ,@i_BUMA_zip_code
            ,@i_BUMA_city
            ,@i_BUMA_state
            ,@i_BUMA_county
            ,@i_BUMA_country
            ,@i_BUMA_payment_center
            ,@i_T_tin_effective_date
            ,@i_T_tin_end_date
            ,@i_T_w9_onfile
            ,@i_T_W9_Completed
            ,@i_T_W9_Date_Requested
            ,@i_T_w9_rec_date
            ,@i_T_w9_business_type
            ,@i_T_name_1099
            ,@i_T_name_1099_2
            ,@i_B_waiver
            ,@i_B_waiver_percentage
            ,@i_T_location_id
            ,@i_T_location_name
            ,@i_T_address_1
            ,@i_T_address_2
            ,@i_T_zip_code
            ,@i_T_city
            ,@i_T_state
            ,@i_T_county
            ,@i_T_country
            ,@i_B_aba_number
            ,@i_B_bank_name
            ,@i_B_branch_phone_number
            ,@i_B_account_type
            ,@i_B_account_number
            ,@i_B_eft_status
            ,@i_B_eft_effective_date
            ,@i_B_eft_decline_code
            ,@i_B_eft_decline_start_date
            ,@i_B_eft_decline_end_date
            ,@i_C_cap_pcp_roster
            ,@i_SL_location_id
            ,@i_SL_location_name
            ,@i_SL_address_1
            ,@i_SL_address_2
            ,@i_SL_zip_code
            ,@i_SL_city
            ,@i_SL_state
            ,@i_SL_county
            ,@i_SL_country
            ,@i_MA_location_id
            ,@i_MA_location_name
            ,@i_MA_address_1
            ,@i_MA_address_2
            ,@i_MA_zip_code
            ,@i_MA_city
            ,@i_MA_state
            ,@i_MA_county
            ,@i_MA_country
            ,@i_SL_contact_fname
            ,@i_SL_contact_lname
            ,@i_SL_contact_phone
            ,@i_SL_contact_fax
            ,@i_SL_contact_email
            ,@i_SL_emerg_phone
            ,@i_Alt_fax_number
            ,@i_SL_website_url
            ,@i_primary_location_indicator
            ,@i_SL_status_code
            ,@i_SL_assign_override_flag
            ,@i_SL_cust_prov_id
            ,@i_SL_npf_site_id
            ,@i_SL_add_override_code
            ,@i_SL_filed_fee_id
            ,@i_SL_default_deliv_method
            ,@i_show_in_directory
            ,@i_handicap_accessible
            ,@i_handicap_acc_date
            ,@i_accept_new_patient
            ,@i_appt_wait_days
            ,@i_min_patient_age
            ,@i_max_patient_age
            ,@i_Accept_Dis
            ,@i_TranslationServices
            ,@i_TTYService
            ,@i_WheelAccess_ExamRoom
            ,@i_WheelAccess_RestRoom
            ,@i_WheelAccess_Ramp
            ,@i_PublicTrans_Access
            ,@i_accepts_hiv_aids_patients
            ,@i_accepts_co_occuring_disorders_patients
            ,@i_accepts_chronic_illness_patients
            ,@i_accepts_physical_disabilities_patients
            ,@i_accepts_serious_mental_illness_patients
            ,@i_accepts_homeless_patients
            ,@i_accepts_blind_visually_impaired_patients
            ,@i_accepts_deaf_hearing_impaired_patients
            ,@i_adjustable_exam_table
            ,@i_handicap_parking
            ,@i_hour_24
            ,@i_mon
            ,@i_language_1
            ,@i_tue
            ,@i_language_2
            ,@i_wed
            ,@i_language_3
            ,@i_thu
            ,@i_language_4
            ,@i_fri
            ,@i_sat
            ,@i_sun
            ,@i_drg_version
            ,@i_SL_new_effective_date
            ,@i_SL_new_termination_date
            ,@i_npi_id
            ,@i_SL_npi_verif
            ,@i_Loc_Category
            ,@i_SL_termination_reason
            ,@iServiceLocationName
            ,@i_chain_code
            ,@i_chain_name
            ,@i_dispenser_class
            ,@i_dispenser_type
            ,@i_license_id
            ,@i_license_type
            ,@i_license_date
            ,@i_license_term_date
            ,@i_license_state
            ,@i_practice_in
            ,@i_verify_start_date
            ,@i_verify_date
            ,@i_verifier_name
            ,@i_verifier_phone
            ,@i_BAC
            ,@i_Bus_Code
            ,@i_Schedule
            ,@i_location_id
            ,@i_location_desc
            ,@i_address_1
            ,@i_address_2
            ,@i_zip_code
            ,@i_city
            ,@i_state
            ,@i_county
            ,@i_country
            ,@i_P_malprac_carrier
            ,@i_P_malprac_policy
            ,@i_P_malprac_eff_date
            ,@i_P_malprac_term_date
            ,@i_P_Verif_Date_Started
            ,@i_P_Verif_Date_Completed
            ,@i_P_malprac_limit_occur
            ,@i_P_malprac_limit_year
            ,@i_P_Aggregate_Amount
            ,@i_P_Coverage_Type
            ,@i_P_Carrier_Time
            ,@i_P_Carrier_span
            ,@i_P_Notes
            ,@i_P_Carrier_Loc_ID
            ,@i_P_Carrier_Location_Desc
            ,@i_P_Carrier_Address1
            ,@i_P_Carrier_Address2
            ,@i_P_Carrier_Zip
            ,@i_P_Carrier_City
            ,@i_P_Carrier_State
            ,@i_P_Carrier_County
            ,@i_P_Carrier_Country
            ,@i_P_Verifer_Name
            ,@i_P_Verifer_Phone
            ,@i_S_specialty
            ,@i_S_specialty_desc
            ,@i_S_treat_as_specialty
            ,@i_S_treat_specialty_desc
            ,@i_primary_indicator
            ,@i_S_school
            ,@i_S_grad_year
            ,@i_S_res_comp_date
            ,@i_S_board_elig_date
            ,@i_S_board_cert
            ,@i_board_name
			,@i_board_cert_url
            ,@i_S_print_as_spec
            ,@i_spi_id
            ,@i_sp_npi_id
            ,@i_sp_npi_verif
            ,@i_scheduled_date
            ,@i_experation_date
            ,@i_Recertification_date
            ,@i_reporting_type
            ,@i_S_State_Rpt_type
            ,@i_HMS_Specialty_ID
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_P_Provider_id, @i_SL_location_id, @i_BU_business_unit_id, @status, @err_num, @err_msg

        FETCH NEXT FROM ServiceLocations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_field
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_eDATE
             ,@i_tDate
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_P_Provider_id
             ,@i_P_Practice_As
             ,@i_P_HIPPA_id
             ,@i_NPI_Verif
             ,@i_Medicaid_Participatient
             ,@i_P_Medicaid_id
             ,@i_Medicaid_Requested
             ,@i_Medicaid_Received
             ,@i_Medicare_Participatient
             ,@i_P_Medicare_id
             ,@i_Medicare_Requested
             ,@i_Medicare_Received
             ,@i_P_name_prefix
             ,@i_P_first_name
             ,@i_P_last_name
             ,@i_P_middle_name
             ,@i_Prof_desg_1
             ,@i_Prof_desg_2
             ,@i_Prof_desg_3
             ,@i_P_name_suffix
             ,@i_P_soc_sec_number
             ,@i_P_date_of_birth
             ,@i_P_Gender
             ,@i_P_health_impairment
             ,@i_P_email
             ,@i_P_lang1
             ,@i_P_lang2
             ,@i_P_ethnicity
             ,@i_US_citizen
             ,@i_VisaNo
             ,@i_Agree_version
             ,@i_Agree_Signee
             ,@i_Agree_Sign_date
             ,@i_UPIN
             ,@i_H_loc_id
             ,@i_H_loc_name
             ,@i_H_address1
             ,@i_H_address2
             ,@i_H_zip
             ,@i_H_city
             ,@i_H_state
             ,@i_H_County
             ,@i_H_Country
             ,@i_O_loc_id
             ,@i_O_loc_name
             ,@i_O_address1
             ,@i_O_address2
             ,@i_O_zip
             ,@i_O_city
             ,@i_O_state
             ,@i_O_County
             ,@i_O_Country
             ,@i_BU_business_unit_id
             ,@i_BU_npi_id
             ,@i_BU_npi_verif
             ,@i_BU_business_name
             ,@i_BU_business_type
             ,@i_T_tax_id_number
             ,@i_T_tax_id_type
             ,@i_BU_doing_business_as
			 ,@iPaymentDestination		--SP45
             ,@i_BU_location_id
             ,@i_BU_location_name
             ,@i_BU_address_1
             ,@i_BU_address_2
             ,@i_BU_zip_code
             ,@i_BU_city
             ,@i_BU_state
             ,@i_BU_county
             ,@i_BU_country
             ,@i_BU_email_address
             ,@i_BU_phone_number
             ,@i_BU_fax_number
             ,@i_BU_owner_name
             ,@i_BU_owner_license
             ,@i_BUMA_location_id
             ,@i_BUMA_location_name
             ,@i_BUMA_address_1
             ,@i_BUMA_address_2
             ,@i_BUMA_zip_code
             ,@i_BUMA_city
             ,@i_BUMA_state
             ,@i_BUMA_county
             ,@i_BUMA_country
             ,@i_BUMA_payment_center
             ,@i_T_tin_effective_date
             ,@i_T_tin_end_date
             ,@i_T_w9_onfile
             ,@i_T_W9_Completed
             ,@i_T_W9_Date_Requested
             ,@i_T_w9_rec_date
             ,@i_T_w9_business_type
             ,@i_T_name_1099
             ,@i_T_name_1099_2
             ,@i_B_waiver
             ,@i_B_waiver_percentage
             ,@i_T_location_id
             ,@i_T_location_name
             ,@i_T_address_1
             ,@i_T_address_2
             ,@i_T_zip_code
             ,@i_T_city
             ,@i_T_state
             ,@i_T_county
             ,@i_T_country
             ,@i_B_aba_number
             ,@i_B_bank_name
             ,@i_B_branch_phone_number
             ,@i_B_account_type
             ,@i_B_account_number
             ,@i_B_eft_status
             ,@i_B_eft_effective_date
             ,@i_B_eft_decline_code
             ,@i_B_eft_decline_start_date
             ,@i_B_eft_decline_end_date
             ,@i_C_cap_pcp_roster
             ,@i_SL_location_id
             ,@i_SL_location_name
             ,@i_SL_address_1
             ,@i_SL_address_2
             ,@i_SL_zip_code
             ,@i_SL_city
             ,@i_SL_state
             ,@i_SL_county
             ,@i_SL_country
             ,@i_MA_location_id
             ,@i_MA_location_name
             ,@i_MA_address_1
             ,@i_MA_address_2
             ,@i_MA_zip_code
             ,@i_MA_city
             ,@i_MA_state
             ,@i_MA_county
             ,@i_MA_country
             ,@i_SL_contact_fname
             ,@i_SL_contact_lname
             ,@i_SL_contact_phone
             ,@i_SL_contact_fax
             ,@i_SL_contact_email
             ,@i_SL_emerg_phone
             ,@i_Alt_fax_number
             ,@i_SL_website_url
             ,@i_primary_location_indicator
             ,@i_SL_status_code
             ,@i_SL_assign_override_flag
             ,@i_SL_cust_prov_id
             ,@i_SL_npf_site_id
             ,@i_SL_add_override_code
             ,@i_SL_filed_fee_id
             ,@i_SL_default_deliv_method
             ,@i_show_in_directory
             ,@i_handicap_accessible
             ,@i_handicap_acc_date
             ,@i_accept_new_patient
             ,@i_appt_wait_days
             ,@i_min_patient_age
             ,@i_max_patient_age
             ,@i_Accept_Dis
             ,@i_TranslationServices
             ,@i_TTYService
             ,@i_WheelAccess_ExamRoom
             ,@i_WheelAccess_RestRoom
             ,@i_WheelAccess_Ramp
             ,@i_PublicTrans_Access
             ,@i_accepts_hiv_aids_patients
             ,@i_accepts_co_occuring_disorders_patients
             ,@i_accepts_chronic_illness_patients
             ,@i_accepts_physical_disabilities_patients
             ,@i_accepts_serious_mental_illness_patients
             ,@i_accepts_homeless_patients
             ,@i_accepts_blind_visually_impaired_patients
             ,@i_accepts_deaf_hearing_impaired_patients
             ,@i_adjustable_exam_table
             ,@i_handicap_parking
             ,@i_hour_24
             ,@i_mon
             ,@i_language_1
             ,@i_tue
             ,@i_language_2
             ,@i_wed
             ,@i_language_3
             ,@i_thu
             ,@i_language_4
             ,@i_fri
             ,@i_sat
             ,@i_sun
             ,@i_drg_version
             ,@i_SL_new_effective_date
             ,@i_SL_new_termination_date
             ,@i_npi_id
             ,@i_SL_npi_verif
             ,@i_Loc_Category
             ,@i_SL_termination_reason
             ,@iServiceLocationName
             ,@i_chain_code
             ,@i_chain_name
             ,@i_dispenser_class
             ,@i_dispenser_type
             ,@i_license_id
             ,@i_license_type
             ,@i_license_date
             ,@i_license_term_date
             ,@i_license_state
             ,@i_practice_in
             ,@i_verify_start_date
             ,@i_verify_date
             ,@i_verifier_name
             ,@i_verifier_phone
             ,@i_BAC
             ,@i_Bus_Code
             ,@i_Schedule
             ,@i_location_id
             ,@i_location_desc
             ,@i_address_1
             ,@i_address_2
             ,@i_zip_code
             ,@i_city
             ,@i_state
             ,@i_county
             ,@i_country
             ,@i_P_malprac_carrier
             ,@i_P_malprac_policy
             ,@i_P_malprac_eff_date
             ,@i_P_malprac_term_date
             ,@i_P_Verif_Date_Started
             ,@i_P_Verif_Date_Completed
             ,@i_P_malprac_limit_occur
             ,@i_P_malprac_limit_year
             ,@i_P_Aggregate_Amount
             ,@i_P_Coverage_Type
             ,@i_P_Carrier_Time
             ,@i_P_Carrier_span
             ,@i_P_Notes
             ,@i_P_Carrier_Loc_ID
             ,@i_P_Carrier_Location_Desc
             ,@i_P_Carrier_Address1
             ,@i_P_Carrier_Address2
             ,@i_P_Carrier_Zip
             ,@i_P_Carrier_City
             ,@i_P_Carrier_State
             ,@i_P_Carrier_County
             ,@i_P_Carrier_Country
             ,@i_P_Verifer_Name
             ,@i_P_Verifer_Phone
             ,@i_S_specialty
             ,@i_S_specialty_desc
             ,@i_S_treat_as_specialty
             ,@i_S_treat_specialty_desc
             ,@i_primary_indicator
             ,@i_S_school
             ,@i_S_grad_year
             ,@i_S_res_comp_date
             ,@i_S_board_elig_date
             ,@i_S_board_cert
             ,@i_board_name
			 ,@i_board_cert_url		-- Comment this out for SP37 or earlier
             ,@i_S_print_as_spec
             ,@i_spi_id
             ,@i_sp_npi_id
             ,@i_sp_npi_verif
             ,@i_scheduled_date
             ,@i_experation_date
             ,@i_Recertification_date
             ,@i_reporting_type
             ,@i_S_State_Rpt_type
             ,@i_HMS_Specialty_ID
             ,@o_status
             ,@o_message
             ,@i_DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocations_Cursor
DEALLOCATE ServiceLocations_Cursor

END
GO