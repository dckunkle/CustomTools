/**************************************************************************************************
Name:       spPortal_MaintainData
Purpose:    Top level stored procedure to maintain DELETED portal data

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_MaintainData 1200
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_MaintainData
      (@days		INT	= 30)
AS
BEGIN
SET NOCOUNT ON

DECLARE @log_id			INT
	   ,@cutoff_date	DATE
	   
--*************************************************************************************************
-- Calculate the cutoff date
--*************************************************************************************************
SELECT @cutoff_date = DATEADD(day, -@days, GETDATE())

--*************************************************************************************************
-- Create the log
--*************************************************************************************************
INSERT INTO dbo.DRLog
      (cutoff_date
	  ,start_time
	  ,email_address)
SELECT @cutoff_date
      ,GETDATE()
	  ,'dkunkle@evolenthealth.com'

SELECT @log_id = SCOPE_IDENTITY()

--*************************************************************************************************
-- Populate the deletes table with tables to delete
--*************************************************************************************************
EXEC spPortal_MaintainMiscData				@days, @log_id
EXEC spPortal_MaintainHealthCoverageData	@days, @log_id
EXEC spPortal_MaintainPolicyBenefitData		@days, @log_id
EXEC spPortal_MaintainCommissionData		@days, @log_id
EXEC spPortal_MaintainServiceLineData		@days, @log_id
EXEC spPortal_MaintainServicePaymentData	@days, @log_id
EXEC spPortal_MaintainClaimPaymentData		@days, @log_id
EXEC spPortal_MaintainClaimData				@days, @log_id
EXEC spPortal_MaintainFileDetailData		@days, @log_id
EXEC spPortal_MaintainPolicyData			@days, @log_id
EXEC spPortal_MaintainBrokerData			@days, @log_id
EXEC spPortal_MaintainEligibilityData		@days, @log_id
EXEC spPortal_MaintainInvoiceData			@days, @log_id
EXEC spPortal_MaintainMemberData			@days, @log_id
EXEC spPortal_MaintainEmployeeData			@days, @log_id
EXEC spPortal_MaintainMailData				@days, @log_id
EXEC spPortal_MaintainLocationData			@days, @log_id
EXEC spPortal_MaintainHistoricalData		@days, @log_id

--*************************************************************************************************
-- Complete the log
--*************************************************************************************************
UPDATE dbo.DRLog
   SET end_time	= GETDATE()
 WHERE log_id	= @log_id

END
GO