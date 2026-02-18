IF OBJECT_ID('dbo.spFCAuto_CreateFiles') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_CreateFiles AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_CreateFiles
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
12/23/2020	DK				Add ability to create 837 files with the correct header/trailer
10/04/2021	DK				Add 820 file
06/27/2022	DK				Add support for Fixed Width files
07/07/2022	DK				Add support for Import (Import Spreadsheets)
12/06/2022  DK              Add support for 834 files
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CreateFiles 'aldqrdb02', 'ExportMember%', 'dkunkle@evolenthealth.com',22, 'FileCreator'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_CreateFiles
     (@server				VARCHAR(200)
	 ,@test_case_pattern	VARCHAR(400)
	 ,@email_address		VARCHAR(200)
	 ,@build_id				INT
	 ,@job_name				VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @log_id					INT

	   ,@test_case_name			VARCHAR(200)
	   ,@test_case_user_id		VARCHAR(200)
	   ,@pattern				VARCHAR(200)

	   ,@method_name			VARCHAR(200)
	   ,@filename				VARCHAR(200)
	   ,@file_type				VARCHAR(100)
	   ,@sql					VARCHAR(8000)

	   ,@err_num				INT
	   ,@err_msg				VARCHAR(4000)

	   ,@log_id_char			CHAR(6)
	   ,@server_name_char		CHAR(20)
	   ,@test_case_name_char	CHAR(40)
	   ,@email_address_char		CHAR(40)

	   ,@cmd					VARCHAR(4000)
	   ,@stored_procedure		VARCHAR(200)

SELECT @server				= RTRIM(@server)
      ,@test_case_pattern	= RTRIM(@test_case_pattern)
	  ,@job_name			= RTRIM(@job_name)

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO CoreFileCreator.fw.FCLog
      (destination_server
	  ,test_case_pattern
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT @server
      ,@test_case_pattern
      ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Write to the Jenkins log
--*************************************************************************************************
SELECT @log_id_char			= LEFT(CONVERT(VARCHAR(6), @log_id) + SPACE(6), 6)
	  ,@server_name_char	= LEFT(LOWER(RIGHT(@server, 20)) + SPACE(20), 20)
	  ,@test_case_name_char	= LEFT(LEFT(@test_case_pattern, 40) + SPACE(40), 40)
	  ,@email_address_char	= LEFT(LEFT(@email_address, 30) + SPACE(30), 30)

PRINT ''
PRINT ''
PRINT ''
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' FILE CREATOR'
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' '
PRINT '       -Log ID---Date Time-------------Server Name----------Test Case--------------------------------Email Address------------------------------'
PRINT '        ' + ISNULL(@log_id_char, '') + '   ' + CONVERT(VARCHAR(100), GETDATE(), 20) + '   ' + ISNULL(@server_name_char, '') + ' ' + ISNULL(@test_case_name_char, '') + ' ' + ISNULL(@email_address_char, '')
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
  FROM CoreFileCreator.fw.TestCase TC
 WHERE TC.TestCaseName		LIKE @test_case_pattern
   AND TC.Status			= 'A'

IF OBJECT_ID('tempdb.dbo.#test_case_methods') IS NOT NULL
	DROP TABLE #test_case_methods

CREATE TABLE #test_case_methods
      (method_order				INT
	  ,method_name				VARCHAR(200)
	  ,filename					VARCHAR(200)
	  ,file_type				VARCHAR(100))

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
   INTO @test_case_name, @test_case_user_id, @pattern

PRINT ''
PRINT '       -Method Name----------------------------------------Filename----------------------------Exp--Act--Folder---------------------------------'

  WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Figure out the methods to run for the test case
		TRUNCATE TABLE #test_case_methods
		INSERT INTO #test_case_methods
			  (method_order
			  ,method_name
			  ,filename
			  ,file_type)
		SELECT DISTINCT
			   TCM.ProcessOrder
			  ,TCM.Method_Name
			  ,ISNULL(C.filename, '')
			  ,C.file_type
		  FROM CoreFileCreator.fw.TestCaseMethod		TCM
		  LEFT JOIN CoreFileCreator.fw.Catalog		C
		    ON TCM.Method_Name						= C.Method_Name
		 WHERE TCM.Status							= 'A'
		   AND TCM.TestCaseName						= @test_case_name

		-- Start looping through all of the methods to run for each test case
		DECLARE Method_Cursor CURSOR FOR
		 SELECT method_name
			   ,filename
			   ,file_type
		   FROM #test_case_methods
		  ORDER BY method_order

			OPEN Method_Cursor
			FETCH NEXT FROM Method_Cursor
			INTO @method_name, @filename, @file_type

			WHILE @@FETCH_STATUS = 0
				BEGIN

					SELECT @stored_procedure = CASE WHEN @method_name = '837ParseLoad'	THEN 'spFCAuto_CreateFile837'
													WHEN @method_name = 'X12.820Import'	THEN 'spFCAuto_CreateFile820'
													WHEN @method_name = 'Lockbox'		THEN 'spFCAuto_CreateLockboxFile'
													WHEN @file_type   = 'fixed'			THEN 'spFCAuto_CreateFileFixed'
													WHEN @method_name = '834File'		THEN 'spFCAuto_CreateFile834'
													ELSE 'spFCAuto_CreateFile'
												END

					SELECT @cmd = 'EXEC ' + @stored_procedure + ' ''' + @pattern + ''',''' + @test_case_name + ''',''' + @method_name + ''',''' + @server + ''',' + CONVERT(VARCHAR(200), @log_id)
					EXEC(@cmd)

					WAITFOR DELAY '00:00:01.100';

					FETCH NEXT FROM Method_Cursor
						INTO @method_name, @filename, @file_type

				END

			CLOSE Method_Cursor
			DEALLOCATE Method_Cursor

			FETCH NEXT FROM TestCase_Cursor
				INTO @test_case_name, @test_case_user_id, @pattern
		END

CLOSE TestCase_Cursor
DEALLOCATE TestCase_Cursor

--*************************************************************************************************
-- Update the end time
--*************************************************************************************************
PRINT ''
PRINT '       -----------------------------------------------------------------------------------------------------------------------------------------'
PRINT ''

UPDATE CoreFileCreator.fw.FCLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

IF @email_address <> '' 
	BEGIN
		
		PRINT ''
		EXEC spFCAuto_EmailResults @log_id, @email_address
	
	END
END
GO