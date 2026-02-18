/**************************************************************************************************
Name:       spPortal_MaintainMemberData
Purpose:    Remove records in the Member related tables in the portal database

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_MaintainMemberData 601
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_MaintainMemberData
      (@days		INT	= 30
	  ,@log_id		INT	= 999)
AS
BEGIN
SET NOCOUNT ON

DECLARE @category			VARCHAR(20)			= 'Member'
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
IF OBJECT_ID('tempdb.dbo.#member_ids') IS NOT NULL
	BEGIN DROP TABLE #member_ids END

CREATE TABLE #member_ids
      (MEMBER_ID					NUMERIC(18,0))

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

CREATE TABLE #table_deletes
      (table_name					VARCHAR(256)
	  ,check_ids					BIT)

--*************************************************************************************************
-- Populate the deletes table with tables to delete
--*************************************************************************************************
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER', 0)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_ALLERGY', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_ATTRIBUTE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_ATTRIBUTE_ID', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_BROKER', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_COB', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_CONTACT', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_DIAGNOSIS', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_FAMILY_HEALTH', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_HEALTH_HISTORY', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_HEALTH_STATS', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_ID', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_IMMUNIZATION', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_INSURANCE_INFO', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_INTERVENTION', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_LANGUAGE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_LIST_DETAILS', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_MEDICATIONS', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PERSONAL_INFO', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PREMIUM', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PREVENTATIVE_CARE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PROCEDURE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PROVIDER', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_PROVIDER_INFO', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_SERVICE_HISTORY', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('MEMBER_SHARE_PREFERENCES', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('NOTIFICATION_HISTORY', 1)

INSERT INTO #table_deletes (table_name, check_ids) VALUES ('ELIGIBILITY', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('EMPLOYEE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('FILE_DETAIL_ASSOCIATION', 1)

--*************************************************************************************************
-- Populate the mail IDs to specifically look for and delete
--*************************************************************************************************
INSERT INTO #member_ids
      (MEMBER_ID)
SELECT M.MEMBER_ID
  FROM MEMBER			M
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
					            + '  FROM #member_ids X '
							    + '  JOIN ' + @table_name + ' TN '
								+ '    ON X.MEMBER_ID = TN.MEMBER_ID'
					BEGIN TRY
						--PRINT @sql
						EXEC (@sql)
						SELECT @records = @@ROWCOUNT
						IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'MEMBER_ID Match', @table_name, @records END

					END TRY
					BEGIN CATCH

						SELECT @err_msg = ERROR_MESSAGE()
						      ,@err_num = 100
						EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'MEMBER_ID Match', @table_name, 0, @err_num, @err_msg

					END CATCH
				END

			SELECT @sql = 'DELETE ' + @table_name
					    + ' WHERE ENTRY_DATE < ''' + CONVERT(VARCHAR(20), @cutoff_date) + ''''
						+ '   AND DELETED = ''Y'''
			BEGIN TRY

				--PRINT @sql
				EXEC (@sql)
				SELECT @records = @@ROWCOUNT
				IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'ENTRY_DATE Match', @table_name, @records END

			END TRY
			BEGIN CATCH

				SELECT @err_msg = ERROR_MESSAGE()
				      ,@err_num = 100
				EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'ENTRY_DATE Match', @table_name, 0, @err_num, @err_msg

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
IF OBJECT_ID('tempdb.dbo.#member_ids') IS NOT NULL
	BEGIN DROP TABLE #member_ids END

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

END
GO