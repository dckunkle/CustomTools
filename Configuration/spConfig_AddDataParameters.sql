/**************************************************************************************************
Name:       spConfig_AddDataParameters
Purpose:    Based on the method and parameters, return the parameters that are needed to make the
            stored procedure call

Date        User            Change
---------------------------------------------------------------------------------------------
02/26/2022	DK				Original procedure

---------------------------------------------------------------------------------------------
DECLARE @add_id INT, @err_num INT, @err_msg VARCHAR(4000)
EXEC spConfig_AddDataParameters 'BenefitStrategy', 'prBenefitStrategyAdd', 21, @add_id OUTPUT, @err_num OUTPUT, @err_msg OUTPUT
SELECT @add_id, @err_num, @err_msg
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_AddDataParameters
     (@method			VARCHAR(100)
	 ,@add_procedure	VARCHAR(200)	 
	 ,@parameters		INT
	 ,@add_id			INT				OUTPUT
	 ,@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(4000)	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Set initial values for some variables
--*************************************************************************************************
SELECT @err_num = 0
      ,@err_msg = 'Success'

--*************************************************************************************************
-- Verify that the load option has been configured for this screen, exit with an error if not
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 AC.MethodName
                FROM cfg.ActionCatalog		AC
			   WHERE AC.MethodName			= @method
				 AND AC.Action				= 'Add')

	BEGIN

		SELECT @err_num = 1001
		      ,@err_msg = 'CFG - The add action has not been configured for this method, ' + @method 
		GOTO CLEANUP

	END

--*************************************************************************************************
-- Verify that the load function supports this combination of proc and parameters
--*************************************************************************************************
SELECT @add_id				= ISNULL(AA.AddID, 0)
  FROM cfg.ActionAdd		AA
 WHERE AA.MethodName		= @method
   AND AA.CoreProcedure		= @add_procedure
   AND AA.ParameterCount	= @parameters

IF ISNULL(@add_id, 0) = 0
	BEGIN

		SELECT @err_num = 1002
		      ,@err_msg = 'CFG - The add action for ' + @method + ' does not support the combination of parameters and stored procedure (' + CONVERT(VARCHAR(10), @parameters) + ', ' + @add_procedure + ')'
		GOTO CLEANUP

	END	

--*************************************************************************************************
-- Verify that a SQL query has been defined to associate the existing data with the populate SP
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 AD.ParameterName
				FROM cfg.ActionAddDetail	AD
				WHERE AD.AddID				= @add_id)

	BEGIN
		
		SELECT @err_num = 1003
		      ,@err_msg = 'CFG - No parameters have been configured for this parameter and method combination (' + CONVERT(VARCHAR(10), @parameters) + ', ' + @method + ')'
		GOTO CLEANUP

	END

--*************************************************************************************************
-- Output the parameters that have been configured for the stored procedure call
--*************************************************************************************************
SELECT AD.AddID
      ,AD.ParameterOrder
	  ,AD.ParameterName
	  ,AD.DataType			SQLType
	  ,AD.DataLength		SQLLength
	  ,DT.DBType
	  ,CASE WHEN AD.IsOutput = 1 THEN 'Yes' ELSE 'No' END IsOutput
	  ,CASE WHEN DT.UseLength = 1 THEN 'Yes' ELSE 'No' END UseLength
  FROM cfg.ActionAddDetail	AD
  LEFT JOIN cfg.DataType	DT
    ON AD.DataType			= DT.SQLType
 WHERE AD.AddID				= @add_id
 ORDER BY AD.ParameterOrder

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO