/**************************************************************************************************
Name:       spPortal_MaintainHistoricalData
Purpose:    Remove records in the Policy related tables in the portal database

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_MaintainHistoricalData 1200
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_MaintainHistoricalData
      (@days		INT	= 30
	  ,@log_id		INT	= 999)
AS
BEGIN
SET NOCOUNT ON

DECLARE @category			VARCHAR(20)			= 'Historical'
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
-- Create temp tables to store the tables to be reviewed
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

CREATE TABLE #table_deletes
      (table_name					VARCHAR(256))

--*************************************************************************************************
-- Populate the deletes table with tables to delete
--*************************************************************************************************
INSERT INTO #table_deletes (table_name) VALUES ('ADDTL_PATIENT_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('ADDTL_SERVICE_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_DIAGNOSIS_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_MEMBER_ID_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_OTHER_UMO_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_PATIENT_TRANSPORT_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_REQUESTER_ID_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_SERVICE_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_SERVICE_PROV_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_SERVICE_PROV_ID_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('AUTH_TOOTH_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('COMM_CONTACT_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('HCARE_SERVICES_DELIVERY_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('HCARE_SVC_DELIVERY_REQ_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('HCARE_SVC_DELIVERY_USED_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('HEALTH_CARE_CODE_INFO_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('PATIENT_CONDITION_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('REQUEST_HIST')
INSERT INTO #table_deletes (table_name) VALUES ('UMO_DENIAL_HIST')

--*************************************************************************************************
-- Delete data using the proper delete order and for the right IDs
--*************************************************************************************************
BEGIN TRY
		
	DECLARE table_delete_cursor CURSOR FOR
	SELECT TC.table_name
    FROM #table_deletes			TC
	JOIN DeleteOrder			DO
		ON TC.table_name		= DO.table_name
	ORDER BY DO.table_level DESC
		    ,DO.table_name  DESC

	OPEN table_delete_cursor
    FETCH NEXT FROM table_delete_cursor INTO @table_name

	WHILE @@FETCH_STATUS = 0
		BEGIN

			SELECT @sql = 'DELETE ' + @table_name
					    + ' WHERE HIST_ENTRY_DATE < ''' + CONVERT(VARCHAR(20), @cutoff_date) + ''''
						+ '   AND DELETED = ''Y'''
			BEGIN TRY

				--PRINT @sql
				EXEC (@sql)
				SELECT @records = @@ROWCOUNT
				IF @records <> 0 BEGIN EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'HIST_ENTRY_DATE Match', @table_name, @records END

			END TRY
			BEGIN CATCH

				SELECT @err_msg = ERROR_MESSAGE()
				      ,@err_num = 100
				EXEC spPortal_DeleteRecordLogDetail @log_id, @category, 'HIST_ENTRY_DATE Match', @table_name, @records, @err_num, @err_msg

			END CATCH


			FETCH NEXT FROM table_delete_cursor INTO @table_name
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
IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

END
GO