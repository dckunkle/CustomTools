/**************************************************************************************************
Name:       fnConfig_SetupAddDetails
Purpose:    Return a listing of parameters for the add procedure

Date        User            Change
---------------------------------------------------------------------------------------------
03/01/2022	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT * FROM fnConfig_SetupAddDetails('prNet_SuperNet_AddModify', 111)
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupAddDetails
     (@add_procedure	SYSNAME
	 ,@screen_gid		INT)

RETURNS

@parameters TABLE
	(parameter_order		INT
	,parameter_name			SYSNAME
	,field_name				VARCHAR(200)
	,data_type				VARCHAR(100)
	,data_length			INT
	,is_output				BIT)

AS
BEGIN

	DECLARE @fields TABLE
	       (field_id		INT
		   ,field_name		VARCHAR(200)
		   ,field_sid		INT IDENTITY(1,1))

	INSERT INTO @fields
	      (field_id
		  ,field_name)
	SELECT SD.Field_Order
	      ,dbo.fnConfig_SetupGetColumnName(SD.Label)
	  FROM Screen_details	SD
	 WHERE Screen_GID		= @screen_gid
	   AND SD.Data_Type		NOT IN ('EXPAND','SPACE','DUMMY','PLACE')
	 ORDER BY SD.Field_Order

	UPDATE @fields
	   SET field_id = field_sid + 14

	INSERT INTO @parameters
	      (parameter_order
		  ,parameter_name
		  ,field_name
		  ,data_type
		  ,data_length
		  ,is_output)
	SELECT P.parameter_id
	      ,P.name
		  ,ISNULL(F.field_name, '')
		  ,T.name
		  ,P.max_length
		  ,P.is_output
      FROM QR06APP.sys.parameters		P
	  JOIN QR06APP.sys.procedures		PR
	    ON P.object_id			= PR.object_id
	  JOIN QR06APP.sys.types			T
	    ON P.system_type_id		= T.system_type_id
	  LEFT JOIN @fields				F
	    ON P.parameter_id		= F.field_id
     WHERE PR.name				= @add_procedure
	 ORDER BY P.parameter_id

	RETURN

END
GO