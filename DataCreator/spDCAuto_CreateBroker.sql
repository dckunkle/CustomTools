IF OBJECT_ID('dbo.spDCAuto_CreateBroker') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBroker AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBroker
Purpose:    Create broker data from CorderAutomation
Method:     Broker
Screen GID: 33
Procedure:  dbo.prBrokerAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBroker '100-Config%', 22, 'Broker'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBroker
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_agency_gid         VARCHAR(50)
       ,@i_key_2_Gid          VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_broker_id          VARCHAR(50)
       ,@i_prior_id           VARCHAR(50)
       ,@i_Contact_ID         VARCHAR(50)
       ,@i_Contact_Date       VARCHAR(50)
       ,@i_eff_date           VARCHAR(50)
       ,@i_term_date          VARCHAR(50)
       ,@i_agency_id          VARCHAR(50)
       ,@i_agency_name        VARCHAR(100)
       ,@i_pay_dest           VARCHAR(50)
       ,@i_hipaa_agree        VARCHAR(50)
       ,@i_broker_status      VARCHAR(50)
       ,@i_broker_term_reason VARCHAR(50)
       ,@i_wnine_onfile       VARCHAR(50)
       ,@i_agreement_onfile   VARCHAR(50)
       ,@i_w9recieved         VARCHAR(50)
       ,@i_Agreement_recieved VARCHAR(50)
       ,@i_Vendor_num         VARCHAR(50)
       ,@i_lic_state          VARCHAR(50)
       ,@i_license            VARCHAR(50)
       ,@i_lic_eff_date       VARCHAR(50)
       ,@i_lic_term_date      VARCHAR(50)
       ,@i_status             VARCHAR(50)
       ,@i_term_reason        VARCHAR(50)
       ,@i_lob_grouper_id     VARCHAR(50)
       ,@i_lob_grouper_desc   VARCHAR(100)
       ,@i_custom_lob         VARCHAR(50)
       ,@i_carrier_code       VARCHAR(50)
       ,@i_carrier_desc       VARCHAR(50)
       ,@i_aba_number         VARCHAR(50)
       ,@i_fina_institute     VARCHAR(80)
       ,@i_bank_phone         VARCHAR(50)
       ,@i_account_type       VARCHAR(50)
       ,@i_account_number     VARCHAR(50)
       ,@i_eft_status         VARCHAR(50)
       ,@i_eft_eff_date       VARCHAR(50)
       ,@i_eft_decline_reason VARCHAR(50)
       ,@i_eft_decline_start  VARCHAR(50)
       ,@i_eft_decline_end    VARCHAR(50)
       ,@i_actual_SSN         VARCHAR(50)
       ,@i_prefix             VARCHAR(50)
       ,@i_First_Name         VARCHAR(50)
       ,@i_Middle_Name        VARCHAR(50)
       ,@i_Last_Name          VARCHAR(60)
       ,@i_suffix             VARCHAR(50)
       ,@i_Salutation_Name    VARCHAR(50)
       ,@i_Address_1          VARCHAR(55)
       ,@i_Address_2          VARCHAR(55)
       ,@i_Zip_Code           VARCHAR(50)
       ,@i_City               VARCHAR(50)
       ,@i_State              VARCHAR(50)
       ,@i_Country            VARCHAR(50)
       ,@i_Phone_Number       VARCHAR(50)
       ,@i_Extension          VARCHAR(50)
       ,@i_Other_Phone_Number VARCHAR(50)
       ,@i_Fax_Number         VARCHAR(50)
       ,@i_Email_Address      VARCHAR(50)
       ,@i_birth_date         VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)
       ,@DisplayResults       VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Broker') IS NOT NULL
	DROP TABLE #Broker

