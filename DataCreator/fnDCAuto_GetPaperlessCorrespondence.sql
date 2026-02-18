/**************************************************************************************************
Name:       fnDCAuto_GetPaperlessCorrespondence
Purpose:    Convert selections to their abbreviations for Member Paperless selections

Date        User            Change
---------------------------------------------------------------------------------------------
01/25/2023	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnDCAuto_GetPaperlessCorrespondence
     (@i_correspondence	VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @correspondence VARCHAR(128) = ''

	SELECT @correspondence = (SELECT SAV.Short_Desc
	                            FROM System_Action_Values	SAV
							   WHERE SAV.record_status		= 'A'
							     AND SAV.Reference_Type		= 'PAPCOR'
								 AND SAV.Description		= @i_correspondence)
			
	RETURN @correspondence
	
END
GO