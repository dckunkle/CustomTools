/**************************************************************************************************
Name:       spConfig_SetupDataTable
Purpose:    Build a table definition given a screen gid and the table name

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_SetupDataTable 'BenefitStrategy', 'prBenefitStrategyAdd', 21, 'Add'
EXEC spConfig_SetupDataTable 'BenefitRuleVariation', 'prBenefitPlanAdd', 50, 'Add'
EXEC spConfig_SetupDataTable 'PlanStrategy','prPlanStrategyNameAdd', 123, 'Add'
EXEC spConfig_SetupDataTable 'CopaySchedule','prScheduleNameAddModWrapper', 20, 'Add'
EXEC spConfig_SetupDataTable 'CopayScheduleVariation','prCopayScheduleAddModify', 40, 'Add'
EXEC spConfig_SetupDataTable 'SuperNetwork','prNet_SuperNet_AddModify', 29, 'Add'
EXEC spConfig_SetupDataTable 'CodeLimitation','prEntityStrategyAdd', 20, 'Add'

EXEC spConfig_SetupDataTable 'CopayLevel','prEntityStrategyAdd', 20, 'Add'
EXEC spConfig_SetupDataTable 'CopayLevelVariation','prCopayStrategyVarAdd', 39, 'Add'

EXEC spConfig_SetupDataTable 'PriceStrategy','prEntityStrategyAdd', 20, 'Add'
EXEC spConfig_SetupDataTable 'PayerCompassEditCodeRelations','prDetailRuleNameAdd', 18, 'Add'
EXEC spConfig_SetupDataTable 'RemarkCodes','prProcessingPolicyAdd_Modify', 52, 'Add'
EXEC spConfig_SetupDataTable 'BenefitClass','prBenefitClassAddModify', 27, 'Add'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_SetupDataTable
     (@method			VARCHAR(100)
	 ,@procedure		VARCHAR(100)
	 ,@parameters		INT
	 ,@load_from		VARCHAR(20))
AS
BEGIN

SET NOCOUNT ON

DECLARE @table_name		VARCHAR(128)	= ''
       ,@sql			VARCHAR(8000)	= ''
       ,@sql_columns	VARCHAR(8000)	= ''
       ,@load_id		INT				= 0
	   ,@add_id			INT				= 0

	   ,@column_name	VARCHAR(128)
	   ,@column_type	VARCHAR(100)
	   ,@column_length	INT

--*************************************************************************************************
-- Create a table that will be used to construct the data table
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

CREATE TABLE #column_names
      (column_order			INT
	  ,column_name			VARCHAR(200)
	  ,column_type			VARCHAR(100)
	  ,column_length		INT)

--*************************************************************************************************
-- Find the columns that will be part of the data table
--*************************************************************************************************
IF @load_from = 'Add'
	BEGIN

		SELECT @add_id				= AA.AddID
		  FROM cfg.ActionAdd		AA
		 WHERE AA.MethodName		= @method
		   AND AA.CoreProcedure		= @procedure
		   AND AA.ParameterCount	= @parameters

		PRINT @add_id
		INSERT INTO #column_names
			  (column_order
			  ,column_name
			  ,column_type
			  ,column_length)
		SELECT AAD.ParameterOrder
			  ,AAD.FieldName
			  ,AAD.DataType
			  ,AAD.DataLength
		  FROM cfg.ActionAddDetail	AAD
		 WHERE AAD.AddID			= @add_id
		   AND AAD.FieldName		<> ''

		SELECT @table_name		= C.TableName
		  FROM cfg.Catalog		C
		 WHERE C.MethodName		= @method

	END

IF @load_from = 'Load'
	BEGIN

		SELECT @load_id				= AL.LoadID
		  FROM cfg.ActionLoad		AL
		 WHERE AL.MethodName		= @method
		   AND AL.CoreProcedure		= @procedure
		   AND AL.FieldCount		= @parameters

		PRINT @load_id
		INSERT INTO #column_names
				(column_order
				,column_name
				,column_type
				,column_length)
		SELECT ALD.ColumnOrder
				,ALD.ColumnName
				,ALD.DataType
				,ALD.DataLength
			FROM cfg.ActionLoadDetail ALD
			WHERE ALD.LoadID			= @load_id
			AND ALD.LoadColumn		= 1

		SELECT @table_name		= C.TableName
			FROM cfg.Catalog		C
			WHERE C.MethodName		= @method
		 SELECT * FROM #column_names

	END
--*************************************************************************************************
-- Loop through the fields and build the SQL to add them to the table
--*************************************************************************************************
DECLARE Column_Cursor CURSOR FOR
SELECT column_name
      ,column_type
	  ,column_length
  FROM #column_names
 ORDER BY column_order

  OPEN Column_Cursor
 FETCH NEXT FROM Column_Cursor
  INTO @column_name, @column_type, @column_length

WHILE @@FETCH_STATUS = 0
	BEGIN

		PRINT @column_name
		SELECT @sql_columns = @sql_columns + ',[' + @column_name + '] ' + @column_type + CASE WHEN @column_type = 'int' THEN ''
		                                                                                      ELSE '(' + CONVERT(VARCHAR(10), @column_length) + ')'
																						  END + ' NULL'
		FETCH NEXT FROM Column_Cursor
         INTO @column_name, @column_type, @column_length

	END

CLOSE Column_Cursor
DEALLOCATE Column_Cursor

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
SET @sql = 'IF OBJECT_ID(''[data].[' + @table_name + ']'', ''U'') IS NOT NULL BEGIN DROP TABLE [data].[' + @table_name + '] END'
EXEC(@sql)

SET @sql = 'CREATE TABLE [data].[' + @table_name + '](
				   [ConfigurationID]					varchar(200)		NULL
				  ,[ParentID]							varchar(200)		NULL '

				 + @sql_columns +

				 ',[Action]							    VARCHAR(20)			NULL
				  ,[Status]								varchar(5)			NULL
				  ,[CreatedBy]							varchar(50)			NULL
				  ,[CreatedDate]						datetime			NULL
				  ,[ModifiedBy]							varchar(50)			NULL
				  ,[ModifiedDate]						datetime			NULL
				  ,[RecordID]							int IDENTITY(1,1)	NOT NULL
					
					CONSTRAINT [PK_' + @table_name + '_RecordID] PRIMARY KEY NONCLUSTERED 
				([RecordID] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) 
				ON [PRIMARY]'
PRINT @sql
ExEC (@sql)

--*************************************************************************************************
-- Create constraints and indexes
--*************************************************************************************************
SET @sql = 'ALTER TABLE [data].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_Status]  DEFAULT (''A'') FOR [Status]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [data].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_Action]  DEFAULT (''Add or Modify'') FOR [Action]'
EXEC (@sql)

SET @sql = 'CREATE CLUSTERED INDEX [CX_' + @table_name + '] ON [data].[' + @table_name + ']
				   ([ConfigurationID] ASC)
				   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]'
EXEC (@sql)

--*************************************************************************************************
-- Create triggers
--*************************************************************************************************
SET @sql = 'CREATE TRIGGER [data].[TR_' + @table_name + '_Insert]
                ON [data].[' + @table_name + ']
             AFTER INSERT
                AS
                IF UPDATE(RecordID)
					BEGIN

						UPDATE ' + @table_name + '
                            SET CreatedBy		= SUSER_NAME()
                                ,CreatedDate	= GETDATE()
			                    ,ModifiedBy		= SUSER_NAME()
                                ,ModifiedDate	= GETDATE()
			                    
		                    FROM Inserted I
		                    WHERE I.RecordID = ' + @table_name + '.RecordID 
	                END'

EXEC (@sql)

SET @sql = 'ALTER TABLE [data].[' + @table_name + '] ENABLE TRIGGER [TR_' + @table_name + '_Insert]'
EXEC (@sql)

SET @sql = 'CREATE TRIGGER [data].[TR_' + @table_name + '_Update]
                ON [data].[' + @table_name + ']
             AFTER UPDATE
                AS

			UPDATE ' + @table_name + '
			   SET ModifiedBy	= SUSER_NAME()
				  ,ModifiedDate = GETDATE()
			  FROM Inserted I
			 WHERE I.RecordID = ' + @table_name + '.RecordID'

EXEC (@sql)

SET @sql = 'ALTER TABLE [data].[' + @table_name + '] ENABLE TRIGGER [TR_' + @table_name + '_Update]'
EXEC (@sql)
	
--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#field_names') IS NOT NULL
	DROP TABLE #field_names

END 
GO