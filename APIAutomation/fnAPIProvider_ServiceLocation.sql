IF OBJECT_ID('dbo.fnAPIProvider_ServiceLocation') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAPIProvider_ServiceLocation() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnAPIProvider_ServiceLocation
Purpose:    Return the formatted address of the service location

Date        User            Change
---------------------------------------------------------------------------------------------
02/12/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT dbo.fnAPIProvider_ServiceLocation(520500001)
***************************************************************************************************/
ALTER FUNCTION dbo.fnAPIProvider_ServiceLocation
     (@location_gid	INT)

RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @address1			VARCHAR(50)
	       ,@address2			VARCHAR(50)
	       ,@city				VARCHAR(50)
		   ,@state				VARCHAR(50)
		   ,@zip				VARCHAR(200)
		   ,@location_address	VARCHAR(200)

	SELECT @address1		= L.address_1
	      ,@address2		= L.address_2
	      ,@city			= L.city
		  ,@state			= L.state
		  ,@zip				= L.zip_code
	  FROM dbo.Locations	L
	 WHERE L.record_status	= 'A'
	   AND L.location_gid	= @location_gid

	SET @location_address = @address1 
	                      + CASE WHEN @address2 = '' THEN ''
						         ELSE ' ' + @address2 
							 END
						  + ' ' + @city + ', ' + @state + ' ' + @zip

	RETURN @location_address
END
GO