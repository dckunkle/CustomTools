IF OBJECT_ID('dbo.fnAPICommon_GetRequestJSON') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAPICommon_GetRequestJSON() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnAPICommon_GetRequestJSON
Purpose:    Build the shell of the proper JSON request based on the method

Date        User            Change
---------------------------------------------------------------------------------------------
02/13/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT dbo.fnAPICommon_GetRequestJSON('search-provider-state-lastName') request_template
***************************************************************************************************/
ALTER FUNCTION dbo.fnAPICommon_GetRequestJSON
     (@method_name	VARCHAR(200))

RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @service_name	VARCHAR(200)
	       ,@endpoint		VARCHAR(200)
		   ,@request_json	VARCHAR(MAX)

		   ,@field_name		VARCHAR(50)
		   ,@field_type		VARCHAR(50)
		   ,@field_default	VARCHAR(50)

--*************************************************************************************************
-- From the method_name, find out the associated service and endpoint to to get the request definition
--*************************************************************************************************
SELECT @service_name	= GD.service_name
	  ,@endpoint		= GD.endpoint
  FROM COREAUTO.APIAutomation.gen.GeneratorDetail	GD
 WHERE GD.method_name	= @method_name

--*************************************************************************************************
-- Build a table from the request detail
--*************************************************************************************************
DECLARE @request_detail TABLE
       (field_name		VARCHAR(50)
	   ,field_order		INT
	   ,field_type		VARCHAR(50)
	   ,field_default	VARCHAR(50))

INSERT INTO @request_detail
      (field_name
	  ,field_order
	  ,field_type
	  ,field_default)
SELECT RD.field_name
      ,RD.field_order
	  ,RD.field_type
	  ,RD.field_default
  FROM COREAUTO.APIAutomation.gen.RequestDetail RD
 WHERE RD.service_name	= @service_name
   AND RD.endpoint		= @endpoint

--*************************************************************************************************
-- Build a table of the fields the generator is going to use for this request
--*************************************************************************************************
DECLARE @request_variables TABLE
       (field1		VARCHAR(100)
	   ,field2		VARCHAR(100)
	   ,field3		VARCHAR(100)
	   ,field4		VARCHAR(100)
	   ,field5		VARCHAR(100)
	   ,field6		VARCHAR(100)
	   ,field7		VARCHAR(100)
	   ,field8		VARCHAR(100)
	   ,field9		VARCHAR(100)
	   ,field10		VARCHAR(100))

INSERT INTO @request_variables
      (field1
	  ,field2
	  ,field3
	  ,field4
	  ,field5
	  ,field6
	  ,field7
	  ,field8
	  ,field9
	  ,field10)
SELECT GD.request_field_1
      ,GD.request_field_2
	  ,GD.request_field_3
	  ,GD.request_field_4
	  ,GD.request_field_5
	  ,GD.request_field_6
	  ,GD.request_field_7
	  ,GD.request_field_8
	  ,GD.request_field_9
	  ,GD.request_field_10
  FROM COREAUTO.APIAutomation.gen.GeneratorDetail GD
 WHERE GD.method_name		= @method_name

--*************************************************************************************************
-- Loop through the request details and generate an appropriate request
--*************************************************************************************************
SET @request_json = '{'

DECLARE Request_Detail CURSOR FOR
 SELECT field_name
	   ,field_type
	   ,field_default
   FROM @request_detail
  ORDER BY field_order 

   OPEN Request_Detail
  FETCH NEXT FROM Request_Detail
   INTO @field_name, @field_type, @field_default

  WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Check to see if any of the fields will be populated with variable data, if so add a placeholder for the variable to be replaced later on
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field1  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_1~"' ELSE '~request_field_1~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field2  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_2~"' ELSE '~request_field_2~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field3  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_3~"' ELSE '~request_field_3~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field4  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_4~"' ELSE '~request_field_4~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field5  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_5~"' ELSE '~request_field_5~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field6  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_6~"' ELSE '~request_field_6~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field7  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_7~"' ELSE '~request_field_7~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field8  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_8~"' ELSE '~request_field_8~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field9  = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_9~"' ELSE '~request_field_9~' END
		IF EXISTS(SELECT TOP 1 * FROM @request_variables WHERE field10 = @field_name) SET @field_default = CASE WHEN @field_type = 'String' OR @field_type = 'Date' THEN '"~request_field_10~"' ELSE '~request_field_10~' END
		
		SET @request_json = @request_json + '"' + @field_name + '": ' + @field_default + ','

		FETCH NEXT FROM Request_Detail
		 INTO @field_name, @field_type, @field_default

	END

CLOSE Request_Detail
DEALLOCATE Request_Detail

--Strip off the last comma and add the trailing curly brace for the request
SET @request_json = LEFT(@request_json, LEN(@request_json) - 1)
IF ISNULL(@request_json, '') <> '' SET @request_json = @request_json + '}'

	RETURN @request_json
END
GO