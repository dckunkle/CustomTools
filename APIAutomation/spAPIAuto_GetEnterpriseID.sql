/**************************************************************************************************
Name:       spAPIAuto_GetEnterpriseID
Purpose:    Lookup the enterprised ID for a given system URL

Date        User            Change
---------------------------------------------------------------------------------------------
06/01/2021	DK				Original procedure
09/19/2022  DK				Include the system name in the output
10/11/2022  DK				Include the Layer in the output
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_GetEnterpriseID 'https://qr03-qa.core.valence.care/'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spAPIAuto_GetEnterpriseID
     (@url				VARCHAR(2000)
	 ,@enterprise_id	VARCHAR(200)	= ''	OUTPUT
	 ,@system_name		VARCHAR(200)	= ''	OUTPUT
	 ,@layer			VARCHAR(100)	= ''	OUTPUT
	 ,@status			INT				= 0		OUTPUT
	 ,@message			VARCHAR(8000)	= ''	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

SELECT @status		= 0
      ,@message		= 'Success'

BEGIN TRY
	
	SELECT @enterprise_id			= ISNULL(E.EnterpriseID, '')
	      ,@system_name             = ISNULL(E.SystemName, '')
		  ,@layer					= ISNULL(E.Layer, '')
	  FROM fw.EnterpriseIDLookup	E
	 WHERE E.URL					= @url

	 IF ISNULL(@enterprise_id, '') = ''
		BEGIN
			SELECT @status = 100
			      ,@message = 'An Enterprise ID for ' + @url + ' has not been configured.'
		END 

	 IF ISNULL(@system_name, '') = ''
		BEGIN
			SELECT @status = 101
			      ,@message = 'A System Name for ' + @url + ' has not been configured.'
		END 

	IF ISNULL(@layer, '') = ''
		BEGIN
			SELECT @status = 102
			      ,@message = 'A Layer for ' + @url + ' has not been configured.'
		END 
END TRY
BEGIN CATCH

	SELECT @status	= ERROR_NUMBER()
		  ,@message	= ERROR_MESSAGE()
	
END CATCH

SELECT @enterprise_id	AS EnterpriseID
      ,@system_name		AS SystemName
	  ,@layer			AS Layer

END
GO