/**************************************************************************************************
Name:       spFCAuto_GetImportXLSXData
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
07/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_GetImportXLSXData 'ImportXLSXDiagnosisCode', 'UAT-TestCase%'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_GetImportXLSXData
     (@i_method_name	VARCHAR(400)
	 ,@i_pattern		VARCHAR(200))

AS
BEGIN

SET NOCOUNT ON

DECLARE @method_name		VARCHAR(400)
       ,@pattern			VARCHAR(200)

	   ,@table_name			VARCHAR(200)
	   ,@column_name		VARCHAR(200)
	   ,@sql				VARCHAR(8000)
	   
	   -- Used to determine which fields to include in the file
	   ,@type_location		INT
	   ,@active_location	INT

SELECT @method_name			= @i_method_name
      ,@pattern				= @i_pattern

--***************************************************************************************************
-- Create temp tables to help gather data
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

CREATE TABLE #column_names
      (field_name	VARCHAR(200)
	  ,field_order	INT)

--***************************************************************************************************
-- Get information based on the method_name passed in
--***************************************************************************************************
SELECT @table_name		= C.table_name
  FROM fw.Catalog		C
 WHERE C.method_name	= @method_name

--***************************************************************************************************
-- Build a list of the fields that need to be exported
--***************************************************************************************************
BEGIN TRY

	SELECT TOP 1
	       @type_location	= C.column_id + 1
	  FROM sys.columns	C
	  JOIN sys.tables	T
		ON C.object_id	= T.object_id
	 WHERE C.name = 'Type' 
	ORDER BY c.column_id ASC

	SELECT @active_location	= C.column_id - 1
	  FROM sys.columns	C
	  JOIN sys.tables	T
		ON C.object_id	= T.object_id
	 WHERE T.name		= @table_name
	   AND C.name		= 'ActiveTestCase'

	INSERT INTO #column_names
		  (field_name
		  ,field_order)
	SELECT C.name
		  ,C.column_id
	  FROM sys.columns	C
	  JOIN sys.tables	T
		ON C.object_id	= T.object_id
	 WHERE T.name		= @table_name
	   AND C.column_id	BETWEEN @type_location AND @active_location

	-- Loop through the columns building the correct SQL
	DECLARE Fields_Cursor CURSOR FOR
	 SELECT field_name
	   FROM #column_names	C
	  ORDER BY field_order
  
	  OPEN Fields_Cursor
	 FETCH NEXT FROM Fields_Cursor
	  INTO @column_name

	SELECT @sql = 'SELECT RecordID, '

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			PRINT @column_name
			SELECT @sql = @sql + '[' + @column_name + '], '

			FETCH NEXT FROM Fields_Cursor
			  INTO @column_name
		END

	CLOSE Fields_Cursor
	DEALLOCATE Fields_Cursor

	SELECT @sql = LEFT(@sql, LEN(@sql) - 1)	-- Drop the last comma
	SELECT @sql = @sql + ' FROM dbo.' + @table_name + ' WHERE TCID LIKE (''' + @pattern + ''') AND ActiveTestCase = ''A'''

	PRINT @sql
	EXEC(@sql)

	SELECT I.entity_name
	      ,I.screen_gid
	  FROM fw.ImportSpreadsheet		I
	 WHERE I.method_name			= @method_name

END TRY
BEGIN CATCH
END CATCH

--***************************************************************************************************
-- Cleanup
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

END
GO