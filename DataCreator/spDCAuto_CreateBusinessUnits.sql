IF OBJECT_ID('dbo.spDCAuto_CreateBusinessUnits') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBusinessUnits AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnits
Purpose:    Create businessunits data from CorderAutomation
Method:     BusinessUnits
Screen GID: 2005
Procedure:  dbo.prPMBusinessUnitAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/14/2019	DK				Original procedure
03/24/2021	DK				Added Payment Destination (SP45)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnits 'RFF-Int-Config-1%', 22, 'RFF-Int-Config-1000','BusinessUnits','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnits
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

DECLARE @i_entity_name              VARCHAR(50)
       ,@i_key_1_field              VARCHAR(50)
       ,@i_key_2_field              VARCHAR(20)
       ,@i_key_3_field              VARCHAR(20)
       ,@i_key_4_field              VARCHAR(200)
       ,@i_key_5_field              VARCHAR(100)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(10)
       ,@i_date_time_modified       VARCHAR(20)
       ,@iUserID                    VARCHAR(25)
       ,@i_BU_business_unit_id      VARCHAR(50)
       ,@i_BU_npi_id                VARCHAR(50)
       ,@i_BU_npi_verif             VARCHAR(50)
       ,@i_BU_business_name         VARCHAR(100)
       ,@i_BU_business_type         VARCHAR(50)
       ,@i_T_tax_id_number          VARCHAR(100)
       ,@i_T_tax_id_type            VARCHAR(50)
       ,@i_BU_doing_business_as     VARCHAR(50)
	   ,@iPaymentDestination        VARCHAR(1)	-- SP45
       ,@i_BU_location_id           VARCHAR(100)
       ,@i_BU_location_name         VARCHAR(100)
       ,@i_BU_address_1             VARCHAR(55)
       ,@i_BU_address_2             VARCHAR(55)
       ,@i_BU_zip_code              VARCHAR(50)
       ,@i_BU_city                  VARCHAR(50)
       ,@i_BU_state                 VARCHAR(50)
       ,@i_BU_county                VARCHAR(50)
       ,@i_BU_country               VARCHAR(50)
       ,@i_BU_email_address         VARCHAR(100)
       ,@i_BU_phone_number          VARCHAR(50)
       ,@i_BU_fax_number            VARCHAR(50)
       ,@i_BU_owner_name            VARCHAR(50)
       ,@i_BU_owner_license         VARCHAR(50)
       ,@i_BUMA_location_id         VARCHAR(50)
       ,@i_BUMA_location_name       VARCHAR(100)
       ,@i_BUMA_address_1           VARCHAR(50)
       ,@i_BUMA_address_2           VARCHAR(55)
       ,@i_BUMA_zip_code            VARCHAR(50)
       ,@i_BUMA_city                VARCHAR(50)
       ,@i_BUMA_state               VARCHAR(50)
       ,@i_BUMA_county              VARCHAR(50)
       ,@i_BUMA_country             VARCHAR(20)
       ,@i_BUMA_payment_center      VARCHAR(20)
       ,@i_T_tin_effective_date     VARCHAR(20)
       ,@i_T_tin_end_date           VARCHAR(20)
       ,@i_T_w9_onfile              VARCHAR(50)
       ,@i_T_W9_Completed           VARCHAR(50)
       ,@i_T_W9_Date_Requested      VARCHAR(50)
       ,@i_T_w9_rec_date            VARCHAR(50)
       ,@i_T_w9_business_type       VARCHAR(200)
       ,@i_T_name_1099              VARCHAR(100)
       ,@i_T_name_1099_2            VARCHAR(10)
       ,@i_B_waiver                 VARCHAR(10)
       ,@i_B_waiver_percent         VARCHAR(50)
       ,@i_T_location_id            VARCHAR(50)
       ,@i_T_location_name          VARCHAR(100)
       ,@i_T_address_1              VARCHAR(55)
       ,@i_T_address_2              VARCHAR(55)
       ,@i_T_zip_code               VARCHAR(50)
       ,@i_T_city                   VARCHAR(50)
       ,@i_T_state                  VARCHAR(50)
       ,@i_T_county                 VARCHAR(50)
       ,@i_T_country                VARCHAR(50)
       ,@i_B_aba_number             VARCHAR(50)
       ,@i_B_bank_name              VARCHAR(50)
       ,@i_B_branch_phone_number    VARCHAR(50)
       ,@i_B_account_type           VARCHAR(50)
       ,@i_B_account_number         VARCHAR(50)
       ,@i_B_eft_status             VARCHAR(50)
       ,@i_B_eft_effective_date     VARCHAR(50)
       ,@i_B_eft_decline_code       VARCHAR(50)
       ,@i_B_eft_decline_start_date VARCHAR(50)
       ,@i_B_eft_decline_end_date   VARCHAR(50)
       ,@i_BU_eop_output_type       VARCHAR(50)
       ,@i_cap_pcp_roster           VARCHAR(100)
       ,@oStatus                    VARCHAR(20)
       ,@oMessage                   VARCHAR(20)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnits') IS NOT NULL
	DROP TABLE #BusinessUnits

