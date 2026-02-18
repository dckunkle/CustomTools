IF OBJECT_ID('dbo.spDCAuto_CreateInvoicePrintRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateInvoicePrintRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateInvoicePrintRules
Purpose:    Create invoiceprintrules data from CorderAutomation
Method:     InvoicePrintRules
Screen GID: 6091
Procedure:  dbo.prInvoicePrintRuleAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateInvoicePrintRules '100-Config%', 22, 'InvoicePrintRules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateInvoicePrintRules
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

DECLARE @i_entity_name          VARCHAR(30)
       ,@i_key_1_field          VARCHAR(100)
       ,@i_key_2_field          VARCHAR(50)
       ,@i_key_3_field          VARCHAR(50)
       ,@i_key_4_field          VARCHAR(20)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(50)
       ,@i_userID               VARCHAR(25)
       ,@i_InvoicePrintRuleID   VARCHAR(50)
       ,@i_InvoicePrintRuleDesc VARCHAR(100)
       ,@i_AutoPayment          VARCHAR(50)
       ,@i_ZeroBalance          VARCHAR(50)
       ,@o_status               INT
       ,@o_message              VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#InvoicePrintRules') IS NOT NULL
	DROP TABLE #InvoicePrintRules

CREATE TABLE #InvoicePrintRules
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(30)       DEFAULT('Invoice_Print_Rule')
      ,i_key_1_field          VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(50)       DEFAULT('')
      ,i_userID               VARCHAR(25)       DEFAULT('')
      ,i_InvoicePrintRuleID   VARCHAR(50)
      ,i_InvoicePrintRuleDesc VARCHAR(100)
      ,i_AutoPayment          VARCHAR(50)
      ,i_ZeroBalance          VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #InvoicePrintRules
      (SearchID
      ,i_InvoicePrintRuleID
      ,i_InvoicePrintRuleDesc
	  ,i_AutoPayment
      ,i_ZeroBalance
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*InvoicePrintRulesID], '')
      ,ISNULL([*InvoicePrintRulesDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EnrolledinAutoPayment]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvEndBalLessOrEqualtoZero]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_InvoicePrintRules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #InvoicePrintRules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE InvoicePrintRules_Cursor CURSOR FOR
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
       ,i_userID
       ,i_InvoicePrintRuleID
       ,i_InvoicePrintRuleDesc
       ,i_AutoPayment
       ,i_ZeroBalance
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #InvoicePrintRules

   OPEN InvoicePrintRules_Cursor
  FETCH NEXT FROM InvoicePrintRules_Cursor
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
       ,@i_userID
       ,@i_InvoicePrintRuleID
       ,@i_InvoicePrintRuleDesc
       ,@i_AutoPayment
       ,@i_ZeroBalance
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prInvoicePrintRuleAddModify
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
            ,@i_userID
            ,@i_InvoicePrintRuleID
            ,@i_InvoicePrintRuleDesc
            ,@i_AutoPayment
            ,@i_ZeroBalance
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
				UPDATE dbo.InvoicePrintRules 
				   SET InvoicePrintRule_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND InvoicePrintRuleID		= @i_InvoicePrintRuleID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_InvoicePrintRuleID, @i_InvoicePrintRuleDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM InvoicePrintRules_Cursor
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
             ,@i_userID
             ,@i_InvoicePrintRuleID
             ,@i_InvoicePrintRuleDesc
             ,@i_AutoPayment
             ,@i_ZeroBalance
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE InvoicePrintRules_Cursor
DEALLOCATE InvoicePrintRules_Cursor

END
GO