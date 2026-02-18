IF OBJECT_ID('dbo.fnDCAuto_GetOfferedServicesXML') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetOfferedServicesXML() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetOfferedServicesXML
Purpose:    Build the XML that is needed to add offered services to a service location

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetOfferedServicesXML
     (@i_service1		VARCHAR(200) = ''
	 ,@i_service2		VARCHAR(200) = ''
	 ,@i_service3		VARCHAR(200) = ''
	 ,@i_service4		VARCHAR(200) = ''
	 ,@i_service5		VARCHAR(200) = '')

RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @servicesXML	VARCHAR(MAX)	= ''
	       ,@l_service1		VARCHAR(200)
		   ,@l_service2		VARCHAR(200)
		   ,@l_service3		VARCHAR(200)
		   ,@l_service4		VARCHAR(200)
		   ,@l_service5		VARCHAR(200)
		
	SET @l_service1 = ISNULL(@i_service1, '')
	SET @l_service2 = ISNULL(@i_service2, '')
	SET @l_service3 = ISNULL(@i_service3, '')
	SET @l_service4 = ISNULL(@i_service4, '')
	SET @l_service5 = ISNULL(@i_service5, '')

	SELECT @servicesXML = '<rows>'
	SELECT @servicesXML = @servicesXML + CASE WHEN @l_service1 = '' THEN '' ELSE '<row service="' + @l_service1 + '" />' END
	SELECT @servicesXML = @servicesXML + CASE WHEN @l_service2 = '' THEN '' ELSE '<row service="' + @l_service2 + '" />' END
	SELECT @servicesXML = @servicesXML + CASE WHEN @l_service3 = '' THEN '' ELSE '<row service="' + @l_service3 + '" />' END
	SELECT @servicesXML = @servicesXML + CASE WHEN @l_service4 = '' THEN '' ELSE '<row service="' + @l_service4 + '" />' END
	SELECT @servicesXML = @servicesXML + CASE WHEN @l_service5 = '' THEN '' ELSE '<row service="' + @l_service5 + '" />' END
	SELECT @servicesXML = @servicesXML + '</rows>'

--*************************************************************************************************
-- Build the XML necessary
--*************************************************************************************************


	RETURN @servicesXML
	
END
GO