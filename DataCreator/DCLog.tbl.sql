IF OBJECT_ID('dbo.DCLog','U') IS NOT NULL
	BEGIN DROP TABLE dbo.DCLog END
GO
/**************************************************************************************************
Name:       DCLog table
Purpose:    Table used to log header information about the data being created. Used along
            with the DCLogDetail table

Date        User        Change
---------------------------------------------------------------------------------------------
10/18/2019	DK			Original procedure
01/13/2020	DK			Added email address field
01/15/2020	DK			Added build_id and job_name from Jenkins as optional parameters
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.DCLog
      (log_id			INT				IDENTITY(1,1)
	  ,user_id			VARCHAR(200)
	  ,pattern			VARCHAR(200)
	  ,start_time		DATETIME
	  ,end_time			DATETIME
	  ,email_address	VARCHAR(8000)
	  ,build_id			INT
	  ,job_name			VARCHAR(200)

CONSTRAINT [PK_DCLog] PRIMARY KEY CLUSTERED 
          (log_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO