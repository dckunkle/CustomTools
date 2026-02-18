/**************************************************************************************************
Name:       fnDCAuto_GetEnterpriseID
Purpose:    Determine the EnterpriseID from the server name

Date        User            Change
---------------------------------------------------------------------------------------------
08/25/2023	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnDCAuto_GetEnterpriseID()
RETURNS VARCHAR(20)
AS
BEGIN
	
	DECLARE @server_name	VARCHAR(128)
	       ,@enterprise_id	VARCHAR(20)

	SELECT @server_name = @@SERVERNAME

	SELECT @enterprise_id	= ISNULL(EnterpriseID, 0)
	  FROM COREAUTO.APIAutomation.fw.EnterpriseIDLookup
	 WHERE ServerName		= @server_name

	RETURN @enterprise_id
END
GO