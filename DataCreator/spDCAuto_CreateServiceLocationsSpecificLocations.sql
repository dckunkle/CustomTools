IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocationsSpecificLocations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocationsSpecificLocations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocationsSpecificLocations
Purpose:    Create servicelocationsspecificlocations data from CorderAutomation
Method:     ServiceLocationsSpecificLocations
Screen GID: 151
Procedure:  dbo.prPMProviderLink_Add

Date        User            Change
---------------------------------------------------------------------------------------------
11/21/2019	DK				Original procedure
10/27/2020	DK				Added lookup for languages since the screen does not follow the 
                            normal pattern of Description(Short_Desc)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocationsSpecificLocations '100-Config%', 22, 'ServiceLocationsSpecificLocations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocationsSpecificLocations
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

	   ,@provider_id				VARCHAR(200)
	   ,@location_id				VARCHAR(200)
	   ,@business_id				VARCHAR(200)
	   ,@service_location_count		INT

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name                              VARCHAR(50)
       ,@i_provider_gid                             VARCHAR(50)
       ,@i_location_gid                             VARCHAR(50)
       ,@i_business_gid                             VARCHAR(50)
       ,@i_key_4_field                              VARCHAR(50)
       ,@i_key_5_field                              VARCHAR(50)
       ,@i_key_6_field                              VARCHAR(50)
       ,@i_effective_date                           VARCHAR(50)
       ,@i_termination_date                         VARCHAR(50)
       ,@i_key_9_field                              VARCHAR(50)
       ,@i_key_10_field                             VARCHAR(50)
       ,@i_action                                   VARCHAR(50)
       ,@i_date_time_modified                       VARCHAR(50)
       ,@iUserID                                    VARCHAR(50)
       ,@i_status_code                              VARCHAR(50)
       ,@i_assignment_override_code                 VARCHAR(50)
       ,@i_cust_prov_id                             VARCHAR(60)
       ,@i_npf_site_id                              VARCHAR(50)
       ,@i_address_override_flag                    VARCHAR(50)
       ,@i_filed_fee_id                             VARCHAR(50)
       ,@i_def_deliv                                VARCHAR(50)
       ,@i_show_in_dir                              VARCHAR(50)
       ,@i_handi_access                             VARCHAR(50)
       ,@i_handi_date                               VARCHAR(50)
       ,@i_accept_new_pats                          VARCHAR(50)
       ,@i_appt_wait_days                           VARCHAR(50)
       ,@i_min_patient_age                          INT
       ,@i_max_patient_age                          INT
       ,@i_new_effective_date                       VARCHAR(50)
       ,@i_new_termination_date                     VARCHAR(50)
       ,@i_npi_id                                   VARCHAR(50)
       ,@i_SL_npi_verif                             VARCHAR(50)
       ,@i_Loc_Category                             VARCHAR(50)
       ,@i_termination_reason                       VARCHAR(50)
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
       ,@i_BLIKey                                   VARCHAR(50)
       ,@iServiceLocationName                       VARCHAR(100)
       ,@i_phys_location_id                         VARCHAR(50)
       ,@i_phys_location_name                       VARCHAR(100)
       ,@i_phys_addy1                               VARCHAR(55)
       ,@i_phys_addy2                               VARCHAR(55)
       ,@i_phys_zip                                 VARCHAR(50)
       ,@i_phys_city                                VARCHAR(50)
       ,@i_phys_state                               VARCHAR(50)
       ,@i_phys_county                              VARCHAR(50)
       ,@i_phys_country                             VARCHAR(50)
       ,@i_mail_location_id                         VARCHAR(50)
       ,@i_mail_location_name                       VARCHAR(100)
       ,@i_mail_addy1                               VARCHAR(55)
       ,@i_mail_addy2                               VARCHAR(55)
       ,@i_mail_zip                                 VARCHAR(50)
       ,@i_mail_city                                VARCHAR(50)
       ,@i_mail_state                               VARCHAR(50)
       ,@i_mail_county                              VARCHAR(50)
       ,@i_mail_country                             VARCHAR(50)
       ,@i_contact_fname                            VARCHAR(50)
       ,@i_contact_lname                            VARCHAR(60)
       ,@i_phone_number                             VARCHAR(50)
       ,@i_emerg_phone_number                       VARCHAR(50)
       ,@i_fax_number                               VARCHAR(50)
       ,@i_Alt_fax_number                           VARCHAR(50)
       ,@i_email_address                            VARCHAR(100)
       ,@i_website_url                              VARCHAR(255)
       ,@i_primary_location_indicator               VARCHAR(50)
       ,@i_hour_24                                  VARCHAR(50)
       ,@i_mon_hours                                VARCHAR(50)
       ,@i_lang1                                    VARCHAR(50)
       ,@i_tue_hours                                VARCHAR(50)
       ,@i_lang2                                    VARCHAR(50)
       ,@i_wed_hours                                VARCHAR(50)
       ,@i_lang3                                    VARCHAR(50)
       ,@i_thu_hours                                VARCHAR(50)
       ,@i_lang4                                    VARCHAR(50)
       ,@i_fri_hours                                VARCHAR(50)
       ,@i_sat_hours                                VARCHAR(50)
       ,@i_sun_hours                                VARCHAR(50)
       ,@i_drg_version                              VARCHAR(50)
       ,@i_chain_id                                 VARCHAR(50)
       ,@i_chain_name                               VARCHAR(255)
       ,@i_dispenser_class                          VARCHAR(50)
       ,@i_dispenser_type                           VARCHAR(50)
       ,@o_status                                   INT
       ,@o_message                                  VARCHAR(100)
       ,@i_Mail_Loc_gid                             INT
       ,@i_disp_results                             VARCHAR(50)
       ,@i_ext_prov                                 VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsSpecificLocations') IS NOT NULL
	DROP TABLE #ServiceLocationsSpecificLocations

