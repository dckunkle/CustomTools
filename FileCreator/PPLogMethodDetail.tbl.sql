IF OBJECT_ID('dbo.PPLogMethodDetail','U') IS NOT NULL
	BEGIN DROP TABLE dbo.PPLogMethodDetail END
GO
/**************************************************************************************************
Name:       PPLogMethodDetail table
Purpose:    Table used to log header information about the preprocessor

Date        User        Change
---------------------------------------------------------------------------------------------
05/20/2021	DK			Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE dbo.PPLogMethodDetail
      (method_id		INT				NULL
	  ,record_id		INT				NULL
	  ,claim_number		VARCHAR(50)		NULL
	  ,line_number		VARCHAR(50)		NULL
	  ,date_submitted	DATETIME		NULL
	  ,claim_sid		INT				NULL
	  ,status			VARCHAR(50)		NULL
	  ,detail_id		INT IDENTITY(1,1)
 CONSTRAINT PK_PPLogMethodDetail PRIMARY KEY CLUSTERED 
           (detail_id ASC)
		   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO