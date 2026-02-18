/**************************************************************************************************  
Name:       spFDAuto_LogCreate
Purpose:    Used to log details for the Configurator  
  
Date        User            Change  
---------------------------------------------------------------------------------------------  
08/04/2023	DK    Original procedure  
---------------------------------------------------------------------------------------------  
  
***************************************************************************************************  
DECLARE @log_id INT  
EXEC spFDAuto_LogCreate 'Bright%', 'dkunkle@evolenthealth.com', 745, 'Configurator', @log_id OUTPUT  
SELECT @log_id  
***************************************************************************************************/  
CREATE OR ALTER PROCEDURE dbo.spFDAuto_LogCreate  
      (@server_name			VARCHAR(200) 
	  ,@test_case			VARCHAR(200)
      ,@email_address		VARCHAR(8000)  
      ,@build_id			INT  
      ,@job_name			VARCHAR(200)  
      ,@log_id				INT				OUTPUT)  
AS  
BEGIN  
  
--*************************************************************************************************  
-- Begin logging data  
--*************************************************************************************************  
INSERT INTO FDLog  
      (user_id  
      ,server_name
	  ,test_case
      ,start_time  
      ,email_address  
      ,build_id  
      ,job_name)  
SELECT SYSTEM_USER  
      ,@server_name
	  ,@test_case
      ,GETDATE()  
      ,@email_address  
      ,@build_id  
      ,@job_name  
  
SELECT @log_id = @@IDENTITY  
  
END  
GO