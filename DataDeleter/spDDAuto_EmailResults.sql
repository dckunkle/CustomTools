IF OBJECT_ID('dbo.spDDAuto_EmailResults') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_EmailResults AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_EmailResults
Purpose:    Used to send email results from the Data Deleter

Date        User            Change
---------------------------------------------------------------------------------------------
01/22/2020	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_EmailResults 166, 'dkunkle@evolenthealth.com'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_EmailResults
     (@log_id				INT
	 ,@email_address		VARCHAR(200))
AS
BEGIN

DECLARE @l_email_address	NVARCHAR(MAX)
       ,@l_body				NVARCHAR(MAX)
	   ,@l_subject			NVARCHAR(MAX)
       
	   ,@table_name			VARCHAR(200)
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
SET @th_styling		= 'style="background-color:#e2344c;color:white;padding:4px;border: 1px solid #dddddd;"'

SET @tr_odd			= 'style="background-color:#ffffff;padding:4px;"'
SET @tr_even		= 'style="background-color:#e2e2e2;padding:4px;"'
SET @td_right		= @td_styling + 'text-align:right;"'
SET @td_left		= @td_styling + 'text-align:left;"'
SET @td_right_error	= LEFT(@td_right, LEN(@td_right) - 1) + 'color:red;font-weight:bold;"'

--*************************************************************************************************
-- Collect the results data from the logs
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#results') IS NOT NULL
	DROP TABLE #results

CREATE TABLE #results
      (table_name	VARCHAR(200)
	  ,error		INT
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
	  ,entity_to_delete		VARCHAR(200)
	  ,entity_type			VARCHAR(200)
	  ,start_time			DATETIME
	  ,end_time				DATETIME
	  ,error				INT		
	  ,success				INT
	  ,total_minutes		INT
	  ,total_seconds		DECIMAL(10,2)
	  ,email_address		VARCHAR(8000))

;WITH Results_CTE
   AS(SELECT table_name
            ,CASE WHEN status = 'Config'	THEN 'Skip' 
			      WHEN status = 'Delete'	THEN 'Success'
				  ELSE status 
			  END AS status
	        ,SUM(record_count)	AS count
	        ,MAX(log_sid)		AS table_order
		FROM DDLogDetail
	   WHERE log_id = @log_id
       GROUP BY table_name, status)
INSERT INTO #results
      (table_name
	  ,error
	  ,success
	  ,sort_order)
SELECT table_name
      ,ISNULL(error, 0)		AS error
	  ,ISNULL(success, 0)	AS success
	  ,table_order
  FROM Results_CTE
 PIVOT(SUM(count)
   FOR status IN ([error],[success])) pvt

;WITH Totals_CTE
   AS(SELECT SUM(error)		AS error
			,SUM(success)	AS success
        FROM #results) 
INSERT INTO #totals
      (error
	  ,success)
SELECT error
	  ,success
  FROM Totals_CTE

UPDATE #totals
   SET job_name				= L.job_name
      ,build_id				= L.build_id
      ,log_id				= L.log_id
      ,user_id				= L.user_id
	  ,entity_to_delete		= L.entity_to_delete
	  ,entity_type			= L.entity_type
	  ,start_time			= L.start_time
	  ,end_time				= L.end_time
	  ,total_minutes		= DATEDIFF(MILLISECOND,L.start_time,L.end_time)/60000
	  ,total_seconds		= 0
	  ,email_address		= L.email_address
  FROM DDLog				L
 WHERE L.log_id				= @log_id

UPDATE #totals
   SET total_seconds		= (DATEDIFF(MILLISECOND,start_time,end_time) - total_minutes * 60000)/1000

UPDATE #totals
   SET total_seconds		= total_seconds + (((DATEDIFF(MILLISECOND,start_time,end_time) - (total_minutes * 60000) - (total_seconds * 1000))%1000)/1000)

--*************************************************************************************************
-- Begin creating the HTML for the body of the email
--*************************************************************************************************
SET @l_subject = 'Data Deleter Results'
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
	   ,@entity_to_delete	VARCHAR(100)
	   ,@entity_type		VARCHAR(200)
	   
SELECT @user_id				= T.user_id
      ,@entity_to_delete	= T.entity_to_delete
	  ,@entity_type			= T.entity_type
	  ,@error				= T.error
	  ,@success				= T.success
	  ,@total_time			= CASE WHEN T.total_minutes = 0 THEN CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
								   ELSE CONVERT(VARCHAR(20), T.total_minutes) + ' minutes and ' + CONVERT(VARCHAR(20), T.total_seconds) + ' seconds'
							   END
	  ,@t_email_address		= T.email_address
	  ,@build_id			= CONVERT(VARCHAR(200), T.build_id)
	  ,@job_name			= T.job_name
  FROM #totals		T

SELECT @webURL			= LOWER(REPLACE(GP.variable_value, '/services/',''))
  FROM Global_Params	GP
 WHERE variable_name	= 'AlderaWebServiceURL'

SET @l_body = @l_body +
'<p>The Data Deleter process has completed running on ' + @@SERVERNAME + ' (<a>' + @webURL + '</a>).</p>'

SET @l_body = @l_body
+ '<h2>Processing Summary</h2>' + @crlf 
+ '<table ' + @table_styling + '>' + @crlf
		 + '	<tr ' + @th_styling + '>' + @crlf
		 + '		<td ' + @th_styling + '>Job Name</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Build</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Log ID</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>User</td>'				+ @crlf
		 + '		<td ' + @th_styling + '>Server</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>' + @entity_type + ' To Delete</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Errors</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Successful</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Total Time</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Email Address</td>'		+ @crlf
		 + '	</tr>' + @crlf

SET @l_body = @l_body
		 + '	<tr ' + @tr_odd + '>' + @crlf
		 + '		<td ' + @td_right + '>' + @job_name + '</td>'									+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @build_id) + '</td>'				+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), @log_id) + '</td>'				+ @crlf
		 + '		<td ' + @td_left  + '>' + @user_id + '</td>'									+ @crlf
		 + '		<td ' + @td_left  + '>' + @@SERVERNAME + '</td>'								+ @crlf
		 + '		<td ' + @td_left  + '>' + @entity_to_delete + '</td>'							+ @crlf
		 + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@error, 0)) + '</td>'		+ @crlf
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
		 + '		<td ' + @th_styling + '>Table Name</td>'	+ @crlf
		 + '		<td ' + @th_styling + '>Error</td>'			+ @crlf
		 + '		<td ' + @th_styling + '>Success</td>'		+ @crlf
		 + '		<td ' + @th_styling + '>Total</td>'			+ @crlf
		 + '	</tr>' + @crlf

