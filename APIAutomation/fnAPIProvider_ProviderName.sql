IF OBJECT_ID('dbo.fnAPIProvider_ProviderName') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAPIProvider_ProviderName() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnAPIProvider_ProviderName
Purpose:    Return the provider's name according to what the provider service returns

Date        User            Change
---------------------------------------------------------------------------------------------
02/12/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT dbo.fnAPIProvider_ProviderName(520060001)
***************************************************************************************************/
ALTER FUNCTION dbo.fnAPIProvider_ProviderName
     (@provider_gid	INT)

RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @first			VARCHAR(50)
	       ,@middle			VARCHAR(50)
	       ,@last			VARCHAR(50)
		   ,@title			VARCHAR(50)
		   ,@provider_name	VARCHAR(200)

	SELECT @first			= ISNULL(P.first_name, '')
	      ,@middle			= ISNULL(P.middle_initial, '')
	      ,@last			= ISNULL(P.last_name, '')
		  ,@title			= ISNULL(P.Prof_desg_1, '')
	  FROM dbo.Provider		P
	 WHERE record_status	= 'A'
	   AND provider_gid		= @provider_gid

	SET @provider_name = @first 
	                   + CASE WHEN @middle = '' THEN ''
					          ELSE ' ' + @middle 
						  END
					   + ' ' + @last + ' '
	                   + CASE WHEN @title = '' THEN ''
					          ELSE ',' + @title
						  END
	RETURN @provider_name
END
GO