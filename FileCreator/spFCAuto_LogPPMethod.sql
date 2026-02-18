IF OBJECT_ID('dbo.spFCAuto_LogPPMethod') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_LogPPMethod AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_LogPPMethod
Purpose:    Used to log details to the PPLogDetail table (Preprocessor logging)

Date        User            Change
---------------------------------------------------------------------------------------------
05/20/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_LogPPMethod '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_LogPPMethod
     (@log_id			INT
	 ,@method_name		VARCHAR(8000)
	 ,@table_name		VARCHAR(8000)
	 ,@action			VARCHAR(8000)
	 ,@method_id		INT	OUTPUT)
AS
BEGIN

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO dbo.PPLogMethod
      (log_id
	  ,method_name
	  ,table_name
	  ,action)
SELECT @log_id
      ,@method_name
	  ,@table_name
	  ,@action

SET @method_id = @@IDENTITY

END
GO