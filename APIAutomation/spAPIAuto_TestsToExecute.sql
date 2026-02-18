IF OBJECT_ID('dbo.spAPIAuto_TestsToExecute') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIAuto_TestsToExecute AS SELECT 1')
GO
/**************************************************************************************************
Name:       spAPIAuto_TestsToExecute
Purpose:    Determine the test cases that should be run for a given testcase pattern

Date        User            Change
---------------------------------------------------------------------------------------------
09/25/2020	DK				Original procedure
10/05/2020	DK				Filter for TCIDs that match the pattern
12/04/2020	DK				Add username and password to output
01/11/2021	DK				Added support for the Token field in the Catalog table
02/02/2021	DK				Added the RequestMethod field to the output
03/30/2021	DK				Added support for the Location field from Jenkins
07/14/2021	DK				Added support for ValidateResponse field
07/22/2021  DK              Added APIKey to output
08/02/2021  DK				Added Fail400s field to the output results
09/17/2021	DK				Only select A records for TestCaseMethod
09/24/2021	DK				Add api_key_value to the output
09/30/2021	DK				Changed the source for APIKey and BearerToken to FW_Environments
10/28/2021	DK				Add StatusCode to the output
09/29/2022	DK				Added support for Parameters in the URL
10/21/2022	DK				Added support for SQL Queries (TD_SQLSquery)
11/17/2022  DK              Add support for pausing (e.g. PauseFor10Seconds)
12/07/2022	DK				Added Connection_String to output for SQL Queries
02/09/2023  DK				Added support for Enterprise ID Override, System Name and API Key
03/15/2023	DK				Wrap new fields with ISNULL so that Java doesn't break
04/11/2023	DK				Add ability to query other databases (IdentifiMember, CustomerServic and Claims Processing)
05/16/2023	DK				Add TestDescription to output to include in Console Output
07/26/2023  DK				Fix bug that was updating more than one record when a parameters field exists
07/26/2023  DK				Add custom timeout to the output
07/26/2023  DK				Add batch folder and attachment folder to the output
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_TestsToExecute 'Ragnarok-TestCase-520%', 'QA Automation', 'On-Prem', '[106] https://qr06-qa.core.valence.care/'
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIAuto_TestsToExecute
     (@test_case_pattern	VARCHAR(2000)
	 ,@environment			VARCHAR(200)
	 ,@location				VARCHAR(200)	= 'On-Prem'
	 ,@target_url			VARCHAR(200)	= ''
	 ,@record_count			INT				= 0		OUTPUT
	 ,@status				INT				= 0		OUTPUT
	 ,@message				VARCHAR(8000)	= ''	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql						VARCHAR(8000)
       ,@table_name					VARCHAR(200)
	   ,@TCID_pattern				VARCHAR(200)
	   ,@user						VARCHAR(50)
	   ,@password					VARCHAR(50)
	   ,@end_point					VARCHAR(8000)
	   ,@token_required				VARCHAR(50)
	   ,@api_key					VARCHAR(50)
	   ,@api_key_value				VARCHAR(300)
	   ,@fail_400s					VARCHAR(50)
	   ,@base_URL					VARCHAR(8000)
	   ,@include_version			VARCHAR(3)
	   ,@test_case_order			INT
	   ,@test_method_order			INT
	   ,@service_name				VARCHAR(200)
	   ,@validate_response			VARCHAR(5)
	   ,@err_num					INT				= 0
	   ,@err_msg					VARCHAR(8000)	= 'Success'
	   ,@target_system_id			INT
	   ,@target_connection_string	VARCHAR(200)
	   ,@content_type				VARCHAR(50)
	   ,@layer						VARCHAR(30)
	   ,@custom_timeout				INT
	   ,@batch_folder				VARCHAR(2000)
	   ,@attachment_folder			VARCHAR(2000)

--*************************************************************************************************
-- Gather Request variable search fields and their values 
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_data') IS NOT NULL
	DROP TABLE #table_data

CREATE TABLE #table_data
      (test_case_name			VARCHAR(200)
	  ,test_case_order			INT
	  ,TCID_pattern				VARCHAR(200)
	  ,UserID					VARCHAR(50)
	  ,Password					VARCHAR(50)
	  ,test_method_order		INT
	  ,method_name				VARCHAR(200)
	  ,table_name				VARCHAR(200)
	  ,end_point				VARCHAR(8000)
	  ,token_required			VARCHAR(50)
	  ,api_key					VARCHAR(50)
	  ,api_key_value			VARCHAR(300)
	  ,fail_400s				VARCHAR(50)
	  ,service_name				VARCHAR(8000)
	  ,base_URL					VARCHAR(8000)
	  ,include_version			VARCHAR(3)
	  ,validate_response		VARCHAR(5)
	  ,content_type				VARCHAR(50)
	  ,custom_timeout			INT)

IF OBJECT_ID('tempdb.dbo.#test_case_data') IS NOT NULL
	DROP TABLE #test_case_data

CREATE TABLE #test_case_data
      (test_case_order			INT
	  ,test_method_order		INT
	  ,table_name				VARCHAR(200)
	  ,record_id				INT
	  ,TCID						VARCHAR(200)
	  ,UserID					VARCHAR(50)
	  ,Password					VARCHAR(50)
	  ,service_URL				VARCHAR(8000)
	  ,token_required			VARCHAR(50)
	  ,api_key					VARCHAR(50)
	  ,api_key_value			VARCHAR(300)
	  ,fail_400s				VARCHAR(50)
	  ,request_method			VARCHAR(50)
	  ,request					VARCHAR(MAX)
	  ,url_parameters			VARCHAR(MAX)
	  ,query					VARCHAR(MAX)
	  ,connection_string		VARCHAR(1000)
	  ,status_code				INT
	  ,response					VARCHAR(MAX)
	  ,service_name				VARCHAR(200)
	  ,location					VARCHAR(200)
	  ,validate_response		VARCHAR(5)
	  ,enterprise_id_override	VARCHAR(20)
	  ,system_name_override		VARCHAR(20)
	  ,api_key_override			VARCHAR(200)
	  ,content_type				VARCHAR(50)
	  ,server_type				VARCHAR(30)
	  ,test_case_description	VARCHAR(1000)
	  ,custom_timeout			INT
	  ,batch_folder				VARCHAR(2000)
	  ,attachment_folder		VARCHAR(2000))

--*************************************************************************************************
-- Gather test cases that will be executed
--*************************************************************************************************
INSERT INTO #table_data
      (test_case_name
	  ,test_case_order
	  ,TCID_pattern
	  ,UserID
	  ,Password
	  ,test_method_order
	  ,method_name
	  ,table_name
	  ,end_point
	  ,token_required
	  ,api_key
	  ,api_key_value
	  ,fail_400s
	  ,service_name
	  ,base_URL
	  ,include_version
	  ,validate_response
	  ,content_type
	  ,custom_timeout)
SELECT TC.TestCaseName
      ,TC.TestCaseOrder
	  ,TC.TCID
	  ,ISNULL(TC.UserID, '')
	  ,ISNULL(TC.Password, '')
	  ,TCM.ProcessOrder
	  ,TCM.Method_Name
	  ,C.Table_Name
	  ,C.Endpoint
	  ,E.BearerToken
	  ,E.APIKey
	  ,E.APIKeyValue
	  ,C.Fail400s
	  ,C.ServiceName
	  ,ISNULL(E.URL, 'Not Available')
	  ,ISNULL(E.IncludeVersion, 'No')
	  ,ISNULL(C.ValidateResponse, 'Yes')
	  ,ISNULL(C.ContentType, 'json')
	  ,ISNULL(C.CustomTimeout, 30)
  FROM fw.TestCase			TC
  JOIN fw.TestCaseMethod	TCM
    ON TC.TestCaseName		= TCM.TestCaseName
  JOIN fw.Catalog			C
    ON TCM.Method_Name		= C.Method_Name
  LEFT JOIN FW_Environments	E
    ON C.ServiceName		= E.ServiceName
   AND E.Environment		= @environment
   AND E.Location			= @location
 WHERE TC.TestCaseName		LIKE @test_case_pattern
   AND TC.Status			= 'A'
   AND TCM.Status			= 'A'

--*************************************************************************************************
-- Lookup the target system information
--*************************************************************************************************
IF @target_url <> ''
	BEGIN
		IF LEFT(@target_url, 1) = '['
			BEGIN
				SELECT @target_system_id = SUBSTRING(@target_url, 2, CHARINDEX(']', @target_url, 1) - 2)

				SELECT @target_connection_string	= 'jdbc:sqlserver://' + S.instance_name + ';databaseName=' + S.core_database + ';integratedSecurity=true;'
				      ,@layer						= S.layer
					  ,@batch_folder				= '\\' + ISNULL(S.server_name, '') + '\' + ISNULL(S.batch_folder, '') + '\'
					  ,@attachment_folder			= '\\' + ISNULL(S.server_name, '') + '\' + ISNULL(S.attachment_folder, '') + '\'
				  FROM SystemAudit.dbo.Server		S
				 WHERE S.environment_id				= @target_system_id
			END
		ELSE
			BEGIN
				SELECT @target_system_id			= 0
					  ,@target_connection_string	= ''
			END
	END
ELSE
	BEGIN
		SELECT @target_system_id			= 0
		      ,@target_connection_string	= ''
	END

--*************************************************************************************************
-- Loop through all of the tables to get the requests that need to be executed
--*************************************************************************************************
DECLARE Gather_Test_Cases CURSOR FOR
 SELECT table_name
       ,TCID_pattern
	   ,UserID
	   ,Password
	   ,end_point
	   ,token_required
	   ,api_key
	   ,api_key_value
	   ,fail_400s
	   ,base_URL
	   ,include_version
	   ,test_case_order
	   ,test_method_order
	   ,service_name
	   ,validate_response
	   ,content_type
	   ,custom_timeout
   FROM #table_data

   OPEN Gather_Test_Cases
  FETCH NEXT FROM Gather_Test_Cases
   INTO @table_name
       ,@TCID_pattern
	   ,@user
	   ,@password
	   ,@end_point
	   ,@token_required
	   ,@api_key
	   ,@api_key_value
	   ,@fail_400s
	   ,@base_URL
	   ,@include_version
	   ,@test_case_order
	   ,@test_method_order
	   ,@service_name
	   ,@validate_response
	   ,@content_type
	   ,@custom_timeout
       
WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @table_name <> 'TD_SQLQuery'
			BEGIN

				SET @sql = 'INSERT INTO #test_case_data
								  (test_case_order
								  ,test_method_order
								  ,table_name
								  ,record_id
								  ,TCID
								  ,UserID
								  ,Password
								  ,service_URL
								  ,token_required
								  ,api_key
								  ,api_key_value
								  ,fail_400s
								  ,request_method
								  ,request
								  ,status_code
								  ,response
								  ,service_name
								  ,location
								  ,validate_response
								  ,enterprise_id_override
								  ,system_name_override
								  ,api_key_override
								  ,content_type
								  ,server_type
								  ,test_case_description
								  ,custom_timeout
								  ,batch_folder
								  ,attachment_folder)
							SELECT ' + CONVERT(VARCHAR(10), @test_case_order) + '
								  ,' + CONVERT(VARCHAR(10), @test_method_order) + '
								  ,''' + ISNULL(@table_name, '') + '''
								  ,RecordID
								  ,TCID
								  ,''' + ISNULL(@user, '') + '''
								  ,''' + ISNULL(@password, '') + '''
								  ,CASE WHEN ''' + @base_URL + ''' = ''Not Available'' THEN ''' + @base_URL + ''' ELSE 
								  ''' + @base_URL + ''' + CASE WHEN ''' + @include_version + ''' = ''Yes'' THEN ''/'' + Version + ''' + @end_point + ''' ELSE ' + '''' + @end_point + ''' END END
								  ,''' + ISNULL(@token_required, 'No') + '''
								  ,''' + ISNULL(@api_key, 'Yes') + '''
								  ,''' + ISNULL(@api_key_value, '') + '''
								  ,''' + ISNULL(@fail_400s, 'No') + '''
								  ,RequestMethod
								  ,Request
								  ,StatusCode
								  ,Response
								  ,''' + @service_name +'''
								  ,''' + @location + '''
								  ,''' + @validate_response + '''
								  ,ISNULL(EnterpriseIDOverride, '''')
								  ,ISNULL(SystemNameOverride, '''')
								  ,ISNULL(APIKeyOverride, '''')
								  ,''' + @content_type + '''
								  ,''''
								  ,TestDescription
								  ,' + CONVERT(VARCHAR(10), @custom_timeout) + '
								  ,''' + @batch_folder + '''
								  ,''' + @attachment_folder + '''
							  FROM ' + @table_name + '
							 WHERE ActiveTestCase = ''A''
							   AND TCID LIKE ''' + @TCID_pattern + ''''
				EXEC (@sql)
			END
		ELSE
			BEGIN
				SET @sql = 'INSERT INTO #test_case_data
								  (test_case_order
								  ,test_method_order
								  ,table_name
								  ,record_id
								  ,TCID
								  ,UserID
								  ,Password
								  ,service_URL
								  ,token_required
								  ,api_key
								  ,api_key_value
								  ,fail_400s
								  ,request_method
								  ,request
								  ,status_code
								  ,query
								  ,connection_string
								  ,response
								  ,service_name
								  ,location
								  ,validate_response
								  ,enterprise_id_override
								  ,system_name_override
								  ,api_key_override
								  ,content_type
								  ,server_type
								  ,test_case_description
								  ,custom_timeout
								  ,batch_folder
								  ,attachment_folder)
							SELECT ' + CONVERT(VARCHAR(10), @test_case_order) + '
								  ,' + CONVERT(VARCHAR(10), @test_method_order) + '
								  ,''' + ISNULL(@table_name, '') + '''
								  ,RecordID
								  ,TCID
								  ,''' + ISNULL(@user, '') + '''
								  ,''' + ISNULL(@password, '') + '''
								  ,''Not Available''
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,Query
								  ,''' + @target_connection_string + '''
								  ,Response
								  ,''' + @service_name +'''
								  ,NULL
								  ,NULL
								  ,ISNULL(EnterpriseIDOverride, '''')
								  ,ISNULL(SystemNameOverride, '''')
								  ,ISNULL(APIKeyOverride, '''')
								  ,''''
								  ,ServerType
								  ,TestDescription
								  ,30
								  ,''''
								  ,''''
							  FROM ' + @table_name + '
							 WHERE ActiveTestCase = ''A''
							   AND TCID LIKE ''' + @TCID_pattern + ''''

				EXEC (@sql)
			END

		-- Used to pass PauseFor10Seconds methods through
		IF LEFT(@table_name, 8) = 'PauseFor'
			BEGIN
				SET @sql = 'INSERT INTO #test_case_data
								  (test_case_order
								  ,test_method_order
								  ,table_name
								  ,record_id
								  ,TCID
								  ,UserID
								  ,Password
								  ,service_URL
								  ,token_required
								  ,api_key
								  ,api_key_value
								  ,fail_400s
								  ,request_method
								  ,request
								  ,status_code
								  ,query
								  ,response
								  ,service_name
								  ,location
								  ,validate_response
								  ,enterprise_id_override
								  ,system_name_override
								  ,api_key_override
								  ,content_type
								  ,server_type
								  ,test_case_description
								  ,custom_timeout
								  ,batch_folder
								  ,attachment_folder)
							SELECT ' + CONVERT(VARCHAR(10), @test_case_order) + '
								  ,' + CONVERT(VARCHAR(10), @test_method_order) + '
								  ,''' + ISNULL(@table_name, '') + '''
								  ,0
								  ,''' + @table_name + '''
								  ,''' + ISNULL(@user, '') + '''
								  ,''' + ISNULL(@password, '') + '''
								  ,''Not Available''
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL
								  ,''' + @service_name +'''
								  ,NULL
								  ,NULL
								  ,''''
								  ,''''
								  ,''''
								  ,''''
								  ,''''
								  ,''''
								  ,30
								  ,''''
								  ,'''''

				EXEC (@sql)
			END

		-- If the table has a Parameters field then include the parameters field in the output
		IF EXISTS(SELECT T.name FROM sys.tables T JOIN sys.columns C ON T.object_id = C.object_id WHERE C.name = 'Parameters' AND T.name = @table_name)
			BEGIN

				SELECT @sql = 'UPDATE TD
				                  SET url_parameters = T.Parameters
								 FROM ' + @table_name + ' T
								 JOIN #test_case_data TD
								   ON T.RecordID = TD.record_id
								  AND TD.table_name = ''' + @table_name + ''''
				EXEC (@sql)

			END

		FETCH NEXT FROM Gather_Test_Cases
         INTO @table_name
		     ,@TCID_pattern
			 ,@user
			 ,@password
		     ,@end_point
			 ,@token_required
			 ,@api_key
			 ,@api_key_value
			 ,@fail_400s
		     ,@base_URL
		     ,@include_version
			 ,@test_case_order
		     ,@test_method_order
			 ,@service_name
			 ,@validate_response
			 ,@content_type
			 ,@custom_timeout
	END

CLOSE Gather_Test_Cases
DEALLOCATE Gather_Test_Cases

--*************************************************************************************************
-- For any SQL Queries that do not hit the Core database update the connection string
--*************************************************************************************************
UPDATE TCD
   SET connection_string	= D.ConnectionString
 FROM #test_case_data		TCD
 JOIN fw.[Database]			D
   ON TCD.server_type		= D.ServerType
  AND D.Layer				= @layer

--*************************************************************************************************
-- Output the test cases to excute
--*************************************************************************************************
SELECT @record_count = COUNT(*)
  FROM #test_case_data

SELECT test_case_order
      ,test_method_order
	  ,TCID
	  ,UserID	
	  ,Password
	  ,table_name				AS TableName
	  ,record_id				AS RecordID
	  ,token_required			AS Token_Required
	  ,api_key					AS API_Key
	  ,api_key_value			AS API_Key_Value
	  ,fail_400s				AS Fail400s
	  ,service_URL				AS URL
	  ,request_method			AS Request_Method
	  ,request					AS Request
	  ,url_parameters			AS Parameters
	  ,query					AS Query
	  ,connection_string		AS Connection_String
	  ,status_code				AS StatusCode
	  ,response					AS Response
	  ,service_name				AS Service_Name
	  ,location					AS Location
	  ,validate_response		AS Validate_Response
	  ,enterprise_id_override	AS EnterpriseIDOverride
	  ,system_name_override		AS SystemNameOverride
	  ,api_key_override			AS APIKeyOverride
	  ,content_type				AS ContentType
	  ,test_case_description	AS TestDescription
	  ,custom_timeout			AS CustomTimeout
	  ,batch_folder				AS BatchFolder
	  ,attachment_folder		AS AttachmentFolder
  FROM #test_case_data
 ORDER BY test_case_order
         ,test_method_order
		 ,TCID

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#table_data') IS NOT NULL
	DROP TABLE #table_data

IF OBJECT_ID('tempdb.dbo.#test_case_data') IS NOT NULL
	DROP TABLE #test_case_data

SELECT @status	= @err_num
      ,@message	= @err_msg
END
GO