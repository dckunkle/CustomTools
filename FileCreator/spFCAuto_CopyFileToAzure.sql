/**************************************************************************************************
Name:       spFCAuto_CopyFileToAzure
Purpose:    Used to create a SQL Agent job that will run a Powershell script on the wqaapehjsauto02
            server to copy the file to Azure

Date        User            Change
---------------------------------------------------------------------------------------------
05/31/2023	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_CopyFileToAzure 'H:\Azure\RiskScores\FC_RiskScores_20230531.txt'
                             ,'data-sources'
							 ,'RiskScores/COREQR09/Staging/FC_RiskScores_20230531.txt'
							 ,'hpsqaidmstoragetrans02'
							 ,'/iYUOLgwwAzLbglBTpILMLhZa7N3OVeyh6s3ZpQrxUZJimjfNizDFN6Qj+pHUrN5xycQCP3vs417H9w3qSIzxA=='

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_CopyFileToAzure
     (@filename				VARCHAR(200)
	 ,@container			VARCHAR(200)
	 ,@blob					VARCHAR(400)
	 ,@storage_account		VARCHAR(200)
	 ,@storage_key			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @job_name			NVARCHAR(200)
       ,@job_id				BINARY(16)
	   ,@return_code		INT				= 0

	   ,@destination		VARCHAR(4000)
	   ,@command			VARCHAR(4000)

--***************************************************************************************************
-- Create job name and job
--***************************************************************************************************
SELECT @job_name = N'FC_MoveFileToAzure_' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 121), '-', ''), ' ', ''), ':', ''), '.','')

EXEC @return_code = msdb.dbo.sp_add_job @job_name				= @job_name
                                       ,@enabled				= 1
									   ,@notify_level_eventlog	= 0
									   ,@notify_level_email		= 0
									   ,@notify_level_netsend	= 0
									   ,@notify_level_page		= 0
									   ,@delete_level			= 0
									   ,@description			= N'Copy file to Azure'
									   ,@category_name			= N'[Uncategorized (Local)]' 
									   ,@owner_login_name		= N'CHICAGO\dkunkle'
									   ,@job_id					= @job_id OUTPUT

--***************************************************************************************************
-- Create job step 1
--***************************************************************************************************
SELECT @destination = 'Microsoft.PowerShell.Core\FileSystem::\\wqaapehjsauto02\' + SUBSTRING(@filename, 4, 99999)
SELECT @command = 'Copy-Item "Microsoft.PowerShell.Core\FileSystem::' + @filename + '" -Destination "' + @destination + '" -Force'

EXEC @return_code = msdb.dbo.sp_add_jobstep @job_id					= @job_id
                                           ,@step_name				= N'Copy File to Jenkins'
										   ,@step_id				= 1
										   ,@cmdexec_success_code	= 0
										   ,@on_success_action		= 3
										   ,@on_success_step_id		= 0
										   ,@on_fail_action			= 2
										   ,@on_fail_step_id		= 0
										   ,@retry_attempts			= 0
										   ,@retry_interval			= 0
										   ,@os_run_priority		= 0
										   ,@subsystem				= N'PowerShell'
										   ,@command				= @command
										   ,@database_name			= N'master'
										   ,@flags					= 0
--***************************************************************************************************
-- Create job step 2
--***************************************************************************************************
SELECT @destination = 'E:\' + SUBSTRING(@filename, 4, 99999)
SELECT @command = 'Invoke-Command -ComputerName wqaapehjsauto02 -ScriptBlock {\\wqaapehjsauto02\PowerShell\Move-FileToAzureStorage.ps1 -Filename ' + @destination + ' -Container ' + @container + ' -Blob ' + @blob + ' -StorageAccount ' + @storage_account + ' -StorageKey ' + @storage_key + '}'

EXEC @return_code = msdb.dbo.sp_add_jobstep @job_id					= @job_id
                                           ,@step_name				= N'Load File to Azure Blob Storage'
										   ,@step_id				= 2
										   ,@cmdexec_success_code	= 0
										   ,@on_success_action		= 1
										   ,@on_success_step_id		= 0
										   ,@on_fail_action			= 2
										   ,@on_fail_step_id		= 0
										   ,@retry_attempts			= 0
										   ,@retry_interval			= 0
										   ,@os_run_priority		= 0
										   ,@subsystem				= N'PowerShell'
										   ,@command				= @command
										   ,@database_name			= N'master'
										   ,@flags					= 0
--***************************************************************************************************
-- Setup job to run on the local server
--***************************************************************************************************
EXEC @return_code = msdb.dbo.sp_update_job @job_id			= @job_id
                                          ,@start_step_id	= 1

EXEC @return_code = msdb.dbo.sp_add_jobserver @job_id		= @job_id
                                             ,@server_name	= N'(local)'
--***************************************************************************************************
-- Run the job
--***************************************************************************************************
EXEC @return_code = msdb.dbo.sp_start_job @job_id = @job_id

END
GO