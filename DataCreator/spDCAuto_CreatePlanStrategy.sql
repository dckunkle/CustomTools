IF OBJECT_ID('dbo.spDCAuto_CreatePlanStrategy') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePlanStrategy AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePlanStrategy
Purpose:    Create planstrategy data from CorderAutomation
Method:     PlanStrategy
Screen GID: 108
Procedure:  dbo.prPlanStrategyNameAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePlanStrategy '100-Config%', 22, 'PlanStrategy'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePlanStrategy
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
       ,@i_key_1_field                              VARCHAR(50)
       ,@i_key_2_field                              VARCHAR(50)
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
       ,@i_model_strategy_id                        VARCHAR(50)
       ,@i_model_strategy_name                      VARCHAR(150)
       ,@i_plan_type                                VARCHAR(50)
       ,@i_effective_date                           VARCHAR(50)
       ,@i_termination_date                         VARCHAR(50)
       ,@i_System_Lists                             VARCHAR(50)
       ,@i_Support_Codes                            VARCHAR(50)
       ,@i_EOB                                      VARCHAR(50)
       ,@i_Alias                                    VARCHAR(50)
       ,@i_Network_Search_ID                        VARCHAR(50)
       ,@i_Network_Search_Desc                      VARCHAR(50)
       ,@i_rx_network_strategy_ID                   VARCHAR(50)
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
       ,@i_DUE_Strategy_Desc                        VARCHAR(100)
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
       ,@i_planVariationLookup                      VARCHAR(50)
       ,@i_generateAutoOfficeVisit                  VARCHAR(50)
       ,@i_paymentIntegrity_RemarkCode              VARCHAR(50)
       ,@i_paymentIntegrity_RemarkCode_Desc         VARCHAR(1000)
       ,@iNursingFacServicesPatRespRulesetID        VARCHAR(50)
       ,@iNursingFacServicesPatRespRulesetDesc      VARCHAR(500)
       ,@iIsMedicareAdvantage                       VARCHAR(50)
       ,@i_bc_contract_number                       VARCHAR(50)
       ,@i_bs_contract_number                       VARCHAR(50)
       ,@i_dmds_group_number                        VARCHAR(50)
       ,@i_section                                  VARCHAR(50)
       ,@i_alpha_prefix                             VARCHAR(50)
       ,@i_variation                                VARCHAR(50)
       ,@i_deductible                               VARCHAR(50)
       ,@i_out_of_pocket                            VARCHAR(50)
       ,@i_maternity                                VARCHAR(50)
       ,@i_ob_wait_period                           VARCHAR(50)
       ,@i_preex_wait_period                        VARCHAR(50)
       ,@i_plan_summary_url                         VARCHAR(200)
       ,@i_plan_contact_email                       VARCHAR(100)
       ,@i_Age_Bump                                 VARCHAR(50)
       ,@i_Durational_Bump                          VARCHAR(50)
       ,@i_StateFileType                            VARCHAR(50)
       ,@i_StateFileDate                            VARCHAR(50)
       ,@i_State_File_Prior_Days                    VARCHAR(50)
       ,@i_Correspondence                           VARCHAR(50)
       ,@i_Guarantee_Period                         VARCHAR(50)
       ,@i_Guarantee_Units                          VARCHAR(50)
       ,@i_on_exchange                              VARCHAR(50)
       ,@i_Security_Deposit                         INT
       ,@i_Carrier_ID                               VARCHAR(50)
       ,@i_Carrier_Name                             VARCHAR(50)
       ,@i_Generic_Plan_ID                          VARCHAR(50)
       ,@i_Other_Plan_ID                            VARCHAR(50)
       ,@iAPTCAllowed                               VARCHAR(50)
       ,@iCSRAllowed                                VARCHAR(50)
       ,@iMetallicLevel                             VARCHAR(50)
       ,@iActuarialValue                            VARCHAR(50)
       ,@i_hios_plan_id                             VARCHAR(50)
       ,@i_tenant_id                                VARCHAR(50)
       ,@iPayerCompassOONContractID                 VARCHAR(200)
       ,@iPayerCompassClinicalEditContractID        VARCHAR(200)
       ,@iPayerCompassDefaultServiceAreaContractID  VARCHAR(200)
       ,@iPayerCompassEditCodeRelationsID           VARCHAR(50)
       ,@iPayerCompassEditCodeRelationsDesc         VARCHAR(500)
       ,@iCOBMethod                                 VARCHAR(50)
       ,@i_edi_837_claim_COB_indicated              VARCHAR(50)
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

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PlanStrategy') IS NOT NULL
	DROP TABLE #PlanStrategy

