IF OBJECT_ID('dbo.spDCAuto_CreateBillingParameters') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBillingParameters AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBillingParameters
Purpose:    Create billingparameters data from CorderAutomation

Date        User            Change
---------------------------------------------------------------------------------------------
10/23/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBillingParameters 'Census-Config-1%', 22, 'Census-Config', 'BillingParameters', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBillingParameters
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

	   ,@billing_gid				INT

DECLARE @i_Entity_name                           VARCHAR(50)
       ,@i_Billing_Parameters_Gid                VARCHAR(50)
       ,@i_Calendar_Gid                          VARCHAR(50)
       ,@i_key_3_field                           VARCHAR(50)
       ,@i_key_4_field                           VARCHAR(50)
       ,@i_key_5_field                           VARCHAR(50)
       ,@i_key_6_field                           VARCHAR(50)
       ,@i_key_7_field                           VARCHAR(50)
       ,@i_key_8_field                           VARCHAR(50)
       ,@i_key_9_field                           VARCHAR(50)
       ,@i_key_10_field                          VARCHAR(50)
       ,@i_action                                VARCHAR(10)
       ,@l_modified_date                         VARCHAR(50)
       ,@iUserID                                 VARCHAR(25)
       ,@i_billing_parameters_id                 VARCHAR(50)
       ,@i_billing_parameters_description        VARCHAR(50)
       ,@i_effective_date                        CHAR(20)
       ,@i_termination_date                      CHAR(20)
       ,@i_bill_treatment                        CHAR(1)
       ,@i_bill_premium                          CHAR(1)
       ,@i_bill_stop_loss                        CHAR(1)
       ,@i_bill_funding                          CHAR(1)
       ,@i_calendar_id                           VARCHAR(50)
       ,@i_calendar_desc                         VARCHAR(50)
       ,@i_payment_terms                         CHAR(6)
       ,@i_prorate_method                        CHAR(1)
       ,@i_Last_Inv_Date                         CHAR(20)
       ,@i_invoice_freq                          CHAR(1)
       ,@i_Last_Inv_Start_Date                   CHAR(20)
       ,@i_Last_Inv_End_Date                     CHAR(20)
       ,@i_Next_Inv_Start_Date                   CHAR(20)
       ,@i_Next_Inv_End_Date                     CHAR(20)
       ,@i_Invoice_Message_Id                    VARCHAR(10)
       ,@i_Invoice_Message                       VARCHAR(180)
       ,@i_suppress_elec_pay                     CHAR(1)
       ,@i_invoice_start_option                  CHAR(1)
       ,@i_offcycle_rollback                     CHAR(1)
       ,@i_offcycle_days                         INT
       ,@i_due_date_days_prior                   CHAR(2)
       ,@i_Calculation_Rounding_Precision        CHAR(1)
       ,@i_inv_detail_adds                       CHAR(1)
       ,@i_inv_detail_terminations               CHAR(1)
       ,@i_inv_detail_deletions                  CHAR(1)
       ,@i_inv_detail_census_changes             CHAR(1)
       ,@i_inv_detail_miscellaneous_transactions CHAR(1)
       ,@i_inv_treatment_detail                  CHAR(1)
       ,@i_inv_detail_continuing_census          CHAR(1)
       ,@i_line_detail_sort                      CHAR(1)
       ,@i_invoice_sort1                         CHAR(1)
       ,@i_subtotal_sort1                        CHAR(1)
       ,@i_invoice_sort2                         CHAR(1)
       ,@i_subtotal_sort2                        CHAR(1)
       ,@i_invoice_sort3                         CHAR(1)
       ,@i_subtotal_sort3                        CHAR(1)
       ,@i_subgroup_detail                       CHAR(1)
       ,@iShortFormat                            CHAR(1)
       ,@i_retro_detail                          CHAR(1)
       ,@o_status                                INT
       ,@o_message                               VARCHAR(250)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BillingParameters') IS NOT NULL
	DROP TABLE #BillingParameters

