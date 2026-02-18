IF OBJECT_ID('dbo.spDCAuto_LoadData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_LoadData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_LoadData
Purpose:    POC to see if data from Core can easily be loaded into CoreAutomation tables

Date        User            Change
---------------------------------------------------------------------------------------------
11/08/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_LoadData 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_LoadData
     (@screen_gid			INT				
	 ,@entity_name			VARCHAR(200)
	 ,@td_table_name		VARCHAR(200)		
	 ,@core_table_name		VARCHAR(200)	
	 ,@key_field_1			VARCHAR(200)	
	 ,@key_field_2			VARCHAR(200)
	 ,@key_field_3			VARCHAR(200)
	 ,@suppress_defaults	BIT)	
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE	@l_screen_gid			INT				
		   ,@l_td_table_name		VARCHAR(200)	
		   ,@l_entity_name			VARCHAR(200)	
		   ,@l_core_table_name		VARCHAR(200)	
		   ,@l_key_field_1			VARCHAR(200)	
		   ,@l_key_field_2			VARCHAR(200)
		   ,@l_key_field_3			VARCHAR(200)	

--*************************************************************************************************
		  ,@sql						VARCHAR(4000)
		  ,@crlf					VARCHAR(20)		= CHAR(13) + CHAR(10)
		  ,@stored_procedure_name	VARCHAR(200)
		  ,@error_message			VARCHAR(4000)
		  ,@num_screen_fields		INT
		  ,@max_screen_fields		INT
		  ,@field_counter			INT
		  ,@key_1					VARCHAR(200)
		  ,@key_2					VARCHAR(200)
		  ,@key_3					VARCHAR(200)
		  ,@field_name				VARCHAR(200)

	SELECT @l_screen_gid			= @screen_gid
	      ,@l_entity_name			= @entity_name
		  ,@l_td_table_name			= @td_table_name
		  ,@l_core_table_name		= @core_table_name
		  ,@l_key_field_1			= @key_field_1
		  ,@l_key_field_2			= @key_field_2
		  ,@l_key_field_3			= @key_field_3

--*************************************************************************************************
-- Check to make sure the screen can be used to extract data
--*************************************************************************************************
SET @error_message = ''

IF NOT EXISTS(SELECT TOP 1 * FROM Entity_Screen_Action WHERE screen_gid = @screen_gid AND action = 'ADD') OR
   NOT EXISTS(SELECT TOP 1 * FROM Entity_Screen_Action WHERE screen_gid = @screen_gid AND action = 'MODIFY')

	BEGIN
		SET @error_message = 'This utility will only work for data that uses the same screen for adding and modifying data in Aldera.'
	END

SELECT @num_screen_fields	= COUNT(*)
  FROM ScreenDetails
 WHERE ScreenGid = @l_screen_gid

SELECT @max_screen_fields = MAX(FieldOrder) 
  FROM ScreenDetails 
 WHERE ScreenGid = @l_screen_gid

IF @num_screen_fields <> @max_screen_fields 
	BEGIN
		SET @error_message = 'This utility will only work for data that uses the same screen for adding and modifying data in Aldera.'
	END

IF @error_message <> '' RETURN

--*************************************************************************************************
-- Create the table that will be used to store the TD Table data
--*************************************************************************************************
IF Object_ID('tempdb.dbo.#ScreenDetails') IS NOT NULL
	DROP TABLE #ScreenDetails

CREATE TABLE #ScreenDetails
      (FieldOrder		INT
	  ,Label			VARCHAR(200)
	  ,ComboType		VARCHAR(20)
	  ,DefaultValue		VARCHAR(200)
	  ,isRequired		INT
	  ,isLocked			INT)

INSERT INTO #ScreenDetails
      (FieldOrder
	  ,Label
	  ,ComboType
	  ,DefaultValue
	  ,isRequired
	  ,isLocked)
SELECT FieldOrder
      ,Label
	  ,ComboType
	  ,DefaultValue
	  ,isRequired
	  ,isLocked
  FROM ScreenDetails
 WHERE ScreenGid		= @l_screen_gid

--*************************************************************************************************
-- Create the table that will be used to store the TD Table data
--*************************************************************************************************
SET @sql = 'IF OBJECT_ID(''QA.dbo.' + @l_td_table_name + ''') IS NOT NULL DROP TABLE QA.dbo.' + @l_td_table_name
EXEC(@sql)

SET @sql = 
'SELECT 0 AS [Selected]
       ,T.*
  INTO QA.dbo.' +  @l_td_table_name + '
  FROM COREAUTO.CoreAutomation.dbo.' + @l_td_table_name + ' T
 WHERE 0=1'
EXEC(@sql)

--SET @sql = 'ALTER TABLE QA.dbo.' + @l_td_table_name + ' ADD [Selected] BIT DEFAULT(0)'
--EXEC(@sql)

--*************************************************************************************************
-- Create the table that will hold the data from Core
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##Core_Data') IS NOT NULL
	DROP TABLE ##Core_Data

SET @field_counter = 1
SET @sql = 'CREATE TABLE ##Core_Data' + @crlf

WHILE @field_counter <= @max_screen_fields
	BEGIN

		SET @sql = @sql + CASE WHEN @field_counter = 1 THEN '(' ELSE ',' END + 'Field' + CONVERT(VARCHAR(10), @field_counter) + CASE WHEN @field_counter < 10 THEN '      '
																																	 WHEN @field_counter <100 THEN '     '
																																	 ELSE '    '
																																 END + 'VARCHAR(4000)' + @crlf
		SET @field_counter = @field_counter + 1
	END

SET @sql = @sql + ',date_time_created	VARCHAR(200)' +
                + ',user_id_created		VARCHAR(200)' +
				+ ',date_time_modified	VARCHAR(200)' +
				+ ',user_id				VARCHAR(200)' +
				+ ',form_id				VARCHAR(200)' +
				+ ',ID					INT				IDENTITY(1,1))' 

EXEC (@sql)

--*************************************************************************************************
-- Create a table with all of the data to be imported
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Key_Data') IS NOT NULL
	DROP TABLE #Key_Data

CREATE TABLE #Key_Data
      (key_field_1		VARCHAR(200)
	  ,key_field_2		VARCHAR(200)
	  ,key_field_3		VARCHAR(200))

SET @sql = 'INSERT INTO #Key_Data'		+ @crlf +
           '      (key_field_1'			+ @crlf +
		   '      ,key_field_2'			+ @crlf +
		   '      ,key_field_3)'		+ @crlf +
           'SELECT ' + @l_key_field_1	+ @crlf +
		   '      ,' + CASE WHEN @l_key_field_2 = '' 
		                    THEN '''''' 
							ELSE @l_key_field_2 
						END	+ @crlf +
		   '      ,' + CASE WHEN @l_key_field_3 = '' 
		                    THEN '''''' 
							ELSE @l_key_field_3 
						END	+ @crlf +
		   '  FROM ' + @core_table_name + @crlf +
		   ' WHERE record_status = ''A'''
EXEC(@sql)   

--*************************************************************************************************
-- Start populating the Core data 
--*************************************************************************************************
SELECT @stored_procedure_name	= populate_stored_proc
  FROM Entity_Screen_Action
 WHERE screen_gid				= @l_screen_gid
   AND action					= 'MODIFY'

DECLARE CoreData_Cursor CURSOR FOR
 SELECT key_field_1
       ,key_field_2
	   ,key_field_3
   FROM #Key_Data

OPEN CoreData_Cursor
  FETCH NEXT FROM CoreData_Cursor
   INTO @key_1
       ,@key_2
	   ,@key_3

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @sql = 'INSERT INTO ##Core_Data EXEC ' + @stored_procedure_name + '''' + @l_entity_name + ''',''' + @key_1 + ''',''' + @key_2 +''',''' + @key_3 + ''',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''MODIFY'',''0'','''''
		EXEC(@sql)

		 FETCH NEXT FROM CoreData_Cursor
		  INTO @key_1
			  ,@key_2
			  ,@key_3

	END


CLOSE CoreData_Cursor
DEALLOCATE CoreData_Cursor

--*************************************************************************************************
-- Update the Core data with the description/value for dropdown values
--*************************************************************************************************
DECLARE @field_order		INT
       ,@label				VARCHAR(200)
	   ,@combo				VARCHAR(200)
	   ,@default			VARCHAR(200)
	   ,@is_required		INT
	   ,@is_locked			INT

SET @sql = 'INSERT INTO QA.dbo.' + @l_TD_table_name + @crlf +
           '      (Selected'            + @crlf +
		   '      ,ID_Field'			+ @crlf +
	       --'      ,EnvironmentID'		+ @crlf +
	       '      ,TCID'				+ @crlf +
	       '      ,RecordID'			+ @crlf +
	       '      ,TCType)'				+ @crlf +
           'SELECT 0'                   + @crlf +
		   '      ,ID'					+ @crlf +
           --'      ,ID'					+ @crlf +
           '      ,ID'					+ @crlf +
	       '      ,ID'					+ @crlf +
	       '      ,''Add'''				+ @crlf +
           '  FROM ##Core_Data'

EXEC(@sql)

SET @field_counter = 6

DECLARE Screen_Cursor CURSOR FOR
 SELECT FieldOrder
       ,Label
	   ,ISNULL(ComboType, '')
	   ,ISNULL(DefaultValue, '')
	   ,isRequired	
	   ,isLocked
   FROM #ScreenDetails

OPEN Screen_Cursor
  FETCH NEXT FROM Screen_Cursor
   INTO @field_order
       ,@label
	   ,@combo
	   ,@default
	   ,@is_required
	   ,@is_locked

WHILE @@FETCH_STATUS = 0
	BEGIN

		IF ISNULL(@label, '') <> '' AND @is_Locked <> 1
			BEGIN

				SELECT @field_name			= C.name
				  FROM QA.sys.columns		C
				  JOIN QA.sys.tables		T
					ON C.object_id			= T.object_id
				 WHERE T.name				= @l_td_table_name
				   AND C.column_id			= @field_counter

				SET @sql = 'UPDATE TD ' +
				           '   SET [' + @field_name + '] = CASE WHEN [Field' + CONVERT(VARCHAR(10), @field_order) + '] = ''' + @default + ''' AND ' + CONVERT(VARCHAR(1), @suppress_defaults) + ' = 1 THEN NULL ELSE ' +
						                                       CASE WHEN ISNULL(@combo, '') = '' THEN '[Field' + CONVERT(VARCHAR(10), @field_order) + ']'
						                                            ELSE 'SAV.Description + ''('' + SAV.Short_Desc + '')''' 
																END + ' END' +
						   '  FROM QA.dbo.' + @l_td_table_name + '	TD' +
						   '  JOIN ##Core_Data	CD' +
						   '    ON TD.RecordID	= CD.ID' +
						   '  LEFT JOIN System_Action_Values SAV' +
						   '    ON SAV.Short_Desc = [Field' + CONVERT(VARCHAR(10), @field_order) + ']' +
						   '   AND SAV.Reference_Type = ''' + @combo + '''' +
						   '   AND SAV.record_status = ''A'''
				EXEC(@sql)

				SET @field_counter = @field_counter + 1
			END

		FETCH NEXT FROM Screen_Cursor
	     INTO @field_order
		     ,@label
		     ,@combo
		     ,@default
		     ,@is_required
		     ,@is_locked

	END

CLOSE Screen_Cursor
DEALLOCATE Screen_Cursor

END
GO