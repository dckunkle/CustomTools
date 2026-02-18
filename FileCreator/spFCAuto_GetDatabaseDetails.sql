/**************************************************************************************************
Name:       spFCAuto_GetDatabaseDetails
Purpose:    Gather connection string data to delete application data

Date        User            Change
---------------------------------------------------------------------------------------------
07/25/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_GetDatabaseDetails 'IdentifiMember', '[109] https://qr09-qa.core.valence.care/'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_GetDatabaseDetails
     (@application	VARCHAR(200)
	 ,@url			VARCHAR(200))

AS
BEGIN

SET NOCOUNT ON

DECLARE @server_id			INT
	   ,@server_name		VARCHAR(400)
	   ,@end_position		INT
	   ,@id_length			INT
	   ,@layer				VARCHAR(100)
	   ,@client_key			VARCHAR(100)
	   ,@database_name		VARCHAR(100)
	   ,@password			VARCHAR(100)
	   ,@user_id			VARCHAR(100)
	   ,@err_msg			VARCHAR(4000)

--*************************************************************************************************
-- Get the Server ID from the URL being passed in
--*************************************************************************************************
IF LEFT(@url, 1) = '[' AND CHARINDEX(']', @url) > 0
	BEGIN
		SELECT @end_position = CHARINDEX(']', @url)
		SELECT @id_length = @end_position - 2
		SELECT @server_id = SUBSTRING(@url, 2, @id_length)
	END
ELSE
	BEGIN
		SELECT @server_id = 0
	END

IF @server_id = 0 
	BEGIN 
		SELECT @err_msg = 'The server information could not be determined from the URL that was provided, ' + @url
	END

--*************************************************************************************************
-- Get server details
--*************************************************************************************************
SELECT @server_name = CASE WHEN @application = 'Identifi Member' THEN 'ipe1qa-hpss-001.database.windows.net' 
                           ELSE 'ipe1qa-hpss-001.database.windows.net'
					   END 

SELECT @layer					= S.Layer
      ,@client_key				= S.enterprise_id
  FROM SystemAudit.dbo.Server	S
 WHERE S.environment_id			= @server_id

SELECT @password = CASE WHEN @layer = 'QA'         THEN 'HZB4XYxgBVPAxXoc5N6o' 
                        WHEN @layer = 'Automation' THEN 'QcjoFfdtimmKHP4by4HQ'
						WHEN @layer = 'Regression' THEN 'rguvlGlfHnFbwbWYTbh1'
						ELSE ''
					END
SELECT @user_id	= 'md_readwrite_user'

SELECT @database_name = CASE WHEN @layer = 'QA'         THEN 'mdsd-qa-001' 
							 WHEN @layer = 'Automation' THEN 'mdsd-auto-001'
							 WHEN @layer = 'Regression' THEN 'mdsd-reg-001'
							 ELSE ''
						 END

--*************************************************************************************************
-- Output the server details
--*************************************************************************************************
SELECT @server_name		AS server_name
      ,@client_key		AS client_key
	  ,@database_name	AS database_name
	  ,@user_id			AS user_id
	  ,@password		AS password
END
GO