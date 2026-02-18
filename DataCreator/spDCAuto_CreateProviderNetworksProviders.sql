IF OBJECT_ID('dbo.spDCAuto_CreateProviderNetworksProviders') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProviderNetworksProviders AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProviderNetworksProviders
Purpose:    Create providernetworksproviders data from CorderAutomation
Method:     ProviderNetworksProviders
Screen GID: 165
Procedure:  dbo.prNet_ProvNet_AddProvider

Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProviderNetworksProviders '100-Config%', 22, 'ProviderNetworksProviders'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProviderNetworksProviders
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern					VARCHAR(200)
	   ,@log_id						INT
	   ,@test_case_name				VARCHAR(200)
	   ,@method						VARCHAR(200)
	   ,@user						VARCHAR(200)

	   ,@record_id					INT
	   ,@gid						INT
	   ,@err_msg					VARCHAR(4000)
       ,@err_num					INT
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT
	   ,@SearchID					VARCHAR(200)
	   ,@location_gid				INT
	   ,@location_orig_name			VARCHAR(2000)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_to_entity              VARCHAR(50)
       ,@i_Network_gid            VARCHAR(50)
       ,@i_to_key_2_field         VARCHAR(50)
       ,@i_to_key_3_field         VARCHAR(50)
       ,@i_to_key_4_field         VARCHAR(20)
       ,@i_to_key_5_field         VARCHAR(20)
       ,@i_to_key_6_field         VARCHAR(50)
       ,@i_to_key_7_field         VARCHAR(50)
       ,@i_to_key_8_field         VARCHAR(50)
       ,@i_to_key_9_field         VARCHAR(50)
       ,@i_to_key_10_field        VARCHAR(50)
       ,@i_action                 VARCHAR(10)
       ,@i_Date_Time_Modified     VARCHAR(50)
       ,@iUserID                  VARCHAR(25)
       ,@i_provider_id            VARCHAR(50)
       ,@i_provider_name          VARCHAR(150)
       ,@i_location_gid           VARCHAR(50)
       ,@i_effective_date         VARCHAR(50)
       ,@i_termination_date       VARCHAR(50)
       ,@i_Coverage_denied        VARCHAR(50)
       ,@i_price_strategy_id      VARCHAR(50)
       ,@i_price_strategy_desc    VARCHAR(50)
       ,@i_copay_strategy_id      VARCHAR(50)
       ,@i_copay_strategy_desc    VARCHAR(50)
       ,@i_coverage_strategy_id   VARCHAR(50)
       ,@i_coverage_strategy_desc VARCHAR(50)
       ,@iCodePairingID           VARCHAR(50)
       ,@iCodePairingDesc         VARCHAR(50)
       ,@iBenefitStrategyID       VARCHAR(50)
       ,@iBenefitStrategyDesc     VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(100)
	   ,@location_name			  VARCHAR(2000)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProviderNetworksProviders') IS NOT NULL
	DROP TABLE #ProviderNetworksProviders

CREATE TABLE #ProviderNetworksProviders
      (SearchID                 VARCHAR(200)
      ,i_to_entity              VARCHAR(50)       DEFAULT('Providers')
      ,i_Network_gid            VARCHAR(50)       DEFAULT('0')
      ,i_to_key_2_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_3_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_4_field         VARCHAR(20)       DEFAULT('0')
      ,i_to_key_5_field         VARCHAR(20)       DEFAULT('0')
      ,i_to_key_6_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_7_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_8_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_9_field         VARCHAR(50)       DEFAULT('0')
      ,i_to_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action                 VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified     VARCHAR(50)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,i_provider_id            VARCHAR(50)
      ,i_provider_name          VARCHAR(150)
      ,i_location_gid           VARCHAR(50)		  DEFAULT(-1)	-- Skip the Location GID check
      ,i_effective_date         VARCHAR(50)
      ,i_termination_date       VARCHAR(50)
      ,i_Coverage_denied        VARCHAR(50)
      ,i_price_strategy_id      VARCHAR(50)
      ,i_price_strategy_desc    VARCHAR(50)
      ,i_copay_strategy_id      VARCHAR(50)
      ,i_copay_strategy_desc    VARCHAR(50)
      ,i_coverage_strategy_id   VARCHAR(50)
      ,i_coverage_strategy_desc VARCHAR(50)
      ,iCodePairingID           VARCHAR(50)
      ,iCodePairingDesc         VARCHAR(50)
      ,iBenefitStrategyID       VARCHAR(50)
      ,iBenefitStrategyDesc     VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT
	  ,location_name			VARCHAR(2000))

