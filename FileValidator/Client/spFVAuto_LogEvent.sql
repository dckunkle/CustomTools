IF OBJECT_ID('dbo.spFVAuto_LogEvent') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_LogEvent AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_LogEvent
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_LogEvent '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_LogEvent
     (@log_id			INT
	 ,@testcase			VARCHAR(8000)
	 ,@method			VARCHAR(8000)
	 ,@TCID				VARCHAR(8000)
	 ,@status			VARCHAR(100)	
	 ,@record_id		INT
	 ,@core_sid			INT
	 ,@search_keys		VARCHAR(8000)
	 ,@search_values	VARCHAR(8000)
	 ,@file_field		VARCHAR(8000)
	 ,@file_value		VARCHAR(8000)
	 ,@core_field		VARCHAR(8000)
	 ,@core_value		VARCHAR(8000)
	 ,@default_value	VARCHAR(8000))
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO FVLogDetail
      (log_id
	  ,date_time
	  ,record_id
	  ,testcase
	  ,method
	  ,TCID
	  ,status
	  ,core_sid
	  ,search_keys
	  ,search_values
	  ,file_field
	  ,file_value
	  ,core_field
	  ,core_value
	  ,default_value)
SELECT @log_id
      ,GETDATE()
	  ,ISNULL(@record_id, 0)
	  ,@testcase
	  ,@method
	  ,@TCID
	  ,@status
	  ,@core_sid
	  ,@search_keys
	  ,@search_values
	  ,@file_field		
	  ,@file_value		
	  ,@core_field		
	  ,@core_value		
	  ,@default_value	

END
GO