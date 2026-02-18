IF OBJECT_ID('dbo.spFCAuto_CreateFile837') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_CreateFile837 AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_CreateFile837
Purpose:    Used to generate 837 files for importing into Core

Date        User            Change
---------------------------------------------------------------------------------------------
12/23/2020	DK				Original procedure
06/23/2021	DK				Change GS Segment based on Professional or Institutional claim
07/19/2021  DK				Properly report error when BCP is not able to write a file
12/07/2022  DK				Add log_id to work table to allow for concurrent files to be processed 
                            at the same time
06/27/2023  DK				Add support for Dental claims
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateFile837 'Count-Config-DK%', 'Count-Config-DK', '837ParseLoad', 'aldqrdb07', '12'
EXEC spFCAuto_CreateFile837 'RFF-Config-21%', 'RFF-Config-2101', '837ParseLoad', 'aldtstdbcoree01', '999999'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_CreateFile837
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

	   -- Used to add the proper header and trailer to the EDI file
	   ,@interchangeID		VARCHAR(50)
	   ,@interchangeID_type	VARCHAR(50)
	   ,@element_separator	VARCHAR(20)
	   ,@header				VARCHAR(4000)
	   ,@trailer			VARCHAR(4000)
	   ,@claim_type			VARCHAR(200)
	   ,@expected_records	INT				= 0
	   ,@gs_segment			VARCHAR(200)

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
  FROM TD_837ParseLoadDetail
 WHERE TCID					LIKE @tcid
   AND ActiveTestCase		= 'A'
        
--***************************************************************************************************
-- Determine what type of file it will be, Professional or Institutional 
--***************************************************************************************************
-- Choose the first claim type, assume that the file will not be created if there is a mix 
SELECT @claim_type = (SELECT TOP 1 ClaimType 
                        FROM dbo.TD_837ParseLoadDetail 
					   WHERE TCID LIKE @tcid 
					     AND ActiveTestCase = 'A' 
					   GROUP BY ClaimType)

SELECT @gs_segment = CASE WHEN @claim_type = 'Professional' THEN '005010X222A1' 
						  WHEN @claim_type = 'Institutional' THEN '005010X223A2'
						  WHEN @claim_type = 'Dental' THEN '005010X224A2'
					  END

--***************************************************************************************************
-- Update the header and trailer records for the 837 file
--***************************************************************************************************
SELECT @interchangeID		= LEFT(ISNULL(PL.InterchangeID, '') + SPACE(15),15)
      ,@interchangeID_type	= LEFT(ISNULL(PL.InterchangeIDType, '') + SPACE(2),2)
	  ,@element_separator	= LEFT(ISNULL(PL.ElementSeparator, '') + SPACE(1),1)
  FROM TD_837ParseLoad		PL
 WHERE ActiveTestCase		= 'A'
   AND TCID					LIKE @tcid

SET @header = 'ISA*00*          *00*          *~InterchangeIDType~*~InterchangeID~*ZZ*364265323      *yymmdd*1259*^*00501*000000001*0*T*~ElementSeparator~~GS*HC*IB837QA*364265323*ccyymmdd*1259*000000001*X*~GSSegment~~'
	
SET @header	= REPLACE(@header, '~InterchangeIDType~', @interchangeID_type)
SET @header	= REPLACE(@header, '~InterchangeID~', @interchangeID)
SET @header	= REPLACE(@header, '~ElementSeparator~', @element_separator)
SET @header = REPLACE(@header, '~GSSegment~', @gs_segment)
SET @header = REPLACE(@header, 'ccyymmdd', FORMAT(GETDATE(),'yyyyMMdd'))
SET @header = REPLACE(@header, 'yymmdd', FORMAT(GETDATE(),'yyMMdd'))

SET @trailer = 'GE*ww*000000001~IEA*1*000000001~'
SET @trailer = REPLACE(@trailer, 'ww', CONVERT(VARCHAR(20), @expected_records))

--***************************************************************************************************
-- Collect the data needed, and verify that the last character is a ~
--***************************************************************************************************
TRUNCATE TABLE wrk.ParseLoad837

INSERT INTO wrk.ParseLoad837
      (log_id
	  ,claim_type
	  ,claim_data
	  ,last_character)
VALUES(@log_id
      ,@claim_type
      ,LEFT(@header, LEN(@header) - 1)
	  ,RIGHT(@header, 1))

INSERT INTO wrk.ParseLoad837
      (log_id
	  ,claim_type
	  ,claim_data
	  ,last_character)
SELECT @log_id
      ,ClaimType
      ,LEFT(ClaimData, LEN(ClaimData) - 1)
	  ,RIGHT(ClaimData, 1)
  FROM dbo.TD_837ParseLoadDetail
 WHERE TCID LIKE @tcid
   AND ActiveTestCase = 'A'

INSERT INTO wrk.ParseLoad837
      (log_id
	  ,claim_type
	  ,claim_data
	  ,last_character)
VALUES(@log_id
      ,@claim_type
      ,LEFT(@trailer, LEN(@trailer) - 1)
	  ,RIGHT(@trailer, 1))

IF EXISTS(SELECT TOP 1 last_character FROM wrk.ParseLoad837 WHERE last_character <> '~')
	BEGIN
		SELECT @err_num = 200
		      ,@err_msg = 'Error: Not all the data in the ClaimData field of the TD_837ParseLoad table ends with a ~.'
			  ,@status = 'Error'
		GOTO LOG_ERROR
	END

IF (SELECT COUNT(*) FROM (SELECT claim_type FROM wrk.ParseLoad837 GROUP BY claim_type) X) > 1
	BEGIN
		SELECT @err_num = 201
		      ,@err_msg = 'Error: There is a mix of professional, institutional and/or dental claims in the data that will be exported.'
			  ,@status = 'Error'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Build the filename that will be used to export the file
--***************************************************************************************************
IF @datetime_stamp <> '' SELECT @datetime_stamp = @filename_delimiter + FORMAT(GETDATE(), @datetime_stamp)

SELECT @filename = @filename
                   + CASE WHEN @claim_type = 'Professional' THEN 'P' 
						  WHEN @claim_type = 'Institutional' THEN 'I'
						  WHEN @claim_type = 'Dental' THEN 'D'
					  END
				   + @filename_delimiter
				   + CASE WHEN RIGHT(@tcid, 1) = '%' THEN LEFT(@tcid, LEN(@tcid) -1)
				          ELSE @tcid
					  END
				   + CASE WHEN ISNULL(@datetime_stamp, '') = '' THEN ''
				          ELSE @datetime_stamp
					  END
				   + @file_extension

SELECT @batch_folder = dbo.fnFCAuto_GetFolderName(@instance_name)

-- Convert the folder name to the fully qualified path
SELECT @folder = '\\' 
                 + @server
				 + '\' + @batch_folder +'\'
				 + CASE WHEN RIGHT(@export_folder, 1) = '\' THEN @export_folder
				        ELSE @export_folder + '\'
					END

--***************************************************************************************************
-- Call BCP to create the file
--***************************************************************************************************
BEGIN TRY

	SELECT @sql = 'SELECT claim_data FROM wrk.ParseLoad837 WHERE log_id = ' + CONVERT(VARCHAR(10), @log_id) + ' ORDER BY claim_sid ASC'
	SELECT @cmd = 'bcp "' + @sql + '" queryout "' + @folder + @filename + '" -T -c -S wqadbhpauto01.chicago.local -d CoreFileCreator -r ' + @record_delimiter
	PRINT @cmd
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
   FROM wrk.ParseLoad837
 WHERE log_id = @log_id

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

END
GO