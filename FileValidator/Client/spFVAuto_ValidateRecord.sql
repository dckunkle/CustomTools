IF OBJECT_ID('dbo.spFVAuto_ValidateRecord') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_ValidateRecord AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_ValidateRecord
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
05/18/2020	DK				Add validation in related table
06/22/2020  DK				Add Jenkins logging
10/21/2020	DK				Add field: type default value (ex. mailing address defaulted to location)
11/13/2020	DK				Add the core type, Lookup, so that comparisons are not done
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_ValidateRecord 'UAT-TestCase-1001%','ImportXLSXRemarkCode','TD_ImportXLSXRemarkCode',4, 20
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_ValidateRecord
     (@test_case_name		VARCHAR(2000)
	 ,@test_method			VARCHAR(2000)
	 ,@table_name			VARCHAR(200)
	 ,@record_id			VARCHAR(200)
	 ,@i_log_id				INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @search_sql			NVARCHAR(4000)
       ,@sql				NVARCHAR(4000)
	   ,@gid_sql			NVARCHAR(4000)
	   ,@sid_column			VARCHAR(200)

	   ,@database_name		VARCHAR(200)
	   ,@variable			VARCHAR(200)
	   ,@variable_value		VARCHAR(4000)
	   ,@variable_name		VARCHAR(4000)
	   ,@variable_count		INT
	   ,@core_sid			INT				= 0

	   ,@status				VARCHAR(100)	
	   ,@TCID				VARCHAR(2000)

	   ,@file_table_name	VARCHAR(200)	
       ,@file_field			VARCHAR(200)	
	   ,@file_value			VARCHAR(8000)

	   ,@core_table_name	VARCHAR(200)	
	   ,@core_field			VARCHAR(200)	
	   ,@core_value			VARCHAR(8000)
	   ,@core_default		VARCHAR(8000)	
	   ,@core_type			VARCHAR(100)	
	   ,@core_lookup_table	VARCHAR(200)
	   ,@core_lookup_field	VARCHAR(200)
	   ,@core_lookup_gid	VARCHAR(200)

	   ,@search_keys		VARCHAR(8000)	= ''
	   ,@search_values		VARCHAR(8000)	= ''
	   ,@err_type			VARCHAR(20)
	   ,@err_msg			VARCHAR(8000)
	   ,@tc_log_id			INT

	   ,@test_method_log	CHAR(50)
	   ,@TCID_log			CHAR(40)
	   ,@record_id_log		CHAR(15)
	   ,@default_field		VARCHAR(200)

--*************************************************************************************************
-- Collect additional information for the logging
--*************************************************************************************************
SET @sql = 'SELECT @data = ISNULL(TCID, '''') FROM COREAUTO.CoreFileCreator.dbo.' + @table_name + ' WHERE RecordID = ' + CONVERT(VARCHAR(100), @record_id)
EXEC sp_executesql @sql, N'@data NVARCHAR(4000) OUTPUT', @data=@TCID OUTPUT

--*************************************************************************************************
-- Write to Jenkins log - Test Method detail
--*************************************************************************************************
SELECT @test_method_log = LEFT(RIGHT(@test_method, 50) + SPACE(50), 50)
      ,@TCID_log		= LEFT(RIGHT(@TCID, 40) + SPACE(40), 40)
	  ,@record_id_log	= LEFT(CONVERT(VARCHAR(15), @record_id) + SPACE(15), 15)

PRINT ' '
PRINT '-Method----------------------------------------------TCID--------------------------------------Record ID----------------------------------------------------'
PRINT ' ' + ISNULL(@test_method_log, '') + '  ' + ISNULL(@TCID_log, '') + '  ' + ISNULL(@record_id_log, '')
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' '
PRINT '    Matching Criteria'
--*************************************************************************************************
-- Collect the search criteria to find the data in Core
--*************************************************************************************************
SELECT @search_sql		= C.sql
      ,@sid_column		= C.sid_column
  FROM COREAUTO.CoreFileCreator.fw.TestCaseValidationCriteria C
 WHERE table_name = @table_name
 
-- Report missing config and exit
IF ISNULL(@search_sql, '') = ''
	BEGIN
		SELECT @err_type = 'Config'
			  ,@err_msg = 'The File Validator has not been configured for this type of file.'

		EXEC spFVAuto_LogTestCase @i_log_id ,@test_case_name ,@test_method ,@TCID ,@record_id ,@core_sid, @search_keys, @search_values, @err_type, @err_msg, @tc_log_id
		GOTO MISSING_DATA
	END

SET @database_name = dbo.fnDCAuto_GetDatabaseName()
SET @database_name = ISNULL(@database_name, '')

SET @variable_count = 1
WHILE @variable_count < 10
	BEGIN

		SET @sql = 'SELECT @variable = variable_' + CONVERT(VARCHAR(2), @variable_count) + ' FROM COREAUTO.CoreFileCreator.fw.TestCaseValidationCriteria C WHERE table_name = ''' + @table_name + ''''
		EXEC sp_executesql @sql, N'@variable VARCHAR(4000) OUTPUT', @variable=@variable OUTPUT

		IF @variable <> ''
			BEGIN

				SET @search_keys = @search_keys + @variable + '~'

				SET @sql = 'SELECT @value = [' + @variable + '] FROM COREAUTO.CoreFileCreator.dbo.' + @table_name + ' WHERE RecordID  = ' + CONVERT(VARCHAR(100), @record_id)
				EXEC sp_executesql @sql, N'@value VARCHAR(4000) OUTPUT', @value=@variable_value OUTPUT
				
				SET @variable_value = ISNULL(@variable_value, '')

				-- If the key value was defaulted, figure out what the value should have been
				IF @variable_value = ''
					BEGIN

						SELECT @core_default = ISNULL(core_default_value, '') FROM COREAUTO.CoreFileCreator.fw.TestCaseValidation WHERE table_name = @table_name AND file_field = @variable
						IF @core_default = 'GETDATE()' 
							BEGIN SET @variable_value = REPLACE(CONVERT(VARCHAR(10), GETDATE(), 102), '.','-') END
						ELSE
							BEGIN IF @core_default <> '' SET @variable_value = @core_default END
						
					END

				SET @search_values = @search_values + CONVERT(VARCHAR(2000), @variable_value) + '~'

				SET @variable_name = '~variable_' + CONVERT(VARCHAR(2), @variable_count) + '~'
				IF @variable <> '' SELECT @search_sql = REPLACE(@search_sql, @variable_name, @variable_value)

				PRINT '      ' + LEFT(ISNULL(@variable, '') + ':' + SPACE(35), 35) + ' ' + LEFT(ISNULL(@variable_value, '') + SPACE(35), 35)
			END

		SET @variable_count = @variable_count +1
	END


--Finally, replace the proper database name
SELECT @search_sql = REPLACE(@search_sql, '~DB~', @database_name)

-- Use the sql to find the sid of the record in Core
EXEC sp_executesql @search_sql, N'@data INT OUTPUT', @data=@core_sid OUTPUT

IF RIGHT(@search_keys, 1) = '~' SET @search_keys = LEFT(@search_keys, LEN(@search_keys) -1)
IF RIGHT(@search_values, 1) = '~' SET @search_values = LEFT(@search_values, LEN(@search_values) -1)

PRINT '      ' + LEFT('Core_sid:' + SPACE(36), 36) + CONVERT(VARCHAR(20), @core_sid) 
PRINT '  '
PRINT '  '
PRINT '    Field Validations'
PRINT '      -Status-File Field------------------------File Value--------------------Core Field------------------------Core Value--------------------Default-------'
--*************************************************************************************************
-- Try to find a matching record in Core, if no match log the error
--*************************************************************************************************
IF ISNULL(@core_sid, 0) = 0
	BEGIN
		SELECT @err_type = 'Missing'
			  ,@err_msg = 'No Core data was found for this record'

		EXEC spFVAuto_LogTestCase @i_log_id ,@test_case_name ,@test_method ,@TCID ,@record_id ,@core_sid, @search_keys, @search_values, @err_type, @err_msg, @tc_log_id
		GOTO MISSING_DATA
	END 
ELSE
	BEGIN
		-- Write to the testcase log
		EXEC spFVAuto_LogTestCase @i_log_id ,@test_case_name ,@test_method ,@TCID ,@record_id ,@core_sid, @search_keys, @search_values, '', '', @tc_log_id OUTPUT
	END

--*************************************************************************************************
-- Loop through all of the field validations and log the results
--*************************************************************************************************
DECLARE Validation_Cursor CURSOR FOR
 SELECT table_name
	   ,file_field
	   ,core_table_name
	   ,core_field
	   ,core_default_value
	   ,core_field_type
	   ,gid_lookup_query
   FROM COREAUTO.CoreFileCreator.fw.TestCaseValidation
  WHERE table_name		= @table_name 
    AND status			IN ('K', 'A')
  ORDER BY field_order

   OPEN Validation_Cursor
  FETCH NEXT FROM Validation_Cursor
   INTO @file_table_name, @file_field, @core_table_name, @core_field, @core_default, @core_type, @gid_sql

  WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @status = ''
		SET @core_value = ''

		-- Get the value that was in the file
		SET @sql = 'SELECT @data = ISNULL(CONVERT(VARCHAR(8000),[' + @file_field + ']), '''') FROM COREAUTO.CoreFileCreator.dbo.' + @file_table_name + ' WHERE RecordID = ' +  CONVERT(VARCHAR(100), @record_id)
		EXEC sp_executesql @sql, N'@data NVARCHAR(4000) OUTPUT', @data=@file_value OUTPUT

		-- Get the value that is in Core
		IF @gid_sql <> ''
			BEGIN
				-- Find the data in the related table
				SET @core_value = ''
				SET @sql = REPLACE(@gid_sql, '~sid_value~', @core_sid)
				SET @sql = REPLACE(@sql, '~field_value~', @core_field)
				EXEC sp_executesql @sql, N'@data NVARCHAR(4000) OUTPUT', @data=@core_value OUTPUT
			END
		ELSE
			BEGIN
			
				SET @sql = 'SELECT @data = ISNULL(CONVERT(VARCHAR(8000), ' + @core_field + '), '''') FROM ' + @database_name + '.dbo.' + @core_table_name + ' WHERE ' + @sid_column + ' = ' +  CONVERT(VARCHAR(100), @core_sid) --+ ' AND record_status = ''A''' 
				EXEC sp_executesql @sql, N'@data NVARCHAR(4000) OUTPUT', @data=@core_value OUTPUT

			END

		--*************************************************************************************************
		-- Compare the values to see if they are the same
		--*************************************************************************************************
		IF @core_default = 'GETDATE()' BEGIN SET @core_default = REPLACE(CONVERT(VARCHAR(10), GETDATE(), 102), '.','-') END

		IF LEFT(@core_default, 6) = 'field:'
			BEGIN

				SET @default_field = SUBSTRING(@core_default, 7, 999)

				SET @sql = 'SELECT @data = ISNULL(CONVERT(VARCHAR(8000),' + @default_field + '), '''') FROM COREAUTO.CoreFileCreator.dbo.' + @file_table_name + ' WHERE RecordID = ' +  CONVERT(VARCHAR(100), @record_id)
				EXEC sp_executesql @sql, N'@data NVARCHAR(4000) OUTPUT', @data=@core_default OUTPUT
				
			END

		IF (@core_type = 'Date' OR @core_type = 'LookupDate')
			BEGIN

				SELECT @file_value		= ISNULL(@file_value, '')
				      ,@core_value		= ISNULL(@core_value, '')
					  ,@core_default	= ISNULL(@core_default, '')

				IF @file_value <> ''	SET @file_value		= REPLACE(CONVERT(VARCHAR(10), CONVERT(DATE, @file_value),102), '.','-')
				IF @core_Value <> ''	SET @core_Value		= REPLACE(CONVERT(VARCHAR(10), CONVERT(DATE, @core_Value),102), '.','-')
				IF @core_default <> ''	SET @core_default	= REPLACE(CONVERT(VARCHAR(10), CONVERT(DATE, @core_default),102), '.','-')

			END

		IF @core_type = 'Money'
			BEGIN
				IF @file_value <> '' SET @file_value = CONVERT(VARCHAR(100), CONVERT(MONEY, @file_value))
				SET @core_value = CONVERT(VARCHAR(100), CONVERT(MONEY, @core_Value))
			END

		-- If there is a default value, and the file value is blank, check to see if the Core value has been defaulted
		IF ISNULL(@core_default, '') <> '' AND ISNULL(@file_value, '') = ''
			BEGIN
				
				IF @core_default = @core_value 
					BEGIN
						SET @status = 'Pass-Defaulted'
					END

			END

		IF @status = ''
			BEGIN

				SELECT @status = CASE WHEN @core_type	= 'Lookup'	
				                        OR @core_type	= 'LookupDate'	THEN 'Look' 
									  WHEN @file_value	= @core_Value	THEN 'Pass'	
									  ELSE 'Fail'
								  END
			END

		--*************************************************************************************************
		-- Write to the Jenkins log
		--*************************************************************************************************
		DECLARE @status_log			CHAR(5)
			   ,@file_field_log		CHAR(32)
			   ,@file_value_log		CHAR(28)
			   ,@core_field_log		CHAR(32)
			   ,@core_value_log		CHAR(28)
			   ,@default_log		CHAR(14)

		SELECT @status_log			= LEFT(ISNULL(CASE WHEN @status = 'Pass-Defaulted' THEN 'Def' ELSE @status END,'') + SPACE(5), 5)
		      ,@file_field_log		= LEFT(ISNULL(@file_field,'') + SPACE(32), 32)
			  ,@file_value_log		= LEFT(ISNULL(@file_value,'') + SPACE(28), 28)
			  ,@core_field_log		= LEFT(ISNULL(@core_field,'') + SPACE(32), 32)
			  ,@core_value_log		= LEFT(ISNULL(@core_value,'') + SPACE(28), 28)
			  ,@default_log			= LEFT(ISNULL(@core_default,'') + SPACE(14), 14)

		PRINT '       ' + @status_log + '  ' + @file_field_log + '  ' + @file_value_log + '  ' + @core_field_log + '  ' + @core_value_log + '  ' + @default_log

		--*************************************************************************************************
		-- Log the results and move on to the next field to validate
		--*************************************************************************************************
		EXEC spFVAuto_LogTestCaseValidation @tc_log_id, @status, @file_field ,@file_value , @core_field ,@core_value ,@core_default

		FETCH NEXT FROM Validation_Cursor
		 INTO @file_table_name, @file_field, @core_table_name, @core_field, @core_default, @core_type, @gid_sql
	END

	PRINT '      ------------------------------------------------------------------------------------------------------------------------------------------------------'
	PRINT '  '
	PRINT '  '
	PRINT '  '
CLOSE Validation_Cursor
DEALLOCATE Validation_Cursor

--*************************************************************************************************
-- Log the results and move on to the next field to validate
--*************************************************************************************************
MISSING_DATA:

END
GO