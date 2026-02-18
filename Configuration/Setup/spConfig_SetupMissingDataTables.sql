/**************************************************************************************************
Name:       spConfig_SetupMissingDataTables
Purpose:    Build a table definition given a screen gid and the table name

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_SetupMissingDataTables 
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_SetupMissingDataTables
AS
BEGIN

SET NOCOUNT ON 

DECLARE @table_name		VARCHAR(128)
       ,@method_name	VARCHAR(128)
	   ,@core_procedure VARCHAR(128)
	   ,@fields			INT

--*************************************************************************************************
-- Create a table that will be used to create any missing tables
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_names') IS NOT NULL
	DROP TABLE #table_names

CREATE TABLE #table_names
      (method_name			VARCHAR(128)
	  ,table_name			VARCHAR(128)
	  ,core_procedure		VARCHAR(128)
	  ,fields				INT)
	
--*************************************************************************************************
-- Create a table that will be used to construct the data table
--*************************************************************************************************
INSERT INTO #table_names
      (method_name
	  ,table_name
	  ,core_procedure
	  ,fields)
SELECT C.MethodName
      ,C.TableName
	  ,AL.CoreProcedure
	  ,AL.FieldCount
  FROM cfg.Catalog		C
  JOIN cfg.ActionLoad	AL
    ON C.MethodName		= AL.MethodName

--*************************************************************************************************
-- Loop through the tables and create any that are missing
--*************************************************************************************************
 DECLARE Tables_Cursor CURSOR FOR
 SELECT method_name
       ,table_name
	   ,core_procedure
	   ,fields
   FROM #table_names

   OPEN Tables_Cursor
  FETCH NEXT FROM Tables_Cursor
   INTO @method_name, @table_name, @core_procedure, @fields

WHILE @@FETCH_STATUS = 0
	BEGIN

		IF NOT EXISTS(SELECT TOP 1 T.name
						FROM sys.tables	T
						JOIN sys.schemas	S
						  ON T.schema_id	= S.schema_id
					   WHERE S.name		= 'data'
						 AND T.name		= @table_name)
			BEGIN

				PRINT 'Creating table ' + @table_name
				EXEC spConfig_SetupDataTable @method_name, @core_procedure, @fields
			END

		FETCH NEXT FROM Tables_Cursor
		 INTO @method_name, @table_name, @core_procedure, @fields

	END

END
GO