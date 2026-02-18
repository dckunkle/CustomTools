/**************************************************************************************************
Name:       spAPIAuto_RFFInterestUpdateState
Purpose:    Used to update the state being imported

Date        User            Change
---------------------------------------------------------------------------------------------
01/20/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_RFFInterestUpdateState
      (@iFileID				INT
	  ,@iStateSelected		VARCHAR(20))
AS
BEGIN

UPDATE tmp.RFFInterestFile
   SET FileState	= @iStateSelected
 WHERE FileID		= @iFileID

END
GO