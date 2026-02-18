/**************************************************************************************************
Purpose:	Given the screen and the stored procedure, create a stored procedure that will work
            with automation to modify records

Date--------User----Change-------------------------------------------------------------------------
01/09/2020  DK		Original Version

***************************************************************************************************/
SET NOCOUNT ON

DECLARE @screen_gid			INT				= 130	
	   ,@method				VARCHAR(128)	= 'BusinessUnitsBusinessTaxInfo'
       ,@sp_name			VARCHAR(128)	= 'prPMAddModify_BusTaxInfo'
	   ,@entity				VARCHAR(200)	= 'Business_Tax_Info'

--*************************************************************************************************
	   ,@max_parameter_len	INT
	   ,@database_name		VARCHAR(128)	
	   ,@td_table			VARCHAR(128)	
       ,@sql				VARCHAR(MAX)	= ''
	   ,@sql_temp			VARCHAR(MAX)
	   ,@parameter_line		VARCHAR(200)
	   ,@crlf				VARCHAR(10)		= CHAR(13) + CHAR(10)
	   ,@full_sp_name		VARCHAR(200)
	   ,@dc_sp_name			VARCHAR(128)	= 'spDCAuto_Create'
	   ,@field_name			VARCHAR(400)
	   ,@field_order		INT
	   ,@spaces				INT

--*************************************************************************************************
-- Set some initial values
--*************************************************************************************************
SELECT @dc_sp_name		= @dc_sp_name + @method
SELECT @database_name	= dbo.fnDCAuto_GetDatabaseName()
SELECT @sp_name			= 'dbo.' + @sp_name 
SELECT @full_sp_name	= @database_name + '.' + @sp_name

SELECT @td_table		= Table_Name
  FROM COREAUTO.CoreAutomation.fw.Catalog
 WHERE Method_Name		= @method
 PRINT @td_table
--*************************************************************************************************
-- Gather the screen fields and defaults based on the screen_gid
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#screen') IS NOT NULL
	DROP TABLE #screen

CREATE TABLE #screen
      (field_order		INT
	  ,parameter_order	INT				DEFAULT(0)	
	  ,field_name		VARCHAR(200)
	  ,default_value	VARCHAR(200)
	  ,required			BIT
	  ,locked			BIT
	  ,valid_values		BIT)

INSERT INTO #screen
      (field_order
	  ,field_name
	  ,default_value
	  ,required
	  ,locked
	  ,valid_values)
SELECT SD.Field_Order
      ,SD.Label
	  ,ISNULL(SD.Default_Value,'')
	  ,CASE WHEN CHARINDEX('R',SD.Field_Tag,1) <> 0 THEN 1
	        ELSE 0
		END
	  ,SD.Field_Locked
	  ,CASE WHEN ISNULL(SD.vary_combo_type,'') <> '' THEN 1
	        ELSE 0
		END
  FROM Screen_Details SD
 WHERE SD.Screen_GID		= @screen_gid
   --AND ISNULL(SD.Label,'')	<> ''

