IF OBJECT_ID('dbo.DDLogDetail','U') IS NOT NULL
	BEGIN DROP TABLE dbo.DDLogDetail END
GO
/**************************************************************************************************
Name:       DDLogDetail table
Purpose:    Table used to log DataDeleter activity

Date        User        Change
---------------------------------------------------------------------------------------------
01/21/2020	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.DDLogDetail
      (log_id		INT	
	  ,date_time	DATETIME
	  ,table_name	VARCHAR(256)
	  ,record_count	INT
	  ,status		VARCHAR(300)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,log_sid		INT				IDENTITY(1,1))

GO