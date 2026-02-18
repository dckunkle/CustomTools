/**************************************************************************************************
Name:       fnConfig_SetupScreenDetails
Purpose:    Return a table of screen definition details

Date        User            Change
---------------------------------------------------------------------------------------------
12/14/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT * FROM fnConfig_SetupScreenDetails(230)
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupScreenDetails
     (@screen_gid	INT)

RETURNS

@Screen_Details TABLE
               (column_order	INT
			   ,column_name		SYSNAME
			   ,column_type		VARCHAR(100)
			   ,column_length	INT
			   ,default_value	VARCHAR(100))

AS
BEGIN
	
	INSERT INTO @Screen_Details
	      (column_order
		  ,column_name
		  ,column_type
		  ,column_length
		  ,default_value)
	SELECT SD.Field_Order + 14									field_order
          ,dbo.fnConfig_SetupGetColumnName(SD.Label)			field_name
		  ,Data_Type											column_type
		  ,[Length]												column_length
	      ,ISNULL(SD.default_value, '')							default_value
      FROM Screen_details	SD
     WHERE SD.Screen_GID										= @screen_gid

	RETURN

END
GO