/**************************************************************************************************
Name:       fnConfig_GridDollarAmount
Purpose:    Extract and correct dollar amounts in the passed in descriptions

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original script
10/06/2022	DK				Remove thousands delimiter
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_GridDollarAmount('$35 after deductible')
SELECT dbo.fnConfig_GridDollarAmount('$50')
SELECT dbo.fnConfig_GridDollarAmount('2 free visit(s) then $20')
SELECT dbo.fnConfig_GridDollarAmount('$50.5')
SELECT dbo.fnConfig_GridDollarAmount('$50.0')
SELECT dbo.fnConfig_GridDollarAmount('$1,250')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_GridDollarAmount
     (@benefit_description		VARCHAR(100))
RETURNS VARCHAR(50)
AS
BEGIN
	
	DECLARE @dollar_pos INT
	       ,@space_pos	INT
		   ,@dollars	VARCHAR(50)
	
	SELECT @dollar_pos = CHARINDEX('$', @benefit_description)
	SELECT @space_pos = CHARINDEX(' ', @benefit_description, @dollar_pos)

	--If there is a space after the dollar sign then use that, otherwise assume it is at the end of the string
	IF @space_pos <> 0
		BEGIN
			SELECT @dollars = SUBSTRING(@benefit_description, @dollar_pos + 1, @space_pos - @dollar_pos -1)
		END
	ELSE	
		BEGIN
			SELECT @dollars = SUBSTRING(@benefit_description, @dollar_pos + 1, LEN(@benefit_description) - @dollar_pos)
		END

	--If any dollar amounts include cents then make sure to include two decimals (unless it is .00)
	IF (CHARINDEX('.',@dollars) <> 0)
		BEGIN
			SELECT @dollars = LTRIM(STR(@dollars, 10, 2))

			IF RIGHT(@dollars, 3) = '.00' 
				BEGIN
					SELECT @dollars = LEFT(@dollars, CHARINDEX('.', @dollars) - 1)
				END
		END
	--If any dollar amounts include a thousands delimiter remove it
	SELECT @dollars = REPLACE(@dollars,',','')

	RETURN @dollars
END
GO