/**************************************************************************************************
Name:       spConfig_SetupCatalog
Purpose:    Gather configuration data from Core to be used by the Configurator

Date        User            Change
---------------------------------------------------------------------------------------------
12/21/2021	DK				Original procedure
03/01/2022  DK				Added Add setup

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_SetupCatalog 'PlaceOfServiceList', 'POS_List', 1, 'PlaceOfServiceList','Place of Service List', 1

EXEC spConfig_SetupCatalog 'BenefitStrategy','Benefit_Strategy_Name', 199, 'BenefitStrategy', 'Benefit Strategy', 1
EXEC spConfig_SetupCatalog 'BenefitStrategyVariation','Benefit_Strategy', 139, 'BenefitStrategyVariation', 'Benefit Strategy Variation', 1

EXEC spConfig_SetupCatalog 'BenefitRuleVariation','Benefit_Plan', 66, 'BenefitRuleVariation', 'Benefit Rule Variation', 1

EXEC spConfig_SetupCatalog 'CopaySchedule','Copay_Schedule_Name', 53, 'CopaySchedule', 'Copay Schedule', 1
EXEC spConfig_SetupCatalog 'CopayScheduleVariation','Copay_Schedule', 48, 'CopayScheduleVariation', 'Copay Schedule Variation', 1

EXEC spConfig_SetupCatalog 'CopayLevel','Copay_Strategy', 196, 'CopayLevel', 'Copay Level', 1
EXEC spConfig_SetupCatalog 'CopayLevelVariation','Copay_Strategy_Variation', 54, 'CopayLevelVariation', 'Copay Level Variation', 1

EXEC spConfig_SetupCatalog 'SuperNetwork','Super_Networks', 111, 'SuperNetwork', 'Super Network', 1
EXEC spConfig_SetupCatalog 'CodeLimitation','Coverage_Strategy', 195, 'CodeLimitation', 'Code Limitation', 1
EXEC spConfig_SetupCatalog 'PayerCompassEditCodeRelations','PayerCompassEditRelations', 57, 'PayerCompassEditCodeRelations', 'Payer Compass Edit Code Relations', 1
EXEC spConfig_SetupCatalog 'PriceStrategy','Price_Strategy', 197, 'PriceStrategy', 'Price Strategy', 1

EXEC spConfig_SetupCatalog 'RemarkCodes','Processing_Policies', 156, 'RemarkCodes', 'Remark Codes', 1

EXEC spConfig_SetupCatalog 'BenefitClass','Benefit_Classes', 3002, 'BenefitClass', 'Benefit Class', 1
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_SetupCatalog
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
DECLARE @stored_procedure		SYSNAME			= ''
	   ,@parameter_count		INT
	   ,@sql					VARCHAR(4000)	= ''
	   ,@load_id_current		INT
	   ,@load_id_new			INT
	   
DECLARE @procedure_parameters TABLE
       (column_order	INT
	   ,column_name		SYSNAME)

--*************************************************************************************************
-- Create a new entry in the cfg.Catalog table for the new functionality
--*************************************************************************************************
IF @overwrite = 1
	BEGIN

		DELETE C
		  FROM COREAUTO.Configuration.cfg.Catalog		C
		 WHERE C.MethodName		= @method

	END

IF NOT EXISTS(SELECT TOP 1 C.MethodName 
                FROM COREAUTO.Configuration.cfg.Catalog		C
			   WHERE C.MethodName		= @method)

	BEGIN
		
		INSERT INTO COREAUTO.Configuration.cfg.Catalog
		      (MethodName
			  ,CoreScreen
			  ,CoreEntity
			  ,EntityName
			  ,TableName)
		SELECT @method 
		      ,@core_screen
		      ,@core_entity
			  ,@entity_name
			  ,@table_name

	END

--*************************************************************************************************
-- Add any actions for the given screen
--*************************************************************************************************

EXEC dbo.spConfig_SetupLoad @method, @core_entity, @core_screen, @table_name, @entity_name, @overwrite

EXEC dbo.spConfig_SetupAdd @method, @core_entity, @core_screen, @table_name, @entity_name, @overwrite
--EXEC dbo.spConfig_SetupPopulate @entity, @screen_gid, @table_name, @entity_name, @overwrite

--TODO:
-- EXEC Add
-- EXEC Modify


END 
GO