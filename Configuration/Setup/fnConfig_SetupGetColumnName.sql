/**************************************************************************************************
Name:       fnConfig_SetupGetColumnName
Purpose:    Function to standardize the column names in the database based on the labels for screens

Date        User            Change
---------------------------------------------------------------------------------------------
07/06/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_SetupGetColumnName('Dans (Contact%)+')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupGetColumnName
     (@label_text		VARCHAR(1000))
RETURNS SYSNAME
AS
BEGIN
	
	DECLARE @column_name SYSNAME
	
	SELECT @column_name = REPLACE(@label_text, ' ', '')
	SELECT @column_name = REPLACE(@column_name, ':', '')
	SELECT @column_name = REPLACE(@column_name, '(', '')
	SELECT @column_name = REPLACE(@column_name, ')', '')
	SELECT @column_name = REPLACE(@column_name, '+', '')
	SELECT @column_name = REPLACE(@column_name, '/', '')
	SELECT @column_name = REPLACE(@column_name, '\', '')
	SELECT @column_name = REPLACE(@column_name, '-', '')
	SELECT @column_name = REPLACE(@column_name, '%', '')


	RETURN @column_name
END
GO