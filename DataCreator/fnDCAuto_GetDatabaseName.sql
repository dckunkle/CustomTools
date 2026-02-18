IF OBJECT_ID('dbo.fnDCAuto_GetDatabaseName') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetDatabaseName() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetDatabaseName
Purpose:    Determine the database name for the Core database

Date        User            Change
---------------------------------------------------------------------------------------------
10/21/2019	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetDatabaseName()
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @database_name VARCHAR(128) = ''

	IF EXISTS(SELECT database_id FROM sys.databases WHERE name = 'CORE') 
		BEGIN 
		
			SET @database_name = 'CORE' 
			
		END
	ELSE
		BEGIN

			SELECT @database_name	= (SELECT TOP 1 D.name
										 FROM sys.databases	D
										WHERE D.name			LIKE '%APP%'			-- 2019-02-28 Tweak WHERE
										ORDER BY D.name)
		END

	RETURN @database_name
END
GO