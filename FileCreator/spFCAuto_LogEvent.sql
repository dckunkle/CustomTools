IF OBJECT_ID('dbo.spFCAuto_LogEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_LogEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_LogEvent
Purpose:    Used to log details to the FCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
03/12/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_LogEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_LogEvent
     (@log_id			INT
	 ,@testcase			VARCHAR(8000)
	 ,@method			VARCHAR(8000)
	 ,@filename			VARCHAR(8000)
	 ,@folder			VARCHAR(8000)
	 ,@expected_records	INT
	 ,@actualt_records	INT
	 ,@status			VARCHAR(8000)
	 ,@err_num			INT
	 ,@err_msg			VARCHAR(8000))
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO fw.FCLogDetail
      (log_id
	  ,date_time
	  ,testcase
	  ,method
	  ,filename
	  ,folder
	  ,expected_records
	  ,actual_records
	  ,status
	  ,err_num
	  ,err_msg)
SELECT @log_id
      ,GETDATE()
	  ,@testcase
	  ,@method
	  ,@filename
	  ,@folder
	  ,@expected_records
	  ,@actualt_records
	  ,@status
	  ,@err_num
	  ,@err_msg

END
GO