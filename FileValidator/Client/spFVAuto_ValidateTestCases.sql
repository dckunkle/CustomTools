IF OBJECT_ID('dbo.spFVAuto_ValidateTestCases') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_ValidateTestCases AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_ValidateTestCases
Purpose:    Read data from CoreFileCreator and validate the appropriate test cases

Date        User            Change
---------------------------------------------------------------------------------------------
05/10/2020	DK				Original procedure
06/22/2020	DK				Add Jenkins logging
08/06/2021	DK				Add Validate flag to determine which test cases to validate
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_ValidateTestCases 'Dev-Lockbox', 'dkunkle@evolenthealth.com','32','FileValidator'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_ValidateTestCases
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
	   ,@table_name				VARCHAR(200)
	   ,@sql					VARCHAR(8000)

	   ,@err_num				INT
	   ,@err_msg				VARCHAR(4000)

	   ,@log_id_char			CHAR(6)
	   ,@server_name_char		CHAR(20)
	   ,@test_case_name_char	CHAR(30)
	   ,@email_address_char		CHAR(40)

SELECT @pattern				= @i_pattern

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO FVLog
      (destination_server
	  ,test_case_pattern
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT @@SERVERNAME
      ,@pattern
	  ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Write to the Jenkins log
--*************************************************************************************************
SELECT @log_id_char			= LEFT(CONVERT(VARCHAR(6), @log_id) + SPACE(6), 6)
	  ,@server_name_char	= LEFT(LOWER(RIGHT(@@SERVERNAME, 20)) + SPACE(20), 20)
	  ,@test_case_name_char	= LEFT(RIGHT(@pattern, 30) + SPACE(30), 30)
	  ,@email_address_char	= LEFT(RIGHT(@email_address, 40) + SPACE(40), 40)

PRINT ' '
PRINT ' '
PRINT '-Log ID---Date Time-------------Server Name----------Test Case----------------------Email Address-----------------------------------------------------------'
PRINT ' ' + ISNULL(@log_id_char, '') + '   ' + CONVERT(VARCHAR(100), GETDATE()) + '   ' + ISNULL(@server_name_char, '') + ' ' + ISNULL(@test_case_name_char, '') + ' ' + ISNULL(@email_address_char, '')
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' '
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
	  ,test_case_pattern)
SELECT TC.TestCaseName
      ,TC.TestCaseOrder
	  ,TC.TCID
  FROM COREAUTO.CoreFileCreator.fw.TestCase TC
 WHERE TC.TestCaseName		LIKE @pattern
   AND TC.Status			= 'A'

IF OBJECT_ID('tempdb.dbo.#test_case_methods') IS NOT NULL
	DROP TABLE #test_case_methods

CREATE TABLE #test_case_methods
      (method_order		INT
	  ,method_name		VARCHAR(200)
	  ,table_name		VARCHAR(200))

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

		-- Figure out the methods to run for the test case
		TRUNCATE TABLE #test_case_methods
		  INSERT INTO #test_case_methods
				(method_order
				,method_name
				,table_name)
		  SELECT DISTINCT
				 TCM.ProcessOrder
				,TCM.Method_Name
				,ISNULL(C.table_name, '')
			FROM COREAUTO.CoreFileCreator.fw.TestCaseMethod	TCM
			LEFT JOIN COREAUTO.CoreFileCreator.fw.Catalog	C
			  ON TCM.Method_Name	= C.Method_Name
		   WHERE TCM.Status			= 'A'
			 AND TCM.TestCaseName	= @test_case_name
			 AND TCM.Validate		= 'Yes'

		-- IF there are any Lockbox records, then validate Lockbox Detail records as well
		IF EXISTS(SELECT TOP 1 method_name FROM #test_case_methods WHERE method_name = 'Lockbox')
			BEGIN

				INSERT INTO #test_case_methods
				      (method_order
					  ,method_name
					  ,table_name)
				SELECT TOP 1 
				       99
				      ,'LockboxDetail'
					  ,'TD_LockboxDetail'
				  FROM COREAUTO.CoreFileCreator.dbo.TD_LockboxDetail
				 WHERE TCID				LIKE @test_case_pattern
				   AND ActiveTestCase	= 'A'

			END

		-- Start looping through all of the methods to run for each test case
		DECLARE Method_Cursor CURSOR FOR
		 SELECT method_name
			   ,table_name
		   FROM #test_case_methods
		  ORDER BY method_order

		   OPEN Method_Cursor
		  FETCH NEXT FROM Method_Cursor
		   INTO @method_name, @table_name


				  WHILE @@FETCH_STATUS = 0
					BEGIN

						IF @table_name = '' 
							BEGIN
						
								EXEC spFVAuto_LogEvent @log_id, @test_case_name, @method_name, 0, 'Config', 0, 0, 'Missing Table Name', 'The table_name field in fw.Catalog is not defined for this Method_Name.','','',''

							END
						ELSE
							BEGIN

								EXEC spFVAuto_ValidateTestCase @test_case_name ,@method_name ,@table_name ,@test_case_pattern ,@log_id
					
							END

						FETCH NEXT FROM Method_Cursor
						 INTO @method_name, @table_name

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
UPDATE FVLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

IF @email_address <> '' 
	BEGIN
		
		SET @log_id = @log_id
		EXEC spFVAuto_EmailResults @log_id, @email_address
	
	END

--*************************************************************************************************
-- Update the end time
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#test_cases') IS NOT NULL
	DROP TABLE #test_cases

IF OBJECT_ID('tempdb.dbo.#test_case_methods') IS NOT NULL
	DROP TABLE #test_case_methods

GO