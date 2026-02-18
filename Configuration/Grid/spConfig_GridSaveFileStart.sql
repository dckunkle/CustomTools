/**************************************************************************************************
Name:       spConfig_GridSaveFileStart
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveFileStart 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveFileStart
     (@file_id			INT
	 ,@worksheet		VARCHAR(100)
	 ,@sheet_id			INT				OUTPUT)
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO grid.[FileSheet]
      (FileID
	  ,WorksheetName)
SELECT @file_id
      ,@worksheet

SELECT @sheet_id = @@IDENTITY

END
GO