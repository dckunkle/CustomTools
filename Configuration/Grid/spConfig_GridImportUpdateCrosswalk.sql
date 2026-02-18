/**************************************************************************************************
Name:       spConfig_GridImportUpdateCrosswalk
Purpose:    Update the Benenfit Crosswalk marking those scenarios that cannot be processed at this
            time. For example, many Bright benefits mapped to a single benefit class, or when
			a Bright benefit has no mapping

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original procedure
06/15/2022  DK				Remove Ignore logic to different stored procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportUpdateCrosswalk
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportUpdateCrosswalk
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Reset the data to the original state
--*************************************************************************************************
UPDATE grid.PlanBenefitCrosswalk
   SET MappingType = NULL

--*************************************************************************************************
-- Update the mapping type for each mapping (one to one, one to many, many to one)
--*************************************************************************************************
UPDATE PBC
   SET MappingType	= '1:1'
  FROM grid.PlanBenefitCrosswalk PBC
 WHERE Ignore		= 0
   AND BenefitID IN (SELECT BenefitID
					   FROM grid.PlanBenefitCrosswalk
					  WHERE Ignore = 0
					  GROUP BY BenefitID
					 HAVING COUNT(*) = 1)

UPDATE PBC
   SET MappingType	= '1:M'
  FROM grid.PlanBenefitCrosswalk PBC
 WHERE Ignore		= 0
   AND BenefitID IN (SELECT BenefitID
					   FROM grid.PlanBenefitCrosswalk
					  WHERE Ignore = 0
					  GROUP BY BenefitID
					 HAVING COUNT(*) > 1)

UPDATE PBC
   SET MappingType	= 'M:1'
  FROM grid.PlanBenefitCrosswalk PBC
 WHERE Ignore		= 0
   AND CoreBenefitID IN (SELECT CoreBenefitID
					       FROM grid.PlanBenefitCrosswalk
						  WHERE Ignore = 0
					      GROUP BY CoreBenefitID
					     HAVING COUNT(*) > 1)



END 
GO