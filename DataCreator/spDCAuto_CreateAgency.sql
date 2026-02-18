IF OBJECT_ID('dbo.spDCAuto_CreateAgency') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAgency AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAgency
Purpose:    Create agency data from CorderAutomation
Method:     Agency
Screen GID: 33
Procedure:  dbo.prBH_Add

Date        User            Change
---------------------------------------------------------------------------------------------
11/21/2019	DK				Original procedure
12/10/2019	DK				Add additional GIDs to handle Primary Key violations when setting the GID
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAgency '100-Config%', 22, 'Agency'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAgency
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
	   ,@broker_gid					INT
	   ,@broker_house_gid			INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity                VARCHAR(50)
       ,@i_key_1_field           VARCHAR(50)
       ,@i_key_2_field           VARCHAR(50)
       ,@i_key_3_field           VARCHAR(50)
       ,@i_key_4_field           VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(50)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(10)
       ,@i_date_modified         VARCHAR(20)
       ,@iUserID                 VARCHAR(25)
       ,@i_Agency_ID             VARCHAR(50)
       ,@i_Agency_name           VARCHAR(100)
       ,@i_DBA                   VARCHAR(50)
       ,@i_Business_Type         VARCHAR(50)
       ,@i_Tax_Type              VARCHAR(50)
       ,@i_Tax_id                VARCHAR(50)
       ,@i_other_id              VARCHAR(50)
       ,@i_effective_date        VARCHAR(50)
       ,@i_termination_date      VARCHAR(50)
       ,@i_payment_dest          VARCHAR(50)
       ,@i_agency_status         VARCHAR(50)
       ,@i_agency_term_reason    VARCHAR(50)
       ,@i_suppress_check        VARCHAR(50)
       ,@i_lic_state             VARCHAR(50)
       ,@i_lic_id                VARCHAR(50)
       ,@i_lic_eff_date          VARCHAR(50)
       ,@i_lic_term_date         VARCHAR(50)
       ,@i_status                VARCHAR(50)
       ,@i_term_reason           VARCHAR(50)
       ,@i_lob_grouper_id        VARCHAR(50)
       ,@i_lob_grouper_desc      VARCHAR(100)
       ,@i_custom_lob            VARCHAR(50)
       ,@i_carrier_code          VARCHAR(50)
       ,@i_carrier_desc          VARCHAR(50)
       ,@i_aba_number            VARCHAR(50)
       ,@i_financial_institution VARCHAR(80)
       ,@i_bank_phone            VARCHAR(50)
       ,@i_account_type          VARCHAR(50)
       ,@i_account_number        VARCHAR(50)
       ,@i_eft_status            VARCHAR(50)
       ,@i_eft_eff_date          VARCHAR(50)
       ,@i_eft_decline_reason    VARCHAR(50)
       ,@i_eft_decline_start     VARCHAR(50)
       ,@i_eft_decline_end       VARCHAR(50)
       ,@i_Address_1             VARCHAR(55)
       ,@i_Address_2             VARCHAR(55)
       ,@i_Zip_Code              VARCHAR(50)
       ,@i_City                  VARCHAR(50)
       ,@i_State                 VARCHAR(50)
       ,@i_Country               VARCHAR(50)
       ,@i_C_phone               VARCHAR(50)
       ,@i_C_ext                 VARCHAR(50)
       ,@i_C_other_phone         VARCHAR(50)
       ,@i_C_fax                 VARCHAR(50)
       ,@i_C_email               VARCHAR(50)
       ,@i_broker_ID             VARCHAR(50)
       ,@i_prior_id              VARCHAR(50)
       ,@i_Contact_ID            VARCHAR(50)
       ,@i_SSN                   VARCHAR(50)
       ,@i_prefix                VARCHAR(50)
       ,@i_first_name            VARCHAR(50)
       ,@i_middle_name           VARCHAR(50)
       ,@i_last_name             VARCHAR(60)
       ,@i_suffix                VARCHAR(50)
       ,@i_nickname              VARCHAR(50)
       ,@i_DOB                   VARCHAR(50)
       ,@i_hipaa_agree           VARCHAR(50)
       ,@i_wnine_onfile          VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Agency') IS NOT NULL
	DROP TABLE #Agency

