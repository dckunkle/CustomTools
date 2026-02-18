IF OBJECT_ID('dbo.DCLogDetail','U') IS NOT NULL
	BEGIN DROP TABLE dbo.DCLogDetail END
GO
/**************************************************************************************************
Name:       DCLogDetail table
Purpose:    Table used to log header information about the data being created. Used along
            with the DCLogDetail table

Date        User        Change
---------------------------------------------------------------------------------------------
10/18/2019	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.DCLogDetail
      (log_id		INT	
	  ,date_time	DATETIME
	  ,testcase		VARCHAR(8000)
	  ,method		VARCHAR(8000)
	  ,record_id	INT
	  ,key_data_1	VARCHAR(8000)
	  ,key_data_2	VARCHAR(8000)
	  ,key_data_3	VARCHAR(8000)
	  ,status		VARCHAR(8000)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,log_sid		INT				IDENTITY(1,1))

GO