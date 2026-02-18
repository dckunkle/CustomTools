IF OBJECT_ID('dbo.spFVAuto_EmailResults') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFVAuto_EmailResults AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFVAuto_EmailResults
Purpose:    Report results of the File Validator

Date        User            Change
---------------------------------------------------------------------------------------------
05/13/2020	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFVAuto_EmailResults 9, 'dkunkle@evolenthealth.com'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFVAuto_EmailResults
     (@log_id				INT
	 ,@email_address		VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @l_email_address	NVARCHAR(MAX)
       ,@l_body				NVARCHAR(MAX)
	   ,@l_subject			NVARCHAR(MAX)
       
	   ,@method				VARCHAR(200)
	   ,@missing_data		INT
	   ,@missing_validation	INT
	   ,@validated			INT
	   ,@total				INT
	   ,@crlf				VARCHAR(20)
	   ,@counter			INT				= 1

-- Styling Variables
	   ,@td_styling			NVARCHAR(MAX)
	   ,@table_styling		NVARCHAR(MAX)
	   ,@th_styling			NVARCHAR(MAX)
	   ,@tr_odd				NVARCHAR(MAX)
	   ,@tr_even			NVARCHAR(MAX)
	   ,@td_right			NVARCHAR(MAX)
	   ,@td_left			NVARCHAR(MAX)
	   ,@td_right_error		NVARCHAR(MAX)

SELECT @crlf				= CHAR(13) + CHAR(10)
      ,@l_email_address		= @email_address

--*************************************************************************************************
-- CSS Styling
--*************************************************************************************************
SET @table_styling	= 'cellspacing="0" style="font-family: Calibri, Arial, Helvetica, sans-serif;"'
SET @td_styling		= 'style="border: 1px solid #dddddd;padding: 4px;white-space:pre'
SET @th_styling		= 'style="background-color:#b72d5b;color:white;padding:4px;border: 1px solid #dddddd;"'

SET @tr_odd			= 'style="background-color:#ffffff;padding:4px;"'
SET @tr_even		= 'style="background-color:#f2f2f2;padding:4px;"'
SET @td_right		= @td_styling + 'text-align:right;"'
SET @td_left		= @td_styling + 'text-align:left;"'
SET @td_right_error	= LEFT(@td_right, LEN(@td_right) - 1) + 'color:red;font-weight:bold;"'

--*************************************************************************************************
-- Collect the results data from the logs
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#results') IS NOT NULL
	DROP TABLE #results

CREATE TABLE #results
      (testcase				VARCHAR(200)
	  ,method				VARCHAR(200)
	  ,missing_data			INT
	  ,missing_validation	INT
	  ,validated			INT
	  ,sort_order			INT)

IF OBJECT_ID('tempdb.dbo.#totals') IS NOT NULL
	DROP TABLE #totals

CREATE TABLE #totals
      (job_name				VARCHAR(200)
	  ,build_id				INT
	  ,log_id				INT
	  ,server_name			VARCHAR(200)
	  ,test_case_pattern	VARCHAR(200)
	  ,start_time			DATETIME
	  ,end_time				DATETIME
	  ,missing_data			INT		
	  ,missing_validation	INT
	  ,validated			INT
	  ,total_minutes		INT
	  ,total_seconds		DECIMAL(10,2)
	  ,email_address		VARCHAR(8000))

IF OBJECT_ID('tempdb.dbo.#field_result_totals') IS NOT NULL
	DROP TABLE #field_result_totals

CREATE TABLE #field_result_totals
      (tc_log_id			INT
	  ,pass					INT
	  ,pass_default			INT
	  ,fail					INT
	  ,sort_order			INT)

--*************************************************************************************************
-- Collect data for the Processing Summary
--*************************************************************************************************
;WITH Results_CTE
   AS(SELECT testcase
            ,method
            ,CASE WHEN err_type = 'Config'	THEN 'Config' 
			      WHEN err_type = 'Missing'	THEN 'Missing'
				  WHEN err_type = ''		THEN 'Validated'
				  ELSE err_type 
			  END AS status
	        ,count(*)		AS count
	        ,MAX(tc_log_id)	AS method_order
		FROM FVLogTestCase
	   WHERE log_id = @log_id
       GROUP BY testcase, method, err_type)
INSERT INTO #results
      (testcase
	  ,method
	  ,missing_validation
	  ,missing_data
	  ,validated
	  ,sort_order)
SELECT testcase
      ,method
      ,ISNULL(Config, 0)		AS missing_validation
	  ,ISNULL(Missing, 0)		AS missing_data
	  ,ISNULL(validated, 0)		AS validated
	  ,method_order
  FROM Results_CTE
 PIVOT(SUM(count)
   FOR status IN ([Config], [Missing], [validated])) pvt

;WITH Totals_CTE
   AS(SELECT SUM(missing_validation)	AS missing_validation
			,SUM(missing_data)			AS missing_data
			,SUM(validated)				AS validated
        FROM #results) 
INSERT INTO #totals
      (missing_validation
	  ,missing_data
	  ,validated)
SELECT missing_validation
	  ,missing_data
	  ,validated
  FROM Totals_CTE

UPDATE #totals
   SET job_name				= L.job_name
      ,build_id				= L.build_id
      ,log_id				= L.log_id
	  ,test_case_pattern	= L.test_case_pattern
	  ,start_time			= L.start_time
	  ,end_time				= L.end_time
	  ,total_minutes		= DATEDIFF(MILLISECOND,L.start_time,L.end_time)/60000
	  ,total_seconds		= 0
	  ,email_address		= L.email_address
  FROM FVLog				L
 WHERE L.log_id				= @log_id

UPDATE #totals
   SET total_seconds		= (DATEDIFF(MILLISECOND,start_time,end_time) - total_minutes * 60000)/1000

UPDATE #totals
   SET total_seconds		= total_seconds + (((DATEDIFF(MILLISECOND,start_time,end_time) - (total_minutes * 60000) - (total_seconds * 1000))%1000)/1000)

--*************************************************************************************************
-- Collect data for the Processing Summary
--*************************************************************************************************
;WITH Results_CTE
   AS(SELECT TC.tc_log_id
            ,ISNULL(TCV.status, 'Fail')		AS status
	        ,count(*)						AS count
	        ,MAX(TC.tc_log_id)				AS method_order
		FROM FVLogTestCase					TC
		LEFT JOIN FVLogTestCaseValidation	TCV
		  ON TCV.tc_log_id				= TC.tc_log_id
	   WHERE TC.log_id					= @log_id
       GROUP BY TC.tc_log_id, TCV.status)
INSERT INTO #field_result_totals
      (tc_log_id
	  ,pass
	  ,pass_default
	  ,fail
	  ,sort_order)
SELECT tc_log_id
      ,ISNULL(pass, 0)				AS pass
	  ,ISNULL([pass-defaulted], 0)	AS pass_default
	  ,ISNULL(fail, 0)				AS fail
	  ,method_order
  FROM Results_CTE
 PIVOT(SUM(count)
   FOR status IN ([pass], [pass-defaulted], [fail])) pvt


--*************************************************************************************************
-- Begin creating the HTML for the body of the email
--*************************************************************************************************
SET @l_subject = 'File Validator Results'
SET @l_body    = 
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>Data Creator Results</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body>'

--*************************************************************************************************
-- Create summary portion of the email
--*************************************************************************************************
DECLARE @test_case			VARCHAR(200)
	   ,@test_case_name		VARCHAR(200)
	   ,@total_time			VARCHAR(200)
	   ,@webURL				VARCHAR(2000)
	   ,@t_email_address	VARCHAR(8000)
	   ,@build_id			VARCHAR(200)
	   ,@job_name			VARCHAR(200)
	   
SELECT @test_case			= T.test_case_pattern
	  ,@missing_data		= T.missing_data
	  ,@missing_validation	= T.missing_validation
	  ,@validated			= T.validated
	  ,@total_time			= CASE WHEN T.total_minutes = 0 THEN CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
								   ELSE CONVERT(VARCHAR(20), T.total_minutes) + ' minutes and ' + CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
							   END
	  ,@t_email_address		= T.email_address
	  ,@build_id			= CONVERT(VARCHAR(200), T.build_id)
	  ,@job_name			= T.job_name
  FROM #totals		T

SELECT @webURL			= LOWER(REPLACE(GP.variable_value, '/services/',''))
  FROM Global_Params	GP
 WHERE variable_name = 'AlderaWebServiceURL'

SET @l_body = @l_body +
'<p>The File Validator process has completed running on ' + @@SERVERNAME + ' (<a>' + @webURL + '</a>).</p>'

SET @l_body = @l_body
+ '<h2>Processing Summary</h2>' + @crlf 
+ '<table ' + @table_styling + '>' + @crlf
		 + '	<tr ' + @th_styling + '>' + @crlf
		 + '		<td ' + @th_styling + '>Job Name</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Build</td>'					+ @crlf
		 + '		<td ' + @th_styling + '>Log ID</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Server</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Test Case</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Missing Data</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Missing Config</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Validated</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Total Time</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Email Address</td>'			+ @crlf
		 + '	</tr>' + @crlf

SET @l_body = @l_body
		 + '	<tr ' + @tr_odd + '>' + @crlf
		 + '		<td ' + @td_left  + '>' + @job_name + '</td>'												+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @build_id) + '</td>'							+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @log_id) + '</td>'							+ @crlf
		 + '		<td ' + @td_left  + '>' + @@SERVERNAME + '</td>'											+ @crlf
		 + '		<td ' + @td_left  + '>' + @test_case + '</td>'												+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@missing_data, 0)) + '</td>'			+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@missing_validation, 0)) + '</td>'	+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@validated, 0)) + '</td>'				+ @crlf
		 + '		<td ' + @td_left  + '>' + @total_time + '</td>'												+ @crlf
		 + '		<td ' + @td_left  + '>' + @t_email_address + '</td>'										+ @crlf
		 + '	</tr>' + @crlf

