/**************************************************************************************************
Name:       spPortal_MaintainPolicyData
Purpose:    Remove records in the Policy related tables in the portal database

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_MaintainPolicyData 1262
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_MaintainPolicyData
      (@days		INT	= 30
	  ,@log_id		INT	= 999)
AS
BEGIN
SET NOCOUNT ON

DECLARE @category			VARCHAR(20)			= 'Policy'
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
IF OBJECT_ID('tempdb.dbo.#policy_ids') IS NOT NULL
	BEGIN DROP TABLE #policy_ids END

CREATE TABLE #policy_ids
      (POLICY_ID				NUMERIC(18,0))

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

IF OBJECT_ID('tempdb.dbo.#policy_benefit_ids') IS NOT NULL
	BEGIN DROP TABLE #policy_benefit_ids END

CREATE TABLE #policy_benefit_ids
      (POLICY_BENEFIT_ID				NUMERIC(18,0))

CREATE TABLE #table_deletes
      (table_name					VARCHAR(256)
	  ,check_ids					BIT)

--*************************************************************************************************
-- Populate the mail IDs to specifically look for and delete
--*************************************************************************************************
INSERT INTO #policy_ids
      (POLICY_ID)
SELECT X.POLICY_ID
  FROM dbo.POLICY		X
 WHERE X.DELETED		= 'Y'
   AND X.ENTRY_DATE		< @cutoff_date

INSERT INTO #policy_benefit_ids
      (POLICY_BENEFIT_ID)
SELECT X.POLICY_BENEFIT_ID
  FROM POLICY_BENEFIT		X
  JOIN #policy_ids			P
    ON X.POLICY_ID			= P.POLICY_ID

--*************************************************************************************************
-- Populate the deletes table with tables to delete
--*************************************************************************************************
DELETE FROM #table_deletes
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('POLICY_BENEFIT', 0)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('POLICY_BENEFIT_NETWORK', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('ELIGIBILITY_BENEFIT', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('X12_HEALTH_COVERAGE', 1)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('CLAIM_SUBSCRIBER', 1)

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
					            + '  FROM #policy_benefit_ids X '
							    + '  JOIN ' + @table_name + ' TN '
								+ '    ON X.POLICY_BENEFIT_ID = TN.POLICY_BENEFIT_ID'
					BEGIN TRY
						--PRINT @sql
						EXEC (@sql)
						SELECT @records = @@ROWCOUNT
						IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'POLICY_BENEFIT_ID Match', @table_name, @records END

					END TRY
					BEGIN CATCH

						SELECT @err_msg = ERROR_MESSAGE()
						      ,@err_num = 100
						EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'POLICY_BENEFIT_ID Match', @table_name, @records, @err_num, @err_msg

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
-- Populate the deletes table with tables to delete
--*************************************************************************************************
DELETE FROM #table_deletes
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('POLICY', 0)
INSERT INTO #table_deletes (table_name, check_ids) VALUES ('POLICY_BENEFIT', 1)

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
					            + '  FROM #policy_ids X '
							    + '  JOIN ' + @table_name + ' TN '
								+ '    ON X.POLICY_ID = TN.POLICY_ID'
					BEGIN TRY
						--PRINT @sql
						EXEC (@sql)
						SELECT @records = @@ROWCOUNT
						IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'POLICY_ID Match', @table_name, @records END

					END TRY
					BEGIN CATCH

						SELECT @err_msg = ERROR_MESSAGE()
						      ,@err_num = 100
						EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'POLICY_ID Match', @table_name, 0, @err_num, @err_msg

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
IF OBJECT_ID('tempdb.dbo.#policy_ids') IS NOT NULL
	BEGIN DROP TABLE #policy_ids END

IF OBJECT_ID('tempdb.dbo.#policy_benefit_ids') IS NOT NULL
	BEGIN DROP TABLE #policy_benefit_ids END

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

END
GO