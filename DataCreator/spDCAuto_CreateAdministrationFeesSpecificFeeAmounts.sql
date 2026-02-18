IF OBJECT_ID('dbo.spDCAuto_CreateAdministrationFeesSpecificFeeAmounts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAdministrationFeesSpecificFeeAmounts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAdministrationFeesSpecificFeeAmounts
Purpose:    Create administrationfeesspecificfeeamounts data from CorderAutomation
Method:     AdministrationFeesSpecificFeeAmounts
Screen GID: 325
Procedure:  dbo.prAdminFeeAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAdministrationFeesSpecificFeeAmounts '100-Config%', 22, 'AdministrationFeesSpecificFeeAmounts'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAdministrationFeesSpecificFeeAmounts
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

DECLARE @i_Entity_name       VARCHAR(50)
       ,@i_Fee_GID           VARCHAR(50)
       ,@i_Entity_Type       VARCHAR(10)
       ,@i_charge_Key        VARCHAR(10)
       ,@i_KeyEffDate        VARCHAR(100)
       ,@i_KeyTermDate       VARCHAR(100)
       ,@i_OptData1          VARCHAR(100)
       ,@i_OptData2          VARCHAR(20)
       ,@i_OptData3          VARCHAR(100)
       ,@i_key_9_field       VARCHAR(50)
       ,@i_key_10_field      VARCHAR(20)
       ,@i_action            VARCHAR(20)
       ,@l_modified_date     VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iImportAdminFeeID   VARCHAR(50)
       ,@iImportAdminFeeDesc VARCHAR(50)
       ,@iEffDate            VARCHAR(50)
       ,@iTermDate           VARCHAR(50)
       ,@iFeeKey             VARCHAR(50)
       ,@iFinancialCode      VARCHAR(50)
       ,@iFeeType            VARCHAR(50)
       ,@iFeeAmount          VARCHAR(50)
       ,@iFeeTrigger         VARCHAR(50)
       ,@iCalculationPeriod  VARCHAR(50)
       ,@iFeeMinimum         VARCHAR(50)
       ,@iFeeMaximum         VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AdministrationFeesSpecificFeeAmounts') IS NOT NULL
	DROP TABLE #AdministrationFeesSpecificFeeAmounts

CREATE TABLE #AdministrationFeesSpecificFeeAmounts
      (SearchID            VARCHAR(200)
      ,i_Entity_name       VARCHAR(50)       DEFAULT('Admin_Fees')
      ,i_Fee_GID           VARCHAR(50)       DEFAULT('0')
      ,i_Entity_Type       VARCHAR(10)       DEFAULT('0')
      ,i_charge_Key        VARCHAR(10)       DEFAULT('0')
      ,i_KeyEffDate        VARCHAR(100)      DEFAULT('0')
      ,i_KeyTermDate       VARCHAR(100)      DEFAULT('0')
      ,i_OptData1          VARCHAR(100)      DEFAULT('0')
      ,i_OptData2          VARCHAR(20)       DEFAULT('0')
      ,i_OptData3          VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field      VARCHAR(20)       DEFAULT('0')
      ,i_action            VARCHAR(20)       DEFAULT('ADD')
      ,l_modified_date     VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iImportAdminFeeID   VARCHAR(50)
      ,iImportAdminFeeDesc VARCHAR(50)
      ,iEffDate            VARCHAR(50)
      ,iTermDate           VARCHAR(50)
      ,iFeeKey             VARCHAR(50)
      ,iFinancialCode      VARCHAR(50)
      ,iFeeType            VARCHAR(50)
      ,iFeeAmount          VARCHAR(50)
      ,iFeeTrigger         VARCHAR(50)
      ,iCalculationPeriod  VARCHAR(50)
      ,iFeeMinimum         VARCHAR(50)
      ,iFeeMaximum         VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(255)
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
INSERT INTO #AdministrationFeesSpecificFeeAmounts
      (SearchID
      ,iEffDate
      ,iTermDate
      ,iFeeKey
      ,iFinancialCode
      ,iFeeType
      ,iFeeAmount
      ,iFeeTrigger
      ,iCalculationPeriod
      ,iFeeMinimum
      ,iFeeMaximum
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FeeType]), 'NSF')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FinancialCode]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CalculationType]), 'D')
      ,ISNULL([*AmountPercent], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FeeBasis]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CalculationPeriod]), 'N')
      ,ISNULL([FeeMinimum], '0.00')
      ,ISNULL([FeeMaximum], '0.00')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AdministrationFeesSpecificFeeAmounts
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AdministrationFeesSpecificFeeAmounts
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AdministrationFeesSpecificFeeAmounts_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_Fee_GID
       ,i_Entity_Type
       ,i_charge_Key
       ,i_KeyEffDate
       ,i_KeyTermDate
       ,i_OptData1
       ,i_OptData2
       ,i_OptData3
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,iImportAdminFeeID
       ,iImportAdminFeeDesc
       ,iEffDate
       ,iTermDate
       ,iFeeKey
       ,iFinancialCode
       ,iFeeType
       ,iFeeAmount
       ,iFeeTrigger
       ,iCalculationPeriod
       ,iFeeMinimum
       ,iFeeMaximum
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AdministrationFeesSpecificFeeAmounts

   OPEN AdministrationFeesSpecificFeeAmounts_Cursor
  FETCH NEXT FROM AdministrationFeesSpecificFeeAmounts_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_Fee_GID
       ,@i_Entity_Type
       ,@i_charge_Key
       ,@i_KeyEffDate
       ,@i_KeyTermDate
       ,@i_OptData1
       ,@i_OptData2
       ,@i_OptData3
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@iImportAdminFeeID
       ,@iImportAdminFeeDesc
       ,@iEffDate
       ,@iTermDate
       ,@iFeeKey
       ,@iFinancialCode
       ,@iFeeType
       ,@iFeeAmount
       ,@iFeeTrigger
       ,@iCalculationPeriod
       ,@iFeeMinimum
       ,@iFeeMaximum
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the second search criteria only
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the trading partner
			SELECT @i_Fee_GID				= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'Admin_Fee_Name'

			EXEC dbo.prAdminFeeAddModify
             @i_Entity_name
            ,@i_Fee_GID
            ,@i_Entity_Type
            ,@i_charge_Key
            ,@i_KeyEffDate
            ,@i_KeyTermDate
            ,@i_OptData1
            ,@i_OptData2
            ,@i_OptData3
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@iImportAdminFeeID
            ,@iImportAdminFeeDesc
            ,@iEffDate
            ,@iTermDate
            ,@iFeeKey
            ,@iFinancialCode
            ,@iFeeType
            ,@iFeeAmount
            ,@iFeeTrigger
            ,@iCalculationPeriod
            ,@iFeeMinimum
            ,@iFeeMaximum
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iFinancialCode, @iFeeAmount, @status, @err_num, @err_msg

        FETCH NEXT FROM AdministrationFeesSpecificFeeAmounts_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_Fee_GID
             ,@i_Entity_Type
             ,@i_charge_Key
             ,@i_KeyEffDate
             ,@i_KeyTermDate
             ,@i_OptData1
             ,@i_OptData2
             ,@i_OptData3
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@iImportAdminFeeID
             ,@iImportAdminFeeDesc
             ,@iEffDate
             ,@iTermDate
             ,@iFeeKey
             ,@iFinancialCode
             ,@iFeeType
             ,@iFeeAmount
             ,@iFeeTrigger
             ,@iCalculationPeriod
             ,@iFeeMinimum
             ,@iFeeMaximum
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AdministrationFeesSpecificFeeAmounts_Cursor
DEALLOCATE AdministrationFeesSpecificFeeAmounts_Cursor

END
GO