SET @l_body = @l_body
+ '</table>' + @crlf

--*************************************************************************************************
-- Create detailed results portion of the email
--*************************************************************************************************
DECLARE @TCID				VARCHAR(100)
	   ,@search_keys		VARCHAR(400)
	   ,@record_id			INT
	   ,@core_sid			INT
	   ,@pass				INT
	   ,@pass_default		INT
	   ,@fail				INT
	   ,@err_type			VARCHAR(200)
	   ,@err_msg			VARCHAR(4000)

SET @l_body = @l_body
+ '<h2>Processing Detail</h2>' + @crlf
+ '<table ' + @table_styling + '>' + @crlf
		 + '	<tr ' + @th_styling + '>' + @crlf
		 + '		<td ' + @th_styling + '>Test Case</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Method</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>TCID</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Pass</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Default</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Fail</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Total</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Search Criteria</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Record ID</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Core SID</td>'			+ @crlf
		 + '	</tr>' + @crlf

DECLARE Results_Cursor CURSOR FOR
 SELECT TC.testcase
       ,TC.method
	   ,LEFT(TC.TCID, 100)
	   ,LEFT(TC.search_keys, 200) + '<br>' +LEFT(TC.search_values, 200)
	   ,ISNULL(TC.err_type, '')
	   ,TC.err_message
	   ,TC.record_id
	   ,TC.core_sid
       ,SUM(R.pass)					AS pass
       ,SUM(R.pass_default)			AS pass_default
	   ,SUM(R.fail)					AS fail
   FROM FVLogTestCase				TC
   JOIN #field_result_totals		R
     ON TC.tc_log_id				= R.tc_log_id
  WHERE TC.log_id					= @log_id
  GROUP BY testcase, method, TCID, LEFT(TC.search_keys, 200) + '<br>' +LEFT(TC.search_values, 200), err_type, err_message, record_id, core_sid
  ORDER BY MAX(sort_order)
  
  OPEN Results_Cursor
 FETCH NEXT FROM Results_Cursor
  INTO @test_Case_name,@method, @TCID, @search_keys, @err_type, @err_msg, @record_id, @core_sid, @pass, @pass_default, @fail

WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @err_type <> '' SET @search_keys = @err_type + ' - ' + @err_msg

		SET @total = @pass + @pass_default + @fail
		SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@test_case_name, '')						+ '</td>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@method, '')								+ '</td>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@TCID, '')									+ '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@pass, 0))			+ '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@pass_default, 0))	+ '</td>' + @crlf
							  + '		<td ' + CASE WHEN @fail > 0 THEN @td_right_error
							                         ELSE @td_right 
											     END + '>' + CONVERT(VARCHAR(20), ISNULL(@fail, 0)) + '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@total, 0))			+ '</td>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@search_keys, '')							+ '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@record_id, 0))		+ '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@core_sid, 0))		+ '</td>' + @crlf
							  + '	</tr>' + @crlf
		SET @counter = @counter + 1

		 FETCH NEXT FROM Results_Cursor
		  INTO @test_Case_name,@method, @TCID, @search_keys, @err_type, @err_msg, @record_id, @core_sid, @pass, @pass_default, @fail

	END

CLOSE Results_Cursor
DEALLOCATE Results_Cursor

SELECT @pass			= SUM(pass)
      ,@pass_default	= SUM(pass_default)
	  ,@fail			= SUM(fail)
  FROM #field_result_totals

SET @total = @pass + @pass_default + @fail

