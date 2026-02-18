IF OBJECT_ID('dbo.spDCAuto_CreateAffiliationNetworksAffiliations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAffiliationNetworksAffiliations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAffiliationNetworksAffiliations
Purpose:    Create affiliationnetworksaffiliations data from CorderAutomation
Method:     AffiliationNetworksAffiliations
Screen GID: 120
Procedure:  dbo.prNet_AttribNet_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/14/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAffiliationNetworksAffiliations '100-Config%', 22, 'AffiliationNetworksAffiliations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAffiliationNetworksAffiliations
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name            VARCHAR(20)
       ,@i_Network_gid            VARCHAR(20)
       ,@i_Old_Effective_date     VARCHAR(10)
       ,@i_Old_Termination_date   VARCHAR(10)
       ,@i_Old_price_strategy_gid VARCHAR(100)
       ,@i_Old_copay_strategy_gid VARCHAR(100)
       ,@i_Old_Society_gid        VARCHAR(20)
       ,@i_Old_State              VARCHAR(100)
       ,@i_Network_sid            VARCHAR(20)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(10)
       ,@i_action                 VARCHAR(50)
       ,@i_date_time_modified     VARCHAR(50)
       ,@iUserID                  VARCHAR(25)
       ,@i_effective_date         VARCHAR(50)
       ,@i_termination_date       VARCHAR(50)
       ,@i_area_code              VARCHAR(100)
       ,@i_zip_code               VARCHAR(100)
       ,@i_city                   VARCHAR(50)
       ,@i_county                 VARCHAR(50)
       ,@i_state                  VARCHAR(50)
       ,@i_country                VARCHAR(50)
       ,@i_region_code            VARCHAR(50)
       ,@i_region_desc            VARCHAR(50)
       ,@i_coverage_denied        VARCHAR(50)
       ,@i_Status_code            VARCHAR(50)
       ,@i_Specialty_code         VARCHAR(50)
       ,@i_Specialty_desc         VARCHAR(100)
       ,@i_Chain_ID               VARCHAR(50)
       ,@i_Chain_Desc             VARCHAR(100)
       ,@i_Affiliation_ID         VARCHAR(50)
       ,@i_Disp_Type              VARCHAR(50)
       ,@i_Price_Strategy_Id      VARCHAR(50)
       ,@i_Price_Strategy_Desc    VARCHAR(50)
       ,@i_Copay_Strategy_Id      VARCHAR(50)
       ,@i_Copay_Strategy_Desc    VARCHAR(50)
       ,@i_Coverage_Strategy_Id   VARCHAR(50)
       ,@i_Coverage_Strategy_Desc VARCHAR(50)
       ,@iCodePairingID           VARCHAR(50)
       ,@iCodePairingDesc         VARCHAR(50)
       ,@iBenefitStrategyID       VARCHAR(50)
       ,@iBenefitStrategyDesc     VARCHAR(50)
       ,@iWithholdID              VARCHAR(50)
       ,@iWithholdDesc            VARCHAR(100)
       ,@iCapRateTableID          VARCHAR(50)
       ,@iCapRateTableDesc        VARCHAR(100)
       ,@o_status                 INT
       ,@o_message                VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AffiliationNetworksAffiliations') IS NOT NULL
	DROP TABLE #AffiliationNetworksAffiliations

CREATE TABLE #AffiliationNetworksAffiliations
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(20)       DEFAULT('Attributes')
      ,i_Network_gid            VARCHAR(20)       DEFAULT('0')
      ,i_Old_Effective_date     VARCHAR(10)       DEFAULT('0')
      ,i_Old_Termination_date   VARCHAR(10)       DEFAULT('0')
      ,i_Old_price_strategy_gid VARCHAR(100)      DEFAULT('0')
      ,i_Old_copay_strategy_gid VARCHAR(100)      DEFAULT('0')
      ,i_Old_Society_gid        VARCHAR(20)       DEFAULT('0')
      ,i_Old_State              VARCHAR(100)      DEFAULT('0')
      ,i_Network_sid            VARCHAR(20)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(10)       DEFAULT('0')
      ,i_action                 VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(50)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,i_effective_date         VARCHAR(50)
      ,i_termination_date       VARCHAR(50)
      ,i_area_code              VARCHAR(100)
      ,i_zip_code               VARCHAR(100)
      ,i_city                   VARCHAR(50)
      ,i_county                 VARCHAR(50)
      ,i_state                  VARCHAR(50)
      ,i_country                VARCHAR(50)
      ,i_region_code            VARCHAR(50)
      ,i_region_desc            VARCHAR(50)
      ,i_coverage_denied        VARCHAR(50)
      ,i_Status_code            VARCHAR(50)
      ,i_Specialty_code         VARCHAR(50)
      ,i_Specialty_desc         VARCHAR(100)
      ,i_Chain_ID               VARCHAR(50)
      ,i_Chain_Desc             VARCHAR(100)
      ,i_Affiliation_ID         VARCHAR(50)
      ,i_Disp_Type              VARCHAR(50)
      ,i_Price_Strategy_Id      VARCHAR(50)
      ,i_Price_Strategy_Desc    VARCHAR(50)
      ,i_Copay_Strategy_Id      VARCHAR(50)
      ,i_Copay_Strategy_Desc    VARCHAR(50)
      ,i_Coverage_Strategy_Id   VARCHAR(50)
      ,i_Coverage_Strategy_Desc VARCHAR(50)
      ,iCodePairingID           VARCHAR(50)
      ,iCodePairingDesc         VARCHAR(50)
      ,iBenefitStrategyID       VARCHAR(50)
      ,iBenefitStrategyDesc     VARCHAR(50)
      ,iWithholdID              VARCHAR(50)
      ,iWithholdDesc            VARCHAR(100)
      ,iCapRateTableID          VARCHAR(50)
      ,iCapRateTableDesc        VARCHAR(100)
      ,o_status                 INT
      ,o_message                VARCHAR(255)
      ,record_id                INT
      ,static_gid               INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AffiliationNetworksAffiliations
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_area_code
      ,i_zip_code
      ,i_city
      ,i_county
      ,i_state
      ,i_country
      ,i_region_code
      ,i_coverage_denied
      ,i_Status_code
      ,i_Specialty_code
      ,i_Chain_ID
      ,i_Affiliation_ID
      ,i_Disp_Type
      ,i_Price_Strategy_Id
      ,i_Copay_Strategy_Id
      ,i_Coverage_Strategy_Id
      ,iCodePairingID
      ,iBenefitStrategyID
      ,iWithholdID
      ,iCapRateTableID
      ,record_id
      ,static_gid)
