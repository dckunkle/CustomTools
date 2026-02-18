/**************************************************************************************************
Name:       spConfig_GridSaveOutOfPocket
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveOutOfPocket 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveOutOfPocket
     (@file_id					INT
	 ,@sheet_id					INT
	 ,@row						INT
	 ,@out_of_pocket_id			INT
	 ,@individual_out_of_pocket	VARCHAR(50)
	 ,@family_out_of_pocket		VARCHAR(50))
AS
BEGIN

--*************************************************************************************************
-- Insert individual deductible
--*************************************************************************************************
INSERT INTO grid.PlanOutOfPocket
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,OutOfPocketID
	  ,OutOfPocketType
	  ,OutOfPocketAmount)
SELECT @file_id
      ,@sheet_id
      ,@row
	  ,@out_of_pocket_id
	  ,'Individual'
	  ,@individual_out_of_pocket

--*************************************************************************************************
-- Insert family deductible
--*************************************************************************************************
INSERT INTO grid.PlanOutOfPocket
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,OutOfPocketID
	  ,OutOfPocketType
	  ,OutOfPocketAmount)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@out_of_pocket_id
	  ,'Family'
	  ,@family_out_of_pocket

END
GO