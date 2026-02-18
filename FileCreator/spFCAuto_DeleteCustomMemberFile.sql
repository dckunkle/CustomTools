IF OBJECT_ID('dbo.spFCAuto_DeleteCustomMemberFile') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustomMemberFile AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustomMemberFile
Purpose:    Delete data that was loaded by a Member Conversionfile

Date        User            Change
---------------------------------------------------------------------------------------------
11/03/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomMemberFile 'Member_Import_202011030240.txt'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustomMemberFile
     (@filename		VARCHAR(200)	
	 ,@err_num		INT				= 0		OUTPUT
	 ,@err_msg		VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id		INT				= 99)
AS
BEGIN

SET NOCOUNT ON

DECLARE @table_name			VARCHAR(255)
	   ,@record_count		INT
	   ,@sql				VARCHAR(4000)

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
					 WHERE user_id_created LIKE ''' + @filename + ''''
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
 WHERE EC.user_id_created			= @filename
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
 WHERE EC.user_id_created						= @filename
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
		 WHERE EC.user_id_created						= @filename
		   AND EC.record_status							= 'A'

		SELECT @record_count = records FROM #table_counts WHERE table_name = 'Effectuation_Transaction_BLOB_Storage' 

		IF @record_count > 0 
			BEGIN
				EXEC spFDAuto_LogTypeEvent @type_id, 'Effectuation_Transaction_BLOB_Storage', @record_count, 'Deleted', 0, ''
				EXEC spFCAuto_DeleteDisplayCounts 'Effectuation_Transaction_BLOB_Storage', @record_count
			END

		DELETE BS
		  FROM Eligibility_Coverage						EC
		  JOIN Effectuation_BLOB_Storage				BS
			ON EC.child_gid								= BS.child_gid
		   AND EC.parent_gid							= BS.parent_gid
		 WHERE EC.user_id_created						= @filename
		   AND EC.record_status							= 'A'

		SELECT @record_count = records FROM #table_counts WHERE table_name = 'Effectuation_BLOB_Storage' 

		IF @record_count > 0
			BEGIN
				EXEC spFDAuto_LogTypeEvent @type_id, 'Effectuation_BLOB_Storage', @record_count, 'Deleted', 0, ''
				EXEC spFCAuto_DeleteDisplayCounts 'Effectuation_BLOB_Storage', @record_count
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

				SET @sql = 'DELETE FROM [' + @table_name + '] WHERE user_id_created LIKE ''' + @filename + ''''
				EXEC (@sql)

				IF @record_count > 0 
					BEGIN
						EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
						EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count
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
						EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count
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
		EXEC spFDAuto_LogTypeEvent @type_id, 'Elig_Load_Run_Log', @record_count, 'Deleted', 0, ''
		EXEC spFCAuto_DeleteDisplayCounts 'Elig_Load_Run_Log', @record_count

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	SELECT @err_num	= ERROR_NUMBER()
	      ,@err_msg	= ERROR_MESSAGE()

	ROLLBACK TRANSACTION
	
	EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Error', @err_num, @err_msg

END CATCH

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