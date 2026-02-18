IF OBJECT_ID('dbo.spFCAuto_CreateLockboxFiles') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_CreateLockboxFiles AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_CreateLockboxFiles
Purpose:    Delete data that was loaded via a lockbox file

Date        User            Change
---------------------------------------------------------------------------------------------
03/05/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateLockboxFiles 'Dev-Lockbox%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_CreateLockboxFiles
     (@test_case_name	VARCHAR(200)	
	 ,@err_num			INT				= 0		OUTPUT
	 ,@err_msg			VARCHAR(8000)	= ''	OUTPUT)

AS
BEGIN

SET NOCOUNT ON

DECLARE @file_name		VARCHAR(200)
	   ,@file_prefix	VARCHAR(200)

SELECT @err_num = 0
	  ,@err_msg	 = 'Success'
	  
--*************************************************************************************************
-- Determine the TCIDs that need to be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TCIDs') IS NOT NULL
	DROP TABLE #TCIDs

CREATE TABLE #TCIDs
      (tcid		VARCHAR(200))

INSERT INTO #TCIDs
      (tcid)
SELECT TCID
  FROM COREAUTO.CoreFileCreator.fw.TestCase
 WHERE TestCaseName LIKE @test_case_name

IF OBJECT_ID('tempdb.dbo.#file_prefixes') IS NOT NULL
	DROP TABLE #file_prefixes

CREATE TABLE #file_prefixes
      (file_prefix	VARCHAR(200))

INSERT INTO #file_prefixes
      (file_prefix)
SELECT LB.file_prefix
  FROM COREAUTO.CoreFileCreator.dbo.TD_Lockbox	LB
  JOIN #TCIDs									T
    ON LB.TCID									LIKE T.tcid

--*************************************************************************************************
-- Loop through all the 837 files that have been loaded and delete each one
--*************************************************************************************************
DECLARE Prefix_Cursor CURSOR FOR
 SELECT file_prefix
   FROM #file_prefixes

   OPEN Prefix_Cursor
  FETCH NEXT FROM Prefix_Cursor
   INTO @file_prefix

SET @file_prefix = 'FC_Lockbox_' + @file_prefix + '%'

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			PRINT @file_prefix
			DECLARE Delete_Files CURSOR FOR
			 SELECT FRL.file_name
			   FROM dbo.File_Receive_Log	FRL
			  WHERE FRL.file_name			LIKE @file_prefix

			   OPEN Delete_Files
			  FETCH NEXT FROM Delete_Files
			   INTO @file_name

			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC spFCAuto_CreateLockboxFile @file_name, @err_num OUTPUT, @err_msg OUTPUT
					FETCH NEXT FROM Delete_Files
					 INTO @file_name

				END

			CLOSE Delete_Files
			DEALLOCATE Delete_Files

		END TRY
		BEGIN CATCH

			SET @err_msg = ERROR_MESSAGE()
			PRINT ' '
			PRINT 'Error: File, ' + @file_name + ' could not be deleted due to: ' + @err_msg

		END CATCH

		FETCH NEXT FROM Prefix_Cursor INTO @file_prefix
	END

CLOSE Prefix_Cursor
DEALLOCATE Prefix_Cursor

END
GO