CREATE TABLE #PlanStrategy
      (SearchID                                   VARCHAR(200)
      ,i_entity_name                              VARCHAR(50)       DEFAULT('Plan_Strategy')
      ,i_key_1_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field                              VARCHAR(50)       DEFAULT('0')
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
      ,i_model_strategy_id                        VARCHAR(50)
      ,i_model_strategy_name                      VARCHAR(150)
      ,i_plan_type                                VARCHAR(50)
      ,i_effective_date                           VARCHAR(50)
      ,i_termination_date                         VARCHAR(50)
      ,i_System_Lists                             VARCHAR(50)
      ,i_Support_Codes                            VARCHAR(50)
      ,i_EOB                                      VARCHAR(50)
      ,i_Alias                                    VARCHAR(50)
      ,i_Network_Search_ID                        VARCHAR(50)
      ,i_Network_Search_Desc                      VARCHAR(50)
      ,i_rx_network_strategy_ID                   VARCHAR(50)
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
      ,i_DUE_Strategy_Desc                        VARCHAR(100)
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
      ,i_planVariationLookup                      VARCHAR(50)
      ,i_generateAutoOfficeVisit                  VARCHAR(50)
      ,i_paymentIntegrity_RemarkCode              VARCHAR(50)
      ,i_paymentIntegrity_RemarkCode_Desc         VARCHAR(1000)
      ,iNursingFacServicesPatRespRulesetID        VARCHAR(50)
      ,iNursingFacServicesPatRespRulesetDesc      VARCHAR(500)
      ,iIsMedicareAdvantage                       VARCHAR(50)
      ,i_bc_contract_number                       VARCHAR(50)
      ,i_bs_contract_number                       VARCHAR(50)
      ,i_dmds_group_number                        VARCHAR(50)
      ,i_section                                  VARCHAR(50)
      ,i_alpha_prefix                             VARCHAR(50)
      ,i_variation                                VARCHAR(50)
      ,i_deductible                               VARCHAR(50)
      ,i_out_of_pocket                            VARCHAR(50)
      ,i_maternity                                VARCHAR(50)
      ,i_ob_wait_period                           VARCHAR(50)
      ,i_preex_wait_period                        VARCHAR(50)
      ,i_plan_summary_url                         VARCHAR(200)
      ,i_plan_contact_email                       VARCHAR(100)
      ,i_Age_Bump                                 VARCHAR(50)
      ,i_Durational_Bump                          VARCHAR(50)
      ,i_StateFileType                            VARCHAR(50)
      ,i_StateFileDate                            VARCHAR(50)
      ,i_State_File_Prior_Days                    VARCHAR(50)
      ,i_Correspondence                           VARCHAR(50)
      ,i_Guarantee_Period                         VARCHAR(50)
      ,i_Guarantee_Units                          VARCHAR(50)
      ,i_on_exchange                              VARCHAR(50)
      ,i_Security_Deposit                         INT
      ,i_Carrier_ID                               VARCHAR(50)
      ,i_Carrier_Name                             VARCHAR(50)
      ,i_Generic_Plan_ID                          VARCHAR(50)
      ,i_Other_Plan_ID                            VARCHAR(50)
      ,iAPTCAllowed                               VARCHAR(50)
      ,iCSRAllowed                                VARCHAR(50)
      ,iMetallicLevel                             VARCHAR(50)
      ,iActuarialValue                            VARCHAR(50)
      ,i_hios_plan_id                             VARCHAR(50)
      ,i_tenant_id                                VARCHAR(50)
      ,iPayerCompassOONContractID                 VARCHAR(200)
      ,iPayerCompassClinicalEditContractID        VARCHAR(200)
      ,iPayerCompassDefaultServiceAreaContractID  VARCHAR(200)
      ,iPayerCompassEditCodeRelationsID           VARCHAR(50)
      ,iPayerCompassEditCodeRelationsDesc         VARCHAR(500)
      ,iCOBMethod                                 VARCHAR(50)
      ,i_edi_837_claim_COB_indicated              VARCHAR(50)
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
INSERT INTO #PlanStrategy
      (SearchID
      ,i_strategy_id
      ,i_strategy_name
      ,i_model_strategy_id
      ,i_plan_type
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
      ,i_DUE_Strategy_ID
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
      ,i_planVariationLookup
      ,i_generateAutoOfficeVisit
      ,i_paymentIntegrity_RemarkCode
      ,iNursingFacServicesPatRespRulesetID
      ,iIsMedicareAdvantage
      ,i_bc_contract_number
      ,i_bs_contract_number
      ,i_dmds_group_number
      ,i_section
      ,i_alpha_prefix
      ,i_variation
      ,i_deductible
      ,i_out_of_pocket
      ,i_maternity
      ,i_ob_wait_period
      ,i_preex_wait_period
      ,i_plan_summary_url
      ,i_plan_contact_email
      ,i_Age_Bump
      ,i_Durational_Bump
      ,i_StateFileType
      ,i_StateFileDate
      ,i_State_File_Prior_Days
      ,i_Correspondence
      ,i_Guarantee_Period
      ,i_Guarantee_Units
      ,i_on_exchange
      ,i_Security_Deposit
      ,i_Carrier_Name
      ,i_Generic_Plan_ID
      ,i_Other_Plan_ID
      ,iAPTCAllowed
      ,iCSRAllowed
      ,iMetallicLevel
      ,iActuarialValue
      ,i_hios_plan_id
      ,i_tenant_id
      ,iPayerCompassOONContractID
      ,iPayerCompassClinicalEditContractID
      ,iPayerCompassDefaultServiceAreaContractID
      ,iPayerCompassEditCodeRelationsID
      ,iCOBMethod
      ,i_edi_837_claim_COB_indicated
      ,iPayUptoMedicareABCOBException
      ,iPayMedicareBCOBException
      ,iCOBMedicareBExceptionCodeListID 
      ,iCOBMedicareBExceptionReviewRemarkCodeID
      ,i_Plan_COB_Type
      ,i_Medi_Supp_Deductible
      ,i_EAPGGrouperPricerEnabled
      ,i_ClinicalEditID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_PlanStratID], '')
      ,ISNULL([*Common_PlanStratDescription], '')
      ,ISNULL([Common_ModelPlanStratID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PlanType]), 'None')
      ,ISNULL([*Common_EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BaseRules]), 'DENTAL')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DefaultStatus]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EOB]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseAliasCodes]), 'N')
      ,ISNULL([Common_SuperNetworkID], '')
      ,ISNULL([Common_CopayLevelsID], '')
      ,ISNULL([Common_PriceStrategyID], '')
      ,ISNULL([Common_BenefitStrategyID], '')
      ,ISNULL([Common_DUEStrategyID], '')
      ,ISNULL([Common_CodeLimitationsID], '')
      ,ISNULL([Common_AuthMatchID], '')
      ,ISNULL([Common_RemarkCodeRelatID], '')
      ,ISNULL([Common_RebateStrategyID], '')
      ,ISNULL([Common_ComparisonSchedID], '')
      ,ISNULL([Common_CodePairingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PCPRequiredforElig]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CAPAffiliationID]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PCPRequiredforAdj]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubmittedCostReq]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UCRRequired]), 'N')
      ,ISNULL([Common_ClinicalEngineID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AutoAdjAccident]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PTE_PREDEnforceCOB]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PTE_PREDCarryFwdOffsets]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PlanVariationLookup]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_GenerateOfficeVisit]), 'N')
      ,ISNULL([Common_PaymentIntRemarkCodeID], '')
      ,ISNULL([Common_NursingFacilityPatRespRulesetID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MedicareAdvantagePlan]), 'N')
      ,ISNULL([Misc_BCContractNo], '')
      ,ISNULL([Misc_BSContractNo], '')
      ,ISNULL([Misc_DMDSGroupNo], '')
      ,ISNULL([Misc_Section], '')
      ,ISNULL([Misc_AlphaPrefix], '')
      ,ISNULL([Misc_Variation], '0')
      ,ISNULL([Misc_Deductible], '')
      ,ISNULL([Misc_OutOfPocket], '')
      ,ISNULL([Misc_Maternity], '')
      ,ISNULL([Misc_OBWaitingPeriod], '0')
      ,ISNULL([Misc_BCBSPreExWaiting], '0')
      ,ISNULL([Misc_SummaryURL], '')
      ,ISNULL([Misc_PlanContactEmail], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_AgeBump]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_OKDurationalDisc]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_StateFileDate]), 'D')
      ,ISNULL([Misc_StateFileSpecDate], '01/01/1900')
      ,ISNULL([Misc_StateFileNotifDays], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_GenerateStateFileCorresp]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_RateGuaranteePeriod]), 'M')
      ,ISNULL([Misc_RateGuaranteeUnits], '12')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_OnExchange]), 'N')
      ,ISNULL([Misc_SecurityDeposit], '0')
      ,ISNULL([Carr_CarrierID], '')
      ,ISNULL([Carr_GenericPlanID], '')
      ,ISNULL([Carr_OtherPlanID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Carr_APTCAllowed]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Carr_CSRAllowed]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Carr_MetallicLevel]), '')
      ,ISNULL([Carr_ActuarialValue], '0.00')
      ,ISNULL([Carr_HIOSPlanID], '')
      ,ISNULL([Carr_TenantID], '')
      ,ISNULL([PayC_PayerCompassOONProvID], '')
      ,ISNULL([PayC_PayerCompassClinicalEditsID], '')
      ,ISNULL([PayC_PayerCompassDefaultServiceID], '')
      ,ISNULL([PayC_PayerCompassEditCodeRelID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_Method]), 'TRAD')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_837ClaimCOBInd]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_PayUpToMedicare]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_PayMedicareB]), 'N')
      ,ISNULL([COBMed_CodeListID], '')
      ,ISNULL([COBMed_ReviewRemarkID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_MedSuppCOBReimb]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBMed_MedSuppDeductReimb]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EAPG_GroupPricerEnabled]), 'N')
      ,ISNULL([EAPG_EditCodeRelationsID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PlanStrategy
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PlanStrategy
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PlanStrategy_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_field
       ,i_key_2_field
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
       ,i_model_strategy_id
       ,i_model_strategy_name
       ,i_plan_type
       ,i_effective_date
       ,i_termination_date
       ,i_System_Lists
       ,i_Support_Codes
       ,i_EOB
       ,i_Alias
       ,i_Network_Search_ID
       ,i_Network_Search_Desc
       ,i_rx_network_strategy_ID
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
       ,i_planVariationLookup
       ,i_generateAutoOfficeVisit
       ,i_paymentIntegrity_RemarkCode
       ,i_paymentIntegrity_RemarkCode_Desc
       ,iNursingFacServicesPatRespRulesetID
       ,iNursingFacServicesPatRespRulesetDesc
       ,iIsMedicareAdvantage
       ,i_bc_contract_number
       ,i_bs_contract_number
       ,i_dmds_group_number
       ,i_section
       ,i_alpha_prefix
       ,i_variation
       ,i_deductible
       ,i_out_of_pocket
       ,i_maternity
       ,i_ob_wait_period
       ,i_preex_wait_period
       ,i_plan_summary_url
       ,i_plan_contact_email
       ,i_Age_Bump
       ,i_Durational_Bump
       ,i_StateFileType
       ,i_StateFileDate
       ,i_State_File_Prior_Days
       ,i_Correspondence
       ,i_Guarantee_Period
       ,i_Guarantee_Units
       ,i_on_exchange
       ,i_Security_Deposit
       ,i_Carrier_ID
       ,i_Carrier_Name
       ,i_Generic_Plan_ID
       ,i_Other_Plan_ID
       ,iAPTCAllowed
       ,iCSRAllowed
       ,iMetallicLevel
       ,iActuarialValue
       ,i_hios_plan_id
       ,i_tenant_id
       ,iPayerCompassOONContractID
       ,iPayerCompassClinicalEditContractID
       ,iPayerCompassDefaultServiceAreaContractID
       ,iPayerCompassEditCodeRelationsID
       ,iPayerCompassEditCodeRelationsDesc
       ,iCOBMethod
       ,i_edi_837_claim_COB_indicated
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
   FROM #PlanStrategy

   OPEN PlanStrategy_Cursor
  FETCH NEXT FROM PlanStrategy_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_field
       ,@i_key_2_field
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
       ,@i_model_strategy_id
       ,@i_model_strategy_name
       ,@i_plan_type
       ,@i_effective_date
       ,@i_termination_date
       ,@i_System_Lists
       ,@i_Support_Codes
       ,@i_EOB
       ,@i_Alias
       ,@i_Network_Search_ID
       ,@i_Network_Search_Desc
       ,@i_rx_network_strategy_ID
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
       ,@i_planVariationLookup
       ,@i_generateAutoOfficeVisit
       ,@i_paymentIntegrity_RemarkCode
       ,@i_paymentIntegrity_RemarkCode_Desc
       ,@iNursingFacServicesPatRespRulesetID
       ,@iNursingFacServicesPatRespRulesetDesc
       ,@iIsMedicareAdvantage
       ,@i_bc_contract_number
       ,@i_bs_contract_number
       ,@i_dmds_group_number
       ,@i_section
       ,@i_alpha_prefix
       ,@i_variation
       ,@i_deductible
       ,@i_out_of_pocket
       ,@i_maternity
       ,@i_ob_wait_period
       ,@i_preex_wait_period
       ,@i_plan_summary_url
       ,@i_plan_contact_email
       ,@i_Age_Bump
       ,@i_Durational_Bump
       ,@i_StateFileType
       ,@i_StateFileDate
       ,@i_State_File_Prior_Days
       ,@i_Correspondence
       ,@i_Guarantee_Period
       ,@i_Guarantee_Units
       ,@i_on_exchange
       ,@i_Security_Deposit
       ,@i_Carrier_ID
       ,@i_Carrier_Name
       ,@i_Generic_Plan_ID
       ,@i_Other_Plan_ID
       ,@iAPTCAllowed
       ,@iCSRAllowed
       ,@iMetallicLevel
       ,@iActuarialValue
       ,@i_hios_plan_id
       ,@i_tenant_id
       ,@iPayerCompassOONContractID
       ,@iPayerCompassClinicalEditContractID
       ,@iPayerCompassDefaultServiceAreaContractID
       ,@iPayerCompassEditCodeRelationsID
       ,@iPayerCompassEditCodeRelationsDesc
       ,@iCOBMethod
       ,@i_edi_837_claim_COB_indicated
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

			EXEC dbo.prPlanStrategyNameAdd
             @i_entity_name
            ,@i_key_1_field
            ,@i_key_2_field
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
            ,@i_model_strategy_id
            ,@i_model_strategy_name
            ,@i_plan_type
            ,@i_effective_date
            ,@i_termination_date
            ,@i_System_Lists
            ,@i_Support_Codes
            ,@i_EOB
            ,@i_Alias
            ,@i_Network_Search_ID
            ,@i_Network_Search_Desc
            ,@i_rx_network_strategy_ID
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
            ,@i_planVariationLookup
            ,@i_generateAutoOfficeVisit
            ,@i_paymentIntegrity_RemarkCode
            ,@i_paymentIntegrity_RemarkCode_Desc
            ,@iNursingFacServicesPatRespRulesetID
            ,@iNursingFacServicesPatRespRulesetDesc
            ,@iIsMedicareAdvantage
            ,@i_bc_contract_number
            ,@i_bs_contract_number
            ,@i_dmds_group_number
            ,@i_section
            ,@i_alpha_prefix
            ,@i_variation
            ,@i_deductible
            ,@i_out_of_pocket
            ,@i_maternity
            ,@i_ob_wait_period
            ,@i_preex_wait_period
            ,@i_plan_summary_url
            ,@i_plan_contact_email
            ,@i_Age_Bump
            ,@i_Durational_Bump
            ,@i_StateFileType
            ,@i_StateFileDate
            ,@i_State_File_Prior_Days
            ,@i_Correspondence
            ,@i_Guarantee_Period
            ,@i_Guarantee_Units
            ,@i_on_exchange
            ,@i_Security_Deposit
            ,@i_Carrier_ID
            ,@i_Carrier_Name
            ,@i_Generic_Plan_ID
            ,@i_Other_Plan_ID
            ,@iAPTCAllowed
            ,@iCSRAllowed
            ,@iMetallicLevel
            ,@iActuarialValue
            ,@i_hios_plan_id
            ,@i_tenant_id
            ,@iPayerCompassOONContractID
            ,@iPayerCompassClinicalEditContractID
            ,@iPayerCompassDefaultServiceAreaContractID
            ,@iPayerCompassEditCodeRelationsID
            ,@iPayerCompassEditCodeRelationsDesc
            ,@iCOBMethod
            ,@i_edi_837_claim_COB_indicated
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

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN
				
				SELECT @current_gid				= plan_strategy_gid
				  FROM Plan_Strategy_Names
				  WHERE plan_strategy_id		=  @i_strategy_id

				-- Update to the static gid
				UPDATE dbo.Plan_Strategy_Names
				   SET plan_strategy_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND plan_strategy_gid		= @current_gid

				-- Update to the static gid
				UPDATE dbo.Plan_Strategy 
				   SET plan_strategy_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND plan_strategy_gid		= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_strategy_id, @i_strategy_name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM PlanStrategy_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_field
             ,@i_key_2_field
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
             ,@i_model_strategy_id
             ,@i_model_strategy_name
             ,@i_plan_type
             ,@i_effective_date
             ,@i_termination_date
             ,@i_System_Lists
             ,@i_Support_Codes
             ,@i_EOB
             ,@i_Alias
             ,@i_Network_Search_ID
             ,@i_Network_Search_Desc
             ,@i_rx_network_strategy_ID
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
             ,@i_planVariationLookup
             ,@i_generateAutoOfficeVisit
             ,@i_paymentIntegrity_RemarkCode
             ,@i_paymentIntegrity_RemarkCode_Desc
             ,@iNursingFacServicesPatRespRulesetID
             ,@iNursingFacServicesPatRespRulesetDesc
             ,@iIsMedicareAdvantage
             ,@i_bc_contract_number
             ,@i_bs_contract_number
             ,@i_dmds_group_number
             ,@i_section
             ,@i_alpha_prefix
             ,@i_variation
             ,@i_deductible
             ,@i_out_of_pocket
             ,@i_maternity
             ,@i_ob_wait_period
             ,@i_preex_wait_period
             ,@i_plan_summary_url
             ,@i_plan_contact_email
             ,@i_Age_Bump
             ,@i_Durational_Bump
             ,@i_StateFileType
             ,@i_StateFileDate
             ,@i_State_File_Prior_Days
             ,@i_Correspondence
             ,@i_Guarantee_Period
             ,@i_Guarantee_Units
             ,@i_on_exchange
             ,@i_Security_Deposit
             ,@i_Carrier_ID
             ,@i_Carrier_Name
             ,@i_Generic_Plan_ID
             ,@i_Other_Plan_ID
             ,@iAPTCAllowed
             ,@iCSRAllowed
             ,@iMetallicLevel
             ,@iActuarialValue
             ,@i_hios_plan_id
             ,@i_tenant_id
             ,@iPayerCompassOONContractID
             ,@iPayerCompassClinicalEditContractID
             ,@iPayerCompassDefaultServiceAreaContractID
             ,@iPayerCompassEditCodeRelationsID
             ,@iPayerCompassEditCodeRelationsDesc
             ,@iCOBMethod
             ,@i_edi_837_claim_COB_indicated
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

CLOSE PlanStrategy_Cursor
DEALLOCATE PlanStrategy_Cursor

END
GO