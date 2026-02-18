IF OBJECT_ID('dbo.spFCAuto_CreateFile') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_CreateFile AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_CreateFile
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
06/11/2020	DK				Correct filename delimiter logic for empty string
02/05/2021	DK				Add support for Core environments which use multiple instances
                            on the same server
06/15/2021	DK				Portal Extract includes Type fields, therefore needed to change
                            the column search to look for TestType field for PE
07/19/2021  DK				Properly report error when BCP is not able to write a file
09/12/2021	DK				Fix issue when there is a field called Type in the table (ProviderAccreditation)
10/17/2022	DK				Changes to support moving files to Azure storage
03/02/2023	DK				Added support for Secondary Demographics files
05/30/2023	DK				Added support for Risk Score files
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateFile 'UAT%', 'UAT-TestCase-1000', 'ImportXLSXDiagnosisCode', 'aldqadbqr06', '2222'
EXEC spFCAuto_CreateFile '100-Config%', 'ExportMemberFIles', 'SomeOtherFile', 'aldqrdb02', '22'
EXEC spFCAuto_CreateFile 'Test%', 'MemberHold', 'MemberHold', 'aldqrdb02', '22'
EXEC spFCAuto_CreateFile 'PTL-CORE-DATA%', 'PortalExtractProviderAccrediatation', 'PortalExtractMessageInNo', 'aldqadbqr06', '22'
EXEC spFCAuto_CreateFile 'Setup%', 'VendorClaims', 'VendorClaimsDelimited', 'aldqadbqr03', '22'
EXEC spFCAuto_CreateFile 'EB-File-RiskScores-Add%', 'EB-File-RiskScores-Add', 'RiskScores', 'aldqrdb09', '22'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_CreateFile
     (@i_tcid			VARCHAR(200)
	 ,@i_test_case		VARCHAR(200)
	 ,@i_method_name	VARCHAR(400)
	 ,@server			VARCHAR(200)
	 ,@i_log_id			INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @test_case			VARCHAR(200)
       ,@method_name		VARCHAR(400)
       ,@tcid				VARCHAR(200)
	   ,@log_id				INT
	   ,@table_name			VARCHAR(200)
	   ,@database			VARCHAR(200)

	   -- Used to build the filename of the file being created
	   ,@filename			VARCHAR(8000)
	   ,@filename_delimiter	VARCHAR(1)
	   ,@export_folder		VARCHAR(1000)
	   ,@folder				VARCHAR(8000)
	   ,@file_extension		VARCHAR(100)
	   ,@filename_prefix	VARCHAR(200)
	   ,@file_with_path		VARCHAR(4000)

	   -- Used to build the date portion of the file, if required
	   ,@include_date		VARCHAR(10)
	   ,@file_date			VARCHAR(100)
	   ,@file_date_format	VARCHAR(100)	= 'YYYYMMDD'

	   -- Used to build the time portion of the file, if required
	   ,@include_time		VARCHAR(10)
	   ,@file_time			VARCHAR(100)
	   ,@file_time_format	VARCHAR(100)	= 'HHMMSS'

	   ,@datetime_stamp		VARCHAR(50)

	   -- Used to determine which fields to include in the file
	   ,@Type_location		INT
	   ,@Active_location	INT

	   -- Used when calling BCP
	   ,@file_type			VARCHAR(100)
	   ,@field_delimiter	VARCHAR(10)
	   ,@record_delimiter	VARCHAR(10)
	   ,@text_qualifier		VARCHAR(10)
	   ,@sql				VARCHAR(8000)
	   ,@table_sql			VARCHAR(8000)
	   ,@cmd				VARCHAR(8000)
	   ,@column_name		VARCHAR(200)
	   ,@include_header		BIT
	   ,@headers			VARCHAR(8000)

	   -- Used for error reporting
	   ,@err_num			INT				= 0
	   ,@err_msg			VARCHAR(4000)	= 'File created successfully.'
	   ,@status				VARCHAR(100)	= 'Success'
	   ,@records_copied		INT				= 0
	   ,@expected_records	INT				= 0

	   -- Used for Jenkins log
	   ,@filename_char		VARCHAR(200)
	   ,@method_char		VARCHAR(200)
	   ,@folder_char		VARCHAR(200)
	   ,@expected_char		VARCHAR(10)
	   ,@copied_char		VARCHAR(10)

	   -- Support Core environments
	   ,@instance_name		VARCHAR(200)
	   ,@batch_folder		VARCHAR(200)

	   -- Azure support variables
	   ,@azure				BIT				= 0
	   ,@layer				VARCHAR(50)
	   ,@abbreviation		VARCHAR(50)
	   ,@container			VARCHAR(4000)
	   ,@blob				VARCHAR(4000)
	   ,@storage			VARCHAR(100)
	   ,@key				VARCHAR(100)	

	   -- Secondary Demographics
	   ,@secondary_demographics	BIT			= 0
	   ,@risk_score				BIT			= 0
	   ,@vendor					VARCHAR(20)
	   ,@sd_file_date			VARCHAR(20)

SELECT @test_case		= @i_test_case
      ,@method_name		= @i_method_name
      ,@tcid			= @i_tcid
	  ,@log_id			= @i_log_id

--Adjust server name for Core environments
SELECT @instance_name	= @server
SELECT @server			= dbo.fnFCAuto_GetServerName(@instance_name)
SELECT @database		= dbo.fnFCAuto_GetDatabaseName(@instance_name)

--***************************************************************************************************
-- Create temp tables to help gather data
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

CREATE TABLE #column_names
      (field_name	VARCHAR(200)
	  ,field_order	INT)

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

CREATE TABLE #cmd_results
		(results	VARCHAR(8000)
		,result_id	INT				IDENTITY(1,1))

--***************************************************************************************************
-- Get details about te that needs to be created
--***************************************************************************************************
SELECT @filename			= ISNULL(C.filename, '')
      ,@filename_delimiter	= ISNULL(C.filename_delimiter, '')
      --,@include_date		= ISNULL(C.date_in_filename, '')
	  --,@include_time		= ISNULL(C.time_in_filename, '')
	  ,@file_type			= ISNULL(C.file_type, '')
	  ,@field_delimiter     = ISNULL(C.field_delimiter, '')
	  ,@record_delimiter	= ISNULL(C.record_delimiter, '\l') -- Default the record delimiter to linefeed
	  ,@text_qualifier		= ISNULL(C.text_qualifier, '')
	  ,@file_extension		= ISNULL(C.file_extension, '')
	  ,@table_name			= ISNULL(C.table_name, '')
	  ,@export_folder		= ISNULL(C.export_folder, '')
	  ,@datetime_stamp		= ISNULL(C.datetime_stamp, '')
	  ,@include_header		= ISNULL(C.include_header, 0)
  FROM fw.Catalog		C
 WHERE C.Method_Name	= @method_name

--***************************************************************************************************
-- Special Setup for Secondary Demographics files
--***************************************************************************************************
IF @method_name = 'SecondaryDemographics'
	BEGIN
		
		SELECT @secondary_demographics	= 1
		      ,@table_name				= 'TD_SecondaryDemographicsDetail'

		SELECT @vendor					= SD.Vendor
			  ,@sd_file_date			= SD.FileDate
		  FROM TD_SecondaryDemographics	SD
		 WHERE TCID LIKE @i_tcid

	END

IF @method_name = 'RiskScores'
	BEGIN SELECT @risk_score = 1 END

--***************************************************************************************************
-- Validate the values to make sure a file can be built
--***************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 Method_Name FROM fw.Catalog WHERE Method_Name = @method_name)
	BEGIN
		SELECT @err_num	= 100
		      ,@err_msg	= 'The method name, ' + @method_name + ', is not defined in the fw.Catalog table. The file cannot be created.'
			  ,@status	= 'Config'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Validate required fields
