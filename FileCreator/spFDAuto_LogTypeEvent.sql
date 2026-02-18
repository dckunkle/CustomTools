IF OBJECT_ID('dbo.spFDAuto_LogTypeEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFDAuto_LogTypeEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFDAuto_LogTypeEvent
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFDAuto_LogTypeEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFDAuto_LogTypeEvent
     (@type_id		INT
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
INSERT INTO FDLogTypeDetail
      (type_id
	  ,date_time
	  ,table_name
	  ,record_count
	  ,status
	  ,err_num
	  ,err_msg)
SELECT @type_id
      ,GETDATE()
	  ,@table_name
	  ,@record_count
	  ,@status
	  ,@err_num
	  ,@err_msg

END
GO