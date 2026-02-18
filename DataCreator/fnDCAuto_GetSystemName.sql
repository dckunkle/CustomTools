/**************************************************************************************************
Name:       fnDCAuto_GetSystemName
Purpose:    Determine the System Name from the server name

Date        User            Change
---------------------------------------------------------------------------------------------
08/25/2023	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnDCAuto_GetSystemName()
RETURNS VARCHAR(20)
AS
BEGIN
	
	DECLARE @server_name	VARCHAR(128)
	       ,@system_name	VARCHAR(20)

	SELECT @server_name = @@SERVERNAME

	SELECT @system_name	= ISNULL(SystemName, 0)
	  FROM COREAUTO.APIAutomation.fw.EnterpriseIDLookup
	 WHERE ServerName		= @server_name

	RETURN @system_name
END
GO