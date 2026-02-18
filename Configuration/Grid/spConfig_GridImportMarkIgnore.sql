/**************************************************************************************************
Name:       spConfig_GridImportMarkIgnore
Purpose:    Mark data to ignore to prevent downstream processing

Date        User            Change
---------------------------------------------------------------------------------------------
03/23/2022	DK				Original procedure
10/06/2022  DK				Repurpose procedure to mark all Ignore flags except very specific scenarios
12/09/2022  DK				Comment out ignoring dental and eyeglasses
12/22/2022  DK				TEMP: Force 50 to 365 BC, ignore 241
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportMarkIgnore
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportMarkIgnore
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Reset initial condition
--*************************************************************************************************
UPDATE grid.PlanBenefit
   SET Ignore = 0

UPDATE grid.PlanBenefitCrosswalk
   SET Ignore = 0

UPDATE grid.PlanCoinsuranceCopay
   SET Ignore = 0

UPDATE grid.PlanDeductible
   SET Ignore = 0

UPDATE grid.PlanOutOfPocket
   SET Ignore = 0

--*************************************************************************************************
-- Mark any Plan Benefits as ignore if they should be ignored, ignore OON and Tier 2
--*************************************************************************************************
UPDATE grid.PlanBenefit
   SET Ignore			= 1
 WHERE BenefitName		LIKE '%- OON'
    OR BenefitName		LIKE '%- INN T2'

-- Ignore Drugs
UPDATE grid.PlanBenefit
   SET Ignore			= 1
 WHERE BenefitName LIKE '%Drugs - INN'
    OR BenefitName LIKE '%Drugs - OON'

-- Ignore Dental
	--UPDATE grid.PlanBenefit
	--   SET Ignore			= 1
	-- WHERE BenefitName LIKE '%Dental%'
	--    OR BenefitName LIKE '%Orthodontia%'
	--	OR BenefitName LIKE '%Mandibular%'

-- Ignore Vision
UPDATE grid.PlanBenefit
   SET Ignore			= 1
 WHERE BenefitName LIKE '%Vision%'
	--OR BenefitName LIKE '%Eyeglasses%'
	--OR BenefitName LIKE '%Eye Exam%'

-- Ignore so that 365 benefits are selected properly
UPDATE grid.PlanBenefit
   SET Ignore			= 1
 WHERE BenefitName		= 'Substance Use Disorder Inpatient Professional Fee - INN'

UPDATE grid.PlanBenefit
   SET Ignore			= 1
 WHERE BenefitStatus	<> 'Active'

--*************************************************************************************************
-- Update Ignore for any Crosswalk benefits that should be ignored
--*************************************************************************************************
UPDATE CW
   SET Ignore = 1
  FROM grid.PlanBenefitCrosswalk	CW
  JOIN grid.PlanBenefit				PB
    ON CW.BenefitID					= PB.BenefitID
 WHERE PB.Ignore					= 1

--*************************************************************************************************
-- Update Ignore in PlanBenefitCrosswalk
--*************************************************************************************************
UPDATE grid.PlanBenefitCrosswalk
   SET Ignore = 1
 WHERE CoreBenefitID IN ('-1'		-- Ignore any benefits that were not mapped (0)
						,'196'		-- Will be handled specifically
						,'1196'		-- Free visit scenarios will be specifically handled
						,'1296'		-- Free visit scenarios will be specifically handled
						,'1396'		-- Free visit scenarios will be specifically handled
						,'196/191') -- Free visit scenarios will be specifically handled

--*************************************************************************************************
-- Update Ignore fore any Copay benefits that should be ignored
--*************************************************************************************************
UPDATE CI
   SET Ignore = 1
  FROM grid.PlanCoinsuranceCopay	CI
  JOIN grid.PlanBenefit				PB
    ON CI.BenefitID					= PB.BenefitID
 WHERE PB.Ignore					= 1

--*************************************************************************************************
-- Mark any coinsurance to ignore if it is not referenced by the plan
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET Ignore				= 1
 WHERE CopayID IN (SELECT PC.CopayID
                     FROM grid.PlanCoinsuranceCopay		PC
					 LEFT JOIN grid.[Plan]				P
					   ON PC.CopayID					= P.CopayID
				    WHERE P.DeductibleID				IS NULL
					GROUP BY PC.CopayID)

--*************************************************************************************************
-- Update Ignore for any Plans that are missing
--*************************************************************************************************
UPDATE grid.PlanDeductible
   SET Ignore				= 1
 WHERE DeductibleID IN (SELECT PD.DeductibleID
                          FROM grid.PlanDeductible		PD
						  LEFT JOIN grid.[Plan]			P
						    ON PD.DeductibleID			= P.DeductibleID
						 WHERE P.DeductibleID			IS NULL
						 GROUP BY PD.DeductibleID)

--*************************************************************************************************
-- Update Ignore deductibles that are OON 
--*************************************************************************************************
-- OK out-of-network
UPDATE grid.PlanDeductible
   SET Ignore				= 1
 WHERE DeductibleType		LIKE '% OON'

UPDATE grid.PlanDeductible
   SET Ignore				= 1
 WHERE DeductibleAmount		= 'N/A'

END
GO