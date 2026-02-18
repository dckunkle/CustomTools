/**************************************************************************************************  
Name:       spConfig_LogEvent  
Purpose:    Used to log details for the Configurator  
  
Date        User            Change  
---------------------------------------------------------------------------------------------  
02/26/2022 DK    Original procedure  
---------------------------------------------------------------------------------------------  
  
***************************************************************************************************  
DECLARE @log_id INT  
EXEC spConfig_LogEvent 'Bright%', 'dkunkle@evolenthealth.com', 745, 'Configurator', @log_id OUTPUT  
SELECT @log_id  
***************************************************************************************************/  
CREATE OR ALTER PROCEDURE dbo.spConfig_LogEvent  
      (@target_system	VARCHAR(100)  
      ,@target_database VARCHAR(100)  
      ,@config_id		VARCHAR(500)  
      ,@email_address	VARCHAR(8000)  
      ,@build_id		INT  
      ,@job_name		VARCHAR(200)  
      ,@log_id			INT				OUTPUT)  
AS  
BEGIN  
  
--*************************************************************************************************  
-- Begin logging data  
--*************************************************************************************************  
INSERT INTO log.Config  
      (target_system  
      ,target_database  
      ,user_id  
      ,config_id  
      ,start_time  
      ,email_address  
      ,build_id  
      ,job_name)  
SELECT @target_system  
      ,@target_database  
      ,SYSTEM_USER  
      ,@config_id  
      ,GETDATE()  
      ,@email_address  
      ,@build_id  
      ,@job_name  
  
SELECT @log_id = @@IDENTITY  
  
END  