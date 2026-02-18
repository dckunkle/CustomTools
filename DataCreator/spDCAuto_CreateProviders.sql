IF OBJECT_ID('dbo.spDCAuto_CreateProviders') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProviders AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProviders
Purpose:    Create providers data from CorderAutomation
Method:     Providers
Screen GID: 2006
Procedure:  dbo.prPMProvider_BulkAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProviders '100-Config%', 22, 'Providers'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProviders
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

DECLARE @i_entity_name                            VARCHAR(50)
       ,@i_key_1_field                            VARCHAR(50)
       ,@i_key_2_field                            VARCHAR(50)
       ,@i_key_3_field                            VARCHAR(50)
       ,@i_key_4_field                            VARCHAR(50)
       ,@i_key_5_field                            VARCHAR(50)
       ,@i_key_6_field                            VARCHAR(50)
       ,@i_eDATE                                  VARCHAR(50)
       ,@i_tDate                                  VARCHAR(50)
       ,@i_key_9_field                            VARCHAR(50)
       ,@i_key_10_field                           VARCHAR(50)
       ,@i_action                                 VARCHAR(50)
       ,@i_date_time_modified                     VARCHAR(30)
       ,@iUserID                                  VARCHAR(25)
       ,@i_P_Provider_id                          VARCHAR(60)
       ,@i_P_Practice_As                          VARCHAR(50)
       ,@i_P_HIPPA_id                             VARCHAR(50)
       ,@i_NPI_Verif                              DATETIME
       ,@i_Medicaid_Participatient                VARCHAR(50)
       ,@i_P_Medicaid_id                          VARCHAR(50)
       ,@i_Medicaid_Requested                     DATETIME
       ,@i_Medicaid_Received                      DATETIME
       ,@i_Medicare_Participatient                VARCHAR(50)
       ,@i_P_Medicare_id                          VARCHAR(50)
       ,@i_Medicare_Requested                     DATETIME
       ,@i_Medicare_Received                      DATETIME
       ,@i_P_name_prefix                          VARCHAR(50)
       ,@i_P_first_name                           VARCHAR(50)
       ,@i_P_last_name                            VARCHAR(100)
       ,@i_P_middle_name                          VARCHAR(50)
       ,@i_Prof_desg_1                            VARCHAR(50)
       ,@i_Prof_desg_2                            VARCHAR(50)
       ,@i_Prof_desg_3                            VARCHAR(50)
       ,@i_P_name_suffix                          VARCHAR(50)
       ,@i_P_soc_sec_number                       VARCHAR(50)
       ,@i_P_date_of_birth                        VARCHAR(50)
       ,@i_P_Gender                               VARCHAR(50)
       ,@i_P_health_impairment                    VARCHAR(50)
       ,@i_P_email_address                        VARCHAR(100)
       ,@i_P_language1                            VARCHAR(50)
       ,@i_P_language2                            VARCHAR(50)
       ,@i_P_ethnicity                            VARCHAR(50)
       ,@i_US_citizen                             VARCHAR(50)
       ,@i_VisaNo                                 VARCHAR(50)
       ,@i_Agree_version                          VARCHAR(50)
       ,@i_Agree_Signee                           VARCHAR(80)
       ,@i_Agree_Sign_date                        VARCHAR(50)
       ,@i_UPIN                                   VARCHAR(50)
       ,@i_cultural_competency_training           VARCHAR(50)
       ,@i_dual_demonstration_population_training VARCHAR(50)
       ,@i_H_loc_id                               VARCHAR(50)
       ,@i_H_loc_name                             VARCHAR(100)
       ,@i_H_address1                             VARCHAR(50)
       ,@i_H_address2                             VARCHAR(50)
       ,@i_H_zip                                  VARCHAR(50)
       ,@i_H_city                                 VARCHAR(50)
       ,@i_H_state                                VARCHAR(50)
       ,@i_H_County                               VARCHAR(50)
       ,@i_H_Country                              VARCHAR(50)
       ,@i_O_loc_id                               VARCHAR(50)
       ,@i_O_loc_name                             VARCHAR(100)
       ,@i_O_address1                             VARCHAR(50)
       ,@i_O_address2                             VARCHAR(50)
       ,@i_O_zip                                  VARCHAR(50)
       ,@i_O_city                                 VARCHAR(50)
       ,@i_O_state                                VARCHAR(50)
       ,@i_O_County                               VARCHAR(50)
       ,@i_O_Country                              VARCHAR(50)
       ,@i_license_id                             VARCHAR(50)
       ,@i_license_type                           VARCHAR(50)
       ,@i_license_date                           VARCHAR(50)
       ,@i_license_term_date                      VARCHAR(50)
       ,@i_license_state                          VARCHAR(50)
       ,@i_practice_in                            VARCHAR(50)
       ,@i_verify_start_date                      VARCHAR(50)
       ,@i_verify_date                            VARCHAR(50)
       ,@i_verifier_name                          VARCHAR(50)
       ,@i_verifier_phone                         VARCHAR(50)
       ,@i_BAC                                    VARCHAR(50)
       ,@i_Bus_Code                               VARCHAR(50)
       ,@i_Schedule                               VARCHAR(50)
       ,@i_location_id                            VARCHAR(55)
       ,@i_location_desc                          VARCHAR(55)
       ,@i_address_1                              VARCHAR(55)
       ,@i_address_2                              VARCHAR(55)
       ,@i_zip_code                               VARCHAR(50)
       ,@i_city                                   VARCHAR(50)
       ,@i_state                                  VARCHAR(50)
       ,@i_county                                 VARCHAR(50)
       ,@i_country                                VARCHAR(50)
       ,@i_P_malprac_carrier                      VARCHAR(50)
       ,@i_P_malprac_policy                       VARCHAR(50)
       ,@i_P_malprac_eff_date                     VARCHAR(50)
       ,@i_P_malprac_term_date                    VARCHAR(50)
       ,@i_P_Verif_Date_Started                   VARCHAR(50)
       ,@i_P_Verif_Date_Completed                 VARCHAR(50)
       ,@i_P_malprac_limit_occur                  VARCHAR(50)
       ,@i_P_malprac_limit_year                   VARCHAR(50)
       ,@i_P_Aggregate_Amount                     VARCHAR(50)
       ,@i_P_Coverage_Type                        VARCHAR(50)
       ,@i_P_Carrier_Time                         VARCHAR(50)
       ,@i_P_Carrier_span                         VARCHAR(50)
       ,@i_P_Notes                                VARCHAR(100)
       ,@i_P_Carrier_Loc_ID                       VARCHAR(50)
       ,@i_P_Carrier_Location_Desc                VARCHAR(50)
       ,@i_P_Carrier_Address1                     VARCHAR(50)
       ,@i_P_Carrier_Address2                     VARCHAR(50)
       ,@i_P_Carrier_Zip                          VARCHAR(50)
       ,@i_P_Carrier_City                         VARCHAR(50)
       ,@i_P_Carrier_State                        VARCHAR(50)
       ,@i_P_Carrier_County                       VARCHAR(50)
       ,@i_P_Carrier_Country                      VARCHAR(50)
       ,@i_P_Verifer_Name                         VARCHAR(50)
       ,@i_P_Verifer_Phone                        VARCHAR(50)
       ,@o_status                                 INT
       ,@o_message                                VARCHAR(100)
       ,@intProvider_gid                          INT
       ,@i_DisplayResults                         VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Providers') IS NOT NULL
	DROP TABLE #Providers

