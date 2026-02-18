/**************************************************************************************************
Name:       spPortal_DeleteTableData
Purpose:    Delete any data in the given table that is older than the cutoff date
Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2022	DK				Original procedure
---------------------------------------------------------------------------------------------
IF @@TRANCOUNT > 0 BEGIN ROLLBACK TRANSACTION END
USE QA06_PORTAL ALTER TABLE USER_PREFERENCE CHECK CONSTRAINT ALL USE QA
***************************************************************************************************
EXEC spPortal_DeleteTableData 99, '20220101', 'PROVIDER_ID'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_DeleteTableData
      (@log_id			INT
	  ,@cutoff_date		DATE
	  ,@table_name		VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @has_delete				BIT				= 0
       ,@has_update				BIT				= 0
	   ,@err_msg				VARCHAR(8000)	= ''
	   ,@err_num				INT				= 0

	   ,@foreign_key_constraint	VARCHAR(200)
	   ,@is_disabled			BIT
	   ,@sql					VARCHAR(8000)

	   ,@enabled_keys_before	INT				= 0
	   ,@disabled_keys_before	INT				= 0
	   ,@enabled_keys_after		INT				= 0			
	   ,@disabled_keys_after	INT				= 0
	   ,@deleted_records		INT				= 0
	   ,@full_table_name		VARCHAR(4000)
	   ,@constraint_table		VARCHAR(200)
	   ,@days					INT
	   ,@update_field_name		VARCHAR(100)

--*************************************************************************************************
-- Guarantee the cutoff date is no closer than 60 days from today
--*************************************************************************************************
SELECT @days = DATEDIFF(DAY,@cutoff_date, GETDATE())

IF @days < 60 
	BEGIN
		SELECT @err_msg = 'To prevent the accidental deletion of too much data, the cutoff date cannot be less than 60 days from today''s date.'
		GOTO LOG_DATA
	END

--*************************************************************************************************
-- Make sure that the table being passed has the right fields to proceed, and set the update field name
--*************************************************************************************************
IF EXISTS(SELECT C.name FROM QA06_PORTAL.sys.tables T JOIN QA06_PORTAL.sys.columns C ON T.object_id = C.object_id WHERE C.name = 'DELETED' AND T.name = @table_name)
	BEGIN SELECT @has_delete = 1 END

IF EXISTS(SELECT C.name FROM QA06_PORTAL.sys.tables T JOIN QA06_PORTAL.sys.columns C ON T.object_id = C.object_id WHERE C.name = 'UPDATE_DATE' AND T.name = @table_name)
	BEGIN 
		SELECT @has_update = 1 
		      ,@update_field_name	= 'UPDATE_DATE'
	END

IF EXISTS(SELECT C.name FROM QA06_PORTAL.sys.tables T JOIN QA06_PORTAL.sys.columns C ON T.object_id = C.object_id WHERE C.name = 'updateDate' AND T.name = @table_name)
	BEGIN 
		SELECT @has_update			= 1 
		      ,@update_field_name	= 'updateDate'
	END

IF EXISTS(SELECT C.name FROM QA06_PORTAL.sys.tables T JOIN QA06_PORTAL.sys.columns C ON T.object_id = C.object_id WHERE C.name = 'REF_DATE' AND T.name = @table_name)
	BEGIN 
		SELECT @has_update			= 1 
		      ,@update_field_name	= 'REF_DATE'
	END

IF ((@has_delete = 0) OR (@has_update = 0))
	BEGIN
		SELECT @err_msg = 'The table, ' + @table_name + ', is missing fields that are required for this type of maintenance.'
		GOTO LOG_DATA
	END

--*************************************************************************************************
-- Determine if there are any check constraints that will block the delete
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#foreign_keys') IS NOT NULL
	BEGIN DROP TABLE #foreign_keys END

CREATE TABLE #foreign_keys
      (table_name				VARCHAR(200)
	  ,foreign_key_constraint	VARCHAR(200)
	  ,is_disabled				BIT)

SELECT @full_table_name = 'QA06_PORTAL.dbo.' + @table_name

INSERT INTO #foreign_keys
      (table_name
	  ,foreign_key_constraint
	  ,is_disabled)
SELECT T2.name
      ,FK.name
	  ,FK.is_disabled
  FROM QA06_PORTAL.sys.tables			T1
  JOIN QA06_PORTAL.sys.foreign_keys		FK    
    ON T1.object_id						= FK.parent_object_id
  JOIN QA06_PORTAL.sys.tables			T2
    ON FK.parent_object_id				= T2.object_id
 WHERE T1.name							= @table_name
    OR FK.referenced_object_id			= OBJECT_ID(@full_table_name)

SELECT @enabled_keys_before = COUNT(*)	FROM #foreign_keys WHERE is_disabled = 0
SELECT @disabled_keys_before = COUNT(*) FROM #foreign_keys WHERE is_disabled = 1

--*************************************************************************************************
-- Loop throught the foreign keys disabling them, if they should be disabled
--*************************************************************************************************
BEGIN TRY
	BEGIN TRANSACTION

		DECLARE Constraint_Cursor CURSOR FOR
		 SELECT table_name
		       ,foreign_key_constraint
			   ,is_disabled
		   FROM #foreign_keys
		  ORDER BY table_name

		   OPEN Constraint_Cursor
		  FETCH NEXT FROM Constraint_Cursor
		   INTO @constraint_table
		       ,@foreign_key_constraint
			   ,@is_disabled

		WHILE @@FETCH_STATUS = 0
			BEGIN

				IF @is_disabled = 0
					BEGIN
						SELECT @sql = 'USE QA06_PORTAL ALTER TABLE ' + @constraint_table + ' NOCHECK CONSTRAINT ' + @foreign_key_constraint + ' USE QA;'	
						--PRINT @sql
						EXEC(@sql)
					END
				FETCH NEXT FROM Constraint_Cursor
				 INTO @constraint_table
					 ,@foreign_key_constraint
					 ,@is_disabled

			END

		CLOSE Constraint_Cursor
		DEALLOCATE Constraint_Cursor
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH

	SELECT @err_msg = 'The foreign key constraints could not be disabled for the table, ' + @constraint_table + ', due to the following error: ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 BEGIN ROLLBACK TRANSACTION END
	
	CLOSE Constraint_Cursor
	DEALLOCATE Constraint_Cursor

	GOTO LOG_DATA

END CATCH

--*************************************************************************************************
-- Now that the foreign key constriants have been disabled, delete the data and save count
--*************************************************************************************************
BEGIN TRY

	SELECT @sql = 'DELETE FROM QA06_PORTAL.dbo.' + @table_name + ' WHERE DELETED = ''Y'' AND ' + @update_field_name + ' < ''' + CONVERT(VARCHAR(20), @cutoff_date, 112) + ''''
	EXEC(@sql)

	SELECT @deleted_records = @@ROWCOUNT

END TRY
BEGIN CATCH

	SELECT @err_msg = 'The data for the table, ' + @table_name + ', could not be deleted due to the following error: ' + ERROR_MESSAGE()

END CATCH

--*************************************************************************************************
-- Re-enable the foreign key constraints
--*************************************************************************************************
BEGIN TRY
	BEGIN TRANSACTION

		DECLARE Constraint_Cursor CURSOR FOR
		 SELECT table_name
		       ,foreign_key_constraint
			   ,is_disabled
		   FROM #foreign_keys
		  ORDER BY table_name

		   OPEN Constraint_Cursor
		  FETCH NEXT FROM Constraint_Cursor
		   INTO @constraint_table
		       ,@foreign_key_constraint
			   ,@is_disabled

		WHILE @@FETCH_STATUS = 0
			BEGIN

				IF @is_disabled = 0
					BEGIN
						SELECT @sql = 'USE QA06_PORTAL ALTER TABLE ' + @constraint_table + ' CHECK CONSTRAINT ' + @foreign_key_constraint + ' USE QA;'	
						--PRINT @sql
						EXEC(@sql)
					END
				FETCH NEXT FROM Constraint_Cursor
				 INTO @constraint_table
					 ,@foreign_key_constraint
					 ,@is_disabled

			END

		CLOSE Constraint_Cursor
		DEALLOCATE Constraint_Cursor
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH

	SELECT @err_msg = 'Attempting to re-enable the foreing key constraints for the table ,' + @constraint_table + ', faile due to the following error: ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 BEGIN ROLLBACK TRANSACTION END
		
	CLOSE Constraint_Cursor
	DEALLOCATE Constraint_Cursor

	GOTO LOG_DATA

END CATCH

--*************************************************************************************************
-- Get the foreign key constraint counts after to make sure they are the same as when we started
--*************************************************************************************************
SELECT @enabled_keys_after				= COUNT(*)
  FROM QA06_PORTAL.sys.tables			T1
  JOIN QA06_PORTAL.sys.foreign_keys		FK    
    ON T1.object_id						= FK.parent_object_id
  JOIN QA06_PORTAL.sys.tables			T2
    ON FK.parent_object_id				= T2.object_id
 WHERE (T1.name							= @table_name
    OR FK.referenced_object_id			= OBJECT_ID(@full_table_name))
   AND FK.is_disabled					= 0

SELECT @disabled_keys_after				= COUNT(*)
  FROM QA06_PORTAL.sys.tables			T1
  JOIN QA06_PORTAL.sys.foreign_keys		FK    
    ON T1.object_id						= FK.parent_object_id
  JOIN QA06_PORTAL.sys.tables			T2
    ON FK.parent_object_id				= T2.object_id
 WHERE (T1.name							= @table_name
    OR FK.referenced_object_id			= OBJECT_ID(@full_table_name))
   AND FK.is_disabled					= 1

--SELECT @disabled_keys_after			= COUNT(*)
--  FROM QA06_PORTAL.sys.tables		T
--  JOIN QA06_PORTAL.sys.foreign_keys	FK
--    ON T.object_id					= FK.parent_object_id
-- WHERE FK.is_disabled				= 1
--   AND T.name						= @table_name

--*************************************************************************************************
-- Log the results
--*************************************************************************************************
LOG_DATA:
IF @err_msg <> '' BEGIN SELECT @err_num = 100 END

INSERT INTO DRLogDetail
      (log_id
	  ,date_time
	  ,delete_type
	  ,table_name
	  ,cutoff_date
	  ,enabled_fk_before
	  ,disabled_fk_before
	  ,enabled_fk_after
	  ,disabled_fk_after
	  ,records
	  ,err_num
	  ,err_msg)
SELECT @log_id
      ,GETDATE()
	  ,'Delete By Date'
	  ,@table_name
	  ,CONVERT(VARCHAR(20), @cutoff_date, 101)
	  ,@enabled_keys_before
	  ,@disabled_keys_before
	  ,@enabled_keys_after
	  ,@disabled_keys_after
	  ,@deleted_records
	  ,@err_num
	  ,@err_msg

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#foreign_keys') IS NOT NULL
	BEGIN DROP TABLE #foreign_keys END

END
GO