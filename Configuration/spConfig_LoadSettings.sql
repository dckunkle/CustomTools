/**************************************************************************************************
Name:       spConfig_LoadSettings
Purpose:    Validate that the combination of screen and entity have been configured before proceeding

Date        User            Change
---------------------------------------------------------------------------------------------
12/23/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @err_num INT			= 0
       ,@err_msg VARCHAR(2000)	= ''

EXEC spConfig_LoadSettings 'TOB_List', 1, @err_num OUTPUT, @err_msg OUTPUT

SELECT @err_num, @err_msg

***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_LoadSettings
     (@method				VARCHAR(100)
	 ,@screen_fields		INT
	 ,@load_procedure		VARCHAR(200)
	 ,@parameter_count		INT				OUTPUT
	 ,@populate_sql			VARCHAR(8000)	OUTPUT
	 ,@load_id				INT				OUTPUT
	 ,@err_num				INT				OUTPUT
	 ,@err_msg				VARCHAR(4000)	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

SELECT @err_num = 0
      ,@err_msg = 'Success'

--*************************************************************************************************
-- Set up some variables for later use
--*************************************************************************************************
DECLARE @destination_table			VARCHAR(128)	= ''
	   ,@sql						VARCHAR(4000)	= ''

--*************************************************************************************************
-- Verify that the load option has been configured for this screen, exit with an error if not
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 AC.MethodName
                FROM cfg.ActionCatalog		AC
			   WHERE AC.MethodName			= @method
				 AND AC.Action				= 'Load')

	BEGIN

		SELECT @err_num = 1001
		      ,@err_msg = 'CFG - The load action has not been configured for this method, ' + @method 
		GOTO CLEANUP

	END

--*************************************************************************************************
-- Verify that the load function supports this combination of proc and parameters
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 AL.LoadID
			    FROM cfg.ActionLoad		AL
			   WHERE AL.MethodName		= @method
			     AND AL.CoreProcedure	= @load_procedure
			     AND AL.FieldCount	    = @screen_fields)

	BEGIN

		SELECT @err_num = 1002
		      ,@err_msg = 'CFG - The load action for ' + @method + ' does not support the combination of parameters and stored procedure (' + CONVERT(VARCHAR(10), @screen_fields) + ', ' + @load_procedure + ')'
		GOTO CLEANUP

	END	

--*************************************************************************************************
-- Verify that a SQL query has been defined to associate the existing data with the populate SP
--*************************************************************************************************
SELECT @sql					= AL.PopulateSQL
  FROM cfg.ActionLoad		AL
 WHERE AL.MethodName		= @method
   AND AL.CoreProcedure		= @load_procedure
   AND AL.FieldCount		= @screen_fields

IF ISNULL(@sql, '') = ''
	BEGIN
		
		SELECT @err_num = 1003
		      ,@err_msg = 'CFG - The SQL query for the load action has not configured for ' + @method
		GOTO CLEANUP

	END

--*************************************************************************************************
-- If all the validation passes gather the settings to return
--*************************************************************************************************
SELECT @parameter_count		= AL.ParameterCount
      ,@populate_sql		= AL.PopulateSQL
	  ,@load_id				= AL.LoadID
  FROM cfg.ActionLoad		AL
 WHERE AL.MethodName		= @method
   AND AL.CoreProcedure		= @load_procedure
   AND AL.FieldCount		= @screen_fields

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO