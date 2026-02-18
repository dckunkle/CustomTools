/**************************************************************************************************
Name:       spPortal_MaintainMailData
Purpose:    Remove records in the Mail related tables in the portal database

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_MaintainMailData 1050
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_MaintainMailData
      (@days		INT	= 30
	  ,@log_id		INT	= 999)
AS
BEGIN
SET NOCOUNT ON

DECLARE @category			VARCHAR(20)			= 'Mail'
       ,@sql				VARCHAR(8000)
	   ,@table_name			VARCHAR(256)
	   ,@check_ids			BIT
	   ,@cutoff_date		DATE
	   ,@err_num			INT
	   ,@err_msg			VARCHAR(8000)
	   ,@records			INT
	   
--*************************************************************************************************
-- Calculate the cutoff date
--*************************************************************************************************
SELECT @cutoff_date = DATEADD(day, -@days, GETDATE())

--*************************************************************************************************
-- Create Provider tables
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#mail_ids') IS NOT NULL
	BEGIN DROP TABLE #mail_ids END

CREATE TABLE #mail_ids
      (MAIL_ID					NUMERIC(18,0))

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

CREATE TABLE #table_deletes
      (table_name					VARCHAR(256)
	  ,check_ids					BIT)

--*************************************************************************************************
-- Populate the deletes table with tables to delete
--*************************************************************************************************
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MAIL',0)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MAIL_ATTACHMENTS',1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MAIL_USER',1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MAIL_CONTACT_LIST',0)

--*************************************************************************************************
-- Populate the mail IDs to specifically look for and delete
--*************************************************************************************************
INSERT INTO #mail_ids
      (MAIL_ID)
SELECT M.MAIL_ID
  FROM MAIL			M
 WHERE M.DELETED		= 'Y'
   AND M.ENTRY_DATE		< @cutoff_date

--*************************************************************************************************
-- Delete data using the proper delete order and for the right IDs
--*************************************************************************************************
BEGIN TRY
		
	DECLARE table_delete_cursor CURSOR FOR
	SELECT TC.table_name
		  ,TC.check_ids
    FROM #table_deletes			TC
	JOIN DeleteOrder			DO
		ON TC.table_name		= DO.table_name
	ORDER BY DO.table_level DESC
		    ,DO.table_name  DESC

	OPEN table_delete_cursor
    FETCH NEXT FROM table_delete_cursor INTO @table_name, @check_ids

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF @check_ids <> ''
				BEGIN

					SELECT @sql = 'DELETE TN '
					            + '  FROM #mail_ids M '
							    + '  JOIN ' + @table_name + ' TN '
								+ '    ON M.MAIL_ID = TN.MAIL_ID'
					BEGIN TRY

						EXEC (@sql)
						SELECT @records = @@ROWCOUNT
						IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'MAIL_ID Match', @table_name, @records END

					END TRY
					BEGIN CATCH

						SELECT @err_msg = ERROR_MESSAGE()
						      ,@err_num = 100
						EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'MAIL_ID Match', @table_name, @records, @err_num, @err_msg

					END CATCH
				END

			SELECT @sql = 'DELETE ' + @table_name
					    + ' WHERE ENTRY_DATE < ''' + CONVERT(VARCHAR(20), @cutoff_date) + ''''
						+ '   AND DELETED = ''Y'''
			BEGIN TRY

				EXEC (@sql)
				SELECT @records = @@ROWCOUNT
				IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'ENTRY_DATE Match', @table_name, @records END

			END TRY
			BEGIN CATCH

				SELECT @err_msg = ERROR_MESSAGE()
				      ,@err_num = 100
				EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'ENTRY_DATE Match', @table_name, @records, @err_num, @err_msg

			END CATCH


			FETCH NEXT FROM table_delete_cursor INTO @table_name, @check_ids
		END

	CLOSE table_delete_cursor
	DEALLOCATE table_delete_cursor
END TRY
BEGIN CATCH

	PRINT ERROR_MESSAGE()
	CLOSE table_count_cursor
	DEALLOCATE table_count_cursor

END CATCH

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#mail_ids') IS NOT NULL
	BEGIN DROP TABLE #mail_ids END

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

END
GO