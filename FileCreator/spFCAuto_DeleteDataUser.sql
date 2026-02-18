IF OBJECT_ID('dbo.spFCAuto_DeleteDataUser') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteDataUser AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteDataUser
Purpose:    Used to delete any existing data for a data import file using a specific user ID

Date        User            Change
---------------------------------------------------------------------------------------------
07/30/2020	DK				Original procedure
06/11/2021  DK				Added cutoff date to ignore previously loaded data
07/24/2023  DK				Added 275Attachment for delete           
11/27/2023	DK				Changed table name from 275Attachment to Attachment275ClaimDetails
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteDataUser 'ConvNFSPR'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteDataUser
     (@user_id			VARCHAR(200)
	 ,@data_deleted		BIT				= 0		OUTPUT
	 ,@type_id			INT				= 0)
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql			VARCHAR(8000)
	   ,@table_name		VARCHAR(256)
	   ,@field_name_src	VARCHAR(256)
	   ,@field_name_dst	VARCHAR(256)
	   ,@database_name	VARCHAR(128)
	   ,@record_count	VARCHAR(20)
	   ,@err_num		INT
	   ,@err_msg		INT

	   ,@cutoff_date	VARCHAR(20)		= '2020/01/01'

--*************************************************************************************************
-- Determine the database name for the Core data
--*************************************************************************************************
SELECT @database_name = dbo.fnQAAuto_GetDatabaseName()

--*************************************************************************************************
-- Create tables to hold the table names, record counts, etc.
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TableNames') IS NOT NULL
	BEGIN DROP TABLE #TableNames END

CREATE TABLE #TableNames
      (table_name VARCHAR(256))

IF OBJECT_ID('tempdb.dbo.#TableNameCounts') IS NOT NULL
	BEGIN DROP TABLE #TableNameCounts END

CREATE TABLE #TableNameCounts
      (table_name VARCHAR(256)
	  ,record_count INT)

IF OBJECT_ID('tempdb.dbo.#ProtectedTables') IS NOT NULL
	BEGIN DROP TABLE #ProtectedTables END

CREATE TABLE #ProtectedTables
      (table_name VARCHAR(256))

IF OBJECT_ID('tempdb.dbo.#ClaimTables') IS NOT NULL
	BEGIN DROP TABLE #ClaimTables END

CREATE TABLE #ClaimTables
      (table_name		VARCHAR(256)
	  ,field_name_src	VARCHAR(256)
	  ,field_name_dst	VARCHAR(256))

IF OBJECT_ID('tempdb.dbo.#Claims') IS NOT NULL
	BEGIN DROP TABLE #Claims END

CREATE TABLE #Claims
      (claim_number VARCHAR(15)
	  ,claim_sid	INT)

IF OBJECT_ID('tempdb.dbo.#GroupTables') IS NOT NULL
	BEGIN DROP TABLE #GroupTables END

CREATE TABLE #GroupTables
      (table_name		VARCHAR(256)
	  ,field_name_src	VARCHAR(256)
	  ,field_name_dst	VARCHAR(256))

IF OBJECT_ID('tempdb.dbo.#GroupsToDelete') IS NOT NULL
	BEGIN DROP TABLE #GroupsToDelete END

CREATE TABLE #GroupsToDelete
      (group_gid	INT
	  ,child_gid	INT
	  ,parent_gid	INT)

--*************************************************************************************************
-- Find all Core tables that have the user_id_created field in them
--*************************************************************************************************
SET @sql = 'INSERT INTO #TableNames
                  (table_name)
            SELECT T.name
              FROM ' + @database_name + '.sys.tables	T
              JOIN ' + @database_name + '.sys.columns	C
                ON T.object_id = C.object_id
             WHERE C.name = ''user_id_created'''
EXEC (@sql)

--*************************************************************************************************
-- Capture the gids for all of the groups that will be deleted. The gids will be used to delete ancillary data
--*************************************************************************************************
SET @sql = 'INSERT INTO #GroupsToDelete 
                  (group_gid
	              ,child_gid
				  ,parent_gid)
            SELECT group_gid
			      ,child_gid
				  ,parent_gid
             FROM ' + @database_name + '.dbo.Eligibility_Coverage
            WHERE user_id LIKE ''' + @user_id + '''
			  AND child_identifier = ''G''
			  AND parent_identifier = ''G'''

