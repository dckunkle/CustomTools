/**************************************************************************************************
Name:       spFCAuto_CreateFileFixed
Purpose:    Used to export a fixed length file

Date        User            Change
---------------------------------------------------------------------------------------------
06/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateFileFixed 'Setup%', 'Setup', 'VendorAccumulator', 'aldqadbqr06', '22'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_CreateFileFixed
     (@i_tcid			VARCHAR(200)
	 ,@i_test_case		VARCHAR(200)
	 ,@i_method_name	VARCHAR(400)
	 ,@server			VARCHAR(200)
	 ,@i_log_id			INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @test_case			VARCHAR(200)	= @i_test_case
       ,@method_name		VARCHAR(400)	= @i_method_name
       ,@tcid				VARCHAR(200)	= @i_tcid
	   ,@log_id				INT				= @i_log_id

	   ,@filename			VARCHAR(8000)
	   ,@folder				VARCHAR(8000)
	   ,@table_name			VARCHAR(200)
	   ,@fixed_file_id		INT

	   -- Used to determine which fields to include in the file
	   ,@Type_location		INT
	   ,@Active_location	INT

	   -- Used when calling BCP
	   ,@file_type			VARCHAR(100)
	   ,@field_delimiter	VARCHAR(10)
	   ,@record_delimiter	VARCHAR(10)
	   ,@text_qualifier		VARCHAR(10)
	   ,@sql				VARCHAR(MAX)
	   ,@table_sql			VARCHAR(MAX)
	   ,@cmd				VARCHAR(8000)
	   ,@column_name		VARCHAR(200)

	   -- Used for error reporting
	   ,@err_num			INT				= 0
	   ,@err_msg			VARCHAR(4000)	= 'File created successfully.'
	   ,@status				VARCHAR(100)	= 'Success'
	   ,@records_copied		INT				= 0
	   ,@expected_records	INT				= 0

	   -- Used for Jenkins log
	   ,@export_folder		VARCHAR(8000)
	   ,@filename_char		VARCHAR(200)
	   ,@method_char		VARCHAR(200)
	   ,@folder_char		VARCHAR(200)
	   ,@expected_char		VARCHAR(10)
	   ,@copied_char		VARCHAR(10)

--***************************************************************************************************
-- Create temp tables to help gather data
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#column_names') IS NOT NULL
	DROP TABLE #column_names

CREATE TABLE #column_names
      (field_name		VARCHAR(200)
	  ,field_order		INT
	  ,fixed_file_id	INT
	  ,field_length		INT
	  ,justification	VARCHAR(50)
	  ,fill_character	VARCHAR(5))

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

CREATE TABLE #cmd_results
		(results	VARCHAR(8000)
		,result_id	INT				IDENTITY(1,1))

--***************************************************************************************************
-- Get the filename and folder where the file will be created
--***************************************************************************************************
EXEC spFCAuto_CreateAndValidateFilename @tcid, @method_name, @server, @folder OUTPUT, @filename OUTPUT, @err_num OUTPUT, @err_msg OUTPUT

IF @err_num <> 0
	BEGIN
		SELECT @status = 'Error'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Get details about te that needs to be created
--***************************************************************************************************
SELECT @file_type			= ISNULL(C.file_type, '')
	  ,@field_delimiter     = ISNULL(C.field_delimiter, '')
	  ,@record_delimiter	= ISNULL(C.record_delimiter, '\l') -- Default the record delimiter to linefeed
	  ,@text_qualifier		= ISNULL(C.text_qualifier, '')
	  ,@table_name			= ISNULL(C.table_name, '')
	  ,@export_folder		= ISNULL(C.export_folder, '')
	  ,@fixed_file_id		= ISNULL(C.fixed_file_id, 0)
  FROM fw.Catalog		C
 WHERE C.Method_Name	= @method_name

--***************************************************************************************************
-- Validate the values to make sure a file can be built
--***************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 Method_Name FROM fw.Catalog WHERE Method_Name = @method_name)
	BEGIN
		SELECT @err_num	= 100
		      ,@err_msg	= 'The method name, ' + @method_name + ', is not defined in the fw.Catalog table. The file cannot be created.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Validate required fields
--***************************************************************************************************
IF @file_type = ''
	BEGIN
		SELECT @err_num	= 102
		      ,@err_msg	= 'The file_type field is a required field and cannot be blank. Please review the file_type field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @table_name = ''
	BEGIN
		SELECT @err_num	= 103
		      ,@err_msg	= 'The table_name field is a required field and cannot be blank. Please review the table_name field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
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

IF @file_type = 'fixed' AND @fixed_file_id = 0
	BEGIN
		SELECT @err_num	= 105
		      ,@err_msg	= 'When the file_type is fixed width, a fixed file ID must be defined in the fixed_file_id field.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
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

	UPDATE CN
	   SET fixed_file_id		= @fixed_file_id
	      ,field_length			= FWD.FieldLength
	      ,justification		= FWD.Justification
	      ,fill_character		= FWD.FillCharacter
	 FROM #column_names			CN
	 JOIN fw.FixedWidthDetail	FWD
	   ON CN.field_name			= FWD.FieldName
    WHERE FWD.FileID			= @fixed_file_id

--***************************************************************************************************
-- Loop through the columns building the correct SQL
--***************************************************************************************************
	DECLARE @field_length		INT
	       ,@justification		VARCHAR(10)
		   ,@fill_character		VARCHAR(10)
		   ,@fill				VARCHAR(200)

	DECLARE Fields_Cursor CURSOR FOR
	 SELECT field_name
	       ,field_length
		   ,justification
		   ,fill_character
	   FROM #column_names	C
	  ORDER BY field_order
  
	  OPEN Fields_Cursor
	 FETCH NEXT FROM Fields_Cursor
	  INTO @column_name, @field_length, @justification, @fill_character

	SELECT @sql = 'INSERT INTO wrk.FixedLength (log_id, record_id, fixed_data) SELECT ' + CONVERT(VARCHAR(10), @log_id) + ', RecordID, '
	SELECT @table_sql = 'CREATE TABLE ##expected_records ('

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SELECT @fill = CASE WHEN @fill_character = 'Space' THEN 'SPACE(' + CONVERT(VARCHAR(10), @field_length) + ')'
			                    WHEN @fill_character = 'Zero'  THEN 'REPLACE(SPACE(' + CONVERT(VARCHAR(10), @field_length) + '), '' '', ''0'')'
							END

			SELECT @sql = @sql + CASE WHEN @justification = 'Left' THEN 'LEFT(' ELSE 'RIGHT(' END 
			                   + CASE WHEN @justification = 'Right' THEN @fill + ' + ' ELSE '' END
			                   + '[' + @column_name + ']'
							   + CASE WHEN @justification = 'Left'  THEN ' + ' + @fill + ', ' + CONVERT(VARCHAR(10), @field_length) + ') + ' 
							          ELSE ', ' +  CONVERT(VARCHAR(10), @field_length) + ') + ' 
								  END

			FETCH NEXT FROM Fields_Cursor
			  INTO @column_name, @field_length, @justification, @fill_character
		END

	CLOSE Fields_Cursor
	DEALLOCATE Fields_Cursor

	SELECT @sql = LEFT(@sql, LEN(@sql) - 2)	-- Drop the last comma
	SELECT @sql = @sql + ' FROM dbo.' + @table_name + ' WHERE TCID LIKE (''' + @tcid + ''') AND ActiveTestCase = ''A'''

	DELETE FROM wrk.FixedLength WHERE log_id = @log_id

	EXEC(@sql)

	SELECT @expected_records = COUNT(*) 
	  FROM wrk.FixedLength 
	 WHERE log_id = @log_id

	--***************************************************************************************************
	-- Call BCP to create the file
	--***************************************************************************************************
	PRINT @folder
	PRINT @filename
	SELECT @sql = 'SELECT fixed_data FROM wrk.FixedLength WHERE log_id = ' + CONVERT(VARCHAR(10), @log_id) + ' ORDER BY fixed_sid ASC'
	SELECT @cmd = 'bcp "' + ISNULL(@sql, '') + '" queryout "' + ISNULL(@folder, '') + ISNULL(@filename, '') + '" -T -c -S wqadbhpauto01.chicago.local -d CoreFileCreator'
	SELECT @cmd = @cmd + ' -r ' + ISNULL(@record_delimiter, '')
	PRINT @cmd

	INSERT INTO #cmd_results
	  EXEC master.sys.xp_cmdshell @cmd

	SELECT * FROM #cmd_results
	-- Determine if the copy was successful or not and then log the details
	EXEC spFCAuto_GetBCPResults @err_num OUTPUT, @err_msg OUTPUT, @records_copied OUTPUT
	IF @err_num <> 0 BEGIN SET @status = 'Error' END

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