IF OBJECT_ID('dbo.spDCAuto_CreateFeeScheduleDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateFeeScheduleDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateFeeScheduleDetails
Purpose:    Create feescheduledetails data from CorderAutomation
Method:     FeeScheduleDetails
Screen GID: 153
Procedure:  dbo.prFeeScheduleDetails_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateFeeScheduleDetails 'Adjudication-Config-1000%', 22, 'Adjudication-Config-1000', 'FeeScheduleDetails', 'AdjudicationConfig1000'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateFeeScheduleDetails
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

DECLARE @FeeScheduleID	   VARCHAR(100)
       ,@iEntityName       VARCHAR(50)
       ,@iFeeScheduleGID   VARCHAR(50)
       ,@iKey2Effdate      VARCHAR(50)
       ,@iKey3ProdID       VARCHAR(50)
       ,@iKeyProdQual      VARCHAR(50)
       ,@iKeyModifier      VARCHAR(50)
       ,@iKeyCodeListGID   VARCHAR(50)
       ,@iKeyTob           VARCHAR(50)
       ,@iFeeScheduleSID   VARCHAR(50)
       ,@iKeyPos           VARCHAR(50)
       ,@iKey10Field       VARCHAR(50)
       ,@iAction           VARCHAR(50)
       ,@iDateTimeModified VARCHAR(50)
       ,@iUserID           VARCHAR(50)
       ,@iEffectiveDate    VARCHAR(50)
       ,@iTerminationDate  VARCHAR(50)
       ,@iFromUnits        VARCHAR(50)
       ,@iToUnits          VARCHAR(50)
       ,@iProductQualifier VARCHAR(50)
       ,@iProductID        VARCHAR(50)
       ,@iProductDesc      VARCHAR(50)
       ,@iToothType        VARCHAR(50)
       ,@iSoi              VARCHAR(50)
       ,@iModifier1        VARCHAR(50)
       ,@iModifier2        VARCHAR(50)
       ,@iModifier3        VARCHAR(50)
       ,@iModifier4        VARCHAR(50)
       ,@iModLogic         VARCHAR(50)
       ,@iDollarAmount     VARCHAR(50)
       ,@iStartRange       VARCHAR(50)
       ,@iEndRange         VARCHAR(50)
       ,@iTypeOfBill       VARCHAR(50)
       ,@iContractBasis    VARCHAR(20)
       ,@iPOSCode          VARCHAR(50)
       ,@iPOSDesc          VARCHAR(50)
       ,@iPOSListID        VARCHAR(50)
       ,@iPOSListDesc      VARCHAR(100)
       ,@iCodeListID       VARCHAR(50)
       ,@iCodeListDesc     VARCHAR(50)
       ,@iMinUnit          VARCHAR(50)
       ,@iMaxUnit          VARCHAR(50)
       ,@iUnitRound        VARCHAR(50)
       ,@iAllowTakeBack    VARCHAR(50)
       ,@iRemarkCode1      VARCHAR(50)
       ,@iRemarkCode1Desc  VARCHAR(500)
       ,@iRemarkCode2      VARCHAR(50)
       ,@iRemarkCode2Desc  VARCHAR(500)
       ,@iAutoOfficeVisit  VARCHAR(50)
       ,@oStatus           INT
       ,@oMessage          VARCHAR(200)
       ,@iDisplay          VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#FeeScheduleDetails') IS NOT NULL
	DROP TABLE #FeeScheduleDetails

CREATE TABLE #FeeScheduleDetails
      (iEntityName       VARCHAR(50)       DEFAULT('Fee_Schedule_Details')
      ,iFeeScheduleGID   VARCHAR(50)       DEFAULT('0')
      ,iKey2Effdate      VARCHAR(50)       DEFAULT('0')
      ,iKey3ProdID       VARCHAR(50)       DEFAULT('0')
      ,iKeyProdQual      VARCHAR(50)       DEFAULT('0')
      ,iKeyModifier      VARCHAR(50)       DEFAULT('0')
      ,iKeyCodeListGID   VARCHAR(50)       DEFAULT('0')
      ,iKeyTob           VARCHAR(50)       DEFAULT('0')
      ,iFeeScheduleSID   VARCHAR(50)       DEFAULT('0')
      ,iKeyPos           VARCHAR(50)       DEFAULT('0')
      ,iKey10Field       VARCHAR(50)       DEFAULT('0')
      ,iAction           VARCHAR(50)       DEFAULT('ADD')
      ,iDateTimeModified VARCHAR(50)       DEFAULT('')
      ,iUserID           VARCHAR(50)       DEFAULT('')
      ,iEffectiveDate    VARCHAR(50)
      ,iTerminationDate  VARCHAR(50)
      ,iFromUnits        VARCHAR(50)
      ,iToUnits          VARCHAR(50)
      ,iProductQualifier VARCHAR(50)
      ,iProductID        VARCHAR(50)
      ,iProductDesc      VARCHAR(50)
      ,iToothType        VARCHAR(50)
      ,iSoi              VARCHAR(50)
      ,iModifier1        VARCHAR(50)
      ,iModifier2        VARCHAR(50)
      ,iModifier3        VARCHAR(50)
      ,iModifier4        VARCHAR(50)
      ,iModLogic         VARCHAR(50)
      ,iDollarAmount     VARCHAR(50)
      ,iStartRange       VARCHAR(50)
      ,iEndRange         VARCHAR(50)
      ,iTypeOfBill       VARCHAR(50)
      ,iContractBasis    VARCHAR(50)
      ,iPOSCode          VARCHAR(50)
      ,iPOSDesc          VARCHAR(50)
      ,iPOSListID        VARCHAR(50)
      ,iPOSListDesc      VARCHAR(100)
      ,iCodeListID       VARCHAR(50)
      ,iCodeListDesc     VARCHAR(50)
      ,iMinUnit          VARCHAR(50)
      ,iMaxUnit          VARCHAR(50)
      ,iUnitRound        VARCHAR(50)
      ,iAllowTakeBack    VARCHAR(50)
      ,iRemarkCode1      VARCHAR(50)
      ,iRemarkCode1Desc  VARCHAR(500)
      ,iRemarkCode2      VARCHAR(50)
      ,iRemarkCode2Desc  VARCHAR(500)
      ,iAutoOfficeVisit  VARCHAR(50)
      ,oStatus           INT
      ,oMessage          VARCHAR(200)
      ,iDisplay          VARCHAR(50)
      ,record_id         INT
      ,static_gid        INT
	  ,FeeScheduleID	 VARCHAR(100))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #FeeScheduleDetails
      (FeeScheduleID
	  ,iEffectiveDate
      ,iTerminationDate
      ,iFromUnits
      ,iToUnits
      ,iProductQualifier
      ,iProductID
      ,iToothType
      ,iSoi
      ,iModifier1
      ,iModifier2
      ,iModifier3
      ,iModifier4
      ,iModLogic
      ,iDollarAmount
      ,iStartRange
      ,iEndRange
      ,iTypeOfBill
      ,iContractBasis
      ,iPOSCode
      ,iPOSListID
      ,iCodeListID
      ,iMinUnit
      ,iMaxUnit
      ,iUnitRound
      ,iAllowTakeBack
      ,iRemarkCode1
      ,iRemarkCode2
      ,iAutoOfficeVisit
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([FromUnits], '')
      ,ISNULL([ToUnits], '')
      ,CASE WHEN  [ProductQualifier] = '<Partial>CPT' THEN 'CPT'
	        ELSE ISNULL(dbo.fnDCAuto_GetDropdownValue([ProductQualifier]), '*')
		 END
      ,ISNULL([Code], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ToothTypeLogic]), '00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SeverityofIllness]), '0')
      ,ISNULL([Modifier1], '')
      ,ISNULL([Modifier2], '')
      ,ISNULL([Modifier3], '')
      ,ISNULL([Modifier4], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ModifierLogic]), '1')
      ,ISNULL([DollarAmt/MarkupPercent], '0.00')
      ,ISNULL([SubmittedCostStartRange], '0.00')
      ,ISNULL([SubmittedCostEndRange], '9999999999.99')
      ,ISNULL([TypeofBill], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContractBasis]), '')
      ,ISNULL([POSCode], '')
      ,ISNULL([POSList], '')
      ,ISNULL([ClaimAlsoContainsCodeFromListID], '')
      ,ISNULL([MinimumReimbursementUnit], '0')
      ,ISNULL([MaximumReimbursementUnit], '9999999.99')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReimbursementUnitRounding]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AllowProviderTakeBack]), 'N')
      ,ISNULL([RemarkCode], '')
      ,ISNULL([RemarkCode2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OfficeVisittoGenerateonClaim]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_FeeScheduleDetails
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #FeeScheduleDetails
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE FeeScheduleDetails_Cursor CURSOR FOR
 SELECT FeeScheduleID
       ,iEntityName
       ,iFeeScheduleGID
       ,iKey2Effdate
       ,iKey3ProdID
       ,iKeyProdQual
       ,iKeyModifier
       ,iKeyCodeListGID
       ,iKeyTob
       ,iFeeScheduleSID
       ,iKeyPos
       ,iKey10Field
       ,iAction
       ,iDateTimeModified
       ,iUserID
       ,iEffectiveDate
       ,iTerminationDate
       ,iFromUnits
       ,iToUnits
       ,iProductQualifier
       ,iProductID
       ,iProductDesc
       ,iToothType
       ,iSoi
       ,iModifier1
       ,iModifier2
       ,iModifier3
       ,iModifier4
       ,iModLogic
       ,iDollarAmount
       ,iStartRange
       ,iEndRange
       ,iTypeOfBill
       ,iContractBasis
       ,iPOSCode
       ,iPOSDesc
       ,iPOSListID
       ,iPOSListDesc
       ,iCodeListID
       ,iCodeListDesc
       ,iMinUnit
       ,iMaxUnit
       ,iUnitRound
       ,iAllowTakeBack
       ,iRemarkCode1
       ,iRemarkCode1Desc
       ,iRemarkCode2
       ,iRemarkCode2Desc
       ,iAutoOfficeVisit
       ,oStatus
       ,oMessage
       ,iDisplay
       ,record_id
       ,static_gid
   FROM #FeeScheduleDetails

   OPEN FeeScheduleDetails_Cursor
  FETCH NEXT FROM FeeScheduleDetails_Cursor
   INTO @FeeScheduleID
       ,@iEntityName
       ,@iFeeScheduleGID
       ,@iKey2Effdate
       ,@iKey3ProdID
       ,@iKeyProdQual
       ,@iKeyModifier
       ,@iKeyCodeListGID
       ,@iKeyTob
       ,@iFeeScheduleSID
       ,@iKeyPos
       ,@iKey10Field
       ,@iAction
       ,@iDateTimeModified
       ,@iUserID
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iFromUnits
       ,@iToUnits
       ,@iProductQualifier
       ,@iProductID
       ,@iProductDesc
       ,@iToothType
       ,@iSoi
       ,@iModifier1
       ,@iModifier2
       ,@iModifier3
       ,@iModifier4
       ,@iModLogic
       ,@iDollarAmount
       ,@iStartRange
       ,@iEndRange
       ,@iTypeOfBill
       ,@iContractBasis
       ,@iPOSCode
       ,@iPOSDesc
       ,@iPOSListID
       ,@iPOSListDesc
       ,@iCodeListID
       ,@iCodeListDesc
       ,@iMinUnit
       ,@iMaxUnit
       ,@iUnitRound
       ,@iAllowTakeBack
       ,@iRemarkCode1
       ,@iRemarkCode1Desc
       ,@iRemarkCode2
       ,@iRemarkCode2Desc
       ,@iAutoOfficeVisit
       ,@oStatus
       ,@oMessage
       ,@iDisplay
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Determine the gid of the Fee Schedule ID
		SELECT @iFeeScheduleGID		= CONVERT(VARCHAR(100), fee_schedule_gid)
		  FROM Fee_Schedule			FS
		 WHERE FS.record_status		= 'A'
		   AND FS.fee_schedule_id	= @FeeScheduleID

		EXEC dbo.prFeeScheduleDetails_Add_Modify
             @iEntityName
            ,@iFeeScheduleGID
            ,@iKey2Effdate
            ,@iKey3ProdID
            ,@iKeyProdQual
            ,@iKeyModifier
            ,@iKeyCodeListGID
            ,@iKeyTob
            ,@iFeeScheduleSID
            ,@iKeyPos
            ,@iKey10Field
            ,@iAction
            ,@iDateTimeModified
            ,@iUserID
            ,@iEffectiveDate
            ,@iTerminationDate
            ,@iFromUnits
            ,@iToUnits
            ,@iProductQualifier
            ,@iProductID
            ,@iProductDesc
            ,@iToothType
            ,@iSoi
            ,@iModifier1
            ,@iModifier2
            ,@iModifier3
            ,@iModifier4
            ,@iModLogic
            ,@iDollarAmount
            ,@iStartRange
            ,@iEndRange
            ,@iTypeOfBill
            ,@iContractBasis
            ,@iPOSCode
            ,@iPOSDesc
            ,@iPOSListID
            ,@iPOSListDesc
            ,@iCodeListID
            ,@iCodeListDesc
            ,@iMinUnit
            ,@iMaxUnit
            ,@iUnitRound
            ,@iAllowTakeBack
            ,@iRemarkCode1
            ,@iRemarkCode1Desc
            ,@iRemarkCode2
            ,@iRemarkCode2Desc
            ,@iAutoOfficeVisit
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @FeeScheduleID, @iEffectiveDate, @iTerminationDate, @status, @err_num, @err_msg

        FETCH NEXT FROM FeeScheduleDetails_Cursor
         INTO @FeeScheduleID
             ,@iEntityName
             ,@iFeeScheduleGID
             ,@iKey2Effdate
             ,@iKey3ProdID
             ,@iKeyProdQual
             ,@iKeyModifier
             ,@iKeyCodeListGID
             ,@iKeyTob
             ,@iFeeScheduleSID
             ,@iKeyPos
             ,@iKey10Field
             ,@iAction
             ,@iDateTimeModified
             ,@iUserID
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iFromUnits
             ,@iToUnits
             ,@iProductQualifier
             ,@iProductID
             ,@iProductDesc
             ,@iToothType
             ,@iSoi
             ,@iModifier1
             ,@iModifier2
             ,@iModifier3
             ,@iModifier4
             ,@iModLogic
             ,@iDollarAmount
             ,@iStartRange
             ,@iEndRange
             ,@iTypeOfBill
             ,@iContractBasis
             ,@iPOSCode
             ,@iPOSDesc
             ,@iPOSListID
             ,@iPOSListDesc
             ,@iCodeListID
             ,@iCodeListDesc
             ,@iMinUnit
             ,@iMaxUnit
             ,@iUnitRound
             ,@iAllowTakeBack
             ,@iRemarkCode1
             ,@iRemarkCode1Desc
             ,@iRemarkCode2
             ,@iRemarkCode2Desc
             ,@iAutoOfficeVisit
             ,@oStatus
             ,@oMessage
             ,@iDisplay
             ,@record_id
             ,@static_gid
	END

CLOSE FeeScheduleDetails_Cursor
DEALLOCATE FeeScheduleDetails_Cursor

END
GO