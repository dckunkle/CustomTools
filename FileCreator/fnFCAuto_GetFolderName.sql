IF OBJECT_ID('dbo.fnFCAuto_GetFolderName') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnFCAuto_GetFolderName() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnFCAuto_GetFolderName
Purpose:    Given the SQL Instance name, return the batch folder name

Date        User            Change
---------------------------------------------------------------------------------------------
02/05/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnFCAuto_GetFolderName
     (@instance_name		VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @folder_name VARCHAR(200) = ''

	SELECT @folder_name		= batch_folder
	  FROM fw.BatchFolder
	 WHERE instance_name	= @instance_name

	RETURN @folder_name
END
GO