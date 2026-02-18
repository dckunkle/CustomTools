/**************************************************************************************************
Name:       spDCAuto_CreatePause10Minutes
Purpose:    Pause execution of Data Creator for 10 minutes

Date        User            Change
---------------------------------------------------------------------------------------------
10/11/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreatePause10Minutes
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS 
BEGIN

SET NOCOUNT ON

DECLARE @err_msg					VARCHAR(4000)	= ''
       ,@err_num					INT				= 0
	   ,@status						VARCHAR(25)		= 'Pause'


	WAITFOR DELAY '00:10:00.000'

	EXEC spDCAuto_LogEvent @i_log_id, @i_test_case_name, @i_method, 0, '', '', '', @status, @err_num, @err_msg
END

