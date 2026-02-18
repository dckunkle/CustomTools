/**************************************************************************************************
Name:       fnConfig_GridAdjustPlanName
Purpose:    Remove anything that appears in paranetheses

Date        User            Change
---------------------------------------------------------------------------------------------
03/30/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnConfig_GridAdjustPlanName('Gold Plan (Plan Details)')
SELECT dbo.fnConfig_GridAdjustPlanName('Gold Plan')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_GridAdjustPlanName
     (@plan_name		VARCHAR(1000))
RETURNS VARCHAR(500)
AS
BEGIN
	
	DECLARE @paren_pos INT
	
	SELECT @paren_pos = CHARINDEX('(', @plan_name)
	IF @paren_pos <> 0
		BEGIN
			SELECT @plan_name = RTRIM(LEFT(@plan_name, @paren_pos - 1))
		END

	RETURN @plan_name
END
GO