/**************************************************************************************************
Name:       spFCAuto_DeleteCustomRiskScores
Purpose:    Delete data for Risk Scores

Date        User            Change
---------------------------------------------------------------------------------------------
05/30/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomRiskScores @test_case_name = 'EB-Risk%', @server_name = 'aldqadbqr06'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_DeleteCustomRiskScores
     (@test_case_name	VARCHAR(200)	
	 ,@err_num			INT				= 0		OUTPUT
	 ,@err_msg			VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id			INT				= 99
	 ,@server_name		VARCHAR(200)	= ''
	 ,@log_id			INT				= 0)

AS
BEGIN

SET NOCOUNT ON

DECLARE @layer				VARCHAR(100)
	   ,@enterprise_id		VARCHAR(100)
	   ,@database_name		VARCHAR(100)
	   ,@password			VARCHAR(100)
	   ,@user_id			VARCHAR(100)
	   ,@cmd				VARCHAR(8000)
	   ,@filename			VARCHAR(200)

SELECT @err_num = 0
	  ,@err_msg	 = 'Success'

--*************************************************************************************************
-- Create the table to collect the results of the command
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
	DROP TABLE #cmd_results

CREATE TABLE #cmd_results
		(results	VARCHAR(8000)
		,result_id	INT				IDENTITY(1,1))

--*************************************************************************************************
-- Get other related details
--*************************************************************************************************
SELECT @layer					= S.Layer
  FROM SystemAudit.dbo.Server	S
 WHERE S.instance_name			= @server_name

SELECT @enterprise_id			= EL.EnterpriseID
  FROM APIAutomation.fw.EnterpriseIDLookup	EL
 WHERE EL.ServerName			= @server_name

SELECT @filename 				= C.Filename
  FROM fw.Catalog				C
 WHERE C.method_name			= 'RiskScores'

SELECT @filename = @filename + '%'

SELECT @password = CASE WHEN @layer = 'QA'         THEN 'HZB4XYxgBVPAxXoc5N6o' 
                        WHEN @layer = 'Automation' THEN 'QcjoFfdtimmKHP4by4HQ'
						WHEN @layer = 'Regression' THEN 'rguvlGlfHnFbwbWYTbh1'
						ELSE ''
					END
SELECT @user_id	= 'md_readwrite_user'

SELECT @database_name = CASE WHEN @layer = 'QA'         THEN 'mdsd-qa-001' 
							 WHEN @layer = 'Automation' THEN 'mdsd-auto-001'
							 WHEN @layer = 'Regression' THEN 'mdsd-reg-001'
							 ELSE ''
						 END

--*************************************************************************************************
-- Loop through the file(s) deleting each one
--*************************************************************************************************
BEGIN TRY

	SELECT @cmd = '"C:\PowerShell\Delete-RiskScoresFiles.ps1" '
	SELECT @cmd = @cmd + '-Server "'   + ISNULL(@server_name, '') + '" '
	SELECT @cmd = @cmd + '-Filename "'   + ISNULL(@filename, '') + '" '
	SELECT @cmd = @cmd + '-ClientKey "'   + ISNULL(@enterprise_id, '') + '" '
	SELECT @cmd = @cmd + '-Database "' + ISNULL(@database_name, '') + '" '
	SELECT @cmd = @cmd + '-UserId "'   + ISNULL(@user_id, '') + '" '
	SELECT @cmd = @cmd + '-Password "'  + ISNULL(@password, '') + '" '
	SELECT @cmd = @cmd + '-LogId "'  + ISNULL(CONVERT(VARCHAR(10), @log_id), 0) + '" '

	SELECT @cmd = 'powershell.exe -ExecutionPolicy "ByPass" -File ' + @cmd
	SELECT  @cmd
	INSERT INTO #cmd_results
		EXEC master.sys.xp_cmdshell @cmd
	SELECT * FROM #cmd_results

END TRY
BEGIN CATCH
	 
	SELECT @err_num = 100
	      ,@err_msg = @filename + ' could not be deleted due to: ' + ERROR_MESSAGE()

END CATCH

END
GO