CREATE TABLE #BusinessUnits
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('Bus_Units')
      ,i_key_1_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field              VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field              VARCHAR(20)       DEFAULT('0')
      ,i_key_4_field              VARCHAR(200)      DEFAULT('0')
      ,i_key_5_field              VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field             VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified       VARCHAR(20)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,i_BU_business_unit_id      VARCHAR(50)
      ,i_BU_npi_id                VARCHAR(50)
      ,i_BU_npi_verif             VARCHAR(50)
      ,i_BU_business_name         VARCHAR(100)
      ,i_BU_business_type         VARCHAR(50)
      ,i_T_tax_id_number          VARCHAR(100)
      ,i_T_tax_id_type            VARCHAR(50)
      ,i_BU_doing_business_as     VARCHAR(50)
	  ,iPaymentDestination		  VARCHAR(50)
      ,i_BU_location_id           VARCHAR(100)
      ,i_BU_location_name         VARCHAR(100)
      ,i_BU_address_1             VARCHAR(55)
      ,i_BU_address_2             VARCHAR(55)
      ,i_BU_zip_code              VARCHAR(50)
      ,i_BU_city                  VARCHAR(50)
      ,i_BU_state                 VARCHAR(50)
      ,i_BU_county                VARCHAR(50)
      ,i_BU_country               VARCHAR(50)
      ,i_BU_email_address         VARCHAR(100)
      ,i_BU_phone_number          VARCHAR(50)
      ,i_BU_fax_number            VARCHAR(50)
      ,i_BU_owner_name            VARCHAR(50)
      ,i_BU_owner_license         VARCHAR(50)
      ,i_BUMA_location_id         VARCHAR(50)
      ,i_BUMA_location_name       VARCHAR(100)
      ,i_BUMA_address_1           VARCHAR(50)
      ,i_BUMA_address_2           VARCHAR(55)
      ,i_BUMA_zip_code            VARCHAR(50)
      ,i_BUMA_city                VARCHAR(50)
      ,i_BUMA_state               VARCHAR(50)
      ,i_BUMA_county              VARCHAR(50)
      ,i_BUMA_country             VARCHAR(20)
      ,i_BUMA_payment_center      VARCHAR(20)
      ,i_T_tin_effective_date     VARCHAR(20)
      ,i_T_tin_end_date           VARCHAR(20)
      ,i_T_w9_onfile              VARCHAR(50)
      ,i_T_W9_Completed           VARCHAR(50)
      ,i_T_W9_Date_Requested      VARCHAR(50)
      ,i_T_w9_rec_date            VARCHAR(50)
      ,i_T_w9_business_type       VARCHAR(200)
      ,i_T_name_1099              VARCHAR(100)
      ,i_T_name_1099_2            VARCHAR(10)
      ,i_B_waiver                 VARCHAR(10)
      ,i_B_waiver_percent         VARCHAR(50)
      ,i_T_location_id            VARCHAR(50)
      ,i_T_location_name          VARCHAR(100)
      ,i_T_address_1              VARCHAR(55)
      ,i_T_address_2              VARCHAR(55)
      ,i_T_zip_code               VARCHAR(50)
      ,i_T_city                   VARCHAR(50)
      ,i_T_state                  VARCHAR(50)
      ,i_T_county                 VARCHAR(50)
      ,i_T_country                VARCHAR(50)
      ,i_B_aba_number             VARCHAR(50)
      ,i_B_bank_name              VARCHAR(50)
      ,i_B_branch_phone_number    VARCHAR(50)
      ,i_B_account_type           VARCHAR(50)
      ,i_B_account_number         VARCHAR(50)
      ,i_B_eft_status             VARCHAR(50)
      ,i_B_eft_effective_date     VARCHAR(50)
      ,i_B_eft_decline_code       VARCHAR(50)
      ,i_B_eft_decline_start_date VARCHAR(50)
      ,i_B_eft_decline_end_date   VARCHAR(50)
      ,i_BU_eop_output_type       VARCHAR(50)
      ,i_cap_pcp_roster           VARCHAR(100)
      ,oStatus                    VARCHAR(20)
      ,oMessage                   VARCHAR(20)
      ,record_id                  INT
      ,static_gid                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BusinessUnits
      (SearchID
      ,i_BU_business_unit_id
      ,i_BU_npi_id
      ,i_BU_npi_verif
      ,i_BU_business_name
      ,i_BU_business_type
      ,i_T_tax_id_number
      ,i_T_tax_id_type
      ,i_BU_doing_business_as
	  ,iPaymentDestination
      ,i_BU_location_id
      ,i_BU_email_address
      ,i_BU_phone_number
      ,i_BU_fax_number
      ,i_BU_owner_name
      ,i_BU_owner_license
      ,i_BUMA_location_id
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
      ,i_B_waiver_percent
      ,i_T_location_id
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
      ,i_BU_eop_output_type
      ,i_cap_pcp_roster
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([BusinessUnitID], '')
      ,ISNULL([NPIID], '')
      ,ISNULL([NPIVerification], '01/01/1900')
      ,ISNULL([BusinessName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BusinessType]), '06')
      ,ISNULL([TaxID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TaxIDType]), '1')
      ,ISNULL([DBA], '')
	  ,ISNULL([PaymentDestination], 'B')		--SP45
      ,ISNULL([BusinessUnitLocID], '')
      ,ISNULL([Email], '')
      ,ISNULL([Phone], '0000000000')
      ,ISNULL([Fax], '0000000000')
      ,ISNULL([OwnerName], '')
      ,ISNULL([OwnerLicense], '')
      ,ISNULL([MailingLocID], '')
      ,ISNULL([PaymentCenter], '')
      ,ISNULL([TINEffDate], '01/01/1900')
      ,ISNULL([TINEndDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9OnFile]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9Completed]), 'N')
      ,ISNULL([W9Requested], '01/01/1900')
      ,ISNULL([W9Received], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9BusType]), 'C')
      ,ISNULL([1099PayeeName1], '')
      ,ISNULL([1099PayeeName2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RetentionWaiver]), 'N')
      ,ISNULL([WaiverPercentage], '0.00')
      ,ISNULL([TaxLocationID], '')
      ,ISNULL([ABA], '')
      ,ISNULL([BankName], '')
      ,ISNULL([BankPhone], '0000000000')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AccountType]), 'C')
      ,ISNULL([AccountNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTStatus]), '0')
      ,ISNULL([EFTEffDate], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EFTDeclineDesc]), '06')
      ,ISNULL([DeclineStartDate], '01/01/1900')
      ,ISNULL([DeclineEndDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EOPOutputType]), 'B')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenerateCAP_PCP]), 'B')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnit
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BusinessUnits
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BusinessUnits_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
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
       ,i_date_time_modified
       ,iUserID
       ,i_BU_business_unit_id
       ,i_BU_npi_id
       ,i_BU_npi_verif
       ,i_BU_business_name
       ,i_BU_business_type
       ,i_T_tax_id_number
       ,i_T_tax_id_type
       ,i_BU_doing_business_as
	   ,iPaymentDestination			--SP45
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
       ,i_B_waiver_percent
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
       ,i_BU_eop_output_type
       ,i_cap_pcp_roster
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #BusinessUnits

   OPEN BusinessUnits_Cursor
  FETCH NEXT FROM BusinessUnits_Cursor
   INTO @SearchID
       ,@i_entity_name
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
       ,@i_date_time_modified
       ,@iUserID
       ,@i_BU_business_unit_id
       ,@i_BU_npi_id
       ,@i_BU_npi_verif
       ,@i_BU_business_name
       ,@i_BU_business_type
       ,@i_T_tax_id_number
       ,@i_T_tax_id_type
       ,@i_BU_doing_business_as
	   ,@iPaymentDestination
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
       ,@i_B_waiver_percent
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
       ,@i_BU_eop_output_type
       ,@i_cap_pcp_roster
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prPMBusinessUnitAdd
             @i_entity_name
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
            ,@i_date_time_modified
            ,@iUserID
            ,@i_BU_business_unit_id
            ,@i_BU_npi_id
            ,@i_BU_npi_verif
            ,@i_BU_business_name
            ,@i_BU_business_type
            ,@i_T_tax_id_number
            ,@i_T_tax_id_type
            ,@i_BU_doing_business_as
			,@iPaymentDestination
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
            ,@i_B_waiver_percent
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
            ,@i_BU_eop_output_type
            ,@i_cap_pcp_roster
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN
				
				-- Update the Business Unit and Business Tax Relations tables
				SELECT @current_gid				= business_gid
				  FROM Business_Units
				 WHERE business_unit_id			= @i_BU_business_unit_id
				   AND record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.Business_Units 
				   SET business_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND business_gid				= @current_gid

				-- Update to the static gid
				UPDATE dbo.Business_Tax_Relation 
				   SET business_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND business_gid				= @current_gid

				-- Update the Business Tax Relations and Business Tax Info tables
				SELECT @current_gid				= business_tax_gid
				  FROM Business_Tax_Relation
				 WHERE business_gid				= @static_gid
				   AND record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.Business_Tax_Info 
				   SET business_tax_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND business_tax_gid			= @current_gid

				-- Update to the static gid
				UPDATE dbo.Business_Tax_Relation 
				   SET business_tax_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND business_tax_gid			= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_BU_business_unit_id, @i_BU_business_name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM BusinessUnits_Cursor
         INTO @SearchID
             ,@i_entity_name
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
             ,@i_date_time_modified
             ,@iUserID
             ,@i_BU_business_unit_id
             ,@i_BU_npi_id
             ,@i_BU_npi_verif
             ,@i_BU_business_name
             ,@i_BU_business_type
             ,@i_T_tax_id_number
             ,@i_T_tax_id_type
             ,@i_BU_doing_business_as
			 ,@iPaymentDestination
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
             ,@i_B_waiver_percent
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
             ,@i_BU_eop_output_type
             ,@i_cap_pcp_roster
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnits_Cursor
DEALLOCATE BusinessUnits_Cursor

END
GO