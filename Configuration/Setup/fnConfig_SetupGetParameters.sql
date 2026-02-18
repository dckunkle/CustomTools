/**************************************************************************************************
Name:       fnConfig_SetupGetParameters
Purpose:    Return a SQL statement that selects the parametrs for a given stored procedure

Date        User            Change
---------------------------------------------------------------------------------------------
12/14/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_SetupGetParameters('prTypeOfBillAddModify')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupGetParameters(@procedure_name SYSNAME)
RETURNS VARCHAR(4000)
AS
BEGIN
	
	DECLARE @database_name	SYSNAME			= ''
	DECLARE @sql			VARCHAR(4000)	= ''

	SELECT @database_name = dbo.fnConfig_SetupGetDatabase()

	SELECT @sql = 'SELECT P.parameter_id
			             ,P.name 
                     FROM ' + @database_name + '.sys.parameters		P
				     JOIN ' + @database_name + '.sys.procedures		PR
				       ON P.object_id = PR.object_id
				    WHERE PR.name = ''' + @procedure_name + ''''

	RETURN @sql
END
GO