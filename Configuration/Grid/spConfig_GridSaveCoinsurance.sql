/**************************************************************************************************
Name:       spConfig_GridSaveCoinsurance
Purpose:    Used to load Coinsurance and Copay data from the Benefit Grid

Date        User            Change
---------------------------------------------------------------------------------------------
03/28/2022	DK				Original procedure
10/06/2022  DK				Remove extra spaces from the coinsurance value
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridSaveCoinsurance
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveCoinsurance
     (@file_id					INT
	 ,@sheet_id					INT
	 ,@row						INT
	 ,@column					INT	
	 ,@coinsurance_id			INT
	 ,@benefit_id				INT
	 ,@coinsurance_value		VARCHAR(100))
AS
BEGIN

--*************************************************************************************************
-- Insert individual deductible
--*************************************************************************************************
SELECT @coinsurance_value = TRIM(@coinsurance_value)

INSERT INTO grid.PlanCoinsuranceCopay
      (GridFileID
	  ,GridSheetID
	  ,GridRow
	  ,GridColumn
	  ,CopayID
	  ,BenefitID
	  ,CopayCoinsValue)
SELECT @file_id
	  ,@sheet_id
      ,@row
	  ,@column
	  ,@coinsurance_id
	  ,@benefit_id
	  ,@coinsurance_value

END
GO