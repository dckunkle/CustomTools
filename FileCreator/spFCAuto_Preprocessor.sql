IF OBJECT_ID('dbo.spFCAuto_Preprocessor') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_Preprocessor AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_Preprocessor
Purpose:    Run prior to creating the file to do any data manipulation before the file is created.
		    Example, update the Claims SID for PaymentIntegrity files

Date        User            Change
---------------------------------------------------------------------------------------------
07/20/2020	DK				Original procedure
08/26/2020	DK				Added Refund and Recoup to the preprocessor logic
09/08/2021	DK				Change the default for the @server variable
04/14/2023	DK				Add preprocessor steps for Risk Score
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_Preprocessor 'EB-RiskScores-Add'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_Preprocessor
     (@test_case_pattern	VARCHAR(400)
	 ,@server				VARCHAR(200)	= 'wqadbhpauto01'
	 ,@build_id				INT				= 9999
	 ,@job_name				VARCHAR(200)	= 'Internal Preprocessor')
AS
BEGIN

SET NOCOUNT ON

DECLARE @table_name				VARCHAR(200)
       ,@TCID					VARCHAR(200)
	   ,@method_name			VARCHAR(200)
	   ,@sql					NVARCHAR(4000)

	   ,@log_id					INT
	   ,@method_id				INT
	   ,@status					VARCHAR(100)

	   ,@claim_number_field		VARCHAR(200)
	   ,@line_number_field		VARCHAR(200)
	   ,@claim_sid_field		VARCHAR(200)

	   ,@nothing_to_preprocess	BIT	= 1
	   ,@claim_number			VARCHAR(200)
	   ,@line_number			INT
	   ,@record_id				INT
	   ,@claim_sid				INT
	   ,@date_submitted			DATETIME

	   ,@member_id				VARCHAR(50)
	   ,@member_gid				INT
	   ,@member_gid_char		VARCHAR(20)

	   ,@claim_sid_char			VARCHAR(400)
	   ,@date_submitted_char	VARCHAR(400)

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO dbo.PPLog
      (destination_server
	  ,test_case_pattern
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT @server
      ,@test_case_pattern
      ,GETDATE()
	  ,''
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- Ouptut to the log
--*************************************************************************************************
PRINT ''
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' PREPROCESSOR'
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ''

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

IF OBJECT_ID('tempdb.dbo.#member_gids') IS NOT NULL
	DROP TABLE #member_gids

CREATE TABLE #member_gids
      (member_id		VARCHAR(200)
	  ,member_gid		INT				DEFAULT(0)
	  ,record_id		INT)

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
-- PREPROCESSOR: Payment Integrity
--*************************************************************************************************
IF EXISTS(SELECT TOP 1 * FROM #TestCaseTables WHERE TableName LIKE 'TD_PaymentIntegrity%')
	BEGIN

		DECLARE TestCaseTable_Cursor CURSOR FOR
		 SELECT TableName
			   ,TCID
			   ,TestCaseMethod
		   FROM #TestCaseTables

		   OPEN TestCaseTable_Cursor
		  FETCH NEXT FROM TestCaseTable_Cursor
		   INTO @table_name, @TCID, @method_name

		  WHILE @@FETCH_STATUS = 0
			BEGIN

				IF @table_name = 'TD_PaymentIntegrityPostPayIdentification' 
				OR @table_name = 'TD_PaymentIntegrityPostPayClosed'
				OR @table_name = 'TD_PaymentIntegrityPostPayRecoup'
				OR @table_name = 'TD_PaymentIntegrityPostPayRefund'

					BEGIN
						SELECT @claim_number_field	= 'Claim_Number'
							  ,@line_number_field	= 'Claim_Line_Number'
							  ,@claim_sid_field		= 'Claim_SID'
					END

				SET @sql = 'INSERT INTO #TestCases
				                  (claim_number
								  ,line_number
								  ,record_id)
							SELECT ' + @claim_number_field + '
							      ,' + @line_number_field + '
								  ,RecordID
				              FROM COREAUTO.CoreFileCreator.dbo.' + @table_name + '
							 WHERE TCID LIKE ''' + @TCID + '''
							   AND ActiveTestCase = ''A'''
				EXEC(@sql)

				-- If there are any test cases for the Identification file then update the Claims SID
				IF EXISTS(SELECT TOP 1 * FROM #TestCases) AND
				         (@table_name = 'TD_PaymentIntegrityPostPayIdentification' 
				       OR @table_name = 'TD_PaymentIntegrityPostPayClosed'
					   OR @table_name = 'TD_PaymentIntegrityPostPayRecoup'
					   OR @table_name = 'TD_PaymentIntegrityPostPayRefund')

					BEGIN
						
						SET @nothing_to_preprocess = 0

						EXEC spFCAuto_LogPPMethod @log_id, @method_name, @table_name, 'Update Claim SIDs', @method_id OUTPUT

						PRINT '        Method: ' + @method_name
						PRINT '        Table:  ' + @table_name
						PRINT '        Action: Update Claim SIDs'
						PRINT ''
						PRINT ''
						PRINT '        -Record ID--Claim Number---------Line Number----Date Submitted----------------------Claim SID--------------------------------------------'

						DECLARE TestCase_Cursor CURSOR FOR
						 SELECT claim_number
							   ,line_number
							   ,record_id
						   FROM #TestCases

						   OPEN TestCase_Cursor
						  FETCH NEXT FROM TestCase_Cursor
						   INTO @claim_number, @line_number, @record_id

						  WHILE @@FETCH_STATUS = 0
							
							BEGIN

								-- Get the latest date the claim was submitted
								SET @sql = 'SELECT @date_submitted = MAX(date_submitted) FROM Claims_Log_V2 WHERE claim_number = ''' + @claim_number + ''' AND line_number = ''' + CONVERT(VARCHAR(100), @line_number) + ''' AND bank_acct_check_gid <> -1'
								EXEC sp_executesql @sql, N'@date_submitted DATETIME OUTPUT', @date_submitted=@date_submitted OUTPUT
								SELECT @date_submitted_char = CASE WHEN ISNULL(@date_submitted, '') = '' THEN 'No matching claim found in the Core database.' ELSE LEFT(CONVERT(VARCHAR(100), @date_submitted, 21) + SPACE(35), 35) END
								SELECT @status = CASE WHEN ISNULL(@date_submitted, '') = '' THEN 'No matching claim found in the Core database.' ELSE '' END

								SET @sql = 'SELECT @claim_sid = claim_sid FROM Claims_Log_V2 WHERE claim_number = ''' + @claim_number + ''' AND line_number = ''' + CONVERT(VARCHAR(100), @line_number) + ''' AND date_submitted = ''' + CONVERT(VARCHAR(100), @date_submitted, 21) + ''' AND bank_acct_check_gid <> -1'
								EXEC sp_executesql @sql, N'@claim_sid INT OUTPUT', @claim_sid=@claim_sid OUTPUT
								SELECT @claim_sid_char = CASE WHEN ISNULL(@claim_sid, 0) = 0 THEN SPACE(10) ELSE LEFT(CONVERT(VARCHAR(10), @claim_sid) + SPACE(10), 10) END
					
								PRINT '         ' + LEFT(CONVERT(VARCHAR(10), @record_id) + SPACE(10), 10)  + ' ' + LEFT(@claim_number + SPACE(20), 20) + ' ' + LEFT(CONVERT(VARCHAR(10), @line_number) + SPACE(14),14) + ' ' + @date_submitted_char + ' ' + @claim_sid_char
								
								--IF @err_num = 100 SET @err_num = 0
								EXEC spFCAuto_LogPPMethodDetail @method_id, @record_id, @claim_number, @line_number, @date_submitted, @claim_sid, @status

								SELECT @claim_sid = ISNULL(@claim_sid, 0)
								SET @sql = 'UPDATE COREAUTO.CoreFileCreator.dbo.' + @table_name + ' SET ' + @claim_sid_field + ' = ' + CONVERT(VARCHAR(10), @claim_sid) + ' WHERE RecordID = ' + CONVERT(VARCHAR(20), @record_id)
								EXEC(@sql)

								FETCH NEXT FROM TestCase_Cursor
								 INTO @claim_number, @line_number, @record_id

							END

						CLOSE TestCase_Cursor
						DEALLOCATE TestCase_Cursor
					END

				FETCH NEXT FROM TestCaseTable_Cursor
		         INTO @table_name, @TCID, @method_name
			END

		CLOSE TestCaseTable_Cursor
		DEALLOCATE TestCaseTable_Cursor
	END

--*************************************************************************************************
-- PREPROCESSOR: Risk Scores
--*************************************************************************************************
IF EXISTS(SELECT TOP 1 * FROM #TestCaseTables WHERE TableName = 'TD_RiskScores')
	BEGIN

		DECLARE TestCaseTable_Cursor CURSOR FOR
		 SELECT TableName
			   ,TCID
			   ,TestCaseMethod
		   FROM #TestCaseTables

		   OPEN TestCaseTable_Cursor
		  FETCH NEXT FROM TestCaseTable_Cursor
		   INTO @table_name, @TCID, @method_name

		  WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @sql = 'INSERT INTO #member_gids
									(member_id
									,record_id)
							SELECT MEMBER_ID
									,RecordID
								FROM COREAUTO.CoreFileCreator.dbo.' + @table_name + '
								WHERE TCID LIKE ''' + @TCID + '''
								AND ActiveTestCase = ''A'''
				EXEC(@sql)

				-- If there are any test cases for the Identification file then update the Claims SID
				IF EXISTS(SELECT TOP 1 * FROM #member_gids) 
					BEGIN
						
						SET @nothing_to_preprocess = 0

						EXEC spFCAuto_LogPPMethod @log_id, @method_name, @table_name, 'Update Member GIDs', @method_id OUTPUT

						PRINT '        Method: ' + @method_name
						PRINT '        Table:  ' + @table_name
						PRINT '        Action: Update Member GIDs'
						PRINT ''
						PRINT ''
						PRINT '        -Record ID--Member ID------------Member GID----------------------------------------------------------------------------------------------'

						DECLARE Member_Cursor CURSOR FOR
						 SELECT member_id
							   ,record_id
						   FROM #member_gids

						   OPEN Member_Cursor
						  FETCH NEXT FROM Member_Cursor
						   INTO @member_id, @record_id

						  WHILE @@FETCH_STATUS = 0
							
							BEGIN

								-- Get the member gid
								SET @sql = 'SELECT @member_gid = parent_gid FROM Eligibility_Coverage WHERE member_id = ''' + @member_id + ''' AND record_status = ''A'' AND child_identifier = ''M'' AND parent_identifier = ''M'''
								EXEC sp_executesql @sql, N'@member_gid INT OUTPUT', @member_gid=@member_gid OUTPUT
								SELECT @member_gid_char = CASE WHEN ISNULL(@member_gid, 0) = 0 THEN SPACE(10) ELSE LEFT(CONVERT(VARCHAR(10), @member_gid) + SPACE(10), 10) END
								SELECT @status = CASE WHEN ISNULL(@member_gid, 0) = 0 THEN 'No matching member found in the Core database.' ELSE '' END

								PRINT '         ' + LEFT(CONVERT(VARCHAR(10), @record_id) + SPACE(10), 10)  + ' ' + LEFT(@member_id + SPACE(20), 20) + ' ' + @member_gid_char
								
								--IF @err_num = 100 SET @err_num = 0
								EXEC spFCAuto_LogPPMethodDetail @method_id, @record_id, @member_id, '', '', @member_gid, @status

								SELECT @claim_sid = ISNULL(@claim_sid, 0)
								SET @sql = 'UPDATE COREAUTO.CoreFileCreator.dbo.' + @table_name + ' SET MEMBER_GID = ' + CONVERT(VARCHAR(20), @member_gid) + ', SUBSCRIBER_GID = ' + CONVERT(VARCHAR(20), @member_gid) + ' WHERE RecordID = ' + CONVERT(VARCHAR(20), @record_id)
								EXEC(@sql)

								FETCH NEXT FROM Member_Cursor
								 INTO @member_id, @record_id

							END

						CLOSE Member_Cursor
						DEALLOCATE Member_Cursor
					END

				FETCH NEXT FROM TestCaseTable_Cursor
		         INTO @table_name, @TCID, @method_name
			END

		CLOSE TestCaseTable_Cursor
		DEALLOCATE TestCaseTable_Cursor
	END
--*************************************************************************************************
-- If there was nothing to process output message to the user
--*************************************************************************************************
IF @nothing_to_preprocess = 1
	PRINT '        Nothing for the preprocessor to process'

PRINT ''
PRINT '        ----------------------------------------------------------------------------------------------------------------------------------------'

UPDATE dbo.PPLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TestCaseTables') IS NOT NULL
	DROP TABLE #TestCaseTables

IF OBJECT_ID('tempdb.dbo.#TestCases') IS NOT NULL
	DROP TABLE #TestCases

IF OBJECT_ID('tempdb.dbo.#member_gids') IS NOT NULL
	DROP TABLE #member_gids
END
GO