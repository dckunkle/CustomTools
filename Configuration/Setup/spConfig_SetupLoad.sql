/**************************************************************************************************
Name:       spConfig_SetupLoad
Purpose:    Gather configuration from Core to be used by the Configurator for loading data

Date        User            Change
---------------------------------------------------------------------------------------------
12/15/2021	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_SetupLoad 'BenefitStrategy','Benefit_Strategy_Name', 199, 'BenefitStrategy', 'Benefit Strategy', 1
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_SetupLoad
     (@method			VARCHAR(100)
	 ,@core_entity		VARCHAR(100)
	 ,@core_screen		INT
	 ,@table_name		VARCHAR(128)
	 ,@entity_name		VARCHAR(200)
	 ,@overwrite		BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Declare variables to be used later
--*************************************************************************************************
DECLARE @stored_procedure		SYSNAME		= ''
	   ,@field_count			INT			= 0
	   ,@load_id_current		INT			= 0
	   ,@load_id_new			INT			= 0
	   ,@parameter_count		INT			= 0
	   
DECLARE @output_fields TABLE
       (field_order		INT
	   ,field_name		SYSNAME)

DECLARE @load_parameters TABLE
       (parameter_order			INT
	   ,parameter_name			VARCHAR(200)
	   ,data_type				VARCHAR(50)
	   ,data_length				INT
	   ,is_output				BIT)

--*************************************************************************************************
-- Get the name of the stored procedure for the specific action passed in
--*************************************************************************************************
SELECT @stored_procedure		= ESA.populate_stored_proc
  FROM Entity_Screen_Action		ESA
 WHERE ESA.screen_gid			= @core_screen
   AND ESA.entity				= @core_entity
   AND ESA.action				IN ('ADD','MODIFY')
   AND ISNULL(ESA.populate_stored_proc, '')	<> ''

--*************************************************************************************************
-- Gather the output columns from the populate stored procedure
--*************************************************************************************************
INSERT INTO @output_fields
      (field_order
	  ,field_name)
SELECT column_order
      ,column_name
  FROM dbo.fnConfig_SetupLoadDetails(@core_screen)

SELECT @field_count = COUNT(*)
  FROM @output_fields

--*************************************************************************************************
-- Gather the parameters that are required to call the populate procedure
--*************************************************************************************************
INSERT INTO @load_parameters
      (parameter_order
	  ,parameter_name
	  ,data_type
	  ,data_length
	  ,is_output)
SELECT parameter_order
	  ,parameter_name
	  ,data_type
	  ,data_length
	  ,is_output
  FROM dbo.fnConfig_SetupLoadParameters(@stored_procedure)

SELECT @parameter_count = COUNT(*)
  FROM @load_parameters

--*************************************************************************************************
-- Delete any existing configuration for the Core screen if the user chooses to overwrite it
--*************************************************************************************************
IF @overwrite = 1
	BEGIN
				
		SELECT @load_id_current								= ISNULL(AL.LoadID, 0)
		  FROM COREAUTO.Configuration.cfg.ActionLoad		AL
		 WHERE AL.MethodName								= @method
		   AND AL.CoreProcedure								= @stored_procedure
		   AND AL.FieldCount								= @field_count

		DELETE ALF
		  FROM COREAUTO.Configuration.cfg.ActionLoadField	ALF
		 WHERE ALF.LoadID									= @load_id_current

		DELETE ALP
		  FROM COREAUTO.Configuration.cfg.ActionLoadParameter ALP
		 WHERE ALP.LoadID									= @load_id_current

		DELETE AL
		  FROM COREAUTO.Configuration.cfg.ActionLoad		AL
		 WHERE AL.LoadID									= @load_id_current

		DELETE AC
		  FROM COREAUTO.Configuration.cfg.ActionCatalog		AC
		 WHERE AC.MethodName								= @method
		   AND AC.Action									= 'Load'

	END

--*************************************************************************************************
-- Add the Core screen to the ActionCatalog
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 MethodName
		        FROM COREAUTO.Configuration.cfg.ActionCatalog	AC
			   WHERE AC.MethodName								= @method
				 AND AC.Action									= 'Load')

	BEGIN
				
		INSERT INTO COREAUTO.Configuration.cfg.ActionCatalog
			  (MethodName
			  ,Action)
		SELECT @method
			  ,'Load'

	END

--*************************************************************************************************
-- Add data to the Action Load table for the Core Screen
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 MethodName
		        FROM COREAUTO.Configuration.cfg.ActionLoad		AL
			   WHERE AL.MethodName								= @method
				 AND AL.CoreProcedure							= @stored_procedure
				 AND AL.FieldCount								= @field_count)

	BEGIN
				
		INSERT INTO COREAUTO.Configuration.cfg.ActionLoad
			  (MethodName
			  ,CoreProcedure
			  ,ParameterCount
			  ,FieldCount)
		SELECT @method
			  ,@stored_procedure
			  ,@parameter_count
			  ,@field_count

		-- Need to explicitly get the max load id since @@IDENTITY is not working for linked server data
		SELECT @load_id_new = MAX(LoadID)
		  FROM COREAUTO.Configuration.cfg.ActionLoad

		INSERT INTO COREAUTO.Configuration.cfg.ActionLoadField
			  (LoadID
			  ,FieldOrder
			  ,OutputOrder
			  ,FieldName
			  ,DataType
			  ,DataLength
			  ,DestinationFieldName
			  ,LoadField
			  ,SkipField)
		SELECT @load_id_new
			  ,S.column_order	
			  ,S.column_order
			  ,CASE WHEN ISNULL(S.column_name, '') = '' THEN 'Dummy' + CONVERT(VARCHAR(5), S.column_order) ELSE S.column_name END
			  ,'VARCHAR'
			  ,CASE WHEN S.column_length = 0 THEN 5 ELSE S.column_length END
			  ,ISNULL(S.column_name, '')	
			  ,S.load_column
			  ,CASE WHEN ISNULL(S.column_name, '') = '' THEN 1 ELSE 0 END
		  FROM (SELECT column_order
					  ,column_name
					  ,column_type
					  ,column_length
					  ,load_column
				  FROM dbo.fnConfig_SetupLoadDetails(@core_screen)) S

		INSERT INTO COREAUTO.Configuration.cfg.ActionLoadParameter
		      (LoadID
			  ,ParameterOrder
			  ,ParameterName
			  ,DataType
			  ,DataLength
			  ,IsOutput)
		SELECT @load_id_new
		      ,parameter_order
			  ,parameter_name
			  ,data_type
			  ,data_length
			  ,is_output
		  FROM @load_parameters

	END

END 
GO