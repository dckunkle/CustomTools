IF OBJECT_ID('dbo.spDDAuto_LogEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_LogEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_LogEvent
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_LogEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_LogEvent
     (@log_id		INT
	 ,@table_name	VARCHAR(8000)
	 ,@record_count	INT
	 ,@status		VARCHAR(8000)
	 ,@err_num		INT
	 ,@err_msg		VARCHAR(8000))
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DDLogDetail
      (log_id
	  ,date_time
	  ,table_name
	  ,record_count
	  ,status
	  ,err_num
	  ,err_msg)
SELECT @log_id
      ,GETDATE()
	  ,@table_name
	  ,@record_count
	  ,@status
	  ,@err_num
	  ,@err_msg

END
GO