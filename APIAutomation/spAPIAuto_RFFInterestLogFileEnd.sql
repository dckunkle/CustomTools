/**************************************************************************************************
Name:       spAPIAuto_RFFInterestLogFileEnd
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
01/18/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridLogFileEnd 22
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_RFFInterestLogFileEnd
     (@file_id INT)
AS
BEGIN

--*************************************************************************************************
-- If beginning the log then add the file and get the ID
--*************************************************************************************************
UPDATE tmp.RFFInterestFile
   SET EndDate			= GETDATE()
 WHERE FileID			= @file_id

END
GO