CREATE TABLE #Providers
      (i_entity_name                            VARCHAR(50)       DEFAULT('Prov_Inc2')
      ,i_key_1_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                            VARCHAR(50)       DEFAULT('0')
      ,i_eDATE                                  VARCHAR(50)       DEFAULT('0')
      ,i_tDate                                  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                           VARCHAR(50)       DEFAULT('0')
      ,i_action                                 VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified                     VARCHAR(30)       DEFAULT('')
      ,iUserID                                  VARCHAR(25)       DEFAULT('')
      ,i_P_Provider_id                          VARCHAR(60)
      ,i_P_Practice_As                          VARCHAR(50)
      ,i_P_HIPPA_id                             VARCHAR(50)
      ,i_NPI_Verif                              DATETIME
      ,i_Medicaid_Participatient                VARCHAR(50)
      ,i_P_Medicaid_id                          VARCHAR(50)
      ,i_Medicaid_Requested                     DATETIME
      ,i_Medicaid_Received                      DATETIME
      ,i_Medicare_Participatient                VARCHAR(50)
      ,i_P_Medicare_id                          VARCHAR(50)
      ,i_Medicare_Requested                     DATETIME
      ,i_Medicare_Received                      DATETIME
      ,i_P_name_prefix                          VARCHAR(50)
      ,i_P_first_name                           VARCHAR(50)
      ,i_P_last_name                            VARCHAR(100)
      ,i_P_middle_name                          VARCHAR(50)
      ,i_Prof_desg_1                            VARCHAR(50)
      ,i_Prof_desg_2                            VARCHAR(50)
      ,i_Prof_desg_3                            VARCHAR(50)
      ,i_P_name_suffix                          VARCHAR(50)
      ,i_P_soc_sec_number                       VARCHAR(50)
      ,i_P_date_of_birth                        VARCHAR(50)
      ,i_P_Gender                               VARCHAR(50)
      ,i_P_health_impairment                    VARCHAR(50)
      ,i_P_email_address                        VARCHAR(100)
      ,i_P_language1                            VARCHAR(50)
      ,i_P_language2                            VARCHAR(50)
      ,i_P_ethnicity                            VARCHAR(50)
      ,i_US_citizen                             VARCHAR(50)
      ,i_VisaNo                                 VARCHAR(50)
      ,i_Agree_version                          VARCHAR(50)
      ,i_Agree_Signee                           VARCHAR(80)
      ,i_Agree_Sign_date                        VARCHAR(50)
      ,i_UPIN                                   VARCHAR(50)
      ,i_cultural_competency_training           VARCHAR(50)
      ,i_dual_demonstration_population_training VARCHAR(50)
      ,i_H_loc_id                               VARCHAR(50)
      ,i_H_loc_name                             VARCHAR(100)
      ,i_H_address1                             VARCHAR(50)
      ,i_H_address2                             VARCHAR(50)
      ,i_H_zip                                  VARCHAR(50)
      ,i_H_city                                 VARCHAR(50)
      ,i_H_state                                VARCHAR(50)
      ,i_H_County                               VARCHAR(50)
      ,i_H_Country                              VARCHAR(50)
      ,i_O_loc_id                               VARCHAR(50)
      ,i_O_loc_name                             VARCHAR(100)
      ,i_O_address1                             VARCHAR(50)
      ,i_O_address2                             VARCHAR(50)
      ,i_O_zip                                  VARCHAR(50)
      ,i_O_city                                 VARCHAR(50)
      ,i_O_state                                VARCHAR(50)
      ,i_O_County                               VARCHAR(50)
      ,i_O_Country                              VARCHAR(50)
      ,i_license_id                             VARCHAR(50)
      ,i_license_type                           VARCHAR(50)
      ,i_license_date                           VARCHAR(50)
      ,i_license_term_date                      VARCHAR(50)
      ,i_license_state                          VARCHAR(50)
      ,i_practice_in                            VARCHAR(50)
      ,i_verify_start_date                      VARCHAR(50)
      ,i_verify_date                            VARCHAR(50)
      ,i_verifier_name                          VARCHAR(50)
      ,i_verifier_phone                         VARCHAR(50)
      ,i_BAC                                    VARCHAR(50)
      ,i_Bus_Code                               VARCHAR(50)
      ,i_Schedule                               VARCHAR(50)
      ,i_location_id                            VARCHAR(55)
      ,i_location_desc                          VARCHAR(55)
      ,i_address_1                              VARCHAR(55)
      ,i_address_2                              VARCHAR(55)
      ,i_zip_code                               VARCHAR(50)
      ,i_city                                   VARCHAR(50)
      ,i_state                                  VARCHAR(50)
      ,i_county                                 VARCHAR(50)
      ,i_country                                VARCHAR(50)
      ,i_P_malprac_carrier                      VARCHAR(50)
      ,i_P_malprac_policy                       VARCHAR(50)
      ,i_P_malprac_eff_date                     VARCHAR(50)
      ,i_P_malprac_term_date                    VARCHAR(50)
      ,i_P_Verif_Date_Started                   VARCHAR(50)
      ,i_P_Verif_Date_Completed                 VARCHAR(50)
      ,i_P_malprac_limit_occur                  VARCHAR(50)
      ,i_P_malprac_limit_year                   VARCHAR(50)
      ,i_P_Aggregate_Amount                     VARCHAR(50)
      ,i_P_Coverage_Type                        VARCHAR(50)
      ,i_P_Carrier_Time                         VARCHAR(50)
      ,i_P_Carrier_span                         VARCHAR(50)
      ,i_P_Notes                                VARCHAR(100)
      ,i_P_Carrier_Loc_ID                       VARCHAR(50)
      ,i_P_Carrier_Location_Desc                VARCHAR(50)
      ,i_P_Carrier_Address1                     VARCHAR(50)
      ,i_P_Carrier_Address2                     VARCHAR(50)
      ,i_P_Carrier_Zip                          VARCHAR(50)
      ,i_P_Carrier_City                         VARCHAR(50)
      ,i_P_Carrier_State                        VARCHAR(50)
      ,i_P_Carrier_County                       VARCHAR(50)
      ,i_P_Carrier_Country                      VARCHAR(50)
      ,i_P_Verifer_Name                         VARCHAR(50)
      ,i_P_Verifer_Phone                        VARCHAR(50)
      ,o_status                                 INT
      ,o_message                                VARCHAR(100)
      ,intProvider_gid                          INT
      ,i_DisplayResults                         VARCHAR(50)
      ,record_id                                INT
      ,static_gid                               INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Providers
      (i_P_Provider_id
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
      ,i_P_email_address
      ,i_P_language1
      ,i_P_language2
      ,i_P_ethnicity
      ,i_US_citizen
      ,i_VisaNo
      ,i_Agree_version
      ,i_Agree_Signee
      ,i_Agree_Sign_date
      ,i_UPIN
      ,i_cultural_competency_training
      ,i_dual_demonstration_population_training
      ,i_H_loc_id
      ,i_O_loc_id
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
      ,i_P_Verifer_Name
      ,i_P_Verifer_Phone
      ,record_id
      ,static_gid)
SELECT ISNULL([*Common_ProviderID], '')
      ,ISNULL([*Common_PracticingAs], '')
      ,ISNULL([Common_NPIID], '')
      ,ISNULL([Common_NPIVerification], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MedicaidParticipant]), 'U')
      ,ISNULL([Common_MedicaidID], '')
      ,ISNULL([Common_MedicaidRequested], '12/31/9999')
      ,ISNULL([Common_MedicaidReceived], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MediCareParticipant]), 'U')
      ,ISNULL([Common_MedicareID], '')
      ,ISNULL([Common_MedicareRequested], '12/31/9999')
      ,ISNULL([Common_MedicareReceived], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Prefix]), 'Dr.')
      ,ISNULL([Common_FirstName], '')
      ,ISNULL([*Common_LastCorpName], '')
      ,ISNULL([Common_MiddleName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ProfDesignation1]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ProfDesignation2]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ProfDesignation3]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Suffix]), '')
      ,ISNULL([Common_SSN], '')
      ,ISNULL([Common_DOB], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Gender]), 'U')
      ,ISNULL([Common_HealthImpairment], '')
      ,ISNULL([Common_Email], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Lang1]), 'EN')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Lang2]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Ethnicity]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_USCitizen]), '')
      ,ISNULL([Common_ResVisaNo], '')
      ,ISNULL([Common_ProvAgreemVer], '')
      ,ISNULL([Common_ProvAgreemSignee], '')
      ,ISNULL([Common_ProvAgreemSignedDt], '12/31/9999')
      ,ISNULL([Common_UniquePhysIDNo], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CulCompTrng]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DualDemoPopulTrngExp]), 'U')
      ,ISNULL([Common_HomeLocID], '')
      ,ISNULL([Common_OtherLocID], '')
      ,ISNULL([LicMal_LicenseNo], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_LicenseType]), '')
      ,ISNULL([LicMal_OrigDtOfIssue], '')
      ,ISNULL([LicMal_ExpirationDt], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_StateOfReg]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_PracticeInState]), 'N')
      ,ISNULL([LicMal_VerProcessStartDt], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([LicMal_DtVerified], '12/31/9999')
      ,ISNULL([LicMal_LicenseVerifierName], '')
      ,ISNULL([LicMal_LicenseVerifierPhone], '')
      ,ISNULL([LicMal_BAC], '')
      ,ISNULL([LicMal_BASubCode], '')
      ,ISNULL([LicMal_Schedule], '')
      ,ISNULL([LicMal_LicenseLocID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_MalpInsCarrier]), '')
      ,ISNULL([LicMal_PolicyNo], '')
      ,ISNULL([LicMal_EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([LicMal_ExpDate], '12/31/9999')
      ,ISNULL([LicMal_MalpVerifStartDt], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([LicMal_MalpVerifCompDt], '12/31/9999')
      ,ISNULL([LicMal_LimitPerOccur], '')
      ,ISNULL([LicMal_LimitPerYear], '')
      ,ISNULL([LicMal_AmtCovAggregate], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_TypeOfCoverage]), 'C')
      ,ISNULL([LicMal_TimeSpanCarrier], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicMal_LengthOfTimeCarrier]), 'D')
      ,ISNULL([LicMal_Notes], '')
      ,ISNULL([LicMal_CarrierLocID], '')
      ,ISNULL([LicMal_MalpVerifierName], '')
      ,ISNULL([LicMal_MalpVerifierPhone], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Provider
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Providers
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Providers_Cursor CURSOR FOR
 SELECT i_entity_name
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
       ,i_P_email_address
       ,i_P_language1
       ,i_P_language2
       ,i_P_ethnicity
       ,i_US_citizen
       ,i_VisaNo
       ,i_Agree_version
       ,i_Agree_Signee
       ,i_Agree_Sign_date
       ,i_UPIN
       ,i_cultural_competency_training
       ,i_dual_demonstration_population_training
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
       ,o_status
       ,o_message
       ,intProvider_gid
       ,i_DisplayResults
       ,record_id
       ,static_gid
   FROM #Providers

   OPEN Providers_Cursor
  FETCH NEXT FROM Providers_Cursor
   INTO @i_entity_name
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
       ,@i_P_email_address
       ,@i_P_language1
       ,@i_P_language2
       ,@i_P_ethnicity
       ,@i_US_citizen
       ,@i_VisaNo
       ,@i_Agree_version
       ,@i_Agree_Signee
       ,@i_Agree_Sign_date
       ,@i_UPIN
       ,@i_cultural_competency_training
       ,@i_dual_demonstration_population_training
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
       ,@o_status
       ,@o_message
       ,@intProvider_gid
       ,@i_DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prPMProvider_BulkAdd
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
            ,@i_P_email_address
            ,@i_P_language1
            ,@i_P_language2
            ,@i_P_ethnicity
            ,@i_US_citizen
            ,@i_VisaNo
            ,@i_Agree_version
            ,@i_Agree_Signee
            ,@i_Agree_Sign_date
            ,@i_UPIN
            ,@i_cultural_competency_training
            ,@i_dual_demonstration_population_training
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
            ,@o_status			= @err_num		OUTPUT
            ,@o_message			= @err_msg		OUTPUT
            ,@intProvider_gid	= @current_gid	OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Get the current provider gid
				SELECT @current_gid				= provider_gid
				  FROM dbo.Provider
				 WHERE provider_id				= @i_P_Provider_id
				   AND record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.Provider 
				   SET provider_gid				= @static_gid 
				 WHERE provider_gid				= @current_gid
				   AND record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.Provider_License_Information 
				   SET provider_gid				= @static_gid 
				 WHERE provider_gid				= @current_gid
				   AND record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.Credentialling 
				   SET entity_gid				= @static_gid 
				 WHERE entity_gid				= @current_gid
				   AND record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_P_Provider_id, @i_P_first_name, @i_P_last_name, @status, @err_num, @err_msg

        FETCH NEXT FROM Providers_Cursor
         INTO @i_entity_name
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
             ,@i_P_email_address
             ,@i_P_language1
             ,@i_P_language2
             ,@i_P_ethnicity
             ,@i_US_citizen
             ,@i_VisaNo
             ,@i_Agree_version
             ,@i_Agree_Signee
             ,@i_Agree_Sign_date
             ,@i_UPIN
             ,@i_cultural_competency_training
             ,@i_dual_demonstration_population_training
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
             ,@o_status
             ,@o_message
             ,@intProvider_gid
             ,@i_DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE Providers_Cursor
DEALLOCATE Providers_Cursor

END
GO