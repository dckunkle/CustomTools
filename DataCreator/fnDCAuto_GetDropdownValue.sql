IF OBJECT_ID('dbo.fnDCAuto_GetDropdownValue') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetDropdownValue() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetDropdownValue
Purpose:    Extract the dropdown value from the dropdown description/value
            Ex. Medical(M) need to extract the M

Date        User            Change
---------------------------------------------------------------------------------------------
10/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetDropdownValue
     (@i_dropdown	VARCHAR(200))
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @dropdown VARCHAR(128) = ''

	SET @dropdown = @i_dropdown

	--Check to make sure the format is as expected, otherwise return the original value
	IF CHARINDEX('(', @dropdown) <> 0 AND CHARINDEX(')', @dropdown) <> 0 
		BEGIN

			SET @dropdown = REVERSE(@dropdown)	--Reverse the string to get the last instance of (
			SET @dropdown = SUBSTRING(@dropdown, CHARINDEX(')', @dropdown) + 1, 9999)
			SET @dropdown = LEFT(@dropdown,CHARINDEX('(', @dropdown) -1)
			SET @dropdown = REVERSE(@dropdown)

		END
			
	RETURN @dropdown
	
END
GO