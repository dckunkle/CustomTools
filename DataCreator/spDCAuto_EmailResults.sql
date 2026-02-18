IF OBJECT_ID('dbo.spDCAuto_EmailResults') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_EmailResults AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_EmailResults
Purpose:    Used to log details to the DCLogDetail table

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
01/08/2020	DK				Wrap variables in ISNULL to prevent a NULL value from wiping out the
                            body of the email
01/13/2020	DK				Add the email address and the build number to the output
01/15/2020	DK				Add the build number and job name coming from Jenkins
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_EmailResults 166, 'dkunkle@evolenthealth.com'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_EmailResults
     (@log_id				INT
	 ,@email_address		VARCHAR(200))
AS
BEGIN

DECLARE @l_email_address	NVARCHAR(MAX)
       ,@l_body				NVARCHAR(MAX)
	   ,@l_subject			NVARCHAR(MAX)
       
	   ,@method				VARCHAR(200)
	   ,@skip				INT
	   ,@error				INT
	   ,@success			INT
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
SET @td_styling		= 'style="border: 1px solid #dddddd;padding: 4px;'
SET @th_styling		= 'style="background-color:#0099cc;color:white;padding:4px;border: 1px solid #dddddd;"'

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
      (method		VARCHAR(200)
	  ,error		INT
	  ,skip			INT
	  ,success		INT
	  ,sort_order	INT)

IF OBJECT_ID('tempdb.dbo.#totals') IS NOT NULL
	DROP TABLE #totals

CREATE TABLE #totals
      (job_name				VARCHAR(200)
	  ,build_id				INT
	  ,log_id				INT
	  ,server_name			VARCHAR(200)
	  ,user_id				VARCHAR(200)
	  ,test_case_pattern	VARCHAR(200)
	  ,start_time			DATETIME
	  ,end_time				DATETIME
	  ,error				INT		
	  ,skip					INT
	  ,success				INT
	  ,total_minutes		INT
	  ,total_seconds		DECIMAL(10,2)
	  ,email_address		VARCHAR(8000))

;WITH Results_CTE
   AS(SELECT method
            ,CASE WHEN status = 'Config'	THEN 'Skip' 
			      WHEN status = 'Add'		THEN 'Success'
				  ELSE status 
			  END AS status
	        ,count(*)		AS count
	        ,MAX(log_sid)	AS method_order
		FROM DCLogDetail
	   WHERE log_id = @log_id
       GROUP BY method, status)
INSERT INTO #results
      (method
	  ,error
	  ,skip
	  ,success
	  ,sort_order)
SELECT method
      ,ISNULL(error, 0)		AS error
	  ,ISNULL(skip, 0)		AS skip
	  ,ISNULL(success, 0)	AS success
	  ,method_order
  FROM Results_CTE
 PIVOT(SUM(count)
   FOR status IN ([error],[skip],[success])) pvt

;WITH Totals_CTE
   AS(SELECT SUM(error)		AS error
			,SUM(skip)		AS skip
			,SUM(success)	AS success
        FROM #results) 
INSERT INTO #totals
      (error
	  ,skip
	  ,success)
SELECT error
	  ,skip
	  ,success
  FROM Totals_CTE

UPDATE #totals
   SET job_name				= L.job_name
      ,build_id				= L.build_id
      ,log_id				= L.log_id
      ,user_id				= L.user_id
	  ,test_case_pattern	= L.pattern
	  ,start_time			= L.start_time
	  ,end_time				= L.end_time
	  ,total_minutes		= DATEDIFF(MILLISECOND,L.start_time,L.end_time)/60000
	  ,total_seconds		= 0
	  ,email_address		= L.email_address
  FROM DCLog				L
 WHERE L.log_id				= @log_id

UPDATE #totals
   SET total_seconds		= (DATEDIFF(MILLISECOND,start_time,end_time) - total_minutes * 60000)/1000

UPDATE #totals
   SET total_seconds		= total_seconds + (((DATEDIFF(MILLISECOND,start_time,end_time) - (total_minutes * 60000) - (total_seconds * 1000))%1000)/1000)

--*************************************************************************************************
-- Begin creating the HTML for the body of the email
--*************************************************************************************************
SET @l_subject = 'Data Creator Results'
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
DECLARE @user_id			VARCHAR(200)
       ,@test_case			VARCHAR(200)
	   ,@total_time			VARCHAR(200)
	   ,@webURL				VARCHAR(2000)
	   ,@t_email_address	VARCHAR(8000)
	   ,@build_id			VARCHAR(200)
	   ,@job_name			VARCHAR(200)
	   
SELECT @user_id			= T.user_id
      ,@test_case		= T.test_case_pattern
	  ,@error			= T.error
	  ,@skip			= T.skip
	  ,@success			= T.success
	  ,@total_time		= CASE WHEN T.total_minutes = 0 THEN CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
							   ELSE CONVERT(VARCHAR(20), T.total_minutes) + ' minutes and ' + CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
						   END
	  ,@t_email_address = T.email_address
	  ,@build_id		= CONVERT(VARCHAR(200), T.build_id)
	  ,@job_name		= T.job_name
  FROM #totals		T

SELECT @webURL			= LOWER(REPLACE(GP.variable_value, '/services/',''))
  FROM Global_Params	GP
 WHERE variable_name = 'AlderaWebServiceURL'

SET @l_body = @l_body +
'<p>The Data Creator process has completed running on ' + @@SERVERNAME + ' (<a>' + @webURL + '</a>).</p>'

SET @l_body = @l_body
+ '<h2>Processing Summary</h2>' + @crlf 
+ '<table ' + @table_styling + '>' + @crlf
		 + '	<tr ' + @th_styling + '>' + @crlf
		 + '		<td ' + @th_styling + '>Job Name</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Build</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Log ID</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>User</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Server</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Test Case</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Errors</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Skipped</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Successful</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Total Time</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Email Address</td>'	+ @crlf
		 + '	</tr>' + @crlf

SET @l_body = @l_body
		 + '	<tr ' + @tr_odd + '>' + @crlf
		 + '		<td ' + @td_right + '>' + @job_name + '</td>'									+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @build_id) + '</td>'				+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @log_id) + '</td>'				+ @crlf
		 + '		<td ' + @td_left  + '>' + @user_id + '</td>'									+ @crlf
		 + '		<td ' + @td_left  + '>' + @@SERVERNAME + '</td>'								+ @crlf
		 + '		<td ' + @td_left  + '>' + @test_case + '</td>'									+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@error, 0)) + '</td>'		+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@skip, 0)) + '</td>'		+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@success, 0)) + '</td>'	+ @crlf
		 + '		<td ' + @td_right + '>' + @total_time + '</td>'									+ @crlf
		 + '		<td ' + @td_right + '>' + @t_email_address + '</td>'							+ @crlf
		 + '	</tr>' + @crlf