CREATE TABLE #ServiceLocationsSpecificLocations
      (SearchID                                   VARCHAR(200)
      ,i_entity_name                              VARCHAR(50)       DEFAULT('Prov_Loc_Info')
      ,i_provider_gid                             VARCHAR(50)       DEFAULT('0')
      ,i_location_gid                             VARCHAR(50)       DEFAULT('0')
      ,i_business_gid                             VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                              VARCHAR(50)       DEFAULT('0')
      ,i_effective_date                           VARCHAR(50)       DEFAULT('0')
      ,i_termination_date                         VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                             VARCHAR(50)       DEFAULT('0')
      ,i_action                                   VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified                       VARCHAR(50)       DEFAULT('')
      ,iUserID                                    VARCHAR(50)       DEFAULT('')
      ,i_status_code                              VARCHAR(50)
      ,i_assignment_override_code                 VARCHAR(50)
      ,i_cust_prov_id                             VARCHAR(60)
      ,i_npf_site_id                              VARCHAR(50)
      ,i_address_override_flag                    VARCHAR(50)
      ,i_filed_fee_id                             VARCHAR(50)
      ,i_def_deliv                                VARCHAR(50)
      ,i_show_in_dir                              VARCHAR(50)
      ,i_handi_access                             VARCHAR(50)
      ,i_handi_date                               VARCHAR(50)
      ,i_accept_new_pats                          VARCHAR(50)
      ,i_appt_wait_days                           VARCHAR(50)
      ,i_min_patient_age                          INT
      ,i_max_patient_age                          INT
      ,i_new_effective_date                       VARCHAR(50)
      ,i_new_termination_date                     VARCHAR(50)
      ,i_npi_id                                   VARCHAR(50)
      ,i_SL_npi_verif                             VARCHAR(50)
      ,i_Loc_Category                             VARCHAR(50)
      ,i_termination_reason                       VARCHAR(50)
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
      ,i_BLIKey                                   VARCHAR(50)
      ,iServiceLocationName                       VARCHAR(100)
      ,i_phys_location_id                         VARCHAR(50)
      ,i_phys_location_name                       VARCHAR(100)
      ,i_phys_addy1                               VARCHAR(55)
      ,i_phys_addy2                               VARCHAR(55)
      ,i_phys_zip                                 VARCHAR(50)
      ,i_phys_city                                VARCHAR(50)
      ,i_phys_state                               VARCHAR(50)
      ,i_phys_county                              VARCHAR(50)
      ,i_phys_country                             VARCHAR(50)
      ,i_mail_location_id                         VARCHAR(50)
      ,i_mail_location_name                       VARCHAR(100)
      ,i_mail_addy1                               VARCHAR(55)
      ,i_mail_addy2                               VARCHAR(55)
      ,i_mail_zip                                 VARCHAR(50)
      ,i_mail_city                                VARCHAR(50)
      ,i_mail_state                               VARCHAR(50)
      ,i_mail_county                              VARCHAR(50)
      ,i_mail_country                             VARCHAR(50)
      ,i_contact_fname                            VARCHAR(50)
      ,i_contact_lname                            VARCHAR(60)
      ,i_phone_number                             VARCHAR(50)
      ,i_emerg_phone_number                       VARCHAR(50)
      ,i_fax_number                               VARCHAR(50)
      ,i_Alt_fax_number                           VARCHAR(50)
      ,i_email_address                            VARCHAR(100)
      ,i_website_url                              VARCHAR(255)
      ,i_primary_location_indicator               VARCHAR(50)
      ,i_hour_24                                  VARCHAR(50)
      ,i_mon_hours                                VARCHAR(50)
      ,i_lang1                                    VARCHAR(50)
      ,i_tue_hours                                VARCHAR(50)
      ,i_lang2                                    VARCHAR(50)
      ,i_wed_hours                                VARCHAR(50)
      ,i_lang3                                    VARCHAR(50)
      ,i_thu_hours                                VARCHAR(50)
      ,i_lang4                                    VARCHAR(50)
      ,i_fri_hours                                VARCHAR(50)
      ,i_sat_hours                                VARCHAR(50)
      ,i_sun_hours                                VARCHAR(50)
      ,i_drg_version                              VARCHAR(50)
      ,i_chain_id                                 VARCHAR(50)
      ,i_chain_name                               VARCHAR(255)
      ,i_dispenser_class                          VARCHAR(50)
      ,i_dispenser_type                           VARCHAR(50)
      ,o_status                                   INT
      ,o_message                                  VARCHAR(100)
      ,i_Mail_Loc_gid                             INT
      ,i_disp_results                             VARCHAR(50)
      ,i_ext_prov                                 VARCHAR(50)
      ,record_id                                  INT
      ,static_gid                                 INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ServiceLocationsSpecificLocations
      (SearchID
      ,i_status_code                              
      ,i_assignment_override_code                 
      ,i_cust_prov_id                             
      ,i_npf_site_id                              
      ,i_address_override_flag                    
      ,i_filed_fee_id                             
      ,i_def_deliv                                
      ,i_show_in_dir                              
      ,i_handi_access                             
      ,i_handi_date                               
      ,i_accept_new_pats                          
      ,i_appt_wait_days                           
      ,i_min_patient_age                          
      ,i_max_patient_age                          
      ,i_new_effective_date                       
      ,i_new_termination_date                     
      ,i_npi_id                                   
      ,i_SL_npi_verif                             
      ,i_Loc_Category                             
      ,i_termination_reason                       
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
      ,iServiceLocationName                       
      ,i_phys_location_id                         
      ,i_mail_location_id                         
      ,i_contact_fname                            
      ,i_contact_lname                            
      ,i_phone_number                             
      ,i_emerg_phone_number                       
      ,i_fax_number                               
      ,i_Alt_fax_number                           
      ,i_email_address                            
      ,i_website_url                              
      ,i_primary_location_indicator               
      ,i_hour_24                                  
      ,i_mon_hours                                
      ,i_lang1                                    
      ,i_tue_hours                                
      ,i_lang2                                    
      ,i_wed_hours                                
      ,i_lang3                                    
      ,i_thu_hours                                
      ,i_lang4                                    
      ,i_fri_hours                                
      ,i_sat_hours                                
      ,i_sun_hours                                
      ,i_drg_version                              
      ,i_chain_id                                 
      ,i_dispenser_class                          
      ,i_dispenser_type                           
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_StatusCode]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Assignable]), 'U')
      ,ISNULL([Common_PriorID], '')
      ,ISNULL([Common_SiteID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AddressOverrideCode]), '')
      ,ISNULL([Common_FiledFeeID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DefaultDelMethod]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ShowinDirectory]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HandicapAccess]), 'N')
      ,ISNULL([Common_HandicapAccDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptNewPatients]), 'Y')
      ,ISNULL([Common_Appointmentwaitdays], '0')
      ,ISNULL([Common_PatientMinAge], '0')
      ,ISNULL([Common_PatientMaxAge], '999')
      ,ISNULL([Common_*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Common_*TerminationDate], '12/31/9999')
      ,ISNULL([Common_NPIID], '')
      ,ISNULL([Common_NPIVerification], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LocationCategory]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TerminationReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsDevDisabPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TranslationServices]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TTYService]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_WheelchairAccessExamRm]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_WheelchairAccessRestrm]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_WheelchairRamps]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AccessiblebyPubTrans]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsHIVAIDSPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsCo-OccurringDisPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsChronicIllnessPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsPhyDisabPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsSeriousMentalIllPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsHomelessPatients]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsBlindVisuallyImprdPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AcceptsDeafHearingImpairdPat]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AdjustableExamTable]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HandicapParking]), 'U')
      ,ISNULL([Common_ServiceLocationName], '')
      ,ISNULL([AddContact_Physical_*LocationID], '')
      ,ISNULL([AddContact_Mail_*LocationID], '')
      ,ISNULL([AddContact_ContactFirstName], '')
      ,ISNULL([AddContact_ContactLastName], '')
      ,ISNULL([AddContact_Phone], '0000000000')
      ,ISNULL([AddContact_EmergencyPhone], '0000000000')
      ,ISNULL([AddContact_Fax], '0000000000')
      ,ISNULL([AddContact_AltFax], '0000000000')
      ,ISNULL([AddContact_Email], '')
      ,ISNULL([AddContact_WebSiteURL], '')
	  ,'U' --,ISNULL(dbo.fnDCAuto_GetDropdownValue([AddContactPrimaryProviderLoc]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenOps_24HourOperation]), 'N')
      ,ISNULL([GenOps_Monday], '')
      ,ISNULL([GenOps_Lang#1], '')
      ,ISNULL([GenOps_Tuesday], '')
      ,ISNULL([GenOps_Lang#2], '')
      ,ISNULL([GenOps_Wednesday], '')
      ,ISNULL([GenOps_Lang#3], '')
      ,ISNULL([GenOps_Thursday], '')
      ,ISNULL([GenOps_Lang#4], '')
      ,ISNULL([GenOps_Friday], '')
      ,ISNULL([GenOps_Saturday], '')
      ,ISNULL([GenOps_Sunday], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenOps_DRGVersion]), '')
      ,ISNULL([Pharm_ChainID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Pharm_DispenserClassCode]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Pharm_DispenserTypeCode]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocationSpecificLocInfo
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ServiceLocationsSpecificLocations
   SET iUserID  = @user

--*************************************************************************************************
-- Update any language codes that have been passed in
--*************************************************************************************************
UPDATE SLSL
   SET SLSL.i_lang1							= CASE WHEN ISNULL(SAV.Short_Desc, '') = '' THEN SLSL.i_lang1 ELSE SAV.Short_Desc END
  FROM #ServiceLocationsSpecificLocations	SLSL
  JOIN System_Action_Values					SAV
    ON SLSL.i_lang1							= SAV.Description
 WHERE SAV.Reference_Type					= 'LANG'
   AND SAV.record_status					= 'A'

UPDATE SLSL
   SET SLSL.i_lang2							= CASE WHEN ISNULL(SAV.Short_Desc, '') = '' THEN SLSL.i_lang2 ELSE SAV.Short_Desc END
  FROM #ServiceLocationsSpecificLocations	SLSL
  JOIN System_Action_Values					SAV
    ON SLSL.i_lang2							= SAV.Description
 WHERE SAV.Reference_Type					= 'LANG'
   AND SAV.record_status					= 'A'

UPDATE SLSL
   SET SLSL.i_lang3							= CASE WHEN ISNULL(SAV.Short_Desc, '') = '' THEN SLSL.i_lang3 ELSE SAV.Short_Desc END
  FROM #ServiceLocationsSpecificLocations	SLSL
  JOIN System_Action_Values					SAV
    ON SLSL.i_lang3							= SAV.Description
 WHERE SAV.Reference_Type					= 'LANG'
   AND SAV.record_status					= 'A'

UPDATE SLSL
   SET SLSL.i_lang4							= CASE WHEN ISNULL(SAV.Short_Desc, '') = '' THEN SLSL.i_lang4 ELSE SAV.Short_Desc END
  FROM #ServiceLocationsSpecificLocations	SLSL
  JOIN System_Action_Values					SAV
    ON SLSL.i_lang4							= SAV.Description
 WHERE SAV.Reference_Type					= 'LANG'
   AND SAV.record_status					= 'A'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocationsSpecificLocations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_provider_gid
       ,i_location_gid
       ,i_business_gid
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_effective_date
       ,i_termination_date
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_status_code
       ,i_assignment_override_code
       ,i_cust_prov_id
       ,i_npf_site_id
       ,i_address_override_flag
       ,i_filed_fee_id
       ,i_def_deliv
       ,i_show_in_dir
       ,i_handi_access
       ,i_handi_date
       ,i_accept_new_pats
       ,i_appt_wait_days
       ,i_min_patient_age
       ,i_max_patient_age
       ,i_new_effective_date
       ,i_new_termination_date
       ,i_npi_id
       ,i_SL_npi_verif
       ,i_Loc_Category
       ,i_termination_reason
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
       ,i_BLIKey
       ,iServiceLocationName
       ,i_phys_location_id
       ,i_phys_location_name
       ,i_phys_addy1
       ,i_phys_addy2
       ,i_phys_zip
       ,i_phys_city
       ,i_phys_state
       ,i_phys_county
       ,i_phys_country
       ,i_mail_location_id
       ,i_mail_location_name
       ,i_mail_addy1
       ,i_mail_addy2
       ,i_mail_zip
       ,i_mail_city
       ,i_mail_state
       ,i_mail_county
       ,i_mail_country
       ,i_contact_fname
       ,i_contact_lname
       ,i_phone_number
       ,i_emerg_phone_number
       ,i_fax_number
       ,i_Alt_fax_number
       ,i_email_address
       ,i_website_url
       ,i_primary_location_indicator
       ,i_hour_24
       ,i_mon_hours
       ,i_lang1
       ,i_tue_hours
       ,i_lang2
       ,i_wed_hours
       ,i_lang3
       ,i_thu_hours
       ,i_lang4
       ,i_fri_hours
       ,i_sat_hours
       ,i_sun_hours
       ,i_drg_version
       ,i_chain_id
       ,i_chain_name
       ,i_dispenser_class
       ,i_dispenser_type
       ,o_status
       ,o_message
       ,i_Mail_Loc_gid
       ,i_disp_results
       ,i_ext_prov
       ,record_id
       ,static_gid
   FROM #ServiceLocationsSpecificLocations

   OPEN ServiceLocationsSpecificLocations_Cursor
  FETCH NEXT FROM ServiceLocationsSpecificLocations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_provider_gid
       ,@i_location_gid
       ,@i_business_gid
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_effective_date
       ,@i_termination_date
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_status_code
       ,@i_assignment_override_code
       ,@i_cust_prov_id
       ,@i_npf_site_id
       ,@i_address_override_flag
       ,@i_filed_fee_id
       ,@i_def_deliv
       ,@i_show_in_dir
       ,@i_handi_access
       ,@i_handi_date
       ,@i_accept_new_pats
       ,@i_appt_wait_days
       ,@i_min_patient_age
       ,@i_max_patient_age
       ,@i_new_effective_date
       ,@i_new_termination_date
       ,@i_npi_id
       ,@i_SL_npi_verif
       ,@i_Loc_Category
       ,@i_termination_reason
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
       ,@i_BLIKey
       ,@iServiceLocationName
       ,@i_phys_location_id
       ,@i_phys_location_name
       ,@i_phys_addy1
       ,@i_phys_addy2
       ,@i_phys_zip
       ,@i_phys_city
       ,@i_phys_state
       ,@i_phys_county
       ,@i_phys_country
       ,@i_mail_location_id
       ,@i_mail_location_name
       ,@i_mail_addy1
       ,@i_mail_addy2
       ,@i_mail_zip
       ,@i_mail_city
       ,@i_mail_state
       ,@i_mail_county
       ,@i_mail_country
       ,@i_contact_fname
       ,@i_contact_lname
       ,@i_phone_number
       ,@i_emerg_phone_number
       ,@i_fax_number
       ,@i_Alt_fax_number
       ,@i_email_address
       ,@i_website_url
       ,@i_primary_location_indicator
       ,@i_hour_24
       ,@i_mon_hours
       ,@i_lang1
       ,@i_tue_hours
       ,@i_lang2
       ,@i_wed_hours
       ,@i_lang3
       ,@i_thu_hours
       ,@i_lang4
       ,@i_fri_hours
       ,@i_sat_hours
       ,@i_sun_hours
       ,@i_drg_version
       ,@i_chain_id
       ,@i_chain_name
       ,@i_dispenser_class
       ,@i_dispenser_type
       ,@o_status
       ,@o_message
       ,@i_Mail_Loc_gid
       ,@i_disp_results
       ,@i_ext_prov
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Split the search criteria into the provider and location IDs
		TRUNCATE TABLE #Tokens
		INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')

		SELECT @provider_id = token FROM #Tokens WHERE token_order = 1
		SELECT @location_id	= token FROM #Tokens WHERE token_order = 2
		SELECT @business_id	= token FROM #Tokens WHERE token_order = 3

		SELECT @provider_id	= ISNULL(@provider_id, '')
		SELECT @location_id = ISNULL(@location_id, '')
		SELECT @business_id	= ISNULL(@business_id, '')

		-- Make sure there is only one service location 
		SELECT @service_location_count = COUNT(*)
		  FROM Provider_Link			PL
		  JOIN Provider					P
			ON PL.provider_gid			= P.provider_gid
		  JOIN Locations				L
			ON PL.location_gid			= L.location_gid
		  JOIN Business_Units			BU
		    ON PL.business_gid			= BU.business_gid
		  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
			              WHEN provider_id = @provider_id		THEN 1
					      ELSE 0 END)
			AND 1 = (CASE WHEN @location_id = ''				THEN 1 
			              WHEN location_id = @location_id		THEN 1
				          ELSE 0 END)
			AND 1 = (CASE WHEN @business_id = ''				THEN 1 
			              WHEN business_unit_id = @business_id	THEN 1
				          ELSE 0 END)
			AND PL.record_status		= 'A'
			AND P.record_status			= 'A'
			AND L.record_status			= 'A'
			AND BU.record_status		= 'A'

		IF @service_location_count != 1
			BEGIN

				SELECT @status	= 'Error' 
					    ,@err_num	= 16
						,@err_msg	= 'The search criteria, SearchID, does not match to a single service location. Cannot add specialty record.'
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @business_id, @status, @err_num, @err_msg
					
			END
		ELSE
			BEGIN

				BEGIN TRY

					SELECT @i_provider_gid			= PL.provider_gid
						  ,@i_location_gid			= PL.location_gid
						  ,@i_business_gid			= PL.business_gid
					  FROM Provider_Link			PL
					  JOIN Provider					P
						ON PL.provider_gid			= P.provider_gid
					  JOIN Locations				L
						ON PL.location_gid			= L.location_gid
					  JOIN Business_Units			BU
						ON PL.business_gid			= BU.business_gid
					  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
									  WHEN provider_id = @provider_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @location_id = ''				THEN 1 
									  WHEN location_id = @location_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @business_id = ''				THEN 1 
									  WHEN business_unit_id = @business_id	THEN 1
									  ELSE 0 END)
						AND PL.record_status		= 'A'
						AND P.record_status			= 'A'
						AND L.record_status			= 'A'
						AND BU.record_status		= 'A'

					EXEC dbo.prPMProviderLink_Add
					 @i_entity_name
					,@i_provider_gid
					,@i_location_gid
					,@i_business_gid
					,@i_key_4_field
					,@i_key_5_field
					,@i_key_6_field
					,@i_effective_date
					,@i_termination_date
					,@i_key_9_field
					,@i_key_10_field
					,@i_action
					,@i_date_time_modified
					,@iUserID
					,@i_status_code
					,@i_assignment_override_code
					,@i_cust_prov_id
					,@i_npf_site_id
					,@i_address_override_flag
					,@i_filed_fee_id
					,@i_def_deliv
					,@i_show_in_dir
					,@i_handi_access
					,@i_handi_date
					,@i_accept_new_pats
					,@i_appt_wait_days
					,@i_min_patient_age
					,@i_max_patient_age
					,@i_new_effective_date
					,@i_new_termination_date
					,@i_npi_id
					,@i_SL_npi_verif
					,@i_Loc_Category
					,@i_termination_reason
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
					,@i_BLIKey
					,@iServiceLocationName
					,@i_phys_location_id
					,@i_phys_location_name
					,@i_phys_addy1
					,@i_phys_addy2
					,@i_phys_zip
					,@i_phys_city
					,@i_phys_state
					,@i_phys_county
					,@i_phys_country
					,@i_mail_location_id
					,@i_mail_location_name
					,@i_mail_addy1
					,@i_mail_addy2
					,@i_mail_zip
					,@i_mail_city
					,@i_mail_state
					,@i_mail_county
					,@i_mail_country
					,@i_contact_fname
					,@i_contact_lname
					,@i_phone_number
					,@i_emerg_phone_number
					,@i_fax_number
					,@i_Alt_fax_number
					,@i_email_address
					,@i_website_url
					,@i_primary_location_indicator
					,@i_hour_24
					,@i_mon_hours
					,@i_lang1
					,@i_tue_hours
					,@i_lang2
					,@i_wed_hours
					,@i_lang3
					,@i_thu_hours
					,@i_lang4
					,@i_fri_hours
					,@i_sat_hours
					,@i_sun_hours
					,@i_drg_version
					,@i_chain_id
					,@i_chain_name
					,@i_dispenser_class
					,@i_dispenser_type
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT


				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH

			SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
			EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @business_id, @status, @err_num, @err_msg

		END 


        FETCH NEXT FROM ServiceLocationsSpecificLocations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_provider_gid
             ,@i_location_gid
             ,@i_business_gid
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_effective_date
             ,@i_termination_date
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_status_code
             ,@i_assignment_override_code
             ,@i_cust_prov_id
             ,@i_npf_site_id
             ,@i_address_override_flag
             ,@i_filed_fee_id
             ,@i_def_deliv
             ,@i_show_in_dir
             ,@i_handi_access
             ,@i_handi_date
             ,@i_accept_new_pats
             ,@i_appt_wait_days
             ,@i_min_patient_age
             ,@i_max_patient_age
             ,@i_new_effective_date
             ,@i_new_termination_date
             ,@i_npi_id
             ,@i_SL_npi_verif
             ,@i_Loc_Category
             ,@i_termination_reason
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
             ,@i_BLIKey
             ,@iServiceLocationName
             ,@i_phys_location_id
             ,@i_phys_location_name
             ,@i_phys_addy1
             ,@i_phys_addy2
             ,@i_phys_zip
             ,@i_phys_city
             ,@i_phys_state
             ,@i_phys_county
             ,@i_phys_country
             ,@i_mail_location_id
             ,@i_mail_location_name
             ,@i_mail_addy1
             ,@i_mail_addy2
             ,@i_mail_zip
             ,@i_mail_city
             ,@i_mail_state
             ,@i_mail_county
             ,@i_mail_country
             ,@i_contact_fname
             ,@i_contact_lname
             ,@i_phone_number
             ,@i_emerg_phone_number
             ,@i_fax_number
             ,@i_Alt_fax_number
             ,@i_email_address
             ,@i_website_url
             ,@i_primary_location_indicator
             ,@i_hour_24
             ,@i_mon_hours
             ,@i_lang1
             ,@i_tue_hours
             ,@i_lang2
             ,@i_wed_hours
             ,@i_lang3
             ,@i_thu_hours
             ,@i_lang4
             ,@i_fri_hours
             ,@i_sat_hours
             ,@i_sun_hours
             ,@i_drg_version
             ,@i_chain_id
             ,@i_chain_name
             ,@i_dispenser_class
             ,@i_dispenser_type
             ,@o_status
             ,@o_message
             ,@i_Mail_Loc_gid
             ,@i_disp_results
             ,@i_ext_prov
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocationsSpecificLocations_Cursor
DEALLOCATE ServiceLocationsSpecificLocations_Cursor

END
GO