CREATE TABLE #Agency
      (SearchID                VARCHAR(200)
      ,i_entity                VARCHAR(50)       DEFAULT('Broker_House')
      ,i_key_1_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_modified         VARCHAR(20)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_Agency_ID             VARCHAR(50)
      ,i_Agency_name           VARCHAR(100)
      ,i_DBA                   VARCHAR(50)
      ,i_Business_Type         VARCHAR(50)
      ,i_Tax_Type              VARCHAR(50)
      ,i_Tax_id                VARCHAR(50)
      ,i_other_id              VARCHAR(50)
      ,i_effective_date        VARCHAR(50)
      ,i_termination_date      VARCHAR(50)
      ,i_payment_dest          VARCHAR(50)
      ,i_agency_status         VARCHAR(50)
      ,i_agency_term_reason    VARCHAR(50)
      ,i_suppress_check        VARCHAR(50)
      ,i_lic_state             VARCHAR(50)
      ,i_lic_id                VARCHAR(50)
      ,i_lic_eff_date          VARCHAR(50)
      ,i_lic_term_date         VARCHAR(50)
      ,i_status                VARCHAR(50)
      ,i_term_reason           VARCHAR(50)
      ,i_lob_grouper_id        VARCHAR(50)
      ,i_lob_grouper_desc      VARCHAR(100)
      ,i_custom_lob            VARCHAR(50)
      ,i_carrier_code          VARCHAR(50)
      ,i_carrier_desc          VARCHAR(50)
      ,i_aba_number            VARCHAR(50)
      ,i_financial_institution VARCHAR(80)
      ,i_bank_phone            VARCHAR(50)
      ,i_account_type          VARCHAR(50)
      ,i_account_number        VARCHAR(50)
      ,i_eft_status            VARCHAR(50)
      ,i_eft_eff_date          VARCHAR(50)
      ,i_eft_decline_reason    VARCHAR(50)
      ,i_eft_decline_start     VARCHAR(50)
      ,i_eft_decline_end       VARCHAR(50)
      ,i_Address_1             VARCHAR(55)
      ,i_Address_2             VARCHAR(55)
      ,i_Zip_Code              VARCHAR(50)
      ,i_City                  VARCHAR(50)
      ,i_State                 VARCHAR(50)
      ,i_Country               VARCHAR(50)
      ,i_C_phone               VARCHAR(50)
      ,i_C_ext                 VARCHAR(50)
      ,i_C_other_phone         VARCHAR(50)
      ,i_C_fax                 VARCHAR(50)
      ,i_C_email               VARCHAR(50)
      ,i_broker_ID             VARCHAR(50)
      ,i_prior_id              VARCHAR(50)
      ,i_Contact_ID            VARCHAR(50)
      ,i_SSN                   VARCHAR(50)
      ,i_prefix                VARCHAR(50)
      ,i_first_name            VARCHAR(50)
      ,i_middle_name           VARCHAR(50)
      ,i_last_name             VARCHAR(60)
      ,i_suffix                VARCHAR(50)
      ,i_nickname              VARCHAR(50)
      ,i_DOB                   VARCHAR(50)
      ,i_hipaa_agree           VARCHAR(50)	DEFAULT('N')
      ,i_wnine_onfile          VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(100)
      ,record_id               INT
      ,static_gid              INT)

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (location_id		VARCHAR(200)  
      ,location_name 	VARCHAR(200)
      ,address_1		VARCHAR(200)
      ,address_2   		VARCHAR(200)
      ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
      ,County  			VARCHAR(200)
      ,Country 			VARCHAR(200) 
      ,status  			INT
      ,Message			VARCHAR(200))  

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Agency
      (SearchID
      ,i_Agency_ID             
      ,i_Agency_name           
      ,i_DBA                   
      ,i_Business_Type         
      ,i_Tax_Type              
      ,i_Tax_id                
      ,i_other_id              
      ,i_effective_date        
      ,i_termination_date      
      ,i_payment_dest          
      ,i_agency_status         
      ,i_agency_term_reason    
      ,i_suppress_check        
      ,i_lic_state             
      ,i_lic_id                
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
      ,i_C_phone               
      ,i_C_ext                 
      ,i_C_other_phone         
      ,i_C_fax                 
      ,i_C_email               
      ,i_broker_ID             
      ,i_prior_id              
      ,i_Contact_ID        
      ,i_wnine_onfile          
      ,record_id
      ,static_gid)