SET @l_body = @l_body
+ '</table>' + @crlf

--*************************************************************************************************
-- Create detailed results portion of the email
--*************************************************************************************************
SET @l_body = @l_body
+ '<h2>Processing Detail</h2>' + @crlf
+ '<table ' + @table_styling + '>' + @crlf
		 + '	<tr ' + @th_styling + '>' + @crlf
		 + '		<td ' + @th_styling + '>Method</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Error</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Skip</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Success</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Total</td>'		+ @crlf
		 + '	</tr>' + @crlf

DECLARE Results_Cursor CURSOR FOR
 SELECT method
       ,SUM(error)		AS error
       ,SUM(skip)		AS skip
	   ,SUM(success)	AS success
   FROM #results	R
  GROUP BY method
  ORDER BY MAX(sort_order)
  
  OPEN Results_Cursor
 FETCH NEXT FROM Results_Cursor
  INTO @method, @error, @skip, @success

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @total = @error + @skip + @success
		SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@method, '') + '</td>' + @crlf
							  + '		<td ' + CASE WHEN @error > 0 THEN @td_right_error
							                         ELSE @td_right 
											     END + '>' + CONVERT(VARCHAR(20), ISNULL(@error, 0)) + '</td>' + @crlf
							  + '		<td ' + CASE WHEN @skip > 0 THEN @td_right_error
							                         ELSE @td_right 
											     END + '>' + CONVERT(VARCHAR(20), ISNULL(@skip, 0)) + '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@success, 0)) + '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@total, 0)) + '</td>' + @crlf
							  + '	</tr>' + @crlf
		SET @counter = @counter + 1

		 FETCH NEXT FROM Results_Cursor
		  INTO @method, @error, @skip, @success

	END

CLOSE Results_Cursor
DEALLOCATE Results_Cursor

SELECT @error	= error
      ,@skip	= skip
	  ,@success = success
  FROM #totals

SET @total = @error + @skip + @success

SET @l_body = @l_body + '<tr ' + @th_styling + '>
                         <td ' + @td_left + '>Totals</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@error, 0)) + '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@skip, 0)) + '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@success, 0)) + '</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@total, 0)) + '</td></tr>
 </table>
 '

--*************************************************************************************************
-- Create the Errored Records Detail portion of the email (if there are any errors)
--*************************************************************************************************
DECLARE @key1		VARCHAR(200)
       ,@key2		VARCHAR(200)
	   ,@key3		VARCHAR(200)
	   ,@record_id	INT
	   ,@err_num	INT
	   ,@err_msg	VARCHAR(4000)

IF OBJECT_ID('tempdb.dbo.#errors') IS NOT NULL
	DROP TABLE #errors

CREATE TABLE #errors
      (method		VARCHAR(200)
	  ,record_id	INT
	  ,key_data_1	VARCHAR(8000)
	  ,key_data_2	VARCHAR(8000)
	  ,key_data_3	VARCHAR(8000)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,log_sid		INT)

