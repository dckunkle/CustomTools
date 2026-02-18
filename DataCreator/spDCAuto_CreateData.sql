IF OBJECT_ID('dbo.spDCAuto_CreateData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateData
Purpose:    Read data from CoreAutomation and create the test data

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
01/13/2020	DK				Pass in the build number from Jenkins and use that instead of 
                            an IDENTITY field on the DClog table
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateData '100-Config%'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateData
     (@i_pattern		VARCHAR(200)
	 ,@email_address	VARCHAR(200)	= ''
	 ,@build_id			INT				= 1
	 ,@job_name			VARCHAR(200)	= '')
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern				VARCHAR(200) 
	   ,@log_id					INT

	   ,@test_case_name			VARCHAR(200)
	   ,@test_case_user_id		VARCHAR(200)
	   ,@test_case_pattern		VARCHAR(200)

	   ,@method_name			VARCHAR(200)
	   ,@stored_procedure_name	VARCHAR(200)
	   ,@sql					VARCHAR(8000)

	   ,@err_num				INT
	   ,@err_msg				VARCHAR(4000)

SELECT @pattern		= @i_pattern

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DCLog
      (user_id
	  ,pattern
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT SUSER_NAME()
      ,@pattern
	  ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Determine which test cases need to be run
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#test_cases') IS NOT NULL
	DROP TABLE #test_cases

CREATE TABLE #test_cases
       (test_case_name		VARCHAR(200)
	   ,test_case_order		INT
	   ,test_case_userid	VARCHAR(200)
	   ,test_case_pattern	VARCHAR(200))

INSERT INTO #test_cases
      (test_case_name
	  ,test_case_order
	  ,test_case_userid
	  ,test_case_pattern)
SELECT TC.TestCaseName
      ,TC.TestCaseOrder
	  ,TC.UserID
	  ,TC.TCID
  FROM COREAUTO.CoreAutomation.fw.TestCase TC
 WHERE TC.TestCaseName		LIKE @pattern
   AND TC.Status			= 'A'

IF OBJECT_ID('tempdb.dbo.#test_case_methods') IS NOT NULL
	DROP TABLE #test_case_methods

CREATE TABLE #test_case_methods
      (method_order				INT
	  ,method_name				VARCHAR(200)
	  ,stored_procedure_name	VARCHAR(200))

--*************************************************************************************************
-- For each test case, determine all of the steps that needs to be executed
--*************************************************************************************************
DECLARE TestCase_Cursor CURSOR FOR
 SELECT test_case_name
	   ,test_case_userid
	   ,test_case_pattern
   FROM #test_cases
  ORDER BY test_case_order

   OPEN TestCase_Cursor
  FETCH NEXT FROM TestCase_Cursor
   INTO @test_case_name, @test_case_user_id, @test_case_pattern

  WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Delete any existing data for the user and create/recreate the user
		EXEC spQAAuto_ResetUsersAndData @test_case_user_id, 'Y', @err_num OUTPUT, @err_msg OUTPUT

		IF @err_num <> 0
			BEGIN

				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method_name, 0, 'Reset User and Delete Data', '', '', 'Errored', @err_num, @err_msg

				END
		ELSE
			BEGIN

				-- Figure out the methods to run for the test case
				TRUNCATE TABLE #test_case_methods
				INSERT INTO #test_case_methods
					  (method_order
					  ,method_name
					  ,stored_procedure_name)
				SELECT DISTINCT
					   TCM.ProcessOrder
					  ,TCM.Method_Name
					  ,ISNULL(C.Stored_Procedure, '')
				  FROM COREAUTO.CoreAutomation.fw.TestCaseMethod	TCM
				  LEFT JOIN COREAUTO.CoreAutomation.fw.Catalog		C
					ON TCM.Method_Name	= C.Method_Name
				 WHERE TCM.Status = 'A'
				   AND TCM.TestCaseName = @test_case_name

				-- Start looping through all of the methods to run for each test case
				DECLARE Method_Cursor CURSOR FOR
				 SELECT method_name
					   ,stored_procedure_name
				   FROM #test_case_methods
				  ORDER BY method_order

				   OPEN Method_Cursor
				  FETCH NEXT FROM Method_Cursor
				   INTO @method_name, @stored_procedure_name


				  WHILE @@FETCH_STATUS = 0
					BEGIN

						IF @stored_procedure_name = '' 
							BEGIN
						
								EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method_name, 0, 'Missing Stored Procedure', '', '', 'Config', -1, 'The Stored_Procedure field in fw.Catalog is not defined for this Method_Name.'

							END
						ELSE
							BEGIN

								SET @sql = 'EXEC ' + @stored_procedure_name + ' ''' + @test_case_pattern + ''',''' + CONVERT(VARCHAR(20), @log_id) + ''', ''' + @test_case_name + ''', ''' + @method_name + ''', ''' + @test_case_user_id + ''''
								PRINT @sql
								EXEC (@sql)
					
							END

						FETCH NEXT FROM Method_Cursor
						 INTO @method_name, @stored_procedure_name

					END

					CLOSE Method_Cursor
					DEALLOCATE Method_Cursor

					FETCH NEXT FROM TestCase_Cursor
					 INTO @test_case_name, @test_case_user_id, @test_case_pattern

			END
	END

CLOSE TestCase_Cursor
DEALLOCATE TestCase_Cursor

--*************************************************************************************************
-- Update the end time
--*************************************************************************************************
UPDATE DCLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

IF @email_address <> '' 
	BEGIN

		EXEC spDCAuto_EmailResultsVerbose @log_id, @email_address
	
	END
END
GO