/**************************************************************************************************
Name:       spPortal_DeleteRecordLogDetail
Purpose:    Remove records in the Mail related tables in the portal database

Date        User            Change
---------------------------------------------------------------------------------------------
08/24/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_DeleteRecordLogDetail 999, 'Mail', 'MAIL', '2'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_DeleteRecordLogDetail
      (@log_id			INT	
	  ,@category		VARCHAR(20)
	  ,@delete_type		VARCHAR(100)
	  ,@table_name		VARCHAR(250)
	  ,@records			INT
	  ,@err_num			INT				= 0
	  ,@err_msg			VARCHAR(8000)	= '')
AS
BEGIN
SET NOCOUNT ON

INSERT INTO dbo.DRLogDetail
      (log_id
	  ,date_time
	  ,category
	  ,delete_type
	  ,table_name
	  ,records
	  ,err_num
	  ,err_msg)
SELECT @log_id
	  ,GETDATE()
	  ,@category
	  ,@delete_type
	  ,@table_name
	  ,ISNULL(@records, 0)
	  ,@err_num
	  ,@err_msg

END 
GO