INSERT INTO #errors
      (method
	  ,record_id
	  ,key_data_1
	  ,key_data_2
	  ,key_data_3
	  ,err_num
	  ,err_msg
	  ,log_sid)
SELECT method
      ,record_id
	  ,ISNULL(key_data_1, '')
	  ,ISNULL(key_data_2, '')
	  ,ISNULL(key_data_3, '')
	  ,ISNULL(err_num, 0)
	  ,err_msg
	  ,log_sid
  FROM DCLogDetail
 WHERE log_id		= @log_id
   AND status		= 'error'

IF EXISTS(SELECT TOP 1 * FROM #errors)
	BEGIN

		SET @counter = 1
		SET @l_body = @l_body
		+ '<h2>Errored Records Detail</h2>' + @crlf
		+ '<table ' + @table_styling + '>' + @crlf
				 + '	<tr ' + @th_styling + '>' + @crlf
				 + '		<td ' + @th_styling + '>Method Name</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Record_ID</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_1</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_2</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_3</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Error</td>'			+ @crlf
				 + '		<td ' + @th_styling + '>Error Message</td>'	+ @crlf
				 + '	</tr>' + @crlf

		DECLARE Errors_Cursor CURSOR FOR
		 SELECT method
			   ,record_id
			   ,key_data_1
			   ,key_data_2
			   ,key_data_3
			   ,err_num
			   ,err_msg
		   FROM #errors	
		  ORDER BY log_sid
  
		  OPEN Errors_Cursor
		 FETCH NEXT FROM Errors_Cursor
		  INTO @method, @record_id, @key1, @key2, @key3, @err_num, @err_msg

		WHILE @@FETCH_STATUS = 0
			BEGIN


				SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
									  + '		<td ' + @td_left  + '>' + @method + '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), @record_id) + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key1 + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key2 + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key3 + '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), @err_num) + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @err_msg + '</td>' + @crlf
									  + '	</tr>' + @crlf
				SET @counter = @counter + 1

				 FETCH NEXT FROM Errors_Cursor
				  INTO @method, @record_id, @key1, @key2, @key3, @err_num, @err_msg

			END

		CLOSE Errors_Cursor
		DEALLOCATE Errors_Cursor

	END

SET @l_body = @l_body +
'</table>' + @crlf
 
--*************************************************************************************************
-- Create the Skipped Records Detail portion of the email (if there are any skipped records)
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#skipped') IS NOT NULL
	DROP TABLE #skipped

CREATE TABLE #skipped
      (method		VARCHAR(200)
	  ,record_id	INT
	  ,key_data_1	VARCHAR(8000)
	  ,key_data_2	VARCHAR(8000)
	  ,key_data_3	VARCHAR(8000)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,log_sid		INT)

INSERT INTO #skipped
      (method
	  ,record_id
	  ,key_data_1
	  ,key_data_2
	  ,key_data_3
	  ,err_num
	  ,err_msg
	  ,log_sid)
SELECT method
      ,record_id
	  ,key_data_1
	  ,key_data_2
	  ,key_data_3
	  ,err_num
	  ,err_msg
	  ,log_sid
  FROM DCLogDetail
 WHERE log_id		= @log_id
   AND status		IN ('Skip', 'Config')

IF EXISTS(SELECT TOP 1 * FROM #skipped)
	BEGIN

		SET @counter = 1
		SET @l_body = @l_body
		+ '<h2>Skipped Records Detail</h2>' + @crlf
		+ '<table ' + @table_styling + '>' + @crlf
				 + '	<tr ' + @th_styling + '>' + @crlf
				 + '		<td ' + @th_styling + '>Method Name</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Record_ID</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_1</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_2</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Value_3</td>'		+ @crlf
				 + '		<td ' + @th_styling + '>Error</td>'			+ @crlf
				 + '		<td ' + @th_styling + '>Error Message</td>'	+ @crlf
				 + '	</tr>' + @crlf

		DECLARE Skipped_Cursor CURSOR FOR
		 SELECT method
			   ,record_id
			   ,key_data_1
			   ,key_data_2
			   ,key_data_3
			   ,err_num
			   ,err_msg
		   FROM #skipped	
		  ORDER BY log_sid
  
		  OPEN Skipped_Cursor
		 FETCH NEXT FROM Skipped_Cursor
		  INTO @method, @record_id, @key1, @key2, @key3, @err_num, @err_msg

		WHILE @@FETCH_STATUS = 0
			BEGIN


				SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
									  + '		<td ' + @td_left  + '>' + @method + '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), @record_id) + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key1 + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key2 + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @key3 + '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), @err_num) + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @err_msg + '</td>' + @crlf
									  + '	</tr>' + @crlf
				SET @counter = @counter + 1

				 FETCH NEXT FROM Skipped_Cursor
				  INTO @method, @record_id, @key1, @key2, @key3, @err_num, @err_msg

			END

		CLOSE Skipped_Cursor
		DEALLOCATE Skipped_Cursor

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
							,@from_address	= 'data_creator@evolenthealth.com'

END
GO