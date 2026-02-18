IF OBJECT_ID('dbo.spFVAuto_LogTestCase') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_LogTestCase AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_LogTestCase
Purpose:    Used to log details to the FVLogTestCase table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_LogTestCase '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_LogTestCase
     (@log_id			INT
	 ,@testcase			VARCHAR(8000)
	 ,@method			VARCHAR(8000)
	 ,@TCID				VARCHAR(8000)	
	 ,@record_id		INT
	 ,@core_sid			INT
	 ,@search_keys		VARCHAR(8000)
	 ,@search_values	VARCHAR(8000)
	 ,@err_type			VARCHAR(20)
	 ,@err_message		VARCHAR(8000)
	 ,@tc_log_id		INT OUTPUT)
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO FVLogTestCase
      (log_id
	  ,date_time
	  ,record_id
	  ,testcase
	  ,method
	  ,TCID
	  ,core_sid
	  ,search_keys
	  ,search_values
	  ,err_type
	  ,err_message)
SELECT @log_id
      ,GETDATE()
	  ,ISNULL(@record_id, 0)
	  ,@testcase
	  ,@method
	  ,@TCID
	  ,@core_sid
	  ,@search_keys
	  ,@search_values
	  ,@err_type
	  ,@err_message
	

SET @tc_log_id = @@IDENTITY

END
GO