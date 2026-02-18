IF OBJECT_ID('dbo.spDCAuto_CreateMemberFundingAssignments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberFundingAssignments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberFundingAssignments
Purpose:    Create memberfundingassignments data from CorderAutomation
Method:     MemberFundingAssignments
Screen GID: 2310
Procedure:  dbo.prFundingGroupMemberAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/08/2020	DK				Original procedure
02/05/2020	DK				Make sure funding assignment applied to subscriber
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberFundingAssignments '100-Config%', 22, 'MemberFundingAssignments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberFundingAssignments
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

DECLARE @iEntity            VARCHAR(50)
       ,@iRecordSID         VARCHAR(50)
       ,@iKeyEntityType     VARCHAR(50)
       ,@iKeyChildGID       VARCHAR(50)
       ,@iKeyParentGID      VARCHAR(50)
       ,@iKeyGroupGID       VARCHAR(50)
       ,@iKeyEffDate        VARCHAR(50)
       ,@iKeyTermDate       VARCHAR(50)
       ,@iKeyFundingID      VARCHAR(50)
       ,@iOldABA            VARCHAR(50)
       ,@iOldAcct           VARCHAR(50)
       ,@iAction            VARCHAR(10)
       ,@iDateModified      VARCHAR(50)
       ,@iUserID            VARCHAR(25)
       ,@iEntityID          VARCHAR(50)
       ,@iEntityName        VARCHAR(50)
       ,@iEffDate           VARCHAR(50)
       ,@iTermDate          VARCHAR(50)
       ,@iFundingID         VARCHAR(50)
       ,@iFundingAmount     VARCHAR(50)
       ,@iPremiumPay        VARCHAR(50)
       ,@iClaimPay          VARCHAR(50)
       ,@i_Acct_Type        VARCHAR(50)
       ,@i_Acct_Name        VARCHAR(100)
       ,@i_ABA_Number       VARCHAR(50)
       ,@i_Institution_Name VARCHAR(50)
       ,@i_Acct_Number      VARCHAR(50)
       ,@i_CC_Auth_Number   VARCHAR(50)
       ,@i_CC_Month         VARCHAR(50)
       ,@i_CC_Year          VARCHAR(50)
       ,@i_ACH_Draft_Day    VARCHAR(50)
       ,@i_Acct_Dist        VARCHAR(50)
       ,@iAccountVerified   VARCHAR(50)
       ,@oStatus            INT
       ,@oMessage           VARCHAR(250)
       ,@iTransSource       VARCHAR(50)
       ,@iDebug             VARCHAR(50)
       ,@return_xml         XML
       ,@FromMemberAdd      VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberFundingAssignments') IS NOT NULL
	DROP TABLE #MemberFundingAssignments

CREATE TABLE #MemberFundingAssignments
      (SearchID           VARCHAR(200)
      ,iEntity            VARCHAR(50)       DEFAULT('Funding_Member_Assign')
      ,iRecordSID         VARCHAR(50)       DEFAULT('0')
      ,iKeyEntityType     VARCHAR(50)       DEFAULT('0')
      ,iKeyChildGID       VARCHAR(50)       DEFAULT('0')
      ,iKeyParentGID      VARCHAR(50)       DEFAULT('0')
      ,iKeyGroupGID       VARCHAR(50)       DEFAULT('0')
      ,iKeyEffDate        VARCHAR(50)       DEFAULT('0')
      ,iKeyTermDate       VARCHAR(50)       DEFAULT('0')
      ,iKeyFundingID      VARCHAR(50)       DEFAULT('0')
      ,iOldABA            VARCHAR(50)       DEFAULT('0')
      ,iOldAcct           VARCHAR(50)       DEFAULT('0')
      ,iAction            VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified      VARCHAR(50)       DEFAULT('')
      ,iUserID            VARCHAR(25)       DEFAULT('')
      ,iEntityID          VARCHAR(50)
      ,iEntityName        VARCHAR(50)
      ,iEffDate           VARCHAR(50)
      ,iTermDate          VARCHAR(50)
      ,iFundingID         VARCHAR(50)
      ,iFundingAmount     VARCHAR(50)
      ,iPremiumPay        VARCHAR(50)
      ,iClaimPay          VARCHAR(50)
      ,i_Acct_Type        VARCHAR(50)
      ,i_Acct_Name        VARCHAR(100)
      ,i_ABA_Number       VARCHAR(50)
      ,i_Institution_Name VARCHAR(50)
      ,i_Acct_Number      VARCHAR(50)
      ,i_CC_Auth_Number   VARCHAR(50)
      ,i_CC_Month         VARCHAR(50)
      ,i_CC_Year          VARCHAR(50)
      ,i_ACH_Draft_Day    VARCHAR(50)
      ,i_Acct_Dist        VARCHAR(50)
      ,iAccountVerified   VARCHAR(50)
      ,oStatus            INT
      ,oMessage           VARCHAR(250)
      ,iTransSource       VARCHAR(50)
      ,iDebug             VARCHAR(50)
      ,return_xml         XML
      ,FromMemberAdd      VARCHAR(50)
      ,record_id          INT
      ,static_gid         INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberFundingAssignments
      (SearchID
      ,iEntityID
	  ,iEntityName
      ,iEffDate
      ,iTermDate
      ,iFundingID
      ,iFundingAmount
      ,iPremiumPay
      ,iClaimPay
      ,i_Acct_Type
      ,i_Acct_Name
      ,i_ABA_Number
	  ,i_Acct_Number
      ,i_CC_Auth_Number
      ,i_CC_Month
      ,i_CC_Year
      ,i_ACH_Draft_Day
      ,i_Acct_Dist
      ,iAccountVerified
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_MemberID], '')
      ,ISNULL([*Common_MemberInfo], '')
      ,ISNULL([*Common_EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_FundingSrc]), '')
      ,ISNULL([*Common_FundingAmt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseForPremium]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseForClaim]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Credit_AccType]), '')
      ,ISNULL([Credit_NameOnAcct], '')
      ,ISNULL([Credit_ABANumber], '')
      ,ISNULL([Credit_AccNumber], '')
      ,ISNULL([Credit_AuthNumber], '')
      ,ISNULL([Credit_ExpMonth], '')
      ,ISNULL([Credit_ExpYear], '')
      ,ISNULL([Credit_ACHDraftDay], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Credit_AccDistinc]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Credit_PreNoteVerified]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberFundingAssign
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberFundingAssignments
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberFundingAssignments_Cursor CURSOR FOR
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
       ,iPremiumPay
       ,iClaimPay
       ,i_Acct_Type
       ,i_Acct_Name
       ,i_ABA_Number
       ,i_Institution_Name
       ,i_Acct_Number
       ,i_CC_Auth_Number
       ,i_CC_Month
       ,i_CC_Year
       ,i_ACH_Draft_Day
       ,i_Acct_Dist
       ,iAccountVerified
       ,oStatus
       ,oMessage
       ,iTransSource
       ,iDebug
       ,return_xml
       ,FromMemberAdd
       ,record_id
       ,static_gid
   FROM #MemberFundingAssignments

   OPEN MemberFundingAssignments_Cursor
  FETCH NEXT FROM MemberFundingAssignments_Cursor
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
       ,@iPremiumPay
       ,@iClaimPay
       ,@i_Acct_Type
       ,@i_Acct_Name
       ,@i_ABA_Number
       ,@i_Institution_Name
       ,@i_Acct_Number
       ,@i_CC_Auth_Number
       ,@i_CC_Month
       ,@i_CC_Year
       ,@i_ACH_Draft_Day
       ,@i_Acct_Dist
       ,@iAccountVerified
       ,@oStatus
       ,@oMessage
       ,@iTransSource
       ,@iDebug
       ,@return_xml
       ,@FromMemberAdd
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the GIDs for the member
			SELECT @iKeyChildGID			= EC.child_gid
			      ,@iKeyParentGID			= EC.parent_gid
				  ,@iKeyGroupGID			= EC.group_gid
			  FROM Eligibility_Coverage		EC
			 WHERE EC.record_status			= 'A'
			   AND EC.member_id				= @SearchID
			   AND EC.child_gid				= EC.parent_gid		-- Make sure it is the subscriber that gets the funding assignment

			SELECT @iEntityName = CONVERT(VARCHAR(20), @iKeyChildGID) + ':' + CONVERT(VARCHAR(20), @iKeyParentGID) + ':' + CONVERT(VARCHAR(20), @iKeyGroupGID)
			      ,@iEntityID	= @SearchID

			EXEC dbo.prFundingGroupMemberAddModify
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
            ,@iPremiumPay
            ,@iClaimPay
            ,@i_Acct_Type
            ,@i_Acct_Name
            ,@i_ABA_Number
            ,@i_Institution_Name
            ,@i_Acct_Number
            ,@i_CC_Auth_Number
            ,@i_CC_Month
            ,@i_CC_Year
            ,@i_ACH_Draft_Day
            ,@i_Acct_Dist
            ,@iAccountVerified
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Get the current gid
				SELECT @current_gid				= current_gid
				  FROM dbo.SomeTable
				 WHERE record_status			= 'A'

				-- Update to the static gid
				UPDATE dbo.SomeTable 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iFundingID, '', @status, @err_num, @err_msg

        FETCH NEXT FROM MemberFundingAssignments_Cursor
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
             ,@iPremiumPay
             ,@iClaimPay
             ,@i_Acct_Type
             ,@i_Acct_Name
             ,@i_ABA_Number
             ,@i_Institution_Name
             ,@i_Acct_Number
             ,@i_CC_Auth_Number
             ,@i_CC_Month
             ,@i_CC_Year
             ,@i_ACH_Draft_Day
             ,@i_Acct_Dist
             ,@iAccountVerified
             ,@oStatus
             ,@oMessage
             ,@iTransSource
             ,@iDebug
             ,@return_xml
             ,@FromMemberAdd
             ,@record_id
             ,@static_gid
	END

CLOSE MemberFundingAssignments_Cursor
DEALLOCATE MemberFundingAssignments_Cursor

END
GO