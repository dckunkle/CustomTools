IF OBJECT_ID('dbo.spDCAuto_CreateMiscellaneousTransactionCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMiscellaneousTransactionCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMiscellaneousTransactionCodes
Purpose:    Create miscellaneoustransactioncodes data from CorderAutomation
Method:     MiscellaneousTransactionCodes
Screen GID: 69
Procedure:  dbo.prBARMisc_Trans_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMiscellaneousTransactionCodes '100-Config%', 22, 'MiscellaneousTransactionCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMiscellaneousTransactionCodes
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

DECLARE @i_entity_name      VARCHAR(20)
       ,@i_misc_trans_gid   VARCHAR(30)
       ,@i_key_2_field      VARCHAR(20)
       ,@i_key_3_field      VARCHAR(50)
       ,@i_key_4_field      VARCHAR(50)
       ,@i_key_5_field      VARCHAR(20)
       ,@i_key_6_field      VARCHAR(50)
       ,@i_key_7_field      VARCHAR(50)
       ,@i_key_8_field      VARCHAR(50)
       ,@i_key_9_field      VARCHAR(50)
       ,@i_key_10_field     VARCHAR(50)
       ,@i_action           VARCHAR(10)
       ,@i_modified_date    VARCHAR(50)
       ,@iUserID            VARCHAR(25)
       ,@i_entity_type      VARCHAR(50)
       ,@i_transaction_type VARCHAR(50)
       ,@i_adj_ID           VARCHAR(50)
       ,@i_adj_Name         VARCHAR(100)
       ,@i_screen_type      VARCHAR(50)
       ,@i_premium_status   VARCHAR(50)
       ,@i_dbt_gl_acct_id   VARCHAR(50)
       ,@i_dbt_gl_name      VARCHAR(100)
       ,@i_crd_gl_acct_id   VARCHAR(50)
       ,@i_crd_gl_name      VARCHAR(100)
       ,@i_financial_code   VARCHAR(50)
       ,@o_status           INT
       ,@o_message          VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MiscellaneousTransactionCodes') IS NOT NULL
	DROP TABLE #MiscellaneousTransactionCodes

CREATE TABLE #MiscellaneousTransactionCodes
      (SearchID           VARCHAR(200)
      ,i_entity_name      VARCHAR(20)       DEFAULT('Misc_tran_codes')
      ,i_misc_trans_gid   VARCHAR(30)       DEFAULT('0')
      ,i_key_2_field      VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field      VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field     VARCHAR(50)       DEFAULT('0')
      ,i_action           VARCHAR(10)       DEFAULT('ADD')
      ,i_modified_date    VARCHAR(50)       DEFAULT('')
      ,iUserID            VARCHAR(25)       DEFAULT('')
      ,i_entity_type      VARCHAR(50)
      ,i_transaction_type VARCHAR(50)
      ,i_adj_ID           VARCHAR(50)
      ,i_adj_Name         VARCHAR(100)
      ,i_screen_type      VARCHAR(50)
      ,i_premium_status   VARCHAR(50)
      ,i_dbt_gl_acct_id   VARCHAR(50)
      ,i_dbt_gl_name      VARCHAR(100)
      ,i_crd_gl_acct_id   VARCHAR(50)
      ,i_crd_gl_name      VARCHAR(100)
      ,i_financial_code   VARCHAR(50)
      ,o_status           INT
      ,o_message          VARCHAR(200)
      ,record_id          INT
      ,static_gid         INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MiscellaneousTransactionCodes
      (SearchID
      ,i_entity_type
      ,i_transaction_type
      ,i_adj_ID
      ,i_adj_Name
      ,i_screen_type
      ,i_premium_status
      ,i_dbt_gl_acct_id
      ,i_crd_gl_acct_id
      ,i_financial_code
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*EntityType]), 'B')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*TransactionType]), '')
      ,ISNULL([*AdjustmentID], '')
      ,ISNULL([*AdjustmentName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ScreenType]), '1006')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PremiumStatus]), 'P')
      ,ISNULL([DebitGLAccountID], '')
      ,ISNULL([CreditGLAccountID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FinancialCode]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MiscTransCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MiscellaneousTransactionCodes
   SET iUserID  = @user

UPDATE MTC
   SET i_screen_type					= SAV.Short_Desc
  FROM #MiscellaneousTransactionCodes	MTC
  JOIN System_Action_Values				SAV
    ON MTC.i_screen_type				= SAV.description
 WHERE SAV.reference_type				= '*MSTRX'
   AND SAV.record_status				= 'A'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MiscellaneousTransactionCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_misc_trans_gid
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
       ,i_modified_date
       ,iUserID
       ,i_entity_type
       ,i_transaction_type
       ,i_adj_ID
       ,i_adj_Name
       ,i_screen_type
       ,i_premium_status
       ,i_dbt_gl_acct_id
       ,i_dbt_gl_name
       ,i_crd_gl_acct_id
       ,i_crd_gl_name
       ,i_financial_code
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MiscellaneousTransactionCodes

   OPEN MiscellaneousTransactionCodes_Cursor
  FETCH NEXT FROM MiscellaneousTransactionCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_misc_trans_gid
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
       ,@i_modified_date
       ,@iUserID
       ,@i_entity_type
       ,@i_transaction_type
       ,@i_adj_ID
       ,@i_adj_Name
       ,@i_screen_type
       ,@i_premium_status
       ,@i_dbt_gl_acct_id
       ,@i_dbt_gl_name
       ,@i_crd_gl_acct_id
       ,@i_crd_gl_name
       ,@i_financial_code
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prBARMisc_Trans_Add_Modify
             @i_entity_name
            ,@i_misc_trans_gid
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
            ,@i_modified_date
            ,@iUserID
            ,@i_entity_type
            ,@i_transaction_type
            ,@i_adj_ID
            ,@i_adj_Name
            ,@i_screen_type
            ,@i_premium_status
            ,@i_dbt_gl_acct_id
            ,@i_dbt_gl_name
            ,@i_crd_gl_acct_id
            ,@i_crd_gl_name
            ,@i_financial_code
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
				UPDATE dbo.Misc_Trans_Definition 
				   SET misc_trans_code_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND misc_trans_code			= @i_adj_ID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_adj_ID, @i_adj_Name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM MiscellaneousTransactionCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_misc_trans_gid
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
             ,@i_modified_date
             ,@iUserID
             ,@i_entity_type
             ,@i_transaction_type
             ,@i_adj_ID
             ,@i_adj_Name
             ,@i_screen_type
             ,@i_premium_status
             ,@i_dbt_gl_acct_id
             ,@i_dbt_gl_name
             ,@i_crd_gl_acct_id
             ,@i_crd_gl_name
             ,@i_financial_code
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MiscellaneousTransactionCodes_Cursor
DEALLOCATE MiscellaneousTransactionCodes_Cursor

END
GO