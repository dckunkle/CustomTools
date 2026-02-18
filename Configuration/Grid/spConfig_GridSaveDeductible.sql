/**************************************************************************************************
Name:       spConfig_GridSaveDeductible
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveDeductible 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveDeductible
     (@file_id						INT
	 ,@sheet_id						INT
	 ,@row							INT
	 ,@deductible_id				INT
	 ,@individual_deductible		VARCHAR(50)
	 ,@family_deductible			VARCHAR(50)
	 ,@individual_oon_deductible	VARCHAR(50)
	 ,@family_oon_deductible		VARCHAR(50))
AS
BEGIN

--*************************************************************************************************
-- Insert individual deductible
--*************************************************************************************************
INSERT INTO grid.PlanDeductible
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,DeductibleID
	  ,DeductibleType
	  ,DeductibleAmount)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@deductible_id
	  ,'Individual'
	  ,@individual_deductible

--*************************************************************************************************
-- Insert family deductible
--*************************************************************************************************
INSERT INTO grid.PlanDeductible
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,DeductibleID
	  ,DeductibleType
	  ,DeductibleAmount)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@deductible_id
	  ,'Family'
	  ,@family_deductible

--*************************************************************************************************
-- Insert individual deductible
--*************************************************************************************************
INSERT INTO grid.PlanDeductible
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,DeductibleID
	  ,DeductibleType
	  ,DeductibleAmount)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@deductible_id
	  ,'Individual OON'
	  ,@individual_oon_deductible

--*************************************************************************************************
-- Insert family deductible
--*************************************************************************************************
INSERT INTO grid.PlanDeductible
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,DeductibleID
	  ,DeductibleType
	  ,DeductibleAmount)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@deductible_id
	  ,'Family OON'
	  ,@family_oon_deductible
END
GO