/**************************************************************************************************
Name:       spConfig_GridSavePlan
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
10/06/2022  DK				Remove trailing question mark due to non printable characters
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSavePlan 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSavePlan
     (@file_id			INT
	 ,@sheet_id			INT
	 ,@row				INT
	 ,@hios_id			VARCHAR(50)
	 ,@plan_id			VARCHAR(50)
	 ,@plan_name		VARCHAR(500)
	 ,@plan_state		VARCHAR(10)
	 ,@deductible_id	INT
	 ,@out_of_pocket_id	INT
	 ,@copay_id			INT)
AS
BEGIN

--*************************************************************************************************
-- Update logging data
--*************************************************************************************************
IF (RIGHT(@plan_name, 1) = '?') AND (LEN(@plan_name) > 1) 
	BEGIN 
		SELECT @plan_name = SUBSTRING(@plan_name, 1, LEN(@plan_name) -1)
	END

SELECT @plan_name = TRIM(@plan_name)

INSERT INTO grid.[Plan]
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,HIOSID
      ,PlanID
      ,PlanName
      ,PlanState
      ,DeductibleID
      ,OutOfPocketID
      ,CopayID)
SELECT @file_id
      ,@sheet_id
	  ,@row
      ,@hios_id
      ,@plan_id
	  ,dbo.fnConfig_GridAdjustPlanName(@plan_name)
	  ,@plan_state
	  ,@deductible_id
	  ,@out_of_pocket_id
	  ,@copay_id

END
GO