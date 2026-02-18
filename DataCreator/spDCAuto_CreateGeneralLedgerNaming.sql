IF OBJECT_ID('dbo.spDCAuto_CreateGeneralLedgerNaming') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGeneralLedgerNaming AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGeneralLedgerNaming
Purpose:    Create generalledgernaming data from CorderAutomation
Method:     GeneralLedgerNaming
Screen GID: 750
Procedure:  dbo.prGL_Naming_Add

Date        User            Change
---------------------------------------------------------------------------------------------
11/05/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGeneralLedgerNaming '100-Config%', 22, 'GeneralLedgerNaming'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGeneralLedgerNaming
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_key_gl_naming_gid  VARCHAR(50)
       ,@i_key_gl_acct_number VARCHAR(50)
       ,@i_key_gl_acct_desc   VARCHAR(80)
       ,@i_key_bank_acct_gid  VARCHAR(50)
       ,@i_key_5_field        VARCHAR(20)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(20)
       ,@iUserID              VARCHAR(25)
       ,@i_gl_acct_number     VARCHAR(50)
       ,@i_gl_acct_desc       VARCHAR(80)
       ,@i_bank_acct_number   VARCHAR(50)
       ,@i_bank_acct_desc     VARCHAR(80)
       ,@i_bank_desc          VARCHAR(80)
       ,@i_fin_trans_type     VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GeneralLedgerNaming') IS NOT NULL
	DROP TABLE #GeneralLedgerNaming

CREATE TABLE #GeneralLedgerNaming
      (i_entity_name        VARCHAR(50)       DEFAULT('General_Ledger_Naming')
      ,i_key_gl_naming_gid  VARCHAR(50)       DEFAULT('0')
      ,i_key_gl_acct_number VARCHAR(50)       DEFAULT('0')
      ,i_key_gl_acct_desc   VARCHAR(80)       DEFAULT('0')
      ,i_key_bank_acct_gid  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(20)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_gl_acct_number     VARCHAR(50)
      ,i_gl_acct_desc       VARCHAR(80)
      ,i_bank_acct_number   VARCHAR(50)
      ,i_bank_acct_desc     VARCHAR(80)
      ,i_bank_desc          VARCHAR(80)
      ,i_fin_trans_type     VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GeneralLedgerNaming
      (i_gl_acct_number
      ,i_gl_acct_desc
      ,i_bank_acct_number
      ,i_fin_trans_type
      ,record_id
      ,static_gid)
SELECT ISNULL([*GenLedgerAcct], '')
      ,ISNULL([*GenLedgerAcctDesc], '')
      ,ISNULL([*BankAcctNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FinancialTransType]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GeneralLedgerNaming
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GeneralLedgerNaming
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GeneralLedgerNaming_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_key_gl_naming_gid
       ,i_key_gl_acct_number
       ,i_key_gl_acct_desc
       ,i_key_bank_acct_gid
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_gl_acct_number
       ,i_gl_acct_desc
       ,i_bank_acct_number
       ,i_bank_acct_desc
       ,i_bank_desc
       ,i_fin_trans_type
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GeneralLedgerNaming

   OPEN GeneralLedgerNaming_Cursor
  FETCH NEXT FROM GeneralLedgerNaming_Cursor
   INTO @i_entity_name
       ,@i_key_gl_naming_gid
       ,@i_key_gl_acct_number
       ,@i_key_gl_acct_desc
       ,@i_key_bank_acct_gid
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_gl_acct_number
       ,@i_gl_acct_desc
       ,@i_bank_acct_number
       ,@i_bank_acct_desc
       ,@i_bank_desc
       ,@i_fin_trans_type
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prGL_Naming_Add
             @i_entity_name
            ,@i_key_gl_naming_gid
            ,@i_key_gl_acct_number
            ,@i_key_gl_acct_desc
            ,@i_key_bank_acct_gid
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_gl_acct_number
            ,@i_gl_acct_desc
            ,@i_bank_acct_number
            ,@i_bank_acct_desc
            ,@i_bank_desc
            ,@i_fin_trans_type
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.General_Ledger_Naming 
				   SET gl_naming_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND gl_acct_number			= @i_gl_acct_number
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_gl_acct_number, @i_gl_acct_desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GeneralLedgerNaming_Cursor
         INTO @i_entity_name
             ,@i_key_gl_naming_gid
             ,@i_key_gl_acct_number
             ,@i_key_gl_acct_desc
             ,@i_key_bank_acct_gid
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_gl_acct_number
             ,@i_gl_acct_desc
             ,@i_bank_acct_number
             ,@i_bank_acct_desc
             ,@i_bank_desc
             ,@i_fin_trans_type
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GeneralLedgerNaming_Cursor
DEALLOCATE GeneralLedgerNaming_Cursor

END
GO