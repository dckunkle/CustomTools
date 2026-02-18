IF OBJECT_ID('log.Config','U') IS NOT NULL
	BEGIN DROP TABLE log.Config END
GO
/**************************************************************************************************
Name:       log.Config
Purpose:    Table used to log header information about the data being created

Date        User        Change
---------------------------------------------------------------------------------------------
02/26/2022	DK			Original procedure
04/04/2022	DK			Added target system fields
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE log.Config
      (log_id			INT				IDENTITY(1,1)
	  ,target_system	VARCHAR(100)	NULL
	  ,target_database	VARCHAR(100)	NULL
	  ,user_id			VARCHAR(200)	NULL
	  ,config_id		VARCHAR(500)	NULL
	  ,start_time		DATETIME		NULL
	  ,end_time			DATETIME		NULL
	  ,email_address	VARCHAR(8000)	NULL
	  ,build_id			INT				NULL
	  ,job_name			VARCHAR(200)	NULL

CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED 
          (log_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO