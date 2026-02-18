IF OBJECT_ID('dbo.spDCAuto_CreateFundingDefinition') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateFundingDefinition AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateFundingDefinition
Purpose:    Create fundingdefinition data from CorderAutomation

Screen:     2300
Method:     FundingDefinition
Procedure:  dbo.prFundingDefinitionAddModify
Entity:     Funding_Definition

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
07/05/2022	DK				Changes for SP51 (WAHBE)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateFundingDefinition '400-Config%', 22, 'FundingDefinition'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateFundingDefinition
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

DECLARE @iEntity                             VARCHAR(50)
       ,@iKeyField1                          VARCHAR(50)
       ,@iKeyField2                          VARCHAR(50)
       ,@iKeyField3                          VARCHAR(50)
       ,@iKeyField4                          VARCHAR(10)
       ,@iKeyField5                          VARCHAR(10)
       ,@iKeyField6                          VARCHAR(20)
       ,@iKeyField7                          VARCHAR(20)
       ,@iKeyField8                          VARCHAR(20)
       ,@iKeyField9                          VARCHAR(20)
       ,@iKeyField10                         VARCHAR(20)
       ,@iAction                             VARCHAR(20)
       ,@iDateModified                       VARCHAR(50)
       ,@iUserID                             VARCHAR(25)
       ,@iFundingID                          VARCHAR(10)
       ,@iFundingDesc                        VARCHAR(50)
       ,@iFinancialCode                      VARCHAR(10)
       ,@iGroupSponsored                     VARCHAR(10)
       ,@iIsInvoiced                         VARCHAR(50)
       ,@iIsCreditCard                       VARCHAR(50)
       ,@iIsBankAccount                      VARCHAR(50)
       ,@iClaimPay                           VARCHAR(50)
       ,@iPriority                           INT
       ,@iGroupOnly                          VARCHAR(50)
       ,@iAssumeRisk                         VARCHAR(50)
       ,@iIsSubsidy                          VARCHAR(50)		-- SP51
       ,@iSubsidy_Priority                   VARCHAR(50)		-- SP51
       ,@i820PaymentTypeCodeList_ID          VARCHAR(50)		-- SP51
       ,@i820PaymentTypeCodeList_Description VARCHAR(50)		-- SP51
       ,@oStatus                             INT
       ,@oMessage                            VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#FundingDefinition') IS NOT NULL
	DROP TABLE #FundingDefinition

