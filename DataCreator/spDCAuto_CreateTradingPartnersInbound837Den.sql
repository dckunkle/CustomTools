IF OBJECT_ID('dbo.spDCAuto_CreateTradingPartnersInbound837Den') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTradingPartnersInbound837Den AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTradingPartnersInbound837Den
Purpose:    Create tradingpartnersinbound837den data from CorderAutomation
Method:     TradingPartnersInbound837Den
Screen GID: 11011
Procedure:  dbo.prInbound_X12_837_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTradingPartnersInbound837Den '100-Config%', 22, 'TradingPartnersInbound837Den'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTradingPartnersInbound837Den
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

DECLARE @i_entity_name                VARCHAR(50)
       ,@i_Trading_partner_gid        VARCHAR(50)
       ,@i_Key_Transaction_type       VARCHAR(50)
       ,@i_Key_Direction              VARCHAR(50)
       ,@i_Trxn_SID                   VARCHAR(50)
       ,@i_Key_5                      VARCHAR(50)
       ,@i_Key_6                      VARCHAR(50)
       ,@i_key_7_field                VARCHAR(50)
       ,@i_key_8_field                VARCHAR(50)
       ,@i_key_9_field                VARCHAR(50)
       ,@i_key_10_field               VARCHAR(50)
       ,@iAction                      VARCHAR(10)
       ,@i_date_time_modified         VARCHAR(20)
       ,@i_user_id                    VARCHAR(20)
       ,@i_Transaction_Type           VARCHAR(50)
       ,@i_Direction                  VARCHAR(50)
       ,@i_Transaction_Purpose        VARCHAR(50)
       ,@iDefManualClaim              VARCHAR(50)
       ,@iMemberMatchID               VARCHAR(50)
       ,@iMemberMatchDesc             VARCHAR(50)
       ,@i999FileNamingID             VARCHAR(50)
       ,@i999FileNamingDesc           VARCHAR(50)
       ,@i_ReasonMappingID            VARCHAR(50)
       ,@i_ReasonMappingDesc          VARCHAR(50)
       ,@iNonParLoc1                  VARCHAR(50)
       ,@iNonParValue1                VARCHAR(50)
       ,@i_non_par_price_var_bypass_1 VARCHAR(50)
       ,@iNonParLoc2                  VARCHAR(50)
       ,@iNonParValue2                VARCHAR(50)
       ,@i_non_par_price_var_bypass_2 VARCHAR(50)
       ,@i_non_par_loc_3              VARCHAR(50)
       ,@i_non_par_value_3            VARCHAR(50)
       ,@i_non_par_price_var_bypass_3 VARCHAR(50)
       ,@i_non_par_loc_4              VARCHAR(50)
       ,@i_non_par_value_4            VARCHAR(50)
       ,@i_non_par_price_var_bypass_4 VARCHAR(50)
       ,@i_non_par_loc_5              VARCHAR(50)
       ,@i_non_par_value_5            VARCHAR(50)
       ,@i_non_par_price_var_bypass_5 VARCHAR(50)
       ,@i_non_par_price_state_5      VARCHAR(50)
       ,@iK3Mapped                    VARCHAR(50)
       ,@iReasonCodeLoc               VARCHAR(50)
       ,@iProductCodeLoc              VARCHAR(50)
       ,@iExhaustAllHierarchies       VARCHAR(50)
       ,@iAdditionalK3Codes           VARCHAR(50)
       ,@iK3EditRelationID            VARCHAR(50)
       ,@iK3EditRelationDesc          VARCHAR(50)
       ,@iMatchOnTaxonomy             VARCHAR(50)
       ,@iValidateBillNPI             VARCHAR(50)
       ,@iValidateMAID                VARCHAR(50)
       ,@iValidateReferringMAID       VARCHAR(50)
       ,@iValidateOrdOrAttMAID        VARCHAR(50)
	   ,@iSequestrationRuleID         VARCHAR(50) 
       ,@iSequestrationRuleDesc       VARCHAR(150)  
       ,@o_status                     INT
       ,@o_message                    VARCHAR(255)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TradingPartnersInbound837Den') IS NOT NULL
	DROP TABLE #TradingPartnersInbound837Den

