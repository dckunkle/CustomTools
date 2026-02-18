/**************************************************************************************************
Name:       spAPIAuto_ImportRFFInterestRecord
Purpose:    Called from Powershell to validate and save incoming RFF Interest data

Date        User            Change
---------------------------------------------------------------------------------------------
01/17/2023	DK				Original procedure
03/03/2023	DK				Allow Tier to be 0 to 4
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_ImportRFFInterestRecord
      (@iFileID							INT
	  ,@iRowID							INT
	  ,@iStateSelected					VARCHAR(20)
	  ,@iScenario						VARCHAR(1000)
	  ,@iScenarioType					VARCHAR(1000)
	  ,@iAutomate						VARCHAR(20)
	  ,@iScenarioDetail					VARCHAR(4000)
	  ,@iState							VARCHAR(20)
	  ,@iNetworkStatus					VARCHAR(50)
	  ,@iTier							VARCHAR(20)
	  ,@iClaimFormType					VARCHAR(50)
	  ,@i837SubmissionFormat			VARCHAR(20)
	  ,@iAdjudicationType				VARCHAR(20)
	  ,@iPaidRFF1						VARCHAR(20)
	  ,@iPaidTimelyRFF1					VARCHAR(20)
	  ,@iPaidRFF2						VARCHAR(20)
	  ,@iPaidTimelyRFF2					VARCHAR(20)
	  ,@iPaidRFF3						VARCHAR(20)
	  ,@iPaidTimelyRFF3					VARCHAR(20)
	  ,@iPaidRFF4						VARCHAR(20)
	  ,@iPaidTimelyRFF4					VARCHAR(20)
	  ,@iSubmittedAmount				VARCHAR(20)
	  ,@iTrueAllowedAmount				VARCHAR(20)
	  ,@iNetAmount						VARCHAR(20)
	  ,@iPatientResponsibilityAmount	VARCHAR(20)
	  ,@iContractDiscount				VARCHAR(20)
	  ,@iReceivedDate					VARCHAR(20)
	  ,@iRunDate						VARCHAR(20)
	  ,@iClaimLineNumber				VARCHAR(20)
	  ,@iStep							VARCHAR(20)
	  ,@iChange							VARCHAR(4000)
	  ,@iMemberID						VARCHAR(20)
	  ,@iClaimNumber					VARCHAR(20)
	  ,@iGroupID						VARCHAR(20)
	  ,@iLOB							VARCHAR(20)
	  ,@iPatientAccountNumber			VARCHAR(50)
	  ,@iProviderID						VARCHAR(50)
	  ,@iNPI							VARCHAR(20)
	  ,@iExpectedResultPenaltyDays		VARCHAR(20)
	  ,@iPenaltyDays					VARCHAR(20)
	  ,@iPenaltyAmount					VARCHAR(20)
	  ,@iManualInterest					VARCHAR(20)
	  ,@iVerified						VARCHAR(20)
	  ,@iCorrectedClaimRelation			VARCHAR(20)
	  ,@iCorrectedClaim					VARCHAR(20))

AS
BEGIN

SET NOCOUNT ON

DECLARE @ColumnID						VARCHAR(5)
       ,@DataLocation					VARCHAR(20)
	   ,@err_num						INT
	   ,@err_msg						VARCHAR(4000)

       ,@ScenarioType					VARCHAR(1000)
       ,@Scenario						VARCHAR(1000)
	   ,@Automate						VARCHAR(20)
	   ,@ScenarioDetail					VARCHAR(4000)
	   ,@State							VARCHAR(20)
	   ,@NetworkStatus					VARCHAR(50)
	   ,@Tier							VARCHAR(20)
	   ,@ClaimFormType					VARCHAR(50)
	   ,@837SubmissionFormat			VARCHAR(20)
	   ,@AdjudicationType				VARCHAR(20)
	   ,@PaidRFF1						VARCHAR(20)
	   ,@PaidTimelyRFF1					VARCHAR(20)
	   ,@PaidRFF2						VARCHAR(20)
	   ,@PaidTimelyRFF2					VARCHAR(20)
	   ,@PaidRFF3						VARCHAR(20)
	   ,@PaidTimelyRFF3					VARCHAR(20)
	   ,@PaidRFF4						VARCHAR(20)
	   ,@PaidTimelyRFF4					VARCHAR(20)
	   ,@SubmittedAmount				VARCHAR(20)
	   ,@TrueAllowedAmount				VARCHAR(20)
	   ,@NetAmount						VARCHAR(20)
	   ,@PatientResponsibilityAmount	VARCHAR(20)
	   ,@ContractDiscount				VARCHAR(20)
	   ,@ReceivedDate					VARCHAR(20)
	   ,@RunDate						VARCHAR(20)
	   ,@ClaimLineNumber				VARCHAR(20)
	   ,@Step							VARCHAR(20)
	   ,@Change							VARCHAR(4000)
	   ,@MemberID						VARCHAR(20)
	   ,@ClaimNumber					VARCHAR(20)
	   ,@GroupID						VARCHAR(20)
	   ,@LOB							VARCHAR(20)
	   ,@PatientAccountNumber			VARCHAR(50)
	   ,@ProviderID						VARCHAR(50)
	   ,@NPI							VARCHAR(20)
	   ,@ExpectedResultPenaltyDays		VARCHAR(20)
	   ,@PenaltyDays					VARCHAR(20)
	   ,@PenaltyAmount					VARCHAR(20)
	   ,@ManualInterest					VARCHAR(20)
	   ,@Verified						VARCHAR(20)
	   ,@CorrectedClaimRelation			VARCHAR(20)
	   ,@CorrectedClaim					VARCHAR(20)

BEGIN TRY

--*************************************************************************************************
-- Field: Scenario
--*************************************************************************************************
SELECT @Scenario = REPLACE(@iScenario, CHAR(160), ' ')
SELECT @Scenario = REPLACE(REPLACE(@Scenario,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Scenario = TRIM(@Scenario)

SELECT @ColumnID	= 'A'
      ,@err_num		= 0
	  
IF (@Scenario = '') BEGIN SELECT @err_num = 101,@err_msg		= 'The Scenario field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Scenario Type
--*************************************************************************************************
SELECT @ScenarioType = REPLACE(@iScenarioType, CHAR(160), ' ')
SELECT @ScenarioType = REPLACE(REPLACE(@ScenarioType,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ScenarioType = TRIM(@ScenarioType)

--*************************************************************************************************
-- Field: Automate
--*************************************************************************************************
SELECT @Automate = REPLACE(@iAutomate, CHAR(160), ' ')
SELECT @Automate = REPLACE(REPLACE(@Automate,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Automate = TRIM(@Automate)

--*************************************************************************************************
-- Field: Scenario Detail
--*************************************************************************************************
SELECT @ScenarioDetail = REPLACE(@iScenarioDetail, CHAR(160), ' ')
SELECT @ScenarioDetail = REPLACE(REPLACE(@ScenarioDetail,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ScenarioDetail = TRIM(@ScenarioDetail)

SELECT @ColumnID	= 'D'
      ,@err_num		= 0
	  
IF (@ScenarioDetail = '') BEGIN SELECT @err_num = 401, @err_msg = 'The Scenario Detail field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: State
--*************************************************************************************************
SELECT @State = REPLACE(@iState, CHAR(160), ' ')
SELECT @State = REPLACE(REPLACE(@State,  CHAR(13) , ' '), CHAR(10), '')
SELECT @State = TRIM(@State)

SELECT @ColumnID	= 'E'
      ,@err_num		= 0

IF (@State = '') BEGIN SELECT @err_num = 501, @err_msg = 'The State field cannot be blank.' END
IF (@State <> '' AND @State <> @iStateSelected) BEGIN SELECT @err_num = 502, @err_msg = 'The state, ' + @State + ', does not match the state selected.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Network Status
--*************************************************************************************************
SELECT @NetworkStatus = REPLACE(@iNetworkStatus, CHAR(160), ' ')
SELECT @NetworkStatus = REPLACE(REPLACE(@NetworkStatus,  CHAR(13) , ' '), CHAR(10), '')
SELECT @NetworkStatus = TRIM(@NetworkStatus)

SELECT @ColumnID	= 'F'
      ,@err_num		= 0

IF (@NetworkStatus = '') BEGIN SELECT @err_num = 601, @err_msg = 'The Network Status field cannot be blank.' END
IF (@NetworkStatus <> '' AND @NetworkStatus NOT IN ('In-network','Out of network')) BEGIN SELECT @err_num = 602, @err_msg = 'The Network Status, ' + @NetworkStatus + ', does not match an accepted value (In-network, Out of network).' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Tier
--*************************************************************************************************
SELECT @Tier = REPLACE(@iTier, CHAR(160), ' ')
SELECT @Tier = REPLACE(REPLACE(@Tier,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Tier = TRIM(@Tier)

SELECT @ColumnID	= 'G'
      ,@err_num		= 0

IF (@Tier = '') BEGIN SELECT @err_num = 701, @err_msg = 'The Tier field cannot be blank.' END
IF (@Tier <> '' AND @Tier NOT IN ('0','1','2','3','4')) BEGIN SELECT @err_num = 702, @err_msg = 'The Tier, ' + @Tier + ', is not set to 1.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: ClaimFormType
--*************************************************************************************************
SELECT @ClaimFormType = REPLACE(@iClaimFormType, CHAR(160), ' ')
SELECT @ClaimFormType = REPLACE(REPLACE(@ClaimFormType,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ClaimFormType = TRIM(@ClaimFormType)

SELECT @ColumnID	= 'H'
      ,@err_num		= 0

IF (@ClaimFormType = '') BEGIN SELECT @err_num = 801, @err_msg	= 'The Claim Form Type field cannot be blank.' END
IF (@ClaimFormType <> '' AND @ClaimFormType NOT IN ('Professional/HCFA','Facility/UB')) BEGIN SELECT @err_num = 802, @err_msg	= 'The Claim Form Type, ' + @ClaimFormType + ', does not match an accepted value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: 837 Submission Format
--*************************************************************************************************
SELECT @837SubmissionFormat = REPLACE(@i837SubmissionFormat, CHAR(160), ' ')
SELECT @837SubmissionFormat = REPLACE(REPLACE(@837SubmissionFormat,  CHAR(13) , ' '), CHAR(10), '')
SELECT @837SubmissionFormat = TRIM(@837SubmissionFormat)

SELECT @ColumnID	= 'I'
      ,@err_num		= 0
	  
IF (@837SubmissionFormat = '') BEGIN SELECT @err_num = 901, @err_msg = 'The 837 Submission Format field cannot be blank.' END
IF (@837SubmissionFormat <> '' AND @837SubmissionFormat NOT IN ('Paper','EDI')) BEGIN SELECT @err_num = 902, @err_msg = 'The 837 Submission Format, ' + @837SubmissionFormat + ', does not match an accepted value (Paper, EDI).' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Adjudication Type
--*************************************************************************************************
SELECT @AdjudicationType = REPLACE(@iAdjudicationType, CHAR(160), ' ')
SELECT @AdjudicationType = REPLACE(REPLACE(@AdjudicationType,  CHAR(13) , ' '), CHAR(10), '')
SELECT @AdjudicationType = TRIM(@AdjudicationType)

SELECT @ColumnID	= 'J'
      ,@err_num		= 0
	  
IF (@AdjudicationType = '') BEGIN SELECT @err_num = 1001, @err_msg	= 'The Adjudication Type field cannot be blank.' END
IF (@AdjudicationType <> '' AND @AdjudicationType NOT IN ('Auto')) BEGIN SELECT @err_num = 1002, @err_msg	= 'The Adjudication Type, ' + @AdjudicationType + ', does not match an accepted value (Auto).' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Paid RFF 1
--*************************************************************************************************
SELECT @PaidRFF1 = REPLACE(@iPaidRFF1, CHAR(160), ' ')
SELECT @PaidRFF1 = REPLACE(REPLACE(@PaidRFF1,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PaidRFF1 = TRIM(@PaidRFF1)

SELECT @ColumnID	= 'K'
      ,@err_num		= 0
	  
IF (@PaidRFF1 = '') BEGIN SELECT @err_num = 1101, @err_msg = 'The Paid RFF 1 field cannot be blank.' END
IF (@PaidRFF1 <> '' AND @PaidRFF1 NOT IN ('Yes','No')) BEGIN SELECT @err_num = 1102, @err_msg	= 'The Paid RFF 1, ' + @PaidRFF1 + ', does not match an accepted value (Yes, No).' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Paid Timely RFF 1
--*************************************************************************************************
SELECT @PaidTimelyRFF1 = REPLACE(@iPaidTimelyRFF1, CHAR(160), ' ')
SELECT @PaidTimelyRFF1 = REPLACE(REPLACE(@PaidTimelyRFF1,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PaidTimelyRFF1 = TRIM(@PaidTimelyRFF1)

SELECT @ColumnID	= 'L'
      ,@err_num		= 0
	  
IF (@PaidTimelyRFF1 = '') BEGIN SELECT @err_num = 1201, @err_msg = 'The Paid Timely RFF 1field cannot be blank.' END
IF (@PaidTimelyRFF1 <> '' AND @PaidTimelyRFF1 NOT IN ('Yes','No')) BEGIN SELECT @err_num = 1202, @err_msg = 'The Paid Timely RFF 1, ' + @PaidTimelyRFF1 + ', does not match an accepted value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Submitted Amount
--*************************************************************************************************
SELECT @SubmittedAmount = REPLACE(@iSubmittedAmount, CHAR(160), ' ')
SELECT @SubmittedAmount = REPLACE(REPLACE(@SubmittedAmount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @SubmittedAmount = TRIM(@SubmittedAmount)

SELECT @ColumnID	= 'S'
      ,@err_num		= 0
	  
IF (@SubmittedAmount = '') BEGIN SELECT @err_num = 1901, @err_msg = 'The Submitted Amount field cannot be blank.' END
IF (@SubmittedAmount <> '' AND ISNUMERIC(@SubmittedAmount) = 0) BEGIN SELECT @err_num = 1902, @err_msg = 'The Submitted Amount, ' + @SubmittedAmount + ', is not numeric.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: True Allowed Amount
--*************************************************************************************************
SELECT @TrueAllowedAmount = REPLACE(@iTrueAllowedAmount, CHAR(160), ' ')
SELECT @TrueAllowedAmount = REPLACE(REPLACE(@TrueAllowedAmount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @TrueAllowedAmount = TRIM(@TrueAllowedAmount)

SELECT @ColumnID	= 'T'
      ,@err_num		= 0
	  
IF (@TrueAllowedAmount = '') BEGIN SELECT @err_num = 2001,@err_msg = 'The True Allowed Amount field cannot be blank.' END
IF (@TrueAllowedAmount <> '' AND ISNUMERIC(@TrueAllowedAmount) = 0) BEGIN SELECT @err_num = 2002,@err_msg = 'The True Allowed Amount, ' + @TrueAllowedAmount + ', is not numeric.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Net Amount
--*************************************************************************************************
SELECT @NetAmount = REPLACE(@iNetAmount, CHAR(160), ' ')
SELECT @NetAmount = REPLACE(REPLACE(@NetAmount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @NetAmount = TRIM(@NetAmount)

SELECT @ColumnID	= 'U'
      ,@err_num		= 0
	  
IF (@NetAmount = '') BEGIN SELECT @err_num = 2101,@err_msg = 'The Net Amount field cannot be blank.' END
IF (@NetAmount <> '' AND ISNUMERIC(@NetAmount) = 0) BEGIN SELECT @err_num = 2102, @err_msg = 'The Net Amount, ' + @NetAmount + ', is not numeric.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Patient Responsibility Amount
--*************************************************************************************************
SELECT @PatientResponsibilityAmount = REPLACE(@iPatientResponsibilityAmount, CHAR(160), ' ')
SELECT @PatientResponsibilityAmount = REPLACE(REPLACE(@PatientResponsibilityAmount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PatientResponsibilityAmount = TRIM(@PatientResponsibilityAmount)

SELECT @ColumnID	= 'V'
      ,@err_num		= 0
	  
IF (@PatientResponsibilityAmount = '') BEGIN SELECT @err_num = 2201, @err_msg = 'The Patient Responsibility Amount field cannot be blank.' END
IF (@PatientResponsibilityAmount <> '' AND ISNUMERIC(@PatientResponsibilityAmount) = 0) BEGIN SELECT @err_num = 2202, @err_msg = 'The Patient Responsibility Amount, ' + @PatientResponsibilityAmount + ', is not numeric.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Contract Discount
--*************************************************************************************************
SELECT @ContractDiscount = REPLACE(@iContractDiscount, CHAR(160), ' ')
SELECT @ContractDiscount = REPLACE(REPLACE(@ContractDiscount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ContractDiscount = TRIM(@ContractDiscount)

SELECT @ColumnID	= 'W'
      ,@err_num		= 0
	  
IF (@ContractDiscount = '') BEGIN SELECT @err_num = 2301, @err_msg = 'The Contract Discount field cannot be blank.' END
IF (@ContractDiscount <> '' AND ISNUMERIC(@ContractDiscount) = 0) BEGIN SELECT @err_num = 2302, @err_msg = 'The Contract Discount, ' + @ContractDiscount + ', is not numeric.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Received Date
--*************************************************************************************************
SELECT @ReceivedDate = REPLACE(@iReceivedDate, CHAR(160), ' ')
SELECT @ReceivedDate = REPLACE(REPLACE(@ReceivedDate,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ReceivedDate = TRIM(@ReceivedDate)

SELECT @ColumnID	= 'X'
      ,@err_num		= 0
	  
IF (@ReceivedDate = '') BEGIN SELECT @err_num = 2401, @err_msg = 'The Received Date field cannot be blank.' END
IF (@ReceivedDate <> '' AND ISDATE(@ReceivedDate) = 0) BEGIN SELECT @err_num = 2402, @err_msg = 'The Received Date, ' + @ReceivedDate + ', is not a valid date.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Run Date
--*************************************************************************************************
SELECT @RunDate = REPLACE(@iRunDate, CHAR(160), ' ')
SELECT @RunDate = REPLACE(REPLACE(@RunDate,  CHAR(13) , ' '), CHAR(10), '')
SELECT @RunDate = TRIM(@RunDate)

SELECT @ColumnID	= 'Y'
      ,@err_num		= 0


IF (@RunDate <> '' AND ISDATE(@RunDate) = 0) BEGIN SELECT @err_num = 2502, @err_msg = 'The Run Date, ' + @RunDate + ', is not a valid date.' END
IF (@RunDate <> '' AND @RunDate NOT IN ('3/1/2022','4/15/2022','5/30/2022','7/15/2022')) BEGIN SELECT @err_num = 2503, @err_msg = 'The Run Date, ' + @RunDate + ', is not a valid value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Claim Line Number
--*************************************************************************************************
SELECT @ClaimLineNumber = REPLACE(@iClaimLineNumber, CHAR(160), ' ')
SELECT @ClaimLineNumber = REPLACE(REPLACE(@ClaimLineNumber,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ClaimLineNumber = TRIM(@ClaimLineNumber)

SELECT @ColumnID	= 'Z'
      ,@err_num		= 0
	  
IF (@ClaimLineNumber = '') BEGIN SELECT @err_num = 2601, @err_msg = 'The Claim Line Number field cannot be blank.' END
IF (@ClaimLineNumber <> '' AND @ClaimLineNumber NOT IN ('1','2','3','4','5')) BEGIN SELECT @err_num = 2602, @err_msg = 'The Claim Line Number, ' + @ClaimLineNumber + ', is not a valid value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Step
--*************************************************************************************************
SELECT @Step = REPLACE(@iStep, CHAR(160), ' ')
SELECT @Step = REPLACE(REPLACE(@Step,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Step = TRIM(@Step)

SELECT @ColumnID	= 'AA'
      ,@err_num		= 0
	  
IF (@Step = '') BEGIN SELECT @err_num = 2701, @err_msg = 'The Step field cannot be blank.' END
IF (@Step = '' AND @Step NOT IN ('1','2','3','4','5')) BEGIN SELECT @err_num = 2702, @err_msg = 'The Step, ' + @Step + ', is not a valid value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Change
--*************************************************************************************************
SELECT @Change = REPLACE(@iChange, CHAR(160), ' ')
SELECT @Change = REPLACE(REPLACE(@Change,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Change = TRIM(@Change)

SELECT @ColumnID	= 'AB'
      ,@err_num		= 0

--*************************************************************************************************
-- Field: Member ID
--*************************************************************************************************
SELECT @MemberID = REPLACE(@iMemberID, CHAR(160), ' ')
SELECT @MemberID = REPLACE(REPLACE(@MemberID,  CHAR(13) , ' '), CHAR(10), '')
SELECT @MemberID = TRIM(@MemberID)

SELECT @ColumnID	= 'AC'
      ,@err_num		= 0

IF (@MemberID = '') BEGIN SELECT @err_num = 2901, @err_msg = 'The Member ID field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Claim Number
--*************************************************************************************************
SELECT @ClaimNumber = REPLACE(@iClaimNumber, CHAR(160), ' ')
SELECT @ClaimNumber = REPLACE(REPLACE(@ClaimNumber,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ClaimNumber = TRIM(@ClaimNumber)

SELECT @ColumnID	= 'AD'
      ,@err_num		= 0

--*************************************************************************************************
-- Field: Group ID
--*************************************************************************************************
SELECT @GroupID = REPLACE(@iGroupID, CHAR(160), ' ')
SELECT @GroupID = REPLACE(REPLACE(@GroupID,  CHAR(13) , ' '), CHAR(10), '')
SELECT @GroupID = TRIM(@GroupID)

SELECT @ColumnID	= 'AE'
      ,@err_num		= 0

IF (@GroupID = '') BEGIN SELECT @err_num = 3101, @err_msg = 'The Group ID field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: LOB
--*************************************************************************************************
SELECT @LOB = REPLACE(@iLOB, CHAR(160), ' ')
SELECT @LOB = REPLACE(REPLACE(@LOB,  CHAR(13) , ' '), CHAR(10), '')
SELECT @LOB = TRIM(@LOB)

SELECT @ColumnID	= 'AF'
      ,@err_num		= 0

IF (@LOB = '') BEGIN SELECT @err_num = 3201, @err_msg = 'The LOB field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Patient Account Number
--*************************************************************************************************
SELECT @PatientAccountNumber = REPLACE(@iPatientAccountNumber, CHAR(160), ' ')
SELECT @PatientAccountNumber = REPLACE(REPLACE(@PatientAccountNumber,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PatientAccountNumber = TRIM(@PatientAccountNumber)

SELECT @ColumnID	= 'AG'
      ,@err_num		= 0

IF (@PatientAccountNumber = '') BEGIN SELECT @err_num = 3301, @err_msg = 'The Patient Account Number field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Provider ID
--*************************************************************************************************
SELECT @ProviderID = REPLACE(@iProviderID, CHAR(160), ' ')
SELECT @ProviderID = REPLACE(REPLACE(@ProviderID,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ProviderID = TRIM(@ProviderID)

SELECT @ColumnID	= 'AH'
      ,@err_num		= 0

IF (@ProviderID = '') BEGIN SELECT @err_num = 3401, @err_msg = 'The Provider ID field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: NPI
--*************************************************************************************************
SELECT @NPI = REPLACE(@iNPI, CHAR(160), ' ')
SELECT @NPI = REPLACE(REPLACE(@NPI,  CHAR(13) , ' '), CHAR(10), '')
SELECT @NPI = TRIM(@NPI)

SELECT @ColumnID	= 'AI'
      ,@err_num		= 0

IF (@NPI = '') BEGIN SELECT @err_num = 3501, @err_msg = 'The NPI field cannot be blank.' END
IF (CHARINDEX('E+',@NPI) > 0) BEGIN SELECT @err_num = 3501, @err_msg = 'The NPI field, ' + @NPI + ', appears to be in scientific notation. Please expand the AI column to show the entire NPI.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Expected Result Penalty Days
--*************************************************************************************************
SELECT @ExpectedResultPenaltyDays = REPLACE(@iExpectedResultPenaltyDays, CHAR(160), ' ')
SELECT @ExpectedResultPenaltyDays = REPLACE(REPLACE(@ExpectedResultPenaltyDays,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ExpectedResultPenaltyDays = TRIM(@ExpectedResultPenaltyDays)

SELECT @ColumnID	= 'AJ'
      ,@err_num		= 0

--*************************************************************************************************
-- Field: Penalty Days
--*************************************************************************************************
SELECT @PenaltyDays = REPLACE(@iPenaltyDays, CHAR(160), ' ')
SELECT @PenaltyDays = REPLACE(REPLACE(@PenaltyDays,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PenaltyDays = TRIM(@PenaltyDays)

SELECT @ColumnID	= 'AK'
      ,@err_num		= 0

IF (@PenaltyDays = '') BEGIN SELECT @err_num = 3701, @err_msg = 'The Penalty Days field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Penalty Amount
--*************************************************************************************************
SELECT @PenaltyAmount = REPLACE(@iPenaltyAmount, CHAR(160), ' ')
SELECT @PenaltyAmount = REPLACE(REPLACE(@PenaltyAmount,  CHAR(13) , ' '), CHAR(10), '')
SELECT @PenaltyAmount = TRIM(@PenaltyAmount)

SELECT @ColumnID	= 'AL'
      ,@err_num		= 0

IF (@PenaltyAmount = '') BEGIN SELECT @err_num = 3801, @err_msg = 'The Penalty Amount field cannot be blank.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Manual Interest
--*************************************************************************************************
SELECT @ManualInterest = REPLACE(@iManualInterest, CHAR(160), ' ')
SELECT @ManualInterest = REPLACE(REPLACE(@ManualInterest,  CHAR(13) , ' '), CHAR(10), '')
SELECT @ManualInterest = TRIM(@ManualInterest)

SELECT @ColumnID	= 'AM'
      ,@err_num		= 0

IF (@ManualInterest = '') BEGIN SELECT @err_num = 3901, @err_msg = 'The Manual Interest field cannot be blank.' END
IF (@ManualInterest = 'null') BEGIN SELECT @ManualInterest = NULL END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Verified
--*************************************************************************************************
SELECT @Verified = REPLACE(@iVerified, CHAR(160), ' ')
SELECT @Verified = REPLACE(REPLACE(@Verified,  CHAR(13) , ' '), CHAR(10), '')
SELECT @Verified = TRIM(@Verified)

SELECT @ColumnID	= 'AN'
      ,@err_num		= 0

--*************************************************************************************************
-- Field: Corrected Claim Relation
--*************************************************************************************************
SELECT @CorrectedClaimRelation = REPLACE(@iCorrectedClaimRelation, CHAR(160), ' ')
SELECT @CorrectedClaimRelation = REPLACE(REPLACE(@CorrectedClaimRelation,  CHAR(13) , ' '), CHAR(10), '')
SELECT @CorrectedClaimRelation = TRIM(@CorrectedClaimRelation)

SELECT @ColumnID	= 'AO'
      ,@err_num		= 0

IF (@CorrectedClaimRelation <> '' AND @CorrectedClaimRelation NOT IN ('O','C')) BEGIN SELECT @err_num = 4101, @err_msg = 'The Corrected Claim Relation, ' + @CorrectedClaimRelation + ', is not a vlaid value.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

--*************************************************************************************************
-- Field: Corrected Claim
--*************************************************************************************************
SELECT @CorrectedClaim = REPLACE(@iCorrectedClaim, CHAR(160), ' ')
SELECT @CorrectedClaim = REPLACE(REPLACE(@CorrectedClaim,  CHAR(13) , ' '), CHAR(10), '')
SELECT @CorrectedClaim = TRIM(@CorrectedClaim)

SELECT @ColumnID	= 'AP'
      ,@err_num		= 0

IF (@CorrectedClaimRelation = 'O' AND @CorrectedClaim = '') BEGIN SELECT @err_num = 4201, @err_msg = 'The Corrected Claim field cannot be blank when the Corrected Claim Relation is set to ''O''.' END

IF @err_num <> 0 BEGIN EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg END

END TRY
BEGIN CATCH
	SELECT @err_num = ERROR_NUMBER()
	      ,@err_msg = ERROR_MESSAGE()
	EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Field', @iRowID, @ColumnID, @err_num, @err_msg
END CATCH

--*************************************************************************************************
-- Save original record data to the RFFInterestScenarioOriginal table
--*************************************************************************************************
INSERT INTO [tmp].[RFFInterestScenarioOriginal]
           (FileID
		   ,RowID
		   ,[Scenario]
           ,[Comment]
           ,[Automate]
           ,[Scenario Detail]
           ,[State]
           ,[Network Status]
           ,[Tier]
           ,[Claim Form Type]
           ,[837 Submission Format]
           ,[Adjudication Type]
           ,[Paid RFF 1]
           ,[Paid Timely RFF 1]
           ,[Paid RFF 2]
           ,[Paid Timely RFF 2]
           ,[Paid RFF 3]
           ,[Paid Timely RFF 3]
           ,[Paid RFF 4]
           ,[Paid Timely RFF 4]
           ,[Submitted Amount]
           ,[True Allowed Amount]
           ,[Net Amount]
           ,[Patient Responsibility Amount]
           ,[Contract Discount]
           ,[Received Date]
           ,[Run Date]
           ,[Claim Line Number]
           ,[Step]
           ,[Change]
           ,[Member ID]
           ,[Claim Number]
           ,[Group ID]
           ,[LOB]
           ,[Patient Account Number]
           ,[Provider ID]
           ,[NPI]
           ,[Expected Result Text]
           ,[Expected Result Penalty Days]
           ,[Expected Result Penalty Amount]
           ,[Manual Interest]
           ,[Verified]
           ,[Corrected Claim Relation]
           ,[Corrected Claim])
     VALUES
           (@iFileID
		   ,@IRowID
		   ,@iScenario
		   ,@iScenarioType
		   ,@iAutomate
	       ,@iScenarioDetail
	       ,@iState
	       ,@iNetworkStatus
	       ,@iTier
	       ,@iClaimFormType
	       ,@i837SubmissionFormat
	       ,@iAdjudicationType
	       ,@iPaidRFF1
	       ,@iPaidTimelyRFF1
	       ,@iPaidRFF2
	       ,@iPaidTimelyRFF2
	       ,@iPaidRFF3
	       ,@iPaidTimelyRFF3
	       ,@iPaidRFF4
	       ,@iPaidTimelyRFF4
	       ,@iSubmittedAmount
	       ,@iTrueAllowedAmount
	       ,@iNetAmount
	       ,@iPatientResponsibilityAmount
	       ,@iContractDiscount
	       ,@iReceivedDate
	       ,@iRunDate
	       ,@iClaimLineNumber
	       ,@iStep
	       ,@iChange
	       ,@iMemberID
	       ,@iClaimNumber
	       ,@iGroupID
	       ,@iLOB
	       ,@PatientAccountNumber
	       ,@iProviderID
	       ,@iNPI
	       ,@iExpectedResultPenaltyDays
	       ,@iPenaltyDays
	       ,@iPenaltyAmount
	       ,@iManualInterest
	       ,@iVerified
	       ,@iCorrectedClaimRelation
	       ,@iCorrectedClaim)

--*************************************************************************************************
-- Save original record data to the RFFInterestScenarioOriginal table
--*************************************************************************************************
BEGIN TRY
	INSERT INTO [tmp].[RFFInterestScenario]
			   (FileID
			   ,RowID
			   ,[Scenario]
			   ,[Comment]
			   ,[Automate]
			   ,[Scenario Detail]
			   ,[State]
			   ,[Network Status]
			   ,[Tier]
			   ,[Claim Form Type]
			   ,[837 Submission Format]
			   ,[Adjudication Type]
			   ,[Paid RFF 1]
			   ,[Paid Timely RFF 1]
			   ,[Paid RFF 2]
			   ,[Paid Timely RFF 2]
			   ,[Paid RFF 3]
			   ,[Paid Timely RFF 3]
			   ,[Paid RFF 4]
			   ,[Paid Timely RFF 4]
			   ,[Submitted Amount]
			   ,[True Allowed Amount]
			   ,[Net Amount]
			   ,[Patient Responsibility Amount]
			   ,[Contract Discount]
			   ,[Received Date]
			   ,[Run Date]
			   ,[Claim Line Number]
			   ,[Step]
			   ,[Change]
			   ,[Member ID]
			   ,[Claim Number]
			   ,[Group ID]
			   ,[LOB]
			   ,[Patient Account Number]
			   ,[Provider ID]
			   ,[NPI]
			   ,[Expected Result Text]
			   ,[Expected Result Penalty Days]
			   ,[Expected Result Penalty Amount]
			   ,[Manual Interest]
			   ,[Verified]
			   ,[Corrected Claim Relation]
			   ,[Corrected Claim])
		 VALUES
			   (@iFileID
			   ,@iRowID
			   ,@Scenario
			   ,@ScenarioType
			   ,@Automate
			   ,@ScenarioDetail
			   ,@State
			   ,@NetworkStatus
			   ,@Tier
			   ,@ClaimFormType
			   ,@837SubmissionFormat
			   ,@AdjudicationType
			   ,@PaidRFF1
			   ,@PaidTimelyRFF1
			   ,@PaidRFF2
			   ,@PaidTimelyRFF2
			   ,@PaidRFF3
			   ,@PaidTimelyRFF3
			   ,@PaidRFF4
			   ,@PaidTimelyRFF4
			   ,@SubmittedAmount
			   ,@TrueAllowedAmount
			   ,@NetAmount
			   ,@PatientResponsibilityAmount
			   ,@ContractDiscount
			   ,@ReceivedDate
			   ,@RunDate
			   ,@ClaimLineNumber
			   ,@Step
			   ,@Change
			   ,@MemberID
			   ,@ClaimNumber
			   ,@GroupID
			   ,@LOB
			   ,@PatientAccountNumber
			   ,@ProviderID
			   ,@NPI
			   ,@ExpectedResultPenaltyDays
			   ,@PenaltyDays
			   ,@PenaltyAmount
			   ,@ManualInterest
			   ,@Verified
			   ,@CorrectedClaimRelation
			   ,@CorrectedClaim)
END TRY
BEGIN CATCH
	
	SELECT @err_num = 101
	      ,@err_msg = 'The row, ' + CONVERT(VARCHAR(20), @iRowID) + ', failed to save due to the following error: ' + ERROR_MESSAGE()
		  ,@ColumnID = ''
	EXEC spAPIAuto_ImportRFFInterestError @iFileID, 'Record', @iRowID, @ColumnID, @err_num, @err_msg 

END CATCH

END
GO