IF OBJECT_ID('dbo.spFCAuto_DeleteDisplayCounts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteDisplayCounts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteDisplayCounts
Purpose:    Delete data that was loaded by a Member Conversionfile

Date        User            Change
---------------------------------------------------------------------------------------------
11/03/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteDisplayCounts 'Member_Salary', 10
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteDisplayCounts
     (@table_name		VARCHAR(200)
	 ,@record_count		INT)
AS
BEGIN

SET NOCOUNT ON

PRINT SPACE(53) + LEFT(@table_name + SPACE(57), 57) + RIGHT(SPACE(10) + CONVERT(VARCHAR(10), @record_count), 10)

END
GO