SELECT SearchID
      --,ISNULL([*ParentNetworkAffiliation], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([AreaCode], '')
      ,ISNULL([ZipCode], '')
      ,ISNULL([City], '')
      ,ISNULL([County], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([State]), '**')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Country]), '**')
      ,ISNULL([RegionCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CoverageDenied]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ProviderStatus]), 'A')
      ,ISNULL([*SpecialtyCode], '999')
      ,ISNULL([ChainID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Affiliation]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DispType]), '**')
      ,ISNULL([PriceStrategyID], '')
      ,ISNULL([CopayLevelsID], '')
      ,ISNULL([CodeLimitationsID], '')
      ,ISNULL([CodePairingID], '')
      ,ISNULL([BenefitStrategyID], '')
      ,ISNULL([WithholdID], '')
      ,ISNULL([CAPRateTableID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AffiliationNetworksAffiliations
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AffiliationNetworksAffiliations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AffiliationNetworksAffiliations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Network_gid
       ,i_Old_Effective_date
       ,i_Old_Termination_date
       ,i_Old_price_strategy_gid
       ,i_Old_copay_strategy_gid
       ,i_Old_Society_gid
       ,i_Old_State
       ,i_Network_sid
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_effective_date
       ,i_termination_date
       ,i_area_code
       ,i_zip_code
       ,i_city
       ,i_county
       ,i_state
       ,i_country
       ,i_region_code
       ,i_region_desc
       ,i_coverage_denied
       ,i_Status_code
       ,i_Specialty_code
       ,i_Specialty_desc
       ,i_Chain_ID
       ,i_Chain_Desc
       ,i_Affiliation_ID
       ,i_Disp_Type
       ,i_Price_Strategy_Id
       ,i_Price_Strategy_Desc
       ,i_Copay_Strategy_Id
       ,i_Copay_Strategy_Desc
       ,i_Coverage_Strategy_Id
       ,i_Coverage_Strategy_Desc
       ,iCodePairingID
       ,iCodePairingDesc
       ,iBenefitStrategyID
       ,iBenefitStrategyDesc
       ,iWithholdID
       ,iWithholdDesc
       ,iCapRateTableID
       ,iCapRateTableDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AffiliationNetworksAffiliations

   OPEN AffiliationNetworksAffiliations_Cursor
  FETCH NEXT FROM AffiliationNetworksAffiliations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Network_gid
       ,@i_Old_Effective_date
       ,@i_Old_Termination_date
       ,@i_Old_price_strategy_gid
       ,@i_Old_copay_strategy_gid
       ,@i_Old_Society_gid
       ,@i_Old_State
       ,@i_Network_sid
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_effective_date
       ,@i_termination_date
       ,@i_area_code
       ,@i_zip_code
       ,@i_city
       ,@i_county
       ,@i_state
       ,@i_country
       ,@i_region_code
       ,@i_region_desc
       ,@i_coverage_denied
       ,@i_Status_code
       ,@i_Specialty_code
       ,@i_Specialty_desc
       ,@i_Chain_ID
       ,@i_Chain_Desc
       ,@i_Affiliation_ID
       ,@i_Disp_Type
       ,@i_Price_Strategy_Id
       ,@i_Price_Strategy_Desc
       ,@i_Copay_Strategy_Id
       ,@i_Copay_Strategy_Desc
       ,@i_Coverage_Strategy_Id
       ,@i_Coverage_Strategy_Desc
       ,@iCodePairingID
       ,@iCodePairingDesc
       ,@iBenefitStrategyID
       ,@iBenefitStrategyDesc
       ,@iWithholdID
       ,@iWithholdDesc
       ,@iCapRateTableID
       ,@iCapRateTableDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			SELECT @i_Network_gid			= network_gid
			  FROM Attribute_Network_Names
			 WHERE network_id				= @SearchID
			   AND record_status			= 'A'

			EXEC dbo.prNet_AttribNet_AddModify
             @i_entity_name
            ,@i_Network_gid
            ,@i_Old_Effective_date
            ,@i_Old_Termination_date
            ,@i_Old_price_strategy_gid
            ,@i_Old_copay_strategy_gid
            ,@i_Old_Society_gid
            ,@i_Old_State
            ,@i_Network_sid
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_effective_date
            ,@i_termination_date
            ,@i_area_code
            ,@i_zip_code
            ,@i_city
            ,@i_county
            ,@i_state
            ,@i_country
            ,@i_region_code
            ,@i_region_desc
            ,@i_coverage_denied
            ,@i_Status_code
            ,@i_Specialty_code
            ,@i_Specialty_desc
            ,@i_Chain_ID
            ,@i_Chain_Desc
            ,@i_Affiliation_ID
            ,@i_Disp_Type
            ,@i_Price_Strategy_Id
            ,@i_Price_Strategy_Desc
            ,@i_Copay_Strategy_Id
            ,@i_Copay_Strategy_Desc
            ,@i_Coverage_Strategy_Id
            ,@i_Coverage_Strategy_Desc
            ,@iCodePairingID
            ,@iCodePairingDesc
            ,@iBenefitStrategyID
            ,@iBenefitStrategyDesc
            ,@iWithholdID
            ,@iWithholdDesc
            ,@iCapRateTableID
            ,@iCapRateTableDesc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_effective_date, @i_termination_date, @status, @err_num, @err_msg

        FETCH NEXT FROM AffiliationNetworksAffiliations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Network_gid
             ,@i_Old_Effective_date
             ,@i_Old_Termination_date
             ,@i_Old_price_strategy_gid
             ,@i_Old_copay_strategy_gid
             ,@i_Old_Society_gid
             ,@i_Old_State
             ,@i_Network_sid
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_effective_date
             ,@i_termination_date
             ,@i_area_code
             ,@i_zip_code
             ,@i_city
             ,@i_county
             ,@i_state
             ,@i_country
             ,@i_region_code
             ,@i_region_desc
             ,@i_coverage_denied
             ,@i_Status_code
             ,@i_Specialty_code
             ,@i_Specialty_desc
             ,@i_Chain_ID
             ,@i_Chain_Desc
             ,@i_Affiliation_ID
             ,@i_Disp_Type
             ,@i_Price_Strategy_Id
             ,@i_Price_Strategy_Desc
             ,@i_Copay_Strategy_Id
             ,@i_Copay_Strategy_Desc
             ,@i_Coverage_Strategy_Id
             ,@i_Coverage_Strategy_Desc
             ,@iCodePairingID
             ,@iCodePairingDesc
             ,@iBenefitStrategyID
             ,@iBenefitStrategyDesc
             ,@iWithholdID
             ,@iWithholdDesc
             ,@iCapRateTableID
             ,@iCapRateTableDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AffiliationNetworksAffiliations_Cursor
DEALLOCATE AffiliationNetworksAffiliations_Cursor

END
GO