IF OBJECT_ID('dbo.spFCUtil_PopulatePortalExtractTables') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCUtil_PopulatePortalExtractTables AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCUtil_PopulatePortalExtractTables
Purpose:    Create TD_ tables for the Portal Extract by using the table definitions in the
            QA06_PORTAL_DATAREP database on the PTLQADBPERF06 server

Date        User            Change
---------------------------------------------------------------------------------------------
06/16/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCUtil_PopulatePortalExtractTables 
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCUtil_PopulatePortalExtractTables
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql				VARCHAR(MAX) 
       ,@portal_table		VARCHAR(200)
	   ,@file_creator_table	VARCHAR(200)
	   ,@sort_field			VARCHAR(200)

	   ,@sql_insert			VARCHAR(MAX)
	   ,@sql_select			VARCHAR(MAX)

	   ,@column_name		VARCHAR(200)

	   ,@server				VARCHAR(100)	= 'PORTAL'
	   ,@database			VARCHAR(100)	= 'QA06_PORTAL_DATAREP_20210614'

--***************************************************************************************************
-- Create temp tables to help gather data
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_names') IS NOT NULL
	DROP TABLE #table_names

CREATE TABLE #table_names
      (portal_table_name		VARCHAR(200)
	  ,file_creator_table_name	VARCHAR(200)
	  ,sort_field				VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

CREATE TABLE #column_names
      (column_name		VARCHAR(200)
	  ,column_order		INT)

--***************************************************************************************************
-- Gather the data to create the Portal Extract tables
--***************************************************************************************************
INSERT INTO #table_names
      (portal_table_name
	  ,file_creator_table_name
	  ,sort_field)
SELECT portal_table_name
      ,file_creator_table_name
	  ,sort_field
  FROM wrk.PortalMigration		PM
 WHERE PM.in_extract			= 'Y'
   --AND PM.portal_table_name		= 'CLAIM_LD'

--***************************************************************************************************
-- Loop through the tables building a SQL statement to create the File Creator table
--***************************************************************************************************
DECLARE Tables_Cursor CURSOR FOR
 SELECT portal_table_name
       ,file_creator_table_name
	   ,sort_field
   FROM #table_names		T
  ORDER BY T.portal_table_name
  
   OPEN Tables_Cursor
  FETCH NEXT FROM Tables_Cursor
   INTO @portal_table, @file_creator_table, @sort_field

WHILE @@FETCH_STATUS = 0
	BEGIN

		PRINT @portal_table 

		--If there is already data in the table for the CORE load clear it
		SELECT @sql = 'DELETE FROM ' + @file_creator_table + ' WHERE TCID LIKE ''PTL-CORE-DATA%'''
		EXEC(@sql)

		--Make sure there are no columns in the table
		TRUNCATE TABLE #column_names

		-- Gather all of the column names for the portal tables, they will be used to construct the FC tables
		SELECT @sql = 'INSERT INTO #column_names
							 (column_name
							 ,column_order)
					   SELECT C.name
					         ,C.column_id
					     FROM ' + @server + '.' + @database + '.sys.columns		C
						 JOIN ' + @server + '.' + @database + '.sys.tables		T
						   ON C.object_id										= T.object_id
						WHERE T.name = ''' + @portal_table + ''''
						 
		EXEC(@sql)

		-- Loop through the column names building the CREATE TABLE statement 
		DECLARE Columns_Cursor CURSOR FOR
		 SELECT column_name
		   FROM #column_names		C
		  ORDER BY C.column_order
  
		   OPEN Columns_Cursor
		  FETCH NEXT FROM Columns_Cursor
		   INTO @column_name

		-- Begin the CREATE statement
		SELECT @sql_insert = 'INSERT INTO ' + @file_creator_table + '(TCID,TestType'
		SELECT @sql_select = 'SELECT ''PTL-CORE-DATA-'' + RIGHT(''00000'' + CONVERT(VARCHAR(10), ROW_NUMBER() OVER(ORDER BY ' + @sort_field + ')), 5), ''Add'''

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT @sql_insert = @sql_insert + ',' + @column_name 
				SELECT @sql_select = @sql_select + ',' + @column_name

				FETCH NEXT FROM Columns_Cursor
				 INTO @column_name

			END

		CLOSE Columns_Cursor
		DEALLOCATE Columns_Cursor

		SELECT @sql_insert = @sql_insert + ', ActiveTestCase)'
		SELECT @sql_select = @sql_select + ',''A'' FROM ' + @server + '.' + @database + '.dbo.' + @portal_table 

		SELECT @sql = @sql_insert + ' ' + @sql_select

		--PRINT @sql
		EXEC(@sql)

		FETCH NEXT FROM Tables_Cursor
		 INTO  @portal_table, @file_creator_table, @sort_field

	END

CLOSE Tables_Cursor
DEALLOCATE Tables_Cursor

--***************************************************************************************************
-- Cleanup
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_names') IS NOT NULL
	DROP TABLE #table_names

IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

END
GO