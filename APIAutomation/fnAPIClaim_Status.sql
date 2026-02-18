IF OBJECT_ID('dbo.fnAPIClaim_Status') IS NOT NULL
    BEGIN 
		DROP FUNCTION dbo.fnAPIClaim_Status 
	END
GO
/**************************************************************************************************
Name:       fnAPIClaim_Status
Purpose:    Return the formatted address of the service location

Date        User            Change
---------------------------------------------------------------------------------------------
02/12/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT * FROM dbo.fnAPIClaim_Status(520060050,520500003,520050003)
***************************************************************************************************/
CREATE FUNCTION dbo.fnAPIClaim_Status
     (@paid_date		VARCHAR(10)
	 ,@default_status	VARCHAR(5))

RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @status		VARCHAR(100)
	DECLARE @paid		BIT
	
	SELECT @paid = CASE WHEN @paid_date > '1900/01/01' THEN 1
	                    ELSE 0
					END

	SELECT @status = CASE WHEN @default_status = 'Z' THEN 'In Process'
	                      WHEN @default_status = 'X' THEN 'Void'
						  WHEN @default_status = 'R' THEN 'Processed'
						  WHEN 	 IN ('P','R','F') AND @paid = 0 THEN '
			
		END
	
	RETURN @status
END
GO