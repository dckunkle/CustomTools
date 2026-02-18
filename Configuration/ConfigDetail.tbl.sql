IF OBJECT_ID('log.ConfigDetail','U') IS NOT NULL
	BEGIN DROP TABLE log.ConfigDetail END
GO
/**************************************************************************************************
Name:       log.ConfigDetail table
Purpose:    Table used to log detail information about the data being created

Date        User        Change
---------------------------------------------------------------------------------------------
02/26/2022	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE log.ConfigDetail
      (log_id		INT				NOT NULL
	  ,date_time	DATETIME		NULL
	  ,config_id	VARCHAR(8000)	NULL
	  ,method		VARCHAR(8000)	NULL
	  ,record_id	INT				NULL
	  ,key_data_1	VARCHAR(8000)	NULL
	  ,key_data_2	VARCHAR(8000)	NULL
	  ,key_data_3	VARCHAR(8000)	NULL
	  ,status		VARCHAR(8000)	NULL
	  ,err_num		INT				NULL
	  ,err_msg		VARCHAR(8000)	NULL
	  ,log_sid		INT				IDENTITY(1,1))

GO