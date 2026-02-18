/**************************************************************************************************  
Name:       spDDAuto_CreateLog 
Purpose:    Used to log details for the Configurator  
  
Date        User            Change  
---------------------------------------------------------------------------------------------  
02/26/2022 DK    Original procedure  
---------------------------------------------------------------------------------------------  
  
***************************************************************************************************  
DECLARE @log_id INT  
EXEC spDDAuto_CreateLog 'Bright%', 'dkunkle@evolenthealth.com', 745, 'Configurator', @log_id OUTPUT  
SELECT @log_id  
***************************************************************************************************/  
CREATE OR ALTER PROCEDURE dbo.spDDAuto_CreateLog  
      (@entity_to_delete	VARCHAR(500) 
	  ,@entity_type			VARCHAR(100)
      ,@email_address		VARCHAR(8000)  
      ,@build_id			INT  
      ,@job_name			VARCHAR(200)  
      ,@log_id				INT				OUTPUT)  
AS  
BEGIN  
  
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
SELECT SYSTEM_USER  
      ,@entity_to_delete
	  ,@entity_type
      ,GETDATE()  
      ,@email_address  
      ,@build_id  
      ,@job_name  
  
SELECT @log_id = @@IDENTITY  
  
END  
GO