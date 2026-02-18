IF OBJECT_ID('dbo.fnDCAuto_GetDateValue') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetDateValue() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetDateValue
Purpose:    Interpret date value (if necessary)

The formats below assume that there is a single space between each of the characters

Formats:	<date>d - 3		- Today's date minus three days
			<date>m + 2		- Today's date plus two months
			<date>y - 1		- Today's date minus one year
			<date>Today		- return today's date


Date        User            Change
---------------------------------------------------------------------------------------------
12/20/2021	DK				Original script

---------------------------------------------------------------------------------------------

SELECT dbo.fnDCAuto_GetDateValue('<date>d + 2')
SELECT dbo.fnDCAuto_GetDateValue('<date>y - 2')
SELECT dbo.fnDCAuto_GetDateValue('12/21/2021')
SELECT dbo.fnDCAuto_GetDateValue('<date>Today')
***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetDateValue
     (@i_date_value		VARCHAR(200))
RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @date_value		VARCHAR(200)	= '';
	DECLARE @date_text		VARCHAR(200)	= '';
	DECLARE @increment_by	VARCHAR(5)		= '';
	DECLARE @increments		INT;
			
	SET @date_value = TRIM(@i_date_value);

	-- Check to see if the date needs to be interpretted or not
	IF LEFT(@date_value, 6) = '<date>'
		BEGIN

			-- Strip off the <date> at the fron of the string to continue evaluating
			SELECT @date_text = SUBSTRING(@date_value, 7, LEN(@date_value));

			IF @date_text = 'today'
				BEGIN

					SELECT @date_value = FORMAT(GETDATE(), 'MM/dd/yyyy');

				END;
			ELSE
				BEGIN

					SELECT @increment_by	= LEFT(@date_text, 1);
					SELECT @increments		= CONVERT(INT, SUBSTRING(@date_text, 2, LEN(@date_text)));

					IF @increment_by = 'd' BEGIN SELECT @date_value = FORMAT(DATEADD(DAY, @increments, GETDATE()), 'MM/dd/yyyy') END;
					IF @increment_by = 'm' BEGIN SELECT @date_value = FORMAT(DATEADD(MONTH, @increments, GETDATE()), 'MM/dd/yyyy') END;
					IF @increment_by = 'y' BEGIN SELECT @date_value = FORMAT(DATEADD(YEAR, @increments, GETDATE()), 'MM/dd/yyyy') END;

				END;
		END;

	RETURN(@date_value);
	
END;
GO