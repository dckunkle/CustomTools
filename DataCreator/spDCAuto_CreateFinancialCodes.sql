IF OBJECT_ID('dbo.spDCAuto_CreateFinancialCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateFinancialCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateFinancialCodes
Purpose:    Create financialcodes data from CorderAutomation
Method:     FinancialCodes
Screen GID: 813
Procedure:  dbo.prFinancialCodeAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/04/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateFinancialCodes '100-Config%', 22, 'FinancialCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateFinancialCodes
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

DECLARE @iEntity                   VARCHAR(20)
       ,@iKeyField1                VARCHAR(100)
       ,@iKeyField2                VARCHAR(50)
       ,@iKeyField3                VARCHAR(30)
       ,@iKeyField4                VARCHAR(10)
       ,@iKeyField5                VARCHAR(20)
       ,@iKeyField6                VARCHAR(30)
       ,@iKeyField7                VARCHAR(30)
       ,@iKeyField8                VARCHAR(50)
       ,@iKeyField9                VARCHAR(30)
       ,@iKeyField10               VARCHAR(30)
       ,@iAction                   VARCHAR(20)
       ,@iDateModified             VARCHAR(20)
       ,@iUserID                   VARCHAR(25)
       ,@iCode_ID                  VARCHAR(50)
       ,@iCode_Desc                VARCHAR(50)
       ,@iBill_To                  VARCHAR(50)
       ,@iCalculate_Retro          VARCHAR(50)
       ,@iPrimary_Commissionable   VARCHAR(50)
       ,@iSecondary_Commissionable VARCHAR(50)
       ,@iAdvance_PTD              VARCHAR(50)
       ,@iTreatment_Default        VARCHAR(50)
       ,@iReporting                VARCHAR(50)
       ,@iBalanceType              VARCHAR(50)
       ,@iTaxRelated               VARCHAR(50)
       ,@iReconLevel               VARCHAR(50)
       ,@iCashWithAppDefault       VARCHAR(50)
       ,@oStatus                   INT
       ,@oMessage                  VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#FinancialCodes') IS NOT NULL
	DROP TABLE #FinancialCodes

CREATE TABLE #FinancialCodes
      (iEntity                   VARCHAR(20)       DEFAULT('Financial_Codes')
      ,iKeyField1                VARCHAR(100)      DEFAULT('0')
      ,iKeyField2                VARCHAR(50)       DEFAULT('0')
      ,iKeyField3                VARCHAR(30)       DEFAULT('0')
      ,iKeyField4                VARCHAR(10)       DEFAULT('0')
      ,iKeyField5                VARCHAR(20)       DEFAULT('0')
      ,iKeyField6                VARCHAR(30)       DEFAULT('0')
      ,iKeyField7                VARCHAR(30)       DEFAULT('0')
      ,iKeyField8                VARCHAR(50)       DEFAULT('0')
      ,iKeyField9                VARCHAR(30)       DEFAULT('0')
      ,iKeyField10               VARCHAR(30)       DEFAULT('0')
      ,iAction                   VARCHAR(20)       DEFAULT('ADD')
      ,iDateModified             VARCHAR(20)       DEFAULT('')
      ,iUserID                   VARCHAR(25)       DEFAULT('')
      ,iCode_ID                  VARCHAR(50)
      ,iCode_Desc                VARCHAR(50)
      ,iBill_To                  VARCHAR(50)
      ,iCalculate_Retro          VARCHAR(50)
      ,iPrimary_Commissionable   VARCHAR(50)
      ,iSecondary_Commissionable VARCHAR(50)
      ,iAdvance_PTD              VARCHAR(50)
      ,iTreatment_Default        VARCHAR(50)
      ,iReporting                VARCHAR(50)
      ,iBalanceType              VARCHAR(50)
      ,iTaxRelated               VARCHAR(50)
      ,iReconLevel               VARCHAR(50)
      ,iCashWithAppDefault       VARCHAR(50)
      ,oStatus                   INT
      ,oMessage                  VARCHAR(250)
      ,record_id                 INT
      ,static_gid                INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #FinancialCodes
      (iCode_ID
      ,iCode_Desc
      ,iBill_To
      ,iCalculate_Retro
      ,iPrimary_Commissionable
      ,iSecondary_Commissionable
      ,iAdvance_PTD
      ,iTreatment_Default
      ,iReporting
      ,iBalanceType
      ,iTaxRelated
      ,iReconLevel
      ,iCashWithAppDefault
      ,record_id
      ,static_gid)
SELECT ISNULL([*CodeID], '')
      ,ISNULL([*CodeDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BillTo]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CalculateRetro]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PrimaryCommissionable]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SecondaryCommissionable]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AdvancePTD]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TreatmentDefault]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Reporting]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApplyTo]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TaxRelated]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReconciliationLevel]), 'G')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DefaultCashWithApp]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_FinancialCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #FinancialCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE FinancialCodes_Cursor CURSOR FOR
 SELECT iEntity
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
       ,iCode_ID
       ,iCode_Desc
       ,iBill_To
       ,iCalculate_Retro
       ,iPrimary_Commissionable
       ,iSecondary_Commissionable
       ,iAdvance_PTD
       ,iTreatment_Default
       ,iReporting
       ,iBalanceType
       ,iTaxRelated
       ,iReconLevel
       ,iCashWithAppDefault
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #FinancialCodes

   OPEN FinancialCodes_Cursor
  FETCH NEXT FROM FinancialCodes_Cursor
   INTO @iEntity
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
       ,@iCode_ID
       ,@iCode_Desc
       ,@iBill_To
       ,@iCalculate_Retro
       ,@iPrimary_Commissionable
       ,@iSecondary_Commissionable
       ,@iAdvance_PTD
       ,@iTreatment_Default
       ,@iReporting
       ,@iBalanceType
       ,@iTaxRelated
       ,@iReconLevel
       ,@iCashWithAppDefault
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prFinancialCodeAddModify
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
            ,@iCode_ID
            ,@iCode_Desc
            ,@iBill_To
            ,@iCalculate_Retro
            ,@iPrimary_Commissionable
            ,@iSecondary_Commissionable
            ,@iAdvance_PTD
            ,@iTreatment_Default
            ,@iReporting
            ,@iBalanceType
            ,@iTaxRelated
            ,@iReconLevel
            ,@iCashWithAppDefault
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iCode_ID, @iCode_Desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM FinancialCodes_Cursor
         INTO @iEntity
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
             ,@iCode_ID
             ,@iCode_Desc
             ,@iBill_To
             ,@iCalculate_Retro
             ,@iPrimary_Commissionable
             ,@iSecondary_Commissionable
             ,@iAdvance_PTD
             ,@iTreatment_Default
             ,@iReporting
             ,@iBalanceType
             ,@iTaxRelated
             ,@iReconLevel
             ,@iCashWithAppDefault
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE FinancialCodes_Cursor
DEALLOCATE FinancialCodes_Cursor

END
GO