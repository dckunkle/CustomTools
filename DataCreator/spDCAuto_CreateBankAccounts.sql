IF OBJECT_ID('dbo.spDCAuto_CreateBankAccounts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBankAccounts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBankAccounts
Purpose:    Create bank account data from CorderAutomation
Method:     BankAccounts
Screen GID: 90
Procedure:  dbo.prBank_Acct_Table_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBankAccounts '100-Config%', 22, '100-Configuration', 'BankAccounts', '100AutoConfig'
***************************************************************************************************/
ALTER PROCEDURE [dbo].[spDCAuto_CreateBankAccounts]
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

DECLARE @iEntityName             VARCHAR(50)
       ,@iBankAccountGid         VARCHAR(100)
       ,@iContactRelationGid     VARCHAR(50)
       ,@iBankGid                VARCHAR(50)
       ,@iKey4Field              VARCHAR(20)
       ,@iKey5Field              VARCHAR(20)
       ,@iKey6Field              VARCHAR(10)
       ,@iKey7Field              VARCHAR(10)
       ,@iKey8Field              VARCHAR(20)
       ,@iKey9Field              VARCHAR(50)
       ,@iKey10Field             VARCHAR(50)
       ,@iAction                 VARCHAR(10)
       ,@iModifiedDate           VARCHAR(10)
       ,@iUserID                 VARCHAR(100)
       ,@iBankAccountNumber      VARCHAR(10)
       ,@iBankAccountDesc        VARCHAR(50)
       ,@iBankAbaNumber          VARCHAR(50)
       ,@iBankDesc               VARCHAR(80)
       ,@iAccountType            VARCHAR(50)
       ,@iAccountDistinction     VARCHAR(20)
       ,@iNextAvailCheckNum      VARCHAR(20)
       ,@iNextAvailAchNum        BIGINT
       ,@iAchId                  VARCHAR(10)
       ,@iSuspenseGroupID        VARCHAR(50)
       ,@iSuspenseGroupName      VARCHAR(255)
       ,@iLockBox                VARCHAR(50)
       ,@iAppFinCode             VARCHAR(10)
       ,@iCcFilePrefix           VARCHAR(10)
       ,@iCcFileUser             VARCHAR(15)
       ,@iMerchantListId         VARCHAR(50)
       ,@iMerchantListDesc       VARCHAR(50)
       ,@iPositivePayCheckNumber CHAR(1)
       ,@iExtractOn835           CHAR(1)
       ,@oStatus                 INT
       ,@oMessage                VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BankAccounts') IS NOT NULL
	DROP TABLE #BankAccounts

CREATE TABLE #BankAccounts
      (iEntityName             VARCHAR(50)       DEFAULT('Bank_Acct_Table')
      ,iBankAccountGid         VARCHAR(100)      DEFAULT('0')
      ,iContactRelationGid     VARCHAR(50)       DEFAULT('0')
      ,iBankGid                VARCHAR(50)       DEFAULT('0')
      ,iKey4Field              VARCHAR(20)       DEFAULT('0')
      ,iKey5Field              VARCHAR(20)       DEFAULT('0')
      ,iKey6Field              VARCHAR(10)       DEFAULT('0')
      ,iKey7Field              VARCHAR(10)       DEFAULT('0')
      ,iKey8Field              VARCHAR(20)       DEFAULT('0')
      ,iKey9Field              VARCHAR(50)       DEFAULT('0')
      ,iKey10Field             VARCHAR(50)       DEFAULT('0')
      ,iAction                 VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate           VARCHAR(10)       DEFAULT('')
      ,iUserID                 VARCHAR(100)      DEFAULT('')
      ,iBankAccountNumber      VARCHAR(10)
      ,iBankAccountDesc        VARCHAR(50)
      ,iBankAbaNumber          VARCHAR(50)
      ,iBankDesc               VARCHAR(80)
      ,iAccountType            VARCHAR(50)
      ,iAccountDistinction     VARCHAR(20)
      ,iNextAvailCheckNum      VARCHAR(20)
      ,iNextAvailAchNum        BIGINT
      ,iAchId                  VARCHAR(10)
      ,iSuspenseGroupID        VARCHAR(50)
      ,iSuspenseGroupName      VARCHAR(255)
      ,iLockBox                VARCHAR(50)
      ,iAppFinCode             VARCHAR(10)
      ,iCcFilePrefix           VARCHAR(10)
      ,iCcFileUser             VARCHAR(15)
      ,iMerchantListId         VARCHAR(50)
      ,iMerchantListDesc       VARCHAR(50)
      ,iPositivePayCheckNumber CHAR(1)
      ,iExtractOn835           CHAR(1)
      ,oStatus                 INT
      ,oMessage                VARCHAR(255)
      ,record_id               INT
      ,static_gid              INT
	  ,ABANumberSearch		   VARCHAR(20))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BankAccounts
      (iBankAccountNumber
      ,iBankAccountDesc
	  ,iBankAbaNumber
      ,iAccountType
      ,iAccountDistinction
      ,iNextAvailCheckNum
      ,iNextAvailAchNum
      ,iAchId
      ,iSuspenseGroupID
      ,iLockBox
      ,iAppFinCode
      ,iCcFilePrefix
      ,iCcFileUser
      ,iMerchantListId
      ,iPositivePayCheckNumber
      ,iExtractOn835
      ,record_id
      ,static_gid)
SELECT ISNULL([*BankAcctNumber], '')
      ,ISNULL([*NameOnAccount], '')
	  ,SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AccountType]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AccountDistinction]), '')
      ,ISNULL([NextCheckNumber], '0')
      ,ISNULL([NextACHNumber], '0')
      ,ISNULL([ACHID], '')
      ,ISNULL([SuspenseGroupID], '')
      ,ISNULL([LockboxNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CashWithAppFinCode]), '')
      ,ISNULL([ChaseCCFilePrefix], '')
      ,ISNULL([ChaseCCFileUserName], '')
      ,ISNULL([InstaMedMerchantListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PositivePayCheckNumber]), 'A')
	  ,'N'		-- Concat ABA & Bank Acct Num
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BankAccounts
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BankAccounts
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BankAccounts_Cursor CURSOR FOR
 SELECT iEntityName
       ,iBankAccountGid
       ,iContactRelationGid
       ,iBankGid
       ,iKey4Field
       ,iKey5Field
       ,iKey6Field
       ,iKey7Field
       ,iKey8Field
       ,iKey9Field
       ,iKey10Field
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iBankAccountNumber
       ,iBankAccountDesc
       ,iBankAbaNumber
       ,iBankDesc
       ,iAccountType
       ,iAccountDistinction
       ,iNextAvailCheckNum
       ,iNextAvailAchNum
       ,iAchId
       ,iSuspenseGroupID
       ,iSuspenseGroupName
       ,iLockBox
       ,iAppFinCode
       ,iCcFilePrefix
       ,iCcFileUser
       ,iMerchantListId
       ,iMerchantListDesc
       ,iPositivePayCheckNumber
       ,iExtractOn835
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #BankAccounts

   OPEN BankAccounts_Cursor
  FETCH NEXT FROM BankAccounts_Cursor
   INTO @iEntityName
       ,@iBankAccountGid
       ,@iContactRelationGid
       ,@iBankGid
       ,@iKey4Field
       ,@iKey5Field
       ,@iKey6Field
       ,@iKey7Field
       ,@iKey8Field
       ,@iKey9Field
       ,@iKey10Field
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iBankAccountNumber
       ,@iBankAccountDesc
       ,@iBankAbaNumber
       ,@iBankDesc
       ,@iAccountType
       ,@iAccountDistinction
       ,@iNextAvailCheckNum
       ,@iNextAvailAchNum
       ,@iAchId
       ,@iSuspenseGroupID
       ,@iSuspenseGroupName
       ,@iLockBox
       ,@iAppFinCode
       ,@iCcFilePrefix
       ,@iCcFileUser
       ,@iMerchantListId
       ,@iMerchantListDesc
       ,@iPositivePayCheckNumber
       ,@iExtractOn835
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prBank_Acct_Table_Add_Modify
             @iEntityName
            ,@iBankAccountGid
            ,@iContactRelationGid
            ,@iBankGid
            ,@iKey4Field
            ,@iKey5Field
            ,@iKey6Field
            ,@iKey7Field
            ,@iKey8Field
            ,@iKey9Field
            ,@iKey10Field
            ,@iAction
            ,@iModifiedDate
            ,@iUserID
            ,@iBankAccountNumber
            ,@iBankAccountDesc
            ,@iBankAbaNumber
            ,@iBankDesc
            ,@iAccountType
            ,@iAccountDistinction
            ,@iNextAvailCheckNum
            ,@iNextAvailAchNum
            ,@iAchId
            ,@iSuspenseGroupID
            ,@iSuspenseGroupName
            ,@iLockBox
            ,@iAppFinCode
            ,@iCcFilePrefix
            ,@iCcFileUser
            ,@iMerchantListId
            ,@iMerchantListDesc
            ,@iPositivePayCheckNumber
            ,@iExtractOn835
            ,@oStatus				= @err_num	OUTPUT
            ,@oMessage				= @err_msg	OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Bank_Acct_Table 
				   SET bank_acct_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND bank_acct_number			= @iBankAccountNumber
				   AND bank_acct_desc			= @iBankAccountDesc

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iBankAccountNumber, @iBankAccountDesc, @iBankAbaNumber, @status, @err_num, @err_msg

        FETCH NEXT FROM BankAccounts_Cursor
         INTO @iEntityName
             ,@iBankAccountGid
             ,@iContactRelationGid
             ,@iBankGid
             ,@iKey4Field
             ,@iKey5Field
             ,@iKey6Field
             ,@iKey7Field
             ,@iKey8Field
             ,@iKey9Field
             ,@iKey10Field
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iBankAccountNumber
             ,@iBankAccountDesc
             ,@iBankAbaNumber
             ,@iBankDesc
             ,@iAccountType
             ,@iAccountDistinction
             ,@iNextAvailCheckNum
             ,@iNextAvailAchNum
             ,@iAchId
             ,@iSuspenseGroupID
             ,@iSuspenseGroupName
             ,@iLockBox
             ,@iAppFinCode
             ,@iCcFilePrefix
             ,@iCcFileUser
             ,@iMerchantListId
             ,@iMerchantListDesc
             ,@iPositivePayCheckNumber
             ,@iExtractOn835
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid

	END

CLOSE BankAccounts_Cursor
DEALLOCATE BankAccounts_Cursor

END
GO