;WITH Order_CTE
   AS(SELECT field_order
			,ROW_NUMBER() OVER(ORDER BY field_order ASC) AS parameter_order
		FROM #screen)
UPDATE #screen
   SET parameter_order	= O.parameter_order + 14
  FROM Order_CTE		O
  JOIN #screen			C
    ON O.field_order	= C.field_order

UPDATE #screen
   SET field_name = CASE WHEN required = 1 THEN '*'
                         ELSE ''
					 END + REPLACE(REPLACE(REPLACE(field_name,':',''),' ',''),'/','')
SELECT * FROM #screen
--*************************************************************************************************
-- Gather the parameters that will be required when calling the stored procedure 
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#parameters') IS NOT NULL
	DROP TABLE #parameters

CREATE TABLE #parameters
      (parameter_order		INT
	  ,parameter_name		VARCHAR(128)
	  ,parameter_type		VARCHAR(100)
	  ,parameter_length		INT
	  ,parameter_precision	INT
	  ,locked				BIT				DEFAULT(0))

SET @sql_temp = '
INSERT INTO #parameters
      (parameter_order
	  ,parameter_name
	  ,parameter_type
	  ,parameter_length
	  ,parameter_precision)
SELECT P.parameter_id
      ,P.name
      ,TYPE_NAME(P.user_type_id)
	  ,P.max_length
	  ,ODBCPREC(P.system_type_id, P.max_length, P.precision)
  FROM ' + @database_name + '.sys.parameters		P
 WHERE P.OBJECT_ID			= OBJECT_ID(''' + @full_sp_name + ''')'

EXEC (@sql_temp)
--SELECT * FROM #parameters
 SELECT @max_parameter_len = MAX(LEN(P.parameter_name))
   FROM #parameters	P

-- Increase the size of select parameters to avoid truncation errors from automation data
UPDATE #parameters
   SET parameter_type	= 'varchar'
 WHERE parameter_order	> 14
   AND parameter_type	= 'char'

UPDATE #parameters
   SET parameter_length	= '50'
 WHERE parameter_order	> 14
   AND parameter_type	= 'varchar'
   AND parameter_length < 50

--*************************************************************************************************
-- Gather the fields fromt the TD table in CoreAutomation to populate the 
--*************************************************************************************************
DECLARE @action_field	INT
       ,@record_field	INT

IF OBJECT_ID('tempdb.dbo.#automation_data') IS NOT NULL
	DROP TABLE #automation_data

CREATE TABLE #automation_data
      (field_order		INT
	  ,field_name		VARCHAR(128)
	  ,field_type		VARCHAR(100)
	  ,field_length		INT
	  ,field_precision	INT
	  ,default_value	VARCHAR(200)	DEFAULT(''))

SET @sql_temp = '
INSERT INTO #automation_data
      (field_order
	  ,field_name
	  ,field_type
	  ,field_length
	  ,field_precision)
SELECT C.column_id
      ,C.name
      ,TYPE_NAME(C.user_type_id)
	  ,C.max_length
	  ,ODBCPREC(C.system_type_id, C.max_length, C.precision)
  FROM COREAUTO.CoreAutomation.sys.columns		C
 WHERE C.object_id				IN (SELECT object_id
                                      FROM COREAUTO.CoreAutomation.sys.objects
									 WHERE name = ''' + @td_table + ''')
   AND C.column_id > 5'

EXEC (@sql_temp)

-- Now remove all of the TestRail fields before building a table
SELECT @action_field = field_order FROM #automation_data WHERE field_name = 'ACTION'
SELECT @Record_field = field_order FROM #automation_data WHERE field_name = 'RecordID'
DELETE FROM #automation_data WHERE field_order BETWEEN @action_field AND @record_field - 1

--*************************************************************************************************
-- Update the lengths of the parameters to allow for longer values in CoreAutomation
--*************************************************************************************************
UPDATE P
   SET P.parameter_type			= AD.field_type
      ,P.parameter_length		= AD.field_length
	  ,P.parameter_precision	= AD.field_precision
  FROM #parameters				P
  JOIN #screen					S
    ON P.parameter_order		= S.field_order
  JOIN #automation_data			AD
    ON S.field_name				= AD.field_name

--*************************************************************************************************
-- Update CoreAutomation data with the proper defaults from the screen defintion
--*************************************************************************************************
UPDATE AD
   SET default_value	= ISNULL(S.default_value, '')
  FROM #automation_data	AD
  JOIN #screen			S
    ON AD.field_name	= S.field_name

--*************************************************************************************************
-- Update the parameters with the fields that are locked and won't have data in CoreAutomation
--*************************************************************************************************
UPDATE P
   SET locked				= ISNULL(S.locked, 0)
  FROM #parameters			p
  JOIN #screen				S
    ON P.parameter_order	= S.parameter_order

--SELECT * FROM #parameters
--SELECT * FROM #screen
--SELECT * FROM #automation_data

--*************************************************************************************************
-- Start building the stoed procedure
--*************************************************************************************************
SET @sql = + 
'IF OBJECT_ID(''dbo.' + @dc_sp_name + ''') IS NULL
    EXEC (''CREATE PROCEDURE dbo.' + @dc_sp_name + ' AS SELECT 1'')
GO
/**************************************************************************************************
Name:       ' + @dc_sp_name + '
Purpose:    Create ' + LOWER(@method) + ' data from CorderAutomation
Method:     ' + @method + '
Screen GID: ' + CONVERT(VARCHAR(200), @screen_gid) + '
Procedure:  ' + @sp_name + '

Date        User            Change
---------------------------------------------------------------------------------------------
' +
CONVERT(VARCHAR(20),GETDATE(),101) + '	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC ' + @dc_sp_name + ' ''100-Config%'', 22, ''' + @method + '''
***************************************************************************************************/
ALTER PROCEDURE dbo.' + @dc_sp_name + '
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern					VARCHAR(200)
	   ,@log_id						INT
	   ,@test_case_name				VARCHAR(200)
	   ,@method						VARCHAR(200)
	   ,@user						VARCHAR(200)

	   ,@record_id					INT
	   ,@gid						INT
	   ,@err_msg					VARCHAR(4000)
       ,@err_num					INT
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user'

SET @sql = @sql + @crlf
SET @sql = @sql + @crlf

--*************************************************************************************************
-- Create parameters for all inbound parameters for the stored procedure
--*************************************************************************************************'
DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 1 THEN 'DECLARE ' 
             ELSE '       ,'
		 END + parameter_name + SPACE(@max_parameter_len - LEN(parameter_name) +1)
		     + UPPER(parameter_type) + 
		CASE WHEN parameter_type = 'int' OR parameter_type = 'datetime' OR parameter_type = 'bigint' THEN ''
		     ELSE '(' + CONVERT(VARCHAR(20), parameter_length) + ')'
		 END AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order
  
  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

--*************************************************************************************************
-- Build a table definition to hold all of the records in CoreAutomation 
--*************************************************************************************************
SET @sql = @sql + '
--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID(''tempdb.dbo.#' + @method +''') IS NOT NULL
	DROP TABLE #' + @method + '

