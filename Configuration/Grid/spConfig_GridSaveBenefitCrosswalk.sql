/**************************************************************************************************
Name:       spConfig_GridSaveBenefitCrosswalk
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveBenefitCrosswalk 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveBenefitCrosswalk
     (@file_id				INT
	 ,@sheet_id				INT
	 ,@row					INT
	 ,@benefit_id			INT
	 ,@benefit_name			VARCHAR(200)
	 ,@benefit_class_type	VARCHAR(20)
	 ,@cost_share_category	VARCHAR(200)
	 ,@client_benefit_id	VARCHAR(20))
AS
BEGIN

--*************************************************************************************************
-- Update logging data
--*************************************************************************************************
INSERT INTO grid.PlanBenefitCrosswalk
      (GridFileID
	  ,GridSheetID
      ,GridRow
      ,BenefitID
      ,BenefitName
      ,BenefitClassType
	  ,CostShareCategory
	  ,CoreBenefitID)
SELECT @file_id
      ,@sheet_id
      ,@row
	  ,@benefit_id
	  ,@benefit_name
	  ,@benefit_class_type
	  ,@cost_share_category
	  ,@client_benefit_id

END
GO