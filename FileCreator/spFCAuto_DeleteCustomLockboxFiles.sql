IF OBJECT_ID('dbo.spFCAuto_DeleteCustomLockboxFiles') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustomLockboxFiles AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustomLockboxFiles
Purpose:    Delete data that was loaded by a lockbox file

Date        User            Change
---------------------------------------------------------------------------------------------
03/05/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomLockboxFiles 'Dev-Lockbox'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustomLockboxFiles
     (@test_case_name	VARCHAR(200)	
	 ,@err_num			INT				= 0		OUTPUT
	 ,@err_msg			VARCHAR(8000)	= ''	OUTPUT)

AS
BEGIN

SET NOCOUNT ON
	
DECLARE @file_name			VARCHAR(200)
	   ,@tcid				VARCHAR(200)
	   ,@filename			VARCHAR(200)
	   ,@filename_delimiter	VARCHAR(200)
	   ,@filename_prefix	VARCHAR(200)	

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

SELECT @filename							= C.filename
      ,@filename_delimiter					= C.filename_delimiter
  FROM COREAUTO.CoreFileCreator.fw.Catalog	C
 WHERE C.method_name						= 'Lockbox'

--*************************************************************************************************
-- Loop through all the lockbox files that have been loaded and delete each one
--*************************************************************************************************
DECLARE Delete_TCIDs CURSOR FOR
 SELECT tcid
   FROM #TCIDs

   OPEN Delete_TCIDs
  FETCH NEXT FROM Delete_TCIDs
   INTO @tcid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			SET @tcid = CASE WHEN RIGHT(@tcid,1) = '%' THEN @tcid
							 ELSE @tcid + '%'
						 END
			SET @filename_prefix = @filename + @filename_delimiter + @tcid

			DECLARE Delete_Files CURSOR FOR
			 SELECT FRL.file_name
			  FROM dbo.File_Receive_Log	FRL
			 WHERE FRL.file_name		LIKE @filename_prefix
			 GROUP BY FRL.file_name

			   OPEN Delete_Files
			  FETCH NEXT FROM Delete_Files
			   INTO @file_name

			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC spFCAuto_DeleteCustomLockboxFile @file_name, @err_num OUTPUT, @err_msg OUTPUT
					FETCH NEXT FROM Delete_Files
					 INTO @file_name

				END

			CLOSE Delete_Files
			DEALLOCATE Delete_Files

		END TRY
		BEGIN CATCH

			PRINT ' '
			PRINT 'Error: File, ' + @file_name + ' could not be deleted due to: ' + @err_msg

		END CATCH

		FETCH NEXT FROM Delete_TCIDs INTO @tcid
	END

CLOSE Delete_TCIDs
DEALLOCATE Delete_TCIDs

END
GO