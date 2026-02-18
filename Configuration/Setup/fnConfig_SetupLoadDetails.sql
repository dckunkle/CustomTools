/**************************************************************************************************
Name:       fnConfig_SetupLoadDetails
Purpose:    Return a listing of fields that will be used to create a table for collecting the data
            from a call to the populate stored procedure in Core

Date        User            Change
---------------------------------------------------------------------------------------------
12/14/2021	DK				Original script
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT * FROM fnConfig_SetupLoadDetails(139)
***************************************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnConfig_SetupLoadDetails
     (@screen_gid	INT)

RETURNS

@Screen_Details TABLE
               (column_order	INT
			   ,column_name		SYSNAME
			   ,column_type		VARCHAR(100)
			   ,column_length	INT
			   ,load_column		BIT)

AS
BEGIN
	DECLARE @max_order INT

	SELECT @max_order = MAX(SD.Field_Order) 
	  FROM dbo.Screen_details				SD
	 WHERE SD.Screen_GID					= @screen_gid

	INSERT INTO @Screen_Details
	      (column_order
		  ,column_name
		  ,column_type
		  ,column_length
		  ,load_column)
	SELECT SD.Field_Order								field_order
          ,dbo.fnConfig_SetupGetColumnName(SD.Label)	field_name
		  ,Data_Type									column_type
		  ,ISNULL([Length], 50)							column_length
		  ,1
      FROM Screen_details	SD
     WHERE SD.Screen_GID								= @screen_gid
	   AND SD.Data_Type									NOT IN ('EXPAND','SPACE')

	 -- Append the additional columns that the populate stored procedure requires
	 INSERT INTO @Screen_Details(column_order, column_name, column_type, column_length, load_column)
	 VALUES (@max_order + 1, 'date_time_created'	, 'STRING', 50, 0)
	       ,(@max_order + 2, 'user_id_created'		, 'STRING', 50, 0)
		   ,(@max_order + 3, 'date_time_modified'	, 'STRING', 50, 0)
		   ,(@max_order + 4, 'user_id'				, 'STRING', 50, 0)
		   ,(@max_order + 5, 'form_id'				, 'STRING', 50, 0)


	RETURN

END
GO