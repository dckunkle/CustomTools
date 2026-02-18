/**************************************************************************************************
Name:       spConfig_SetupAdd
Purpose:    Gather configuration from Core to be used by the Configurator for adding data

Date        User            Change
---------------------------------------------------------------------------------------------
02/28/2022	DK				Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_SetupAdd 'BenefitStrategyVariation','Benefit_Strategy', 139, 'BenefitStrategyVariation', 'Benefit Strategy Variation', 1
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_SetupAdd
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
	   ,@parameter_count		INT			= 0
	   ,@add_id_current			INT			= 0
	   ,@add_id_new				INT			= 0
	   
DECLARE @add_parameters TABLE
       (parameter_order			INT
	   ,parameter_name			VARCHAR(200)
	   ,field_name				VARCHAR(200)
	   ,data_type				VARCHAR(50)
	   ,data_length				INT
	   ,is_output				BIT)

--*************************************************************************************************
-- Get the name of the stored procedure for the specific action passed in
--*************************************************************************************************
SELECT @stored_procedure		= ESA.action_stored_proc
  FROM Entity_Screen_Action		ESA
 WHERE ESA.screen_gid			= @core_screen
   AND ESA.entity				= @core_entity
   AND ESA.action				= 'ADD'

--*************************************************************************************************
-- Gather the output columns from the populate stored procedure
--*************************************************************************************************
INSERT INTO @add_parameters
      (parameter_order
	  ,parameter_name
	  ,field_name
	  ,data_type
	  ,data_length
	  ,is_output)
SELECT parameter_order
	  ,parameter_name
	  ,field_name
	  ,data_type
	  ,data_length
	  ,is_output
  FROM dbo.fnConfig_SetupAddDetails(@stored_procedure, @core_screen)

SELECT @parameter_count = COUNT(*)
  FROM @add_parameters

--*************************************************************************************************
-- Delete any existing configuration for the Core screen if the user chooses to overwrite it
--*************************************************************************************************
IF @overwrite = 1
	BEGIN
				
		SELECT @add_id_current								= ISNULL(AA.AddID, 0)
		  FROM COREAUTO.Configuration.cfg.ActionAdd			AA
		 WHERE AA.MethodName								= @method
		   AND AA.CoreProcedure								= @stored_procedure
		   AND AA.ParameterCount							= @parameter_count

		DELETE AAD
		  FROM COREAUTO.Configuration.cfg.ActionAddDetail	AAD
		 WHERE AAD.AddID									= @add_id_current

		DELETE AA
		  FROM COREAUTO.Configuration.cfg.ActionAdd			AA
		 WHERE AA.AddID										= @add_id_current

		DELETE AC
		  FROM COREAUTO.Configuration.cfg.ActionCatalog		AC
		 WHERE AC.MethodName								= @method
		   AND AC.Action									= 'Add'

	END

--*************************************************************************************************
-- Add the Core screen to the ActionCatalog
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 MethodName
		        FROM COREAUTO.Configuration.cfg.ActionCatalog	AC
			   WHERE AC.MethodName								= @method
				 AND AC.Action									= 'Add')

	BEGIN
				
		INSERT INTO COREAUTO.Configuration.cfg.ActionCatalog
			  (MethodName
			  ,Action)
		SELECT @method
			  ,'Add'

	END

--*************************************************************************************************
-- Add data to the Action Load table for the Core Screen
--*************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 MethodName
		        FROM COREAUTO.Configuration.cfg.ActionAdd		AA
			   WHERE AA.MethodName								= @method
				 AND AA.CoreProcedure							= @stored_procedure
				 AND AA.ParameterCount							= @parameter_count)

	BEGIN
				
		INSERT INTO COREAUTO.Configuration.cfg.ActionAdd
			  (MethodName
			  ,CoreProcedure
			  ,ParameterCount)
		SELECT @method
			  ,@stored_procedure
			  ,@parameter_count

		-- Need to explicitly get the max load id since @@IDENTITY is not working for linked server data
		SELECT @add_id_new = MAX(AddID)
		  FROM COREAUTO.Configuration.cfg.ActionAdd

		INSERT INTO COREAUTO.Configuration.cfg.ActionAddDetail
			  (AddID
			  ,ParameterOrder
			  ,ParameterName
			  ,DataType
			  ,DataLength
			  ,IsOutput
			  ,FieldName)
		SELECT @add_id_new
			  ,A.parameter_order				
			  ,A.parameter_name
			  ,A.data_type
			  ,A.data_length
			  ,A.is_output
			  ,A.field_name
		  FROM @add_parameters	A

	END

END 
GO