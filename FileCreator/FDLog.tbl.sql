IF OBJECT_ID('dbo.FDLog','U') IS NOT NULL
	BEGIN DROP TABLE dbo.FDLog END
GO
/**************************************************************************************************
Name:       FDLog table
Purpose:    Log activities of the DataDeleter

Date        User        Change
---------------------------------------------------------------------------------------------
05/24/2021	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.FDLog
      (log_id			INT				IDENTITY(1,1)
	  ,user_id			VARCHAR(200)
	  ,server_name		VARCHAR(200)
	  ,test_case		VARCHAR(200)
	  ,start_time		DATETIME
	  ,end_time			DATETIME
	  ,email_address	VARCHAR(8000)
	  ,build_id			INT
	  ,job_name			VARCHAR(200)

CONSTRAINT [PK_FDLog] PRIMARY KEY CLUSTERED 
          (log_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO