/**************************************************************************************************
Name:       spFCAuto_DeleteCustomSecondaryDemographics
Purpose:    Delete data for Secondary Demographics

Date        User            Change
---------------------------------------------------------------------------------------------
04/05/2023	DK				Original procedure
06/02/2023	DK				Change delete to generic delete of files
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomSecondaryDemographics @test_case_name = 'EB-IMM-Member-SearchMemberUpdateDetails', @server_name = 'aldqadbqr06'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_DeleteCustomSecondaryDemographics
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
	   ,@vendor				VARCHAR(100)
	   ,@file_pattern		VARCHAR(1000)
	   ,@log_server			VARCHAR(200)
	   ,@data_server		VARCHAR(200)

SELECT @err_num		= 0
	  ,@err_msg		= 'Success'
	  ,@log_server	= @server_name
	  ,@data_server = 'ipe1qa-hpss-001.database.windows.net'

--*************************************************************************************************
-- Get a list of all the files that need to be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#testcases') IS NOT NULL
	BEGIN DROP TABLE #testcases END

CREATE TABLE #testcases
      (TCID			VARCHAR(200)
	  ,vendor		VARCHAR(1000)
	  ,date_stamp	VARCHAR(100)
	  ,filename		VARCHAR(200))

INSERT INTO #testcases
      (TCID
	  ,vendor
	  ,date_stamp
	  ,filename)
SELECT SD.TCID
	  ,SD.Vendor
	  ,SD.FileDate
	  ,SD.Vendor + '_MemDemoD_' + SD.FileDate + '.txt'
  FROM dbo.TD_SecondaryDemographics	SD
 WHERE TCID LIKE @test_case_name
   AND SD.ActiveTestCase = 'A'

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

	 DECLARE filenames_to_delete CURSOR FOR
	  SELECT filename
	        ,vendor
        FROM #testcases

	OPEN filenames_to_delete FETCH NEXT FROM filenames_to_delete INTO @filename, @vendor

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SELECT @file_pattern = @vendor + '_MemDemoD_%'
			SELECT @cmd = '"C:\PowerShell\Delete-IdentifiMemberFiles.ps1" '
			SELECT @cmd = @cmd + '-Server "'    + ISNULL(@data_server, '')    + '" '
			SELECT @cmd = @cmd + '-LogServer "' + ISNULL(@log_server, '')     + '" '
			SELECT @cmd = @cmd + '-Filename "'  + ISNULL(@file_pattern, '')   + '" '
			SELECT @cmd = @cmd + '-ClientKey "' + ISNULL(@enterprise_id, '')  + '" '
			SELECT @cmd = @cmd + '-Database "'  + ISNULL(@database_name, '')  + '" '
			SELECT @cmd = @cmd + '-UserId "'    + ISNULL(@user_id, '')        + '" '
			SELECT @cmd = @cmd + '-Password "'  + ISNULL(@password, '')       + '" '
			SELECT @cmd = @cmd + '-TypeId "'    + ISNULL(CONVERT(VARCHAR(10), @type_id), 0) + '" '

			SELECT @cmd = 'powershell.exe -ExecutionPolicy "ByPass" -File ' + @cmd
			PRINT @cmd
			INSERT INTO #cmd_results
				EXEC master.sys.xp_cmdshell @cmd

			SELECT * FROM #cmd_results
			FETCH NEXT FROM filenames_to_delete INTO @filename, @vendor
		END

	CLOSE filenames_to_delete
	DEALLOCATE filenames_to_delete

END TRY
BEGIN CATCH
	 
	SELECT @err_num = 100
	      ,@err_msg = @filename + ' could not be deleted due to: ' + ERROR_MESSAGE()

END CATCH

END
GO