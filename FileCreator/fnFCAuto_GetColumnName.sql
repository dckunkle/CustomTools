/**************************************************************************************************
Name:       fnFCAuto_GetColumnName
Purpose:    Function to standardize the column names in the database based on the labels for screens

Date        User            Change
---------------------------------------------------------------------------------------------
07/06/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnFCAuto_GetColumnName('Dans (Contact%)+')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnFCAuto_GetColumnName
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