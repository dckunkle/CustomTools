IF OBJECT_ID('dbo.spFVAuto_LogTestCaseValidation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_LogTestCaseValidation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_LogTestCaseValidation
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_LogTestCaseValidation '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_LogTestCaseValidation
     (@tc_og_id			INT
	 ,@status			VARCHAR(100)	
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
INSERT INTO FVLogTestCaseValidation
      (tc_log_id
	  ,status
	  ,file_field
	  ,file_value
	  ,core_field
	  ,core_value
	  ,default_value)
SELECT @tc_og_id
	  ,@status
	  ,@file_field		
	  ,@file_value		
	  ,@core_field		
	  ,@core_value		
	  ,@default_value	

END
GO