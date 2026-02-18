IF OBJECT_ID('dbo.DDLog','U') IS NOT NULL
	BEGIN DROP TABLE dbo.DDLog END
GO
/**************************************************************************************************
Name:       DDLog table
Purpose:    Log activities of the DataDeleter

Date        User        Change
---------------------------------------------------------------------------------------------
01/20/202	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.DDLog
      (log_id			INT				IDENTITY(1,1)
	  ,user_id			VARCHAR(200)
	  ,job_action		VARCHAR(100)
	  ,entity_to_delete	VARCHAR(200)
	  ,entity_type		VARCHAR(200)
	  ,start_time		DATETIME
	  ,end_time			DATETIME
	  ,email_address	VARCHAR(8000)
	  ,build_id			INT
	  ,job_name			VARCHAR(200)

CONSTRAINT [PK_DDLog] PRIMARY KEY CLUSTERED 
          (log_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO