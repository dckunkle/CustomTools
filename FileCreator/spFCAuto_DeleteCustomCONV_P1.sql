IF OBJECT_ID('dbo.spFCAuto_DeleteCustomCONV_P1') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustomCONV_P1 AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustomCONV_P1
Purpose:    Custom delete for the Member Adjustment Amount file. THe same user ID is used for 
            Group Conversion and deleting by the user ID will delete data in the Context_Relation
			table that breaks any groups that have been loaded by Group Conversion

Date        User            Change
---------------------------------------------------------------------------------------------
11/11/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomCONV_P1
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustomCONV_P1
     (@err_num		INT				= 0		OUTPUT
	 ,@err_msg		VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id		INT)
AS
BEGIN

SET NOCOUNT ON

DECLARE @record_count	INT				= 0
       ,@table_name		VARCHAR(100)	= 'Member_Adjustment_Amounts'

SELECT @err_num = 0
	  ,@err_msg	 = 'Success'


BEGIN TRY

	DELETE 
	  FROM Member_Adjustment_Amounts
	 WHERE user_id_created = 'CONV_P1'

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