--***************************************************************************************************
IF @filename = ''
	BEGIN
		SELECT @err_num	= 101
		      ,@err_msg	= 'The filename field is required field and cannot be blank. Please review the filename field, for the Method_Name, ' + @method_name + ', in the di_Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @file_type = ''
	BEGIN
		SELECT @err_num	= 102
		      ,@err_msg	= 'The file_type field is required field and cannot be blank. Please review the file_type field, for the Method_Name, ' + @method_name + ', in the di_Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @table_name = ''
	BEGIN
		SELECT @err_num	= 103
		      ,@err_msg	= 'The table_name field is a required field and cannot be blank. Please review the table_name field, for the Method_Name, ' + @method_name + ', in the di_Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @export_folder = ''
	BEGIN
		SELECT @err_num	= 104
		      ,@err_msg	= 'The export_folder field is a required field and cannot be blank. Please review the export_folder field, for the Method_Name, ' + @method_name + ', in the di_Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @file_type = 'delimited' AND @field_delimiter = ''
	BEGIN
		SELECT @err_num	= 105
		      ,@err_msg	= 'When the file_type is delimited, a field delimiter must be defined in the field_delimiter field.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Build the file name based on the elements provided
--***************************************************************************************************
IF @datetime_stamp <> '' SELECT @datetime_stamp = @filename_delimiter + FORMAT(GETDATE(), @datetime_stamp)

