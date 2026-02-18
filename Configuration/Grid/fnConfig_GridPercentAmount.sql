/**************************************************************************************************
Name:       fnConfig_GridPercentAmount
Purpose:    Extract and correct percent amounts from the given description

Date        User            Change
---------------------------------------------------------------------------------------------
04/06/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_GridPercentAmount('30% after deductible')
SELECT dbo.fnConfig_GridPercentAmount('2 free visit(s) then 30% after deductible')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_GridPercentAmount
     (@benefit_description		VARCHAR(100))
RETURNS VARCHAR(50)
AS
BEGIN
	
	DECLARE @percent_pos	INT
	       ,@space_pos		INT
		   ,@percent		VARCHAR(50)

	SELECT @benefit_description = REVERSE(@benefit_description)

	SELECT @percent_pos = CHARINDEX('%', @benefit_description)
	SELECT @space_pos = CHARINDEX(' ', @benefit_description, @percent_pos)

	--If there is a space after the dollar sign then use that, otherwise assume it is at the end of the string
	IF @space_pos <> 0
		BEGIN
			SELECT @percent = SUBSTRING(@benefit_description, @percent_pos + 1, @space_pos - @percent_pos -1)
		END
	ELSE	
		BEGIN
			SELECT @percent = SUBSTRING(@benefit_description, @percent_pos + 1, LEN(@benefit_description) - @percent_pos)
		END

	SELECT @percent = REVERSE(@percent) 
	RETURN @percent
END
GO