CREATE TABLE #FundingDefinition
      (SearchID                            VARCHAR(200)
      ,iEntity                             VARCHAR(50)       DEFAULT('Funding_Definition')
      ,iKeyField1                          VARCHAR(50)       DEFAULT('0')
      ,iKeyField2                          VARCHAR(50)       DEFAULT('0')
      ,iKeyField3                          VARCHAR(50)       DEFAULT('0')
      ,iKeyField4                          VARCHAR(10)       DEFAULT('0')
      ,iKeyField5                          VARCHAR(10)       DEFAULT('0')
      ,iKeyField6                          VARCHAR(20)       DEFAULT('0')
      ,iKeyField7                          VARCHAR(20)       DEFAULT('0')
      ,iKeyField8                          VARCHAR(20)       DEFAULT('0')
      ,iKeyField9                          VARCHAR(20)       DEFAULT('0')
      ,iKeyField10                         VARCHAR(20)       DEFAULT('0')
      ,iAction                             VARCHAR(20)       DEFAULT('ADD')
      ,iDateModified                       VARCHAR(50)       DEFAULT('')
      ,iUserID                             VARCHAR(25)       DEFAULT('')
      ,iFundingID                          VARCHAR(10)
      ,iFundingDesc                        VARCHAR(50)
      ,iFinancialCode                      VARCHAR(10)
      ,iGroupSponsored                     VARCHAR(10)
      ,iIsInvoiced                         VARCHAR(50)
      ,iIsCreditCard                       VARCHAR(50)
      ,iIsBankAccount                      VARCHAR(50)
      ,iClaimPay                           VARCHAR(50)
      ,iPriority                           INT
      ,iGroupOnly                          VARCHAR(50)
      ,iAssumeRisk                         VARCHAR(50)
      ,iIsSubsidy                          VARCHAR(50)		-- SP51
      ,iSubsidy_Priority                   VARCHAR(50)		-- SP51
      ,i820PaymentTypeCodeList_ID          VARCHAR(50)		-- SP51
      ,i820PaymentTypeCodeList_Description VARCHAR(50)		-- SP51
      ,oStatus                             INT
      ,oMessage                            VARCHAR(250)
      ,record_id                           INT
      ,static_gid                          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #FundingDefinition
          (SearchID
          ,iFundingID
          ,iFundingDesc
          ,iFinancialCode
          ,iGroupSponsored
          ,iIsInvoiced
          ,iIsCreditCard
          ,iIsBankAccount
          ,iClaimPay
          ,iPriority
          ,iGroupOnly
          ,iAssumeRisk
		  ,iIsSubsidy
          ,iSubsidy_Priority
          ,i820PaymentTypeCodeList_ID
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL([*FundingID], '')
          ,ISNULL([*FundingDesc], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FinancialCode]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GroupSponsored]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IsInvoiced]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CreditCard]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BankAccount]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UsedToPayClaims]), 'N')
          ,ISNULL([ClaimUsePriority], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AllowedOnGroupOnly]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AssumePremiumRisk]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Subsidy]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubsidyPriority]), '-1')
          ,ISNULL([Payment820TypeCodeListID], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_FundingDefinition
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #FundingDefinition
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
DECLARE FundingDefinition_Cursor CURSOR FOR
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
       ,iFundingID
       ,iFundingDesc
       ,iFinancialCode
       ,iGroupSponsored
       ,iIsInvoiced
       ,iIsCreditCard
       ,iIsBankAccount
       ,iClaimPay
       ,iPriority
       ,iGroupOnly
       ,iAssumeRisk
       ,iIsSubsidy								-- SP51
       ,iSubsidy_Priority						-- SP51
       ,i820PaymentTypeCodeList_ID				-- SP51
       ,i820PaymentTypeCodeList_Description		-- SP51
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #FundingDefinition

   OPEN FundingDefinition_Cursor
  FETCH NEXT FROM FundingDefinition_Cursor
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
       ,@iFundingID
       ,@iFundingDesc
       ,@iFinancialCode
       ,@iGroupSponsored
       ,@iIsInvoiced
       ,@iIsCreditCard
       ,@iIsBankAccount
       ,@iClaimPay
       ,@iPriority
       ,@iGroupOnly
       ,@iAssumeRisk
       ,@iIsSubsidy								-- SP51
       ,@iSubsidy_Priority						-- SP51
       ,@i820PaymentTypeCodeList_ID				-- SP51
       ,@i820PaymentTypeCodeList_Description	-- SP51
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

			EXEC dbo.prFundingDefinitionAddModify
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
                ,@iFundingID
                ,@iFundingDesc
                ,@iFinancialCode
                ,@iGroupSponsored
                ,@iIsInvoiced
                ,@iIsCreditCard
                ,@iIsBankAccount
                ,@iClaimPay
                ,@iPriority
                ,@iGroupOnly
                ,@iAssumeRisk
                ,@iIsSubsidy							-- SP51
                ,@iSubsidy_Priority						-- SP51
                ,@i820PaymentTypeCodeList_ID			-- SP51
                ,@i820PaymentTypeCodeList_Description	-- SP51
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iFundingID, @iFundingDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM FundingDefinition_Cursor
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
             ,@iFundingID
             ,@iFundingDesc
             ,@iFinancialCode
             ,@iGroupSponsored
             ,@iIsInvoiced
             ,@iIsCreditCard
             ,@iIsBankAccount
             ,@iClaimPay
             ,@iPriority
             ,@iGroupOnly
             ,@iAssumeRisk
             ,@iIsSubsidy
             ,@iSubsidy_Priority
             ,@i820PaymentTypeCodeList_ID
             ,@i820PaymentTypeCodeList_Description
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE FundingDefinition_Cursor
DEALLOCATE FundingDefinition_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#FundingDefinition') IS NOT NULL
	DROP TABLE #FundingDefinition

END
GO

