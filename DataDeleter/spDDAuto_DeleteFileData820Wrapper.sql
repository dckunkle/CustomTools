IF OBJECT_ID('dbo.spDDAuto_DeleteFileData820Wrapper') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_DeleteFileData820Wrapper AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_DeleteFileData820Wrapper
Purpose:    Delete data for a file loaded through the 820 Import process

Date        User            Change
---------------------------------------------------------------------------------------------
12/08/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_DeleteFileData820Wrapper 'filename'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_DeleteFileData820Wrapper
     (@file_name		VARCHAR(200)
	 ,@test_case_name	VARCHAR(200)
	 ,@action			VARCHAR(50)		= 'List Files'
	 ,@email_address	VARCHAR(200)	= ''
	 ,@build_id			INT				= 1
	 ,@job_name			VARCHAR(200)	= '')
AS
BEGIN

SET NOCOUNT ON

DECLARE @file_count			INT
       ,@tcid				VARCHAR(200)
	   ,@err_msg			VARCHAR(4000)

--*************************************************************************************************
-- If the user specified to List Files then list the files and exit
--*************************************************************************************************
IF ISNULL(@action, '') = 'List Files'
	BEGIN
		EXEC spDDAuto_DeleteFileData820 @file_name, @action, @email_address, @build_id, @job_name
		GOTO CLEANUP
	END

--*************************************************************************************************
-- If the user did not specific a test case name then proceed with the action that was selected
--*************************************************************************************************
IF ISNULL(@test_case_name, '') = ''
	BEGIN
		EXEC spDDAuto_DeleteFileData820 @file_name, @action, @email_address, @build_id, @job_name
		GOTO CLEANUP
	END

--*************************************************************************************************
-- In the event that the user specified a filename and a test case name, process the filename
--*************************************************************************************************
IF ISNULL(@file_name, '') <> ''
	BEGIN
		EXEC spDDAuto_DeleteFileData820 @file_name, @action, @email_address, @build_id, @job_name
	END

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

--*************************************************************************************************
-- Loop through all the 820 files that have been loaded and delete each one
--*************************************************************************************************
DECLARE Delete_TCIDs CURSOR FOR
 SELECT tcid
   FROM #TCIDs

   OPEN Delete_TCIDs
  FETCH NEXT FROM Delete_TCIDs
   INTO @tcid


SET @tcid = CASE WHEN RIGHT(@tcid,1) = '%' THEN @tcid
                 ELSE @tcid + '%'
			 END

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			DECLARE Delete_Files CURSOR FOR
			 SELECT FRL.file_name
			  FROM dbo.File_Receive_Log	FRL
			 WHERE FRL.file_name		LIKE '%I820%.FC.' + @tcid 
			   AND file_type			= '820'
			 GROUP BY FRL.file_name

			   OPEN Delete_Files
			  FETCH NEXT FROM Delete_Files
			   INTO @file_name

			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC spDDAuto_DeleteFileData820 @file_name, @action, @email_address, @build_id, @job_name
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

		FETCH NEXT FROM Delete_TCIDs INTO @tcid
	END

CLOSE Delete_TCIDs
DEALLOCATE Delete_TCIDs


--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#List_Files') IS NOT NULL	
	DROP TABLE #List_Files

END
GO