/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnitClaimsRollingBalanceCreditDebit
Purpose:    Create businessunitclaimsrollingbalancecreditdebit data from CorderAutomation

Screen:     11021
Method:     BusinessUnitClaimsRollingBalanceCreditDebit
Procedure:  dbo.prManualCreditDebitAdd
Entity:     ManualCreditDebitAdd

Date        User            Change
---------------------------------------------------------------------------------------------
06/03/2024	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnitClaimsRollingBalanceCreditDebit '100-Config%', 22, 'BusinessUnitClaimsRollingBalanceCreditDebit'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnitClaimsRollingBalanceCreditDebit
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern						VARCHAR(200)
	   ,@log_id							INT
	   ,@test_case_name					VARCHAR(200)
	   ,@method							VARCHAR(200)
	   ,@user							VARCHAR(200)

	   ,@record_id						INT
	   ,@gid							INT
	   ,@err_msg						VARCHAR(4000)
       ,@err_num						INT
	   ,@status							VARCHAR(25)

	   ,@current_gid					INT
	   ,@static_gid						INT
	   ,@SearchID						VARCHAR(200)
	   ,@claim_level_rolling_balance	VARCHAR(2)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_key_1_field        VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(75)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_key_11_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserid              VARCHAR(25)
       ,@iEntityType          VARCHAR(50)
       ,@iEntityID            VARCHAR(128)
       ,@iBankAccountNbr      VARCHAR(50)
       ,@iBankAcctDesc        VARCHAR(80)
       ,@iAmount              MONEY(8)
       ,@iReceivableCreated   DATETIME
       ,@iReason              VARCHAR(50)
       ,@iRecoupStatus        VARCHAR(50)
       ,@iExtendedUntil       VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnitClaimsRollingBalanceCreditDebit') IS NOT NULL
	DROP TABLE #BusinessUnitClaimsRollingBalanceCreditDebit

CREATE TABLE #BusinessUnitClaimsRollingBalanceCreditDebit
      (SearchID             VARCHAR(200)
      ,i_key_1_field        VARCHAR(50)       DEFAULT('ManualCreditDebitAdd')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_11_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(200)       DEFAULT('')
      ,iUserid              VARCHAR(25)       DEFAULT('')
      ,iEntityType          VARCHAR(50)
      ,iEntityID            VARCHAR(128)
      ,iBankAccountNbr      VARCHAR(50)
      ,iBankAcctDesc        VARCHAR(80)
      ,iAmount              MONEY(8)
      ,iReceivableCreated   DATETIME
      ,iReason              VARCHAR(50)
      ,iRecoupStatus        VARCHAR(50)
      ,iExtendedUntil       VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BusinessUnitClaimsRollingBalanceCreditDebit
          (SearchID
          ,iBankAccountNbr
          ,iAmount
          ,iReceivableCreated
          ,iReason
          ,iRecoupStatus
          ,iExtendedUntil
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([PayeeID], '')
          ,ISNULL([*BankAccountNumber], '')
          ,ISNULL([*BankAccountDesc], '')
          ,ISNULL([Amount], '0')
          ,ISNULL([*ReceivableCreated], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*AdjReasonCode], '')
          ,ISNULL([*RecoupStatus], '')
          ,ISNULL([*ExtensionDate], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnitClaimsRollingBalanceCreditDebit
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BusinessUnitClaimsRollingBalanceCreditDebit
       SET iUserID  = @user


END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BusinessUnitClaimsRollingBalanceCreditDebit_Cursor CURSOR FOR
 SELECT SearchID
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
       ,i_key_11_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserid
       ,iEntityType
       ,iEntityID
       ,iBankAccountNbr
       ,iBankAcctDesc
       ,iAmount
       ,iReceivableCreated
       ,iReason
       ,iRecoupStatus
       ,iExtendedUntil
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BusinessUnitClaimsRollingBalanceCreditDebit

   OPEN BusinessUnitClaimsRollingBalanceCreditDebit_Cursor
  FETCH NEXT FROM BusinessUnitClaimsRollingBalanceCreditDebit_Cursor
   INTO @SearchID
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
       ,@i_key_11_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserid
       ,@iEntityType
       ,@iEntityID
       ,@iBankAccountNbr
       ,@iBankAcctDesc
       ,@iAmount
       ,@iReceivableCreated
       ,@iReason
       ,@iRecoupStatus
       ,@iExtendedUntil
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @claim_level_rolling_balance		= GV.variable_value
			  FROM dbo.Global_Values				GV
			 WHERE GV.variable_name					= 'ClaimLevelRollingBalanceEnabled'

			IF @claim_level_rolling_balance = 'N'
				BEGIN

					EXEC dbo.prManualCreditDebitAdd
						 @i_key_1_field
						,@i_key_2_field
						,@i_key_3_field
						,@i_key_4_field
						,@i_key_5_field
						,@i_key_6_field
						,@i_key_7_field
						,@i_key_8_field
						,@i_key_9_field
						,@i_key_10_field
						,@i_key_11_field
						,@i_action
						,@i_Date_Time_Modified
						,@iUserid
						,@iEntityType
						,@iEntityID
						,@iBankAccountNbr
						,@iBankAcctDesc
						,@iAmount
						,@iReceivableCreated
						,@iReason
						,@iRecoupStatus
						,@iExtendedUntil
						,@o_status     = @err_num OUTPUT
						,@o_message    = @err_msg OUTPUT

				-- Update the GIDs
				IF ISNULL(@static_gid, 0) != 0
					BEGIN

						-- Update to the static gid
						UPDATE dbo.SomeTable 
						   SET entity_gid				= @static_gid 
						 WHERE record_status			= 'A'

					END
				END
			ELSE
				BEGIN
					SELECT @err_num = 2304
					      ,@err_msg = 'Claims Level Rolling Balance is not set to Yes. Either set ClaimLevelRollingBalanceEnabled to Yes or use method BusinessUnitClaimsRollingBalance to create this data.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Missing', '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BusinessUnitClaimsRollingBalanceCreditDebit_Cursor
         INTO @SearchID
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
             ,@i_key_11_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserid
             ,@iEntityType
             ,@iEntityID
             ,@iBankAccountNbr
             ,@iBankAcctDesc
             ,@iAmount
             ,@iReceivableCreated
             ,@iReason
             ,@iRecoupStatus
             ,@iExtendedUntil
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnitClaimsRollingBalanceCreditDebit_Cursor
DEALLOCATE BusinessUnitClaimsRollingBalanceCreditDebit_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BusinessUnitClaimsRollingBalanceCreditDebit') IS NOT NULL
	DROP TABLE #BusinessUnitClaimsRollingBalanceCreditDebit

END
GO