IF OBJECT_ID('tempdb.dbo.#Locations') IS NOT NULL
	DROP TABLE #Locations

CREATE TABLE #Locations
      (location_id				INT
	  ,reference_type			VARCHAR(20)
	  ,location_gid				VARCHAR(20)
	  ,location_description		VARCHAR(2000)
	  ,location_order			INT) 

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ProviderNetworksProviders
      (SearchID
      ,i_provider_id
	  ,location_name
      ,i_effective_date
      ,i_termination_date
      ,i_Coverage_denied
      ,i_price_strategy_id
      ,i_copay_strategy_id
      ,i_coverage_strategy_id
      ,iCodePairingID
      ,iBenefitStrategyID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*ProviderID], '')
	  ,ISNULL([SvcLocation], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CovDenied]), 'N')
      ,ISNULL([PriceStrategyID], '')
      ,ISNULL([CopayLevelsID], '')
      ,ISNULL([CodeLimitationsID], '')
      ,ISNULL([CodePairingID], '')
      ,ISNULL([BenefitStrategyID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ProviderNetworksProviders
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ProviderNetworksProviders
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ProviderNetworksProviders_Cursor CURSOR FOR
 SELECT SearchID
       ,i_to_entity
       ,i_Network_gid
       ,i_to_key_2_field
       ,i_to_key_3_field
       ,i_to_key_4_field
       ,i_to_key_5_field
       ,i_to_key_6_field
       ,i_to_key_7_field
       ,i_to_key_8_field
       ,i_to_key_9_field
       ,i_to_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_provider_id
       ,i_provider_name
       ,i_location_gid
       ,i_effective_date
       ,i_termination_date
       ,i_Coverage_denied
       ,i_price_strategy_id
       ,i_price_strategy_desc
       ,i_copay_strategy_id
       ,i_copay_strategy_desc
       ,i_coverage_strategy_id
       ,i_coverage_strategy_desc
       ,iCodePairingID
       ,iCodePairingDesc
       ,iBenefitStrategyID
       ,iBenefitStrategyDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
	   ,location_name
   FROM #ProviderNetworksProviders

   OPEN ProviderNetworksProviders_Cursor
  FETCH NEXT FROM ProviderNetworksProviders_Cursor
   INTO @SearchID
       ,@i_to_entity
       ,@i_Network_gid
       ,@i_to_key_2_field
       ,@i_to_key_3_field
       ,@i_to_key_4_field
       ,@i_to_key_5_field
       ,@i_to_key_6_field
       ,@i_to_key_7_field
       ,@i_to_key_8_field
       ,@i_to_key_9_field
       ,@i_to_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_provider_id
       ,@i_provider_name
       ,@i_location_gid
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Coverage_denied
       ,@i_price_strategy_id
       ,@i_price_strategy_desc
       ,@i_copay_strategy_id
       ,@i_copay_strategy_desc
       ,@i_coverage_strategy_id
       ,@i_coverage_strategy_desc
       ,@iCodePairingID
       ,@iCodePairingDesc
       ,@iBenefitStrategyID
       ,@iBenefitStrategyDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid
	   ,@location_name

WHILE @@FETCH_STATUS = 0
	BEGIN
			
			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			-- Get the gid for the Provider Network
			SELECT @i_Network_gid			= network_gid
			  FROM Provider_Network_Names
			 WHERE record_status			= 'A'
			   AND network_id				= @SearchID

			-- Get all of the locations for the given provider and select the one to add
			TRUNCATE TABLE #Locations
			INSERT INTO #Locations
			  EXEC prBuildLocationCombo 'SvcLocations', @i_provider_id, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, ''

			SET @location_gid = 0
			SET @location_orig_name = @location_name

			-- If the location_description is NULL, then grab the first location
			IF @location_name IS NULL 
				BEGIN
					
					SELECT @location_gid	= location_gid
					  FROM #Locations
					 WHERE location_order	= 1

				END
			ELSE
				BEGIN

					SET @location_name = REPLACE(@location_name,'<partial>','') -- Remove the Partial if it is there
					SELECT @location_gid	= location_gid
					  FROM #Locations
					 WHERE location_description LIKE '%' + @location_name + '%'
				END 

			IF @location_gid = 0 
				BEGIN

					SELECT @status	= 'Error' 
					      ,@err_num	= 16
						  ,@err_msg	= 'A location could not be found to add to the Provider Network.'
					EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_provider_id, @location_orig_name, @status, @err_num, @err_msg
				END
			ELSE
				BEGIN
					BEGIN TRY

						SET @i_location_gid = @location_gid

						EXEC dbo.prNet_ProvNet_AddProvider
							 @i_to_entity
							,@i_Network_gid
							,@i_to_key_2_field
							,@i_to_key_3_field
							,@i_to_key_4_field
							,@i_to_key_5_field
							,@i_to_key_6_field
							,@i_to_key_7_field
							,@i_to_key_8_field
							,@i_to_key_9_field
							,@i_to_key_10_field
							,@i_action
							,@i_Date_Time_Modified
							,@iUserID
							,@i_provider_id
							,@i_provider_name
							,@i_location_gid
							,@i_effective_date
							,@i_termination_date
							,@i_Coverage_denied
							,@i_price_strategy_id
							,@i_price_strategy_desc
							,@i_copay_strategy_id
							,@i_copay_strategy_desc
							,@i_coverage_strategy_id
							,@i_coverage_strategy_desc
							,@iCodePairingID
							,@iCodePairingDesc
							,@iBenefitStrategyID
							,@iBenefitStrategyDesc
							,@o_status     = @err_num OUTPUT
							,@o_message    = @err_msg OUTPUT

					END TRY
					BEGIN CATCH

						SELECT @err_num = ERROR_NUMBER()
							  ,@err_msg	= ERROR_MESSAGE()

					END CATCH

					SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
					EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_provider_id, '', @status, @err_num, @err_msg

			END

        FETCH NEXT FROM ProviderNetworksProviders_Cursor
         INTO @SearchID
             ,@i_to_entity
             ,@i_Network_gid
             ,@i_to_key_2_field
             ,@i_to_key_3_field
             ,@i_to_key_4_field
             ,@i_to_key_5_field
             ,@i_to_key_6_field
             ,@i_to_key_7_field
             ,@i_to_key_8_field
             ,@i_to_key_9_field
             ,@i_to_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_provider_id
             ,@i_provider_name
             ,@i_location_gid
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Coverage_denied
             ,@i_price_strategy_id
             ,@i_price_strategy_desc
             ,@i_copay_strategy_id
             ,@i_copay_strategy_desc
             ,@i_coverage_strategy_id
             ,@i_coverage_strategy_desc
             ,@iCodePairingID
             ,@iCodePairingDesc
             ,@iBenefitStrategyID
             ,@iBenefitStrategyDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
			 ,@location_name
	END

CLOSE ProviderNetworksProviders_Cursor
DEALLOCATE ProviderNetworksProviders_Cursor

END
GO