IF OBJECT_ID('dbo.FDLogType','U') IS NOT NULL
	BEGIN DROP TABLE dbo.FDLogType END
GO
/**************************************************************************************************
Name:       FDLog table
Purpose:    Log activities of the File Deleter

Date        User        Change
---------------------------------------------------------------------------------------------
05/24/2021	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.FDLogType
      (log_id			INT				
	  ,type_id			INT				IDENTITY(1,1)
	  ,delete_type		VARCHAR(100)
	  ,delete_name		VARCHAR(100)
	  ,delete_data		VARCHAR(100)

CONSTRAINT [PK_FDLogType] PRIMARY KEY CLUSTERED 
          (log_id ASC, type_id ASC)
      WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
      ) ON [PRIMARY]

GO