/**************************************************************************************************
Name:       fnConfig_SetupLoadParameters
Purpose:    Return a listing of parameters for the add procedure

Date        User            Change
---------------------------------------------------------------------------------------------
03/01/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT * FROM fnConfig_SetupLoadParameters('prDetailRuleNamePopulate')
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupLoadParameters
     (@add_procedure	SYSNAME)

RETURNS

@parameters TABLE
	(parameter_order		INT
	,parameter_name			SYSNAME
	,data_type				VARCHAR(100)
	,data_length			INT
	,is_output				BIT)

AS
BEGIN

	INSERT INTO @parameters
	      (parameter_order
		  ,parameter_name
		  ,data_type
		  ,data_length
		  ,is_output)
	SELECT P.parameter_id
	      ,P.name
		  ,T.name
		  ,P.max_length
		  ,P.is_output
      FROM QR06APP.sys.parameters		P
	  JOIN QR06APP.sys.procedures		PR
	    ON P.object_id			= PR.object_id
	  JOIN QR06APP.sys.types			T
	    ON P.system_type_id		= T.system_type_id
     WHERE PR.name				= @add_procedure
	 ORDER BY P.parameter_id

	RETURN

END
GO