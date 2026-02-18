/**************************************************************************************************
Name:       spConfig_GridBenefitCroswalkValidate
Purpose:    Used to validate scenarios where multiple client benefits map to a single Core 
            benefit. In this case need to make sure all of the benefits are the same

Date        User            Change
---------------------------------------------------------------------------------------------
04/19/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridBenefitCroswalkValidate '1193'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridBenefitCroswalkValidate
     (@core_benefit_id		VARCHAR(100))
AS
BEGIN

DECLARE @benefit_id VARCHAR(100)

--*************************************************************************************************
-- Build a table to store the mappings
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Benefit_Mapping') IS NOT NULL
	BEGIN DROP TABLE #Benefit_Mapping END

CREATE TABLE #Benefit_Mapping
      (client_benefit_id	VARCHAR(100)
	  ,client_benefit_name	VARCHAR(100)
	  ,core_benefit_id		VARCHAR(100)
	  ,control_id			BIT
	  ,compared				BIT
	  ,values_match			BIT)

INSERT INTO #Benefit_Mapping
      (client_benefit_id
	  ,client_benefit_name
	  ,core_benefit_id)
SELECT CW.BenefitID
      ,CW.BenefitName
      ,CW.CoreBenefitID
  FROM grid.PlanBenefitCrosswalk	CW
 WHERE CW.CoreBenefitID				= @core_benefit_id
   AND CW.BenefitName				NOT LIKE '%- OON'
   
UPDATE #Benefit_Mapping
   SET compared			= 0
      ,control_id		= 0
	  ,values_match		= 0

UPDATE #Benefit_Mapping
   SET control_id		= 1
      ,values_match		= 1
	  ,compared			= 1
 WHERE client_benefit_id IN (SELECT MIN(client_benefit_id) FROM #Benefit_Mapping)

--*************************************************************************************************
-- Build a table to store unused coinsurance IDs (OK, IL, SC)
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CoinsuranceID') IS NOT NULL
	BEGIN DROP TABLE #CoinsuranceID END

CREATE TABLE #CoinsuranceID
      (coinsurance_id		INT
	  ,used					BIT		DEFAULT(0))

INSERT INTO #CoinsuranceID
      (coinsurance_id)
SELECT PCC.CopayID
  FROM grid.PlanCoinsuranceCopay	PCC
 WHERE Ignore = 0
 GROUP BY PCC.CopayID

;WITH CTE_PlanCopay
   AS (SELECT P.CopayID
         FROM grid.[Plan]	P
		GROUP BY P.CopayID)
UPDATE #CoinsuranceID
   SET used					= 1
  FROM #CoinsuranceID		C
  JOIN CTE_PlanCopay		PC
    ON C.coinsurance_id		= PC.CopayID

--*************************************************************************************************
-- Build a table to compare the benefits
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Benefit_Comparison') IS NOT NULL
	BEGIN DROP TABLE #Benefit_Comparison END

CREATE TABLE #Benefit_Comparison
      (coinsurance_variation_id		INT
	  ,benefit_id_1					VARCHAR(100)
	  ,coinsurance_value_1			VARCHAR(100)
	  ,benefit_id_2					VARCHAR(100)
	  ,coinsurance_value_2			VARCHAR(100)
	  ,comparison					VARCHAR(100))

INSERT INTO #Benefit_Comparison
      (coinsurance_variation_id
	  ,benefit_id_1
	  ,coinsurance_value_1)
SELECT PC.CopayID
      ,PC.BenefitID
	  ,PC.CopayCoinsValue
  FROM grid.PlanCoinsuranceCopay	PC
  JOIN #Benefit_Mapping				BM
    ON PC.BenefitID					= BM.client_benefit_id
 WHERE BM.control_id				= 1
   AND PC.Ignore					= 0

--*************************************************************************************************
-- Loop through the other benefits and make sure they all match the control benefit id
--*************************************************************************************************
SELECT * FROM #Benefit_Mapping 

DECLARE Comparison_Cursor CURSOR FOR
 SELECT client_benefit_id
   FROM #Benefit_mapping
  WHERE control_id = 0
  ORDER BY client_benefit_id

   OPEN Comparison_Cursor
  FETCH NEXT FROM Comparison_Cursor
   INTO @benefit_id

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		UPDATE BC
		   SET BC.benefit_id_2				= PC.BenefitID
		      ,BC.coinsurance_value_2		= PC.CopayCoinsValue
		  FROM #Benefit_Comparison			BC
		  JOIN grid.PlanCoinsuranceCopay	PC
		    ON BC.coinsurance_variation_id	= PC.CopayID
		 WHERE PC.BenefitId					= @benefit_id
		   AND PC.Ignore					= 0

		UPDATE #Benefit_Comparison
		   SET comparison			= 'Match'
		 WHERE coinsurance_value_1	= coinsurance_value_2

		UPDATE #Benefit_Comparison
		   SET comparison			= 'No Match'
		 WHERE coinsurance_value_1	<> coinsurance_value_2

		IF EXISTS(SELECT TOP 1 * FROM #Benefit_Comparison WHERE comparison = 'No Match')
			BEGIN
				UPDATE #Benefit_Mapping
				   SET compared				= 1
				      ,values_match			= 0
				 WHERE client_benefit_id	= @benefit_id
			END
		ELSE
			BEGIN
				UPDATE #Benefit_Mapping
				   SET compared				= 1
				      ,values_match			= 1
				 WHERE client_benefit_id	= @benefit_id
			END

		SELECT BC.*
		      ,C.used
		  FROM #Benefit_Comparison			BC
		  LEFT JOIN #CoinsuranceID			C
		    ON BC.coinsurance_variation_id	= C.coinsurance_id
		 WHERE comparison					= 'No Match' 
		   AND coinsurance_value_1			NOT IN ('CO Specific', 'CA Specific') 
		   AND coinsurance_value_2			NOT IN ('CO Specific', 'CA Specific')
		   AND C.used						= 1
		 ORDER BY coinsurance_variation_id

		FETCH NEXT FROM Comparison_Cursor
         INTO @benefit_id

	END

CLOSE Comparison_Cursor
DEALLOCATE Comparison_Cursor



--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Benefit_Mapping') IS NOT NULL
	BEGIN DROP TABLE #Benefit_Mapping END
END
GO