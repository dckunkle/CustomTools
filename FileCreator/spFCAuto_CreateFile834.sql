/**************************************************************************************************
Name:       spFCAuto_CreateFile834
Purpose:    Used to generate 834 files for importing into Core

Date        User            Change
---------------------------------------------------------------------------------------------
11/07/2022	DK				Original procedure
05/12/2023  DK				Add Azure folder as a destination
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateFile834 'EB-Config%', 'EB-Config', '834File', 'aldqrdb09', '9999'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_CreateFile834
     (@i_tcid			VARCHAR(200)
	 ,@i_test_case		VARCHAR(200)
	 ,@i_method_name	VARCHAR(400)
	 ,@i_server			VARCHAR(200)
	 ,@i_log_id			INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @tcid				VARCHAR(200)
       ,@test_case			VARCHAR(200)
	   ,@method_name		VARCHAR(400)
	   ,@server				VARCHAR(200)
	   ,@log_id				INT

	   -- Error handling and logging
	   ,@err_num			INT				= 0
	   ,@err_msg			VARCHAR(4000)	= 'File created successfully.'
	   ,@status				VARCHAR(100)	= 'Success'
	   ,@records_copied		INT				= 0

	   -- Store values from fw.Catalog to name and export the file
	   ,@filename			VARCHAR(8000)
	   ,@filename_delimiter	VARCHAR(5)
	   ,@datetime_stamp		VARCHAR(50)
	   ,@file_extension		VARCHAR(100)
	   ,@file_type			VARCHAR(100)
	   ,@field_delimiter	VARCHAR(5)
	   ,@record_delimiter	VARCHAR(5)
	   ,@export_folder		VARCHAR(1000)
	   ,@table_name			VARCHAR(200)
	   ,@folder				VARCHAR(8000)
	   ,@batch_folder		VARCHAR(4000)
	   ,@instance_name		VARCHAR(200)
	   ,@now				DATETIME

	   -- Used to add the proper header and trailer to the EDI file
	   ,@interchange_sender_id		VARCHAR(50)
	   ,@interchange_receiver_id	VARCHAR(50)
	   ,@interchange_id_qualifier	VARCHAR(50)
	   ,@element_separator			VARCHAR(20)
	   ,@header						VARCHAR(4000)
	   ,@trailer					VARCHAR(4000)
	   ,@expected_records			INT				= 0
	   ,@gs_segment					VARCHAR(200)
	   ,@gs_version					VARCHAR(200)
	   ,@isa_segment				VARCHAR(400)

	   -- Used when calling BCP
	   ,@sql				VARCHAR(8000)
	   ,@table_sql			VARCHAR(8000)
	   ,@cmd				VARCHAR(8000)
	   ,@column_name		VARCHAR(200)
	   ,@sql_field_list		VARCHAR(8000)
	   ,@sql_from			VARCHAR(8000)

 SELECT @tcid				= @i_tcid
       ,@test_case			= @i_test_case
       ,@method_name		= @i_method_name
	   ,@server				= @i_server
	   ,@log_id				= @i_log_id

--Adjust server name for Core environments
SELECT @instance_name	= @server
SELECT @server			= dbo.fnFCAuto_GetServerName(@instance_name)

--***************************************************************************************************
-- Create temporary tables to be used
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

CREATE TABLE #cmd_results
		(results	VARCHAR(8000)
		,result_id	INT				IDENTITY(1,1))

--***************************************************************************************************
-- Populate the values from the fw.Catalog table to name and export the file
--***************************************************************************************************
SELECT @filename			= ISNULL(C.filename, '')
      ,@filename_delimiter	= ISNULL(C.filename_delimiter, '')
	  ,@datetime_stamp		= ISNULL(C.datetime_stamp, '')
	  ,@file_extension		= ISNULL(C.file_extension, '')
	  ,@file_type			= ISNULL(C.file_type, '')
	  ,@field_delimiter     = ISNULL(C.field_delimiter, '')
	  ,@record_delimiter	= ISNULL(C.record_delimiter, '')
	  ,@export_folder		= ISNULL(C.export_folder, '')
	  ,@table_name			= ISNULL(C.table_name, '')
  FROM fw.Catalog		C
 WHERE C.Method_Name	= @method_name

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
		      ,@err_msg	= 'The filename field is required field and cannot be blank. Please review the filename field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
			  ,@status	= 'Error'
		GOTO LOG_ERROR
	END

IF @file_type = ''
	BEGIN
		SELECT @err_num	= 102
		      ,@err_msg	= 'The file_type field is required field and cannot be blank. Please review the file_type field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
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

IF @export_folder = ''
	BEGIN
		SELECT @err_num	= 104
		      ,@err_msg	= 'The export_folder field is a required field and cannot be blank. Please review the export_folder field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
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
-- Determine how many records will be output
--***************************************************************************************************
SELECT @expected_records	= COUNT(*)
  FROM TD_834FileDetail
 WHERE TCID					LIKE @tcid
   AND ActiveTestCase		= 'A'

SELECT @gs_version = '005010X220A1'

--***************************************************************************************************
-- Update the header and trailer records for the 834 file
--***************************************************************************************************
SELECT @interchange_sender_id		= LEFT(ISNULL(PL.InterchangeSenderID, '') + SPACE(15),15)
      ,@interchange_receiver_id		= LEFT(ISNULL(PL.InterchangeReceiverID, '') + SPACE(15),15)
      ,@interchange_id_qualifier	= LEFT(ISNULL(PL.InterchangeIDQualifier, '') + SPACE(2),2)
	  ,@element_separator			= LEFT(ISNULL(PL.ElementSeparator, '') + SPACE(1),1)
  FROM TD_834File					PL
 WHERE ActiveTestCase				= 'A'
   AND TCID							LIKE @tcid

SET @isa_segment = 'ISA*00*          *00*          *~InterchangeIDQualifier~*~InterchangeSenderID~*~InterchangeIDQualifier~*~InterchangeReceiverID~*yymmdd*1259*^*00501*000011154*0*T*~ElementSeparator~~'
SET @isa_segment	= REPLACE(@isa_segment, '~InterchangeIDQualifier~', @interchange_id_qualifier)
SET @isa_segment	= REPLACE(@isa_segment, '~InterchangeSenderID~'   , @interchange_sender_id)
SET @isa_segment	= REPLACE(@isa_segment, '~InterchangeReceiverID~' , @interchange_receiver_id)
SET @isa_segment	= REPLACE(@isa_segment, '~ElementSeparator~'      , @element_separator)
SET @isa_segment	= REPLACE(@isa_segment, 'yymmdd', FORMAT(GETDATE(),'yyMMdd'))
PRINT @isa_segment

SET @gs_segment = 'GS*BE*~InterchangeSenderID~*~InterchangeReceiverID~*ccyymmdd*1259*000011154*X*~GSVersion~~'
SET @gs_segment = REPLACE(@gs_segment, '~InterchangeSenderID~'		, @interchange_sender_id)
SET @gs_segment = REPLACE(@gs_segment, '~InterchangeReceiverID~'   , @interchange_receiver_id)
SET @gs_segment = REPLACE(@gs_segment, '~GSVersion~', @gs_version)
SET @gs_segment = REPLACE(@gs_segment, 'ccyymmdd', FORMAT(GETDATE(),'yyyyMMdd'))
PRINT @gs_segment

SET @header  = @isa_segment + @gs_segment 
SET @trailer = 'GE*ww*111540001~IEA*1*000011154~'
SET @trailer = REPLACE(@trailer, 'ww', CONVERT(VARCHAR(20), @expected_records))
--PRINT @header

--***************************************************************************************************
-- Collect the data needed, and verify that the last character is a ~
--***************************************************************************************************
TRUNCATE TABLE wrk.Import834

INSERT INTO wrk.Import834
      (log_id
	  ,member_data
	  ,last_character)
VALUES(@log_id
      ,LEFT(@header, LEN(@header) - 1)
	  ,RIGHT(@header, 1))

INSERT INTO wrk.Import834
      (log_id
	  ,member_data
	  ,last_character)
SELECT @log_id
      ,LEFT(MemberData, LEN(MemberData) - 1)
	  ,RIGHT(MemberData, 1)
  FROM dbo.TD_834FileDetail
 WHERE TCID LIKE @tcid
   AND ActiveTestCase = 'A'

INSERT INTO wrk.Import834
      (log_id
	  ,member_data
	  ,last_character)
VALUES(@log_id
      ,LEFT(@trailer, LEN(@trailer) - 1)
	  ,RIGHT(@trailer, 1))

IF EXISTS(SELECT TOP 1 last_character FROM wrk.Import834 WHERE last_character <> '~')
	BEGIN
		SELECT @err_num = 200
		      ,@err_msg = 'Error: Not all the data in the MemberData field of the TD_834FileDetail table ends with a ~.'
			  ,@status = 'Error'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Build the filename that will be used to export the file
--***************************************************************************************************
IF @datetime_stamp <> '' SELECT @datetime_stamp = @filename_delimiter + FORMAT(GETDATE(), @datetime_stamp)

SELECT @now = GETDATE()
      ,@tcid = REPLACE(@tcid, '-', @filename_delimiter)

--SELECT @filename = TRIM(@interchange_sender_id)
--                 + @filename_delimiter
SELECT @filename =  @filename
				   + @filename_delimiter
				   --+ 'D'
				   --+ CONVERT(VARCHAR(4), YEAR(@now)) + CONVERT(VARCHAR(4), MONTH(@now)) + CONVERT(VARCHAR(4), DAY(@now))
				   --+ @filename_delimiter
				   --+ 'T' + DATENAME(HOUR, @now) + DATENAME(MINUTE, @now)
				   --+ @filename_delimiter
				   --+ 'FC'
				   --+ @filename_delimiter
				   + CASE WHEN RIGHT(@tcid, 1) = '%' THEN LEFT(@tcid, LEN(@tcid) -1)
				          ELSE @tcid
					  END
				   + CASE WHEN ISNULL(@datetime_stamp, '') = '' THEN ''
				          ELSE @datetime_stamp
					  END
				   + @file_extension

SELECT @batch_folder = dbo.fnFCAuto_GetFolderName(@instance_name)


-- If the destination is Azure storage
IF LEFT(@export_folder, 5) = 'Azure' 
	BEGIN 
		SELECT @folder = 'H:\' + @export_folder + '\'
	END
ELSE
	BEGIN
		-- Convert the folder name to the fully qualified path
		SELECT @folder = '\\' 
						 + @server
						 + '\' + @batch_folder +'\'
						 + CASE WHEN RIGHT(@export_folder, 1) = '\' THEN @export_folder
								ELSE @export_folder + '\'
							END
	END

--***************************************************************************************************
-- Call BCP to create the file
--***************************************************************************************************
BEGIN TRY

	SELECT @sql = 'SELECT member_data FROM wrk.Import834 WHERE log_id = ' + CONVERT(VARCHAR(10), @log_id) + ' ORDER BY member_sid ASC'
	SELECT @cmd = 'bcp "' + @sql + '" queryout "' + @folder + @filename + '" -T -c -S wqadbhpauto01.chicago.local -d CoreFileCreator -r ' + @record_delimiter
	--PRINT @cmd
	INSERT INTO #cmd_results
	  EXEC master.sys.xp_cmdshell @cmd

	-- Determine if the copy was successful or not and then log the details
	EXEC spFCAuto_GetBCPResults @err_num OUTPUT, @err_msg OUTPUT, @records_copied OUTPUT
	IF @err_num <> 0 BEGIN SET @status = 'Error' END

	--Write to the Jenkins log
	PRINT SPACE(8) + LEFT(@method_name + SPACE(51), 51) 
	      + LEFT(@filename + SPACE(35), 35) + ' ' 
	      + LEFT(CONVERT(VARCHAR(5), @expected_records) + SPACE(5), 5)
		  + LEFT(CONVERT(VARCHAR(5), @records_copied - 2) + SPACE(5), 5)
	      + LEFT(@folder + SPACE(39), 39)

	-- Adjust the records copied count for the header and trailer
	SET @records_copied = @records_copied - 2
	EXEC spFCAuto_LogEvent @log_id, @test_case, @method_name, @filename, @folder, @expected_records, @records_copied, @status,@err_num,@err_msg

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()
		  ,@status	= 'Error'

END CATCH
--***************************************************************************************************
-- Log any errors
--***************************************************************************************************
LOG_ERROR:

IF @err_num <> 0 
	BEGIN
		PRINT ' '
		PRINT SPACE(11) + @err_msg
		EXEC spFCAuto_LogEvent @log_id, @test_case, @method_name, @filename, @folder, @expected_records, @records_copied, @status,@err_num,@err_msg
	END

--***************************************************************************************************
-- Cleanup
--***************************************************************************************************
DELETE 
   FROM wrk.Import834
 WHERE log_id = @log_id

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

END
GO