IF OBJECT_ID('dbo.spFDAuto_LogEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFDAuto_LogEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFDAuto_LogEvent
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
05/24/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFDAuto_LogEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFDAuto_LogEvent
     (@log_id		INT
	 ,@delete_type	VARCHAR(100)
	 ,@delete_name	VARCHAR(100)
	 ,@delete_data	VARCHAR(100)
	 ,@type_id		INT OUTPUT)
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO FDLogType
      (log_id
	  ,delete_type
	  ,delete_name
	  ,delete_data)
SELECT @log_id
	  ,@delete_type
	  ,@delete_name
	  ,@delete_data

SELECT @type_id = @@IDENTITY

END
GO