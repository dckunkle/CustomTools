/**************************************************************************************************
Name:       spConfig_GridImportCopayLevel
Purpose:    Import the Copay Levels and Variations from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original procedure
12/16/2022  DK				Added ability to force benefits to a specific copay
12/16/2022  DK				Modify free visit logic from 2 and 4 to 6 and 10
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportCopayLevel 'Bright-0408-', 'ALL'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportCopayLevel
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL'
	 ,@plan_id			VARCHAR(100)	= ''
	 ,@shells_only		BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

DECLARE @configuration_id	VARCHAR(100)
       ,@effective_date		VARCHAR(100)

SELECT @configuration_id = @config_id

--*************************************************************************************************
-- Get Parameters
--*************************************************************************************************
SELECT @effective_date = ParameterValue
  FROM grid.GridParameter
 WHERE ParameterName = 'EffectiveDate'

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
	  ,out_of_pocket_id		INT
	  ,copay_id				INT
	  ,grid_row				INT)

IF OBJECT_ID('tempdb.dbo.#OtherBenefits') IS NOT NULL
	BEGIN DROP TABLE #OtherBenefits END

--*************************************************************************************************
-- Create table to hold additional benefits
--*************************************************************************************************
CREATE TABLE #OtherBenefits
      (benefit_id			VARCHAR(50)
	  ,benefit				VARCHAR(100)
	  ,benefit_description	VARCHAR(1000))

INSERT INTO #OtherBenefits(benefit_id, benefit ,benefit_description) VALUES(9910, 'NOCOINS', 'NOCOINS')

--*************************************************************************************************
-- Handle the scenarios where multiple client benefits map to a single Core benefit, or duplicate mappings
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ManyBenefitsToOne') IS NOT NULL
	BEGIN DROP TABLE #ManyBenefitsToOne END

CREATE TABLE #ManyBenefitsToOne
      (benefit_id			VARCHAR(100)
	  ,core_benefit_id		VARCHAR(100)
	  ,record_id			INT
	  ,duplicated			BIT
	  ,selected				BIT)

INSERT INTO #ManyBenefitsToOne
      (benefit_id
	  ,core_benefit_id
	  ,record_id
	  ,duplicated
	  ,selected)
SELECT BenefitID
      ,CoreBenefitID
	  ,RecordID
	  ,0
	  ,0
  FROM grid.PlanBenefitCrosswalk
 WHERE MappingType			= 'M:1'
   AND Ignore				= 0
   AND CoreBenefitID		NOT IN ('1193')

--*************************************************************************************************
-- Determine which client benefit and which duplicate to use to create the variations
--*************************************************************************************************
UPDATE #ManyBenefitsToOne
   SET selected	= 1
 WHERE benefit_id IN (SELECT MIN(benefit_id) FROM #ManyBenefitsToOne GROUP BY core_benefit_id)

-- Special scenario
UPDATE #ManyBenefitsToOne
   SET Selected = 1
 WHERE benefit_id = 23

UPDATE #ManyBenefitsToOne
   SET Selected = 0
 WHERE benefit_id = 114

;WITH CTE_Duplicates
   AS(SELECT BenefitID
            ,CoreBenefitID
        FROM grid.PlanBenefitCrosswalk
	   GROUP BY BenefitID
	           ,CoreBenefitID
	  HAVING COUNT(*) > 1)
UPDATE M1
   SET duplicated			= 1
 FROM CTE_Duplicates		D
 JOIN #ManyBenefitsToOne	M1
   ON D.CoreBenefitID		= M1.core_benefit_id
  AND D.BenefitID			= M1.benefit_id

UPDATE #ManyBenefitsToOne
   SET selected				= 0
 WHERE duplicated			= 1

UPDATE #ManyBenefitsToOne
   SET selected	= 1
 WHERE record_id IN (SELECT MIN(record_id) FROM #ManyBenefitsToOne WHERE duplicated = 1 GROUP BY benefit_id, core_benefit_id)

UPDATE CW
   SET Ignore = 1
  FROM grid.PlanBenefitCrosswalk	CW
  JOIN #ManyBenefitsToOne			M1
    ON CW.BenefitID					= M1.benefit_id
 WHERE M1.selected					= 0
   AND M1.duplicated				= 0

UPDATE CW
   SET Ignore = 1
  FROM grid.PlanBenefitCrosswalk	CW
  JOIN #ManyBenefitsToOne			M1
    ON CW.RecordID					= M1.record_id
 WHERE M1.selected					= 0
   AND M1.duplicated				= 1

--*************************************************************************************************
-- Clear any previously created records from the destination tables
--*************************************************************************************************
IF @state <> 'ALL'
	BEGIN
		SELECT @configuration_id = @configuration_id + '-' + @state
	END

DELETE 
  FROM data.CopayLevel
 WHERE ConfigurationID LIKE @configuration_id + '%'

DELETE 
  FROM data.CopayLevelVariation
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Build a table of the plans to begin importing
--*************************************************************************************************
INSERT INTO #GridPlans
      (plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id
	  ,copay_id
	  ,grid_row)
SELECT P.PlanID
      ,P.PlanName
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
	  ,P.CopayID
	  ,P.GridRow
  FROM grid.[Plan]	P
 WHERE 1 = CASE WHEN @state = 'ALL'	THEN 1
				WHEN P.PlanState = @state THEN 1
				ELSE 0
			END
   --AND P.PlanState NOT IN ('IL','SC','OK')		-- States removed due to low enrollment

--*************************************************************************************************
-- Clear any prevously created records from the destination tables
--*************************************************************************************************
IF @state <> 'ALL'
	BEGIN
		SELECT @configuration_id = @configuration_id + '-' + @state
	END

DELETE 
  FROM data.CopayLevel
 WHERE ConfigurationID LIKE @configuration_id + '%'

DELETE 
  FROM data.CopayLevelVariation
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Add the Copay Levels for the plans
--*************************************************************************************************
INSERT INTO [data].[CopayLevel]
      (ConfigurationID
	  ,ParentID
	  ,NewCopayStrategyID
      ,NewCopayStrategyDesc
      ,CopyFromCopayStrategyID
      ,CopyFromCopayStrategyDesc
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPL-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), GP.grid_row), 5)
      ,''
	  ,GP.plan_name
	  ,GP.plan_desc
	  ,''
	  ,''
	  ,'Add'
	  ,'A'
  FROM #GridPlans	GP

IF @shells_only = 1 GOTO SHELLS_ONLY

--*************************************************************************************************
-- Add the Copay Level Variations for PCP and Specialist visits
--*************************************************************************************************
--Scenario: X free visit(s) - First Part (1196, 1296, 1396)
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,CASE WHEN PC.Visits = 1 THEN '1196'
	        WHEN PC.Visits = 2 THEN '1296'
			WHEN PC.Visits = 3 THEN '1396'
		END 						ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,CASE WHEN PC.BenefitID = 6 THEN 'P'
	        WHEN PC.BenefitId = 10 THEN 'S'
		    ELSE '*'
		 END						ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,PC.CopayScheduleName			CopayScheduleID
      ,PC.CopayScheduleDescription	CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
  JOIN [grid].PlanCoinsuranceCopay	PC
    ON GP.copay_id					= PC.CopayID
 WHERE PC.Automate					= 1
   AND PC.Ignore					= 0
   AND PC.FreeVisit					= 1
   AND PC.Visits					> 0

--Scenario: X free visit(s) - Second Part (196 NOCOINS)
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,'196' 						ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,CASE WHEN PC.BenefitID = 6 THEN 'P'
	        WHEN PC.BenefitId = 10 THEN 'S'
		    ELSE '*'
		 END						ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,'NOCOINS'					CopayScheduleID
      ,'NOCOINS'					CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
  JOIN [grid].PlanCoinsuranceCopay	PC
    ON GP.copay_id					= PC.CopayID
 WHERE PC.Automate					= 1
   AND PC.Ignore					= 0
   AND PC.FreeVisit					= 1
   AND PC.Visits					> 0

--Scenario: X free visit(s) - Second Part (191 NOCOINS)
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,'191' 						ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,'S'							ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,'NOCOINS'					CopayScheduleID
      ,'NOCOINS'					CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
  JOIN [grid].PlanCoinsuranceCopay	PC
    ON GP.copay_id					= PC.CopayID
 WHERE PC.Automate					= 1
   AND PC.Ignore					= 0
   AND PC.FreeVisit					= 1
   AND PC.Visits					> 0
   AND PC.BenefitID					= 10

--Scenario: PCP or specialist without free visits (196)
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,'196' 						ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,CASE WHEN PC.BenefitID = 6 THEN 'P'
	        WHEN PC.BenefitId = 10 THEN 'S'
		    ELSE '*'
		 END						ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,PC.CopayScheduleName			CopayScheduleID
      ,PC.CopayScheduleDescription	CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
  JOIN [grid].PlanCoinsuranceCopay	PC
    ON GP.copay_id					= PC.CopayID
 WHERE PC.Automate					= 1
   AND PC.Ignore					= 0
   AND PC.FreeVisit					= 0
   AND PC.BenefitID					IN (6,10)

--Scenario: Specialist without free visits (191)
--INSERT INTO [data].[CopayLevelVariation]
--      (ConfigurationID
--      ,ParentID
--      ,CopayLevelsID
--      ,CopayLevelsDesc
--      ,EffectiveDate
--      ,TerminationDate
--      ,NetworkVariation
--      ,ClassVariation
--      ,CodeVariation
--      ,ReportingClassVar
--      ,UptoCoverageUnits
--      ,NumberofCoverageUnits
--      ,BasisofCoverage
--      ,ProviderType
--      ,AuthExists
--      ,DispenserType
--      ,AssignmentVariation
--      ,ProcessingPriority
--      ,DomainRuleID
--      ,DomainRuleDesc
--      ,DomainRulePriority
--      ,TaxonomyListID
--      ,TaxonomyListDesc
--      ,CopayScheduleID
--      ,CopayScheduleName
--      ,[Action]
--      ,[Status])
--SELECT @configuration_id + GP.plan_state + '-'
--                         + 'CPLV-' 
--                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
--						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
--      ,GP.plan_name
--	  ,GP.plan_name					CopayLevelsID
--	  ,GP.plan_desc					CopayLevelsDesc
--	  ,@effective_date				EffectiveDate
--	  ,'12/31/9999'					TerminationDate
--	  ,'*'							NetworkVariation			
--	  ,'191' 						ClassVariation
--	  ,'*'							CodeVariation
--      ,'******'						ReportingClassVar
--      ,''							UptoCoverageUnits
--      ,'0'							NumberofCoverageUnits
--      ,''							BasisofCoverage
--      ,'S'							ProviderType
--      ,'*'							AuthExists
--      ,'**'							DispenserType
--      ,'*'							AssignmentVariation
--      ,'0'							ProcessingPriority
--      ,''							DomainRuleID
--      ,''							DomainRuleDesc
--      ,'9999'						DomainRulePriority
--      ,''							TaxonomyListID
--      ,''							TaxonomyListDesc
--      ,PC.CopayScheduleName			CopayScheduleID
--      ,PC.CopayScheduleDescription	CopayScheduleName
--	  ,'Add'
--	  ,'A'
--  FROM #GridPlans					GP
--  JOIN [grid].PlanCoinsuranceCopay	PC
--    ON GP.copay_id					= PC.CopayID
-- WHERE PC.Automate					= 1
--   AND PC.Ignore					= 0
--   AND PC.FreeVisit					= 0
--   AND PC.BenefitID					IN (10)

--*************************************************************************************************
-- Add the Copay Level Variations for the rest of the benefits
--*************************************************************************************************
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), PC.GridRow), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), PC.GridColumn), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,CW.CoreBenefitID				ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,CASE WHEN PC.BenefitID = '116' THEN 'P' 
	        WHEN PC.BenefitID = '117' THEN 'S'
			ELSE '*'
		END ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,PC.CopayScheduleName			CopayScheduleID
      ,PC.CopayScheduleDescription	CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
  JOIN [grid].PlanCoinsuranceCopay	PC
    ON GP.copay_id					= PC.CopayID
  JOIN [grid].PlanBenefitCrosswalk	CW
    ON PC.BenefitID					= CW.BenefitID
 WHERE PC.Automate					= 1
   AND PC.FreeVisit					= 0
   AND PC.Ignore					= 0
   AND CW.Ignore					= 0
   --AND CW.MappingType				IN ('1:1', '1:M')

--*************************************************************************************************
-- Additional benefits that need to be added
--*************************************************************************************************
INSERT INTO [data].[CopayLevelVariation]
      (ConfigurationID
      ,ParentID
      ,CopayLevelsID
      ,CopayLevelsDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,ClassVariation
      ,CodeVariation
      ,ReportingClassVar
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ProviderType
      ,AuthExists
      ,DispenserType
      ,AssignmentVariation
      ,ProcessingPriority
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,TaxonomyListID
      ,TaxonomyListDesc
      ,CopayScheduleID
      ,CopayScheduleName
      ,[Action]
      ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
                         + 'CPLV-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), 99999), 5)
						 + RIGHT('000' + CONVERT(VARCHAR(10), 999), 3)
      ,GP.plan_name
	  ,GP.plan_name					CopayLevelsID
	  ,GP.plan_desc					CopayLevelsDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'*'							NetworkVariation			
	  ,OB.benefit_id				ClassVariation
	  ,'*'							CodeVariation
      ,'******'						ReportingClassVar
      ,''							UptoCoverageUnits
      ,'0'							NumberofCoverageUnits
      ,''							BasisofCoverage
      ,'*'							ProviderType
      ,'*'							AuthExists
      ,'**'							DispenserType
      ,'*'							AssignmentVariation
      ,'0'							ProcessingPriority
      ,''							DomainRuleID
      ,''							DomainRuleDesc
      ,'9999'						DomainRulePriority
      ,''							TaxonomyListID
      ,''							TaxonomyListDesc
      ,OB.benefit					CopayScheduleID
      ,OB.benefit_description		CopayScheduleName
	  ,'Add'
	  ,'A'
  FROM #GridPlans					GP
      ,#OtherBenefits				OB

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
SHELLS_ONLY:

IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END

IF OBJECT_ID('tempdb.dbo.#ManyBenefitsToOne') IS NOT NULL
	BEGIN DROP TABLE #ManyBenefitsToOne END

END
GO