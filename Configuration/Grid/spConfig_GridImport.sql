/**************************************************************************************************
Name:       spConfig_GridImport
Purpose:    Populate Configurator with data from the Benefit Grid (e.g. Benfit Strategy,
            Benefit Rules, Copay Levels, Copay Schedules)

Date        User            Change
---------------------------------------------------------------------------------------------
03/23/2022	DK				Original procedure
10/06/2022	DK				Add call to Copay Flags 
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spConfig_GridImport 'Bright-PROD-2023-', 'ALL', 0
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_GridImport
     (@config_id		VARCHAR(100)
	 ,@state			VARCHAR(10)		= 'ALL'
	 ,@shells_only		BIT				= 0)
AS
BEGIN

SET NOCOUNT ON

-- Mark any data that we are not planning to use to ignore 
IF @shells_only = 0
	BEGIN
		EXEC spConfig_GridImportMarkIgnore
		EXEC spConfig_GridImportUpdateCrosswalk
		EXEC spConfig_GridImportSetCopayFlags
	END

-- Build Benenfit Strategy and all variations
EXEC spConfig_GridImportBenefitRule @config_id, @state, @shells_only
EXEC spConfig_GridImportBenefitStrategy @config_id, @state, @shells_only

-- Build Copay Levels and all variations
EXEC spConfig_GridImportCopaySchedule @config_id, @state, @shells_only
EXEC spConfig_GridImportCopayLevel @config_id, @state, @shells_only

-- Build Plan Strategy
EXEC spConfig_GridImportPlanStrategy @config_id, @state

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************


END 
GO