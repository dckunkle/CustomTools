IF OBJECT_ID('dbo.spDCAuto_CreateHoldCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateHoldCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateHoldCodes
Purpose:    Create holdcodes data from CorderAutomation
Method:     HoldCodes
Screen GID: 390
Procedure:  dbo.prHoldDefinitionAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateHoldCodes '100-Config%', 22, 'HoldCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateHoldCodes
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

DECLARE @iEntity                     VARCHAR(50)
       ,@i_entity                    CHAR(1)
       ,@i_hold_code                 VARCHAR(50)
       ,@iKeyField3                  VARCHAR(50)
       ,@iKeyField4                  VARCHAR(50)
       ,@iKeyField5                  VARCHAR(50)
       ,@iKeyField6                  VARCHAR(50)
       ,@iKeyField7                  VARCHAR(50)
       ,@iKeyField8                  VARCHAR(50)
       ,@iKeyField9                  VARCHAR(50)
       ,@iKeyField10                 VARCHAR(50)
       ,@iAction                     VARCHAR(10)
       ,@iDateModified               VARCHAR(50)
       ,@iUserID                     VARCHAR(25)
       ,@Entity                      VARCHAR(10)
       ,@iPriority                   INT
       ,@iHold_Code                  VARCHAR(20)
       ,@iHold_Description           VARCHAR(30)
       ,@iPend_Claim                 VARCHAR(50)
       ,@iPend_Billing               VARCHAR(50)
       ,@iPend_Cap                   VARCHAR(50)
       ,@iPend_ID_Card               VARCHAR(50)
       ,@iPend_Eligibility           VARCHAR(50)
       ,@i_irs_withhold              VARCHAR(50)
       ,@iPend_PCP                   VARCHAR(50)
       ,@iAllowCodeList              VARCHAR(50)
       ,@iStopLoss                   VARCHAR(50)
       ,@iGroup_Rec                  VARCHAR(50)
       ,@i_pend_npp_delinquency_type VARCHAR(50)
       ,@iHold_Code_Category         VARCHAR(10)
       ,@iDisplay_In_Portal          VARCHAR(50)
       ,@iRemark_Code                VARCHAR(50)
       ,@iRemark_Desc                VARCHAR(500)
       ,@iRemark_Code2               VARCHAR(50)
       ,@iRemark_Desc2               VARCHAR(500)
       ,@iReject_Code                VARCHAR(20)
       ,@oStatus                     INT
       ,@oMessage                    VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#HoldCodes') IS NOT NULL
	DROP TABLE #HoldCodes

CREATE TABLE #HoldCodes
      (iEntity                     VARCHAR(50)       DEFAULT('hld_codes')
      ,i_entity                    VARCHAR(50)		 DEFAULT('0')
      ,i_hold_code                 VARCHAR(50)       DEFAULT('0')
      ,iKeyField3                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField4                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField5                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField6                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField7                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField8                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField9                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField10                 VARCHAR(50)       DEFAULT('0')
      ,iAction                     VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified               VARCHAR(50)       DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,Entity                      VARCHAR(50)
      ,iPriority                   INT
      ,iHold_Code                  VARCHAR(50)
      ,iHold_Description           VARCHAR(50)
      ,iPend_Claim                 VARCHAR(50)
      ,iPend_Billing               VARCHAR(50)
      ,iPend_Cap                   VARCHAR(50)
      ,iPend_ID_Card               VARCHAR(50)
      ,iPend_Eligibility           VARCHAR(50)
      ,i_irs_withhold              VARCHAR(50)
      ,iPend_PCP                   VARCHAR(50)
      ,iAllowCodeList              VARCHAR(50)
      ,iStopLoss                   VARCHAR(50)
      ,iGroup_Rec                  VARCHAR(50)
      ,i_pend_npp_delinquency_type VARCHAR(50)
      ,iHold_Code_Category         VARCHAR(50)
      ,iDisplay_In_Portal          VARCHAR(50)
      ,iRemark_Code                VARCHAR(50)
      ,iRemark_Desc                VARCHAR(500)
      ,iRemark_Code2               VARCHAR(50)
      ,iRemark_Desc2               VARCHAR(500)
      ,iReject_Code                VARCHAR(50)
      ,oStatus                     INT
      ,oMessage                    VARCHAR(250)
      ,record_id                   INT
      ,static_gid                  INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #HoldCodes
      (Entity
      ,iPriority
      ,iHold_Code
      ,iHold_Description
      ,iPend_Claim
      ,iPend_Billing
      ,iPend_Cap
      ,iPend_ID_Card
      ,iPend_Eligibility
      ,i_irs_withhold
      ,iPend_PCP
      ,iAllowCodeList
      ,iStopLoss
      ,iGroup_Rec
      ,i_pend_npp_delinquency_type
      ,iHold_Code_Category
      ,iDisplay_In_Portal
      ,iRemark_Code
      ,iRemark_Code2
      ,iReject_Code
      ,record_id
      ,static_gid)
SELECT ISNULL(dbo.fnDCAuto_GetDropdownValue([*Entity]), '')
      ,ISNULL([*Priority], '0')
      ,ISNULL([*HoldCode], '')
      ,ISNULL([*HoldDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendClaim]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendBilling]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendCapitation]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendIDCard]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendEligibility]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*IRSWithhold]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendPCP]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*HoldByCodeDiagList]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ExcludeStopLossReview]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*GroupAcctRecon]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendNPP]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*HoldCodeCategory]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*DisplayInPortal]), 'N')
      ,ISNULL([RemarkCodeID], '')
      ,ISNULL([RemarkCodeID2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RejectCode]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_HoldCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #HoldCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE HoldCodes_Cursor CURSOR FOR
 SELECT iEntity
       ,i_entity
       ,i_hold_code
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
       ,Entity
       ,iPriority
       ,iHold_Code
       ,iHold_Description
       ,iPend_Claim
       ,iPend_Billing
       ,iPend_Cap
       ,iPend_ID_Card
       ,iPend_Eligibility
       ,i_irs_withhold
       ,iPend_PCP
       ,iAllowCodeList
       ,iStopLoss
       ,iGroup_Rec
       ,i_pend_npp_delinquency_type
       ,iHold_Code_Category
       ,iDisplay_In_Portal
       ,iRemark_Code
       ,iRemark_Desc
       ,iRemark_Code2
       ,iRemark_Desc2
       ,iReject_Code
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #HoldCodes

   OPEN HoldCodes_Cursor
  FETCH NEXT FROM HoldCodes_Cursor
   INTO @iEntity
       ,@i_entity
       ,@i_hold_code
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
       ,@Entity
       ,@iPriority
       ,@iHold_Code
       ,@iHold_Description
       ,@iPend_Claim
       ,@iPend_Billing
       ,@iPend_Cap
       ,@iPend_ID_Card
       ,@iPend_Eligibility
       ,@i_irs_withhold
       ,@iPend_PCP
       ,@iAllowCodeList
       ,@iStopLoss
       ,@iGroup_Rec
       ,@i_pend_npp_delinquency_type
       ,@iHold_Code_Category
       ,@iDisplay_In_Portal
       ,@iRemark_Code
       ,@iRemark_Desc
       ,@iRemark_Code2
       ,@iRemark_Desc2
       ,@iReject_Code
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prHoldDefinitionAddModify
             @iEntity
            ,@i_entity
            ,@i_hold_code
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
            ,@Entity
            ,@iPriority
            ,@iHold_Code
            ,@iHold_Description
            ,@iPend_Claim
            ,@iPend_Billing
            ,@iPend_Cap
            ,@iPend_ID_Card
            ,@iPend_Eligibility
            ,@i_irs_withhold
            ,@iPend_PCP
            ,@iAllowCodeList
            ,@iStopLoss
            ,@iGroup_Rec
            ,@i_pend_npp_delinquency_type
            ,@iHold_Code_Category
            ,@iDisplay_In_Portal
            ,@iRemark_Code
            ,@iRemark_Desc
            ,@iRemark_Code2
            ,@iRemark_Desc2
            ,@iReject_Code
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iHold_Code, @iHold_Description, '', @status, @err_num, @err_msg

        FETCH NEXT FROM HoldCodes_Cursor
         INTO @iEntity
             ,@i_entity
             ,@i_hold_code
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
             ,@Entity
             ,@iPriority
             ,@iHold_Code
             ,@iHold_Description
             ,@iPend_Claim
             ,@iPend_Billing
             ,@iPend_Cap
             ,@iPend_ID_Card
             ,@iPend_Eligibility
             ,@i_irs_withhold
             ,@iPend_PCP
             ,@iAllowCodeList
             ,@iStopLoss
             ,@iGroup_Rec
             ,@i_pend_npp_delinquency_type
             ,@iHold_Code_Category
             ,@iDisplay_In_Portal
             ,@iRemark_Code
             ,@iRemark_Desc
             ,@iRemark_Code2
             ,@iRemark_Desc2
             ,@iReject_Code
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE HoldCodes_Cursor
DEALLOCATE HoldCodes_Cursor

END
GO