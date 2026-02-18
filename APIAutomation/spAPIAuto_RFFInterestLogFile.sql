/**************************************************************************************************
Name:       spAPIAuto_RFFInterestLogFile
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
01/18/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @file_id INT
EXEC spAPIAuto_RFFInterestLogFile 'BEGIN', 'C:\Grid\Grid.xlsx', '2022-03-28 10:44:57.560', 2986941, @file_id OUTPUT
SELECT @file_id
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_RFFInterestLogFile
     (@fullname			VARCHAR(2000)	
	 ,@file_directory	VARCHAR(1000)	
	 ,@filename			VARCHAR(1000)
	 ,@file_date		VARCHAR(100)
	 ,@file_size		INT
	 ,@file_state		VARCHAR(20)		= 'ZZ'
	 ,@file_id			INT				OUTPUT)
AS
BEGIN

--*************************************************************************************************
-- If beginning the log then add the file and get the ID
--*************************************************************************************************
INSERT INTO tmp.RFFInterestFile
	  (Fullname
	  ,FileDirectory
	  ,FileName
	  ,FileDate
	  ,FileSize
	  ,BeginDate)
SELECT @fullname
	  ,@file_directory
	  ,@filename
	  ,@file_date
	  ,@file_size
	  ,GETDATE()

SELECT @file_id = @@IDENTITY


END
GO