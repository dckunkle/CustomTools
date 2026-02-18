/**************************************************************************************************
Name:       spDCAuto_APISubmitRequest
Purpose:    Submit a request to a web service

Date        User            Change
---------------------------------------------------------------------------------------------
08/25/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @err_num	INT = 0
       ,@err_msg	VARCHAR(8000) = ''
	   ,@parameters	VARCHAR(8000) = '{"systemName": "QR06_QA", "billingRunDate": "12/15/2019","groupID": "400-TestCase-275", "memberID": "400-TC275-MEM-003", "userID": "dkunkle", "isDocGen": "N"}'

EXEC spDCAuto_APISubmitRequest 'https://finance-qa-auto.core.valence.care/v1/Billing/ValidateBilling', '10606', @parameters, @err_num OUTPUT, @err_msg OUTPUT

SELECT @err_num, @err_msg
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_APISubmitRequest
     (@url				VARCHAR(8000)
	 ,@enterprise_id	VARCHAR(40)
	 ,@parameters		VARCHAR(8000)
	 ,@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(8000)	OUTPUT)
AS
BEGIN

DECLARE @object			INT
	   ,@response		VARCHAR(8000)
	   ,@status			VARCHAR(40)
	   ,@statusText		VARCHAR(40)
	   ,@source			VARCHAR(255)
	   ,@description	VARCHAR(255)
	   ,@api_key		VARCHAR(200)	= 'a7da2eca-a763-4ed9-947b-31b373d96a75'

--*************************************************************************************************
-- Create the request object
--*************************************************************************************************
BEGIN TRY

	EXEC @err_num = sp_OACreate 'WinHttp.WinHttpRequest.5.1', @object OUT

END TRY
BEGIN CATCH

	EXEC sp_OAGetErrorInfo @object, @source OUT, @description OUT
	SELECT @err_msg = 'Error creating request object.'
	GOTO CLEAN_UP

END CATCH

--*************************************************************************************************
-- Set up the headers and the body
--*************************************************************************************************
BEGIN TRY

	EXEC sp_OAMethod @object, 'open',				NULL, 'POST',			@url,				'false'
	EXEC sp_OAMethod @object, 'setRequestHeader',	NULL, 'Content-Type',	'application/json'
	EXEC sp_OAMethod @object, 'setRequestHeader',	NULL, 'EnterpriseId',	@enterprise_id
	EXEC sp_OAMethod @object, 'setRequestHeader',	NULL, 'x-api-key',		@api_key

--*************************************************************************************************
-- Send the request and get the results
--*************************************************************************************************
	EXEC sp_OAMethod @object, 'send', NULL, @parameters

	EXEC sp_OAMethod @object, 'status', @status OUTPUT
	EXEC sp_OAMethod @object, 'statusText', @statusText OUTPUT
	EXEC sp_OAMethod @object, 'responseText', @response OUTPUT

	SELECT @err_num = CASE WHEN @status = 200 THEN 0 ELSE 100 END
	      ,@err_msg = CASE WHEN @status	= 200 THEN '' ELSE @response END

END TRY
BEGIN CATCH
	
	EXEC sp_OAGetErrorInfo @object, @source OUT, @description OUT
	SELECT @err_msg = 'Error submitting request.'

END CATCH
--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEAN_UP:
EXEC sp_OADestroy @object

END
GO