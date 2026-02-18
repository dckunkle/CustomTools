IF OBJECT_ID('dbo.spFCAuto_DeleteCustom837Files') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustom837Files AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustom837Files
Purpose:    Delete data that was loaded by a Member Conversionfile

Date        User            Change
---------------------------------------------------------------------------------------------
11/03/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustom837Files 'CountConfig%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustom837Files
     (@test_case_name	VARCHAR(200)	
	 ,@err_num			INT				= 0		OUTPUT
	 ,@err_msg			VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id			INT				= 99)

AS
BEGIN

SET NOCOUNT ON

DECLARE @file_name	VARCHAR(200)
	   ,@tcid		VARCHAR(200)

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

--*************************************************************************************************
-- Loop through all the 837 files that have been loaded and delete each one
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
			 WHERE FRL.file_name		LIKE 'FC_837__' + @tcid
			 GROUP BY FRL.file_name

			   OPEN Delete_Files
			  FETCH NEXT FROM Delete_Files
			   INTO @file_name

			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC spFCAuto_DeleteCustom837File @file_name, @err_num OUTPUT, @err_msg OUTPUT, @type_id
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