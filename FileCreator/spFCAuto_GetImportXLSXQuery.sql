/**************************************************************************************************
Name:       spFCAuto_GetImportXLSXQuery
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
07/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_GetImportXLSXQuery 'ImportXLSXDiagnosisCode', 1
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_GetImportXLSXQuery
     (@i_method_name	VARCHAR(400)
	 ,@i_record_id		INT)

AS
BEGIN

SET NOCOUNT ON

DECLARE @method_name		VARCHAR(400)
       ,@record_id			INT
	   ,@table_name			VARCHAR(200)
	   ,@sql				NVARCHAR(4000)
	   ,@variable_sql		NVARCHAR(4000)
	   ,@count				INT
	   ,@variable			NVARCHAR(200)
	   ,@variable_value		NVARCHAR(1000)

SELECT @method_name			= @i_method_name
      ,@record_id			= @i_record_id

--***************************************************************************************************
-- Get the SQL needed to get the key data for the record
--***************************************************************************************************
SELECT @sql					= I.key_sql
  FROM fw.ImportSpreadsheet	I
 WHERE I.method_name		= @method_name

SELECT @table_name		= C.table_name
  FROM fw.Catalog		C
 WHERE C.method_name	= @method_name

--***************************************************************************************************
-- Get the variable values for the SQL to collect the key values
--***************************************************************************************************
SET @count = 1

WHILE @count < 5
	BEGIN
		
		SET @variable_sql = 'SELECT @variable = variable_' + CONVERT(VARCHAR(2), @count) + ' FROM CoreFileCreator.fw.ImportSpreadsheet C WHERE method_name = ''' + @method_name + ''''
		EXEC sp_executesql @variable_sql, N'@variable VARCHAR(4000) OUTPUT', @variable=@variable OUTPUT

		PRINT @variable
		IF @variable <> ''
			BEGIN

				SET @variable_sql = 'SELECT @value = [' + @variable + '] FROM CoreFileCreator.dbo.' + @table_name + ' WHERE RecordID  = ' + CONVERT(VARCHAR(100), @record_id)
				EXEC sp_executesql @variable_sql, N'@value NVARCHAR(4000) OUTPUT', @value=@variable_value OUTPUT

				PRINT @variable_value
				SELECT @sql = REPLACE(@sql, '~variable_' + CONVERT(VARCHAR(10), @count) + '~', @variable_value)

			END

		SELECT @count = @count + 1
	END

--***************************************************************************************************
-- Output SQL
--***************************************************************************************************
SELECT @sql AS key_sql

END
GO