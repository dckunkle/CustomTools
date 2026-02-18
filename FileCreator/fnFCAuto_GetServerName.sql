/**************************************************************************************************
Name:       fnFCAuto_GetServerName
Purpose:    Given the SQL Instance name, return the batch folder name

Date        User            Change
---------------------------------------------------------------------------------------------
02/05/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnFCAuto_GetServerName('aldqadbqr06')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnFCAuto_GetServerName
     (@instance_name		VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @server_name VARCHAR(200) = ''

	SELECT @server_name		= server_name
	  FROM fw.BatchFolder
	 WHERE instance_name	= @instance_name

	RETURN @server_name
END
GO