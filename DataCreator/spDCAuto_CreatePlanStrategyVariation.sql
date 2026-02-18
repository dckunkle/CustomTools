IF OBJECT_ID('dbo.spDCAuto_CreatePlanStrategyVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePlanStrategyVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePlanStrategyVariation
Purpose:    Create planstrategyvariation data from CorderAutomation
Method:     PlanStrategyVariation
Screen GID: 107
Procedure:  dbo.prPlanStrategyAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePlanStrategyVariation '100-Config%', 22, 'PlanStrategyVariation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePlanStrategyVariation
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

DECLARE @i_entity_name                              VARCHAR(50)
       ,@i_Strategy_gid                             VARCHAR(50)
       ,@iKeyEffDate                                VARCHAR(50)
       ,@i_key_3_field                              VARCHAR(50)
       ,@i_key_4_field                              VARCHAR(50)
       ,@i_key_5_field                              VARCHAR(50)
       ,@i_key_6_field                              VARCHAR(50)
       ,@i_key_7_field                              VARCHAR(50)
       ,@i_key_8_field                              VARCHAR(50)
       ,@i_key_9_field                              VARCHAR(50)
       ,@i_key_10_field                             VARCHAR(50)
       ,@i_action                                   VARCHAR(10)
       ,@i_Date_Time_Modified                       VARCHAR(200)
       ,@iUserID                                    VARCHAR(25)
       ,@i_strategy_id                              VARCHAR(50)
       ,@i_strategy_name                            VARCHAR(150)
       ,@i_effective_date                           VARCHAR(50)
       ,@i_termination_date                         VARCHAR(50)
       ,@i_System_Lists                             VARCHAR(50)
       ,@i_Support_Codes                            VARCHAR(50)
       ,@i_EOB                                      VARCHAR(50)
       ,@i_Alias                                    VARCHAR(50)
       ,@i_Network_Search_ID                        VARCHAR(50)
       ,@i_Network_Search_Desc                      VARCHAR(50)
       ,@i_rx_network_strategy_id                   VARCHAR(50)
       ,@i_rx_network_strategy_Desc                 VARCHAR(100)
       ,@i_Copay_Strategy_ID                        VARCHAR(50)
       ,@i_Copay_Strategy_Desc                      VARCHAR(50)
       ,@i_Price_Strategy_ID                        VARCHAR(50)
       ,@i_Price_Strategy_Desc                      VARCHAR(50)
       ,@i_Plan_Price_Strat_ID                      VARCHAR(50)
       ,@i_Plan_Price_Strat_Desc                    VARCHAR(50)
       ,@i_Client_Price_Strat_ID                    VARCHAR(50)
       ,@i_Client_Price_Strat_Desc                  VARCHAR(50)
       ,@i_Benefit_Strategy_ID                      VARCHAR(50)
       ,@i_Benefit_Strategy_Desc                    VARCHAR(50)
       ,@i_DUE_Strategy_ID                          VARCHAR(50)
       ,@i_DUE_Strategy_Desc                        VARCHAR(50)
       ,@i_Coverage_Strategy_ID                     VARCHAR(50)
       ,@i_Coverage_Strategy_Desc                   VARCHAR(50)
       ,@i_Auth_Match_ID                            VARCHAR(50)
       ,@i_Auth_Match_Desc                          VARCHAR(50)
       ,@i_Processing_Policy_ID                     VARCHAR(50)
       ,@i_Processing_Policy_Desc                   VARCHAR(50)
       ,@i_Rebate_Strategy_ID                       VARCHAR(50)
       ,@i_Rebate_Strategy_Desc                     VARCHAR(50)
       ,@i_Comp_Schedule_ID                         VARCHAR(50)
       ,@i_Comp_Schedule_Desc                       VARCHAR(50)
       ,@iCodePairingID                             VARCHAR(50)
       ,@iCodePairingDesc                           VARCHAR(50)
       ,@i_pcp_required                             VARCHAR(50)
       ,@i_CapAffiliationID                         VARCHAR(50)
       ,@i_pcp_adj_required                         VARCHAR(50)
       ,@i_cost_required                            VARCHAR(50)
       ,@i_ucr_required                             VARCHAR(50)
       ,@iClinicalEngineID                          VARCHAR(50)
       ,@iClinicalEngineDesc                        VARCHAR(50)
       ,@iAutoAdjAccidentFlag                       VARCHAR(50)
       ,@iPreDetCOBProcess                          VARCHAR(50)
       ,@iPreDetCarryRules                          VARCHAR(50)
       ,@i_generateAutoOfficeVisit                  VARCHAR(50)
       ,@i_paymentIntegrity_RemarkCode              VARCHAR(50)
       ,@i_paymentIntegrity_RemarkCode_Desc         VARCHAR(1000)
       ,@iNursingFacServicesPatRespRulesetID        VARCHAR(50)
       ,@iNursingFacServicesPatRespRulesetDesc      VARCHAR(500)
       ,@iPayerCompassOONContractID                 VARCHAR(200)
       ,@iPayerCompassClinicalEditContractID        VARCHAR(200)
       ,@iPayerCompassDefaultServiceAreaContractID  VARCHAR(200)
       ,@iPayerCompassEditCodeRelationsID           VARCHAR(50)
       ,@iPayerCompassEditCodeRelationsDesc         VARCHAR(500)
       ,@iCOBMethod                                 VARCHAR(50)
       ,@iPayUptoMedicareABCOBException             VARCHAR(50)
       ,@iPayMedicareBCOBException                  VARCHAR(50)
       ,@iCOBMedicareBExceptionCodeListID           VARCHAR(50)
       ,@iCOBMedicareBExceptionCodeListDesc         VARCHAR(500)
       ,@iCOBMedicareBExceptionReviewRemarkCodeID   VARCHAR(50)
       ,@iCOBMedicareBExceptionReviewRemarkCodeDesc VARCHAR(1000)
       ,@i_Plan_COB_Type                            VARCHAR(50)
       ,@i_Medi_Supp_Deductible                     VARCHAR(50)
       ,@i_EAPGGrouperPricerEnabled                 VARCHAR(50)
       ,@i_ClinicalEditID                           VARCHAR(50)
       ,@i_ClinicalEditDesc                         VARCHAR(500)
       ,@o_status                                   INT
       ,@o_message                                  VARCHAR(255)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PlanStrategyVariation') IS NOT NULL
	DROP TABLE #PlanStrategyVariation

CREATE TABLE #PlanStrategyVariation
      (SearchID                                   VARCHAR(200)
      ,i_entity_name                              VARCHAR(50)       DEFAULT('Plan_Strategy_Variations')
      ,i_Strategy_gid                             VARCHAR(50)       DEFAULT('0')
      ,iKeyEffDate                                VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                             VARCHAR(50)       DEFAULT('0')
      ,i_action                                   VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified                       VARCHAR(200)      DEFAULT('')
      ,iUserID                                    VARCHAR(25)       DEFAULT('')
      ,i_strategy_id                              VARCHAR(50)
      ,i_strategy_name                            VARCHAR(150)
      ,i_effective_date                           VARCHAR(50)
      ,i_termination_date                         VARCHAR(50)
      ,i_System_Lists                             VARCHAR(50)
      ,i_Support_Codes                            VARCHAR(50)
      ,i_EOB                                      VARCHAR(50)
      ,i_Alias                                    VARCHAR(50)
      ,i_Network_Search_ID                        VARCHAR(50)
      ,i_Network_Search_Desc                      VARCHAR(50)
      ,i_rx_network_strategy_id                   VARCHAR(50)
      ,i_rx_network_strategy_Desc                 VARCHAR(100)
      ,i_Copay_Strategy_ID                        VARCHAR(50)
      ,i_Copay_Strategy_Desc                      VARCHAR(50)
      ,i_Price_Strategy_ID                        VARCHAR(50)
      ,i_Price_Strategy_Desc                      VARCHAR(50)
      ,i_Plan_Price_Strat_ID                      VARCHAR(50)
      ,i_Plan_Price_Strat_Desc                    VARCHAR(50)
      ,i_Client_Price_Strat_ID                    VARCHAR(50)
      ,i_Client_Price_Strat_Desc                  VARCHAR(50)
      ,i_Benefit_Strategy_ID                      VARCHAR(50)
      ,i_Benefit_Strategy_Desc                    VARCHAR(50)
      ,i_DUE_Strategy_ID                          VARCHAR(50)
      ,i_DUE_Strategy_Desc                        VARCHAR(50)
      ,i_Coverage_Strategy_ID                     VARCHAR(50)
      ,i_Coverage_Strategy_Desc                   VARCHAR(50)
      ,i_Auth_Match_ID                            VARCHAR(50)
      ,i_Auth_Match_Desc                          VARCHAR(50)
      ,i_Processing_Policy_ID                     VARCHAR(50)
      ,i_Processing_Policy_Desc                   VARCHAR(50)
      ,i_Rebate_Strategy_ID                       VARCHAR(50)
      ,i_Rebate_Strategy_Desc                     VARCHAR(50)
      ,i_Comp_Schedule_ID                         VARCHAR(50)
      ,i_Comp_Schedule_Desc                       VARCHAR(50)
      ,iCodePairingID                             VARCHAR(50)
      ,iCodePairingDesc                           VARCHAR(50)
      ,i_pcp_required                             VARCHAR(50)
      ,i_CapAffiliationID                         VARCHAR(50)
      ,i_pcp_adj_required                         VARCHAR(50)
      ,i_cost_required                            VARCHAR(50)
      ,i_ucr_required                             VARCHAR(50)
      ,iClinicalEngineID                          VARCHAR(50)
      ,iClinicalEngineDesc                        VARCHAR(50)
      ,iAutoAdjAccidentFlag                       VARCHAR(50)
      ,iPreDetCOBProcess                          VARCHAR(50)
      ,iPreDetCarryRules                          VARCHAR(50)
      ,i_generateAutoOfficeVisit                  VARCHAR(50)
      ,i_paymentIntegrity_RemarkCode              VARCHAR(50)
      ,i_paymentIntegrity_RemarkCode_Desc         VARCHAR(1000)
      ,iNursingFacServicesPatRespRulesetID        VARCHAR(50)
      ,iNursingFacServicesPatRespRulesetDesc      VARCHAR(500)
      ,iPayerCompassOONContractID                 VARCHAR(200)
      ,iPayerCompassClinicalEditContractID        VARCHAR(200)
      ,iPayerCompassDefaultServiceAreaContractID  VARCHAR(200)
      ,iPayerCompassEditCodeRelationsID           VARCHAR(50)
      ,iPayerCompassEditCodeRelationsDesc         VARCHAR(500)
      ,iCOBMethod                                 VARCHAR(50)
      ,iPayUptoMedicareABCOBException             VARCHAR(50)
      ,iPayMedicareBCOBException                  VARCHAR(50)
      ,iCOBMedicareBExceptionCodeListID           VARCHAR(50)
      ,iCOBMedicareBExceptionCodeListDesc         VARCHAR(500)
      ,iCOBMedicareBExceptionReviewRemarkCodeID   VARCHAR(50)
      ,iCOBMedicareBExceptionReviewRemarkCodeDesc VARCHAR(1000)
      ,i_Plan_COB_Type                            VARCHAR(50)
      ,i_Medi_Supp_Deductible                     VARCHAR(50)
      ,i_EAPGGrouperPricerEnabled                 VARCHAR(50)
      ,i_ClinicalEditID                           VARCHAR(50)
      ,i_ClinicalEditDesc                         VARCHAR(500)
      ,o_status                                   INT
      ,o_message                                  VARCHAR(255)
      ,record_id                                  INT
      ,static_gid                                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PlanStrategyVariation
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_System_Lists
      ,i_Support_Codes
      ,i_EOB
      ,i_Alias
      ,i_Network_Search_ID
      ,i_Copay_Strategy_ID
      ,i_Price_Strategy_ID
      ,i_Benefit_Strategy_ID
      ,i_Coverage_Strategy_ID
      ,i_Auth_Match_ID
      ,i_Processing_Policy_ID
      ,i_Rebate_Strategy_ID
      ,i_Comp_Schedule_ID
      ,iCodePairingID
      ,i_pcp_required
      ,i_CapAffiliationID
      ,i_pcp_adj_required
      ,i_cost_required
      ,i_ucr_required
      ,iClinicalEngineID
      ,iAutoAdjAccidentFlag
      ,iPreDetCOBProcess
      ,iPreDetCarryRules
      ,i_generateAutoOfficeVisit
      ,i_paymentIntegrity_RemarkCode
      ,iPayerCompassOONContractID
      ,iPayerCompassClinicalEditContractID
      ,iPayerCompassDefaultServiceAreaContractID
      ,iPayerCompassEditCodeRelationsID
      ,iCOBMethod
      ,iPayUptoMedicareABCOBException
      ,iPayMedicareBCOBException
      ,iCOBMedicareBExceptionCodeListID 
      ,iCOBMedicareBExceptionReviewRemarkCodeID
      ,i_EAPGGrouperPricerEnabled
      ,i_ClinicalEditID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BaseRules]), 'DENTAL')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DefaultStatus]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EOB]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseAliasCodes]), 'N')
      ,ISNULL([Common_SuperNetworkID], '')
      ,ISNULL([Common_CopayLevelsID], '')
      ,ISNULL([Common_PriceStrategyID], '')
      ,ISNULL([Common_BenefitStrategyID], '')
      ,ISNULL([Common_CodeLimitationsID], '')
      ,ISNULL([Common_AuthMatchID], '')
      ,ISNULL([Common_RemarkCodeRelationsID], '')
      ,ISNULL([Common_RebateStrategyID], '')
      ,ISNULL([Common_ComparisonScheduleID], '')
      ,ISNULL([Common_CodePairingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PCPRequiredforEligibility]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CAPAffiliationID]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PCPRequiredforAdjudication]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubmittedCostRequired]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UCRRequired]), 'N')
      ,ISNULL([Common_ClinicalEngineID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AutoAdjudicateAccident]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PTE/PRED:EnforceCOBEdits]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PTE/PRED:CarryFwdOffsets]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_GenerateOfficeVisit]), 'N')
      ,ISNULL([Common_PaymentIntegrityRemarkCodeID], '')
      ,ISNULL([PayerCompass_OONProviderContractID], '')
      ,ISNULL([PayerCompass_ClinicalEdits-OnlyContractID], '')
      ,ISNULL([PayerCompass_DefaultServiceAreaContractID], '')
      ,ISNULL([PayerCompass_EditCodeRelationsID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMedSupp_CoordinationofBenefits(COB)_Method]), 'TRAD')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMedSupp_PayuptoMedicareA/BDed+Coins]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMedSupp_PayMedicareBDed+Coins]), 'N')
      ,ISNULL([COBMedSupp_CodeListID], '')
      ,ISNULL([COBMedSupp_ReviewRemarkCodeID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EAPG_Grouper-PricerEnabled]), 'N')
      ,ISNULL([EAPG_EditCodeRelationsID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PlanStrategyVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'
   AND [ACTION]			LIKE 'ADD%'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PlanStrategyVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PlanStrategyVariation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Strategy_gid
       ,iKeyEffDate
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_strategy_id
       ,i_strategy_name
       ,i_effective_date
       ,i_termination_date
       ,i_System_Lists
       ,i_Support_Codes
       ,i_EOB
       ,i_Alias
       ,i_Network_Search_ID
       ,i_Network_Search_Desc
       ,i_rx_network_strategy_id
       ,i_rx_network_strategy_Desc
       ,i_Copay_Strategy_ID
       ,i_Copay_Strategy_Desc
       ,i_Price_Strategy_ID
       ,i_Price_Strategy_Desc
       ,i_Plan_Price_Strat_ID
       ,i_Plan_Price_Strat_Desc
       ,i_Client_Price_Strat_ID
       ,i_Client_Price_Strat_Desc
       ,i_Benefit_Strategy_ID
       ,i_Benefit_Strategy_Desc
       ,i_DUE_Strategy_ID
       ,i_DUE_Strategy_Desc
       ,i_Coverage_Strategy_ID
       ,i_Coverage_Strategy_Desc
       ,i_Auth_Match_ID
       ,i_Auth_Match_Desc
       ,i_Processing_Policy_ID
       ,i_Processing_Policy_Desc
       ,i_Rebate_Strategy_ID
       ,i_Rebate_Strategy_Desc
       ,i_Comp_Schedule_ID
       ,i_Comp_Schedule_Desc
       ,iCodePairingID
       ,iCodePairingDesc
       ,i_pcp_required
       ,i_CapAffiliationID
       ,i_pcp_adj_required
       ,i_cost_required
       ,i_ucr_required
       ,iClinicalEngineID
       ,iClinicalEngineDesc
       ,iAutoAdjAccidentFlag
       ,iPreDetCOBProcess
       ,iPreDetCarryRules
       ,i_generateAutoOfficeVisit
       ,i_paymentIntegrity_RemarkCode
       ,i_paymentIntegrity_RemarkCode_Desc
       ,iNursingFacServicesPatRespRulesetID
       ,iNursingFacServicesPatRespRulesetDesc
       ,iPayerCompassOONContractID
       ,iPayerCompassClinicalEditContractID
       ,iPayerCompassDefaultServiceAreaContractID
       ,iPayerCompassEditCodeRelationsID
       ,iPayerCompassEditCodeRelationsDesc
       ,iCOBMethod
       ,iPayUptoMedicareABCOBException
       ,iPayMedicareBCOBException
       ,iCOBMedicareBExceptionCodeListID
       ,iCOBMedicareBExceptionCodeListDesc
       ,iCOBMedicareBExceptionReviewRemarkCodeID
       ,iCOBMedicareBExceptionReviewRemarkCodeDesc
       ,i_Plan_COB_Type
       ,i_Medi_Supp_Deductible
       ,i_EAPGGrouperPricerEnabled
       ,i_ClinicalEditID
       ,i_ClinicalEditDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PlanStrategyVariation

   OPEN PlanStrategyVariation_Cursor
  FETCH NEXT FROM PlanStrategyVariation_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Strategy_gid
       ,@iKeyEffDate
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_strategy_id
       ,@i_strategy_name
       ,@i_effective_date
       ,@i_termination_date
       ,@i_System_Lists
       ,@i_Support_Codes
       ,@i_EOB
       ,@i_Alias
       ,@i_Network_Search_ID
       ,@i_Network_Search_Desc
       ,@i_rx_network_strategy_id
       ,@i_rx_network_strategy_Desc
       ,@i_Copay_Strategy_ID
       ,@i_Copay_Strategy_Desc
       ,@i_Price_Strategy_ID
       ,@i_Price_Strategy_Desc
       ,@i_Plan_Price_Strat_ID
       ,@i_Plan_Price_Strat_Desc
       ,@i_Client_Price_Strat_ID
       ,@i_Client_Price_Strat_Desc
       ,@i_Benefit_Strategy_ID
       ,@i_Benefit_Strategy_Desc
       ,@i_DUE_Strategy_ID
       ,@i_DUE_Strategy_Desc
       ,@i_Coverage_Strategy_ID
       ,@i_Coverage_Strategy_Desc
       ,@i_Auth_Match_ID
       ,@i_Auth_Match_Desc
       ,@i_Processing_Policy_ID
       ,@i_Processing_Policy_Desc
       ,@i_Rebate_Strategy_ID
       ,@i_Rebate_Strategy_Desc
       ,@i_Comp_Schedule_ID
       ,@i_Comp_Schedule_Desc
       ,@iCodePairingID
       ,@iCodePairingDesc
       ,@i_pcp_required
       ,@i_CapAffiliationID
       ,@i_pcp_adj_required
       ,@i_cost_required
       ,@i_ucr_required
       ,@iClinicalEngineID
       ,@iClinicalEngineDesc
       ,@iAutoAdjAccidentFlag
       ,@iPreDetCOBProcess
       ,@iPreDetCarryRules
       ,@i_generateAutoOfficeVisit
       ,@i_paymentIntegrity_RemarkCode
       ,@i_paymentIntegrity_RemarkCode_Desc
       ,@iNursingFacServicesPatRespRulesetID
       ,@iNursingFacServicesPatRespRulesetDesc
       ,@iPayerCompassOONContractID
       ,@iPayerCompassClinicalEditContractID
       ,@iPayerCompassDefaultServiceAreaContractID
       ,@iPayerCompassEditCodeRelationsID
       ,@iPayerCompassEditCodeRelationsDesc
       ,@iCOBMethod
       ,@iPayUptoMedicareABCOBException
       ,@iPayMedicareBCOBException
       ,@iCOBMedicareBExceptionCodeListID
       ,@iCOBMedicareBExceptionCodeListDesc
       ,@iCOBMedicareBExceptionReviewRemarkCodeID
       ,@iCOBMedicareBExceptionReviewRemarkCodeDesc
       ,@i_Plan_COB_Type
       ,@i_Medi_Supp_Deductible
       ,@i_EAPGGrouperPricerEnabled
       ,@i_ClinicalEditID
       ,@i_ClinicalEditDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the first search criteria only
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @i_Strategy_gid		= plan_strategy_gid
			  FROM Plan_Strategy_Names
			 WHERE plan_strategy_id		= @SearchID

			SET @i_strategy_id = @SearchID

			EXEC dbo.prPlanStrategyAdd
             @i_entity_name
            ,@i_Strategy_gid
            ,@iKeyEffDate
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_Date_Time_Modified
            ,@iUserID
            ,@i_strategy_id
            ,@i_strategy_name
            ,@i_effective_date
            ,@i_termination_date
            ,@i_System_Lists
            ,@i_Support_Codes
            ,@i_EOB
            ,@i_Alias
            ,@i_Network_Search_ID
            ,@i_Network_Search_Desc
            ,@i_rx_network_strategy_id
            ,@i_rx_network_strategy_Desc
            ,@i_Copay_Strategy_ID
            ,@i_Copay_Strategy_Desc
            ,@i_Price_Strategy_ID
            ,@i_Price_Strategy_Desc
            ,@i_Plan_Price_Strat_ID
            ,@i_Plan_Price_Strat_Desc
            ,@i_Client_Price_Strat_ID
            ,@i_Client_Price_Strat_Desc
            ,@i_Benefit_Strategy_ID
            ,@i_Benefit_Strategy_Desc
            ,@i_DUE_Strategy_ID
            ,@i_DUE_Strategy_Desc
            ,@i_Coverage_Strategy_ID
            ,@i_Coverage_Strategy_Desc
            ,@i_Auth_Match_ID
            ,@i_Auth_Match_Desc
            ,@i_Processing_Policy_ID
            ,@i_Processing_Policy_Desc
            ,@i_Rebate_Strategy_ID
            ,@i_Rebate_Strategy_Desc
            ,@i_Comp_Schedule_ID
            ,@i_Comp_Schedule_Desc
            ,@iCodePairingID
            ,@iCodePairingDesc
            ,@i_pcp_required
            ,@i_CapAffiliationID
            ,@i_pcp_adj_required
            ,@i_cost_required
            ,@i_ucr_required
            ,@iClinicalEngineID
            ,@iClinicalEngineDesc
            ,@iAutoAdjAccidentFlag
            ,@iPreDetCOBProcess
            ,@iPreDetCarryRules
            ,@i_generateAutoOfficeVisit
            ,@i_paymentIntegrity_RemarkCode
            ,@i_paymentIntegrity_RemarkCode_Desc
            ,@iNursingFacServicesPatRespRulesetID
            ,@iNursingFacServicesPatRespRulesetDesc
            ,@iPayerCompassOONContractID
            ,@iPayerCompassClinicalEditContractID
            ,@iPayerCompassDefaultServiceAreaContractID
            ,@iPayerCompassEditCodeRelationsID
            ,@iPayerCompassEditCodeRelationsDesc
            ,@iCOBMethod
            ,@iPayUptoMedicareABCOBException
            ,@iPayMedicareBCOBException
            ,@iCOBMedicareBExceptionCodeListID
            ,@iCOBMedicareBExceptionCodeListDesc
            ,@iCOBMedicareBExceptionReviewRemarkCodeID
            ,@iCOBMedicareBExceptionReviewRemarkCodeDesc
            ,@i_Plan_COB_Type
            ,@i_Medi_Supp_Deductible
            ,@i_EAPGGrouperPricerEnabled
            ,@i_ClinicalEditID
            ,@i_ClinicalEditDesc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_effective_date, @i_termination_date, @status, @err_num, @err_msg

        FETCH NEXT FROM PlanStrategyVariation_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Strategy_gid
             ,@iKeyEffDate
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_strategy_id
             ,@i_strategy_name
             ,@i_effective_date
             ,@i_termination_date
             ,@i_System_Lists
             ,@i_Support_Codes
             ,@i_EOB
             ,@i_Alias
             ,@i_Network_Search_ID
             ,@i_Network_Search_Desc
             ,@i_rx_network_strategy_id
             ,@i_rx_network_strategy_Desc
             ,@i_Copay_Strategy_ID
             ,@i_Copay_Strategy_Desc
             ,@i_Price_Strategy_ID
             ,@i_Price_Strategy_Desc
             ,@i_Plan_Price_Strat_ID
             ,@i_Plan_Price_Strat_Desc
             ,@i_Client_Price_Strat_ID
             ,@i_Client_Price_Strat_Desc
             ,@i_Benefit_Strategy_ID
             ,@i_Benefit_Strategy_Desc
             ,@i_DUE_Strategy_ID
             ,@i_DUE_Strategy_Desc
             ,@i_Coverage_Strategy_ID
             ,@i_Coverage_Strategy_Desc
             ,@i_Auth_Match_ID
             ,@i_Auth_Match_Desc
             ,@i_Processing_Policy_ID
             ,@i_Processing_Policy_Desc
             ,@i_Rebate_Strategy_ID
             ,@i_Rebate_Strategy_Desc
             ,@i_Comp_Schedule_ID
             ,@i_Comp_Schedule_Desc
             ,@iCodePairingID
             ,@iCodePairingDesc
             ,@i_pcp_required
             ,@i_CapAffiliationID
             ,@i_pcp_adj_required
             ,@i_cost_required
             ,@i_ucr_required
             ,@iClinicalEngineID
             ,@iClinicalEngineDesc
             ,@iAutoAdjAccidentFlag
             ,@iPreDetCOBProcess
             ,@iPreDetCarryRules
             ,@i_generateAutoOfficeVisit
             ,@i_paymentIntegrity_RemarkCode
             ,@i_paymentIntegrity_RemarkCode_Desc
             ,@iNursingFacServicesPatRespRulesetID
             ,@iNursingFacServicesPatRespRulesetDesc
             ,@iPayerCompassOONContractID
             ,@iPayerCompassClinicalEditContractID
             ,@iPayerCompassDefaultServiceAreaContractID
             ,@iPayerCompassEditCodeRelationsID
             ,@iPayerCompassEditCodeRelationsDesc
             ,@iCOBMethod
             ,@iPayUptoMedicareABCOBException
             ,@iPayMedicareBCOBException
             ,@iCOBMedicareBExceptionCodeListID
             ,@iCOBMedicareBExceptionCodeListDesc
             ,@iCOBMedicareBExceptionReviewRemarkCodeID
             ,@iCOBMedicareBExceptionReviewRemarkCodeDesc
             ,@i_Plan_COB_Type
             ,@i_Medi_Supp_Deductible
             ,@i_EAPGGrouperPricerEnabled
             ,@i_ClinicalEditID
             ,@i_ClinicalEditDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PlanStrategyVariation_Cursor
DEALLOCATE PlanStrategyVariation_Cursor

END
GO