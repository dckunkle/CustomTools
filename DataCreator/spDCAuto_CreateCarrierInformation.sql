IF OBJECT_ID('dbo.spDCAuto_CreateCarrierInformation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCarrierInformation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCarrierInformation
Purpose:    Create carrierinformation data from CorderAutomation
Method:     CarrierInformation
Screen GID: 18
Procedure:  dbo.prOtherCarrierMaint

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCarrierInformation '100-Config%', 22, 'CarrierInformation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCarrierInformation
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
	   ,@physical_gid				INT
	   ,@payment_gid				INT
	   ,@billing_gid				INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_other_carrier_gid  VARCHAR(50)
       ,@i_eff_date           VARCHAR(50)
       ,@i_term_date          VARCHAR(50)
       ,@i_relation_gid       VARCHAR(50)
       ,@i_pay_relation_gid   VARCHAR(50)
       ,@i_bill_relation_gid  VARCHAR(50)
       ,@i_demographic_gid    VARCHAR(50)
       ,@i_pay_demo_gid       VARCHAR(50)
       ,@i_bill_demo_gid      VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@i_carrier_code       VARCHAR(50)
       ,@i_full_name          VARCHAR(50)
       ,@i_short_name         VARCHAR(50)
       ,@i_location           VARCHAR(50)
       ,@i_address1           VARCHAR(55)
       ,@i_address2           VARCHAR(55)
       ,@i_zip_code           VARCHAR(50)
       ,@i_city               VARCHAR(50)
       ,@i_state              VARCHAR(50)
       ,@i_country            VARCHAR(50)
       ,@i_phone              VARCHAR(50)
       ,@i_email_address      VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_tax_id_number      VARCHAR(50)
       ,@i_produce_1099       VARCHAR(50)
       ,@i_vendor_code        VARCHAR(50)
       ,@i_pay_first_name     VARCHAR(50)
       ,@i_pay_last_name      VARCHAR(50)
       ,@i_pay_phone          VARCHAR(50)
       ,@i_pay_email          VARCHAR(50)
       ,@i_pay_address1       VARCHAR(55)
       ,@i_pay_address2       VARCHAR(55)
       ,@i_pay_zip_code       VARCHAR(50)
       ,@i_pay_city           VARCHAR(50)
       ,@i_pay_state          VARCHAR(50)
       ,@i_pay_country        VARCHAR(50)
       ,@i_eft_status         VARCHAR(50)
       ,@i_account_type       VARCHAR(50)
       ,@i_aba_number         VARCHAR(50)
       ,@i_bank_name          VARCHAR(80)
       ,@i_account_number     VARCHAR(50)
       ,@i_account_name       VARCHAR(100)
       ,@i_bill_first_name    VARCHAR(50)
       ,@i_bill_last_name     VARCHAR(50)
       ,@i_bill_phone         VARCHAR(50)
       ,@i_bill_email         VARCHAR(50)
       ,@i_bill_address1      VARCHAR(55)
       ,@i_bill_address2      VARCHAR(55)
       ,@i_bill_zip_code      VARCHAR(50)
       ,@i_bill_city          VARCHAR(50)
       ,@i_bill_state         VARCHAR(50)
       ,@i_bill_country       VARCHAR(50)
       ,@i_bill_calendar_id   VARCHAR(50)
       ,@i_bill_calendar_desc VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CarrierInformation') IS NOT NULL
	DROP TABLE #CarrierInformation

CREATE TABLE #CarrierInformation
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Carrier_Information')
      ,i_other_carrier_gid  VARCHAR(50)       DEFAULT('0')
      ,i_eff_date           VARCHAR(50)       DEFAULT('0')
      ,i_term_date          VARCHAR(50)       DEFAULT('0')
      ,i_relation_gid       VARCHAR(50)       DEFAULT('0')
      ,i_pay_relation_gid   VARCHAR(50)       DEFAULT('0')
      ,i_bill_relation_gid  VARCHAR(50)       DEFAULT('0')
      ,i_demographic_gid    VARCHAR(50)       DEFAULT('0')
      ,i_pay_demo_gid       VARCHAR(50)       DEFAULT('0')
      ,i_bill_demo_gid      VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_carrier_code       VARCHAR(50)
      ,i_full_name          VARCHAR(50)
      ,i_short_name         VARCHAR(50)
      ,i_location           VARCHAR(50)
      ,i_address1           VARCHAR(55)
      ,i_address2           VARCHAR(55)
      ,i_zip_code           VARCHAR(50)
      ,i_city               VARCHAR(50)
      ,i_state              VARCHAR(50)
      ,i_country            VARCHAR(50)
      ,i_phone              VARCHAR(50)
      ,i_email_address      VARCHAR(50)
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_tax_id_number      VARCHAR(50)
      ,i_produce_1099       VARCHAR(50)
      ,i_vendor_code        VARCHAR(50)
      ,i_pay_first_name     VARCHAR(50)
      ,i_pay_last_name      VARCHAR(50)
      ,i_pay_phone          VARCHAR(50)
      ,i_pay_email          VARCHAR(50)
      ,i_pay_address1       VARCHAR(55)
      ,i_pay_address2       VARCHAR(55)
      ,i_pay_zip_code       VARCHAR(50)
      ,i_pay_city           VARCHAR(50)
      ,i_pay_state          VARCHAR(50)
      ,i_pay_country        VARCHAR(50)
      ,i_eft_status         VARCHAR(50)
      ,i_account_type       VARCHAR(50)
      ,i_aba_number         VARCHAR(50)
      ,i_bank_name          VARCHAR(80)
      ,i_account_number     VARCHAR(50)
      ,i_account_name       VARCHAR(100)
      ,i_bill_first_name    VARCHAR(50)
      ,i_bill_last_name     VARCHAR(50)
      ,i_bill_phone         VARCHAR(50)
      ,i_bill_email         VARCHAR(50)
      ,i_bill_address1      VARCHAR(55)
      ,i_bill_address2      VARCHAR(55)
      ,i_bill_zip_code      VARCHAR(50)
      ,i_bill_city          VARCHAR(50)
      ,i_bill_state         VARCHAR(50)
      ,i_bill_country       VARCHAR(50)
      ,i_bill_calendar_id   VARCHAR(50)
      ,i_bill_calendar_desc VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CarrierInformation
      (SearchID
      ,i_carrier_code       
      ,i_full_name          
      ,i_short_name         
      ,i_location           
      ,i_address1           
      ,i_address2           
      ,i_zip_code           
      ,i_city               
      ,i_state              
      ,i_country            
      ,i_phone              
      ,i_email_address      
      ,i_effective_date     
      ,i_termination_date   
      ,i_tax_id_number      
      ,i_produce_1099       
      ,i_vendor_code        
      ,i_pay_first_name     
      ,i_pay_last_name      
      ,i_pay_phone          
      ,i_pay_email          
      ,i_pay_address1       
      ,i_pay_address2       
      ,i_pay_zip_code       
      ,i_pay_city           
      ,i_pay_state          
      ,i_pay_country        
      ,i_eft_status         
      ,i_account_type       
      ,i_aba_number         
      ,i_account_number     
      ,i_account_name       
      ,i_bill_first_name    
      ,i_bill_last_name     
      ,i_bill_phone         
      ,i_bill_email         
      ,i_bill_address1      
      ,i_bill_address2      
      ,i_bill_zip_code      
      ,i_bill_city          
      ,i_bill_state         
      ,i_bill_country       
      ,i_bill_calendar_id   
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_CarrierID], '')
      ,ISNULL([*Common_CarrierName], '')
      ,ISNULL([*Common_ShortName], '')
      ,ISNULL([Common_Location], '')
      ,ISNULL([Common_AddressLine1], '')
      ,ISNULL([Common_AddressLine2], '')
      ,ISNULL([Common_ZipCode], '')
      ,ISNULL([Common_City], '')
      ,ISNULL([Common_State], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Country]), 'US')
      ,ISNULL([Common_Phone#], '0000000000')
      ,ISNULL([Common_Email], '')
      ,ISNULL([Common_EffectiveDate], '01/01/1900')
      ,ISNULL([Common_TerminationDate], '12/31/9999')
      ,ISNULL([Common_TaxIDNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Produce1099]), 'N')
      ,ISNULL([Common_VendorCode], '')
      ,ISNULL([PayInfo_PaymentContactFirstName], '')
      ,ISNULL([PayInfo_PaymentContactLastName], '')
      ,ISNULL([PayInfo_PaymentContactPhone], '')
      ,ISNULL([PayInfo_PaymentContactEmail], '')
      ,ISNULL([PayInfo_PaymentAddressLine1], '')
      ,ISNULL([PayInfo_PaymentAddressLine2], '')
      ,ISNULL([PayInfo_PaymentZipCode], '')
      ,ISNULL([PayInfo_PaymentCity], '')
      ,ISNULL([PayInfo_PaymentState], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PayInfo_PaymentCountry]), 'US')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PayInfo_EFTActive]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PayInfo_AccountType]), 'C')
      ,ISNULL([PayInfo_ABANumber], '')
      ,ISNULL([PayInfo_AccountNumber], '')
      ,ISNULL([PayInfo_NameOnAccount], '')
      ,ISNULL([BillingInfo_BillingContactFirstName], '')
      ,ISNULL([BillingInfo_BillingContactLastName], '')
      ,ISNULL([BillingInfo_BillingContactPhone], '')
      ,ISNULL([BillingInfo_BillingContactEmail], '')
      ,ISNULL([BillingInfo_BillingAddressLine1], '')
      ,ISNULL([BillingInfo_BillingAddressLine2], '')
      ,ISNULL([BillingInfo_BillingZipCode], '')
      ,ISNULL([BillingInfo_BillingCity], '')
      ,ISNULL([BillingInfo_BilllingState], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BillingInfo_BillingCountry]), 'US')
      ,ISNULL([BillingInfo_BillingCalendarID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CarrierInformation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CarrierInformation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CarrierInformation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_other_carrier_gid
       ,i_eff_date
       ,i_term_date
       ,i_relation_gid
       ,i_pay_relation_gid
       ,i_bill_relation_gid
       ,i_demographic_gid
       ,i_pay_demo_gid
       ,i_bill_demo_gid
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_carrier_code
       ,i_full_name
       ,i_short_name
       ,i_location
       ,i_address1
       ,i_address2
       ,i_zip_code
       ,i_city
       ,i_state
       ,i_country
       ,i_phone
       ,i_email_address
       ,i_effective_date
       ,i_termination_date
       ,i_tax_id_number
       ,i_produce_1099
       ,i_vendor_code
       ,i_pay_first_name
       ,i_pay_last_name
       ,i_pay_phone
       ,i_pay_email
       ,i_pay_address1
       ,i_pay_address2
       ,i_pay_zip_code
       ,i_pay_city
       ,i_pay_state
       ,i_pay_country
       ,i_eft_status
       ,i_account_type
       ,i_aba_number
       ,i_bank_name
       ,i_account_number
       ,i_account_name
       ,i_bill_first_name
       ,i_bill_last_name
       ,i_bill_phone
       ,i_bill_email
       ,i_bill_address1
       ,i_bill_address2
       ,i_bill_zip_code
       ,i_bill_city
       ,i_bill_state
       ,i_bill_country
       ,i_bill_calendar_id
       ,i_bill_calendar_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CarrierInformation

   OPEN CarrierInformation_Cursor
  FETCH NEXT FROM CarrierInformation_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_other_carrier_gid
       ,@i_eff_date
       ,@i_term_date
       ,@i_relation_gid
       ,@i_pay_relation_gid
       ,@i_bill_relation_gid
       ,@i_demographic_gid
       ,@i_pay_demo_gid
       ,@i_bill_demo_gid
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_carrier_code
       ,@i_full_name
       ,@i_short_name
       ,@i_location
       ,@i_address1
       ,@i_address2
       ,@i_zip_code
       ,@i_city
       ,@i_state
       ,@i_country
       ,@i_phone
       ,@i_email_address
       ,@i_effective_date
       ,@i_termination_date
       ,@i_tax_id_number
       ,@i_produce_1099
       ,@i_vendor_code
       ,@i_pay_first_name
       ,@i_pay_last_name
       ,@i_pay_phone
       ,@i_pay_email
       ,@i_pay_address1
       ,@i_pay_address2
       ,@i_pay_zip_code
       ,@i_pay_city
       ,@i_pay_state
       ,@i_pay_country
       ,@i_eft_status
       ,@i_account_type
       ,@i_aba_number
       ,@i_bank_name
       ,@i_account_number
       ,@i_account_name
       ,@i_bill_first_name
       ,@i_bill_last_name
       ,@i_bill_phone
       ,@i_bill_email
       ,@i_bill_address1
       ,@i_bill_address2
       ,@i_bill_zip_code
       ,@i_bill_city
       ,@i_bill_state
       ,@i_bill_country
       ,@i_bill_calendar_id
       ,@i_bill_calendar_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prOtherCarrierMaint
             @i_entity_name
            ,@i_other_carrier_gid
            ,@i_eff_date
            ,@i_term_date
            ,@i_relation_gid
            ,@i_pay_relation_gid
            ,@i_bill_relation_gid
            ,@i_demographic_gid
            ,@i_pay_demo_gid
            ,@i_bill_demo_gid
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_carrier_code
            ,@i_full_name
            ,@i_short_name
            ,@i_location
            ,@i_address1
            ,@i_address2
            ,@i_zip_code
            ,@i_city
            ,@i_state
            ,@i_country
            ,@i_phone
            ,@i_email_address
            ,@i_effective_date
            ,@i_termination_date
            ,@i_tax_id_number
            ,@i_produce_1099
            ,@i_vendor_code
            ,@i_pay_first_name
            ,@i_pay_last_name
            ,@i_pay_phone
            ,@i_pay_email
            ,@i_pay_address1
            ,@i_pay_address2
            ,@i_pay_zip_code
            ,@i_pay_city
            ,@i_pay_state
            ,@i_pay_country
            ,@i_eft_status
            ,@i_account_type
            ,@i_aba_number
            ,@i_bank_name
            ,@i_account_number
            ,@i_account_name
            ,@i_bill_first_name
            ,@i_bill_last_name
            ,@i_bill_phone
            ,@i_bill_email
            ,@i_bill_address1
            ,@i_bill_address2
            ,@i_bill_zip_code
            ,@i_bill_city
            ,@i_bill_state
            ,@i_bill_country
            ,@i_bill_calendar_id
            ,@i_bill_calendar_desc
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

				-- Generate unique gids for the different contact types to avoid PK errors
				SELECT @physical_gid	= @static_gid + 1000000
				      ,@payment_gid		= @static_gid + 2000000
					  ,@billing_gid		= @static_gid + 3000000

				-- Get the current gid
				SELECT @current_gid				= CI.other_carrier_gid
				  FROM dbo.Carrier_Information	CI
				 WHERE record_status			= 'A'
				   AND CI.other_carrier_code	= @i_carrier_code

				-- Update to the static gid
				UPDATE dbo.Contact_Relation 
				   SET contact_relation_gid		= @physical_gid 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid
				   AND contact_purpose_flag		= 'PHYS'

				-- Update to the static gid
				UPDATE dbo.Contact_Relation 
				   SET contact_relation_gid		= @payment_gid 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid
				   AND contact_purpose_flag		= 'PAY'

				-- Update to the static gid
				UPDATE dbo.Contact_Relation 
				   SET contact_relation_gid		= @billing_gid 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid
				   AND contact_purpose_flag		= 'BILL'

				-- Update to the static gid
				UPDATE dbo.Contact_Relation 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @current_gid
				   
				UPDATE dbo.Carrier_Information	
				   SET other_carrier_gid		= @static_gid
				 WHERE other_carrier_gid		= @current_gid
				   AND record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_carrier_code, '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CarrierInformation_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_other_carrier_gid
             ,@i_eff_date
             ,@i_term_date
             ,@i_relation_gid
             ,@i_pay_relation_gid
             ,@i_bill_relation_gid
             ,@i_demographic_gid
             ,@i_pay_demo_gid
             ,@i_bill_demo_gid
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_carrier_code
             ,@i_full_name
             ,@i_short_name
             ,@i_location
             ,@i_address1
             ,@i_address2
             ,@i_zip_code
             ,@i_city
             ,@i_state
             ,@i_country
             ,@i_phone
             ,@i_email_address
             ,@i_effective_date
             ,@i_termination_date
             ,@i_tax_id_number
             ,@i_produce_1099
             ,@i_vendor_code
             ,@i_pay_first_name
             ,@i_pay_last_name
             ,@i_pay_phone
             ,@i_pay_email
             ,@i_pay_address1
             ,@i_pay_address2
             ,@i_pay_zip_code
             ,@i_pay_city
             ,@i_pay_state
             ,@i_pay_country
             ,@i_eft_status
             ,@i_account_type
             ,@i_aba_number
             ,@i_bank_name
             ,@i_account_number
             ,@i_account_name
             ,@i_bill_first_name
             ,@i_bill_last_name
             ,@i_bill_phone
             ,@i_bill_email
             ,@i_bill_address1
             ,@i_bill_address2
             ,@i_bill_zip_code
             ,@i_bill_city
             ,@i_bill_state
             ,@i_bill_country
             ,@i_bill_calendar_id
             ,@i_bill_calendar_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CarrierInformation_Cursor
DEALLOCATE CarrierInformation_Cursor

END
GO