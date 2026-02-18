IF OBJECT_ID('dbo.spDCAuto_CreateGeneralLedgerScheduleAssigment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGeneralLedgerScheduleAssigment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGeneralLedgerScheduleAssigment
Purpose:    Create generalledgerscheduleassigment data from CorderAutomation
Method:     GeneralLedgerScheduleAssigment
Screen GID: 752
Procedure:  dbo.prGL_Assignment_Add_Wrapper

Date        User            Change
---------------------------------------------------------------------------------------------
11/05/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGeneralLedgerScheduleAssigment '100-Config%', 22, 'GeneralLedgerScheduleAssigment'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGeneralLedgerScheduleAssigment
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

DECLARE @GeneralLedgerID	  VARCHAR(200)
       ,@i_entity_name        VARCHAR(50)
       ,@i_key_1_field        VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(100)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_gl_acct_number     VARCHAR(50)
       ,@i_gl_acct_desc       VARCHAR(80)
       ,@i_cr_gl_acct_number  VARCHAR(50)
       ,@i_cr_gl_acct_desc    VARCHAR(80)
       ,@i_process_type       VARCHAR(50)
       ,@i_process_function   VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GeneralLedgerScheduleAssigment') IS NOT NULL
	DROP TABLE #GeneralLedgerScheduleAssigment

CREATE TABLE #GeneralLedgerScheduleAssigment
      (i_entity_name        VARCHAR(50)       DEFAULT('General_Ledger_Assignment')
      ,i_key_1_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_gl_acct_number     VARCHAR(50)
      ,i_gl_acct_desc       VARCHAR(80)
      ,i_cr_gl_acct_number  VARCHAR(50)
      ,i_cr_gl_acct_desc    VARCHAR(80)
      ,i_process_type       VARCHAR(50)
      ,i_process_function   VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT
	  ,GeneralLedgerID		VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GeneralLedgerScheduleAssigment
      (GeneralLedgerID
	  ,i_effective_date
      ,i_termination_date
      ,i_gl_acct_number
      ,i_cr_gl_acct_number
      ,i_process_type
      ,i_process_function
      ,record_id
      ,static_gid)
SELECT ISNULL([*GeneralLedgerIDSearch], '')
      ,ISNULL([*EffectiveDate], '00/00/0000')
      ,ISNULL([*TerminateDate], '12/31/9999')
      ,ISNULL([*DebitDefaultGLAcct], '')
      ,ISNULL([CreditGLAcct], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProcessType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProcessFunction]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GeneralLedgerScheduleAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GeneralLedgerScheduleAssigment
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GeneralLedgerScheduleAssigment_Cursor CURSOR FOR
 SELECT GeneralLedgerID
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
       ,i_Date_Time_Modified
       ,iUserID
       ,i_effective_date
       ,i_termination_date
       ,i_gl_acct_number
       ,i_gl_acct_desc
       ,i_cr_gl_acct_number
       ,i_cr_gl_acct_desc
       ,i_process_type
       ,i_process_function
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GeneralLedgerScheduleAssigment

   OPEN GeneralLedgerScheduleAssigment_Cursor
  FETCH NEXT FROM GeneralLedgerScheduleAssigment_Cursor
   INTO @GeneralLedgerID
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
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_effective_date
       ,@i_termination_date
       ,@i_gl_acct_number
       ,@i_gl_acct_desc
       ,@i_cr_gl_acct_number
       ,@i_cr_gl_acct_desc
       ,@i_process_type
       ,@i_process_function
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Get the proper gid for the General Ledger Schedule
		SELECT @i_key_1_field		= CONVERT(VARCHAR(50),entity_gid)
		  FROM Entity_Names			EN
		 WHERE EN.entity_identifier	= 'General Ledger Schedule'
		   AND EN.record_status		= 'A'
		   AND EN.entity_user_id	= @GeneralLedgerID

		EXEC dbo.prGL_Assignment_Add_Wrapper
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
            ,@i_Date_Time_Modified
            ,@iUserID
            ,@i_effective_date
            ,@i_termination_date
            ,@i_gl_acct_number
            ,@i_gl_acct_desc
            ,@i_cr_gl_acct_number
            ,@i_cr_gl_acct_desc
            ,@i_process_type
            ,@i_process_function
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_gl_acct_number, @i_cr_gl_acct_number, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GeneralLedgerScheduleAssigment_Cursor
         INTO @GeneralLedgerID
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
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_effective_date
             ,@i_termination_date
             ,@i_gl_acct_number
             ,@i_gl_acct_desc
             ,@i_cr_gl_acct_number
             ,@i_cr_gl_acct_desc
             ,@i_process_type
             ,@i_process_function
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GeneralLedgerScheduleAssigment_Cursor
DEALLOCATE GeneralLedgerScheduleAssigment_Cursor

END
GO