/**************************************************************************************************
Name:       fnDCAuto_GetPaperlessSelection
Purpose:    Convert selections to their abbreviations for Member Paperless selections

Date        User            Change
---------------------------------------------------------------------------------------------
01/25/2023	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnDCAuto_GetPaperlessSelection
     (@i_selection	VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @selection VARCHAR(128) = ''

	SELECT @selection = CASE WHEN @i_selection = 'Apply to Member Only' THEN 'AM'
	                         WHEN @i_Selection = 'Apply to Dependents' THEN 'AD'
							 ELSE 'AM'
						 END
			
	RETURN @selection
	
END
GO