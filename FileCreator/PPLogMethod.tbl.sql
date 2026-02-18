IF OBJECT_ID('dbo.PPLogMethod','U') IS NOT NULL
	BEGIN DROP TABLE dbo.PPLogMethod END
GO
/**************************************************************************************************
Name:       PPLogMethod table
Purpose:    Table used to log header information about the preprocessor

Date        User        Change
---------------------------------------------------------------------------------------------
05/20/2021	DK			Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.PPLogMethod
      (log_id			INT					NOT NULL
	  ,method_id		INT IDENTITY(1,1)	NOT NULL
	  ,method_name		VARCHAR(200)		NULL
	  ,table_name		VARCHAR(200)		NULL
	  ,action			VARCHAR(200)		NULL
 CONSTRAINT PK_PPLogMethod PRIMARY KEY CLUSTERED 
           (log_id ASC, method_id ASC)
		   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO