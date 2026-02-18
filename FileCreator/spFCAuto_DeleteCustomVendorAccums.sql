/**************************************************************************************************
Name:       spFCAuto_DeleteCustomVendorAccums
Purpose:    Delete data that has been added from the Vendor Accums import

Date        User            Change
---------------------------------------------------------------------------------------------
06/27/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomVendorAccums 'Dev-Lockbox'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_DeleteCustomVendorAccums
     (@test_case_name	VARCHAR(200)	
	 ,@err_num			INT				= 0		OUTPUT
	 ,@err_msg			VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id			INT				= 99)

AS
BEGIN

SET NOCOUNT ON

DECLARE @record_count	INT				= 0
       ,@table_name		VARCHAR(100)	= 'Member_Clinical_History'
	   ,@file_name		VARCHAR(200)	= 'Vendor Accumulation File Name: FC_%'

SELECT @err_num = 0
	  ,@err_msg	 = 'Success'


BEGIN TRY

	DELETE MCH
	  FROM Member_Clinical_History		MCH
	 WHERE MCH.user_id_created			= 'Vendor_Accumulation_Load'
	   AND MCH.Comment					LIKE @file_name

	 SET @record_count = @@ROWCOUNT

	 IF @record_count > 0 
		BEGIN
			EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
			EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count
		END

END TRY
BEGIN CATCH
	
	SELECT @err_num = 100
	      ,@err_msg = @table_name + ' no records deleted due to: ' + ERROR_MESSAGE()

	EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Error', @err_num,@err_msg

END CATCH

END
GO