SELECT @file_date = CASE WHEN @include_date = 'Yes' THEN CASE WHEN @file_date_format = 'YYYYMMDD' THEN @filename_delimiter + CONVERT(VARCHAR(10), GETDATE(), 112)
                                                              ELSE @filename_delimiter + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 102), '.',' ')
														  END
						 ELSE '' 
					END

SELECT @file_time = CASE WHEN @include_time = 'Yes' THEN CASE WHEN @file_date_format = 'HHMMSS' THEN @filename_delimiter + FORMAT(GETDATE(), 'hhmmss') 
                                                              ELSE @filename_delimiter + FORMAT(GETDATE(), 'hhmmss')
														  END
						 ELSE '' 
					END

SELECT @filename_prefix = CASE WHEN RIGHT(@tcid, 1) = '%' THEN LEFT(@tcid, LEN(@tcid) -1)
                               ELSE @tcid
						   END

SELECT @filename_prefix = CASE WHEN @method_name = 'InstamedLockbox' THEN @filename_delimiter + @filename_prefix
                               ELSE ''
						   END

IF @datetime_stamp = ''
	BEGIN
		SELECT @filename = @filename + @filename_prefix + @file_date + @file_time + @file_extension
	END
ELSE
	BEGIN
		SELECT @filename = @filename + @filename_prefix + @datetime_stamp + @file_extension
	END

IF @secondary_demographics = 1
	BEGIN
		SELECT @filename = @vendor + @filename_delimiter + 'MemDemoD' + @filename_delimiter + @sd_file_date + @file_extension
	END
-- Convert the folder name to the fully qualified path
SELECT @folder = CASE WHEN RIGHT(@export_folder,1) = '\' THEN @export_folder ELSE @export_folder + '\' END
      ,@batch_folder = dbo.fnFCAuto_GetFolderName(@instance_name)
SELECT @folder = '\\' + @server + '\' + @batch_folder + '\' + @folder

-- If the destination is Azure storage
IF LEFT(@export_folder, 5) = 'Azure' 
	BEGIN 
		SELECT @folder = 'H:\' + @export_folder + '\'
	          ,@azure = 1 
	END

