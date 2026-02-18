IF OBJECT_ID('dbo.FVLogTestCaseValidation','U') IS NOT NULL
	BEGIN DROP TABLE dbo.FVLogTestCaseValidation END
GO
/**************************************************************************************************
Name:       FVLogTestCaseValidation table
Purpose:    Table used to log FileValidator activity

Date        User        Change
---------------------------------------------------------------------------------------------
05/08/2020	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.FVLogTestCaseValidation
      (tc_log_id		INT	
	  ,status			VARCHAR(20)		-- defaulted, match, no match
	  ,file_field		VARCHAR(200)
	  ,file_value		VARCHAR(8000)
	  ,core_field		VARCHAR(200)
	  ,core_value		VARCHAR(8000)
	  ,default_value	VARCHAR(8000)
	  ,log_sid			INT				IDENTITY(1,1))

GO