/**************************************************************************************************
Name:       spConfig_GridImportSetCopayFlags
Purpose:    Import the Coinsurance/Copay data from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original procedure
10/06/2022  DK				2023 Plan changes 
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImportSetCopayFlags 'Bright-0407-', 'ALL'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImportSetCopayFlags
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Set original values
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET  Dollar						= 0
       ,DollarAmount				= -1
	   ,[Percentage]				= 0
	   ,PercentageAmount			= -1
	   ,FreeVisit					= 0
	   ,Visits						= 0
	   ,AfterDeductible				= 0
	   ,Automate					= 1
	   ,CopayScheduleName			= NULL
	   ,CopayScheduleDescription	= NULL

--*************************************************************************************************
-- Determine the values for copays
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET Dollar			= 1
 WHERE CopayCoinsValue	LIKE '%$%'

UPDATE grid.PlanCoinsuranceCopay
   SET DollarAmount		= dbo.fnConfig_GridDollarAmount(CopayCoinsValue)
 WHERE Dollar			= 1

UPDATE grid.PlanCoinsuranceCopay
   SET AfterDeductible	= 1
 WHERE CopayCoinsValue	LIKE '%after deductible%'

--*************************************************************************************************
-- Determine the values for coinsurance
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET [Percentage]		= 1
 WHERE CopayCoinsValue	LIKE '%[%]%'

UPDATE grid.PlanCoinsuranceCopay
   SET PercentageAmount	= dbo.fnConfig_GridPercentAmount(CopayCoinsValue)
 WHERE [Percentage]		= 1

--*************************************************************************************************
-- Determine the free visits
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET FreeVisit		= 1
      ,Visits			= LEFT(CopayCoinsValue, CHARINDEX(' ',CopayCoinsValue,1))
 WHERE CopayCoinsValue	LIKE '%free visit(s)%'

UPDATE grid.PlanCoinsuranceCopay
   SET FreeVisit		= 1
      ,Visits			= RIGHT(LEFT(CopayCoinsValue, 21), 1)
 WHERE CopayCoinsValue	LIKE 'No charge for first % visit(s)%'

--*************************************************************************************************
-- Mark scenarios that won't be automated
--*************************************************************************************************
UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= 'CO Specific'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= 'CA Specific'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= 'Once every 12 months'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= '3 $50 visit(s) then 0% after deductible'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= 'error'
 
UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% off balance over %'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= '$25 copay - $130/20% off balance over $130'
 
UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= 'Not Applicable after deductible'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE 'In lieu%'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% per day'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% up to $%'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE 'Includes % materials allowance plus discount.'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% for first 3 non-preventative visit(s) then deductible'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% Exam(s) per Year'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	LIKE '% Item(s) per Year'

UPDATE grid.PlanCoinsuranceCopay
   SET Automate			= 0
 WHERE CopayCoinsValue	= ''

END
GO