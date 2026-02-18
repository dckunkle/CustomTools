IF OBJECT_ID('dbo.spDCAuto_CreatePaymentTolerance') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePaymentTolerance AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePaymentTolerance
Purpose:    Create paymenttolerance data from CorderAutomation

Date        User            Change
---------------------------------------------------------------------------------------------
10/25/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePaymentTolerance '100-Config%', 22, 'PaymentTolerance'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePaymentTolerance
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

DECLARE @i_entity_name             VARCHAR(20)
       ,@i_Payment_gid             VARCHAR(100)
       ,@i_Payment_sid             VARCHAR(50)
       ,@i_key_3_field             VARCHAR(50)
       ,@i_key_4_field             VARCHAR(50)
       ,@i_key_5_field             VARCHAR(10)
       ,@i_key_6_field             VARCHAR(10)
       ,@i_key_7_field             VARCHAR(50)
       ,@i_key_8_field             VARCHAR(50)
       ,@i_key_9_field             VARCHAR(50)
       ,@i_key_10_field            VARCHAR(50)
       ,@i_action                  VARCHAR(10)
       ,@i_date_time_modified      VARCHAR(50)
       ,@i_UserID                  VARCHAR(25)
       ,@i_Pay_Tol_ID              VARCHAR(30)
       ,@i_Pay_Tol_Desc            VARCHAR(100)
       ,@i_claims_tolerance_pct    VARCHAR(10)
       ,@i_claims_tolerance_dollar VARCHAR(10)
       ,@o_status                  INT
       ,@o_message                 VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PaymentTolerance') IS NOT NULL
	DROP TABLE #PaymentTolerance

CREATE TABLE #PaymentTolerance
      (i_entity_name             VARCHAR(20)       DEFAULT('PaymentTolerance')
      ,i_Payment_gid             VARCHAR(100)       DEFAULT('0')
      ,i_Payment_sid             VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field             VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field             VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field             VARCHAR(10)       DEFAULT('0')
      ,i_key_6_field             VARCHAR(10)       DEFAULT('0')
      ,i_key_7_field             VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field             VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field             VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field            VARCHAR(50)       DEFAULT('0')
      ,i_action                  VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified      VARCHAR(50)       DEFAULT('')
      ,i_UserID                  VARCHAR(25)       DEFAULT('')
      ,i_Pay_Tol_ID              VARCHAR(30)
      ,i_Pay_Tol_Desc            VARCHAR(100)
      ,i_claims_tolerance_pct    VARCHAR(10)
      ,i_claims_tolerance_dollar VARCHAR(10)
      ,o_status                  INT
      ,o_message                 VARCHAR(100)
      ,record_id                 INT
      ,static_gid                INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PaymentTolerance
      (i_Pay_Tol_ID
      ,i_Pay_Tol_Desc
      ,i_claims_tolerance_pct
      ,i_claims_tolerance_dollar
      ,record_id
      ,static_gid)
SELECT ISNULL([*PaymentToleranceID], '')
      ,ISNULL([*PaymentToleranceDesc], '')
      ,ISNULL([PremPayTolerancePercent], '0.00')
      ,ISNULL([PremPayToleranceDollar], '0.00')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PaymentTolerance
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PaymentTolerance
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PaymentTolerance_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_Payment_gid
       ,i_Payment_sid
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
       ,i_UserID
       ,i_Pay_Tol_ID
       ,i_Pay_Tol_Desc
       ,i_claims_tolerance_pct
       ,i_claims_tolerance_dollar
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PaymentTolerance

   OPEN PaymentTolerance_Cursor
  FETCH NEXT FROM PaymentTolerance_Cursor
   INTO @i_entity_name
       ,@i_Payment_gid
       ,@i_Payment_sid
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
       ,@i_UserID
       ,@i_Pay_Tol_ID
       ,@i_Pay_Tol_Desc
       ,@i_claims_tolerance_pct
       ,@i_claims_tolerance_dollar
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prPayment_ToleranceAddModify
             @i_entity_name
            ,@i_Payment_gid
            ,@i_Payment_sid
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
            ,@i_UserID
            ,@i_Pay_Tol_ID
            ,@i_Pay_Tol_Desc
            ,@i_claims_tolerance_pct
            ,@i_claims_tolerance_dollar
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

		SET @err_num = ISNULL(@err_num, 0)

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Get the current gid
				SELECT @current_gid				= payment_tolerance_gid
				  FROM dbo.Payment_Tolerance
				 WHERE record_status			= 'A'
				   AND payment_tol_id			= @i_Pay_Tol_ID

				-- Update to the static gid
				UPDATE dbo.Payment_Tolerance 
				   SET payment_tolerance_gid	= @static_gid 
				 WHERE payment_tolerance_gid	= @current_gid
			END

		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Pay_Tol_ID, @i_Pay_Tol_Desc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM PaymentTolerance_Cursor
         INTO @i_entity_name
             ,@i_Payment_gid
             ,@i_Payment_sid
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
             ,@i_UserID
             ,@i_Pay_Tol_ID
             ,@i_Pay_Tol_Desc
             ,@i_claims_tolerance_pct
             ,@i_claims_tolerance_dollar
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PaymentTolerance_Cursor
DEALLOCATE PaymentTolerance_Cursor

END
GO