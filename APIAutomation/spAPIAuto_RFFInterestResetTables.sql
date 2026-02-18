/**************************************************************************************************
Name:       spAPIAuto_RFFInterestResetTables
Purpose:    Used to log the file and worksheet being loaded

Date        User            Change
---------------------------------------------------------------------------------------------
01/18/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_RFFInterestResetTables

AS
BEGIN

TRUNCATE TABLE tmp.RFFInterestScenario
TRUNCATE TABLE tmp.RFFInterestScenarioOriginal

END
GO