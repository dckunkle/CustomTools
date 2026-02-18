IF OBJECT_ID('dbo.spFCAuto_CreateLockboxFile') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_CreateLockboxFile AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_CreateLockboxFile
Purpose:    Used to generate 837 files for importing into Core

Date        User            Change
---------------------------------------------------------------------------------------------
03/02/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateLockboxFile 'LBX-ADD-TC1%','Load-Lockbox-TC1','Lockbox','aldqadbqr06',11362
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_CreateLockboxFile
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
	   ,@header				VARCHAR(4000)
	   ,@trailer			VARCHAR(4000)
	   ,@claim_type			VARCHAR(200)
	   ,@post_mark			BIT				= 0
	   ,@num_of_payments	INT				= 0
	   ,@sum_of_payments	INT				= 0
	   ,@expected_records	INT				= 0
	   ,@header_tcid		VARCHAR(200)
	   ,@batch				VARCHAR(20)

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
	   ,@header_tcid		= CASE WHEN RIGHT(@i_tcid, 1) = '%' THEN @i_tcid
	                               ELSE @i_tcid + '%'
							   END

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
-- Determine how many records will be output, and if the file inlcudes the Post Mark Date
--***************************************************************************************************
SELECT @num_of_payments		= COUNT(*)
	  ,@sum_of_payments		= SUM(CONVERT(INT, LD.Payment_Amount))
  FROM TD_LockboxDetail		LD
 WHERE TCID					LIKE @header_tcid
   AND LD.ActiveTestCase	= 'A'

IF EXISTS(SELECT TOP 1 Post_Mark_Date 
            FROM dbo.TD_LockboxDetail 
		   WHERE ActiveTestCase				= 'A' 
		     AND ISNULL(Post_Mark_Date, '') <> ''
			 AND TCID						LIKE @header_tcid)
	BEGIN
		SET @post_mark = 1
	END

--***************************************************************************************************
-- Create the header record
--***************************************************************************************************
DECLARE @record_type		VARCHAR(1)
	   ,@lockbox_number		VARCHAR(5)
	   ,@log_date			VARCHAR(10)
	   ,@log_time			VARCHAR(6)

SELECT @record_type			= ISNULL(LB.Record_Type, '')
	  ,@lockbox_number		= ISNULL(LB.Lockbox_Number, '')
	  ,@log_date			= ISNULL(LB.Log_Date, '')
	  ,@log_time			= ISNULL(LB.Log_Time, '')
  FROM dbo.TD_Lockbox		LB
  WHERE LB.TCID				LIKE @tcid
  AND LB.ActiveTestCase		= 'A'

SET @header = @record_type
			+ LEFT(@lockbox_number	+ SPACE(5), 5)
			+ LEFT(@log_date		+ SPACE(8), 8)
			+ LEFT(@log_time		+ SPACE(6), 6)
			+ CASE WHEN @post_mark = 1 THEN SPACE(142)
					ELSE SPACE(134)
				END

--***************************************************************************************************
-- Create the trailer record
--***************************************************************************************************
SELECT @trailer = 'T'
				+ RIGHT('000000' + CONVERT(VARCHAR(6), @num_of_payments), 6)
				+ RIGHT('000000000000' + CONVERT(VARCHAR(12), @sum_of_payments), 12)
				+ CASE WHEN @post_mark = 1 THEN SPACE(143)
					   ELSE SPACE(135)
				   END

--***************************************************************************************************
-- Collect the data needed, and verify that the last character is a ~
--***************************************************************************************************
TRUNCATE TABLE wrk.Lockbox

INSERT INTO wrk.Lockbox
	  (lockbox_data)
VALUES(@header)

INSERT INTO wrk.Lockbox
	  (lockbox_data)
SELECT Record_Type
	  + File_Format
	  + Payment_Type
	  + LEFT(ISNULL(Parent_ID, '')			+ SPACE(50), 50)
	  + LEFT(ISNULL(Member_ID, '')			+ SPACE(18), 18)
	  + LEFT(ISNULL(Routing_Number, '')		+ SPACE(9) ,  9)
	  + LEFT(ISNULL(Account_Number, '')		+ SPACE(17), 17)
	  + LEFT(ISNULL(Check_Number, '')		+ SPACE(18), 18)
	  + RIGHT('000000000' + ISNULL(Payment_Amount, ''),   9)
	  + LEFT(ISNULL(Batch_Number, '')		+ SPACE(8) ,  8)
	  + LEFT(ISNULL(Transaction_Number, '') + SPACE(4) ,  4)
	  + LEFT(ISNULL(Sequence_Number, '')	+ SPACE(3) ,  3)
	  + LEFT(ISNULL(Trace_Number, '')		+ SPACE(15), 15)
	  + CASE WHEN @post_mark = 1 THEN LEFT(ISNULL(Post_Mark_Date, '') + SPACE(8) ,  8)
			 ELSE ''
		 END
  FROM dbo.TD_LockboxDetail		LBD
 WHERE LBD.TCID					LIKE @header_tcid
   AND LBD.ActiveTestCase		= 'A'



INSERT INTO wrk.Lockbox
	  (lockbox_data)
VALUES(@trailer)

--***************************************************************************************************
-- Build the filename that will be used to export the file
--***************************************************************************************************
IF @datetime_stamp <> '' SELECT @datetime_stamp = @filename_delimiter + FORMAT(GETDATE(), @datetime_stamp)

SELECT @filename = @filename 
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

	SELECT @sql = 'SELECT lockbox_data FROM wrk.Lockbox ORDER BY lockbox_sid ASC'
	SELECT @cmd = 'bcp "' + @sql + '" queryout "' + @folder + @filename + '" -T -c -S hpsqadbauto01.chicago.local -d CoreFileCreator -r ' + @record_delimiter

	INSERT INTO #cmd_results
	  EXEC master.sys.xp_cmdshell @cmd

	-- Determine if the copy was successful or not and then log the details
	EXEC spFCAuto_GetBCPResults @err_num OUTPUT, @err_msg OUTPUT, @records_copied OUTPUT

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
IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

IF OBJECT_ID('tempdb.dbo.#lockbox_batches') IS NOT NULL
	DROP TABLE #lockbox_batches

END
GO