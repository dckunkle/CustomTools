IF OBJECT_ID('dbo.spDCAuto_CreateGeneralLedgerAssignmentMatrix') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGeneralLedgerAssignmentMatrix AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGeneralLedgerAssignmentMatrix
Purpose:    Create generalledgerassignmentmatrix data from CorderAutomation
Method:     GeneralLedgerAssignmentMatrix
Screen GID: 753
Procedure:  dbo.prGL_Assignment_Matrix_Add

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGeneralLedgerAssignmentMatrix '100-Config%', 22, 'GeneralLedgerAssignmentMatrix'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGeneralLedgerAssignmentMatrix
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

DECLARE @i_entity_name            VARCHAR(50)
       ,@i_key_1_field            VARCHAR(20)
       ,@i_key_2_field            VARCHAR(10)
       ,@i_key_3_field            VARCHAR(50)
       ,@i_key_4_field            VARCHAR(50)
       ,@i_key_5_field            VARCHAR(100)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(20)
       ,@i_key_8_field            VARCHAR(50)
       ,@i_key_9_field            VARCHAR(20)
       ,@i_key_10_field           VARCHAR(50)
       ,@i_action                 VARCHAR(10)
       ,@i_date_time_modified     VARCHAR(30)
       ,@iUserID                  VARCHAR(25)
       ,@i_effective_date         VARCHAR(50)
       ,@i_termination_date       VARCHAR(50)
       ,@i_contract_state         VARCHAR(50)
       ,@i_contract_class_code    VARCHAR(100)
       ,@i_census_category        VARCHAR(20)
       ,@i_bene_class_variation   VARCHAR(50)
       ,@i_system_lob             VARCHAR(50)
       ,@i_default_lob            VARCHAR(50)
       ,@i_financial_code         VARCHAR(50)
       ,@i_entity_type            VARCHAR(50)
       ,@i_bank_acct_number       VARCHAR(50)
       ,@i_bank_acct_desc         VARCHAR(80)
       ,@i_gl_acct_number         VARCHAR(50)
       ,@i_gl_acct_desc           VARCHAR(80)
       ,@i_cr_gl_acct_number      VARCHAR(50)
       ,@i_cr_gl_acct_desc        VARCHAR(80)
       ,@i_process_type           VARCHAR(50)
       ,@i_process_function       VARCHAR(50)
       ,@i_other_carrier_code     VARCHAR(50)
       ,@i_insurance_carrier_desc VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GeneralLedgerAssignmentMatrix') IS NOT NULL
	DROP TABLE #GeneralLedgerAssignmentMatrix

