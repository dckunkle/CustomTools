IF OBJECT_ID('fw.FCLog','U') IS NOT NULL
	BEGIN DROP TABLE fw.FCLog END
GO
/**************************************************************************************************
Name:       FCLog table
Purpose:    Log activities of the FileCreator

Date        User        Change
---------------------------------------------------------------------------------------------
03/12/2020	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE fw.FCLog
      (log_id				INT				IDENTITY(1,1)
	  ,destination_server	VARCHAR(200)
	  ,test_case_pattern	VARCHAR(200)
	  ,start_time			DATETIME
	  ,end_time				DATETIME
	  ,email_address		VARCHAR(8000)
	  ,build_id				INT
	  ,job_name				VARCHAR(200)

CONSTRAINT [PK_FCLog] PRIMARY KEY CLUSTERED 
          (log_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO