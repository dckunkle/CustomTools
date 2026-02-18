/**************************************************************************************************
Name:       spConfig_GridImportBenefitRule
Purpose:    Build Benefit Rules and Variations for the Benefit Grid data that has been imported
            into the grid schema tables

Date        User            Change
---------------------------------------------------------------------------------------------
02/24/2023	DK				Original procedure
06/01/2022  DK				Adjust CPAD (copay after deductible) logic for deductible variations that are shared
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportBenefitRule 'Bright-2023U-','ALL'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportBenefitRule
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL'
	 ,@shells_only		BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

DECLARE @configuration_id	VARCHAR(100)
       ,@effective_date		VARCHAR(100)

SELECT @configuration_id = @config_id

IF @shells_only = 1 GOTO SHELLS_ONLY

--*************************************************************************************************
-- Get Parameters
--*************************************************************************************************
SELECT @effective_date = ParameterValue
  FROM grid.GridParameter
 WHERE ParameterName = 'EffectiveDate'

--*************************************************************************************************
-- Reset values to begin fresh
--*************************************************************************************************
DELETE 
  FROM grid.PlanDeductible 
 WHERE GridFileID					= -1 
   AND GridSheetID					= -1

UPDATE grid.PlanDeductible
   SET CoreDeductibleID				= NULL 
      ,CoreDeductibleDescription	= NULL
	  ,CopayAfterDeductible			= 0

UPDATE grid.[Plan]
   SET CopayAfterDeductible			= 0

--*************************************************************************************************
-- Remove any thousands separator before creating IDs and description
--*************************************************************************************************
UPDATE grid.PlanDeductible
   SET DeductibleAmount = REPLACE(DeductibleAmount, ',', '')

UPDATE grid.PlanOutOfPocket
   SET OutOfPocketAmount = REPLACE(OutOfPocketAmount, ',', '')

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
	  ,copay_after_deductible	BIT)


--*************************************************************************************************
-- Build a table of the plans to begin importing
--*************************************************************************************************
INSERT INTO #GridPlans
      (plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id
	  ,copay_after_deductible)
SELECT P.PlanID
      ,P.PlanName
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
	  ,P.CopayAfterDeductible
  FROM grid.[Plan]	P
 WHERE 1 = CASE WHEN @state = 'ALL'	THEN 1
				WHEN P.PlanState = @state THEN 1
				ELSE 0
			END

--*************************************************************************************************
-- Determine which plans need Copay After Deductible set and insert another set of plans
--*************************************************************************************************
UPDATE P 
   SET CopayAfterDeductible = 1
  FROM grid.[Plan]	P
 WHERE P.CopayID IN (SELECT CopayID
					  FROM grid.PlanCoinsuranceCopay
					 WHERE Dollar						= 1
					   AND AfterDeductible				= 1
					   AND CONVERT(MONEY,DollarAmount)	> 0
					   AND Ignore						= 0
					 GROUP BY CopayID)

INSERT INTO #GridPlans
      (plan_name
	  ,plan_desc
	  ,plan_state
	  ,deductible_id
	  ,out_of_pocket_id
	  ,copay_after_deductible)
SELECT P.PlanID
      ,P.PlanName
	  ,P.PlanState
	  ,P.DeductibleID
	  ,P.OutOfPocketID
	  ,P.CopayAfterDeductible
  FROM grid.[Plan]	P
 WHERE 1 = CASE WHEN @state = 'ALL'	THEN 1
				WHEN P.PlanState = @state THEN 1
				ELSE 0
			END
   AND CopayAfterDeductible = 1

--*************************************************************************************************
-- Update the Core IDs and Descriptions for the deductibles
--*************************************************************************************************
INSERT INTO grid.PlanDeductible
      (GridFileID
      ,GridSheetID
      ,GridRow
      ,DeductibleID
      ,DeductibleType
      ,DeductibleAmount
      ,CoreDeductibleID
      ,CoreDeductibleDescription
      ,CoreDeductibleType
      ,CoreRemarkCode
      ,Ignore
      ,CopayAfterDeductible)
SELECT -1
      ,-1
	  ,PD.GridRow
	  ,PD.DeductibleID
	  ,PD.DeductibleType
	  ,REPLACE(PD.DeductibleAmount, ',', '')
	  ,PD.CoreDeductibleID
	  ,PD.CoreDeductibleDescription
	  ,PD.CoreDeductibleType
	  ,PD.CoreRemarkCode
	  ,PD.Ignore
	  ,1
  FROM grid.[Plan]				P
  JOIN grid.PlanDeductible		PD
    ON P.DeductibleID			= PD.DeductibleID
 WHERE P.CopayAfterDeductible	= 1
   AND PD.Ignore				= 0
 GROUP BY  PD.GridFileID
		  ,PD.GridSheetID
		  ,PD.GridRow
		  ,PD.DeductibleID
		  ,PD.DeductibleType
		  ,PD.DeductibleAmount
		  ,PD.CoreDeductibleID
		  ,PD.CoreDeductibleDescription
		  ,PD.CoreDeductibleType
		  ,PD.CoreRemarkCode
		  ,PD.Ignore
  
UPDATE PD
   SET PD.CoreDeductibleID				= 'CAL/DED/' 
										+ CASE WHEN PD.DeductibleType = 'Family'			THEN 'FAM'
                                               WHEN PD.DeductibleType = 'Individual'		THEN 'IND'
											   WHEN PD.DeductibleType = 'Family OON'		THEN 'FAM'
                                               WHEN PD.DeductibleType = 'Individual OON'	THEN 'IND'
											   ELSE 'UNK'
										   END
									    + '/' + REPLACE(REPLACE(PD.DeductibleAmount, '$', ''), ',', '')
										+ CASE WHEN GP.copay_after_deductible = 1 THEN ' CPAD'
										       ELSE ''
										   END

      ,PD.CoreDeductibleDescription		= REPLACE(PD.DeductibleAmount, ',', '') + ' ' 
										+ CASE WHEN PD.DeductibleType = 'Family'			THEN 'FAM'
	                                           WHEN PD.DeductibleType = 'Individual'		THEN 'IND'
											   WHEN PD.DeductibleType = 'Family OON'		THEN 'FAM'
	                                           WHEN PD.DeductibleType = 'Individual OON'	THEN 'IND'
											   ELSE 'UNK'
										   END
										+ ' CAL YR DED'
										+ CASE WHEN GP.copay_after_deductible = 1 THEN ' COPAY AFT DED'
										       ELSE ''
										   END

	  ,PD.CoreDeductibleType			= CASE WHEN PD.DeductibleType = 'Family' THEN 'FD'
											   WHEN PD.DeductibleType = 'Individual' THEN 'ID'
											   WHEN PD.DeductibleType = 'Family OON' THEN 'FD'
											   WHEN PD.DeductibleType = 'Individual OON' THEN 'ID'
										   END
	  ,PD.CoreRemarkCode				= CASE WHEN PD.DeductibleType = 'Family' AND PD.DeductibleAmount <> '0' THEN '6008'
											   WHEN PD.DeductibleType = 'Individual' AND PD.DeductibleAmount <> '0' THEN '6003'
											   WHEN PD.DeductibleType = 'Family OON' AND PD.DeductibleAmount <> '0' THEN '6008'
											   WHEN PD.DeductibleType = 'Individual OON' AND PD.DeductibleAmount <> '0' THEN '6003'
											   ELSE ''
										   END
	  --,PD.CopayAfterDeductible			= GP.copay_after_deductible
  FROM #GridPlans						GP
  JOIN grid.PlanDeductible				PD
    ON GP.deductible_id					= PD.DeductibleID
   AND GP.copay_after_deductible		= PD.CopayAfterDeductible
 WHERE Ignore							= 0

 UPDATE PD
   SET PD.CoreDeductibleID				= CASE WHEN PD.DeductibleType = 'Family'			THEN 'NO FAM DED'
                                               WHEN PD.DeductibleType = 'Individual'		THEN 'NO IND DED'
											   WHEN PD.DeductibleType = 'Family OON'		THEN 'NO FAM DED'
                                               WHEN PD.DeductibleType = 'Individual OON'	THEN 'NO IND DED'
										   END
      ,PD.CoreDeductibleDescription		= CASE WHEN PD.DeductibleType = 'Family'			THEN 'NO FAM DED'
	                                           WHEN PD.DeductibleType = 'Individual'		THEN 'NO IND DED'
											   WHEN PD.DeductibleType = 'Family OON'		THEN 'NO FAM DED'
                                               WHEN PD.DeductibleType = 'Individual OON'	THEN 'NO IND DED'
										   END
	  ,PD.CoreRemarkCode				= ''
	  --,PD.CopayAfterDeductible			= GP.copay_after_deductible
  FROM #GridPlans						GP
  JOIN grid.PlanDeductible				PD
    ON GP.deductible_id					= PD.DeductibleID
 WHERE PD.DeductibleAmount				IN ('$0', 'N/A')
   AND Ignore							= 0

--*************************************************************************************************
-- Update the Core IDs and Descriptions for the out-of-pocket
--*************************************************************************************************
UPDATE PO
   SET PO.CoreOutOfPocketID				= 'CAL/OOP/' 
										+ CASE WHEN PO.OutOfPocketType = 'Family'			THEN 'FAM'
                                               WHEN PO.OutOfPocketType = 'Individual'		THEN 'IND'
											   WHEN PO.OutOfPocketType = 'Family OON'		THEN 'FAM'
                                               WHEN PO.OutOfPocketType = 'Individual OON'	THEN 'IND'
											   ELSE 'UNK'
										  END
									    + '/' + REPLACE(REPLACE(PO.OutOfPocketAmount, '$', ''), ',', '')
										
      ,PO.CoreOutOfPocketDescription	= REPLACE(PO.OutOfPocketAmount, ',', '') + ' ' 
										+ CASE WHEN PO.OutOfPocketType = 'Family'			THEN 'FAM'
	                                           WHEN PO.OutOfPocketType = 'Individual'		THEN 'IND'
											   WHEN PO.OutOfPocketType = 'Family OON'		THEN 'FAM'
                                               WHEN PO.OutOfPocketType = 'Individual OON'	THEN 'IND'
											   ELSE 'UNK'
										   END
										 + ' CAL YR OOP'
	  ,PO.CoreOutOfPocketType			= CASE WHEN PO.OutOfPocketType = 'Family' THEN 'FO'
											   WHEN PO.OutOfPocketType = 'Individual' THEN 'IO'
											   WHEN PO.OutOfPocketType = 'Family OON' THEN 'FO'
											   WHEN PO.OutOfPocketType = 'Individual OON' THEN 'IO'
										   END
	  ,PO.CoreRemarkCode				= CASE WHEN PO.OutOfPocketType = 'Family' AND PO.OutOfPocketAmount <> '0' THEN '6012'
											   WHEN PO.OutOfPocketType = 'Individual' AND PO.OutOfPocketAmount <> '0' THEN '6011'
											   WHEN PO.OutOfPocketType = 'Family OON' AND PO.OutOfPocketAmount <> '0' THEN '6012'
											   WHEN PO.OutOfPocketType = 'Individual OON' AND PO.OutOfPocketAmount <> '0' THEN '6011'
											   ELSE ''
										   END
  FROM #GridPlans						GP
  JOIN grid.PlanOutOfPocket				PO
    ON GP.out_of_pocket_id				= PO.OutOfPocketID
 WHERE Ignore							= 0

-- Update special scenarios
UPDATE PO
   SET PO.CoreOutOfPocketID				= CASE WHEN PO.OutOfPocketType = 'Family'			THEN 'NO FAM OOP'
                                               WHEN PO.OutOfPocketType = 'Individual'		THEN 'NO IND OOP'
											   WHEN PO.OutOfPocketType = 'Family OON'		THEN 'NO FAM OOP'
                                               WHEN PO.OutOfPocketType = 'Individual OON'	THEN 'NO IND OOP'
										  END
      ,PO.CoreOutOfPocketDescription	= CASE WHEN PO.OutOfPocketType = 'Family'			THEN 'NO FAM OOP'
	                                           WHEN PO.OutOfPocketType = 'Individual'		THEN 'NO IND OOP'
											   WHEN PO.OutOfPocketType = 'Family OON'		THEN 'NO FAM OOP'
                                               WHEN PO.OutOfPocketType = 'Individual OON'	THEN 'NO IND OOP'
										   END
	  ,PO.CoreRemarkCode				= ''
  FROM #GridPlans						GP
  JOIN grid.PlanOutOfPocket				PO
    ON GP.out_of_pocket_id				= PO.OutOfPocketID
 WHERE PO.OutOfPocketAmount				IN ('$0', 'N/A')
   AND Ignore							= 0

--*************************************************************************************************
-- Clear any prevously created records from the destination tables
--*************************************************************************************************
IF @state <> 'ALL'
	BEGIN
		SELECT @configuration_id = @configuration_id + '-' + @state
	END

DELETE 
  FROM data.BenefitRule
 WHERE ConfigurationID LIKE @configuration_id + '%'

DELETE 
  FROM data.BenefitRuleVariation
 WHERE ConfigurationID LIKE @configuration_id + '%'

--*************************************************************************************************
-- Add the Benefit Rule data for deductibles
--*************************************************************************************************
INSERT INTO [data].[BenefitRule]
      (ConfigurationID
	  ,ParentID
	  ,ID
	  ,[Description]
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + 'BR-' 
					     + PD.CoreDeductibleType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), MIN(PD.GridRow)), 5)
      ,''
	  ,PD.CoreDeductibleID
	  ,PD.CoreDeductibleDescription
	  ,'Add'
	  ,'A'
  FROM grid.PlanDeductible	PD
 WHERE PD.DeductibleID		IN (SELECT GP.deductible_id
                                  FROM #GridPlans GP
								 GROUP BY GP.deductible_id)
   AND Ignore				= 0
 GROUP BY PD.CoreDeductibleID
         ,PD.CoreDeductibleDescription
		 ,PD.CoreDeductibleType
		 ,PD.CoreRemarkCode
		 ,PD.DeductibleAmount

--*************************************************************************************************
-- Add the Benefit Rule data for out of pocket
--*************************************************************************************************
INSERT INTO [data].[BenefitRule]
      (ConfigurationID
	  ,ParentID
	  ,ID
	  ,[Description]
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + 'BR-' 
					     + PO.CoreOutOfPocketType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), MIN(PO.GridRow)), 5)
      ,''
	  ,PO.CoreOutOfPocketID
	  ,PO.CoreOutOfPocketDescription
	  ,'Add'
	  ,'A'
  FROM grid.PlanOutOfPocket	PO
 WHERE PO.OutOfPocketID		IN (SELECT GP.out_of_pocket_id
                                  FROM #GridPlans GP
								 GROUP BY GP.out_of_pocket_id)
   AND Ignore				= 0
 GROUP BY PO.CoreOutOfPocketID
         ,PO.CoreOutOfPocketDescription
		 ,PO.CoreOutOfPocketType
		 ,PO.CoreRemarkCode
		 ,OutOfPocketAmount

--*************************************************************************************************
-- Add the Benefit Rule Variations data for deductibles
--*************************************************************************************************
INSERT INTO [data].[BenefitRuleVariation]
      (ConfigurationID
	  ,ParentID
	  ,BenefitRuleID
	  ,BenefitRuleDesc
	  ,EffectiveDate
      ,TerminationDate
      ,AccBenePeriod
      ,AccNumPeriods
      ,AccBeneStartMonth
      ,AccBeneStartDay
      ,StartDateOption
      ,BenefitType
      ,DollarAmount
      ,LimitAmount
      ,AdditionalMaxAmount
      ,LimittoOneTime
      ,FamilyMetRule
      ,MetCount
      ,WaitPeriod
      ,WaitNumPeriods
      ,RuleAction
      ,RulePriority
      ,MonetaryInclusions
      ,CarryForwardMonths
      ,CarryForwardLimitBasis
      ,CarryForwardLimitUnits
      ,ReimburseRemainingMaxtoPatient
      ,ApplytoIncidents
      ,AccidentLimitAmount
      ,SameProvider
      ,RemarkCode1
      ,RemarkCodeDesc1
      ,RemarkCode2
      ,RemarkCodeDesc2
      ,HPDeductible
      ,HPPercentage
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + 'BRV-' 
					     + PD.CoreDeductibleType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), MIN(PD.GridRow)), 5)
	  ,PD.CoreDeductibleID
	  ,PD.CoreDeductibleID			BenefitRuleID
	  ,PD.CoreDeductibleDescription	BenefitRuleDesc
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'Y'							AccBenePeriod
	  ,'1'							AccNumPeriods
	  ,'0'							AccBeneStartMonth
	  ,'0'							AccBeneStartDay
	  ,'C'							StartDateOption
	  ,PD.CoreDeductibleType		BenefitType
	  ,REPLACE(PD.DeductibleAmount, '$', '') + '.00'	
	                                DollarAmount
	  ,'0'							LimitAmount
	  ,'0.00'						AdditionalMaxAmount
	  ,'N'							LimittoOneTime
	  ,''							FamilyMetRule
	  ,'0'							MetCount
	  ,'N'							WaitPeriod
	  ,'0'							WaitNumPeriods
	  ,'N'							RuleAction
	  ,'0'							RulePriority
	  ,CASE WHEN PD.CopayAfterDeductible = 1 THEN 'Z'
	        ELSE 'N'
		END							MonetaryInclusions
	  ,'0'							CarryForwardMonths
	  ,'N'							CarryForwardLimitBasis
	  ,'0.00'						CarryForwardLimitUnits
	  ,'N'							ReimburseRemainingMaxtoPatient
	  ,'N'							ApplytoIncidents
	  ,'0'							AccidentLimitAmount
	  ,'N'							SameProvider
	  ,PD.CoreRemarkCode			RemarkCode1
	  ,''							RemarkCodeDesc1
	  ,''							RemarkCode2
	  ,''							RemarkCodeDesc2
	  ,'0.00'						HPDeductible
	  ,'0'							HPPercentage
	  ,'Add'
	  ,'A'
  FROM grid.PlanDeductible	PD
 WHERE PD.DeductibleID		IN (SELECT GP.deductible_id
                                  FROM #GridPlans GP
								 GROUP BY GP.deductible_id)
   AND PD.DeductibleAmount	NOT IN ('N/A')
   AND PD.Ignore			= 0
 GROUP BY PD.CoreDeductibleID
         ,PD.CoreDeductibleDescription
		 ,PD.CoreDeductibleType
		 ,PD.CoreRemarkCode
		 ,PD.DeductibleAmount
		 ,PD.CopayAfterDeductible

--*************************************************************************************************
-- Add the Benefit Rule Variations data for out of pocket
--*************************************************************************************************
INSERT INTO [data].[BenefitRuleVariation]
      (ConfigurationID
	  ,ParentID
	  ,BenefitRuleID
	  ,BenefitRuleDesc
	  ,EffectiveDate
      ,TerminationDate
      ,AccBenePeriod
      ,AccNumPeriods
      ,AccBeneStartMonth
      ,AccBeneStartDay
      ,StartDateOption
      ,BenefitType
      ,DollarAmount
      ,LimitAmount
      ,AdditionalMaxAmount
      ,LimittoOneTime
      ,FamilyMetRule
      ,MetCount
      ,WaitPeriod
      ,WaitNumPeriods
      ,RuleAction
      ,RulePriority
      ,MonetaryInclusions
      ,CarryForwardMonths
      ,CarryForwardLimitBasis
      ,CarryForwardLimitUnits
      ,ReimburseRemainingMaxtoPatient
      ,ApplytoIncidents
      ,AccidentLimitAmount
      ,SameProvider
      ,RemarkCode1
      ,RemarkCodeDesc1
      ,RemarkCode2
      ,RemarkCodeDesc2
      ,HPDeductible
      ,HPPercentage
	  ,[Action]
	  ,[Status])
SELECT @configuration_id + 'BRV-' 
					     + PO.CoreOutOfPocketType + '-'
					     + RIGHT('00000' + CONVERT(VARCHAR(10), MIN(PO.GridRow)), 5)
	  ,PO.CoreOutOfPocketID
	  ,PO.CoreOutOfPocketID
	  ,PO.CoreOutOfPocketDescription
	  ,@effective_date				EffectiveDate
	  ,'12/31/9999'					TerminationDate
	  ,'Y'							AccBenePeriod
	  ,'1'							AccNumPeriods
	  ,'0'							AccBeneStartMonth
	  ,'0'							AccBeneStartDay
	  ,'C'							StartDateOption
	  ,PO.CoreOutOfPocketType		BenefitType
	  ,REPLACE(PO.OutOfPocketAmount, '$', '') + '.00'	
									DollarAmount
	  ,'0'							LimitAmount
	  ,'0.00'						AdditionalMaxAmount
	  ,'N'							LimittoOneTime
	  ,''							FamilyMetRule
	  ,'0'							MetCount
	  ,'N'							WaitPeriod
	  ,'0'							WaitNumPeriods
	  ,'1'							RuleAction
	  ,'0'							RulePriority
	  ,'N'							MonetaryInclusions
	  ,'0'							CarryForwardMonths
	  ,'N'							CarryForwardLimitBasis
	  ,'0.00'						CarryForwardLimitUnits
	  ,'N'							ReimburseRemainingMaxtoPatient
	  ,'N'							ApplytoIncidents
	  ,'0'							AccidentLimitAmount
	  ,'N'							SameProvider
	  ,PO.CoreRemarkCode			RemarkCode1
	  ,''							RemarkCodeDesc1
	  ,''							RemarkCode2
	  ,''							RemarkCodeDesc2
	  ,'0.00'						HPDeductible
	  ,'0'							HPPercentage
	  ,'Add'
	  ,'A'
  FROM grid.PlanOutOfPocket	PO
 WHERE PO.OutOfPocketID		IN (SELECT GP.out_of_pocket_id
                                  FROM #GridPlans GP
								 GROUP BY GP.out_of_pocket_id)
   AND Ignore				= 0
 GROUP BY PO.CoreOutOfPocketID
         ,PO.CoreOutOfPocketDescription
		 ,PO.CoreOutOfPocketType
		 ,PO.CoreRemarkCode
		 ,PO.OutOfPocketAmount

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
SHELLS_ONLY:

IF OBJECT_ID('tempdb.dbo.#GridPlans') IS NOT NULL
	BEGIN DROP TABLE #GridPlans END

END 
GO