CREATE TABLE #Broker
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Broker')
      ,i_agency_gid         VARCHAR(50)       DEFAULT('0')
      ,i_key_2_Gid          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_broker_id          VARCHAR(50)
      ,i_prior_id           VARCHAR(50)
      ,i_Contact_ID         VARCHAR(50)
      ,i_Contact_Date       VARCHAR(50)
      ,i_eff_date           VARCHAR(50)
      ,i_term_date          VARCHAR(50)
      ,i_agency_id          VARCHAR(50)
      ,i_agency_name        VARCHAR(100)
      ,i_pay_dest           VARCHAR(50)
      ,i_hipaa_agree        VARCHAR(50)
      ,i_broker_status      VARCHAR(50)
      ,i_broker_term_reason VARCHAR(50)
      ,i_wnine_onfile       VARCHAR(50)
      ,i_agreement_onfile   VARCHAR(50)
      ,i_w9recieved         VARCHAR(50)
      ,i_Agreement_recieved VARCHAR(50)
      ,i_Vendor_num         VARCHAR(50)
      ,i_lic_state          VARCHAR(50)
      ,i_license            VARCHAR(50)
      ,i_lic_eff_date       VARCHAR(50)
      ,i_lic_term_date      VARCHAR(50)
      ,i_status             VARCHAR(50)
      ,i_term_reason        VARCHAR(50)
      ,i_lob_grouper_id     VARCHAR(50)
      ,i_lob_grouper_desc   VARCHAR(100)
      ,i_custom_lob         VARCHAR(50)
      ,i_carrier_code       VARCHAR(50)
      ,i_carrier_desc       VARCHAR(50)
      ,i_aba_number         VARCHAR(50)
      ,i_fina_institute     VARCHAR(80)
      ,i_bank_phone         VARCHAR(50)
      ,i_account_type       VARCHAR(50)
      ,i_account_number     VARCHAR(50)
      ,i_eft_status         VARCHAR(50)
      ,i_eft_eff_date       VARCHAR(50)
      ,i_eft_decline_reason VARCHAR(50)
      ,i_eft_decline_start  VARCHAR(50)
      ,i_eft_decline_end    VARCHAR(50)
      ,i_actual_SSN         VARCHAR(50)
      ,i_prefix             VARCHAR(50)
      ,i_First_Name         VARCHAR(50)
      ,i_Middle_Name        VARCHAR(50)
      ,i_Last_Name          VARCHAR(60)
      ,i_suffix             VARCHAR(50)
      ,i_Salutation_Name    VARCHAR(50)
      ,i_Address_1          VARCHAR(55)
      ,i_Address_2          VARCHAR(55)
      ,i_Zip_Code           VARCHAR(50)
      ,i_City               VARCHAR(50)
      ,i_State              VARCHAR(50)
      ,i_Country            VARCHAR(50)
      ,i_Phone_Number       VARCHAR(50)
      ,i_Extension          VARCHAR(50)
      ,i_Other_Phone_Number VARCHAR(50)
      ,i_Fax_Number         VARCHAR(50)
      ,i_Email_Address      VARCHAR(50)
      ,i_birth_date         VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,DisplayResults       VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Contacts') IS NOT NULL
	DROP TABLE #Contacts

