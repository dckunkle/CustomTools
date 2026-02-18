IF OBJECT_ID('dbo.PPLog','U') IS NOT NULL
	BEGIN DROP TABLE dbo.PPLog END
GO
/**************************************************************************************************
Name:       PPLog table
Purpose:    Table used to log header information about the preprocessor

Date        User        Change
---------------------------------------------------------------------------------------------
05/20/2021	DK			Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.PPLog
      (log_id				INT IDENTITY(1,1)	NOT NULL
	  ,destination_server	VARCHAR(200)		NULL
	  ,test_case_pattern	VARCHAR(200)		NULL
	  ,start_time			DATETIME			NULL
	  ,end_time				DATETIME			NULL
	  ,email_address		VARCHAR(8000)		NULL
	  ,build_id				INT					NULL
	  ,job_name				VARCHAR(200)		NULL
 CONSTRAINT PK_PPLog PRIMARY KEY CLUSTERED 
           (log_id ASC)
		   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO