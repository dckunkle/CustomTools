IF OBJECT_ID('dbo.spDCAuto_CreateSynonyms') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateSynonyms AS SELECT 1')
GO
/**************************************************************************************************
Name:       spQASetup_CreateSynonyms
Purpose:    Create SQL synonyms to point to objects in the proper CORE database from the ENG database

Date        User            Change
---------------------------------------------------------------------------------------------
08/20/2018	DK				Original procedure
05/06/2020	DK				Added schema
03/18/2022	DK				Limited synonyms to the dbo schema

***************************************************************************************************
EXEC spDCAuto_CreateSynonyms 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateSynonyms
AS
BEGIN

SET NOCOUNT ON

DECLARE @object			VARCHAR(128)	= ''
	   ,@database		VARCHAR(128)	= ''
	   ,@schema_name	VARCHAR(128)	= ''
	   ,@insert_sql		VARCHAR(8000)	= ''
	   ,@create_sql		VARCHAR(8000)	= ''
	   ,@drop_sql		VARCHAR(8000)	= ''

SET @database = dbo.fnDCAuto_GetDatabaseName()

--*************************************************************************************************
-- Create a list of all the objects being used by the setup script that are in the Core database
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#objects') IS NOT NULL
	BEGIN DROP TABLE #objects END

CREATE TaBLE #objects
      (object_name		VARCHAR(128)
	  ,schema_name		VARCHAR(128))

SET @insert_sql = 'INSERT INTO #objects
                         (object_name
						 ,schema_name)
                   SELECT ''['' + O.name + '']''  
				         ,S.name
					 FROM ' + @database + '.sys.objects O
					 JOIN ' + @database + '.sys.schemas S
					   ON O.schema_id = S.schema_id
					WHERE O.type IN (''P'',''U'',''FN'',''FS'',''TF'',''FT'',''IF'',''V'')
					  AND S.name IN (''dbo'')'
			  
EXEC (@insert_sql)
 
--*************************************************************************************************
-- Loop through the objects creating the synonyms
--*************************************************************************************************
DECLARE create_synonyms CURSOR FOR
SELECT object_name
      ,schema_name
  FROM #objects				O

OPEN create_synonyms FETCH NEXT FROM create_synonyms INTO @object, @schema_name

WHILE @@FETCH_STATUS = 0
    BEGIN

		SET @drop_sql = 'IF OBJECT_ID(''' + @schema_name + '.' + @object +''', ''SN'') IS NOT NULL BEGIN DROP SYNONYM ' + @schema_name + '.' + @object + ' END'
		EXEC (@drop_sql)

		SET @create_sql = 'CREATE SYNONYM ' + @schema_name + '.' + @object + ' FOR ' + @database + '.' + @schema_name + '.' + @object
		EXEC (@create_sql)

		FETCH NEXT FROM create_synonyms INTO @object, @schema_name
	END

CLOSE create_synonyms
DEALLOCATE create_synonyms

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEAN_UP:
IF OBJECT_ID('tempdb.dbo.#objects') IS NOT NULL
	BEGIN DROP TABLE #objects END

SET NOCOUNT OFF

END
GO