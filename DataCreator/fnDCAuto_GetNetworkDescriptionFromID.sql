IF OBJECT_ID('dbo.fnDCAuto_GetNetworkDescriptionFromID') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetNetworkDescriptionFromID() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetNetworkDescriptionFromID
Purpose:    Return the network search description given the id

Date        User            Change
---------------------------------------------------------------------------------------------
12/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetNetworkDescriptionFromID
     (@i_network_name	VARCHAR(200))
RETURNS VARCHAR(300)
AS
BEGIN
	
	DECLARE @network_name			VARCHAR(300) = ''
	       ,@network_name_desc		VARCHAR(300) = ''

	SET @network_name = @i_network_name

	SELECT @network_name_desc				= PN.network_search_name
	  FROM Provider_Network_Search_Names	PN
	 WHERE PN.record_status					= 'A'
       AND PN.network_search_id				= @network_name
				
	RETURN @network_name_desc
	
END
GO