SELECT ISNULL([SearchID], '')
      ,ISNULL([*Common_AgencyID], '')
      ,ISNULL([*Common_AgencyName], '')
      ,ISNULL([Common_DBA], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BusinessType]), 'O')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TaxType]), 'N')
      ,ISNULL([*Common_TaxID], '')
      ,ISNULL([Common_PriorID], '')
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PaymentDestination]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Status]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_TerminationReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SuppressCheck]), 'N')
      ,ISNULL([Common_LicenseState], '')
      ,ISNULL([Common_LicenseID], '')
      ,ISNULL([Common_LicenseEffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Common_LicenseTermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LicenseStatus]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LicenseTerminationReason]), '')
      ,ISNULL([Common_LobGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LOB]), '*')
      ,ISNULL([Common_CarrierID], '')
      ,ISNULL([EFTInfo_ABANumber], '')
      ,ISNULL([EFTInfo_BankPhone], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_AccountType]), 'C')
      ,ISNULL([EFTInfo_AccountNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_EFTStatus]), '0')
      ,ISNULL([EFTInfo_EFTEffectiveDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTInfo_EFTDeclineReason]), '06')
      ,ISNULL([EFTInfo_DeclineStartDate], '01/01/1900')
      ,ISNULL([EFTInfo_DeclineEndDate], '12/31/9999')
      ,ISNULL([*ContactInfo_AddressLine1], '')
      ,ISNULL([ContactInfo_AddressLine2], '')
      ,ISNULL([*ContactInfo_ZipCode], '')
      ,ISNULL([*ContactInfo_City], '')
      ,ISNULL([ContactInfo_State], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactInfo_Country]), 'US')
      ,ISNULL([ContactInfo_Phone], '')
      ,ISNULL([ContactInfo_Extension], '')
      ,ISNULL([ContactInfo_OtherPhone], '')
      ,ISNULL([ContactInfo_Fax], '')
      ,ISNULL([ContactInfo_EmailAddress], '')
      ,ISNULL([BrokerInfo_BrokerID], '')
      ,ISNULL([BrokerInfo_PriorID], '')
      ,ISNULL([BrokerInfo_ContactID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BrokerInfo_W9OnFile]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Agency
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Agency
   SET iUserID  = @user

UPDATE #Agency
   SET i_lic_state = '**'
 WHERE i_lic_state = '*Any'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Agency_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity
       ,i_key_1_field
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
       ,i_date_modified
       ,iUserID
       ,i_Agency_ID
       ,i_Agency_name
       ,i_DBA
       ,i_Business_Type
       ,i_Tax_Type
       ,i_Tax_id
       ,i_other_id
       ,i_effective_date
       ,i_termination_date
       ,i_payment_dest
       ,i_agency_status
       ,i_agency_term_reason
       ,i_suppress_check
       ,i_lic_state
       ,i_lic_id
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
       ,i_financial_institution
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
       ,i_C_phone
       ,i_C_ext
       ,i_C_other_phone
       ,i_C_fax
       ,i_C_email
       ,i_broker_ID
       ,i_prior_id
       ,i_Contact_ID
       ,i_SSN
       ,i_prefix
       ,i_first_name
       ,i_middle_name
       ,i_last_name
       ,i_suffix
       ,i_nickname
       ,i_DOB
       ,i_hipaa_agree
       ,i_wnine_onfile
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Agency

   OPEN Agency_Cursor
  FETCH NEXT FROM Agency_Cursor
   INTO @SearchID
       ,@i_entity
       ,@i_key_1_field
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
       ,@i_date_modified
       ,@iUserID
       ,@i_Agency_ID
       ,@i_Agency_name
       ,@i_DBA
       ,@i_Business_Type
       ,@i_Tax_Type
       ,@i_Tax_id
       ,@i_other_id
       ,@i_effective_date
       ,@i_termination_date
       ,@i_payment_dest
       ,@i_agency_status
       ,@i_agency_term_reason
       ,@i_suppress_check
       ,@i_lic_state
       ,@i_lic_id
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
       ,@i_financial_institution
       ,@i_bank_phone
       ,@i_account_type
       ,@i_account_number
       ,@i_eft_status
       ,@i_eft_eff_date
       ,@i_eft_decline_reason
       ,@i_eft_decline_start
       ,@i_eft_decline_end
       ,@i_Address_1
       ,@i_Address_2
       ,@i_Zip_Code
       ,@i_City
       ,@i_State
       ,@i_Country
       ,@i_C_phone
       ,@i_C_ext
       ,@i_C_other_phone
       ,@i_C_fax
       ,@i_C_email
       ,@i_broker_ID
       ,@i_prior_id
       ,@i_Contact_ID
       ,@i_SSN
       ,@i_prefix
       ,@i_first_name
       ,@i_middle_name
       ,@i_last_name
       ,@i_suffix
       ,@i_nickname
       ,@i_DOB
       ,@i_hipaa_agree
       ,@i_wnine_onfile
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get any missing pieces of the address that would normally be populated in the UI, if needed
			TRUNCATE TABLE #Addresses
			IF @i_Zip_Code != ''
				BEGIN

					INSERT INTO #Addresses
					  EXEC prPMProvLocTabOff 'Zip', '', '', '', '', @i_Zip_Code, '', '', '', '', 'ADD', 0, 0, ''

					IF @i_city = '' OR @i_state = '' OR @i_country = ''
						BEGIN
							SELECT @i_city		= CASE WHEN @i_city = ''	THEN A.city		ELSE @i_city END
								  ,@i_state		= CASE WHEN @i_state = ''	THEN A.state	ELSE @i_state END
								  ,@i_country	= CASE WHEN @i_country = ''	THEN A.Country	ELSE @i_country END
							  FROM #Addresses	A
							 WHERE zip			= @i_Zip_Code
						END

				END

			EXEC dbo.prBH_Add
             @i_entity
            ,@i_key_1_field
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
            ,@i_date_modified
            ,@iUserID
            ,@i_Agency_ID
            ,@i_Agency_name
            ,@i_DBA
            ,@i_Business_Type
            ,@i_Tax_Type
            ,@i_Tax_id
            ,@i_other_id
            ,@i_effective_date
            ,@i_termination_date
            ,@i_payment_dest
            ,@i_agency_status
            ,@i_agency_term_reason
            ,@i_suppress_check
            ,@i_lic_state
            ,@i_lic_id
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
            ,@i_financial_institution
            ,@i_bank_phone
            ,@i_account_type
            ,@i_account_number
            ,@i_eft_status
            ,@i_eft_eff_date
            ,@i_eft_decline_reason
            ,@i_eft_decline_start
            ,@i_eft_decline_end
            ,@i_Address_1
            ,@i_Address_2
            ,@i_Zip_Code
            ,@i_City
            ,@i_State
            ,@i_Country
            ,@i_C_phone
            ,@i_C_ext
            ,@i_C_other_phone
            ,@i_C_fax
            ,@i_C_email
            ,@i_broker_ID
            ,@i_prior_id
            ,@i_Contact_ID
            ,@i_SSN
            ,@i_prefix
            ,@i_first_name
            ,@i_middle_name
            ,@i_last_name
            ,@i_suffix
            ,@i_nickname
            ,@i_DOB
            ,@i_hipaa_agree
            ,@i_wnine_onfile
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the Contact GID
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- WHen a broker is created along with the agency, create a unique broker gid
				SET @broker_gid			= @static_gid	+ 1000000
				SET @broker_house_gid	= @static_gid	+ 2000000

				-- Get the current contact gid
				SELECT @current_gid				= A.Agency_GID
				  FROM dbo.Agency				A
				 WHERE record_status			= 'A'
				   AND A.Agency_ID				= @i_Agency_ID

				UPDATE Broker_License
				   SET Parent_gid				= CASE WHEN entity_identifier = 'BROKER_HOUSE'	THEN @broker_house_gid
				                                       WHEN entity_identifier = 'BROKER'		THEN @broker_gid 
													   ELSE @static_gid 
												   END
				      ,entity_gid				= @static_gid
					  ,License_gid				= CASE WHEN entity_identifier = 'BROKER_HOUSE'	THEN @broker_house_gid
				                                       WHEN entity_identifier = 'BROKER'		THEN @broker_gid 
													   ELSE @static_gid 
												   END
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid

				UPDATE dbo.Contact_Relation 
				   SET contact_relation_gid		= CASE WHEN entity_identifier = 'BROKER_HOUSE'	THEN @broker_house_gid
				                                       WHEN entity_identifier = 'BROKER'		THEN @broker_gid 
													   ELSE @static_gid 
												   END
					  ,entity_gid				= @static_gid
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid

				-- Update the Agency data with the static gid
				UPDATE dbo.Agency 
				   SET Agency_GID				= @static_gid 
				 WHERE record_status			= 'A'
				   AND Agency_GID				= @current_gid

				-- Get the current demographic gid
				SELECT @current_gid				= CR.demographic_gid
				  FROM dbo.Contact_Relation		CR
				 WHERE CR.entity_gid			= @static_gid

				-- Update the demographic_gid
				UPDATE dbo.Demographics 
				   SET demographic_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @current_gid

				UPDATE dbo.Contact_Relation
				   SET demographic_gid			= @static_gid
				 WHERE demographic_gid			= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Agency_ID, @i_Agency_name, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Agency_Cursor
         INTO @SearchID
             ,@i_entity
             ,@i_key_1_field
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
             ,@i_date_modified
             ,@iUserID
             ,@i_Agency_ID
             ,@i_Agency_name
             ,@i_DBA
             ,@i_Business_Type
             ,@i_Tax_Type
             ,@i_Tax_id
             ,@i_other_id
             ,@i_effective_date
             ,@i_termination_date
             ,@i_payment_dest
             ,@i_agency_status
             ,@i_agency_term_reason
             ,@i_suppress_check
             ,@i_lic_state
             ,@i_lic_id
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
             ,@i_financial_institution
             ,@i_bank_phone
             ,@i_account_type
             ,@i_account_number
             ,@i_eft_status
             ,@i_eft_eff_date
             ,@i_eft_decline_reason
             ,@i_eft_decline_start
             ,@i_eft_decline_end
             ,@i_Address_1
             ,@i_Address_2
             ,@i_Zip_Code
             ,@i_City
             ,@i_State
             ,@i_Country
             ,@i_C_phone
             ,@i_C_ext
             ,@i_C_other_phone
             ,@i_C_fax
             ,@i_C_email
             ,@i_broker_ID
             ,@i_prior_id
             ,@i_Contact_ID
             ,@i_SSN
             ,@i_prefix
             ,@i_first_name
             ,@i_middle_name
             ,@i_last_name
             ,@i_suffix
             ,@i_nickname
             ,@i_DOB
             ,@i_hipaa_agree
             ,@i_wnine_onfile
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Agency_Cursor
DEALLOCATE Agency_Cursor

END
GO