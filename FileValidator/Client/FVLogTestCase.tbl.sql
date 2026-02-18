IF OBJECT_ID('dbo.FVLogTestCase','U') IS NOT NULL
	BEGIN DROP TABLE dbo.FVLogTestCase END
GO
/**************************************************************************************************
Name:       FVLogTestCase table
Purpose:    Table used to log FileValidator activity

Date        User        Change
---------------------------------------------------------------------------------------------
05/08/2020	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.FVLogTestCase
      (log_id			INT	
	  ,tc_log_id		INT IDENTITY(1,1)
	  ,date_time		DATETIME
	  ,testcase			VARCHAR(8000)
	  ,method			VARCHAR(8000)
	  ,TCID				VARCHAR(8000)
	  ,record_id		INT
	  ,search_keys		VARCHAR(8000)
	  ,search_values	VARCHAR(8000)
	  ,core_sid			INT
	  ,err_type			VARCHAR(20)
	  ,err_message		VARCHAR(8000))

GO