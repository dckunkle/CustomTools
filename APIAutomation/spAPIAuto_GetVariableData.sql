IF OBJECT_ID('dbo.spAPIAuto_GetVariableData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIAuto_GetVariableData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spAPIAuto_GetVariableData
Purpose:    Determine the variable values that will be used in the Request object

Date        User            Change
---------------------------------------------------------------------------------------------
09/04/2020	DK				Original procedure
11/02/2020	DK				Add usual parameters
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_GetVariableData 1, 'TD_AdjudicationTrialAdjudicationTrialAdjudicateByFileSid', '10602'
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIAuto_GetVariableData
     (@record_id		INT
	 ,@table_name		VARCHAR(200)
	 ,@enterprise_id	VARCHAR(200)
	 ,@record_count		INT				= 0		OUTPUT
	 ,@status			INT				= 0		OUTPUT
	 ,@message			VARCHAR(8000)	= ''	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql						VARCHAR(8000)
       ,@endpoint					VARCHAR(4000)
	   ,@service_name				VARCHAR(200)
	   ,@err_num					INT				= 0
	   ,@err_msg					VARCHAR(4000)	= 'Success'

       ,@minor_version_column_id	INT
       ,@request_column_id			INT

	   ,@field_name					VARCHAR(200)
	   ,@field_value				VARCHAR(2000)
	   ,@variable_name				VARCHAR(200)
	   ,@variable_value				VARCHAR(4000)
	   ,@default_value				VARCHAR(4000)

	   ,@server_name				VARCHAR(200)
	   ,@database_name				VARCHAR(200)
	   ,@cmd						VARCHAR(8000)

--*************************************************************************************************
-- Gather Request variable search fields and their values 
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#request_data') IS NOT NULL
	DROP TABLE #request_data

CREATE TABLE #request_data
      (field_name		VARCHAR(200)
	  ,field_value		VARCHAR(4000))

-- The search fields, if there are any, will be between the VersionMinor and Request fields
SELECT @minor_version_column_id	= C.column_id
  FROM sys.columns				C
  JOIN sys.tables				T
    ON C.object_id				= T.object_id
 WHERE T.name					= @table_name
   AND C.name					= 'RequestMethod'

SELECT @request_column_id		= C.column_id
  FROM sys.columns				C
  JOIN sys.tables				T
    ON C.object_id				= T.object_id
 WHERE T.name					= @table_name
   AND C.name					= 'Request'

INSERT INTO #request_data
      (field_name)
SELECT C.name
  FROM sys.columns				C
  JOIN sys.tables				T
    ON C.object_id				= T.object_id
 WHERE T.name					= @table_name
   AND C.column_id				> @minor_version_column_id
   AND C.column_id				< @request_column_id

-- Loop through any fields that were found and gather the values that the user has entered
DECLARE User_Data_For_Request CURSOR FOR
 SELECT field_name
   FROM #request_data

   OPEN User_Data_For_Request
  FETCH NEXT FROM User_Data_For_Request
   INTO @field_name

  WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @sql = 'UPDATE #request_data 
		                  SET field_value = (SELECT ISNULL(' + @field_name + ', '''') FROM ' + @table_name + ' WHERE RecordID = ' + CONVERT(VARCHAR(200), @record_id) + ') 
						WHERE field_name = ''' + @field_name + ''''
		EXEC (@sql) 
		
		FETCH NEXT FROM User_Data_For_Request
		 INTO @field_name

	END

CLOSE User_Data_For_Request
DEALLOCATE User_Data_For_Request

--*************************************************************************************************
-- Use the values that the user has entered to determine the GID values to use in the Request
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#request_variables') IS NOT NULL
	DROP TABLE #request_variables

CREATE TABLE #request_variables
      (record_id		INT
	  ,endpoint			VARCHAR(4000)
	  ,variable_name	VARCHAR(200)
	  ,value_sql		VARCHAR(8000)
	  ,variable_value	VARCHAR(4000)
	  ,default_value	VARCHAR(4000))

SELECT @endpoint		= C.Endpoint
      ,@service_name	= C.ServiceName
  FROM fw.Catalog		C
 WHERE Table_Name		= @table_name

 INSERT INTO #request_variables
       (record_id
	   ,endpoint
	   ,value_sql
	   ,variable_name
	   ,default_value)
SELECT @record_id
      ,@endpoint
	  ,RV.SQL
	  ,RV.VariableName
	  ,RV.DefaultValue
  FROM fw.RequestVariable	RV
 WHERE RV.Endpoint			= @endpoint
   AND RV.ServiceName       = @service_name

--*************************************************************************************************
-- For each of the Request variables, create dynamic SQL and run it using SQLCMD to return the value
--*************************************************************************************************
SELECT @server_name				= EL.ServerName
      ,@database_name			= EL.DatabaseName
  FROM fw.EnterpriseIDLookup	EL
 WHERE EL.EnterpriseID			= @enterprise_id

DECLARE Request_Variables CURSOR FOR
 SELECT value_sql
       ,variable_name
	   ,default_value
   FROM #request_variables

   OPEN Request_Variables
  FETCH NEXT FROM Request_Variables
   INTO @sql, @variable_name, @default_value

  WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE User_Data CURSOR FOR
		 SELECT field_name
		       ,field_value
		   FROM #request_data

		   OPEN User_Data
          FETCH NEXT FROM User_Data
           INTO @field_name, @field_value

		  WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT @field_name = '~' + @field_name + '~'
				SELECT @sql = REPLACE(@sql, @field_name, @field_value)

				FETCH NEXT FROM User_Data
				 INTO @field_name, @field_value

			END

		CLOSE User_Data
		DEALLOCATE User_Data

		SET @sql = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@sql,CHAR(13) + CHAR(10), ''), CHAR(9), ' '), '  ', ' '), '  ', ' '), '  ', ' ')
		SET @sql = 'USE ' + @database_name + ' ' + @sql
		SET @cmd = 'SQLCMD -S ' + @server_name + ' -Q "' + @sql + '"'

		PRINT @cmd

		IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
			DROP TABLE #cmd_results

		CREATE TABLE #cmd_results
			  (results		VARCHAR(MAX)
			  ,result_id	INT				IDENTITY(1,1))

		INSERT INTO #cmd_results
		EXEC master.sys.xp_cmdshell @cmd

		SELECT @variable_value	= RTRIM(LTRIM(CR.results))
		  FROM #cmd_results		CR
		 WHERE CR.result_id		= 4

		UPDATE #request_variables
		   SET variable_value = CASE WHEN ISNULL(@variable_value, '') = '' THEN @default_value ELSE @variable_value END
		 WHERE variable_name  = @variable_name

		FETCH NEXT FROM Request_Variables
		 INTO @sql, @variable_name, @default_value

	END

CLOSE Request_Variables
DEALLOCATE Request_Variables

--*************************************************************************************************
-- Provide results for automation to do the substitutions
--*************************************************************************************************
SELECT @record_count = COUNT(*) 
  FROM #request_variables

SELECT @record_id			AS RecordID
      ,@table_name			AS TableName
	  ,RV.variable_name
	  ,RV.variable_value
  FROM #request_variables	RV

SELECT @status	= @err_num
      ,@message	= @err_msg

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#request_data') IS NOT NULL
	DROP TABLE #request_data

IF OBJECT_ID('tempdb.dbo.#request_variables') IS NOT NULL
	DROP TABLE #request_variables

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

END
GO