CREATE TABLE #GeneralLedgerAssignmentMatrix
      (i_entity_name            VARCHAR(50)       DEFAULT('General_Ledger_Assignment_Matrix')
      ,i_key_1_field            VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field            VARCHAR(10)       DEFAULT('0')
      ,i_key_3_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(20)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(20)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(50)       DEFAULT('0')
      ,i_action                 VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(30)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,i_effective_date         VARCHAR(50)
      ,i_termination_date       VARCHAR(50)
      ,i_contract_state         VARCHAR(50)
      ,i_contract_class_code    VARCHAR(100)
      ,i_census_category        VARCHAR(20)
      ,i_bene_class_variation   VARCHAR(50)
      ,i_system_lob             VARCHAR(50)
      ,i_default_lob            VARCHAR(50)
      ,i_financial_code         VARCHAR(50)
      ,i_entity_type            VARCHAR(50)
      ,i_bank_acct_number       VARCHAR(50)
      ,i_bank_acct_desc         VARCHAR(80)
      ,i_gl_acct_number         VARCHAR(50)
      ,i_gl_acct_desc           VARCHAR(80)
      ,i_cr_gl_acct_number      VARCHAR(50)
      ,i_cr_gl_acct_desc        VARCHAR(80)
      ,i_process_type           VARCHAR(50)
      ,i_process_function       VARCHAR(50)
      ,i_other_carrier_code     VARCHAR(50)
      ,i_insurance_carrier_desc VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(200)
      ,record_id                INT
      ,static_gid               INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GeneralLedgerAssignmentMatrix
      (i_effective_date
      ,i_termination_date
      ,i_contract_state
      ,i_contract_class_code
      ,i_census_category
      ,i_bene_class_variation
      ,i_system_lob
      ,i_default_lob
      ,i_financial_code
      ,i_entity_type
      ,i_bank_acct_number
      ,i_gl_acct_number
      ,i_cr_gl_acct_number
      ,i_process_type
      ,i_process_function
      ,i_other_carrier_code
      ,record_id
      ,static_gid)
SELECT ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractState]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractClassCode]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractCensusCategory]), '3-100')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*BenefitClass]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SystemLOB]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOB]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FinancialCode]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*BillType]), '*')
      ,ISNULL([DepositBankAcctID], '')
      ,ISNULL([*DebitDefaultGLAcct], '')
      ,ISNULL([CreditGLAcct], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProcessType]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProcessFunction]), '*')
      ,ISNULL([CarrierID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GeneralLedgerAssignMatrix
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GeneralLedgerAssignmentMatrix
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GeneralLedgerAssignmentMatrix_Cursor CURSOR FOR
 SELECT i_entity_name
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
       ,i_effective_date
       ,i_termination_date
       ,i_contract_state
       ,i_contract_class_code
       ,i_census_category
       ,i_bene_class_variation
       ,i_system_lob
       ,i_default_lob
       ,i_financial_code
       ,i_entity_type
       ,i_bank_acct_number
       ,i_bank_acct_desc
       ,i_gl_acct_number
       ,i_gl_acct_desc
       ,i_cr_gl_acct_number
       ,i_cr_gl_acct_desc
       ,i_process_type
       ,i_process_function
       ,i_other_carrier_code
       ,i_insurance_carrier_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GeneralLedgerAssignmentMatrix

   OPEN GeneralLedgerAssignmentMatrix_Cursor
  FETCH NEXT FROM GeneralLedgerAssignmentMatrix_Cursor
   INTO @i_entity_name
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
       ,@i_effective_date
       ,@i_termination_date
       ,@i_contract_state
       ,@i_contract_class_code
       ,@i_census_category
       ,@i_bene_class_variation
       ,@i_system_lob
       ,@i_default_lob
       ,@i_financial_code
       ,@i_entity_type
       ,@i_bank_acct_number
       ,@i_bank_acct_desc
       ,@i_gl_acct_number
       ,@i_gl_acct_desc
       ,@i_cr_gl_acct_number
       ,@i_cr_gl_acct_desc
       ,@i_process_type
       ,@i_process_function
       ,@i_other_carrier_code
       ,@i_insurance_carrier_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prGL_Assignment_Matrix_Add
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
            ,@i_effective_date
            ,@i_termination_date
            ,@i_contract_state
            ,@i_contract_class_code
            ,@i_census_category
            ,@i_bene_class_variation
            ,@i_system_lob
            ,@i_default_lob
            ,@i_financial_code
            ,@i_entity_type
            ,@i_bank_acct_number
            ,@i_bank_acct_desc
            ,@i_gl_acct_number
            ,@i_gl_acct_desc
            ,@i_cr_gl_acct_number
            ,@i_cr_gl_acct_desc
            ,@i_process_type
            ,@i_process_function
            ,@i_other_carrier_code
            ,@i_insurance_carrier_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_financial_code, @i_gl_acct_number, @i_cr_gl_acct_number, @status, @err_num, @err_msg

        FETCH NEXT FROM GeneralLedgerAssignmentMatrix_Cursor
         INTO @i_entity_name
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
             ,@i_effective_date
             ,@i_termination_date
             ,@i_contract_state
             ,@i_contract_class_code
             ,@i_census_category
             ,@i_bene_class_variation
             ,@i_system_lob
             ,@i_default_lob
             ,@i_financial_code
             ,@i_entity_type
             ,@i_bank_acct_number
             ,@i_bank_acct_desc
             ,@i_gl_acct_number
             ,@i_gl_acct_desc
             ,@i_cr_gl_acct_number
             ,@i_cr_gl_acct_desc
             ,@i_process_type
             ,@i_process_function
             ,@i_other_carrier_code
             ,@i_insurance_carrier_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GeneralLedgerAssignmentMatrix_Cursor
DEALLOCATE GeneralLedgerAssignmentMatrix_Cursor

END
GO