/**************************************************************************************************
Name:       spConfig_GridImportCopaySchedule
Purpose:    Import the Coinsurance/Copay data from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original procedure
10/06/2022  DK				2023 Plan changes, separate flags to new procedure, add 0%
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportCopaySchedule 'Bright-0407-', 'ALL'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportCopaySchedule
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL'
	 ,@shells_only		BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

DECLARE @configuration_id VARCHAR(100)

SELECT @configuration_id = @config_id

--*************************************************************************************************
-- Create table to hold plans
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END

CREATE TABLE #GridPlans
      (plan_name			VARCHAR(50)
	  ,plan_desc			VARCHAR(500)
	  ,plan_state			VARCHAR(10)
	  ,deductible_id		INT
	  ,out_of_pocket_id		INT)

IF OBJECT_ID('tempdb.dbo.#GridSchedules') IS NOT NULL
	BEGIN DROP TABLE #GridSchedules END

CREATE TABLE #GridSchedules
      (schedule_name		VARCHAR(50)
	  ,schedule_desc		VARCHAR(500)
	  ,dollar_amount		VARCHAR(10)
	  ,percent_amount		VARCHAR(10)
	  ,record_id			INT)

IF @shells_only = 1 GOTO SHELLS_ONLY

--*************************************************************************************************
-- Build a table of the plans to begin importing
--*************************************************************************************************
INSERT INTO #GridPlans
      (plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id)
SELECT P.PlanID
      ,P.PlanName
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
  FROM grid.[Plan]	P
 WHERE 1 = CASE WHEN @state = 'ALL'	THEN 1
				WHEN P.PlanState = @state THEN 1
				ELSE 0
			END
   --AND P.PlanState NOT IN ('IL','SC','OK')		-- States removed due to low enrollment

--*************************************************************************************************
-- Create Copay Schedules for known scenarios
--*************************************************************************************************
-- Scenario: $0
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND DollarAmount					= '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 0

-- Scenario: 0%
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND DollarAmount					= '-1'
   AND Dollar						= -0
   AND [Percentage]					= 1
   AND PercentageAmount				= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 0

-- Scenario: $0 after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND DollarAmount					= '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: 0% after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND PercentageAmount				= '0'
   AND [Percentage]					= 1
   AND Dollar						= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: NOT COVERED
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'MEMBER PAYS 100'
      ,CopayScheduleDescription		= 'MEMBER PAYS 100%'
 WHERE Automate						= 1
   AND CopayCoinsValue				IN ('NOT COVERED','N/A','NOT APPLICABLE')
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: $XX
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= DollarAmount + ' COPAY'
      ,CopayScheduleDescription		= '$' + DollarAmount + ' COPAY'
 WHERE Automate						= 1
   AND DollarAmount					<> '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 0
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: $XX after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= DollarAmount + ' COPAY'
      ,CopayScheduleDescription		= '$' + DollarAmount + ' COPAY'
 WHERE Automate						= 1
   AND DollarAmount					<> '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: XX%
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= PercentageAmount + ' COINS'
      ,CopayScheduleDescription		= PercentageAmount + '% COINS'
 WHERE Automate						= 1
   AND PercentageAmount				<> '0'
   AND [Percentage]					= 1
   AND Dollar						= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 0
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: XX% after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= PercentageAmount + ' COINS'
      ,CopayScheduleDescription		= PercentageAmount + '% COINS'
 WHERE Automate						= 1
   AND PercentageAmount				<> '0'
   AND [Percentage]					= 1
   AND Dollar						= 0
   AND FreeVisit					= 0
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: X free visit(s) then 0% after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND PercentageAmount				= '0'
   AND [Percentage]					= 1
   AND Dollar						= 0
   AND FreeVisit					= 1
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: X free visit(s) then $XX
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= DollarAmount + ' COPAY'
      ,CopayScheduleDescription		= '$' + DollarAmount + ' COPAY'
 WHERE Automate						= 1
   AND DollarAmount					<> '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 1
   AND AfterDeductible				= 0
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: X free visit(s) then $0
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= 'NOCOINS'
      ,CopayScheduleDescription		= 'NOCOINS'
 WHERE Automate						= 1
   AND DollarAmount					= '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 1
   AND AfterDeductible				= 0
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

-- Scenario: X free visit(s) then $XX after deductible
UPDATE grid.PlanCoinsuranceCopay
   SET CopayScheduleName			= DollarAmount + ' COPAY'
      ,CopayScheduleDescription		= '$' + DollarAmount + ' COPAY'
 WHERE Automate						= 1
   AND DollarAmount					<> '0'
   AND Dollar						= 1
   AND [Percentage]					= 0
   AND FreeVisit					= 1
   AND AfterDeductible				= 1
   AND CopayScheduleName			IS NULL
   AND CopayScheduleDescription		IS NULL

--*************************************************************************************************
-- Clear any previously created records from the destination tables
--*************************************************************************************************
IF @state <> 'ALL'
	BEGIN
		SELECT @configuration_id = @configuration_id + '-' + @state
	END

DELETE 
  FROM data.CopaySchedule
 WHERE ConfigurationID LIKE @configuration_id + '%'

DELETE 
  FROM data.CopayScheduleVariation
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Now build out the Copay Schedules
--*************************************************************************************************
INSERT INTO #GridSchedules
      (schedule_name
	  ,schedule_desc
	  ,record_id)
SELECT PCC.CopayScheduleName
      ,PCC.CopayScheduleDescription
	  ,MIN(PCC.RecordID)
  FROM grid.PlanCoinsuranceCopay		PCC
 WHERE PCC.Automate						= 1
 GROUP BY PCC.CopayScheduleName
	     ,PCC.CopayScheduleDescription

UPDATE GS
   SET dollar_amount				= PCC.DollarAmount
      ,percent_amount				= PCC.PercentageAmount
  FROM grid.PlanCoinsuranceCopay	PCC
  JOIN #GridSchedules				GS
    ON PCC.RecordID					= GS.record_id

INSERT INTO [data].[CopaySchedule]
      (ConfigurationID
      ,ParentID
      ,ID
      ,[Description]
      ,ComparisonFlag
      ,MaxCopayisSubmittedCost
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + '-CPS-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3)
	  ,''
	  ,GS.schedule_name
	  ,GS.schedule_desc
	  ,'F'
	  ,'Y'
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE PCC.Ignore					= 0

--*************************************************************************************************
-- Now build out the Copay Schedule Variations for copays
--*************************************************************************************************
-- Scenario: XX COPAY (requires two variations, one for the copay and the second for plan pays 100%)
INSERT INTO [data].[CopayScheduleVariation]
      (ConfigurationID
      ,ParentID
      ,CopaySource
      ,CopayType
      ,CalcType
      ,SequenceNumber
      ,DAWCode
      ,DifferentialOption
      ,CopayPercent
      ,DollarAmount
      ,MinCopayAmount
      ,MaxCopayAmount
      ,MinIncPercent
      ,MaxIncPercent
      ,DecrementPcnt
      ,IncrementPcnt
      ,IncentiveBaseDate
      ,CopayMultiplierBasis
      ,ScheduleStepID
      ,ScheduleStepDesc
      ,FeeScheduleLookup
      ,FeeDescription
      ,RemarkCodeID1
      ,Remark1Desc
      ,RemarkCodeID2
      ,Remark2Desc
      ,[Action]
      ,[Status])
SELECT @configuration_id + '-CPSV-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3) + '-1'
	  ,GS.schedule_name		ParentID
      ,'C'					CopaySource
      ,'F'					CopayType
      ,'M'					CalcType
      ,'1'					SequenceNumber
      ,'0'					DAWCode
      ,'0'					DifferentialOption
      ,'0'					CopayPercent
      ,GS.dollar_amount		DollarAmount
      ,'0.00'				MinCopayAmount
      ,'0.00'				MaxCopayAmount
      ,'0'					MinIncPercent
      ,'0'					MaxIncPercent
      ,'0'					DecrementPcnt
      ,'0'					IncrementPcnt
      ,'N'					IncentiveBaseDate
      ,''					CopayMultiplierBasis
      ,''					ScheduleStepID
      ,''					ScheduleStepDesc
      ,''					FeeScheduleLookup
      ,''					FeeDescription
      ,'3'					RemarkCodeID1
      ,''					Remark1Desc
      ,''					RemarkCodeID2
      ,''					Remark2Desc
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE GS.schedule_name				LIKE '%COPAY%'
   AND PCC.Ignore					= 0

INSERT INTO [data].[CopayScheduleVariation]
      (ConfigurationID
      ,ParentID
      ,CopaySource
      ,CopayType
      ,CalcType
      ,SequenceNumber
      ,DAWCode
      ,DifferentialOption
      ,CopayPercent
      ,DollarAmount
      ,MinCopayAmount
      ,MaxCopayAmount
      ,MinIncPercent
      ,MaxIncPercent
      ,DecrementPcnt
      ,IncrementPcnt
      ,IncentiveBaseDate
      ,CopayMultiplierBasis
      ,ScheduleStepID
      ,ScheduleStepDesc
      ,FeeScheduleLookup
      ,FeeDescription
      ,RemarkCodeID1
      ,Remark1Desc
      ,RemarkCodeID2
      ,Remark2Desc
      ,[Action]
      ,[Status])
SELECT @configuration_id + '-CPSV-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3) + '-2'
	  ,GS.schedule_name		ParentID
      ,'C'					CopaySource
      ,'F'					CopayType
      ,'P'					CalcType
      ,'2'					SequenceNumber
      ,'0'					DAWCode
      ,'0'					DifferentialOption
      ,'100'				CopayPercent
      ,'0'					DollarAmount
      ,'0.00'				MinCopayAmount
      ,'0.00'				MaxCopayAmount
      ,'0'					MinIncPercent
      ,'0'					MaxIncPercent
      ,'0'					DecrementPcnt
      ,'0'					IncrementPcnt
      ,'N'					IncentiveBaseDate
      ,''					CopayMultiplierBasis
      ,''					ScheduleStepID
      ,''					ScheduleStepDesc
      ,''					FeeScheduleLookup
      ,''					FeeDescription
      ,'3'					RemarkCodeID1
      ,''					Remark1Desc
      ,''					RemarkCodeID2
      ,''					Remark2Desc
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE GS.schedule_name				LIKE '%COPAY%'
   AND PCC.Ignore					= 0

--*************************************************************************************************
-- Now build out the Copay Schedule Variations for coinsurance
--*************************************************************************************************
-- Scenario: XX COINS
INSERT INTO [data].[CopayScheduleVariation]
      (ConfigurationID
      ,ParentID
      ,CopaySource
      ,CopayType
      ,CalcType
      ,SequenceNumber
      ,DAWCode
      ,DifferentialOption
      ,CopayPercent
      ,DollarAmount
      ,MinCopayAmount
      ,MaxCopayAmount
      ,MinIncPercent
      ,MaxIncPercent
      ,DecrementPcnt
      ,IncrementPcnt
      ,IncentiveBaseDate
      ,CopayMultiplierBasis
      ,ScheduleStepID
      ,ScheduleStepDesc
      ,FeeScheduleLookup
      ,FeeDescription
      ,RemarkCodeID1
      ,Remark1Desc
      ,RemarkCodeID2
      ,Remark2Desc
      ,[Action]
      ,[Status])
SELECT @configuration_id + '-CPSV-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3) + '-1'
	  ,GS.schedule_name		ParentID
      ,'C'					CopaySource
      ,'F'					CopayType
      ,'P'					CalcType
      ,'1'					SequenceNumber
      ,'0'					DAWCode
      ,'0'					DifferentialOption
      ,100 - CONVERT(INT, GS.percent_amount)	
							CopayPercent
      ,'0'					DollarAmount
      ,'0.00'				MinCopayAmount
      ,'0.00'				MaxCopayAmount
      ,'0'					MinIncPercent
      ,'0'					MaxIncPercent
      ,'0'					DecrementPcnt
      ,'0'					IncrementPcnt
      ,'N'					IncentiveBaseDate
      ,''					CopayMultiplierBasis
      ,''					ScheduleStepID
      ,''					ScheduleStepDesc
      ,''					FeeScheduleLookup
      ,''					FeeDescription
      ,'2'					RemarkCodeID1
      ,''					Remark1Desc
      ,''					RemarkCodeID2
      ,''					Remark2Desc
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE GS.schedule_name				LIKE '%COINS%'
   AND GS.schedule_name				<> 'NOCOINS'
   AND PCC.Ignore					= 0

--*************************************************************************************************
-- Now build out the Copay Schedule Variations for other scenarios (MEMBER PAYS 100 and PLAN PAYS 100)
--*************************************************************************************************
-- Scenario: MEMBER PAYS 100
INSERT INTO [data].[CopayScheduleVariation]
      (ConfigurationID
      ,ParentID
      ,CopaySource
      ,CopayType
      ,CalcType
      ,SequenceNumber
      ,DAWCode
      ,DifferentialOption
      ,CopayPercent
      ,DollarAmount
      ,MinCopayAmount
      ,MaxCopayAmount
      ,MinIncPercent
      ,MaxIncPercent
      ,DecrementPcnt
      ,IncrementPcnt
      ,IncentiveBaseDate
      ,CopayMultiplierBasis
      ,ScheduleStepID
      ,ScheduleStepDesc
      ,FeeScheduleLookup
      ,FeeDescription
      ,RemarkCodeID1
      ,Remark1Desc
      ,RemarkCodeID2
      ,Remark2Desc
      ,[Action]
      ,[Status])
SELECT @configuration_id + '-CPSV-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3) + '-1'
	  ,GS.schedule_name		ParentID
      ,'C'					CopaySource
      ,'F'					CopayType
      ,'M'					CalcType
      ,'1'					SequenceNumber
      ,'0'					DAWCode
      ,'0'					DifferentialOption
      ,'100'				CopayPercent
      ,'0'					DollarAmount
      ,'0.00'				MinCopayAmount
      ,'0.00'				MaxCopayAmount
      ,'0'					MinIncPercent
      ,'0'					MaxIncPercent
      ,'0'					DecrementPcnt
      ,'0'					IncrementPcnt
      ,'N'					IncentiveBaseDate
      ,''					CopayMultiplierBasis
      ,''					ScheduleStepID
      ,''					ScheduleStepDesc
      ,''					FeeScheduleLookup
      ,''					FeeDescription
      ,''					RemarkCodeID1
      ,''					Remark1Desc
      ,''					RemarkCodeID2
      ,''					Remark2Desc
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE GS.schedule_name				= 'MEMBER PAYS 100'
   AND PCC.Ignore					= 0

-- Scenario: PLAN PAYS 100
INSERT INTO [data].[CopayScheduleVariation]
      (ConfigurationID
      ,ParentID
      ,CopaySource
      ,CopayType
      ,CalcType
      ,SequenceNumber
      ,DAWCode
      ,DifferentialOption
      ,CopayPercent
      ,DollarAmount
      ,MinCopayAmount
      ,MaxCopayAmount
      ,MinIncPercent
      ,MaxIncPercent
      ,DecrementPcnt
      ,IncrementPcnt
      ,IncentiveBaseDate
      ,CopayMultiplierBasis
      ,ScheduleStepID
      ,ScheduleStepDesc
      ,FeeScheduleLookup
      ,FeeDescription
      ,RemarkCodeID1
      ,Remark1Desc
      ,RemarkCodeID2
      ,Remark2Desc
      ,[Action]
      ,[Status])
SELECT @configuration_id + '-CPSV-' 
					     + RIGHT('0000' + CONVERT(VARCHAR(10), PCC.GridRow), 4) + '-'
						 + RIGHT('000' + CONVERT(VARCHAR(10), PCC.GridColumn), 3) + '-1'
	  ,GS.schedule_name		ParentID
      ,'C'					CopaySource
      ,'F'					CopayType
      ,'P'					CalcType
      ,'1'					SequenceNumber
      ,'0'					DAWCode
      ,'0'					DifferentialOption
      ,'100'				CopayPercent
      ,'0'					DollarAmount
      ,'0.00'				MinCopayAmount
      ,'0.00'				MaxCopayAmount
      ,'0'					MinIncPercent
      ,'0'					MaxIncPercent
      ,'0'					DecrementPcnt
      ,'0'					IncrementPcnt
      ,'N'					IncentiveBaseDate
      ,''					CopayMultiplierBasis
      ,''					ScheduleStepID
      ,''					ScheduleStepDesc
      ,''					FeeScheduleLookup
      ,''					FeeDescription
      ,''					RemarkCodeID1
      ,''					Remark1Desc
      ,''					RemarkCodeID2
      ,''					Remark2Desc
	  ,'Add'
	  ,'A'
  FROM #GridSchedules				GS
  JOIN grid.PlanCoinsuranceCopay	PCC
    ON GS.record_id					= PCC.RecordID
 WHERE GS.schedule_name				= 'NOCOINS'
   AND PCC.Ignore					= 0

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
SHELLS_ONLY:

IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END

IF OBJECT_ID('tempdb.dbo.#GridSchedules') IS NOT NULL
	BEGIN DROP TABLE #GridSchedules END

END
GO