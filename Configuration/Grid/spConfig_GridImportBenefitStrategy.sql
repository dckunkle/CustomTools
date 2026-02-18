/**************************************************************************************************
Name:       spConfig_GridImportBenefitStrategy
Purpose:    Import Benefit Strategy and Benefit Strategy Variations data from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
03/23/2022	DK				Original procedure
06/01/2022  DK				Changes for CPAD (copay after deductible) logic
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportBenefitStrategy 'Bright-0601-', 'ALL'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportBenefitStrategy
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL'
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
      (plan_name				VARCHAR(50)
	  ,plan_desc				VARCHAR(500)
	  ,plan_state				VARCHAR(10)
	  ,deductible_id			INT
	  ,out_of_pocket_id			INT
	  ,copay_after_deductible	BIT
	  ,grid_row					INT)

--*************************************************************************************************
-- Build a table of the plans to begin importing
--*************************************************************************************************
INSERT INTO #GridPlans
      (plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id
	  ,copay_after_deductible
	  ,grid_row)
SELECT P.PlanID
      ,P.PlanName
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
	  ,P.CopayAfterDeductible
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
  FROM data.BenefitStrategy
 WHERE ConfigurationID LIKE @configuration_id + '%'

DELETE 
  FROM data.BenefitStrategyVariation
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Add the Benefit Strategies for the plans
--*************************************************************************************************
INSERT INTO [data].[BenefitStrategy]
      (ConfigurationID
	  ,ParentID
	  ,NewBenefitStrategyID
	  ,NewBenefitStrategyDescription
	  ,CopyFromBenefitStrategyID
	  ,CopyFromBenefitStrategyDesc
	  ,BenefitProcessingHierarchy
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + GP.plan_state + '-'
						 + 'BS-' 
                         + RIGHT('00000' + CONVERT(VARCHAR(10), GP.grid_row), 5)
      ,''
	  ,GP.plan_name
	  ,GP.plan_desc
	  ,''
	  ,''
	  ,'S'
	  ,'Add'
	  ,'A'
  FROM #GridPlans	GP

IF @shells_only = 1 GOTO SHELLS_ONLY

--*************************************************************************************************
-- Add the Benefit Strategy Variations for deductibles for the plans
--*************************************************************************************************
INSERT INTO data.BenefitStrategyVariation
      (ConfigurationID
      ,ParentID
      ,StrategyID
      ,StrategyDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,BenefitClassVariation
      ,BenefitRuleID
      ,BenefitRuleDesc
      ,NetworkGroupingID
      ,NetworkGroupingDesc
      ,ClassGroupingID
      ,ClassGroupingDesc
      ,CodeListID
      ,CodeListDesc
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ReportingClassVar
      ,UsedinPlanSummaryBenefitDisplay
      ,PerToothBenefitStrategy
      ,DiagnosisValidationID
      ,DiagnosisDesc
      ,POSListID
      ,POSListDesc
      ,TOBListID
      ,TOBListDesc
      ,AccidentBenefit
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,SingleMemberVariation
      ,Action
      ,Status)
SELECT @configuration_id + GP.plan_state + '-' 
                         + 'BSV-' 
					     + PD.CoreDeductibleType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), PD.GridRow), 5)
							ConfigurationID
      ,GP.plan_name			ParentID
      ,GP.plan_name			StrategyID
      ,GP.plan_desc			StrategyDesc
      ,@effective_date		EffectiveDate
      ,'12/31/9999'			TerminationDate
      ,CASE WHEN GP.plan_state = 'OK' THEN 'I'
	        ELSE '*'
		END					NetworkVariation
      ,'0'					BenefitClassVariation
      ,PD.CoreDeductibleID	BenefitRuleID
      ,''					BenefitRuleDesc
      ,''					NetworkGroupingID
      ,''					NetworkGroupingDesc
      ,''					ClassGroupingID
      ,''					ClassGroupingDesc
      ,''					CodeListID
      ,''					CodeListDesc
      ,''					UptoCoverageUnits
      ,'0'					NumberofCoverageUnits
      ,''					BasisofCoverage
      ,'******'				ReportingClassVar
      ,'Y'					UsedinPlanSummaryBenefitDisplay
      ,'N'					PerToothBenefitStrategy
      ,''					DiagnosisValidationID
      ,''					DiagnosisDesc
      ,''					POSListID
      ,''					POSListDesc
      ,''					TOBListID
      ,''					TOBListDesc
      ,'N'					AccidentBenefit
      ,''					DomainRuleID
      ,''					DomainRuleDesc
      ,'9999'				DomainRulePriority
      ,'N'					SingleMemberVariation
      ,'Add'				Action
      ,'A'					Status
  FROM #GridPlans					GP
  JOIN grid.PlanDeductible			PD
    ON GP.deductible_id				= PD.DeductibleID
   AND GP.copay_after_deductible	= PD.CopayAfterDeductible
 WHERE PD.DeductibleType			IN ('Family','Individual')
   AND PD.Ignore					= 0

-- Add any out-of-network deductibles
INSERT INTO data.BenefitStrategyVariation
      (ConfigurationID
      ,ParentID
      ,StrategyID
      ,StrategyDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,BenefitClassVariation
      ,BenefitRuleID
      ,BenefitRuleDesc
      ,NetworkGroupingID
      ,NetworkGroupingDesc
      ,ClassGroupingID
      ,ClassGroupingDesc
      ,CodeListID
      ,CodeListDesc
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ReportingClassVar
      ,UsedinPlanSummaryBenefitDisplay
      ,PerToothBenefitStrategy
      ,DiagnosisValidationID
      ,DiagnosisDesc
      ,POSListID
      ,POSListDesc
      ,TOBListID
      ,TOBListDesc
      ,AccidentBenefit
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,SingleMemberVariation
      ,Action
      ,Status)
SELECT @configuration_id + GP.plan_state + '-' 
                         + 'BSV-' 
					     + PD.CoreDeductibleType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), PD.GridRow), 5)
							ConfigurationID
      ,GP.plan_name			ParentID
      ,GP.plan_name			StrategyID
      ,GP.plan_desc			StrategyDesc
      ,@effective_date		EffectiveDate
      ,'12/31/9999'			TerminationDate
      ,CASE WHEN GP.plan_state = 'OK' THEN 'O'
	        ELSE '*'
		END					NetworkVariation
      ,'0'					BenefitClassVariation
      ,PD.CoreDeductibleID	BenefitRuleID
      ,''					BenefitRuleDesc
      ,''					NetworkGroupingID
      ,''					NetworkGroupingDesc
      ,''					ClassGroupingID
      ,''					ClassGroupingDesc
      ,''					CodeListID
      ,''					CodeListDesc
      ,''					UptoCoverageUnits
      ,'0'					NumberofCoverageUnits
      ,''					BasisofCoverage
      ,'******'				ReportingClassVar
      ,'Y'					UsedinPlanSummaryBenefitDisplay
      ,'N'					PerToothBenefitStrategy
      ,''					DiagnosisValidationID
      ,''					DiagnosisDesc
      ,''					POSListID
      ,''					POSListDesc
      ,''					TOBListID
      ,''					TOBListDesc
      ,'N'					AccidentBenefit
      ,''					DomainRuleID
      ,''					DomainRuleDesc
      ,'9999'				DomainRulePriority
      ,'N'					SingleMemberVariation
      ,'Add'				Action
      ,'A'					Status
  FROM #GridPlans					GP
  JOIN grid.PlanDeductible			PD
    ON GP.deductible_id				= PD.DeductibleID
   AND GP.copay_after_deductible	= PD.CopayAfterDeductible
 WHERE PD.DeductibleType			IN ('Family OON','Individual OON')
   AND PD.Ignore					= 0

--*************************************************************************************************
-- Add the Benefit Strategy Variations for out-of-pocket for the plans
--*************************************************************************************************
INSERT INTO data.BenefitStrategyVariation
      (ConfigurationID
      ,ParentID
      ,StrategyID
      ,StrategyDesc
      ,EffectiveDate
      ,TerminationDate
      ,NetworkVariation
      ,BenefitClassVariation
      ,BenefitRuleID
      ,BenefitRuleDesc
      ,NetworkGroupingID
      ,NetworkGroupingDesc
      ,ClassGroupingID
      ,ClassGroupingDesc
      ,CodeListID
      ,CodeListDesc
      ,UptoCoverageUnits
      ,NumberofCoverageUnits
      ,BasisofCoverage
      ,ReportingClassVar
      ,UsedinPlanSummaryBenefitDisplay
      ,PerToothBenefitStrategy
      ,DiagnosisValidationID
      ,DiagnosisDesc
      ,POSListID
      ,POSListDesc
      ,TOBListID
      ,TOBListDesc
      ,AccidentBenefit
      ,DomainRuleID
      ,DomainRuleDesc
      ,DomainRulePriority
      ,SingleMemberVariation
      ,Action
      ,Status)
SELECT @configuration_id + GP.plan_state + '-' 
						 + 'BSV-' 
					     + PO.CoreOutOfPocketType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), PO.GridRow), 5)
							ConfigurationID
      ,GP.plan_name			ParentID
      ,GP.plan_name			StrategyID
      ,GP.plan_desc			StrategyDesc
      ,@effective_date		EffectiveDate
      ,'12/31/9999'			TerminationDate
      ,'*'					NetworkVariation
      ,'0'					BenefitClassVariation
      ,PO.CoreOutOfPocketID	BenefitRuleID
      ,''					BenefitRuleDesc
      ,''					NetworkGroupingID
      ,''					NetworkGroupingDesc
      ,''					ClassGroupingID
      ,''					ClassGroupingDesc
      ,''					CodeListID
      ,''					CodeListDesc
      ,''					UptoCoverageUnits
      ,'0'					NumberofCoverageUnits
      ,''					BasisofCoverage
      ,'******'				ReportingClassVar
      ,'Y'					UsedinPlanSummaryBenefitDisplay
      ,'N'					PerToothBenefitStrategy
      ,''					DiagnosisValidationID
      ,''					DiagnosisDesc
      ,''					POSListID
      ,''					POSListDesc
      ,''					TOBListID
      ,''					TOBListDesc
      ,'N'					AccidentBenefit
      ,''					DomainRuleID
      ,''					DomainRuleDesc
      ,'9999'				DomainRulePriority
      ,'N'					SingleMemberVariation
      ,'Add'				Action
      ,'A'					Status
  FROM #GridPlans			GP
  JOIN grid.PlanOutOfPocket	PO
    ON GP.out_of_pocket_id	= PO.OutOfPocketID
 WHERE PO.OutOfPocketType	IN ('Family','Individual')
   AND PO.Ignore			= 0

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
SHELLS_ONLY:

IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END
END 
GO