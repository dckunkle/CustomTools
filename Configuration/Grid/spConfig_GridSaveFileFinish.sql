/**************************************************************************************************
Name:       spConfig_GridSaveFileFinish
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
03/25/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spConfig_GridSaveFileFinish 'Grid.xlsx', 'Plan Master', @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridSaveFileFinish
     (@file_id			INT
	 ,@sheet_id			INT
	 ,@status			VARCHAR(300))
AS
BEGIN

--*************************************************************************************************
-- Update logging data
--*************************************************************************************************
UPDATE grid.[FileSheet]
   SET ProcessEnd	= GETDATE()
      ,[Status]		= @status
 WHERE FileID		= @file_id	
   AND SheetID		= @sheet_id

END
GO