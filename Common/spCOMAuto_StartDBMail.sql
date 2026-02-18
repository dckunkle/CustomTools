IF OBJECT_ID('dbo.spCOMAuto_StartDBMail') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spCOMAuto_StartDBMail AS SELECT 1')
GO
/**************************************************************************************************
Name:       spCOMAuto_StartDBMail
Purpose:    Used to make sure DBMail is started on the server

Date        User            Change
---------------------------------------------------------------------------------------------
06/09/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spCOMAuto_StartDBMail
***************************************************************************************************/
ALTER PROCEDURE dbo.spCOMAuto_StartDBMail
AS
BEGIN

SET NOCOUNT ON

DECLARE @status				NVARCHAR(20)
       ,@restarted			BIT				= 0
	   ,@restart_attempts	INT				= 0

--*************************************************************************************************
-- Create the table to get the status of DBMail
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DBMailStatus') IS NOT NULL
	DROP TABLE #DBMailStatus
	
CREATE TABLE #DBMailStatus
      (mail_status		NVARCHAR(20))

--*************************************************************************************************
-- Determine the status of DBMail and take the appropriate action
--*************************************************************************************************
BEGIN TRY

	SET @restart_attempts = 0

	WHILE ((@restart_attempts <3) AND (@restarted = 0))

		BEGIN

			-- Get the status of DBMail
			INSERT INTO #DBMailStatus
			EXEC msdb.dbo.sysmail_help_status_sp

			SELECT @status = mail_status
			  FROM #DBMailStatus

			IF @status = 'STARTED'
				BEGIN
					SET @restarted = 1
				END

			IF @status = 'STOPPED'
				BEGIN

					-- Try to restart DBMail and wait 10 seconds
					SET @restart_attempts = @restart_attempts + 1
					EXEC msdb.dbo.sysmail_start_sp
					WAITFOR DELAY '00:00:10'
				END
					
		END
END TRY
BEGIN CATCH

	
END CATCH

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#DBMailStatus') IS NOT NULL
	DROP TABLE #DBMailStatus
END
GO