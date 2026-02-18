/**************************************************************************************************
Name:       spAPIAuto_RFFInterestSelectErrors
Purpose:    Select all of the errors for a givn file

Date        User            Change
---------------------------------------------------------------------------------------------
01/20/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_RFFInterestSelectErrors 111
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_RFFInterestSelectErrors
      (@FileID		INT)
AS
BEGIN

DECLARE @error_order TABLE
       (error_order		INT
	   ,error_level		VARCHAR(20))
	   
INSERT INTO @error_order(error_order, error_level) VALUES (1, 'File')
INSERT INTO @error_order(error_order, error_level) VALUES (2, 'Record')
INSERT INTO @error_order(error_order, error_level) VALUES (3, 'Field')

SELECT R.RowID
      ,R.ColumnID
	  ,R.ErrorLevel
	  ,R.ErrorNumber
	  ,R.ErrorMessage
  FROM tmp.RFFInterestLog	R
  JOIN @error_order			ER
    ON R.ErrorLevel			= ER.error_level
 WHERE R.FileID				= @FileID
 ORDER BY ER.error_order, R.RowID, R.ColumnID

END
GO