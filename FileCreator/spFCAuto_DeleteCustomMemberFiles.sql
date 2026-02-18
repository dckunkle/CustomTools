IF OBJECT_ID('dbo.spFCAuto_DeleteCustomMemberFiles') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustomMemberFiles AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustomMemberFiles
Purpose:    Delete data that was loaded by a Member Conversionfile

Date        User            Change
---------------------------------------------------------------------------------------------
11/03/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomMemberFiles 
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustomMemberFiles
     (@err_num		INT				= 0		OUTPUT
	 ,@err_msg		VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id		INT				= 99)

AS
BEGIN

SET NOCOUNT ON

DECLARE @file_name	VARCHAR(200)


SELECT @err_num = 0
	  ,@err_msg	 = 'Success'

--*************************************************************************************************
-- Loop through all the Member Import files that have been loaded and delete each one
--*************************************************************************************************
BEGIN TRY

	DECLARE Delete_Files CURSOR FOR
	 SELECT ERL.file_name
	  FROM Elig_Load_Run_Log	ERL
	 WHERE ERL.file_name		LIKE 'FC_Member_%'
	 GROUP BY ERL.file_name

	   OPEN Delete_Files
	  FETCH NEXT FROM Delete_Files
	   INTO @file_name

	WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC spFCAuto_DeleteCustomMemberFile @file_name, @err_num OUTPUT, @err_msg OUTPUT, @type_id
			FETCH NEXT FROM Delete_Files
			 INTO @file_name

		END

	CLOSE Delete_Files
	DEALLOCATE Delete_Files

END TRY
BEGIN CATCH

	PRINT 'Error: File, ' + @file_name + ' could not be deleted due to: ' + @err_msg

END CATCH

END
GO