IF OBJECT_ID('dbo.spDDAuto_DeleteFileData837') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_DeleteFileData837 AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_DeleteFileData837
Purpose:    Delete data for a file loaded through the 837 Parse and Load process

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
01/19/2021	DK				Added @internal_delete for deleting at the time the file is being created
09/19/2022  DK				Comment out guardrail code that prevents partial EOC deletes
03/08/2023	DK				Added 275Attachment table
05/09/2023	DK				Added ClaimLevelRollingBalance table
11/27/2023	DK				Changed table name from 275Attachment to Attachment275ClaimDetails
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_DeleteFileData837 'FC_837P_RFF-Int-Run1-Pro_20220922.edi', 'Review Data'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_DeleteFileData837
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
	   ,@record_count		INT
	   ,@sql				VARCHAR(4000)

	   ,@log_id				INT
	   ,@err_num			INT
	   ,@err_msg			VARCHAR(4000)

	   ,@delete_data		BIT				= 0
	   ,@eoc_delete			BIT				= 0
	   ,@internal_delete	BIT				= 0
	   ,@list_file			VARCHAR(256)
	   ,@list_date			VARCHAR(15)

	   ,@temp_table			VARCHAR(256)
	   ,@field_name_src		VARCHAR(256)
	   ,@field_name_dst		VARCHAR(256)

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
	  ,@eoc_delete			= CASE WHEN @action = 'EOC Delete Data' THEN 1
	                               ELSE 0
							   END
	  ,@internal_delete		= CASE WHEN @action = 'Internal Delete' THEN 1
	                               ELSE 0
							   END
	  ,@delete_data			= CASE WHEN @action = 'Delete Data' OR @internal_delete = 1 THEN 1
	                               ELSE 0
							   END
	  ,@header_title		= CASE WHEN @action = 'Delete Data'		THEN 'DELETE 837 FILE DATA'
	                               WHEN @action = 'List Files'		THEN '837 FILE LISTING'
								   WHEN @action = 'Review Data'		THEN 'REVIEW 837 FILE DATA'
								   WHEN @action = 'EOC Delete Data'	THEN 'DELETE 837 FILE DATA'
							   END
	  ,@footer_title		= CASE WHEN @action = 'Delete Data'		THEN 'Total Records Deleted:'
	                               WHEN @action = 'EOC Delete Data'	THEN 'Total Records Deleted:'
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
		 WHERE FRL.file_type			= '837'

		--If there are no files to list then let the user know
		IF NOT EXISTS(SELECT TOP 1 file_name FROM #List_Files)
			BEGIN
				PRINT SPACE(11) + 'No 837 files have been loaded previously.'
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
IF OBJECT_ID('tempdb.dbo.#Claim') IS NOT NULL
	DROP TABLE #Claim

CREATE TABLE #Claim
      (claim_number		VARCHAR(50)
	  ,line_number		INT
	  ,date_submitted	DATETIME)

IF OBJECT_ID('tempdb.dbo.#Claim_Sid') IS NOT NULL
	DROP TABLE #Claim_Sid

CREATE TABLE #Claim_Sid
      (claim_sid		INT)

IF OBJECT_ID('Tempdb.dbo.#eoc') IS NOT NULL
	DROP TABLE #eoc

CREATE TABLE #eoc (
    eoc_gid     int
)

INSERT INTO #Claim  
      (claim_number
	  ,line_number
	  ,date_submitted)
SELECT CD.claim_number
      ,CD.line_number
	  ,CD.date_submitted
  FROM dbo.Claims_Detail_V2		CD
 WHERE CD.file_sid IN (SELECT FRL.file_sid
                         FROM File_Receive_Log	FRL
						WHERE FRL.file_name		= @filename)

INSERT INTO #Claim_Sid
      (claim_sid)
SELECT CL.claim_sid
  FROM #Claim				C
  JOIN dbo.Claims_Log_V2	CL
    ON C.claim_number		= CL.claim_number

INSERT INTO #eoc 
      (eoc_gid)