CREATE TABLE #' + @method + '' + @crlf
+ '      (SearchID' + SPACE(@max_parameter_len - 8) + 'VARCHAR(200)' + @crlf

DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 0 THEN '      (' 
             ELSE '      ,'
		 END + REPLACE(parameter_name,'@','') + SPACE(@max_parameter_len - LEN(parameter_name) +1)
		     + UPPER(parameter_type) + 
		CASE WHEN parameter_type = 'int' OR parameter_type = 'datetime' OR parameter_type = 'bigint' THEN ''
		     ELSE '(' + CONVERT(VARCHAR(20), parameter_length) + ')'
		 END 
		     + CASE WHEN parameter_order = 1				THEN '       DEFAULT(''' + @entity + ''')'
			        WHEN parameter_order BETWEEN 2 AND 11	THEN '       DEFAULT(''0'')'
					WHEN parameter_order = 12				THEN '       DEFAULT(''ADD'')'
					WHEN parameter_order = 13				THEN '       DEFAULT('''')'
					WHEN parameter_order = 14				THEN '       DEFAULT('''')'
					ELSE ''
				END
			 AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + '      ,record_id' + SPACE(@max_parameter_len - 9) + 'INT' + @crlf 
SET @sql = @sql + '      ,static_gid' + SPACE(@max_parameter_len - 10) + 'INT)' + @crlf + @crlf

-- Create the table to store the populate data for the screen
SET @sql = @sql + '
IF OBJECT_ID(''tempdb.dbo.#' + @method +'Screen'') IS NOT NULL
	DROP TABLE #' + @method + 'Screen

CREATE TABLE #' + @method + 'Screen' + @crlf

 SELECT @max_parameter_len = MAX(LEN(S.field_name)) + 5
   FROM #screen	S

DECLARE Screen_Details_Cursor Cursor FOR
 SELECT field_order
       ,field_name
   FROM #screen
  ORDER BY field_order

 OPEN Screen_Details_Cursor
FETCH NEXT FROM Screen_Details_Cursor
 INTO @field_order
     ,@field_name

 WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @field_name = ''
			BEGIN
				SET @field_name = 'Blank'
			END

		SELECT @field_name = REPLACE(@field_name, '*', '') + '_' + CONVERT(VARCHAR(200), @field_order)
		PRINT @field_name + ',' + CONVERT(VARCHAR(20), DATALENGTH(@field_name))

		SELECT @sql = @sql + '      ' + CASE WHEN @field_order = 1 THEN '(' ELSE ',' END + @field_name + SPACE((@max_parameter_len-DATALENGTH(@field_name))) + ' VARCHAR(200)' + @crlf

		FETCH NEXT FROM Screen_Details_Cursor
		INTO @field_order
		    ,@field_name
	END

CLOSE Screen_Details_Cursor
DEALLOCATE Screen_Details_Cursor
 
SELECT @sql = @sql + ')' + @crlf + @crlf

--*************************************************************************************************
-- Grab the data from CoreAutomation and put it in the incoming parameters table 
--*************************************************************************************************
SET @sql = @sql + 
'--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #' + @method + '' + @crlf 
+ '      (SearchID' + @crlf

DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 0 THEN '      (' 
             ELSE '      ,'
		 END + REPLACE(parameter_name,'@','') AS parameter_line
   FROM #parameters	A
  WHERE parameter_order > 14
    AND parameter_name NOT IN ('@o_status','@o_message','@ostatus','@omessage')
	AND locked = 0
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + '      ,record_id' + @crlf
SET @sql = @sql + '      ,static_gid)' + @crlf

DECLARE Field_Cursor CURSOR FOR
 SELECT CASE WHEN A.field_order = 6 THEN 'SELECT SearchID' + @crlf + '      ,'
             ELSE '      ,'
		 END
	   + 'ISNULL(' 
	   + CASE WHEN S.valid_values = 1 THEN 'dbo.fnDCAuto_GetDropdownValue(['
	          ELSE '['
		  END
		+ A.field_name + ']'
		+ CASE WHEN S.valid_values = 1 THEN ')'
		       ELSE ''
		   END
		+ ', ' 
		+ CASE WHEN A.default_value = '' AND S.valid_values = 1 THEN '''Missing''' 
		       WHEN A.default_value = 'TODAY' THEN 'CONVERT(VARCHAR(10), GETDATE(), 101)'
		       ELSE '''' + A.default_value + '''' 
		   END 
		+ ')' AS parameter_line
   FROM #automation_data	A
   LEFT JOIN #screen		S
     ON A.field_name		= S.field_name
  ORDER BY A.field_order

  OPEN Field_Cursor
 FETCH NEXT FROM Field_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		PRINT @parameter_line
		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Field_Cursor
		INTO @parameter_line
	END

CLOSE Field_Cursor
DEALLOCATE Field_Cursor

SET @sql = @sql +
'  FROM COREAUTO.CoreAutomation.dbo.' + @td_table + '
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= ''A''' + @crlf + @crlf

--*************************************************************************************************
-- Populate the proper user
--*************************************************************************************************
SET @sql = @sql +
'--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #' + @method + '
   SET iUserID  = @user' + @crlf + @crlf

--*************************************************************************************************
-- Create the loop that will create the data
--*************************************************************************************************
SET @sql = @sql + 
'--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ' + @method +'_Cursor CURSOR FOR' + @crlf
 
DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 1 THEN ' SELECT SearchID' + @crlf +  '       ,'
             ELSE '       ,'
		 END + REPLACE(parameter_name,'@','') AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + '       ,record_id' + @crlf
SET @sql = @sql + '       ,static_gid' + @crlf
SET @sql = @sql + '   FROM #' + @method + @crlf + @crlf
SET @sql = @sql +
'   OPEN ' + @method +'_Cursor
  FETCH NEXT FROM ' + @method +'_Cursor' + @crlf

DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 1 THEN '   INTO @SearchID' + @crlf +  '       ,'
             ELSE '       ,'
		 END + parameter_name AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + '       ,@record_id' + @crlf
SET @sql = @sql + '       ,@static_gid' + @crlf
SET @sql = @sql + @crlf +
'WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC ' + @sp_name + @crlf

DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 1 THEN '             ' 
             ELSE '            ,'
		 END + parameter_name 
	  + CASE WHEN parameter_name = '@o_status' OR parameter_name = '@ostatus' THEN '     = @err_num OUTPUT'
	         WHEN parameter_name  = '@o_message' OR parameter_name  = '@omessage' THEN '    = @err_msg OUTPUT' 
			 ELSE ''
		 END
		   AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + @crlf +
'        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Get the current gid
				SELECT @current_gid				= current_gid
				  FROM dbo.SomeTable
				 WHERE record_status			= ''A''

				-- Update to the static gid
				UPDATE dbo.SomeTable 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= ''A''

			END' + @crlf 

SET @sql = @sql + @crlf +
'		SELECT @status = CASE WHEN @err_num != 0 THEN ''Error'' ELSE ''Add'' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, ''Missing'', '''', '''', @status, @err_num, @err_msg' + @crlf + @crlf

SET @sql = @sql +
'        FETCH NEXT FROM ' + @method +'_Cursor' + @crlf

DECLARE Parameter_Cursor CURSOR FOR
 SELECT CASE WHEN parameter_order = 1 THEN '         INTO @SearchID' + @crlf +  '             ,'
             ELSE '             ,'
		 END + parameter_name AS parameter_line
   FROM #parameters	P
  ORDER BY parameter_order

  OPEN Parameter_Cursor
 FETCH NEXT FROM Parameter_Cursor
  INTO @parameter_line

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = @sql + @parameter_line + @crlf

		FETCH NEXT FROM Parameter_Cursor
		INTO @parameter_line
	END

CLOSE Parameter_Cursor
DEALLOCATE Parameter_Cursor

SET @sql = @sql + '             ,@record_id' + @crlf
SET @sql = @sql + '             ,@static_gid' + @crlf
SET @sql = @sql + 
'	END

CLOSE ' + @method + '_Cursor
DEALLOCATE ' + @method + '_Cursor

END
GO'
--*************************************************************************************************
-- Output the whole SQL script
--*************************************************************************************************
SELECT CAST('<![CDATA[' + @sql + ']]>' AS XML)