CREATE TABLE #Contacts
      (social_security	VARCHAR(200)  
      ,prefix 			VARCHAR(200)
      ,first_name		VARCHAR(200)
      ,middle_name 		VARCHAR(200)
      ,last_name		VARCHAR(200)
	  ,suffix			VARCHAR(200)
	  ,salutation		VARCHAR(200)
	  ,blank			VARCHAR(200)
	  ,address1			VARCHAR(200)
	  ,address2			VARCHAR(200)
	  ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
      ,country 			VARCHAR(200) 
	  ,phone			VARCHAR(200)
	  ,extension		VARCHAR(200)
	  ,other_phone		VARCHAR(200)
	  ,fax				VARCHAR(200)
	  ,email			VARCHAR(200)
	  ,birth_date		VARCHAR(200)
      ,status  			INT
      ,Message			VARCHAR(200))  

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Broker
      (SearchID
      ,i_broker_id          
      ,i_prior_id           
      ,i_Contact_ID         
      ,i_Contact_Date       
      ,i_eff_date           
      ,i_term_date          
      ,i_agency_id          
      ,i_pay_dest           
      ,i_hipaa_agree        
      ,i_broker_status      
      ,i_broker_term_reason 
      ,i_wnine_onfile       
      ,i_agreement_onfile   
      ,i_w9recieved         
      ,i_Agreement_recieved 
      ,i_Vendor_num         
      ,i_lic_state          
      ,i_license            
      ,i_lic_eff_date       
      ,i_lic_term_date      
      ,i_status             
      ,i_term_reason        
      ,i_lob_grouper_id     
      ,i_custom_lob         
      ,i_carrier_code       
      ,i_aba_number         
      ,i_bank_phone         
      ,i_account_type       
      ,i_account_number     
      ,i_eft_status         
      ,i_eft_eff_date       
      ,i_eft_decline_reason 
      ,i_eft_decline_start  
      ,i_eft_decline_end    
      ,i_Address_1          
      ,i_Address_2          
      ,i_Zip_Code           
      ,i_City               
      ,i_State              
      ,i_Country            
      ,i_Phone_Number       
      ,i_Extension          
      ,i_Other_Phone_Number 
      ,i_Fax_Number         
      ,i_Email_Address      
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_BrokerID], '')
      ,ISNULL([Common_PriorID#], '')
      ,ISNULL([*Common_ContactID], '')
      ,ISNULL([Common_OriginalContactDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_EffectiveDate], '01/01/1900')
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL([*Common_AgencyID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PaymentDestination]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HIPAAAgreement]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Status]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TerminationReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_W9onfile]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CommissionAgreementonfile]), 'N')
      ,ISNULL([Common_W9ReceivedDate], '01/01/2009')
      ,ISNULL([Common_CommissionAgreementReceivedDate], '01/01/2009')
      ,ISNULL([Common_Vendor#], '')
      ,ISNULL([Common_LicenseState], '')
      ,ISNULL([Common_LicenseID], '')
      ,ISNULL([Common_LicenseEffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Common_LicenseTermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LI_Status]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LI_TerminationReason]), '')
      ,ISNULL([Common_LobGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LOB]), '*')
      ,ISNULL([Common_CarrierID], '')
      ,ISNULL([EFTInfo_ABANumber], '')
      ,ISNULL([EFTInfo_BankPhone#], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_AccountType]), 'C')
      ,ISNULL([EFTInfo_AccountNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_EFTStatus]), '0')
      ,ISNULL([EFTInfo_EFTEffectiveDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_EFTDeclineReason]), '06')
      ,ISNULL([EFTInfo_DeclineStartDate], '01/01/1900')
      ,ISNULL([EFTInfo_DeclineEndDate], '12/31/9999')
      ,ISNULL([ContactInfo_AddressLine1], '')
      ,ISNULL([ContactInfo_AddressLine2], '')
      ,ISNULL([ContactInfo_ZIPCode], '')
      ,ISNULL([ContactInfo_City], '')
      ,ISNULL([ContactInfo_State], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactInfo_Country]), 'US')
      ,ISNULL([ContactInfo_Phone#], '')
      ,ISNULL([ContactInfo_Extension], '')
      ,ISNULL([ContactInfo_OtherPhone#], '')
      ,ISNULL([ContactInfo_Fax#], '')
      ,ISNULL([ContactInfo_EmailAddress], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Broker
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Broker
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Broker_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_agency_gid
       ,i_key_2_Gid
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
       ,iUserID
       ,i_broker_id
       ,i_prior_id
       ,i_Contact_ID
       ,i_Contact_Date
       ,i_eff_date
       ,i_term_date
       ,i_agency_id
       ,i_agency_name
       ,i_pay_dest
       ,i_hipaa_agree
       ,i_broker_status
       ,i_broker_term_reason
       ,i_wnine_onfile
       ,i_agreement_onfile
       ,i_w9recieved
       ,i_Agreement_recieved
       ,i_Vendor_num
       ,i_lic_state
       ,i_license
       ,i_lic_eff_date
       ,i_lic_term_date
       ,i_status
       ,i_term_reason
       ,i_lob_grouper_id
       ,i_lob_grouper_desc
       ,i_custom_lob
       ,i_carrier_code
       ,i_carrier_desc
       ,i_aba_number
       ,i_fina_institute
       ,i_bank_phone
       ,i_account_type
       ,i_account_number
       ,i_eft_status
       ,i_eft_eff_date
       ,i_eft_decline_reason
       ,i_eft_decline_start
       ,i_eft_decline_end
       ,i_actual_SSN
       ,i_prefix
       ,i_First_Name
       ,i_Middle_Name
       ,i_Last_Name
       ,i_suffix
       ,i_Salutation_Name
       ,i_Address_1
       ,i_Address_2
       ,i_Zip_Code
       ,i_City
       ,i_State
       ,i_Country
       ,i_Phone_Number
       ,i_Extension
       ,i_Other_Phone_Number
       ,i_Fax_Number
       ,i_Email_Address
       ,i_birth_date
       ,o_status
       ,o_message
       ,DisplayResults
       ,record_id
       ,static_gid
   FROM #Broker

   OPEN Broker_Cursor
  FETCH NEXT FROM Broker_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_agency_gid
       ,@i_key_2_Gid
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
       ,@iUserID
       ,@i_broker_id
       ,@i_prior_id
       ,@i_Contact_ID
       ,@i_Contact_Date
       ,@i_eff_date
       ,@i_term_date
       ,@i_agency_id
       ,@i_agency_name
       ,@i_pay_dest
       ,@i_hipaa_agree
       ,@i_broker_status
       ,@i_broker_term_reason
       ,@i_wnine_onfile
       ,@i_agreement_onfile
       ,@i_w9recieved
       ,@i_Agreement_recieved
       ,@i_Vendor_num
       ,@i_lic_state
       ,@i_license
       ,@i_lic_eff_date
       ,@i_lic_term_date
       ,@i_status
       ,@i_term_reason
       ,@i_lob_grouper_id
       ,@i_lob_grouper_desc
       ,@i_custom_lob
       ,@i_carrier_code
       ,@i_carrier_desc
       ,@i_aba_number
       ,@i_fina_institute
       ,@i_bank_phone
       ,@i_account_type
       ,@i_account_number
       ,@i_eft_status
       ,@i_eft_eff_date
       ,@i_eft_decline_reason
       ,@i_eft_decline_start
       ,@i_eft_decline_end
       ,@i_actual_SSN
       ,@i_prefix
       ,@i_First_Name
       ,@i_Middle_Name
       ,@i_Last_Name
       ,@i_suffix
       ,@i_Salutation_Name
       ,@i_Address_1
       ,@i_Address_2
       ,@i_Zip_Code
       ,@i_City
       ,@i_State
       ,@i_Country
       ,@i_Phone_Number
       ,@i_Extension
       ,@i_Other_Phone_Number
       ,@i_Fax_Number
       ,@i_Email_Address
       ,@i_birth_date
       ,@o_status
       ,@o_message
       ,@DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get any missing pieces of the address that would normally be populated in the UI, if needed
			TRUNCATE TABLE #Contacts
			IF @i_Contact_ID != ''
				BEGIN

					INSERT INTO #Contacts
					  EXEC prBrokerAddContactTabOff 'BROKER', '', '', @i_Contact_ID, '', '', '', '', '', '', '', '', '', ''
					                                , '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
													, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
													, '', '', '', '', '', '', '', '', '', '', 'ADD', 0, 0, ''
					SELECT TOP 1
					       @i_actual_SSN			= C.social_security
						  ,@i_prefix				= C.prefix
						  ,@i_First_Name			= C.first_name
						  ,@i_Middle_Name			= C.middle_name
						  ,@i_Last_Name				= C.last_name
						  ,@i_suffix				= C.suffix
						  ,@i_Salutation_Name		= C.salutation
						  ,@i_Address_1				= C.address1
						  ,@i_Address_2				= C.address2
						  ,@i_Zip_Code				= C.zip
						  ,@i_City					= C.city
						  ,@i_State					= C.state
						  ,@i_Country				= C.country
						  ,@i_Phone_Number			= C.phone
						  ,@i_Extension				= C.extension
						  ,@i_Other_Phone_Number	= C.other_phone
						  ,@i_Fax_Number			= C.fax
						  ,@i_Email_Address			= C.email
						  ,@i_birth_date			= C.birth_date
					  FROM #Contacts				C

				END

			EXEC dbo.prBrokerAdd
             @i_entity_name
            ,@i_agency_gid
            ,@i_key_2_Gid
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
            ,@iUserID
            ,@i_broker_id
            ,@i_prior_id
            ,@i_Contact_ID
            ,@i_Contact_Date
            ,@i_eff_date
            ,@i_term_date
            ,@i_agency_id
            ,@i_agency_name
            ,@i_pay_dest
            ,@i_hipaa_agree
            ,@i_broker_status
            ,@i_broker_term_reason
            ,@i_wnine_onfile
            ,@i_agreement_onfile
            ,@i_w9recieved
            ,@i_Agreement_recieved
            ,@i_Vendor_num
            ,@i_lic_state
            ,@i_license
            ,@i_lic_eff_date
            ,@i_lic_term_date
            ,@i_status
            ,@i_term_reason
            ,@i_lob_grouper_id
            ,@i_lob_grouper_desc
            ,@i_custom_lob
            ,@i_carrier_code
            ,@i_carrier_desc
            ,@i_aba_number
            ,@i_fina_institute
            ,@i_bank_phone
            ,@i_account_type
            ,@i_account_number
            ,@i_eft_status
            ,@i_eft_eff_date
            ,@i_eft_decline_reason
            ,@i_eft_decline_start
            ,@i_eft_decline_end
            ,@i_actual_SSN
            ,@i_prefix
            ,@i_First_Name
            ,@i_Middle_Name
            ,@i_Last_Name
            ,@i_suffix
            ,@i_Salutation_Name
            ,@i_Address_1
            ,@i_Address_2
            ,@i_Zip_Code
            ,@i_City
            ,@i_State
            ,@i_Country
            ,@i_Phone_Number
            ,@i_Extension
            ,@i_Other_Phone_Number
            ,@i_Fax_Number
            ,@i_Email_Address
            ,@i_birth_date
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
				UPDATE dbo.Contact_Relation 
				   SET contact_relation_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND misc_1					= @i_broker_id
				   AND entity_identifier		= 'BROKER'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_broker_id, @i_Contact_ID, @i_agency_id, @status, @err_num, @err_msg

        FETCH NEXT FROM Broker_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_agency_gid
             ,@i_key_2_Gid
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
             ,@iUserID
             ,@i_broker_id
             ,@i_prior_id
             ,@i_Contact_ID
             ,@i_Contact_Date
             ,@i_eff_date
             ,@i_term_date
             ,@i_agency_id
             ,@i_agency_name
             ,@i_pay_dest
             ,@i_hipaa_agree
             ,@i_broker_status
             ,@i_broker_term_reason
             ,@i_wnine_onfile
             ,@i_agreement_onfile
             ,@i_w9recieved
             ,@i_Agreement_recieved
             ,@i_Vendor_num
             ,@i_lic_state
             ,@i_license
             ,@i_lic_eff_date
             ,@i_lic_term_date
             ,@i_status
             ,@i_term_reason
             ,@i_lob_grouper_id
             ,@i_lob_grouper_desc
             ,@i_custom_lob
             ,@i_carrier_code
             ,@i_carrier_desc
             ,@i_aba_number
             ,@i_fina_institute
             ,@i_bank_phone
             ,@i_account_type
             ,@i_account_number
             ,@i_eft_status
             ,@i_eft_eff_date
             ,@i_eft_decline_reason
             ,@i_eft_decline_start
             ,@i_eft_decline_end
             ,@i_actual_SSN
             ,@i_prefix
             ,@i_First_Name
             ,@i_Middle_Name
             ,@i_Last_Name
             ,@i_suffix
             ,@i_Salutation_Name
             ,@i_Address_1
             ,@i_Address_2
             ,@i_Zip_Code
             ,@i_City
             ,@i_State
             ,@i_Country
             ,@i_Phone_Number
             ,@i_Extension
             ,@i_Other_Phone_Number
             ,@i_Fax_Number
             ,@i_Email_Address
             ,@i_birth_date
             ,@o_status
             ,@o_message
             ,@DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE Broker_Cursor
DEALLOCATE Broker_Cursor

END
GO