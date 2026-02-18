/**************************************************************************************************
Name:       spConfig_LoadEntityDetails
Purpose:    Return the details for a given entity

Date        User            Change
---------------------------------------------------------------------------------------------
03/09/2022	DK				Original procedure

---------------------------------------------------------------------------------------------
DECLARE @err_num INT, @err_msg VARCHAR(4000), @method_name VARCHAR(100), @core_entity VARCHAR(100), @screen_gid INT, @table_name VARCHAR(100)
EXEC spConfig_LoadEntityDetails 'Benefit Strategy',@method_name OUTPUT, @core_entity OUTPUT, @screen_gid OUTPUT, @table_name OUTPUT, @err_num OUTPUT, @err_msg OUTPUT
SELECT @err_num, @err_msg, @method_name method, @core_entity core_entity, @screen_gid screen_gid, @table_name table_name
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_LoadEntityDetails
     (@entity_name		VARCHAR(100)
	 ,@method_name		VARCHAR(100)	OUTPUT
	 ,@core_entity		VARCHAR(100)	OUTPUT
	 ,@screen_gid		INT				OUTPUT
	 ,@table_name		VARCHAR(100)	OUTPUT
	 ,@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(4000)	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Set some initial values for some variables
--*************************************************************************************************
SELECT @err_num = 0
      ,@err_msg = 'Success'

--*************************************************************************************************
-- Verify that the load option has been configured for this screen, exit with an error if not
--*************************************************************************************************
IF EXISTS(SELECT TOP 1 * 
            FROM cfg.Catalog
		   WHERE EntityName = @entity_name)
	BEGIN
		
		SELECT @method_name		= C.MethodName
		      ,@core_entity		= C.CoreEntity
			  ,@screen_gid		= C.CoreScreen
			  ,@table_name		= C.TableName
		  FROM cfg.Catalog		C
		 WHERE C.EntityName		= @entity_name

	END
ELSE
	BEGIN

		SELECT @method_name		= ''
			  ,@core_entity		= ''
			  ,@screen_gid		= 0
			  ,@table_name		= ''
			  ,@err_num			= 4000
			  ,@err_msg			= 'The entity, ' + @entity_name + ', was not found in the cfg.Catalog table and may not be set up.'

	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO