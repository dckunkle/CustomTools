/**************************************************************************************************
Name:       spConfig_AddData
Purpose:    Based on the method and config_id, return the data from the appropriate table that will 
            be loaded to Core

Date        User            Change
---------------------------------------------------------------------------------------------
02/26/2022	DK				Original procedure

---------------------------------------------------------------------------------------------
DECLARE @err_num INT, @err_msg VARCHAR(4000)
EXEC spConfig_AddData 'BenefitStrategy','prBenefitStrategyAdd', 21, 'Bright-BS-CO-%', 'dkunkle', @err_num OUTPUT, @err_msg OUTPUT
SELECT @err_num, @err_msg
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_AddData
     (@method			VARCHAR(100)
	 ,@add_procedure	VARCHAR(200)
	 ,@parameters		INT
	 ,@config_id		VARCHAR(500)
	 ,@user_id			VARCHAR(100)
	 ,@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(4000)	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Set some initial values for some variables
--*************************************************************************************************
DECLARE @table_name VARCHAR(200)
       ,@sql		VARCHAR(8000)

SELECT @err_num = 0
      ,@err_msg = 'Success'

--*************************************************************************************************
-- Verify that the load option has been configured for this screen, exit with an error if not
--*************************************************************************************************
SELECT @sql					= ISNULL(AD.SQL, '')
  FROM cfg.ActionAdd		AD
 WHERE AD.MethodName		= @method
   AND AD.ParameterCount	= @parameters
   AND AD.CoreProcedure		= @add_procedure


IF ISNULL(@sql, '') = ''
	BEGIN

		SELECT @err_num = 2001
		      ,@err_msg = 'CFG - The SQL to gather data for the combination of parameters and method (' + CONVERT(VARCHAR(10), @parameters) + ', ' + @method + ') has not been configured'
		GOTO CLEANUP

	END

SELECT @table_name = 'data.' + @table_name

--*************************************************************************************************
-- Assuming there is a good SQL query, replace the config ID and execute it
--*************************************************************************************************
SELECT @sql = REPLACE(@sql, '~ConfigID~', @config_id)
SELECT @sql = REPLACE(@sql, '~UserID~', @user_id)

EXEC(@sql)

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO