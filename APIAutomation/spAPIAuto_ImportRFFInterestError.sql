/**************************************************************************************************
Name:       spAPIAuto_ImportRFFInterestError
Purpose:    Log errors found during RFF Interest validation

Date        User            Change
---------------------------------------------------------------------------------------------
01/17/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_ImportRFFInterestError
      (@iFileID			INT
	  ,@iLevel			VARCHAR(100)
	  ,@iRowID			INT
	  ,@iColumnID		VARCHAR(5)
	  ,@err_num			INT
	  ,@err_msg			VARCHAR(8000))
AS
BEGIN

	SET NOCOUNT ON 

	INSERT INTO tmp.RFFInterestLog
	      (FileID
		  ,RowID
		  ,ColumnID
		  ,ErrorLevel
		  ,ErrorNumber
		  ,ErrorMessage)
	SELECT @iFileID
	      ,@iRowID
		  ,@iColumnID
		  ,@iLevel
		  ,@err_num
		  ,@err_msg
END