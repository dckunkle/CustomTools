IF OBJECT_ID('dbo.spDCAuto_LogEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_LogEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_LogEvent
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_LogEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_LogEvent
     (@log_id		INT
	 ,@testcase		VARCHAR(8000)
	 ,@method		VARCHAR(8000)
	 ,@record_id	INT				= 0
	 ,@key_data_1	VARCHAR(8000)
	 ,@key_data_2	VARCHAR(8000)
	 ,@key_data_3	VARCHAR(8000)
	 ,@status		VARCHAR(8000)
	 ,@err_num		INT
	 ,@err_msg		VARCHAR(8000))
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DCLogDetail
      (log_id
	  ,date_time
	  ,record_id
	  ,testcase
	  ,method
	  ,key_data_1
	  ,key_data_2
	  ,key_data_3
	  ,status
	  ,err_num
	  ,err_msg)
SELECT @log_id
      ,GETDATE()
	  ,ISNULL(@record_id, 0)
	  ,@testcase
	  ,@method
	  ,@key_data_1
	  ,@key_data_2
	  ,@key_data_3
	  ,@status
	  ,@err_num
	  ,@err_msg

END
GO