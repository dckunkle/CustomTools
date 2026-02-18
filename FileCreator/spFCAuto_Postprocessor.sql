IF OBJECT_ID('dbo.spFCAuto_Postprocessor') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_Postprocessor AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_Postprocessor
Purpose:    Run any steps necessary after the files have been created by the File Creator

Date        User            Change
---------------------------------------------------------------------------------------------
09/08/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_Postprocessor 'PortalExtractCore', 'aldqadbqr06'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_Postprocessor
     (@test_case_pattern	VARCHAR(400)
	 ,@server				VARCHAR(200)	= 'wqadbhpauto01'
	 ,@build_id				INT				= 9999
	 ,@job_name				VARCHAR(200)	= 'Internal Preprocessor')
AS
BEGIN

SET NOCOUNT ON

SELECT @test_case_pattern = RTRIM(LTRIM(@test_case_pattern))

--*************************************************************************************************
-- Create a table to determine which test cases will be run
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TestCaseTables') IS NOT NULL
	DROP TABLE #TestCaseTables

CREATE TABLE #TestCaseTables
      (TestCaseName		VARCHAR(200)
	  ,TestCaseMethod	VARCHAR(200)
	  ,TableName		VARCHAR(200)
	  ,TCID				VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#TestCases') IS NOT NULL
	DROP TABLE #TestCases

CREATE TABLE #TestCases
      (claim_number		VARCHAR(200)
	  ,line_number		INT				DEFAULT(0)
	  ,date_submitted	DATETIME
	  ,claim_sid		INT				DEFAULT(0)
	  ,record_id		INT				DEFAULT(0))

--***************************************************************************************************
-- Create temporary tables to be used
--***************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

CREATE TABLE #cmd_results
		(results	VARCHAR(8000)
		,result_id	INT				IDENTITY(1,1))

--*************************************************************************************************
-- Create a table to determine which test cases will be run
--*************************************************************************************************
INSERT INTO #TestCaseTables
      (TestCaseName
	  ,TestCaseMethod
	  ,TableName
	  ,TCID)
SELECT TCM.TestCaseName
      ,TCM.Method_Name
	  ,C.table_name
      ,TCID
  FROM COREAUTO.CoreFileCreator.fw.TestCase			TC
  JOIN COREAUTO.CoreFileCreator.fw.TestCaseMethod	TCM
    ON TC.TestCaseName								= TCM.TestCaseName
  JOIN COREAUTO.CoreFileCreator.fw.Catalog			C
    ON TCM.Method_Name								= C.Method_Name
 WHERE TC.TestCaseName								LIKE @test_case_pattern

--*************************************************************************************************
-- If the test case includes any portal extract tables then call the batch file to zip and move the file
--*************************************************************************************************
IF EXISTS(SELECT TOP 1 * FROM #TestCaseTables WHERE TableName LIKE 'TD_PortalExtract%')
	BEGIN

		DECLARE @executable		VARCHAR(200)	= 'H:\BATCH\SubSystems\AboveHealth\RarAndSend.bat'
		       ,@load_type		VARCHAR(200)	= 'INCR' -- or FULL
			   ,@root_drive		VARCHAR(200)	= 'H'
			   ,@root_source	VARCHAR(200)	= '\BATCH\SubSystems\AboveHealth'
			   ,@root_file_name	VARCHAR(200)	= 'QR06_QAFULL_'
			   ,@root_target	VARCHAR(200)	= '\\ptlqautil.chicago.local\INPUT\QR06_QA'
			   ,@cmd			VARCHAR(4000)

		SELECT @cmd = @executable + ' ' + @load_type + ' ' + @root_drive + ' ' + @root_source + ' ' + @root_file_name + ' ' + @root_target
		
		INSERT INTO #cmd_results
	      EXEC master.sys.xp_cmdshell @cmd

	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TestCaseTables') IS NOT NULL
	DROP TABLE #TestCaseTables

IF OBJECT_ID('tempdb.dbo.#TestCases') IS NOT NULL
	DROP TABLE #TestCases

IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

END
GO