SET @l_body = @l_body + '<tr ' + @th_styling + '>
						 <td ' + @td_left + '></td>
						 <td ' + @td_left + '></td>
                         <td ' + @td_left + '>Totals</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@pass, 0))			+ '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@pass_default, 0))	+ '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@fail, 0))			+ '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@total, 0))			+ '</td>
						 <td ' + @td_left + '></td>
						 <td ' + @td_left + '></td></tr>
 </table>
 '

--*************************************************************************************************
-- Create the Errored Records Detail portion of the email (if there are any errors)
--*************************************************************************************************
DECLARE @status			VARCHAR(200)
       ,@file_field		VARCHAR(200)
	   ,@file_value		VARCHAR(2000)
	   ,@core_field		VARCHAR(200)
	   ,@core_value		VARCHAR(2000)
	   ,@default_value	VARCHAR(200)

IF OBJECT_ID('tempdb.dbo.#errors') IS NOT NULL
	DROP TABLE #errors

CREATE TABLE #errors
      (TCID				VARCHAR(200)
	  ,status			VARCHAR(200)
	  ,file_field		VARCHAR(200)
	  ,file_value		VARCHAR(2000)
	  ,core_field		VARCHAR(200)
	  ,core_value		VARCHAR(2000)
	  ,default_value	VARCHAR(2000)
	  ,log_sid			INT)

INSERT INTO #errors
      (TCID
	  ,status
	  ,file_field
	  ,file_value
	  ,core_field
	  ,core_value
	  ,default_value
	  ,log_sid)
SELECT TC.TCID
	  ,TCV.status
	  ,TCV.file_field
	  ,TCV.file_value
	  ,TCV.core_field
	  ,TCV.core_value
	  ,TCV.default_value
	  ,TCV.log_sid
  FROM FVLogTestCaseValidation	TCV
  JOIN FVLogTestCase			TC
    ON TCV.tc_log_id			= TC.tc_log_id
 WHERE TC.log_id				= @log_id
   AND status					= 'Fail'

IF EXISTS(SELECT TOP 1 * FROM #errors)
	BEGIN

		SET @counter = 1
		SET @l_body = @l_body
		+ '<h2>Failed Validation Detail</h2>' + @crlf
		+ '<table ' + @table_styling + '>' + @crlf
				 + '	<tr ' + @th_styling + '>' + @crlf
				 + '		<td ' + @th_styling + '>TCID</td>'			+ @crlf
				 + '		<td ' + @th_styling + '>Status</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>File Field</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>File Value</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Core Field</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Core Value</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Default Value</td>'	+ @crlf
				 + '	</tr>' + @crlf

		DECLARE Errors_Cursor CURSOR FOR
		 SELECT TCID
		       ,status
			   ,file_field
			   ,file_value
			   ,core_field
			   ,core_value
			   ,default_value
		   FROM #errors	
		  ORDER BY log_sid
  
		  OPEN Errors_Cursor
		 FETCH NEXT FROM Errors_Cursor
		  INTO @TCID, @status, @file_field, @file_value, @core_field, @core_value, @default_value

		WHILE @@FETCH_STATUS = 0
			BEGIN


				SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@TCID, '')				+ '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@status, '')			+ '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@file_field, '')		+ '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@file_value, '')		+ '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@core_field, '')		+ '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + ISNULL(@core_value, '')		+ '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + ISNULL(@default_value, '')	+ '</td>' + @crlf
									  + '	</tr>' + @crlf
				SET @counter = @counter + 1

				 FETCH NEXT FROM Errors_Cursor
				  INTO @TCID, @status, @file_field, @file_value, @core_field, @core_value, @default_value

			END

		CLOSE Errors_Cursor
		DEALLOCATE Errors_Cursor

	END

SET @l_body = @l_body +
'</table>' + @crlf

--*************************************************************************************************
-- Complete the HTML for the email
--*************************************************************************************************

SET @l_body = @l_body + 
'</body>
</html>'

--*************************************************************************************************
-- Email Results
--*************************************************************************************************
EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'Mail Connector'  
                            ,@recipients	= @l_email_address  
                            ,@body			= @l_body  
                            ,@subject		= @l_subject
							,@body_format	= 'HTML'
							,@from_address	= 'file_validator@evolenthealth.com'

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#results') IS NOT NULL
	DROP TABLE #results

IF OBJECT_ID('tempdb.dbo.#totals') IS NOT NULL
	DROP TABLE #totals

IF OBJECT_ID('tempdb.dbo.#field_result_totals') IS NOT NULL
	DROP TABLE #field_result_totals


END
GO