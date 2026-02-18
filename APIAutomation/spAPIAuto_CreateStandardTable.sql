IF OBJECT_ID('dbo.spAPIAuto_CreateStandardTable') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIAuto_CreateStandardTable AS SELECT 1')
GO

/**************************************************************************************************
Name:       spAPIAuto_GetVariableData
Purpose:    Build a TD_ table to store API requests and responses

Date        User            Change
---------------------------------------------------------------------------------------------
09/08/2020	DK				Original procedure
02/01/2021	DK				Add the RequestType field and default it
10/25/2021	DK				Add StatusCode and TestDescription
03/21/2023  DK				Added override fields to the standard table
06/13/2023	SUS				Standardize field names (Table_Name and Method_Name)across tools
08/01/2023  DK				Disable recreating tables to avoid accidental deletion
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_CreateStandardTable 'TD_SearchClaimMemberHistory'
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIAuto_CreateStandardTable
     (@table_name		VARCHAR(200)
	 ,@recreate_table	BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql			VARCHAR(8000)	
       ,@table_exists	BIT
	   ,@request_method	VARCHAR(50)

--*************************************************************************************************
-- Disable recreating tables (haven't used it in a while and other people are creating tables now)
--*************************************************************************************************
SELECT @recreate_table = 0

--*************************************************************************************************
-- Determine the request type from the fw.Catalog table
--*************************************************************************************************
SELECT @request_method	= ISNULL(C.RequestMethod, 'POST')
  FROM fw.Catalog		C
 WHERE C.Table_Name		= @table_name

--*************************************************************************************************
-- Create the table
--*************************************************************************************************
SET @table_exists = CASE WHEN OBJECT_ID(@table_name) IS NOT NULL THEN 1 ELSE 0 END

IF @recreate_table = 1 AND @table_exists = 1
	BEGIN

		SET @sql ='DROP TABLE ' + @table_name
		EXEC (@sql)

	END


	SET @sql = 'CREATE TABLE [dbo].[' + @table_name + '](
						[TCID]								varchar(100)		NULL
						,[TestDescription]					varchar(1000)		NULL
						,[Version]							varchar(50)			NULL
						,[VersionMinor]						varchar(50)			NULL
						,[RequestMethod]					varchar(50)			NULL
						,[Request]							varchar(max)		NULL
						,[StatusCode]						int					NULL
						,[Response]							varchar(max)		NULL
						,[ActiveTestCase]					varchar(5)			NULL
						,[CreatedBy]						varchar(50)			NULL
						,[CreatedDate]						date				NULL
						,[ModifiedBy]						varchar(50)			NULL
						,[ModifiedDate]						date				NULL
						,[TR_Team]							varchar(100)		NULL
						,[RecordID]							int IDENTITY(1,1)	NOT NULL
						,[EnterpriseIDOverride]				varchar(20)			NULL
						,[SystemNameOverride]				varchar(20)			NULL
						,[APIKeyOverride]					varchar(200)		NULL
					
						CONSTRAINT [PK_' + @table_name + '_RecordID] PRIMARY KEY NONCLUSTERED 
					([RecordID] ASC)
					WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) 
					ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]'

	IF @table_exists = 0 OR @recreate_table = 1
		BEGIN
			EXEC (@sql)
		END
	ELSE
		BEGIN
			GOTO SKIP_TRIGGERS
		END

--*************************************************************************************************
-- Create constraints and indexes
--*************************************************************************************************

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_Version]  DEFAULT (''v1'') FOR [Version]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_VersionMinor]  DEFAULT ((0)) FOR [VersionMinor]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_RequestMethod]  DEFAULT (''' + @request_method + ''') FOR [RequestMethod]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_Request]  DEFAULT ('''') FOR [Request]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_Response]  DEFAULT ('''') FOR [Response]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_ActiveTestCase]  DEFAULT (''A'') FOR [ActiveTestCase]'
EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ADD  CONSTRAINT [DF_' + @table_name + '_StatusCode]  DEFAULT (''200'') FOR [StatusCode]'
EXEC (@sql)

SET @sql = 'CREATE CLUSTERED INDEX [CX_' + @table_name + '] ON [dbo].[' + @table_name + ']
				   ([TCID] ASC)
				   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]'
EXEC (@sql)

--*************************************************************************************************
-- Create triggers
--*************************************************************************************************
SET @sql = 'CREATE TRIGGER [dbo].[TR_' + @table_name + '_Insert]
                ON [dbo].[' + @table_name + ']
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

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ENABLE TRIGGER [TR_' + @table_name + '_Insert]'
EXEC (@sql)

SET @sql = 'CREATE TRIGGER [dbo].[TR_' + @table_name + '_Update]
                ON [dbo].[' + @table_name + ']
             AFTER UPDATE
                AS

			UPDATE ' + @table_name + '
			   SET ModifiedBy	= SUSER_NAME()
				  ,ModifiedDate = GETDATE()
			  FROM Inserted I
			 WHERE I.RecordID = ' + @table_name + '.RecordID'

EXEC (@sql)

SET @sql = 'ALTER TABLE [dbo].[' + @table_name + '] ENABLE TRIGGER [TR_' + @table_name + '_Update]'
EXEC (@sql)

SKIP_TRIGGERS:

END
GO