DECLARE Results_Cursor CURSOR FOR
 SELECT table_name
       ,SUM(error)		AS error
	   ,SUM(success)	AS success
   FROM #results	R
  GROUP BY table_name
  ORDER BY MAX(sort_order)
  
  OPEN Results_Cursor
 FETCH NEXT FROM Results_Cursor
  INTO @table_name, @error, @success

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @total = @error + @success
		SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
							  + '		<td ' + @td_left  + '>' + ISNULL(@table_name, '') + '</td>' + @crlf
							  + '		<td ' + CASE WHEN @error > 0 THEN @td_right_error
							                         ELSE @td_right 
											     END + '>' + CONVERT(VARCHAR(20), ISNULL(@error, 0)) + '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@success, 0)) + '</td>' + @crlf
							  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), ISNULL(@total, 0)) + '</td>' + @crlf
							  + '	</tr>' + @crlf
		SET @counter = @counter + 1

		 FETCH NEXT FROM Results_Cursor
		  INTO @table_name, @error, @success

	END

CLOSE Results_Cursor
DEALLOCATE Results_Cursor

SELECT @error	= error
	  ,@success = success
  FROM #totals

SET @total = @error + @success

SET @l_body = @l_body + '<tr ' + @th_styling + '>
                         <td ' + @td_left + '>Totals</td>
						 <td ' + @td_right + '>' + CONVERT(VARCHAR(10), ISNULL(@error, 0)) + '</td>
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
      (table_name	VARCHAR(200)
	  ,err_num		INT
	  ,err_msg		VARCHAR(8000)
	  ,log_sid		INT)

INSERT INTO #errors
      (table_name
	  ,err_num
	  ,err_msg
	  ,log_sid)
SELECT table_name
	  ,ISNULL(err_num, 0)
	  ,err_msg
	  ,log_sid
  FROM DDLogDetail
 WHERE log_id		= @log_id
   AND status		= 'error'

IF EXISTS(SELECT TOP 1 * FROM #errors)
	BEGIN

		SET @counter = 1
		SET @l_body = @l_body
		+ '<h2>Errored Records Detail</h2>' + @crlf
		+ '<table ' + @table_styling + '>' + @crlf
				 + '	<tr ' + @th_styling + '>' + @crlf
				 + '		<td ' + @th_styling + '>Table Name</td>'	+ @crlf
				 + '		<td ' + @th_styling + '>Error</td>'			+ @crlf
				 + '		<td ' + @th_styling + '>Error Message</td>'	+ @crlf
				 + '	</tr>' + @crlf

		DECLARE Errors_Cursor CURSOR FOR
		 SELECT table_name
			   ,err_num
			   ,err_msg
		   FROM #errors	
		  ORDER BY log_sid
  
		  OPEN Errors_Cursor
		 FETCH NEXT FROM Errors_Cursor
		  INTO @table_name, @err_num, @err_msg

		WHILE @@FETCH_STATUS = 0
			BEGIN


				SET @l_body = @l_body + '	<tr ' + CASE WHEN @counter%2 = 0 THEN @tr_even ELSE @tr_odd END + '>' + @crlf
									  + '		<td ' + @td_left  + '>' + @table_name + '</td>' + @crlf
									  + '		<td ' + @td_right + '>' + CONVERT(VARCHAR(20), @err_num) + '</td>' + @crlf
									  + '		<td ' + @td_left  + '>' + @err_msg + '</td>' + @crlf
									  + '	</tr>' + @crlf
				SET @counter = @counter + 1

				 FETCH NEXT FROM Errors_Cursor
				  INTO @table_name, @err_num, @err_msg

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
							,@from_address	= 'data_deleter@evolenthealth.com'

END
GO