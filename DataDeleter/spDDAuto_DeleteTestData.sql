IF OBJECT_ID('dbo.spDDAuto_DeleteTestData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_DeleteTestData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_DeleteTestData
Purpose:    Delete Automation test data given the TCID and user_id

Date        User            Change
---------------------------------------------------------------------------------------------
01/21/2020	DK				Original script
10/05/2022	DK				Changes to support a delimited list of users to delete
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_DeleteTestData 'MS-CFG;NMP-GRP','dkunkle@evolenthealth.com','140','TestDelete'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_DeleteTestData
      (@user_id			VARCHAR(8000)
	  ,@email_address	VARCHAR(8000)
	  ,@build_id		INT
	  ,@job_name		VARCHAR(8000))
AS
BEGIN

SET NOCOUNT ON

DECLARE @err_msg			VARCHAR(8000)
       ,@err_num			INT
	   ,@status				INT
	   ,@message			VARCHAR(8000)
	   ,@log_id				INT

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO DDLog
      (user_id
	  ,entity_to_delete
	  ,entity_type
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT SUSER_NAME()
      ,@user_id
	  ,'User'
	  ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*************************************************************************************************
-- If this is a list of user IDs split them
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#users') IS NOT NULL
	BEGIN DROP TABLE #users END

CREATE TABLE #users
      (user_id		VARCHAR(100))

INSERT INTO #users 
      (user_id)
SELECT username
  FROM dbo.fnQAAuto_SplitUsers(@user_id)

SELECT * FROM #users

--*************************************************************************************************
-- Create temp tables to store the search results
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProtectedUsers') IS NOT NULL
	BEGIN DROP TABLE #ProtectedUsers END

CREATE TABLE #ProtectedUsers
      (protected_user_id VARCHAR(256))

INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('base')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('BaseData')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('BASELOAD')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('build_process')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('FINAL')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('healthadmin')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('HealthAdmn')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('HLTHMAINT')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('hlthsetup')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('LOADER')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('MIDimSQL')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('QASetUpScript')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('sa')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('SCHJOB')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('script')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('ScriptMOD')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('SecDeposit')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('setup')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('SQL')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('system')
INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('')

SELECT @err_num = 0
      ,@err_msg = ''

IF EXISTS(SELECT TOP 1 protected_user_id FROM #ProtectedUsers JOIN #users ON protected_user_id = user_id) SET @err_num = 100
IF EXISTS(SELECT TOP 1 user_id FROM #users WHERE LEFT(user_ID, 4) = 'VHS-') SET @err_num = 100
IF EXISTS(SELECT TOP 1 user_id FROM #users WHERE LEFT(user_ID, 4) = 'HIP-')	SET @err_num = 100
IF EXISTS(SELECT TOP 1 user_id FROM #users WHERE LEFT(user_ID, 3) = 'SFC')	SET @err_num = 100

IF @err_num <> 0
	BEGIN
		IF CHARINDEX(';',@user_id,1) > 0
			BEGIN
				SELECT @err_msg = 'There is at least one user ID, in the list of user IDs, that is considered protected and cannot be deleted. Operation aborted.'
					  ,@err_num = 100
			END
		ELSE
			BEGIN
				SELECT @err_msg = 'User ID, ' + @user_id + ', is a protected user ID and cannot be deleted using this utility. Operation aborted.'
					  ,@err_num = 100
			END
	END 

IF @err_num <> 0 GOTO DELETE_ERROR

--*************************************************************************************************
-- If the username passes all validation then call the delete stored procedure
--*************************************************************************************************
DECLARE users_to_create CURSOR FOR
 SELECT user_id
   FROM #users

OPEN users_to_create FETCH NEXT FROM users_to_create INTO @user_id

WHILE @@FETCH_STATUS = 0
    BEGIN

		PRINT @user_id
		EXEC spQAAuto_DeleteTestData @user_id,@status OUTPUT, @message OUTPUT, 1, @log_id

		IF @status <> 0
			BEGIN

				PRINT '     Error: ' + CONVERT(VARCHAR(20), @status)
				PRINT '     Error Message: ' + @message

				EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Error', @status, @message
			END

		FETCH NEXT FROM users_to_create INTO @user_id
	END

CLOSE users_to_create
DEALLOCATE users_to_create

--*************************************************************************************************
-- Error processing
--*************************************************************************************************
DELETE_ERROR:

IF @err_num <> 0
	BEGIN

		PRINT '     Error: ' + CONVERT(VARCHAR(20), @err_num)
		PRINT '     Error Message: ' + @err_msg

		EXEC dbo.spDDAuto_LogEvent @log_id, 'N/A', 0, 'Error', @err_num, @err_msg
	END

--*************************************************************************************************
-- Finish the logging and send email
--*************************************************************************************************
UPDATE DDLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

-- Now send an email with the results
EXEC spDDAuto_EmailResults @log_id, @email_address

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProtectedUsers') IS NOT NULL
	BEGIN DROP TABLE #ProtectedUsers END

END
GO