CREATE TABLE #BillingParameters
      (i_Entity_name                           VARCHAR(50)       DEFAULT('Billing_Parameters')
      ,i_Billing_Parameters_Gid                VARCHAR(50)       DEFAULT('0')
      ,i_Calendar_Gid                          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                          VARCHAR(50)       DEFAULT('0')
      ,i_action                                VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date                         VARCHAR(50)       DEFAULT('')
      ,iUserID                                 VARCHAR(25)       DEFAULT('')
      ,i_billing_parameters_id                 VARCHAR(50)
      ,i_billing_parameters_description        VARCHAR(50)
      ,i_effective_date                        CHAR(20)
      ,i_termination_date                      CHAR(20)
      ,i_bill_treatment                        CHAR(1)
      ,i_bill_premium                          CHAR(1)
      ,i_bill_stop_loss                        CHAR(1)
      ,i_bill_funding                          CHAR(1)
      ,i_calendar_id                           VARCHAR(50)
      ,i_calendar_desc                         VARCHAR(50)
      ,i_payment_terms                         CHAR(6)
      ,i_prorate_method                        CHAR(1)
      ,i_Last_Inv_Date                         CHAR(20)
      ,i_invoice_freq                          CHAR(1)
      ,i_Last_Inv_Start_Date                   CHAR(20)
      ,i_Last_Inv_End_Date                     CHAR(20)
      ,i_Next_Inv_Start_Date                   CHAR(20)
      ,i_Next_Inv_End_Date                     CHAR(20)
      ,i_Invoice_Message_Id                    VARCHAR(10)
      ,i_Invoice_Message                       VARCHAR(180)
      ,i_suppress_elec_pay                     CHAR(1)
      ,i_invoice_start_option                  CHAR(1)
      ,i_offcycle_rollback                     CHAR(1)
      ,i_offcycle_days                         INT
      ,i_due_date_days_prior                   CHAR(2)
      ,i_Calculation_Rounding_Precision        CHAR(1)
      ,i_inv_detail_adds                       CHAR(1)
      ,i_inv_detail_terminations               CHAR(1)
      ,i_inv_detail_deletions                  CHAR(1)
      ,i_inv_detail_census_changes             CHAR(1)
      ,i_inv_detail_miscellaneous_transactions CHAR(1)
      ,i_inv_treatment_detail                  CHAR(1)
      ,i_inv_detail_continuing_census          CHAR(1)
      ,i_line_detail_sort                      CHAR(1)
      ,i_invoice_sort1                         CHAR(1)
      ,i_subtotal_sort1                        CHAR(1)
      ,i_invoice_sort2                         CHAR(1)
      ,i_subtotal_sort2                        CHAR(1)
      ,i_invoice_sort3                         CHAR(1)
      ,i_subtotal_sort3                        CHAR(1)
      ,i_subgroup_detail                       CHAR(1)
      ,iShortFormat                            CHAR(1)
      ,i_retro_detail                          CHAR(1)
      ,o_status                                INT
      ,o_message                               VARCHAR(250)
      ,record_id                                INT
	  ,gid										INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BillingParameters
      (i_billing_parameters_id
      ,i_billing_parameters_description
      ,i_effective_date
      ,i_termination_date
      ,i_bill_treatment
      ,i_bill_premium
      ,i_bill_stop_loss
      ,i_bill_funding
      ,i_calendar_id
      ,i_payment_terms
      ,i_prorate_method
      ,i_invoice_freq
      ,i_Invoice_Message_Id
      ,i_suppress_elec_pay
      ,i_due_date_days_prior
      ,i_Calculation_Rounding_Precision
      ,i_inv_detail_adds
      ,i_inv_detail_terminations
      ,i_inv_detail_deletions
      ,i_inv_detail_census_changes
      ,i_inv_detail_miscellaneous_transactions
      ,i_inv_treatment_detail
      ,i_inv_detail_continuing_census
      ,i_line_detail_sort
      ,i_invoice_sort1
      ,i_subtotal_sort1
      ,i_invoice_sort2
      ,i_subtotal_sort2
      ,i_invoice_sort3
      ,i_subtotal_sort3
      ,i_subgroup_detail
      ,iShortFormat
      ,i_retro_detail
      ,record_id
	  ,gid)
SELECT ISNULL([*Common_BillingParamID], '')
      ,ISNULL([*Common_ParameterDescription], '')
      ,ISNULL([*Common_EffectiveDate], '')
      ,ISNULL([*Common_TerminationDate], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BillingTreatment]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BillingPremium]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BillingStopLoss]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BillingFundingSources]), 'N')
      ,ISNULL([*Common_CalendarID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PaymentTerms]), '90210')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ProrateMethod]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_InvoiceFrequency]), 'M')
      ,ISNULL([Common_InvoiceMessageID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SuppressOutputOnElectPay]), 'N')
      ,ISNULL([Common_CorrNbrOfDaysPriorStartDt], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CalcRoundingPrecission]), '2')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_AddDetails]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_TerminationDetails]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_DeletionDetails]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_CensusChangeDetails]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_MiscDetails]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_TreatmentDetails]), 'S')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_ContinuingDetails]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_LineDetailSort]), 'L')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_InvSort1]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_SubTotalSort1]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_InvSort2]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_SubTotalSort2]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_InvSort3]), 'S')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_SubTotalSort3]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_SubGroupDetail]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_InvOutputShortFormat]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvDetail_ShortFormatRetroDetail]), 'N')
      ,ISNULL([RecordID], '')
	  ,ISNULL([gid], 0)
  FROM COREAUTO.CoreAutomation.dbo.TD_BillingParameters
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BillingParameters
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BillingParameters_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Billing_Parameters_Gid
       ,i_Calendar_Gid
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_billing_parameters_id
       ,i_billing_parameters_description
       ,i_effective_date
       ,i_termination_date
       ,i_bill_treatment
       ,i_bill_premium
       ,i_bill_stop_loss
       ,i_bill_funding
       ,i_calendar_id
       ,i_calendar_desc
       ,i_payment_terms
       ,i_prorate_method
       ,i_Last_Inv_Date
       ,i_invoice_freq
       ,i_Last_Inv_Start_Date
       ,i_Last_Inv_End_Date
       ,i_Next_Inv_Start_Date
       ,i_Next_Inv_End_Date
       ,i_Invoice_Message_Id
       ,i_Invoice_Message
       ,i_suppress_elec_pay
       ,i_invoice_start_option
       ,i_offcycle_rollback
       ,i_offcycle_days
       ,i_due_date_days_prior
       ,i_Calculation_Rounding_Precision
       ,i_inv_detail_adds
       ,i_inv_detail_terminations
       ,i_inv_detail_deletions
       ,i_inv_detail_census_changes
       ,i_inv_detail_miscellaneous_transactions
       ,i_inv_treatment_detail
       ,i_inv_detail_continuing_census
       ,i_line_detail_sort
       ,i_invoice_sort1
       ,i_subtotal_sort1
       ,i_invoice_sort2
       ,i_subtotal_sort2
       ,i_invoice_sort3
       ,i_subtotal_sort3
       ,i_subgroup_detail
       ,iShortFormat
       ,i_retro_detail
       ,o_status
       ,o_message
       ,record_id
	   ,gid
   FROM #BillingParameters

   OPEN BillingParameters_Cursor
  FETCH NEXT FROM BillingParameters_Cursor
   INTO @i_Entity_name
       ,@i_Billing_Parameters_Gid
       ,@i_Calendar_Gid
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_billing_parameters_id
       ,@i_billing_parameters_description
       ,@i_effective_date
       ,@i_termination_date
       ,@i_bill_treatment
       ,@i_bill_premium
       ,@i_bill_stop_loss
       ,@i_bill_funding
       ,@i_calendar_id
       ,@i_calendar_desc
       ,@i_payment_terms
       ,@i_prorate_method
       ,@i_Last_Inv_Date
       ,@i_invoice_freq
       ,@i_Last_Inv_Start_Date
       ,@i_Last_Inv_End_Date
       ,@i_Next_Inv_Start_Date
       ,@i_Next_Inv_End_Date
       ,@i_Invoice_Message_Id
       ,@i_Invoice_Message
       ,@i_suppress_elec_pay
       ,@i_invoice_start_option
       ,@i_offcycle_rollback
       ,@i_offcycle_days
       ,@i_due_date_days_prior
       ,@i_Calculation_Rounding_Precision
       ,@i_inv_detail_adds
       ,@i_inv_detail_terminations
       ,@i_inv_detail_deletions
       ,@i_inv_detail_census_changes
       ,@i_inv_detail_miscellaneous_transactions
       ,@i_inv_treatment_detail
       ,@i_inv_detail_continuing_census
       ,@i_line_detail_sort
       ,@i_invoice_sort1
       ,@i_subtotal_sort1
       ,@i_invoice_sort2
       ,@i_subtotal_sort2
       ,@i_invoice_sort3
       ,@i_subtotal_sort3
       ,@i_subgroup_detail
       ,@iShortFormat
       ,@i_retro_detail
       ,@o_status
       ,@o_message
       ,@record_id
	   ,@gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prBARBilling_Parameters_Add_Modify
             @i_Entity_name
            ,@i_Billing_Parameters_Gid
            ,@i_Calendar_Gid
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@i_billing_parameters_id
            ,@i_billing_parameters_description
            ,@i_effective_date
            ,@i_termination_date
            ,@i_bill_treatment
            ,@i_bill_premium
            ,@i_bill_stop_loss
            ,@i_bill_funding
            ,@i_calendar_id
            ,@i_calendar_desc
            ,@i_payment_terms
            ,@i_prorate_method
            ,@i_Last_Inv_Date
            ,@i_invoice_freq
            ,@i_Last_Inv_Start_Date
            ,@i_Last_Inv_End_Date
            ,@i_Next_Inv_Start_Date
            ,@i_Next_Inv_End_Date
            ,@i_Invoice_Message_Id
            ,@i_Invoice_Message
            ,@i_suppress_elec_pay
            ,@i_invoice_start_option
            ,@i_offcycle_rollback
            ,@i_offcycle_days
            ,@i_due_date_days_prior
            ,@i_Calculation_Rounding_Precision
            ,@i_inv_detail_adds
            ,@i_inv_detail_terminations
            ,@i_inv_detail_deletions
            ,@i_inv_detail_census_changes
            ,@i_inv_detail_miscellaneous_transactions
            ,@i_inv_treatment_detail
            ,@i_inv_detail_continuing_census
            ,@i_line_detail_sort
            ,@i_invoice_sort1
            ,@i_subtotal_sort1
            ,@i_invoice_sort2
            ,@i_subtotal_sort2
            ,@i_invoice_sort3
            ,@i_subtotal_sort3
            ,@i_subgroup_detail
            ,@iShortFormat
            ,@i_retro_detail
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF @gid IS NOT NULL
			BEGIN

				SELECT @billing_gid				= ISNULL(entity_gid, 0)
				  FROM dbo.Entity_Names
				 WHERE entity_identifier		= 'Billing_Parameters'
				   AND entity_user_id			= @i_billing_parameters_id
				   AND record_status			= 'A'

				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @gid 
				 WHERE entity_identifier		= 'Billing_Parameters'
				   AND entity_user_id			= @i_billing_parameters_id
				   AND record_status			= 'A'

				UPDATE dbo.Billing_Parameters
				   SET billing_parameters_gid	= @gid
				 WHERE billing_parameters_gid	= @billing_gid
				   AND record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_billing_parameters_id, @i_billing_parameters_description, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BillingParameters_Cursor
         INTO @i_Entity_name
             ,@i_Billing_Parameters_Gid
             ,@i_Calendar_Gid
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_billing_parameters_id
             ,@i_billing_parameters_description
             ,@i_effective_date
             ,@i_termination_date
             ,@i_bill_treatment
             ,@i_bill_premium
             ,@i_bill_stop_loss
             ,@i_bill_funding
             ,@i_calendar_id
             ,@i_calendar_desc
             ,@i_payment_terms
             ,@i_prorate_method
             ,@i_Last_Inv_Date
             ,@i_invoice_freq
             ,@i_Last_Inv_Start_Date
             ,@i_Last_Inv_End_Date
             ,@i_Next_Inv_Start_Date
             ,@i_Next_Inv_End_Date
             ,@i_Invoice_Message_Id
             ,@i_Invoice_Message
             ,@i_suppress_elec_pay
             ,@i_invoice_start_option
             ,@i_offcycle_rollback
             ,@i_offcycle_days
             ,@i_due_date_days_prior
             ,@i_Calculation_Rounding_Precision
             ,@i_inv_detail_adds
             ,@i_inv_detail_terminations
             ,@i_inv_detail_deletions
             ,@i_inv_detail_census_changes
             ,@i_inv_detail_miscellaneous_transactions
             ,@i_inv_treatment_detail
             ,@i_inv_detail_continuing_census
             ,@i_line_detail_sort
             ,@i_invoice_sort1
             ,@i_subtotal_sort1
             ,@i_invoice_sort2
             ,@i_subtotal_sort2
             ,@i_invoice_sort3
             ,@i_subtotal_sort3
             ,@i_subgroup_detail
             ,@iShortFormat
             ,@i_retro_detail
             ,@o_status
             ,@o_message
			 ,@record_id
			 ,@gid
	END

CLOSE BillingParameters_Cursor
DEALLOCATE BillingParameters_Cursor

END
GO