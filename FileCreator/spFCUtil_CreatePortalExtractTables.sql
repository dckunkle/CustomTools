IF OBJECT_ID('dbo.spFCUtil_CreatePortalExtractTables') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCUtil_CreatePortalExtractTables AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCUtil_CreatePortalExtractTables
Purpose:    Create TD_ tables for the Portal Extract by using the table definitions in the
            QA06_PORTAL_DATAREP database on the PTLQADBPERF06 server

Date        User            Change
---------------------------------------------------------------------------------------------
06/14/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCUtil_CreatePortalExtractTables 
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCUtil_CreatePortalExtractTables
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql				VARCHAR(8000) 
       ,@portal_table		VARCHAR(200)
	   ,@file_creator_table	VARCHAR(200)

	   ,@sql_drop			VARCHAR(8000)
	   ,@sql_create			VARCHAR(8000)

	   ,@column_name		VARCHAR(200)

	   ,@server				VARCHAR(100)	= 'PORTAL'
	   ,@database			VARCHAR(100)	= 'QA06_PORTAL_DATAREP'

--***************************************************************************************************
-- Create temp tables to help gather data
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_names') IS NOT NULL
	DROP TABLE #table_names

CREATE TABLE #table_names
      (portal_table_name		VARCHAR(200)
	  ,file_creator_table_name	VARCHAR(200))

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
	  ,file_creator_table_name)
SELECT portal_tble_name
      ,file_creator_table_name
  FROM wrk.PortalMigration		PM
 WHERE PM.in_extract			= 'Y'
   AND PM.status				= 'A'
   --AND PM.portal_tble_name		= 'CLAIM_LD'


--***************************************************************************************************
-- Loop through the tables building a SQL statement to create the File Creator table
--***************************************************************************************************
DECLARE Tables_Cursor CURSOR FOR
 SELECT portal_table_name
       ,file_creator_table_name
   FROM #table_names		T
  ORDER BY T.portal_table_name
  
   OPEN Tables_Cursor
  FETCH NEXT FROM Tables_Cursor
   INTO @portal_table, @file_creator_table

WHILE @@FETCH_STATUS = 0
	BEGIN

		PRINT @file_creator_table

		SELECT @sql_drop = 'IF OBJECT_ID(''dbo.' + @file_creator_table + ''') IS NOT NULL DROP TABLE ' + @file_creator_table
		EXEC(@sql_drop)

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
		SELECT @sql_create = 'CREATE TABLE ' + @file_creator_table + '
		                            (TCID		VARCHAR(50)
									,TestType	VARCHAR(100)
									' 						

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT @sql_create = @sql_create + ',' + @column_name + ' VARCHAR(255)'

				FETCH NEXT FROM Columns_Cursor
				 INTO @column_name

			END

		CLOSE Columns_Cursor
		DEALLOCATE Columns_Cursor

		SELECT @sql_create = @sql_create + ',ActiveTestCase		VARCHAR(5)
		                                    ,CreatedBy			VARCHAR(50)
											,CreatedDate		DATE
											,ModifiedBy			VARCHAR(50)
											,ModifiedDate		DATE
											,RecordID			INT			IDENTITY(1,1)

											CONSTRAINT [PK_' + @file_creator_table + '_RecordID] PRIMARY KEY NONCLUSTERED 
											([RecordID] ASC)
											WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) 
											ON [PRIMARY]'
		--PRINT @sql_create
		EXEC(@sql_create)

		--*************************************************************************************************
		-- Create constraints and indexes
		--*************************************************************************************************
		SET @sql = 'ALTER TABLE [dbo].[' + @file_creator_table + '] ADD  CONSTRAINT [DF_' + @file_creator_table + '_ActiveTestCase]  DEFAULT (''A'') FOR [ActiveTestCase]'
		EXEC (@sql)

		SET @sql = 'CREATE CLUSTERED INDEX [CX_' + @file_creator_table + '] ON [dbo].[' + @file_creator_table + ']
						   ([TCID] ASC)
						   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]'
		EXEC (@sql)

		--*************************************************************************************************
		-- Create triggers
		--*************************************************************************************************
		SET @sql = 'CREATE TRIGGER [dbo].[TR_' + @file_creator_table + '_Insert]
						ON [dbo].[' + @file_creator_table + ']
					 AFTER INSERT
						AS
						IF UPDATE(RecordID)
							BEGIN

								UPDATE ' + @file_creator_table + '
									SET CreatedBy		= SUSER_NAME()
										,CreatedDate	= GETDATE()
										,ModifiedBy		= SUSER_NAME()
										,ModifiedDate	= GETDATE()
			                    
									FROM Inserted I
									WHERE I.RecordID = ' + @file_creator_table + '.RecordID 
							END'

		EXEC (@sql)

		SET @sql = 'ALTER TABLE [dbo].[' + @file_creator_table + '] ENABLE TRIGGER [TR_' + @file_creator_table + '_Insert]'
		EXEC (@sql)

		SET @sql = 'CREATE TRIGGER [dbo].[TR_' + @file_creator_table + '_Update]
						ON [dbo].[' + @file_creator_table + ']
					 AFTER UPDATE
						AS

					UPDATE ' + @file_creator_table + '
					   SET ModifiedBy	= SUSER_NAME()
						  ,ModifiedDate = GETDATE()
					  FROM Inserted I
					 WHERE I.RecordID = ' + @file_creator_table + '.RecordID'

		EXEC (@sql)

		SET @sql = 'ALTER TABLE [dbo].[' + @file_creator_table + '] ENABLE TRIGGER [TR_' + @file_creator_table + '_Update]'
		EXEC (@sql)

		FETCH NEXT FROM Tables_Cursor
		 INTO  @portal_table, @file_creator_table

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