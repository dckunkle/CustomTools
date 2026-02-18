/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnitClaimsRollingBalance
Purpose:    Create businessunitclaimsrollingbalance data from CorderAutomation

Screen:     1071
Method:     BusinessUnitClaimsRollingBalance
Procedure:  dbo.prChkRollingBalanceAdd
Entity:     Check_Rolling_Balance

Date        User            Change
---------------------------------------------------------------------------------------------
06/03/2024	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnitClaimsRollingBalance '100-Config%', 22, 'BusinessUnitClaimsRollingBalance'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnitClaimsRollingBalance
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

DECLARE @iEntity             VARCHAR(50)
       ,@iKeyField1          VARCHAR(50)
       ,@iKeyField2          VARCHAR(50)
       ,@iKeyField3          VARCHAR(50)
       ,@iKeyField4          VARCHAR(50)
       ,@iKeyField5          VARCHAR(50)
       ,@iKeyField6          VARCHAR(50)
       ,@iKeyField7          VARCHAR(50)
       ,@iKeyField8          VARCHAR(50)
       ,@iKeyField9          VARCHAR(50)
       ,@iKeyField10         VARCHAR(50)
       ,@iAction             VARCHAR(10)
       ,@iDateModified       VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iBusiness_Unit_ID   VARCHAR(50)
       ,@iBusiness_Unit_Name VARCHAR(50)
       ,@iBankAcct_id        VARCHAR(50)
       ,@iBankAcct_desc      VARCHAR(80)
       ,@iEOC                VARCHAR(50)
       ,@iAmount             VARCHAR(50)
       ,@oStatus             INT
       ,@oMessage            VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnitClaimsRollingBalance') IS NOT NULL
	DROP TABLE #BusinessUnitClaimsRollingBalance

CREATE TABLE #BusinessUnitClaimsRollingBalance
      (SearchID            VARCHAR(200)
      ,iEntity             VARCHAR(50)       DEFAULT('Check_Rolling_Balance')
      ,iKeyField1          VARCHAR(50)       DEFAULT('0')
      ,iKeyField2          VARCHAR(50)       DEFAULT('0')
      ,iKeyField3          VARCHAR(50)       DEFAULT('0')
      ,iKeyField4          VARCHAR(50)       DEFAULT('0')
      ,iKeyField5          VARCHAR(50)       DEFAULT('0')
      ,iKeyField6          VARCHAR(50)       DEFAULT('0')
      ,iKeyField7          VARCHAR(50)       DEFAULT('0')
      ,iKeyField8          VARCHAR(50)       DEFAULT('0')
      ,iKeyField9          VARCHAR(50)       DEFAULT('0')
      ,iKeyField10         VARCHAR(50)       DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified       VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iBusiness_Unit_ID   VARCHAR(50)
      ,iBusiness_Unit_Name VARCHAR(50)
      ,iBankAcct_id        VARCHAR(50)
      ,iBankAcct_desc      VARCHAR(80)
      ,iEOC                VARCHAR(50)
      ,iAmount             VARCHAR(50)
      ,oStatus             INT
      ,oMessage            VARCHAR(250)
      ,record_id           INT
      ,static_gid          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BusinessUnitClaimsRollingBalance
          (SearchID
          ,iBankAcct_id
          ,iAmount
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([BusinessUnitName], '')
          ,ISNULL([*BankAccountNumber], '')
          ,ISNULL([*BankAccountDesc], '')
          ,ISNULL([EOC], '')
          ,ISNULL([*Amount], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnitClaimsRollingBalance
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BusinessUnitClaimsRollingBalance
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
DECLARE BusinessUnitClaimsRollingBalance_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iKeyField1
       ,iKeyField2
       ,iKeyField3
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iBusiness_Unit_ID
       ,iBusiness_Unit_Name
       ,iBankAcct_id
       ,iBankAcct_desc
       ,iEOC
       ,iAmount
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #BusinessUnitClaimsRollingBalance

   OPEN BusinessUnitClaimsRollingBalance_Cursor
  FETCH NEXT FROM BusinessUnitClaimsRollingBalance_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iKeyField1
       ,@iKeyField2
       ,@iKeyField3
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iBusiness_Unit_ID
       ,@iBusiness_Unit_Name
       ,@iBankAcct_id
       ,@iBankAcct_desc
       ,@iEOC
       ,@iAmount
       ,@oStatus
       ,@oMessage
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

					EXEC dbo.prChkRollingBalanceAdd
						 @iEntity
						,@iKeyField1
						,@iKeyField2
						,@iKeyField3
						,@iKeyField4
						,@iKeyField5
						,@iKeyField6
						,@iKeyField7
						,@iKeyField8
						,@iKeyField9
						,@iKeyField10
						,@iAction
						,@iDateModified
						,@iUserID
						,@iBusiness_Unit_ID
						,@iBusiness_Unit_Name
						,@iBankAcct_id
						,@iBankAcct_desc
						,@iEOC
						,@iAmount
						,@oStatus     = @err_num OUTPUT
						,@oMessage    = @err_msg OUTPUT

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
					      ,@err_msg = 'Claims Level Rolling Balance is not set to No. Either set ClaimLevelRollingBalanceEnabled to No or use method BusinessUnitClaimsRollingBalanceCreditDebit to create this data.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Missing', '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BusinessUnitClaimsRollingBalance_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iKeyField1
             ,@iKeyField2
             ,@iKeyField3
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iBusiness_Unit_ID
             ,@iBusiness_Unit_Name
             ,@iBankAcct_id
             ,@iBankAcct_desc
             ,@iEOC
             ,@iAmount
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnitClaimsRollingBalance_Cursor
DEALLOCATE BusinessUnitClaimsRollingBalance_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BusinessUnitClaimsRollingBalance') IS NOT NULL
	DROP TABLE #BusinessUnitClaimsRollingBalance

END
GO

