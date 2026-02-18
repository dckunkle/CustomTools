IF OBJECT_ID('dbo.FDLogTypeDetail','U') IS NOT NULL
	BEGIN DROP TABLE dbo.FDLogTypeDetail END
GO
/**************************************************************************************************
Name:       FDLogTypeDetail table
Purpose:    Table used to log File Deleter activity

Date        User        Change
---------------------------------------------------------------------------------------------
05/24/2021	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.FDLogTypeDetail
      (type_id		INT	
	  ,date_time	DATETIME
	  ,table_name	VARCHAR(256)
	  ,record_count	INT
	  ,status		VARCHAR(300)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,record_id	INT				IDENTITY(1,1))

GO