CREATE TABLE #TradingPartnersInbound837Den
      (SearchID                     VARCHAR(200)
      ,i_entity_name                VARCHAR(50)       DEFAULT('837D_Inbound')
      ,i_Trading_partner_gid        VARCHAR(50)       DEFAULT('0')
      ,i_Key_Transaction_type       VARCHAR(50)       DEFAULT('0')
      ,i_Key_Direction              VARCHAR(50)       DEFAULT('0')
      ,i_Trxn_SID                   VARCHAR(50)       DEFAULT('0')
      ,i_Key_5                      VARCHAR(50)       DEFAULT('837D_Inbound')
      ,i_Key_6                      VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field               VARCHAR(50)       DEFAULT('0')
      ,iAction                      VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified         VARCHAR(20)       DEFAULT('')
      ,i_user_id                    VARCHAR(20)       DEFAULT('')
      ,i_Transaction_Type           VARCHAR(50)		  DEFAULT('837D')
      ,i_Direction                  VARCHAR(50)		  DEFAULT('I')
      ,i_Transaction_Purpose        VARCHAR(50)		  
      ,iDefManualClaim              VARCHAR(50)
      ,iMemberMatchID               VARCHAR(50)		  DEFAULT('')
      ,iMemberMatchDesc             VARCHAR(50)		  DEFAULT('')
      ,i999FileNamingID             VARCHAR(50)		  DEFAULT('')
      ,i999FileNamingDesc           VARCHAR(50)		  DEFAULT('')
      ,i_ReasonMappingID            VARCHAR(50)
      ,i_ReasonMappingDesc          VARCHAR(50)
      ,iNonParLoc1                  VARCHAR(50)
      ,iNonParValue1                VARCHAR(50)
      ,i_non_par_price_var_bypass_1 VARCHAR(50)
      ,iNonParLoc2                  VARCHAR(50)
      ,iNonParValue2                VARCHAR(50)
      ,i_non_par_price_var_bypass_2 VARCHAR(50)
      ,i_non_par_loc_3              VARCHAR(50)
      ,i_non_par_value_3            VARCHAR(50)
      ,i_non_par_price_var_bypass_3 VARCHAR(50)
      ,i_non_par_loc_4              VARCHAR(50)
      ,i_non_par_value_4            VARCHAR(50)
      ,i_non_par_price_var_bypass_4 VARCHAR(50)
      ,i_non_par_loc_5              VARCHAR(50)
      ,i_non_par_value_5            VARCHAR(50)
      ,i_non_par_price_var_bypass_5 VARCHAR(50)
      ,i_non_par_price_state_5      VARCHAR(50)
      ,iK3Mapped                    VARCHAR(50)
      ,iReasonCodeLoc               VARCHAR(50)
      ,iProductCodeLoc              VARCHAR(50)
      ,iExhaustAllHierarchies       VARCHAR(50)
      ,iAdditionalK3Codes           VARCHAR(50)
      ,iK3EditRelationID            VARCHAR(50)
      ,iK3EditRelationDesc          VARCHAR(50)		  DEFAULT('')
      ,iMatchOnTaxonomy             VARCHAR(50)
      ,iValidateBillNPI             VARCHAR(50)
      ,iValidateMAID                VARCHAR(50)
      ,iValidateReferringMAID       VARCHAR(50)		  DEFAULT('')
      ,iValidateOrdOrAttMAID        VARCHAR(50)		  DEFAULT('')
	  ,iSequestrationRuleID         VARCHAR(50) 
      ,iSequestrationRuleDesc       VARCHAR(150)  
      ,o_status                     INT
      ,o_message                    VARCHAR(255)
      ,record_id                    INT
      ,static_gid                   INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TradingPartnersInbound837Den
      (SearchID
      ,i_Transaction_Purpose
      ,iDefManualClaim
      ,i999FileNamingDesc
      ,i_ReasonMappingID
      ,iNonParLoc1
      ,iNonParValue1
      ,i_non_par_price_var_bypass_1
      ,iNonParLoc2
      ,iNonParValue2
      ,i_non_par_price_var_bypass_2
      ,i_non_par_loc_3
      ,i_non_par_value_3
      ,i_non_par_price_var_bypass_3
      ,i_non_par_loc_4
      ,i_non_par_value_4
      ,i_non_par_price_var_bypass_4
      ,i_non_par_loc_5
      ,i_non_par_value_5
      ,i_non_par_price_var_bypass_5
      ,i_non_par_price_state_5
      ,iK3Mapped
      ,iReasonCodeLoc
      ,iProductCodeLoc
      ,iExhaustAllHierarchies
      ,iAdditionalK3Codes
      ,iK3EditRelationID
      ,iMatchOnTaxonomy
      ,iValidateBillNPI
      ,iValidateMAID
	  ,iSequestrationRuleID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*TransactionPurpose]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DefaultforManualClaims]), 'N')
      ,ISNULL([999FileNamingID], '')
      ,ISNULL([RepriceReasonMappingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParLocation1]), '')
      ,ISNULL([RepricerNonParLocationValue1], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceVarBypassNonParVar1]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParLocation2]), '')
      ,ISNULL([RepricerNonParLocationValue2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceVarBypassNonParVar2]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParLocation3]), '')
      ,ISNULL([RepricerNonParLocationValue3], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceVarBypassNonParVar3]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParLocation4]), '')
      ,ISNULL([RepricerNonParLocationValue4], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceVarBypassNonParVar4]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParLocation5]), '')
      ,ISNULL([RepricerNonParLocationValue5], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceVarBypassNonParVar5]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerNonParSvcState5]), '**')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerMessageCodesinK3]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerReasonOrDRGError]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RepricerProductCodeSegment]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ExhaustAllAffiliationNetworks]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([APCStatusOCEorClinicalEditinK3]), 'N')
      ,ISNULL([K3RemarkCodeMappingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MatchOntaxonomyCode]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ValidateBillingProviderNPI]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ValidateRender&BillingProvMedicaidIDs]), 'N')
	  ,ISNULL([SequestrationAdjustmentID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TradingPartnersInbound837Den
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TradingPartnersInbound837Den
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TradingPartnersInbound837Den_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Trading_partner_gid
       ,i_Key_Transaction_type
       ,i_Key_Direction
       ,i_Trxn_SID
       ,i_Key_5
       ,i_Key_6
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,i_date_time_modified
       ,i_user_id
       ,i_Transaction_Type
       ,i_Direction
       ,i_Transaction_Purpose
       ,iDefManualClaim
       ,iMemberMatchID
       ,iMemberMatchDesc
       ,i999FileNamingID
       ,i999FileNamingDesc
       ,i_ReasonMappingID
       ,i_ReasonMappingDesc
       ,iNonParLoc1
       ,iNonParValue1
       ,i_non_par_price_var_bypass_1
       ,iNonParLoc2
       ,iNonParValue2
       ,i_non_par_price_var_bypass_2
       ,i_non_par_loc_3
       ,i_non_par_value_3
       ,i_non_par_price_var_bypass_3
       ,i_non_par_loc_4
       ,i_non_par_value_4
       ,i_non_par_price_var_bypass_4
       ,i_non_par_loc_5
       ,i_non_par_value_5
       ,i_non_par_price_var_bypass_5
       ,i_non_par_price_state_5
       ,iK3Mapped
       ,iReasonCodeLoc
       ,iProductCodeLoc
       ,iExhaustAllHierarchies
       ,iAdditionalK3Codes
       ,iK3EditRelationID
       ,iK3EditRelationDesc
       ,iMatchOnTaxonomy
       ,iValidateBillNPI
       ,iValidateMAID
       ,iValidateReferringMAID
       ,iValidateOrdOrAttMAID
	   ,iSequestrationRuleID         
       ,iSequestrationRuleDesc       
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TradingPartnersInbound837Den

   OPEN TradingPartnersInbound837Den_Cursor
  FETCH NEXT FROM TradingPartnersInbound837Den_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Trading_partner_gid
       ,@i_Key_Transaction_type
       ,@i_Key_Direction
       ,@i_Trxn_SID
       ,@i_Key_5
       ,@i_Key_6
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@i_date_time_modified
       ,@i_user_id
       ,@i_Transaction_Type
       ,@i_Direction
       ,@i_Transaction_Purpose
       ,@iDefManualClaim
       ,@iMemberMatchID
       ,@iMemberMatchDesc
       ,@i999FileNamingID
       ,@i999FileNamingDesc
       ,@i_ReasonMappingID
       ,@i_ReasonMappingDesc
       ,@iNonParLoc1
       ,@iNonParValue1
       ,@i_non_par_price_var_bypass_1
       ,@iNonParLoc2
       ,@iNonParValue2
       ,@i_non_par_price_var_bypass_2
       ,@i_non_par_loc_3
       ,@i_non_par_value_3
       ,@i_non_par_price_var_bypass_3
       ,@i_non_par_loc_4
       ,@i_non_par_value_4
       ,@i_non_par_price_var_bypass_4
       ,@i_non_par_loc_5
       ,@i_non_par_value_5
       ,@i_non_par_price_var_bypass_5
       ,@i_non_par_price_state_5
       ,@iK3Mapped
       ,@iReasonCodeLoc
       ,@iProductCodeLoc
       ,@iExhaustAllHierarchies
       ,@iAdditionalK3Codes
       ,@iK3EditRelationID
       ,@iK3EditRelationDesc
       ,@iMatchOnTaxonomy
       ,@iValidateBillNPI
       ,@iValidateMAID
       ,@iValidateReferringMAID
       ,@iValidateOrdOrAttMAID
	   ,@iSequestrationRuleID         
       ,@iSequestrationRuleDesc       
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Make sure to grab the second search criteria only
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 2

			--Get the gid for the trading partner
			SELECT @i_Trading_partner_gid	= Trading_Partner_gid
			  FROM Trading_Partner
			 WHERE record_status			= 'A'
			   AND Entity_id				= @SearchID

			EXEC dbo.prInbound_X12_837_AddModify
             @i_entity_name
            ,@i_Trading_partner_gid
            ,@i_Key_Transaction_type
            ,@i_Key_Direction
            ,@i_Trxn_SID
            ,@i_Key_5
            ,@i_Key_6
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@iAction
            ,@i_date_time_modified
            ,@i_user_id
            ,@i_Transaction_Type
            ,@i_Direction
            ,@i_Transaction_Purpose
            ,@iDefManualClaim
            ,@iMemberMatchID
            ,@iMemberMatchDesc
            ,@i999FileNamingID
            ,@i999FileNamingDesc
            ,@i_ReasonMappingID
            ,@i_ReasonMappingDesc
            ,@iNonParLoc1
            ,@iNonParValue1
            ,@i_non_par_price_var_bypass_1
            ,@iNonParLoc2
            ,@iNonParValue2
            ,@i_non_par_price_var_bypass_2
            ,@i_non_par_loc_3
            ,@i_non_par_value_3
            ,@i_non_par_price_var_bypass_3
            ,@i_non_par_loc_4
            ,@i_non_par_value_4
            ,@i_non_par_price_var_bypass_4
            ,@i_non_par_loc_5
            ,@i_non_par_value_5
            ,@i_non_par_price_var_bypass_5
            ,@i_non_par_price_state_5
            ,@iK3Mapped
            ,@iReasonCodeLoc
            ,@iProductCodeLoc
            ,@iExhaustAllHierarchies
            ,@iAdditionalK3Codes
            ,@iK3EditRelationID
            ,@iK3EditRelationDesc
            ,@iMatchOnTaxonomy
            ,@iValidateBillNPI
            ,@iValidateMAID
            ,@iValidateReferringMAID
            ,@iValidateOrdOrAttMAID
			,@iSequestrationRuleID         
			,@iSequestrationRuleDesc             
			,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Transaction_Purpose, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TradingPartnersInbound837Den_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Trading_partner_gid
             ,@i_Key_Transaction_type
             ,@i_Key_Direction
             ,@i_Trxn_SID
             ,@i_Key_5
             ,@i_Key_6
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@i_date_time_modified
             ,@i_user_id
             ,@i_Transaction_Type
             ,@i_Direction
             ,@i_Transaction_Purpose
             ,@iDefManualClaim
             ,@iMemberMatchID
             ,@iMemberMatchDesc
             ,@i999FileNamingID
             ,@i999FileNamingDesc
             ,@i_ReasonMappingID
             ,@i_ReasonMappingDesc
             ,@iNonParLoc1
             ,@iNonParValue1
             ,@i_non_par_price_var_bypass_1
             ,@iNonParLoc2
             ,@iNonParValue2
             ,@i_non_par_price_var_bypass_2
             ,@i_non_par_loc_3
             ,@i_non_par_value_3
             ,@i_non_par_price_var_bypass_3
             ,@i_non_par_loc_4
             ,@i_non_par_value_4
             ,@i_non_par_price_var_bypass_4
             ,@i_non_par_loc_5
             ,@i_non_par_value_5
             ,@i_non_par_price_var_bypass_5
             ,@i_non_par_price_state_5
             ,@iK3Mapped
             ,@iReasonCodeLoc
             ,@iProductCodeLoc
             ,@iExhaustAllHierarchies
             ,@iAdditionalK3Codes
             ,@iK3EditRelationID
             ,@iK3EditRelationDesc
             ,@iMatchOnTaxonomy
             ,@iValidateBillNPI
             ,@iValidateMAID
             ,@iValidateReferringMAID
             ,@iValidateOrdOrAttMAID
			 ,@iSequestrationRuleID         
			 ,@iSequestrationRuleDesc              
			 ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TradingPartnersInbound837Den_Cursor
DEALLOCATE TradingPartnersInbound837Den_Cursor

END
GO