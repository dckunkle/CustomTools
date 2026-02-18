IF OBJECT_ID('dbo.spAPIAuto_GenerateTestCases') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIAuto_GenerateTestCases AS SELECT 1')
GO
/**************************************************************************************************
Name:       spAPIAuto_GenerateTestCases
Purpose:	Loop through the test for the Request Generator and build all of the requests

Date        User            Change
---------------------------------------------------------------------------------------------
02/13/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spAPIAuto_GenerateTestCases 'ProviderAPI'
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIAuto_GenerateTestCases
     (@test_case_pattern	VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @method_name			VARCHAR(200)
	   ,@test_case_name			VARCHAR(200)
	   ,@test_case_user_id		VARCHAR(200)
	   ,@pattern				VARCHAR(200)

--*************************************************************************************************
-- Determine which test cases need to be run
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#test_cases') IS NOT NULL
	DROP TABLE #test_cases

CREATE TABLE #test_cases
       (test_case_name		VARCHAR(200)
	   ,test_case_order		INT
	   ,test_case_pattern	VARCHAR(200))

INSERT INTO #test_cases
      (test_case_name
	  ,test_case_order
	  ,test_case_pattern)
SELECT TC.TestCaseName
      ,TC.TestCaseOrder
	  ,TC.TCID
  FROM COREAUTO.APIAutomation.gen.TestCase TC
 WHERE TC.TestCaseName		LIKE @test_case_pattern
   AND TC.Status			= 'A'

IF OBJECT_ID('tempdb.dbo.#test_case_methods') IS NOT NULL
	DROP TABLE #test_case_methods

CREATE TABLE #test_case_methods
      (method_order				INT
	  ,method_name				VARCHAR(200))

--*************************************************************************************************
-- For each test case, determine all of the steps that needs to be executed
--*************************************************************************************************
DECLARE TestCase_Cursor CURSOR FOR
 SELECT test_case_name
	   ,test_case_pattern
   FROM #test_cases
  ORDER BY test_case_order

   OPEN TestCase_Cursor
  FETCH NEXT FROM TestCase_Cursor
   INTO @test_case_name, @pattern

  WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Figure out the methods to run for the test case
		TRUNCATE TABLE #test_case_methods
		INSERT INTO #test_case_methods
			  (method_order
			  ,method_name)
		SELECT DISTINCT
			   TCM.ProcessOrder
			  ,TCM.MethodName
		  FROM COREAUTO.APIAutomation.gen.TestCaseMethod		TCM
		 WHERE TCM.Status							= 'A'
		   AND TCM.TestCaseName						= @test_case_name

		-- Start looping through all of the methods to run for each test case
		DECLARE Method_Cursor CURSOR FOR
		 SELECT method_name
		   FROM #test_case_methods
		  ORDER BY method_order

			OPEN Method_Cursor
			FETCH NEXT FROM Method_Cursor
			INTO @method_name

			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC spAPIAuto_GenerateTestCase @method_name
					FETCH NEXT FROM Method_Cursor
					 INTO @method_name

				END

			CLOSE Method_Cursor
			DEALLOCATE Method_Cursor

			FETCH NEXT FROM TestCase_Cursor
				INTO @test_case_name, @pattern
		END

CLOSE TestCase_Cursor
DEALLOCATE TestCase_Cursor

END
GO