/**************************************************************************************************
Name:       spConfig_LoadDataParameters
Purpose:    Based on the method and parameters, return the parameters that are needed to make the
            stored procedure call

Date        User            Change
---------------------------------------------------------------------------------------------
02/26/2022	DK				Original procedure

---------------------------------------------------------------------------------------------
DECLARE @load_id INT, @err_num INT, @err_msg VARCHAR(4000)
EXEC spConfig_LoadDataParameters 46, @err_num OUTPUT, @err_msg OUTPUT
SELECT @load_id load_id, @err_num err_num, @err_msg err_msg
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_LoadDataParameters
     (@load_id			INT				OUTPUT
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
-- Output the parameters that have been configured for the stored procedure call
--*************************************************************************************************
IF EXISTS(SELECT TOP 1 LoadID 
            FROM cfg.ActionLoadParameter	LP
		   WHERE LP.LoadID					= @load_id)
	BEGIN

		SELECT LP.LoadID
			  ,LP.ParameterOrder
			  ,LP.ParameterName
			  ,LP.DataType			SQLType
			  ,LP.DataLength		SQLLength
			  ,DT.DBType
			  ,CASE WHEN LP.IsOutput = 1 THEN 'Yes' ELSE 'No' END IsOutput
			  ,CASE WHEN DT.UseLength = 1 THEN 'Yes' ELSE 'No' END UseLength
		  FROM cfg.ActionLoadParameter		LP
		  LEFT JOIN cfg.DataType			DT
			ON LP.DataType					= DT.SQLType
		 WHERE LP.LoadID					= @load_id
		 ORDER BY LP.ParameterOrder

	END
ELSE
	BEGIN

		SELECT @err_num = 5000
		      ,@err_msg = 'Load parameters could not be found for load id, ' + CONVERT(VARCHAR(10), @load_id)

	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO