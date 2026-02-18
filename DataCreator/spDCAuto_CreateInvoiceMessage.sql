IF OBJECT_ID('dbo.spDCAuto_CreateInvoiceMessage') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateInvoiceMessage AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateInvoiceMessage
Purpose:    Create invoicemessage data from CorderAutomation
Method:     InvoiceMessage
Screen GID: 83
Procedure:  dbo.prBARInvoice_Message_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateInvoiceMessage '100-Config%', 22, 'InvoiceMessage'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateInvoiceMessage
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

DECLARE @i_Entity_name                 VARCHAR(50)
       ,@i_Invoice_Message_Gid         VARCHAR(50)
       ,@i_key_2_field                 VARCHAR(1000)
       ,@i_key_3_field                 VARCHAR(20)
       ,@i_key_4_field                 VARCHAR(20)
       ,@i_key_5_field                 VARCHAR(50)
       ,@i_key_6_field                 VARCHAR(50)
       ,@i_key_7_field                 VARCHAR(50)
       ,@i_key_8_field                 VARCHAR(50)
       ,@i_key_9_field                 VARCHAR(50)
       ,@i_key_10_field                VARCHAR(50)
       ,@i_action                      VARCHAR(10)
       ,@l_modified_date               VARCHAR(50)
       ,@iUserID                       VARCHAR(25)
       ,@l_Invoice_Message_id          VARCHAR(50)
       ,@l_Invoice_Message_description VARCHAR(50)
       ,@l_Invoice_Message             VARCHAR(180)
       ,@l_effective_date              CHAR(20)
       ,@l_termination_date            CHAR(20)
       ,@o_status                      INT
       ,@o_message                     VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#InvoiceMessage') IS NOT NULL
	DROP TABLE #InvoiceMessage

CREATE TABLE #InvoiceMessage
      (i_Entity_name                 VARCHAR(50)       DEFAULT('Invoice_Message')
      ,i_Invoice_Message_Gid         VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field                 VARCHAR(1000)     DEFAULT('0')
      ,i_key_3_field                 VARCHAR(20)       DEFAULT('0')
      ,i_key_4_field                 VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                VARCHAR(50)       DEFAULT('0')
      ,i_action                      VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date               VARCHAR(50)       DEFAULT('')
      ,iUserID                       VARCHAR(25)       DEFAULT('')
      ,l_Invoice_Message_id          VARCHAR(50)
      ,l_Invoice_Message_description VARCHAR(50)
      ,l_Invoice_Message             VARCHAR(180)
      ,l_effective_date              CHAR(20)
      ,l_termination_date            CHAR(20)
      ,o_status                      INT
      ,o_message                     VARCHAR(100)
      ,record_id                     INT
      ,static_gid                    INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #InvoiceMessage
      (l_Invoice_Message_id
      ,l_Invoice_Message_description
      ,l_Invoice_Message
      ,l_effective_date
      ,l_termination_date
      ,record_id
      ,static_gid)
SELECT ISNULL([*InvMsgID], '')
      ,ISNULL([*InvMsgDesc], '')
      ,ISNULL([*InvoiceMessage], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_InvoiceMessage
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #InvoiceMessage
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE InvoiceMessage_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Invoice_Message_Gid
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
       ,l_modified_date
       ,iUserID
       ,l_Invoice_Message_id
       ,l_Invoice_Message_description
       ,l_Invoice_Message
       ,l_effective_date
       ,l_termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #InvoiceMessage

   OPEN InvoiceMessage_Cursor
  FETCH NEXT FROM InvoiceMessage_Cursor
   INTO @i_Entity_name
       ,@i_Invoice_Message_Gid
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
       ,@l_modified_date
       ,@iUserID
       ,@l_Invoice_Message_id
       ,@l_Invoice_Message_description
       ,@l_Invoice_Message
       ,@l_effective_date
       ,@l_termination_date
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prBARInvoice_Message_Add_Modify
             @i_Entity_name
            ,@i_Invoice_Message_Gid
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
            ,@l_modified_date
            ,@iUserID
            ,@l_Invoice_Message_id
            ,@l_Invoice_Message_description
            ,@l_Invoice_Message
            ,@l_effective_date
            ,@l_termination_date
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				SELECT @current_gid				= ISNULL(entity_gid, 0)
					FROM Entity_Names
					WHERE entity_identifier		= 'Invoice_Message'
					AND entity_user_id			= @l_Invoice_Message_id
					AND record_status			= 'A'

				UPDATE Entity_Names 
				   SET entity_gid				= @static_gid 
					WHERE entity_identifier		= 'Invoice_Message'
					AND entity_user_id			= @l_Invoice_Message_id
					AND record_status			= 'A'

				UPDATE Invoice_Message
					SET invoice_message_gid		= @static_gid
					WHERE invoice_message_gid	= @current_gid
					AND record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @l_Invoice_Message_id, @l_Invoice_Message_description, @l_Invoice_Message, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM InvoiceMessage_Cursor
         INTO @i_Entity_name
             ,@i_Invoice_Message_Gid
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
             ,@l_modified_date
             ,@iUserID
             ,@l_Invoice_Message_id
             ,@l_Invoice_Message_description
             ,@l_Invoice_Message
             ,@l_effective_date
             ,@l_termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE InvoiceMessage_Cursor
DEALLOCATE InvoiceMessage_Cursor

END
GO