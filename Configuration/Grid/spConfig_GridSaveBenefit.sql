/**************************************************************************************************
Name:       spConfig_GridSaveBenefit
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveBenefit 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveBenefit
     (@file_id			INT
	 ,@sheet_id			INT
	 ,@row				INT
	 ,@benefit_id		INT
	 ,@benefit_name		VARCHAR(200)
	 ,@benefit_status	VARCHAR(20))
AS
BEGIN

--*************************************************************************************************
-- Update logging data
--*************************************************************************************************
INSERT INTO grid.PlanBenefit
      (GridFileID
	  ,GridSheetID
      ,GridRow
      ,BenefitID
      ,BenefitName
      ,BenefitStatus)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@benefit_id
	  ,@benefit_name
	  ,@benefit_status

END
GO