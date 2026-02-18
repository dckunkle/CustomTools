/**************************************************************************************************
Name:       fnConfig_CommonGetDatabase
Purpose:    Determine the database name for the Core database

Date        User            Change
---------------------------------------------------------------------------------------------
12/14/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_CommonGetDatabase()
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_CommonGetDatabase()
RETURNS SYSNAME
AS
BEGIN
	
	DECLARE @database_name SYSNAME = ''

	IF EXISTS(SELECT database_id FROM sys.databases WHERE name = 'CORE') 
		BEGIN 
		
			SET @database_name = 'CORE' 
			
		END
	ELSE
		BEGIN

			SELECT @database_name	= (SELECT TOP 1 D.name
										 FROM sys.databases	D
										WHERE D.name			LIKE '%APP%'
										ORDER BY D.name)
		END

	RETURN @database_name
END
GO