--***************************************************************************************************
-- Build a list of the fields that need to be exported
--***************************************************************************************************
BEGIN TRY

	SELECT TOP 1
	       @Type_location	= C.column_id + 1
	  FROM sys.columns	C
	  JOIN sys.tables	T
		ON C.object_id	= T.object_id
	 WHERE 1 = CASE WHEN T.name LIKE 'TD_PortalExtract%' AND T.name = @table_name AND C.name = 'TestType' THEN 1
	                WHEN T.name	= @table_name AND C.name = 'Type' THEN 1
					ELSE 0
				END
	ORDER BY c.column_id ASC

	SELECT @Active_location	= C.column_id - 1
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
	   AND C.column_id	BETWEEN @Type_location AND @Active_location	-- Only use the fields between the TCID field and ActiveTestCase

	-- Loop through the columns building the correct SQL
	DECLARE Fields_Cursor CURSOR FOR
	 SELECT field_name
	   FROM #column_names	C
	  ORDER BY field_order
  
	  OPEN Fields_Cursor
	 FETCH NEXT FROM Fields_Cursor
	  INTO @column_name

	SELECT @sql = 'SELECT '
	SELECT @table_sql = 'CREATE TABLE ##expected_records ('
	SELECT @headers	= 'SELECT '

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SELECT @sql = @sql + '[' + @column_name + '], '
			SELECT @table_sql = @table_sql + '[' + @column_name + '] VARCHAR(8000), '
			SELECT @headers = @headers + '''' + @column_name + ''', ' 

			FETCH NEXT FROM Fields_Cursor
			  INTO @column_name
		END

	CLOSE Fields_Cursor
	DEALLOCATE Fields_Cursor

	SELECT @sql = LEFT(@sql, LEN(@sql) - 1)	-- Drop the last comma
	SELECT @sql = @sql + ' FROM dbo.' + @table_name + ' WHERE TCID LIKE (''' + @tcid + ''') AND ActiveTestCase = ''A'''
	SELECT @headers = LEFT(@headers, LEN(@headers) - 1)

	IF @include_header = 1
		BEGIN
			SELECT @sql = @headers + ' UNION ALL ' + @sql
		END

	--***************************************************************************************************
	-- Select the results of the query to get the expected number of records for later use
	--***************************************************************************************************
	IF OBJECT_ID('tempdb.dbo.##expected_records') IS NOT NULL
		DROP TABLE ##expected_records

	SELECT @table_sql = LEFT(@table_sql, LEN(@table_sql) - 1) + ')'
	  EXEC (@table_sql)

	INSERT INTO ##expected_records
	  EXEC (@sql)

	SELECT @expected_records = COUNT(*)
	  FROM ##expected_records

	IF OBJECT_ID('tempdb.dbo.##expected_records') IS NOT NULL
		DROP TABLE ##expected_records

	--***************************************************************************************************
	-- Call BCP to create a delimited file
	--***************************************************************************************************
	IF @file_type = 'delimited'
		BEGIN
			SELECT @cmd = 'bcp "' + @sql + '" queryout "' + @folder + @filename + '" -T -c -S wqadbhpauto01.chicago.local -d CoreFileCreator'
			SELECT @cmd = @cmd + CASE WHEN @file_type = 'delimited' THEN ' -t "' + @field_delimiter + '"' ELSE '' END
			SELECT @cmd = @cmd + ' -r ' + @record_delimiter 

			INSERT INTO #cmd_results
			  EXEC master.sys.xp_cmdshell @cmd

				-- Determine if the copy was successful or not and then log the details
			EXEC spFCAuto_GetBCPResults @err_num OUTPUT, @err_msg OUTPUT, @records_copied OUTPUT
			IF @err_num <> 0 BEGIN SET @status = 'Error' END
		END

	--***************************************************************************************************
	-- Call PowerShell to create the Import Spreadsheet file
	--***************************************************************************************************
	IF @file_type = 'import'
		BEGIN
			TRUNCATE TABLE #cmd_results

			SELECT @cmd = '"C:\PowerShell\Invoke-ImportSpreadsheet.ps1" '
			SELECT @cmd = @cmd + '-Server "'   + ISNULL(@server, '') + '" '
			SELECT @cmd = @cmd + '-Database "' + ISNULL(@database, '') + '" '
			SELECT @cmd = @cmd + '-Method "'   + ISNULL(@method_name, '') + '" '
			SELECT @cmd = @cmd + '-Pattern "'  + ISNULL(@tcid, '') + '" '
			SELECT @cmd = @cmd + '-Filename "' + ISNULL(@filename, '') + '" '
			SELECT @cmd = @cmd + '-Path '      + ISNULL(@folder, '') + ' '

			SELECT @cmd = 'powershell.exe -ExecutionPolicy "ByPass" -File ' + @cmd

			SELECT @records_copied = @expected_records

			INSERT INTO #cmd_results
			  EXEC master.sys.xp_cmdshell @cmd
		END

	--***************************************************************************************************
	-- Call PowerShell to move the file to Blob Storage
	--***************************************************************************************************
	IF @azure = 1
		BEGIN
			TRUNCATE TABLE #cmd_results

			SELECT @layer					= layer
			      ,@abbreviation			= S.server_abbreviation
			  FROM dbo.QAServer				S
			 WHERE server_name				= @server

			SELECT @container				= AC.Container
			      ,@blob					= AC.LocationName + CASE WHEN @secondary_demographics = 1 THEN '/' + UPPER(@vendor) + '/Staging'
				                                                     WHEN @risk_score = 1 THEN '/Staging'
																	 ELSE '' 
																 END + '/' + @filename
			  FROM fw.AzureContainer		AC
			 WHERE AC.MethodName			= @method_name
			   AND AC.ServerAbbreviation	= @abbreviation

			SELECT @storage					= S.StorageAccount
			      ,@key						= S.StorageKey
			  FROM fw.AzureStorage			S
			 WHERE S.MethodName				= @method_name
			   AND S.Layer					= @layer

			--SELECT @cmd = '"C:\PowerShell\Move-FileToJenkins.ps1" '
			--SELECT @cmd = @cmd + '-Filename "'			+ @folder + @filename + '" '
			--SELECT @cmd = @cmd + '-Container "'			+ ISNULL(@container, '') + '" '
			--SELECT @cmd = @cmd + '-Blob "'				+ ISNULL(@blob, '') + '" '
			--SELECT @cmd = @cmd + '-StorageAccount "'	+ ISNULL(@storage, '') + '" '
			--SELECT @cmd = @cmd + '-StorageKey "'		+ ISNULL(@key, '') + '" '

			--SELECT @cmd = 'powershell.exe -File ' + @cmd ---ExecutionPolicy "ByPass"
			--SELECT @records_copied = @expected_records
			--PRINT @cmd

			SELECT @file_with_path = @folder + @filename

			EXEC spFCAuto_CopyFileToAzure @filename			= @file_with_path
			                             ,@container		= @container
										 ,@blob				= @blob
										 ,@storage_account	= @storage
										 ,@storage_key		= @key

		END
	--***************************************************************************************************
	-- Output the results to the Jenkins console
	--***************************************************************************************************

	SELECT @filename_char	= LEFT(LEFT(@filename, 35) + SPACE(35), 35)
	      ,@method_char		= LEFT(LEFT(@method_name, 50) + SPACE(50), 50)
		  ,@folder_char		= LEFT(LEFT(@export_folder, 55) + SPACE(55), 55)
		  ,@expected_char	= LEFT(CONVERT(VARCHAR(4), @expected_records) + SPACE(4), 4)
		  ,@copied_char		= LEFT(CONVERT(VARCHAR(4), @records_copied) + SPACE(4), 4)

	PRINT '        ' + @method_char + ' ' + @filename_char + ' ' + @expected_char + ' ' + @copied_char + ' ' + @folder_char

	--IF @err_num = 100 SET @err_num = 0
	EXEC spFCAuto_LogEvent @log_id, @test_case, @method_name, @filename, @folder, @expected_records, @records_copied, @status,@err_num,@err_msg

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()
		  ,@status	= 'Error'

	GOTO LOG_ERROR

END CATCH

--***************************************************************************************************
-- Log an error and exit
--***************************************************************************************************
LOG_ERROR:
IF @err_num <> 0 EXEC spFCAuto_LogEvent @log_id, @test_case, @method_name, @filename, @folder, @expected_records, @records_copied, @status,@err_num,@err_msg

IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

END
GO