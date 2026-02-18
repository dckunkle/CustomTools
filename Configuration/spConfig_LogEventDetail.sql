/**************************************************************************************************
Name:       spConfig_LogEventDetail
Purpose:    Used to log details for the Configurator

Date        User            Change
---------------------------------------------------------------------------------------------
02/26/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_LogEventDetail 20, 'Bright-CO-001', 'BenefitStrategy', 1, '31070CO001004103', 'Peak Gold $0 Ded + ADV Rx Copay Direct', '', '', 0, 'Success'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_LogEventDetail
     (@log_id		INT
	 ,@config_id	VARCHAR(200)
	 ,@method		VARCHAR(100)
	 ,@record_id	INT				= 0
	 ,@key_data_1	VARCHAR(100)
	 ,@key_data_2	VARCHAR(100)
	 ,@key_data_3	VARCHAR(100)
	 ,@status		VARCHAR(10)
	 ,@err_num		INT
	 ,@err_msg		VARCHAR(200))
AS
BEGIN

SET ARITHABORT OFF 

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO log.ConfigDetail
      (log_id
	  ,date_time
	  ,record_id
	  ,config_id
	  ,method
	  ,key_data_1
	  ,key_data_2
	  ,key_data_3
	  ,status
	  ,err_num
	  ,err_msg)
SELECT @log_id
      ,GETDATE()
	  ,ISNULL(@record_id, 0)
	  ,@config_id
	  ,@method
	  ,@key_data_1
	  ,@key_data_2
	  ,@key_data_3
	  ,CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
	  ,@err_num
	  ,@err_msg

END
GO