IF OBJECT_ID('dbo.spDDAuto_DeleteFileData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_DeleteFileData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_DeleteFileData
Purpose:    Read data from CoreAutomation and create the test data

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
01/13/2020	DK				Pass in the build number from Jenkins and use that instead of 
                            an IDENTITY field on the DClog table
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_DeleteFileData 'filename'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_DeleteFileData
     (@filename			VARCHAR(200)
	 ,@list_files		VARCHAR(10)		= 'false'
	 ,@email_address	VARCHAR(200)	= ''
	 ,@build_id			INT				= 1
	 ,@job_name			VARCHAR(200)	= '')
AS
BEGIN

SET NOCOUNT ON

DECLARE @filename25			VARCHAR(25)
	   ,@file_count			INT

	   ,@table_name			VARCHAR(255)
	   ,@record_count		INT
	   ,@sql				VARCHAR(4000)

	   ,@log_id				INT
	   ,@err_num			INT
	   ,@err_msg			VARCHAR(4000)

-- The user_id_created field is only 25 characters, so not all of the filename will be stored
SET @filename25 = @filename

--*************************************************************************************************
-- If the user selected a listing , show the listing and exit
--*************************************************************************************************
IF @list_files = 'true'
	BEGIN

		PRINT ''
		PRINT ''
		PRINT '-==============================================[ Listing of Files ]=================================================-'
		PRINT ''
		PRINT ''
		SELECT DISTINCT TOP 50
		       '[ ' AS [[]
              ,ERL.file_name AS [File Name]
			  ,CONVERT(VARCHAR(10), ERL.file_date, 101) AS [File Date]
			  ,' ]' AS [ ]]]
          FROM Elig_Load_Run_Log ERL
		 ORDER BY CONVERT(VARCHAR(10), ERL.file_date, 101) DESC

		PRINT ''
		PRINT ''
		PRINT '-===================================================================================================================-'
		PRINT ''
		PRINT ''
		PRINT ''

		GOTO CLEANUP

	END

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DDLog
      (user_id
	  ,entity_to_delete
	  ,entity_type
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT SUSER_NAME()
      ,@filename
	  ,'File'
	  ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Check to see if deleting data will impact more than one file (due to only the first 25 chars)
--*************************************************************************************************
;WITH CTE_Files
   AS(SELECT DISTINCT
             file_name
        FROM Elig_Load_Run_Log ERL
	   WHERE ERL.file_name LIKE @filename25 + '%'
	     AND ERL.record_status = 'A')
SELECT @file_count	= COUNT(*)
  FROM CTE_Files

IF (@file_count > 1)
	BEGIN
		SELECT @err_num = 100
		      ,@err_msg = 'The first 25 characters of the filename are not unique to a single file. Operation aborted.' 

		EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Error', @err_num, @err_msg

		GOTO CLEANUP
	END

--*************************************************************************************************
-- Create tables and populate with data that will be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#member_tables') IS NOT NULL
	DROP TABLE #member_tables

CREATE TABLE #member_tables
      (table_name	VARCHAR(255))

INSERT INTO #member_tables(table_name) VALUES ('Eligibility_Coverage')
INSERT INTO #member_tables(table_name) VALUES ('Demographics')
INSERT INTO #member_tables(table_name) VALUES ('Contact_Relation')
INSERT INTO #member_tables(table_name) VALUES ('Contacts')
INSERT INTO #member_tables(table_name) VALUES ('PCP_Assignment')
INSERT INTO #member_tables(table_name) VALUES ('Funding_Relation')
INSERT INTO #member_tables(table_name) VALUES ('Card_Print')
INSERT INTO #member_tables(table_name) VALUES ('Member_Salary')
INSERT INTO #member_tables(table_name) VALUES ('Member_Ancillary')
INSERT INTO #member_tables(table_name) VALUES ('Member_Verification')
INSERT INTO #member_tables(table_name) VALUES ('Entity_Paid_Thru')

IF OBJECT_ID('tempdb.dbo.#edi_tables') IS NOT NULL
	DROP TABLE #edi_tables

CREATE TABLE #edi_tables
      (table_name	VARCHAR(255))

INSERT INTO #edi_tables
      (table_name)
SELECT T.name
  FROM sys.tables T
 WHERE T.name LIKE 'edi834%'

IF OBJECT_ID('tempdb.dbo.#table_counts') IS NOT NULL
	DROP TABLE #table_counts

CREATE TABLE #table_counts
      (table_name	VARCHAR(255)
	  ,records		INT)

IF OBJECT_ID('tempdb.dbo.#transactions') IS NOT NULL
	DROP TABLE #transactions

CREATE TABLE #transactions
      (transaction_id NUMERIC(28,0))

INSERT INTO #transactions
      (transaction_id)
SELECT DISTINCT RL.transaction_id
  FROM Elig_Load_Run_Log RL
 WHERE RL.file_name = @filename

--************************************************************************************************
-- Loop through the membership tables to find data that should be deleted
--************************************************************************************************
DECLARE table_cursor CURSOR FOR
SELECT table_name
  FROM #member_tables

OPEN table_cursor
FETCH NEXT FROM table_cursor INTO @table_name

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = 'INSERT INTO #table_counts
		                  (table_name
						  ,records) 
				    SELECT ''' + @table_name + ''' AS TableName
					      ,COUNT(*) AS Count
		              FROM [' + @table_name + '] 
					 WHERE user_id_created LIKE ''' + @filename25 + ''''
		EXEC (@sql)

		FETCH NEXT FROM table_cursor INTO @table_name
	END

CLOSE table_cursor
DEALLOCATE table_cursor

--************************************************************************************************
-- Loop through the EDI tables to find data that should be deleted
--************************************************************************************************
DECLARE edi_table_cursor CURSOR FOR
SELECT table_name
  FROM #edi_tables

OPEN edi_table_cursor
FETCH NEXT FROM edi_table_cursor INTO @table_name

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = 'INSERT INTO #table_counts
		                  (table_name
						  ,records) 
				    SELECT ''' + @table_name + ''' AS TableName
					      ,COUNT(*) AS Count 
				      FROM [' + @table_name + '] X 
					  JOIN #transactions T 
					    ON X.transaction_id = T.transaction_id'
		EXEC (@sql)

		FETCH NEXT FROM edi_table_cursor INTO @table_name
	END

CLOSE edi_table_cursor
DEALLOCATE edi_table_cursor

--************************************************************************************************
-- Get counts of data to delete from special tables (Effectuation tables)
--************************************************************************************************
INSERT INTO #table_counts
      (table_name
	  ,records)
SELECT 'Effectuation_BLOB_Storage'	AS table_name
	  ,COUNT(*)						AS records 
  FROM Eligibility_Coverage			EC
  JOIN Effectuation_BLOB_Storage	BS
    ON EC.child_gid					= BS.child_gid
   AND EC.parent_gid				= BS.parent_gid
 WHERE EC.user_id_created			= @filename25 
   AND EC.record_status				= 'A'

INSERT INTO #table_counts
      (table_name
	  ,records)
SELECT 'Effectuation_Transaction_BLOB_Storage'	AS table_name
	  ,COUNT(*)									AS records
  FROM Eligibility_Coverage						EC
  JOIN Effectuation_BLOB_Storage				BS
    ON EC.child_gid								= BS.child_gid
   AND EC.parent_gid							= BS.parent_gid
  JOIN Effectuation_Transaction_BLOB_Storage	TBS
    ON BS.parent_guid							=TBS.guid
 WHERE EC.user_id_created						= @filename25 
   AND EC.record_status							= 'A'

INSERT INTO #table_counts
      (table_name
	  ,records)
SELECT 'Elig_Load_Run_Log'
      ,COUNT(*)
  FROM Elig_Load_Run_Log
 WHERE file_name = @filename

--*************************************************************************************************
-- Now delete the records and log the activity
--*************************************************************************************************
BEGIN TRY

	BEGIN TRANSACTION

		-- Delete data from Effectuation tables since they require the EC table to find the records to delete 
		DELETE TBS
		  FROM Eligibility_Coverage						EC
		  JOIN Effectuation_BLOB_Storage				BS
			ON EC.child_gid								= BS.child_gid
		   AND EC.parent_gid							= BS.parent_gid
		  JOIN Effectuation_Transaction_BLOB_Storage	TBS
			ON BS.parent_guid							=TBS.guid
		 WHERE EC.user_id_created						= @filename25 
		   AND EC.record_status							= 'A'

		SELECT @record_count = records FROM #table_counts WHERE table_name = 'Effectuation_Transaction_BLOB_Storage' 

		IF @record_count > 0 
			BEGIN
				EXEC dbo.spDDAuto_LogEvent @log_id, 'Effectuation_Transaction_BLOB_Storage', @record_count, 'Delete', 0, ''
				PRINT 'Deleted ' + CONVERT(varchar(10), @record_count) + ' records from the Effectuation_Transaction_BLOB_Storage table.'
			END

		DELETE BS
		  FROM Eligibility_Coverage						EC
		  JOIN Effectuation_BLOB_Storage				BS
			ON EC.child_gid								= BS.child_gid
		   AND EC.parent_gid							= BS.parent_gid
		 WHERE EC.user_id_created						= @filename25 
		   AND EC.record_status							= 'A'

		SELECT @record_count = records FROM #table_counts WHERE table_name = 'Effectuation_BLOB_Storage' 

		IF @record_count > 0
			BEGIN
				EXEC dbo.spDDAuto_LogEvent @log_id, 'Effectuation_BLOB_Storage', @record_count, 'Delete', 0, ''
				PRINT 'Deleted ' + CONVERT(varchar(10), @record_count) + ' records from the Effectuation_BLOB_Storage table.'
			END

		-- Loop through membership tables and delete the data
		DECLARE table_cursor CURSOR FOR
		 SELECT MT.table_name
			   ,TC.records
		   FROM #member_tables	MT
		   JOIN #table_counts	TC
			 ON MT.table_name	= TC.table_name

		OPEN table_cursor
		FETCH NEXT FROM table_cursor INTO @table_name, @record_count

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @sql = 'DELETE FROM [' + @table_name + '] WHERE user_id_created LIKE ''' + @filename25 + ''''
				EXEC (@sql)

				IF @record_count > 0 
					BEGIN
						EXEC dbo.spDDAuto_LogEvent @log_id, @table_name, @record_count, 'Delete', 0, ''
						PRINT 'Deleted ' + CONVERT(varchar(10), @record_count) + ' records from the ' + @table_name + ' table.'
					END

				FETCH NEXT FROM table_cursor INTO @table_name, @record_count
			END

		CLOSE table_cursor
		DEALLOCATE table_cursor

		-- Loop through EDI work tables and delete the data
		DECLARE edi_table_cursor CURSOR FOR
		 SELECT ET.table_name
			   ,TC.records
		   FROM #edi_tables		ET
		   JOIN #table_counts	TC
		     ON ET.table_name	= TC.table_name

		OPEN edi_table_cursor
		FETCH NEXT FROM edi_table_cursor INTO @table_name, @record_count

		WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @sql = 'DELETE X
								FROM [' + @table_name + '] X
								JOIN #transactions T 
								ON X.transaction_id = T.transaction_id'
				EXEC (@sql)

				IF @record_count > 0
					BEGIN
						EXEC dbo.spDDAuto_LogEvent @log_id, @table_name, @record_count, 'Delete', 0, ''
						PRINT 'Deleted ' + CONVERT(varchar(10), @record_count) + ' records from the ' + @table_name + ' table.'
					END

				FETCH NEXT FROM edi_table_cursor INTO @table_name, @record_count
			END

		CLOSE edi_table_cursor
		DEALLOCATE edi_table_cursor
			
		-- Finally, delete data from the Elig_Load_RunLog
		DELETE ERL
		  FROM Elig_Load_Run_Log	ERL
		 WHERE ERL.file_name		= @filename

		SELECT @record_count = records FROM #table_counts WHERE table_name = 'Elig_Load_Run_Log'
		EXEC dbo.spDDAuto_LogEvent @log_id, 'Elig_Load_Run_Log', @record_count, 'Delete', 0, ''
		PRINT 'Deleted ' + CONVERT(varchar(10), @record_count) + ' records from the Elig_Load_Run_Log table.'

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	SELECT @err_num	= ERROR_NUMBER()
	      ,@err_msg	= ERROR_MESSAGE()

	ROLLBACK TRANSACTION
	EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Delete', @err_num, @err_msg

END CATCH

--*************************************************************************************************
-- Finish the logging and send an email
--*************************************************************************************************
UPDATE DDLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

-- Now send an email with the results
EXEC spDDAuto_EmailResults @log_id, @email_address

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#member_tables') IS NOT NULL
	DROP TABLE #member_tables

IF OBJECT_ID('tempdb.dbo.#edi_tables') IS NOT NULL
	DROP TABLE #edi_tables

IF OBJECT_ID('tempdb.dbo.#table_counts') IS NOT NULL
	DROP TABLE #table_counts

IF OBJECT_ID('tempdb.dbo.#transactions') IS NOT NULL
	DROP TABLE #transactions

END
GO