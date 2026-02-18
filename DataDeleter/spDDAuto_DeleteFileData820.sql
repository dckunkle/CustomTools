IF OBJECT_ID('dbo.spDDAuto_DeleteFileData820') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_DeleteFileData820 AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_DeleteFileData820
Purpose:    Delete data for a file loaded through the 837 Parse and Load process

Date        User            Change
---------------------------------------------------------------------------------------------
12/08/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_DeleteFileData820 'CMSFFM.I820.D2021122.T914.FC.Setup.20211202.edi'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_DeleteFileData820
     (@filename			VARCHAR(200)
	 ,@action			VARCHAR(50)		= 'List Files'
	 ,@email_address	VARCHAR(200)	= ''
	 ,@build_id			INT				= 1
	 ,@job_name			VARCHAR(200)	= ''
	 ,@type_id			INT				= 99)
AS
BEGIN

SET NOCOUNT ON

DECLARE @file_count			INT

	   ,@table_name			VARCHAR(255)
	   ,@field_name			VARCHAR(256)
	   ,@record_count		INT
	   ,@sql				VARCHAR(4000)

	   ,@log_id				INT
	   ,@err_num			INT
	   ,@err_msg			VARCHAR(4000)

	   ,@delete_data		BIT				= 0
	   ,@internal_delete	BIT				= 0
	   ,@list_file			VARCHAR(256)
	   ,@list_date			VARCHAR(15)

	   ,@log_id_char		CHAR(6)
	   ,@server_name_char	CHAR(20)
	   ,@filename_char		CHAR(60)
	   ,@action_char		CHAR(15)
	   ,@server				VARCHAR(100)	= LOWER(@@SERVERNAME)
	   ,@header_title		VARCHAR(100)
	   ,@footer_title		VARCHAR(100)
	   ,@total_records		INT

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DDLog
      (user_id
	  ,job_action
	  ,entity_to_delete
	  ,entity_type
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT SUSER_NAME()
      ,@action
      ,@filename
	  ,'File'
	  ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Set variables for Jenkins logging
--*************************************************************************************************
SELECT @log_id_char			= LEFT(CONVERT(VARCHAR(6), @log_id) + SPACE(6), 6)
	  ,@server_name_char	= LEFT(LOWER(RIGHT(@server, 20)) + SPACE(20), 20)
	  ,@action_char			= LEFT(@action + SPACE(15), 15)
	  ,@filename_char		= LEFT(LEFT(@filename, 60) + SPACE(60), 60)
	  ,@internal_delete		= CASE WHEN @action = 'Internal Delete' THEN 1
	                               ELSE 0
							   END
	  ,@delete_data			= CASE WHEN @action = 'Delete Data' OR @internal_delete = 1 THEN 1
	                               ELSE 0
							   END
	  ,@header_title		= CASE WHEN @action = 'Delete Data'		THEN 'DELETE 820 FILE DATA'
	                               WHEN @action = 'List Files'		THEN '837 FILE LISTING'
								   WHEN @action = 'Review Data'		THEN 'REVIEW 820 FILE DATA'
							   END
	  ,@footer_title		= CASE WHEN @action = 'Delete Data'		THEN 'Total Records Deleted:'
	                               WHEN @action = 'List Files'		THEN 'Total Number of Files:'
								   WHEN @action = 'Review Data'		THEN 'Total Records Shown:'
							   END

--*************************************************************************************************
-- Write the header to the Jenkins log
--*************************************************************************************************
IF @internal_delete = 0
	BEGIN
		PRINT ''
		PRINT ''
		PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
		PRINT ' ' + @header_title
		PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
		PRINT ' '
		PRINT '        -Log ID---Date Time-------------Server Name----------Action----------Filename-----------------------------------------------------------'
		PRINT '         ' + ISNULL(@log_id_char, '') + '   ' + CONVERT(VARCHAR(100), GETDATE(), 20) + '   ' + ISNULL(@server_name_char, '') + ' ' + ISNULL(@action_char, '') + ' ' + ISNULL(@filename_char, '')
		PRINT ' '
		PRINT ' '
	END

--*************************************************************************************************
-- If the user selected a listing , show the listing and exit
--*************************************************************************************************
IF @action = 'List Files'
	BEGIN
		
		IF @internal_delete = 0
			BEGIN
				-- Write the file listing header to the Jenkins log
				PRINT '        -File Name------------------------------------------------------File Date-'
				PRINT ' '
			END

		IF OBJECT_ID('tempdb.dbo.#List_Files') IS NOT NULL	
			DROP TABLE #List_Files

		CREATE TABLE #List_Files
		      (file_name	VARCHAR(256)
			  ,file_date	VARCHAR(15))

		INSERT INTO #List_Files
		      (file_name
			  ,file_date)
		SELECT FRL.file_name
			  ,CONVERT(VARCHAR(10), FRL.date_process_start, 23)
          FROM dbo.File_Receive_Log FRL
		 WHERE FRL.file_type		= '820'

		--If there are no files to list then let the user know
		IF NOT EXISTS(SELECT TOP 1 file_name FROM #List_Files)
			BEGIN
				PRINT SPACE(11) + 'No 820 files have been loaded previously.'
			END 

		SELECT @total_records = COUNT(*) FROM #List_Files

		-- Loop through all of the files and list them out
		DECLARE List_Files CURSOR FOR
		 SELECT file_name
			   ,file_date
		   FROM #List_Files
		  ORDER BY file_date DESC

		 OPEN List_Files
		FETCH NEXT FROM List_Files INTO @list_file, @list_date

		WHILE @@FETCH_STATUS = 0
			BEGIN
				--Write the filename and filedate
				PRINT SPACE(9) + LEFT(@list_file + SPACE(63), 63) + @list_date
				FETCH NEXT FROM List_Files INTO @list_file, @list_date
			END

		CLOSE List_Files
		DEALLOCATE List_Files

		-- Write the file listing footer to the Jenkins log
		IF @internal_delete = 0
			BEGIN
				PRINT ' '
				PRINT SPACE(8) + '--------------------------------------------------------------------------'
				PRINT SPACE(8) + RIGHT(SPACE(63) + @footer_title, 63) + RIGHT(SPACE(10) + CONVERT(varchar(10), @total_records),10)
				PRINT ''
				PRINT ''
			END

		UPDATE DDLog SET end_time = GETDATE() WHERE log_id = @log_id
		GOTO CLEANUP

	END

--*************************************************************************************************
-- Write section header to Jenkins log
--*************************************************************************************************
IF @internal_delete = 0
	BEGIN
		PRINT SPACE(8) + '-Table Name-------------------------------------------------------Records-'
		PRINT ' '
	END

--*************************************************************************************************
-- Check to see if deleting data will impact more than one file
--*************************************************************************************************
;WITH CTE_Files
   AS(SELECT DISTINCT
             file_name
        FROM File_Receive_Log FRL
	   WHERE FRL.file_name = @filename 
	     AND FRL.record_status = 'A')
SELECT @file_count	= COUNT(*)
  FROM CTE_Files

IF (@file_count > 1)
	BEGIN
		SELECT @err_num = 100
		      ,@err_msg = 'The filename are not unique to a single file. Operation aborted.' 

		PRINT ' '
		PRINT SPACE(11) + @err_msg
		EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Error', @err_num, @err_msg

		GOTO CLEANUP
	END

--*************************************************************************************************
-- Populate tables that will be used to find the data that needs to be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#File_Sid') IS NOT NULL
	DROP TABLE #File_Sid

CREATE TABLE #File_Sid
      (file_sid		INT)

INSERT INTO #File_Sid
      (file_sid)
SELECT FRL.file_sid
  FROM dbo.File_Receive_Log		FRL
 WHERE FRL.file_type			= '820'
   AND FRL.file_name			= @filename

IF OBJECT_ID('tempdb.dbo.#Audit_Gid') IS NOT NULL
	DROP TABLE #Audit_Gid

CREATE TABLE #Audit_Gid
      (file_sid		INT
	  ,audit_gid	INT)

INSERT INTO #Audit_Gid
      (file_sid
	  ,audit_gid)
SELECT F.file_sid
      ,AD.RecordSID
  FROM dbo.[820AuditDetails]		AD
  JOIN #File_Sid					F
    ON AD.FileSID					= F.file_sid
  JOIN dbo.Cash_Receipt_Transaction	CRT
    ON AD.RecordSID					= CRT.audit_header_820_gid

--*************************************************************************************************
-- Create tables and populate with data that will be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Payment_Table') IS NOT NULL
	DROP TABLE #Payment_Table

CREATE TABLE #Payment_Table
      (table_name	VARCHAR(256)
	  ,field_name	VARCHAR(256))

INSERT INTO #Payment_Table(table_name, field_name) VALUES ('File_Receive_Log',			'file_sid')
INSERT INTO #Payment_Table(table_name, field_name) VALUES ('File_Receive_Log_Details',	'file_sid')
INSERT INTO #Payment_Table(table_name, field_name) VALUES ('820AuditHeader',			'FileSID')
INSERT INTO #Payment_Table(table_name, field_name) VALUES ('820AuditDetails',			'FileSID')

IF OBJECT_ID('tempdb.dbo.#Payment_Count') IS NOT NULL
	DROP TABLE #Payment_Count

CREATE TABLE #Payment_Count
      (table_name	VARCHAR(255)
	  ,records		INT)

--************************************************************************************************
-- Loop through the payments tables to find data that should be deleted
--************************************************************************************************
DECLARE payments_cursor CURSOR FOR
 SELECT table_name
	   ,field_name
   FROM #Payment_Table
  ORDER BY table_name

 OPEN payments_cursor
FETCH NEXT FROM payments_cursor INTO @table_name, @field_name

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = 'INSERT INTO #Payment_Count
		                  (table_name
						  ,records) 
				    SELECT ''' + @table_name + ''' AS TableName
					      ,COUNT(*) AS Count
		              FROM [' + @table_name + ']	CC
					  JOIN [#File_Sid]				C
					    ON CC.[' + @field_name + '] = C.[file_sid]'
		EXEC (@sql)

		FETCH NEXT FROM payments_cursor INTO @table_name, @field_name
	END

CLOSE payments_cursor
DEALLOCATE payments_cursor

--************************************************************************************************
-- Get counts of data to delete from special tables (Effectuation tables)
--************************************************************************************************
INSERT INTO #Payment_Count
      (table_name
	  ,records)
SELECT 'Cash_Receipt_Transaction'
      ,COUNT(*)
  FROM #File_Sid				F
  JOIN [820AuditDetails]		AD
    ON F.file_sid				= AD.FileSID
  JOIN Cash_Receipt_Transaction	CRT
    ON AD.RecordSID				= CRT.audit_header_820_gid

--*************************************************************************************************
-- Now delete the records and log the activity
--*************************************************************************************************
BEGIN TRY

	BEGIN TRANSACTION

		IF NOT EXISTS(SELECT TOP 1 table_name FROM #Payment_Count WHERE records > 0) 
			BEGIN PRINT SPACE(11) + 'No data was found in the database for the specified 820 file.' END

		-- Loop through membership tables and delete the data
		DECLARE delete_cursor CURSOR FOR
		 SELECT PT.table_name
			   ,PT.field_name
			   ,PC.records
		   FROM #Payment_Table	PT
		   JOIN #Payment_Count	PC
			 ON PT.table_name	= PC.table_name

		OPEN delete_cursor
		FETCH NEXT FROM delete_cursor INTO @table_name, @field_name, @record_count

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @sql = 'DELETE CC
				              FROM [' + @table_name + ']	CC
					          JOIN [#File_Sid]	C
					            ON CC.[' + @field_name + '] = C.[file_sid]'
				IF @delete_data = 1 BEGIN EXEC (@sql) END

				IF @record_count > 0 
					BEGIN
						EXEC dbo.spDDAuto_LogEvent @log_id, @table_name, @record_count, 'Delete', 0, ''

						IF @internal_delete = 0
							BEGIN
								PRINT SPACE(9) + LEFT(@table_name + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
							END
						ELSE
							BEGIN
								EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, '' 
								EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count
							END
					END

				FETCH NEXT FROM delete_cursor INTO @table_name, @field_name, @record_count
			END

		CLOSE delete_cursor
		DEALLOCATE delete_cursor
			
--*************************************************************************************************
-- Manually delete the remaining records
--*************************************************************************************************

		SELECT @record_count = records FROM #Payment_Count WHERE table_name = 'Cash_Receipt_Transaction'
		IF @record_count > 0
			BEGIN
				IF @delete_data = 1
					BEGIN
						DELETE CRT
						  FROM dbo.Cash_Receipt_Transaction	CRT
						  JOIN #Audit_Gid					AG
						    ON CRT.audit_header_820_gid		= AG.audit_gid
					END
				EXEC dbo.spDDAuto_LogEvent @log_id, 'Cash_Receipt_Transaction', @record_count, 'Delete', 0, ''
				IF @internal_delete = 0 PRINT SPACE(9) + LEFT('Cash_Receipt_Transaction' + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
				IF @internal_delete = 1 
					BEGIN
						EXEC spFDAuto_LogTypeEvent @type_id, 'Cash_Receipt_Transaction', @record_count, 'Deleted', 0, '' 
						EXEC spFCAuto_DeleteDisplayCounts 'Cash_Receipt_Transaction', @record_count
					END
			END

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	SELECT @err_num	= ERROR_NUMBER()
	      ,@err_msg	= ERROR_MESSAGE()

	ROLLBACK TRANSACTION
	PRINT SPACE(11) + @err_msg
	EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Delete', @err_num, @err_msg

END CATCH

--*************************************************************************************************
-- Finish the logging and send an email
--*************************************************************************************************
SELECT @total_records = SUM(CC.records)
  FROM #Payment_Count	CC

IF @internal_delete = 0
	BEGIN
		PRINT ' '
		PRINT SPACE(8) + '--------------------------------------------------------------------------'
		PRINT SPACE(8) + RIGHT(SPACE(63) + @footer_title, 63) + RIGHT(SPACE(10) + CONVERT(varchar(10), @total_records),10)
		PRINT ''
		PRINT ''
	END

--*************************************************************************************************
-- Finish the logging and send an email
--*************************************************************************************************
UPDATE DDLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

-- Now send an email with the results
IF @internal_delete = 0
	BEGIN
		EXEC spDDAuto_EmailResults @log_id, @email_address
	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#List_Files') IS NOT NULL	
	DROP TABLE #List_Files

IF OBJECT_ID('tempdb.dbo.#File_Sid') IS NOT NULL
	DROP TABLE #File_Sid

IF OBJECT_ID('tempdb.dbo.#Payment_Table') IS NOT NULL
	DROP TABLE #Payment_Table

IF OBJECT_ID('tempdb.dbo.#Payment_Count') IS NOT NULL
	DROP TABLE #Payment_Count

END
GO