SELECT DISTINCT 
       CLX.eoc_gid
  FROM dbo.EOC_To_Claim_Line_Xref	CLX 
  JOIN #Claim_Sid					CS
    ON CLX.claim_sid				= CS.claim_sid

--*************************************************************************************************
-- Make sure no partial check runs are being deleted. If so, report and error and quit 
--*************************************************************************************************
--IF 0 < (SELECT COUNT(x.claim_sid)
--          FROM dbo.EOC_To_Claim_Line_Xref	X 
--          JOIN #eoc                         E 
--		    ON x.eoc_gid					= e.eoc_gid
--          LEFT JOIN #Claim_Sid				L
--		    ON x.claim_sid					= L.claim_sid
--         WHERE L.claim_sid					IS NULL)
--	BEGIN
		
--		PRINT ' '
-- 		PRINT SPACE(11) + 'Not all of the claims included in the Check Run will be deleted. Aborting...'
-- 		GOTO CLEANUP

--	END

--*************************************************************************************************
-- Create tables and populate with data that will be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Claim_Table') IS NOT NULL
	DROP TABLE #Claim_Table

CREATE TABLE #Claim_Table
      (table_name		VARCHAR(256)
	  ,temp_table		VARCHAR(256)
	  ,field_name_src	VARCHAR(256)
	  ,field_name_dst	VARCHAR(256))

INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Detail_V2',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Log_V2',				'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_Documentation',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Header_Entry',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Line_Items_Entry_V2',	'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Rollback_Log',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_Resubmitter',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Document_Import',				'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_Auth_XRef',				'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Log_Message',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_Provider_Data',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('ClaimLevelRollingBalance',	'#Claim',		'claim_number',		'ClaimNumber')

INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_Occur_Codes',			'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_HP_lines',				'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claim_HP_Tiers',				'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Ancillary',			'#Claim_Sid',	'claim_sid',		'claim_sid')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_CAS_Line_Adjustments',	'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Claims_Repricing_Log',		'#Claim',		'claim_number',		'claim_number')
INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('Attachment275ClaimDetails',	'#Claim',		'claim_number',		'ClaimNumber')
--INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('275Attachment',	'#Claim',		'claim_number',		'ClaimNumber')

INSERT INTO #Claim_Table(table_name, temp_table, field_name_src, field_name_dst) VALUES ('WorkFlow_Process',			'#Claim',		'claim_number',		'supporting_data')

IF OBJECT_ID('tempdb.dbo.#Claim_Count') IS NOT NULL
	DROP TABLE #Claim_Count

CREATE TABLE #Claim_Count
      (table_name	VARCHAR(255)
	  ,records		INT)

--************************************************************************************************
-- Loop through the claims tables to find data that should be deleted
--************************************************************************************************
DECLARE claims_cursor CURSOR FOR
 SELECT table_name
       ,temp_table
	   ,field_name_src
	   ,field_name_dst
   FROM #Claim_Table
  ORDER BY table_name

 OPEN claims_cursor
FETCH NEXT FROM claims_cursor INTO @table_name, @temp_table, @field_name_src, @field_name_dst

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = 'IF OBJECT_ID(''[' + @table_name + ']'') IS NOT NULL
						BEGIN
		            INSERT INTO #Claim_Count
		                  (table_name
						  ,records) 
				    SELECT ''' + @table_name + ''' AS TableName
					      ,COUNT(*) AS Count
		              FROM [' + @table_name + ']	CC
					  JOIN [' + @temp_table + ']	C
					    ON CC.[' + @field_name_dst + '] = C.[' + @field_name_src + ']
						END'
		EXEC (@sql)

		FETCH NEXT FROM claims_cursor INTO @table_name, @temp_table, @field_name_src, @field_name_dst
	END

CLOSE claims_cursor
DEALLOCATE claims_cursor

--************************************************************************************************
-- Get counts of data to delete from special tables (Effectuation tables)
--************************************************************************************************
INSERT INTO #Claim_Count
      (table_name
	  ,records)
SELECT 'File_Receive_Log'
      ,COUNT(*)
  FROM dbo.File_Receive_Log
 WHERE file_name = @filename

INSERT INTO #Claim_Count
      (table_name
	  ,records)
SELECT 'File_Receive_Log_Details'
      ,COUNT(*)
  FROM dbo.File_Receive_Log_Details FD
 WHERE FD.file_sid IN (SELECT FRL.file_sid
                         FROM File_Receive_Log	FRL
						WHERE FRL.file_name		= @filename)

INSERT INTO #Claim_Count
      (table_name
	  ,records)
SELECT 'EOC_Table'
      ,COUNT(*)
  FROM dbo.EOC_Table	ET
  JOIN #eoc				E
    ON ET.eoc_gid		= E.eoc_gid

INSERT INTO #Claim_Count
      (table_name
	  ,records)
SELECT 'EOC_To_Claim_Line_Xref'
      ,COUNT(*)
  FROM dbo.EOC_To_Claim_Line_Xref	EX
  JOIN #eoc							E
    ON EX.eoc_gid					= E.eoc_gid

--*************************************************************************************************
-- Check to see if there are EOC records and EOC Delete Data is chosen
--*************************************************************************************************
IF @eoc_delete = 1
	BEGIN
		IF (SELECT records FROM #Claim_Count WHERE table_name = 'EOC_Table') > 0
			BEGIN
				PRINT SPACE(11) + 'There are EOC records associated with this file and the EOC Delete Data option was selected.'
				PRINT SPACE(11) + 'Aborting delete...'
				PRINT ' '
				PRINT SPACE(8) + '--------------------------------------------------------------------------'
				PRINT ' '
				PRINT ' '

				GOTO CLEANUP
			END
	END

--*************************************************************************************************
-- Now delete the records and log the activity
--*************************************************************************************************
BEGIN TRY

	BEGIN TRANSACTION

		IF NOT EXISTS(SELECT TOP 1 table_name FROM #Claim_Count WHERE records > 0) 
			BEGIN PRINT SPACE(11) + 'No data was found in the database for the specified 837 file.' END

		-- Loop through membership tables and delete the data
		DECLARE delete_cursor CURSOR FOR
		 SELECT CT.table_name
		       ,CT.temp_table
			   ,CT.field_name_src
			   ,CT.field_name_dst
			   ,CC.records
		   FROM #Claim_Table	CT
		   JOIN #Claim_Count	CC
			 ON CT.table_name	= CC.table_name

		OPEN delete_cursor
		FETCH NEXT FROM delete_cursor INTO @table_name, @temp_table, @field_name_src, @field_name_dst, @record_count

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @sql = 'DELETE CC
				              FROM [' + @table_name + ']	CC
					          JOIN [' + @temp_table + ']	C
					            ON CC.[' + @field_name_dst + '] = C.[' + @field_name_src + ']'
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

				FETCH NEXT FROM delete_cursor INTO @table_name, @temp_table, @field_name_src, @field_name_dst, @record_count
			END

		CLOSE delete_cursor
		DEALLOCATE delete_cursor
			
--*************************************************************************************************
-- Manually delete the remaining records
--*************************************************************************************************
		SELECT @record_count = records FROM #Claim_Count WHERE table_name = 'EOC_Table'
		IF @record_count > 0
			BEGIN
				IF @delete_data = 1
					BEGIN
						DELETE E
						  FROM dbo.EOC_Table	E
						  JOIN #eoc				X 
							ON E.eoc_gid		= x.eoc_gid
					END

				EXEC dbo.spDDAuto_LogEvent @log_id, 'EOC_Table', @record_count, 'Delete', 0, ''
				IF @internal_delete = 0 PRINT SPACE(9) + LEFT('EOC_Table' + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
				IF @internal_delete = 1 
					BEGIN
						EXEC spFDAuto_LogTypeEvent @type_id, 'EOC_Table', @record_count, 'Deleted', 0, '' 
						EXEC spFCAuto_DeleteDisplayCounts 'EOC_Table', @record_count
					END
			END

		SELECT @record_count = records FROM #Claim_Count WHERE table_name = 'EOC_To_Claim_Line_Xref'
		IF @record_count > 0
			BEGIN
				IF @delete_data = 1
					BEGIN
						DELETE E
						  FROM dbo.EOC_To_Claim_Line_Xref	E
						  JOIN #eoc							X 
							ON e.eoc_gid					= x.eoc_gid
					END

				EXEC dbo.spDDAuto_LogEvent @log_id, 'EOC_To_Claim_Line_Xref', @record_count, 'Delete', 0, ''
				IF @internal_delete = 0 PRINT SPACE(9) + LEFT('EOC_To_Claim_Line_Xref' + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
				IF @internal_delete = 1  
					BEGIN
						EXEC spFDAuto_LogTypeEvent @type_id, 'EOC_To_Claim_Line_Xref', @record_count, 'Deleted', 0, '' 
						EXEC spFCAuto_DeleteDisplayCounts 'EOC_To_Claim_Line_Xref', @record_count
					END
			END

		SELECT @record_count = records FROM #Claim_Count WHERE table_name = 'File_Receive_Log_Details'
		IF @record_count > 0
			BEGIN
				IF @delete_data = 1
					BEGIN
						DELETE FD
						  FROM dbo.File_Receive_Log_Details	FD
						 WHERE FD.file_sid IN (SELECT FRL.file_sid
												 FROM File_Receive_Log	FRL
												WHERE FRL.file_name		= @filename)
					END
				EXEC dbo.spDDAuto_LogEvent @log_id, 'File_Receive_Log_Details', @record_count, 'Delete', 0, ''
				IF @internal_delete = 0 PRINT SPACE(9) + LEFT('File_Receive_Log_Details' + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
				IF @internal_delete = 1 
					BEGIN
						EXEC spFDAuto_LogTypeEvent @type_id, 'File_Receive_Log_Details', @record_count, 'Deleted', 0, '' 
						EXEC spFCAuto_DeleteDisplayCounts 'File_Receive_Log_Details', @record_count
					END
			END

		SELECT @record_count = records FROM #Claim_Count WHERE table_name = 'File_Receive_Log'
		IF @record_count > 0
			BEGIN
				IF @delete_data = 1
					BEGIN
						DELETE FRL
						  FROM dbo.File_Receive_Log		FRL
						 WHERE FRL.file_name			= @filename
					END
				EXEC dbo.spDDAuto_LogEvent @log_id, 'File_Receive_Log', @record_count, 'Delete', 0, ''
				IF @internal_delete = 0 PRINT SPACE(9) + LEFT('File_Receive_Log' + SPACE(62),62) + RIGHT(SPACE(10) + CONVERT(varchar(10), @record_count),10)
				IF @internal_delete = 1  
					BEGIN
							EXEC spFDAuto_LogTypeEvent @type_id, 'File_Receive_Log', @record_count, 'Deleted', 0, '' 
						EXEC spFCAuto_DeleteDisplayCounts 'File_Receive_Log', @record_count
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
  FROM #Claim_Count	CC

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
		IF @email_address <> ''
			BEGIN
				EXEC spDDAuto_EmailResults @log_id, @email_address
			END
	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#List_Files') IS NOT NULL	
	DROP TABLE #List_Files

IF OBJECT_ID('tempdb.dbo.#Claim') IS NOT NULL
	DROP TABLE #Claim

IF OBJECT_ID('tempdb.dbo.#Claim_Sid') IS NOT NULL
	DROP TABLE #Claim_Sid

IF OBJECT_ID('tempdb.dbo.#Claim_Table') IS NOT NULL
	DROP TABLE #Claim_Table

IF OBJECT_ID('tempdb.dbo.#Claim_Count') IS NOT NULL
	DROP TABLE #Claim_Count

IF OBJECT_ID('Tempdb.dbo.#eoc') IS NOT NULL
	DROP TABLE #eoc

END
GO