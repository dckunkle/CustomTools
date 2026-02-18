IF OBJECT_ID('dbo.spFCAuto_DeleteCustom837File') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustom837File AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustom837File
Purpose:    Delete data that was loaded by 837 Parse and Load

Date        User            Change
---------------------------------------------------------------------------------------------
01/19/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustom837File 'Member_Import_202011030240.txt'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustom837File
     (@filename		VARCHAR(200)	
	 ,@err_num		INT				= 0		OUTPUT
	 ,@err_msg		VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id		INT             = 99)
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Call the code to delete a single 837 file loaded through 837 Parse and Load
--*************************************************************************************************
EXEC spDDAuto_DeleteFileData837 @filename, 'Internal Delete', '', 1, '', @type_id

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO