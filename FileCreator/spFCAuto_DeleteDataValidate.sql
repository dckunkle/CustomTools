IF OBJECT_ID('dbo.spFCAuto_DeleteDataValidate') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteDataValidate AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteDataValidate
Purpose:    Delete Automation test data given the user_id

Date        User            Change
---------------------------------------------------------------------------------------------
07/10/2020	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteDataValidate
      (@user_id			VARCHAR(100)
	  ,@err_num			INT				= 0		OUTPUT
	  ,@err_msg			VARCHAR(8000)	= ''	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @server_name		VARCHAR(128)
       ,@protected_user		BIT				= 0

SELECT @err_num	= 0
      ,@err_msg	= 'User ID, ' + @user_id + ', successfully validated.'

--*************************************************************************************************
-- Create a table of the users that should never be deleted
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
--INSERT INTO #ProtectedUsers(protected_user_id) VALUES ('HLTHMAINT')

IF EXISTS(SELECT TOP 1 protected_user_id FROM #ProtectedUsers WHERE protected_user_id = @user_id) SET @protected_user = 1
IF LEFT(@user_ID, 4) = 'VHS-'	SET @protected_user = 1
IF LEFT(@user_ID, 4) = 'HIP-'	SET @protected_user = 1
IF LEFT(@user_ID, 3) = 'SFC'	SET @protected_user = 1

IF @protected_user = 1 
	BEGIN
		SELECT @err_num = 100
		      ,@err_msg =  'User ID, ' + @user_id + ', is a protected user ID and cannot be deleted. Operation aborted.'
	END


IF @err_num <> 0 GOTO DELETE_ERROR

--*******************************************************************************************************
-- Build list of servers this can be run on. DO NOT allow to run on any other servers
--*******************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ValidEnvironments') IS NOT NULL
	BEGIN DROP TABLE #ValidEnvironments END

CREATE TABLE #ValidEnvironments
      (ServerName	VARCHAR(256))

-- QR Environments
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr01')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr02')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr03')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr04')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr05')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqadbqr06')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqrdb07')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqrdb08')
INSERT INTO #ValidEnvironments(ServerName) VALUES ('aldqrdb09')

SELECT @server_name = @@SERVERNAME

IF NOT EXISTS(SELECT ServerName FROM #ValidEnvironments WHERE ServerName = @server_name) 
	BEGIN 
		SELECT @err_num = 101 
		      ,@err_msg = 'Deleting data for User ID, ' + @user_id + ', is not supported on this server, ' + @server_name + '. Operation aborted.'
	END
		
IF @err_num <> 0 GOTO DELETE_ERROR

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
DELETE_ERROR:

IF OBJECT_ID('tempdb.dbo.#ProtectedUsers') IS NOT NULL
	BEGIN DROP TABLE #ProtectedUsers END

IF OBJECT_ID('tempdb.dbo.#ValidEnvironments') IS NOT NULL
	BEGIN DROP TABLE #ValidEnvironments END

END
GO