EXEC (@sql)

--************************************************************************************************
-- Remove any protected tables from consideration while deleting data
--************************************************************************************************
INSERT INTO #ProtectedTables (table_name) VALUES ('Global_Values')

DELETE #TableNames
  FROM #TableNames		T
  JOIN #ProtectedTables	R
    ON T.table_name		= R.table_name

--************************************************************************************************
-- Loop through the remaining tables to see if there is any automation data to delete, get counts
--************************************************************************************************
BEGIN TRY

	DECLARE table_cursor CURSOR FOR
	SELECT table_name
	  FROM #TableNames

	OPEN table_cursor
	FETCH NEXT FROM table_cursor INTO @table_name

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @sql = 'INSERT INTO #TableNameCounts(table_name, record_count) SELECT ''' + @table_name + 
					   ''' AS TableName, COUNT(*) AS Count FROM ' + @database_name + '.dbo.[' + @table_name + '] WHERE user_id_created = ''' + @user_id + '''' --AND date_time_created > ''' + @cutoff_date + ''''

			EXEC (@sql)

			FETCH NEXT FROM table_cursor INTO @table_name
		END

	CLOSE table_cursor
	DEALLOCATE table_cursor

--*************************************************************************************************
-- Delete the records that were created by the automation process
--*************************************************************************************************

	DECLARE table_count_cursor CURSOR FOR
	 SELECT table_name
		   ,record_count
	   FROM #TableNameCounts
	  WHERE record_count > 0
	  ORDER BY table_name

	   OPEN table_count_cursor
	  FETCH NEXT FROM table_count_cursor INTO @table_name, @record_count

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @data_deleted = 1

			SET @sql = 'DELETE FROM ' + @database_name + '.dbo.[' + @table_name + '] WHERE user_id_created LIKE ''' + @user_id + '''' --AND date_time_created > ''' + @cutoff_date + ''''
			EXEC (@sql)

			SET @record_count = @@ROWCOUNT
			EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
			EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

			FETCH NEXT FROM table_count_cursor INTO @table_name, @record_count
		END

	CLOSE table_count_cursor
	DEALLOCATE table_count_cursor
END TRY
BEGIN CATCH

	SELECT @err_num = 100
	      ,@err_msg = @table_name + ' no records deleted due to: ' + ERROR_MESSAGE()

	EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Error', @err_num,@err_msg
	PRINT '         ' + @err_msg

END CATCH

--*************************************************************************************************
-- Secondary process to delete claims data
--*************************************************************************************************
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Log_V2'						,'claim_number'	, 'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Detail_V2'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Xref'							,'claim_number'	,'Orig_Claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Documentation'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Header_Entry'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Line_Items_Entry_V2'			,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Log_Message'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Rollback_Log'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Document_Import'						,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Auth_XRef'						,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Member_Clinical_History'				,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('EOC_CLAIM_LINE_STAGING'				,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('EOC_To_Claim_Line_Xref'				,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('WorkFlow_Process'					,'claim_number'	,'supporting_data')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_CAS_Line_Adjustments_Entry'	,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Pre_RFF_Details'						,'claim_sid'	,'claim_sid')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Ancillary'					,'claim_sid'	,'claim_sid')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Occur_Codes'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Provider_Data'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_Value_Codes'					,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_HP_Lines'						,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claim_HP_Tiers'						,'claim_number'	,'claim_number')
INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Claims_Repricing_Log'				,'claim_number'	,'claim_number')

INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('Attachment275ClaimDetails'			,'claim_number'	, 'ClaimNumber')
--INSERT INTO #ClaimTables (table_name, field_name_src, field_name_dst) VALUES ('275Attachment'			,'claim_number'	, 'ClaimNumber')

-- Build a list of the claims that need to be deleted
SET @sql = 'INSERT INTO #Claims 
                  (claim_number
	              ,claim_sid)
            SELECT claim_number
			      ,claim_sid
             FROM ' + @database_name + '.dbo.Claims_Log_V2
            WHERE user_id = ''' + @user_id + '''  AND receive_date > ''' + @cutoff_date + ''''

			EXEC (@sql)

--*************************************************************************************************
-- Begin deleting claims data
--*************************************************************************************************
BEGIN TRY

	DECLARE claims_cursor CURSOR FOR
	SELECT table_name
	      ,field_name_src
		  ,field_name_dst
	  FROM #ClaimTables
	 ORDER BY table_name

	OPEN claims_cursor
	FETCH NEXT FROM claims_cursor INTO @table_name, @field_name_src, @field_name_dst

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @sql = 'DELETE CT
			              FROM ' + @database_name + '.dbo.[' + @table_name + ']	CT
						  JOIN #Claims	CL 
						    ON CT.[' + @field_name_dst + '] = CL.[' + @field_name_src + ']'
			EXEC (@sql)

			SET @record_count = @@ROWCOUNT

			IF @record_count > 0
				BEGIN
					
					SET @data_deleted = 1
					EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
					EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

				END

			FETCH NEXT FROM claims_cursor INTO @table_name,  @field_name_src, @field_name_dst
		END

	CLOSE claims_cursor
	DEALLOCATE claims_cursor

END TRY
BEGIN CATCH

	SELECT @err_num = 100
	      ,@err_msg = @table_name + ' no records deleted due to: ' + ERROR_MESSAGE()

	EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Error', @err_num,@err_msg
	PRINT '         ' + @err_msg

END CATCH

--*************************************************************************************************
-- Begin deleting group data
--*************************************************************************************************
SELECT @sql				= ''
      ,@table_name		= ''
	  ,@field_name_dst	= ''
	  ,@field_name_src	= ''

INSERT INTO #GroupTables (table_name, field_name_src, field_name_dst) VALUES ('GroupTree', 'child_gid', 'child_gid')

BEGIN TRY

	DECLARE group_cursor CURSOR FOR
	SELECT table_name
	      ,field_name_src
		  ,field_name_dst
	  FROM #GroupTables
	 ORDER BY table_name

	OPEN group_cursor
	FETCH NEXT FROM group_cursor INTO @table_name, @field_name_src, @field_name_dst

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @sql = 'DELETE GT
			              FROM ' + @database_name + '.dbo.[' + @table_name + ']	GT
						  JOIN #GroupsToDelete	GL 
						    ON GT.[' + @field_name_dst + '] = GL.[' + @field_name_src + ']'
			EXEC (@sql)

			SET @record_count = @@ROWCOUNT

			IF @record_count > 0
				BEGIN

					SET @data_deleted = 1
					EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
					EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

				END

			FETCH NEXT FROM group_cursor INTO @table_name,  @field_name_src, @field_name_dst
		END

	CLOSE group_cursor
	DEALLOCATE group_cursor

END TRY
BEGIN CATCH

	SELECT @err_num = 100
	      ,@err_msg = @table_name + ' no records deleted due to: ' + ERROR_MESSAGE()

	EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Error', @err_num,@err_msg
	PRINT '         ' + @err_msg

END CATCH
--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CONFIG_ERROR:

IF OBJECT_ID('tempdb.dbo.#TableNames') IS NOT NULL
	BEGIN DROP TABLE #TableNames END

IF OBJECT_ID('tempdb.dbo.#TableNameCounts') IS NOT NULL
	BEGIN DROP TABLE #TableNameCounts END

IF OBJECT_ID('tempdb.dbo.#ProtectedTables') IS NOT NULL
	BEGIN DROP TABLE #ProtectedTables END

IF OBJECT_ID('tempdb.dbo.#ClaimTables') IS NOT NULL
	BEGIN DROP TABLE #ClaimTables END

IF OBJECT_ID('tempdb.dbo.#Claims') IS NOT NULL
	BEGIN DROP TABLE #Claims END

IF OBJECT_ID('tempdb.dbo.#GroupTables') IS NOT NULL
	BEGIN DROP TABLE #GroupTables END

IF OBJECT_ID('tempdb.dbo.#GroupsToDelete') IS NOT NULL
	BEGIN DROP TABLE #GroupsToDelete END

END
GO