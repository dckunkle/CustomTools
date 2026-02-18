IF OBJECT_ID('dbo.spAPIAuto_GenerateTestCase') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIAuto_GenerateTestCase AS SELECT 1')
GO
/**************************************************************************************************
Name:       spAPIAuto_GenerateTestCase
Purpose:    Given a test case generate the necessary test cases

Date        User            Change
---------------------------------------------------------------------------------------------
02/12/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_GenerateTestCase 'search-claim-basicinfo'
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIAuto_GenerateTestCase
     (@method_name	VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @request_sql		NVARCHAR(MAX)
       ,@request_template	NVARCHAR(MAX)
       ,@request_json		NVARCHAR(MAX)

	   ,@response_sql		NVARCHAR(MAX)
	   ,@response_template	NVARCHAR(MAX)
	   ,@response_json		NVARCHAR(MAX)

	   ,@table_name			VARCHAR(200)
	   ,@modifier			VARCHAR(200)

	   ,@request_field_1	VARCHAR(200)
	   ,@request_field_2	VARCHAR(200)
	   ,@request_field_3	VARCHAR(200)
	   ,@request_field_4	VARCHAR(200)
	   ,@request_field_5	VARCHAR(200)
	   ,@request_field_6	VARCHAR(200)
	   ,@request_field_7	VARCHAR(200)
	   ,@request_field_8	VARCHAR(200)
	   ,@request_field_9	VARCHAR(200)
	   ,@request_field_10	VARCHAR(200)

	   ,@method_abbreviation	VARCHAR(50)
	   ,@counter				INT
	   ,@sql					NVARCHAR(MAX)
	   ,@TCID					VARCHAR(100)
	   ,@top_records			VARCHAR(50)

--*************************************************************************************************
-- Gather the details about the method being called 
--*************************************************************************************************
SELECT @request_sql									= GD.request_sql
      ,@response_template							= GD.response_sql
      ,@table_name									= C.TableName
	  ,@method_abbreviation							= UPPER(GD.method_abbreviation)
	  ,@modifier									= GD.modifier
	  ,@top_records									= GD.top_records
  FROM COREAUTO.APIAutomation.gen.GeneratorDetail	GD
  JOIN COREAUTO.APIAutomation.fw.Catalog			C
    ON GD.service_name								= C.ServiceName
   AND GD.endpoint									= C.Endpoint
 WHERE GD.method_name								= @method_name

--*************************************************************************************************
-- Adjust the request SQL and the response template slightly
--*************************************************************************************************
SELECT @response_template = 'SET @x = (' + @response_template + ')'
SELECT @request_sql = REPLACE(@request_sql, 'TOP n', 'TOP ' + @top_records)

 --*************************************************************************************************
-- Clear any existing auto generated test cases
--*************************************************************************************************
SET @sql = 'DELETE 
              FROM COREAUTO.APIAutomation.dbo.' + @table_name + '
			 WHERE TCID LIKE ''AUTO-' + @method_abbreviation + '%'''

EXEC(@sql)

--*************************************************************************************************
-- Build a table that is going to collect the data for the reqest 
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##request_data') IS NOT NULL
	DROP TABLE ##request_data

CREATE TABLE ##request_data
      (request_field_1		VARCHAR(400)
	  ,request_field_2		VARCHAR(400)
	  ,request_field_3		VARCHAR(400)
	  ,request_field_4		VARCHAR(400)
	  ,request_field_5		VARCHAR(400)
	  ,request_field_6		VARCHAR(400)
	  ,request_field_7		VARCHAR(400)
	  ,request_field_8		VARCHAR(400)
	  ,request_field_9		VARCHAR(400)
	  ,request_field_10		VARCHAR(400)
	  ,sort_field			VARCHAR(400))  -- This field is used to help randomize selecting records

SET @request_sql = 'INSERT INTO ##request_data
						  (request_field_1
						  ,request_field_2
						  ,request_field_3
						  ,request_field_4
						  ,request_field_5
						  ,request_field_6
						  ,request_field_7
						  ,request_field_8
						  ,request_field_9
						  ,request_field_10
						  ,sort_field) ' + @request_sql
EXEC(@request_sql)

--*************************************************************************************************
-- Build the request template that will be submitted  
--*************************************************************************************************
SELECT @request_template = dbo.fnAPICommon_GetRequestJSON(@method_name)

--*************************************************************************************************
-- Now loop through all of the values that will be used to create request and response objects
--*************************************************************************************************
DECLARE Request_Data CURSOR FOR
 SELECT ISNULL(request_field_1, '')
	   ,ISNULL(request_field_2, '')
	   ,ISNULL(request_field_3, '')
	   ,ISNULL(request_field_4, '')
	   ,ISNULL(request_field_5, '')
	   ,ISNULL(request_field_6, '')
	   ,ISNULL(request_field_7, '')
	   ,ISNULL(request_field_8, '')
	   ,ISNULL(request_field_9, '')
	   ,ISNULL(request_field_10, '')
   FROM ##request_data

   OPEN Request_Data
  FETCH NEXT FROM Request_Data
   INTO @request_field_1, @request_field_2, @request_field_3, 
        @request_field_4, @request_field_5, @request_field_6, 
		@request_field_7, @request_field_8, @request_field_9,
		@request_field_10  

	SET @counter = 1

  WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Set the request JSON to the request template 
		SET @request_json = @request_template
		SET @response_sql = @response_template

		-- Make replacements for the request
		IF @request_field_1  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_1~',  @request_field_1)
		IF @request_field_2  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_2~',  @request_field_2)
		IF @request_field_3  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_3~',  @request_field_3)
		IF @request_field_4  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_4~',  @request_field_4)
		IF @request_field_5  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_5~',  @request_field_5)
		IF @request_field_6  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_6~',  @request_field_6)
		IF @request_field_7  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_7~',  @request_field_7)
		IF @request_field_8  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_8~',  @request_field_8)
		IF @request_field_9  <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_9~',  @request_field_9)
		IF @request_field_10 <> '' SELECT @request_json = REPLACE(@request_json, '~request_field_10~', @request_field_10)

		-- Make replacements for the response
		IF @request_field_1  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_1~',  @request_field_1)
		IF @request_field_2  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_2~',  @request_field_2)
		IF @request_field_3  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_3~',  @request_field_3)
		IF @request_field_4  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_4~',  @request_field_4)
		IF @request_field_5  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_5~',  @request_field_5)
		IF @request_field_6  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_6~',  @request_field_6)
		IF @request_field_7  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_7~',  @request_field_7)
		IF @request_field_8  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_8~',  @request_field_8)
		IF @request_field_9  <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_9~',  @request_field_9)
		IF @request_field_10 <> '' SELECT @response_sql = REPLACE(@response_sql, '~request_field_10~', @request_field_10)

		EXEC sp_executesql @response_sql,N'@x NVARCHAR(MAX) OUTPUT', @x = @response_json OUTPUT

--*************************************************************************************************
-- Look for embedded single quotes and try to fix them (replace a single quote with two)
--*************************************************************************************************
SELECT @response_json = REPLACE(@response_json,'''','''''')

--*************************************************************************************************
-- Save the requests and responses
--*************************************************************************************************
		SELECT @TCID = 'AUTO-' + @method_abbreviation + '-' + RIGHT('00000' + CONVERT(VARCHAR(5), @counter), 5)
	    SELECT @sql  = 'INSERT INTO COREAUTO.APIAutomation.dbo.' + @table_name + '
			                  (TCID
							  ,request
							  ,response)
						SELECT ''' + @TCID + '''
						      ,''' + @request_json + '''
							  ,''' + @response_json + ''''
		EXEC(@sql)

		SET @counter = @counter +1

		FETCH NEXT FROM Request_Data
		 INTO @request_field_1, @request_field_2, @request_field_3, 
			  @request_field_4, @request_field_5, @request_field_6, 
			  @request_field_7, @request_field_8, @request_field_9,
			  @request_field_10
	END

CLOSE Request_Data
DEALLOCATE Request_Data

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##request_data') IS NOT NULL
	DROP TABLE ##request_data

END
GO