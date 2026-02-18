/**************************************************************************************************
Name:       spConfig_GridImportPlanStrategy
Purpose:    Import Benefit Strategy and Benefit Strategy Variations data from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
03/23/2022	DK				Original procedure
05/23/2022	DK				Lookup specific Code Limitations for certain plans
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportPlanStrategy 'Bright-0408-'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportPlanStrategy
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL')
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
      (grid_row				INT
	  ,hios_id				VARCHAR(50)
	  ,plan_name			VARCHAR(50)
	  ,plan_desc			VARCHAR(150)
	  ,plan_state			VARCHAR(10)
	  ,metal_level			VARCHAR(20)
	  ,exchange				VARCHAR(10)
	  ,super_network		VARCHAR(100)
	  ,code_limitation		VARCHAR(100)
	  ,oon_provider_network	VARCHAR(100)
	  ,deductible_id		INT
	  ,out_of_pocket_id		INT)

--*************************************************************************************************
-- Build a table of the plans to begin importing
--*************************************************************************************************
INSERT INTO #GridPlans
      (grid_row
	  ,hios_id
	  ,plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id)
SELECT P.GridRow
      ,P.HIOSID
      ,P.PlanID
      ,CASE WHEN P.PlanName LIKE '%[?]%' THEN REPLACE(P.PlanName,'?','')
			ELSE RTRIM(LEFT(P.PlanName, 150))
		END
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
  FROM grid.[Plan]	P
 WHERE 1 = CASE WHEN @state = 'ALL'	THEN 1
				WHEN P.PlanState = @state THEN 1
				ELSE 0
			END

--*************************************************************************************************
-- Determine metal type and on or off exchange
--*************************************************************************************************
UPDATE #GridPlans
   SET exchange = CASE WHEN RIGHT(hios_id, 2) = '00' THEN 'N'
                       ELSE 'Y'
				   END

UPDATE #GridPlans
   SET metal_level = CASE WHEN plan_desc LIKE '%Gold %'			THEN 'GOLD'
                          WHEN plan_desc LIKE '%Silver %'		THEN 'SILVER'
						  WHEN plan_desc LIKE '%Bronze %'		THEN 'BRONZE'
						  WHEN plan_desc LIKE '%Catastrophic %'	THEN 'CAT'
						  WHEN plan_desc LIKE '%Platinum %'		THEN 'PLAT'
						  ELSE ''
					  END

-- Update specific super network values
UPDATE GP
   SET GP.super_network				= SN.SuperNetworkID
   FROM #GridPlans					GP
  JOIN grid.PlanSuperNetworkLookup	SN
    ON GP.plan_name					= SN.PlanID

UPDATE #GridPlans
   SET super_network				= plan_state + 'BRDIRECT'
 WHERE super_network				IS NULL

UPDATE #GridPlans
   SET oon_provider_network			= 'EVH_BRIF_' + plan_state + '_OON'

-- Update specific code limitation values
UPDATE GP
   SET GP.code_limitation			= CL.CodeLimitationID
  FROM #GridPlans					GP
  JOIN grid.PlanCodeLimitation		CL
    ON GP.plan_name					= CL.PlanID

-- If no specific code limitation, then assign a generic one
UPDATE #GridPlans
   SET code_limitation				= 'BASE ' + plan_state + ' IFP'
 WHERE code_limitation				IS NULL

--*************************************************************************************************
-- Clear any prevously created records from the destination tables
--*************************************************************************************************
DELETE 
  FROM data.PlanStrategy
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Add the Benefit Strategy Variations for deductibles for the plans
--*************************************************************************************************
INSERT INTO data.PlanStrategy
      (ConfigurationID
      ,ParentID
      ,PlanStrategyID
      ,PlanStrategyDesc
      ,ModelPlanStrategyID
      ,ModelPlanStrategyDesc
      ,PlanType
      ,EffectiveDate
      ,TerminationDate
      ,BaseRules
      ,DefaultStatus
      ,EOB
      ,UseAliasCodes
      ,SuperNetworkID
      ,SuperNetworkDescription
      ,PharmacyNetworkStrategyID
      ,PharmacyNetworkStrategyDescription
      ,CopayLevelsID
      ,CopayLevelsDescription
      ,PriceStrategyID
      ,PriceStrategyDesc
      ,PriceStrategyIDPlan
      ,PriceStrategyDescPlan
      ,PriceStrategyIDClient
      ,PriceStrategyDescClient
      ,BenefitStrategyID
      ,BenefitStrategyDesc
      ,DUEStrategyID
      ,DUEStrategyDesc
      ,CodeLimitationsID
      ,CodeLimitationsDescription
      ,AuthMatchID
      ,AuthMatchDescription
      ,RemarkCodeRelationsID
      ,RemarkCodeRelationsDesc
      ,RebateStrategyID
      ,RebateStrategyDesc
      ,ComparisonScheduleID
      ,ComparisonScheduleDesc
      ,CodePairingID
      ,CodePairingDesc
      ,PCPRequiredforEligibility
      ,CAPAffiliationID
      ,PCPRequiredforAdjudication
      ,SubmittedCostRequired
      ,UCRRequired
      ,ClinicalEngineID
      ,ClinicalEngineDesc
      ,AutoAdjudicateAccident
      ,PTEPREDEnforceCOBEdits
      ,PTEPREDCarryFwdOffsets
      ,PlanVariationLookup
      ,GenerateOfficeVisit
      ,PaymentIntegrityRemarkCodeID
      ,PaymentIntegrityRemarkCodeDesc
      ,NursingFacilityPatientRespRulesetID
      ,NursingFacilityPatientRespRulesetDesc
      ,MedicareAdvantagePlan
      ,BCContractNumber
      ,BSContractNumber
      ,DMDSGroupNumber
      ,Section
      ,AlphaPrefix
      ,Variation
      ,Deductible
      ,OutofPocket
      ,Maternity
      ,OBWaitingPeriod
      ,BCBSPreExWaitingPeriod
      ,SummaryURL
      ,PlanContactEMail
      ,AgeBump
      ,OKDurationalDiscount
      ,StateFileDate
      ,StateFileSpecificDate
      ,StateFileNotificationDaysPrior
      ,GenerateStateFileCorrespondence
      ,RateGuaranteePeriod
      ,RateGuaranteePeriodUnits
      ,OnExchange
      ,SecurityDeposit
      ,CarrierID
      ,CarrierName
      ,GenericPlanID
      ,OtherPlanID
      ,APTCAllowed
      ,CSRAllowed
      ,MetallicLevel
      ,ActuarialValue
      ,HIOSPlanID
      ,TenantID
      ,OONProviderContractID
      ,ClinicalEditsOnlyContractID
      ,DefaultServiceAreaContractID
      ,EditCodeRelationsID
      ,EditCodeRelationsDesc
      ,Method
      ,[837ClaimCOBIndicated]
      ,PayuptoMedicareABDedCoins
      ,PayMedicareBDedCoins
      ,CodeListID
      ,CodeListDesc
      ,ReviewRemarkCodeID
      ,ReviewRemarkCodeDesc
      ,MedSuppCOBREIMB
      ,MedSuppDeductibleREIMB
      ,GrouperPricerEnabled
      ,EAPGEditCodeRelationsID
      ,EAPGEditCodeRelationsDesc
      ,Action
      ,Status)
SELECT @configuration_id + plan_state + '-'
                         + 'PS-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), GP.grid_row), 5)
										ConfigurationID
      ,''								ParentID
      ,plan_name                        PlanStrategyID
      ,plan_desc						PlanStrategyDesc
      ,''								ModelPlanStrategyID
      ,''								ModelPlanStrategyDesc
      ,'MED'							PlanType
      ,@effective_date					EffectiveDate
      ,'12/31/9999'						TerminationDate
      ,'SYSTEM'							BaseRules
      ,'P'                              DefaultStatus
      ,'N'                              EOB
      ,'N'                              UseAliasCodes
      ,super_network                    SuperNetworkID
      ,''                               SuperNetworkDescription
      ,''                               PharmacyNetworkStrategyID
      ,''                               PharmacyNetworkStrategyDescription
      ,plan_name                        CopayLevelsID
      ,''                               CopayLevelsDescription
      ,'OON_CHC'                        PriceStrategyID
      ,''							    PriceStrategyDesc
      ,''                               PriceStrategyIDPlan
      ,''                               PriceStrategyDescPlan
      ,''                               PriceStrategyIDClient
      ,''                               PriceStrategyDescClient
      ,plan_name                        BenefitStrategyID
      ,''                               BenefitStrategyDesc
      ,''                               DUEStrategyID
      ,''                               DUEStrategyDesc
      ,code_limitation                  CodeLimitationsID
      ,''                               CodeLimitationsDescription
      ,''                               AuthMatchID
      ,''                               AuthMatchDescription
      ,'System'                         RemarkCodeRelationsID
      ,''                               RemarkCodeRelationsDesc
      ,''                               RebateStrategyID
      ,''                               RebateStrategyDesc
      ,''                               ComparisonScheduleID
      ,''                               ComparisonScheduleDesc
      ,''                               CodePairingID
      ,''                               CodePairingDesc
      ,'N'                              PCPRequiredforEligibility
      ,'******'                         CAPAffiliationID
      ,'N'                              PCPRequiredforAdjudication
      ,'Y'                              SubmittedCostRequired
      ,'N'                              UCRRequired
      ,''                               ClinicalEngineID
      ,''                               ClinicalEngineDesc
      ,'N'                              AutoAdjudicateAccident
      ,'Y'                              PTEPREDEnforceCOBEdits
      ,'N'                              PTEPREDCarryFwdOffsets
      ,'C'                              PlanVariationLookup
      ,'N'                              GenerateOfficeVisit
      ,''                               PaymentIntegrityRemarkCodeID
      ,''                               PaymentIntegrityRemarkCodeDesc
      ,''                               NursingFacilityPatientRespRulesetID
      ,''                               NursingFacilityPatientRespRulesetDesc
      ,'N'                              MedicareAdvantagePlan
      ,''                               BCContractNumber
      ,''                               BSContractNumber
      ,''                               DMDSGroupNumber
      ,''                               Section
      ,''                               AlphaPrefix
      ,'0'                              Variation
      ,''                               Deductible
      ,''                               OutofPocket
      ,''                               Maternity
      ,'0'                              OBWaitingPeriod
      ,'0'                              BCBSPreExWaitingPeriod
      ,''                               SummaryURL
      ,''                               PlanContactEMail
      ,'D'                              AgeBump
      ,'D'                              OKDurationalDiscount
      ,'D'                              StateFileDate
      ,'01/01/1900'                     StateFileSpecificDate
      ,'0'                              StateFileNotificationDaysPrior
      ,'D'                              GenerateStateFileCorrespondence
      ,'M'                              RateGuaranteePeriod
      ,'12'                             RateGuaranteePeriodUnits
      ,exchange                         OnExchange
      ,'0'                              SecurityDeposit
      ,''                               CarrierID
      ,''                               CarrierName
      ,''                               GenericPlanID
      ,''                               OtherPlanID
      ,exchange                         APTCAllowed
      ,'N'                              CSRAllowed
      ,metal_level                      MetallicLevel
      ,'0.00'                           ActuarialValue
      ,LEFT(hios_id,14)                 HIOSPlanID
      ,plan_state + '0'                 TenantID
      ,oon_provider_network             OONProviderContractID
      ,''                               ClinicalEditsOnlyContractID
      ,''                               DefaultServiceAreaContractID
      ,'BRIF_PCI_EDIT'                  EditCodeRelationsID
      ,''                               EditCodeRelationsDesc
      ,'TRAD'                           Method
      ,'Y'                              [837ClaimCOBIndicated]
      ,'N'                              PayuptoMedicareABDedCoins
      ,'N'                              PayMedicareBDedCoins
      ,''                               CodeListID
      ,''                               CodeListDesc
      ,''                               ReviewRemarkCodeID
      ,''                               ReviewRemarkCodeDesc
      ,'N'                              MedSuppCOBREIMB
      ,'N'                              MedSuppDeductibleREIMB
      ,'N'                              GrouperPricerEnabled
      ,''                               EAPGEditCodeRelationsID
      ,''                               EAPGEditCodeRelationsDesc
	  ,'Add'
	  ,'A'
  FROM #GridPlans			GP

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END
END 
GO