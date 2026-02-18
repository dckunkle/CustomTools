IF OBJECT_ID('dbo.spDCAuto_CreateGroupGroupFundingAssignments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupGroupFundingAssignments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupGroupFundingAssignments
Purpose:    Create groupgroupfundingassignments data from CorderAutomation
Method:     GroupGroupFundingAssignments
Screen GID: 2305
Procedure:  dbo.prFundingGroupAssignAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupGroupFundingAssignments '100-Config%', 22, 'GroupGroupFundingAssignments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupGroupFundingAssignments
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

DECLARE @iEntity                    VARCHAR(50)
       ,@iRecordSID                 VARCHAR(50)
       ,@iKeyEntityType             VARCHAR(50)
       ,@iKeyChildGID               VARCHAR(50)
       ,@iKeyParentGID              VARCHAR(50)
       ,@iKeyGroupGID               VARCHAR(50)
       ,@iKeyEffDate                VARCHAR(50)
       ,@iKeyTermDate               VARCHAR(50)
       ,@iKeyFundingID              VARCHAR(50)
       ,@iOldABA                    VARCHAR(50)
       ,@iOldAcct                   VARCHAR(50)
       ,@iAction                    VARCHAR(10)
       ,@iDateModified              VARCHAR(50)
       ,@iUserID                    VARCHAR(25)
       ,@iEntityID                  VARCHAR(50)
       ,@iEntityName                VARCHAR(50)
       ,@iEffDate                   VARCHAR(50)
       ,@iTermDate                  VARCHAR(50)
       ,@iFundingID                 VARCHAR(50)
       ,@iFundingAmount             VARCHAR(50)
       ,@iPlanYear                  VARCHAR(50)
       ,@iRecognition               VARCHAR(50)
       ,@iPremiumPay                VARCHAR(50)
       ,@iClaimPay                  VARCHAR(50)
       ,@iProRate                   VARCHAR(50)
       ,@iProRateExc                VARCHAR(50)
       ,@iCarryOver                 VARCHAR(50)
       ,@iCarryLimit                VARCHAR(50)
       ,@iGracePeriod               INT
       ,@iInvoiceUnvail             VARCHAR(50)
       ,@iTopUpMax                  VARCHAR(50)
       ,@iAPTC_CSR_Proration_Method VARCHAR(50)
       ,@i_Acct_Type                VARCHAR(50)
       ,@i_Acct_Name                VARCHAR(100)
       ,@i_ABA_Number               VARCHAR(50)
       ,@i_Institution_Name         VARCHAR(50)
       ,@i_Acct_Number              VARCHAR(50)
       ,@i_CC_Auth_Number           VARCHAR(50)
       ,@i_CC_Month                 VARCHAR(50)
       ,@i_CC_Year                  VARCHAR(50)
       ,@i_Acct_Dist                VARCHAR(50)
       ,@iAccountVerified           VARCHAR(50)
       ,@oStatus                    INT
       ,@oMessage                   VARCHAR(250)
       ,@iTransSource               VARCHAR(50)
       ,@return_xml                 XML

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupGroupFundingAssignments') IS NOT NULL
	DROP TABLE #GroupGroupFundingAssignments

CREATE TABLE #GroupGroupFundingAssignments
      (SearchID                   VARCHAR(200)
      ,iEntity                    VARCHAR(50)       DEFAULT('Funding_Group_Assign')
      ,iRecordSID                 VARCHAR(50)       DEFAULT('0')
      ,iKeyEntityType             VARCHAR(50)       DEFAULT('0')
      ,iKeyChildGID               VARCHAR(50)       DEFAULT('0')
      ,iKeyParentGID              VARCHAR(50)       DEFAULT('0')
      ,iKeyGroupGID               VARCHAR(50)       DEFAULT('0')
      ,iKeyEffDate                VARCHAR(50)       DEFAULT('0')
      ,iKeyTermDate               VARCHAR(50)       DEFAULT('0')
      ,iKeyFundingID              VARCHAR(50)       DEFAULT('0')
      ,iOldABA                    VARCHAR(50)       DEFAULT('0')
      ,iOldAcct                   VARCHAR(50)       DEFAULT('0')
      ,iAction                    VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified              VARCHAR(50)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,iEntityID                  VARCHAR(50)
      ,iEntityName                VARCHAR(50)
      ,iEffDate                   VARCHAR(50)
      ,iTermDate                  VARCHAR(50)
      ,iFundingID                 VARCHAR(50)
      ,iFundingAmount             VARCHAR(50)
      ,iPlanYear                  VARCHAR(50)
      ,iRecognition               VARCHAR(50)
      ,iPremiumPay                VARCHAR(50)
      ,iClaimPay                  VARCHAR(50)
      ,iProRate                   VARCHAR(50)
      ,iProRateExc                VARCHAR(50)
      ,iCarryOver                 VARCHAR(50)
      ,iCarryLimit                VARCHAR(50)
      ,iGracePeriod               INT
      ,iInvoiceUnvail             VARCHAR(50)
      ,iTopUpMax                  VARCHAR(50)
      ,iAPTC_CSR_Proration_Method VARCHAR(50)
      ,i_Acct_Type                VARCHAR(50)
      ,i_Acct_Name                VARCHAR(100)
      ,i_ABA_Number               VARCHAR(50)
      ,i_Institution_Name         VARCHAR(50)
      ,i_Acct_Number              VARCHAR(50)
      ,i_CC_Auth_Number           VARCHAR(50)
      ,i_CC_Month                 VARCHAR(50)
      ,i_CC_Year                  VARCHAR(50)
      ,i_Acct_Dist                VARCHAR(50)
      ,iAccountVerified           VARCHAR(50)
      ,oStatus                    INT
      ,oMessage                   VARCHAR(250)
      ,iTransSource               VARCHAR(50)
      ,return_xml                 XML
      ,record_id                  INT
      ,static_gid                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupGroupFundingAssignments
      (SearchID
      ,iEntityID
      ,iEffDate
      ,iTermDate
      ,iFundingID
      ,iFundingAmount
      ,iPlanYear
      ,iRecognition
      ,iPremiumPay
      ,iClaimPay
      ,iProRate
      ,iProRateExc
      ,iCarryOver
      ,iCarryLimit
      ,iGracePeriod
      ,iInvoiceUnvail
      ,iTopUpMax
      ,iAPTC_CSR_Proration_Method
      ,i_Acct_Type
      ,i_Acct_Name
      ,i_ABA_Number
      ,i_Acct_Number
      ,i_CC_Auth_Number
      ,i_CC_Month
      ,i_CC_Year
      ,i_Acct_Dist
      ,iAccountVerified
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_GroupID], '')
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_FundingSource]), '')
      ,ISNULL([*Common_FundingAmt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PlanYearType]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PrepaymentRecog]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseforPremiumPmt]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseforClaimPmt]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HCSAProratMethod]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ProratExcep]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CarryFwdAllowed]), 'N')
      ,ISNULL([Common_CarryFwdLimit], '0.00')
      ,ISNULL([Common_CarryFwdGraceDays], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_InvoiceGrpforOverAmt]), 'N')
      ,ISNULL([Common_TopUpMax], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_APTC/CSRProratMethod]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BCC_AccountType]), '')
      ,ISNULL([BCC_NameonAcct], '')
      ,ISNULL([BCC_ABANumber], '')
      ,ISNULL([BCC_AccountNum], '')
      ,ISNULL([BCC_CardAuthNum], '')
      ,ISNULL([BCC_CardExpMon], '')
      ,ISNULL([BCC_CardExpYear], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BCC_AcctDistn]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BCC_BankingPreNoteVeri]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupGroupFundingAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupGroupFundingAssignments
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupGroupFundingAssignments_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iRecordSID
       ,iKeyEntityType
       ,iKeyChildGID
       ,iKeyParentGID
       ,iKeyGroupGID
       ,iKeyEffDate
       ,iKeyTermDate
       ,iKeyFundingID
       ,iOldABA
       ,iOldAcct
       ,iAction
       ,iDateModified
       ,iUserID
       ,iEntityID
       ,iEntityName
       ,iEffDate
       ,iTermDate
       ,iFundingID
       ,iFundingAmount
       ,iPlanYear
       ,iRecognition
       ,iPremiumPay
       ,iClaimPay
       ,iProRate
       ,iProRateExc
       ,iCarryOver
       ,iCarryLimit
       ,iGracePeriod
       ,iInvoiceUnvail
       ,iTopUpMax
       ,iAPTC_CSR_Proration_Method
       ,i_Acct_Type
       ,i_Acct_Name
       ,i_ABA_Number
       ,i_Institution_Name
       ,i_Acct_Number
       ,i_CC_Auth_Number
       ,i_CC_Month
       ,i_CC_Year
       ,i_Acct_Dist
       ,iAccountVerified
       ,oStatus
       ,oMessage
       ,iTransSource
       ,return_xml
       ,record_id
       ,static_gid
   FROM #GroupGroupFundingAssignments

   OPEN GroupGroupFundingAssignments_Cursor
  FETCH NEXT FROM GroupGroupFundingAssignments_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iRecordSID
       ,@iKeyEntityType
       ,@iKeyChildGID
       ,@iKeyParentGID
       ,@iKeyGroupGID
       ,@iKeyEffDate
       ,@iKeyTermDate
       ,@iKeyFundingID
       ,@iOldABA
       ,@iOldAcct
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iEntityID
       ,@iEntityName
       ,@iEffDate
       ,@iTermDate
       ,@iFundingID
       ,@iFundingAmount
       ,@iPlanYear
       ,@iRecognition
       ,@iPremiumPay
       ,@iClaimPay
       ,@iProRate
       ,@iProRateExc
       ,@iCarryOver
       ,@iCarryLimit
       ,@iGracePeriod
       ,@iInvoiceUnvail
       ,@iTopUpMax
       ,@iAPTC_CSR_Proration_Method
       ,@i_Acct_Type
       ,@i_Acct_Name
       ,@i_ABA_Number
       ,@i_Institution_Name
       ,@i_Acct_Number
       ,@i_CC_Auth_Number
       ,@i_CC_Month
       ,@i_CC_Year
       ,@i_Acct_Dist
       ,@iAccountVerified
       ,@oStatus
       ,@oMessage
       ,@iTransSource
       ,@return_xml
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Set the group ID
			SELECT @iEntityID = @SearchID

			EXEC dbo.prFundingGroupAssignAddModify
             @iEntity
            ,@iRecordSID
            ,@iKeyEntityType
            ,@iKeyChildGID
            ,@iKeyParentGID
            ,@iKeyGroupGID
            ,@iKeyEffDate
            ,@iKeyTermDate
            ,@iKeyFundingID
            ,@iOldABA
            ,@iOldAcct
            ,@iAction
            ,@iDateModified
            ,@iUserID
            ,@iEntityID
            ,@iEntityName
            ,@iEffDate
            ,@iTermDate
            ,@iFundingID
            ,@iFundingAmount
            ,@iPlanYear
            ,@iRecognition
            ,@iPremiumPay
            ,@iClaimPay
            ,@iProRate
            ,@iProRateExc
            ,@iCarryOver
            ,@iCarryLimit
            ,@iGracePeriod
            ,@iInvoiceUnvail
            ,@iTopUpMax
            ,@iAPTC_CSR_Proration_Method
            ,@i_Acct_Type
            ,@i_Acct_Name
            ,@i_ABA_Number
            ,@i_Institution_Name
            ,@i_Acct_Number
            ,@i_CC_Auth_Number
            ,@i_CC_Month
            ,@i_CC_Year
            ,@i_Acct_Dist
            ,@iAccountVerified
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iFundingID, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupGroupFundingAssignments_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iRecordSID
             ,@iKeyEntityType
             ,@iKeyChildGID
             ,@iKeyParentGID
             ,@iKeyGroupGID
             ,@iKeyEffDate
             ,@iKeyTermDate
             ,@iKeyFundingID
             ,@iOldABA
             ,@iOldAcct
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iEntityID
             ,@iEntityName
             ,@iEffDate
             ,@iTermDate
             ,@iFundingID
             ,@iFundingAmount
             ,@iPlanYear
             ,@iRecognition
             ,@iPremiumPay
             ,@iClaimPay
             ,@iProRate
             ,@iProRateExc
             ,@iCarryOver
             ,@iCarryLimit
             ,@iGracePeriod
             ,@iInvoiceUnvail
             ,@iTopUpMax
             ,@iAPTC_CSR_Proration_Method
             ,@i_Acct_Type
             ,@i_Acct_Name
             ,@i_ABA_Number
             ,@i_Institution_Name
             ,@i_Acct_Number
             ,@i_CC_Auth_Number
             ,@i_CC_Month
             ,@i_CC_Year
             ,@i_Acct_Dist
             ,@iAccountVerified
             ,@oStatus
             ,@oMessage
             ,@iTransSource
             ,@return_xml
             ,@record_id
             ,@static_gid
	END

CLOSE GroupGroupFundingAssignments_Cursor
DEALLOCATE GroupGroupFundingAssignments_Cursor

END
GO