IF OBJECT_ID('dbo.spFVAuto_ValidateTestCase') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_ValidateTestCase AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_ValidateTestCase
Purpose:    Given a table name and the test case pattern, validate each record in the table

Date        User            Change
---------------------------------------------------------------------------------------------
05/10/2020	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_ValidateTestCase 'ProviderConversionAdd','ProviderConversionServiceLocation','TD_ProviderConversionServiceLocation','PC-ADD%',20
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_ValidateTestCase
     (@test_case_name		VARCHAR(2000)
	 ,@test_method			VARCHAR(2000)
	 ,@table_name			VARCHAR(200)
	 ,@test_case_pattern	VARCHAR(200)
	 ,@log_id				INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql			VARCHAR(8000)
       ,@record_id		INT
	   ,@err_num		INT
	   ,@err_msg		VARCHAR(4000)

--*************************************************************************************************
-- Determine which test cases need to be run
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#test_cases_to_validate') IS NOT NULL
	DROP TABLE #test_cases_to_validate

CREATE TABLE #test_cases_to_validate
      (record_id	INT
	  ,TCID			VARCHAR(2000))

SET @sql = 'INSERT INTO #test_cases_to_validate
                  (record_id
				  ,TCID)
		    SELECT RecordID
			      ,TCID
              FROM COREAUTO.CoreFileCreator.dbo.' + @table_name + '
			 WHERE TCID LIKE ''' + @test_case_pattern + '''
			   AND ActiveTestCase = ''A'''

EXEC (@sql)

--*************************************************************************************************
-- For each test case, determine all of the steps that needs to be executed
--*************************************************************************************************
DECLARE ValidateTestCase_Cursor CURSOR FOR
 SELECT record_id
   FROM #test_cases_to_validate
  ORDER BY TCID

   OPEN ValidateTestCase_Cursor
  FETCH NEXT FROM ValidateTestCase_Cursor
   INTO @record_id

  WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC spFVAuto_ValidateRecord @test_case_name,@test_method,@table_name,@record_id, @log_id 
		
		FETCH NEXT FROM ValidateTestCase_Cursor
		 INTO @record_id

	END

CLOSE ValidateTestCase_Cursor
DEALLOCATE ValidateTestCase_Cursor

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#test_cases_to_validate') IS NOT NULL
	DROP TABLE #test_cases_to_validate

END
GO