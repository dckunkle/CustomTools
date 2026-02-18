/**************************************************************************************************
Name:       fnFCAuto_GetDatabaseName
Purpose:    Given the SQL Instance name, return the batch folder name

Date        User            Change
---------------------------------------------------------------------------------------------
07/11/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnFCAuto_GetDatabaseName('aldqadbqr06')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnFCAuto_GetDatabaseName
     (@instance_name		VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @database VARCHAR(200) = ''

	SELECT @database				= S.core_database
	  FROM SystemAudit.dbo.Server	S
	 WHERE S.instance_name			= @instance_name

	RETURN @database
END
GO