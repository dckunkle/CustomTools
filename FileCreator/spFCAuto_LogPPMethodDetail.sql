IF OBJECT_ID('dbo.spFCAuto_LogPPMethodDetail') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_LogPPMethodDetail AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_LogPPMethodDetail
Purpose:    Used to log details to the PPLogDetail table (Preprocessor logging)

Date        User            Change
---------------------------------------------------------------------------------------------
05/20/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_LogPPMethodDetail '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_LogPPMethodDetail
     (@method_id		INT
	 ,@record_id		INT
	 ,@claim_number		VARCHAR(50)
	 ,@line_number		VARCHAR(50)
	 ,@date_submitted	VARCHAR(50)
	 ,@claim_sid		INT
	 ,@status			VARCHAR(300))
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO dbo.PPLogMethodDetail
      (method_id
	  ,record_id
	  ,claim_number
	  ,line_number
	  ,date_submitted
	  ,claim_sid
	  ,status)
SELECT @method_id
      ,@record_id
	  ,@claim_number
	  ,@line_number
	  ,@date_submitted
	  ,@claim_sid
	  ,@status

END
GO