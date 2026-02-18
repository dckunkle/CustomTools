IF OBJECT_ID('dbo.spDCAuto_CreateGlobalValues') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGlobalValues AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGlobalValues
Purpose:    Create globalvalues data from CorderAutomation
Method:     GlobalValues
Screen GID: 169
Procedure:  dbo.prGlobalParamModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/27/2020	DK				Original procedure
02/06/2020	DK				Add Portal Suppress Invoice Group List ID parameter
06/11/2020	DK				Modified for SP41 changes FFM
07/08/2020	DK				Add EOD Version (SP41)
11/30/2020	DK				Add FFM Policy ID Pointer (SP43)
09/14/2021  DK				Add Payee ID Code Qualifier for (SP47)
10/11/2022	DK				Add Instamed Payer ID and Remove Baseline (SP52)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGlobalValues '400-Config%', 22, '400-Configuration','GlobalValues', '400-Config'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGlobalValues
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

DECLARE @iEntity                            VARCHAR(50)
       ,@iRecordKey1                        VARCHAR(50)
       ,@iRecordKey2                        VARCHAR(50)
       ,@iRecordKey3                        VARCHAR(50)
       ,@iRecordKey4                        VARCHAR(50)
       ,@iRecordKey5                        VARCHAR(50)
       ,@iRecordKey6                        VARCHAR(50)
       ,@iRecordKey7                        VARCHAR(50)
       ,@iRecordKey8                        VARCHAR(50)
       ,@iRecordKey9                        VARCHAR(50)
       ,@iRecordKey10                       VARCHAR(50)
       ,@iAction                            VARCHAR(10)
       ,@iModifiedDate                      VARCHAR(30)
       ,@iUserID                            VARCHAR(25)
       ,@iCompanyName                       VARCHAR(100)
       ,@iCompanyAddress1                   VARCHAR(100)
       ,@iCompanyAddress2                   VARCHAR(100)
       ,@iCompanyCity                       VARCHAR(100)
       ,@iCompanyState                      VARCHAR(100)
       ,@iCompanyZipCode                    VARCHAR(100)
       ,@iCompanyPhone                      VARCHAR(100)
       ,@iCompanyFax                        VARCHAR(100)
       ,@iCompanyTaxID                      VARCHAR(100)
       ,@iCompanyTCC                        VARCHAR(100)
       ,@iCompanyABA                        VARCHAR(100)
       ,@iCompanyBankAcctType               VARCHAR(100)
       ,@iCompanyBankAcctNum                VARCHAR(100)
       ,@iCompanyContactName                VARCHAR(100)
       ,@iCompanyContactPhone               VARCHAR(100)
       ,@iCompanyContactExt                 VARCHAR(100)
       ,@iCompanyContactEmail               VARCHAR(100)
       ,@iCompanyBillingContact             VARCHAR(100)
       ,@iCompanyTollFreePhone              VARCHAR(100)
       ,@iCompanySenderQualifier            VARCHAR(50)
       ,@iCompanySenderID                   VARCHAR(50)
       ,@iCompanyDefaultInsuranceCarrier    VARCHAR(50)
       ,@iInsuranceCarrierName              VARCHAR(50)
       ,@iProcessingStates                  VARCHAR(100)
       ,@iCompanyDefaultLOB                 VARCHAR(50)
       ,@iPasswordRuleID                    VARCHAR(50)
       ,@iPasswordRuleDesc                  VARCHAR(100)
       ,@iSessionTimeout                    VARCHAR(50)
       ,@iTimeoutWarning                    VARCHAR(50)
       ,@iDuplicateMemberCheck              VARCHAR(50)
       ,@iMaxClaimAge                       VARCHAR(50)
       ,@iMedicaidInsuranceCarrier          VARCHAR(50)
       ,@iMedicaidCarrierName               VARCHAR(50)
       ,@iADAShow                           VARCHAR(50)
       ,@iDentalEncounterShow               VARCHAR(50)
       ,@iPharmacyShow                      VARCHAR(50)
       ,@iHCFAShow                          VARCHAR(50)
       ,@iHCFAEncounterShow                 VARCHAR(50)
       ,@iUBShow                            VARCHAR(50)
       ,@iPredetYears                       VARCHAR(50)
       ,@iProvW9                            VARCHAR(50)
       ,@iResubFlag                         VARCHAR(50)
       ,@iClaimType                         VARCHAR(50)
       ,@iAuthTimeSpan                      INT
       ,@iInitialAssignmentCode             VARCHAR(50)
       ,@iClaimNumberIncomingInd            VARCHAR(50)
       ,@iClaimNumberManualInd              VARCHAR(50)
       ,@iDefRateID                         VARCHAR(55)
       ,@iDefRateDesc                       VARCHAR(55)
       ,@iToothNumberingSystem              VARCHAR(50)
       ,@iDOITermReason                     VARCHAR(50)
       ,@iAutoGenMemID                      VARCHAR(50)
       ,@iForceClear                        VARCHAR(50)
       ,@iForceClearCC                      VARCHAR(50)
       ,@iPCPMaint                          VARCHAR(50)
       ,@iCCAuthCodeStore                   VARCHAR(50)
       ,@iCascadePlanToDependents           VARCHAR(50)
       ,@iCascadeGroup                      VARCHAR(50)
       ,@iCascadeMember                     VARCHAR(50)
       ,@iSuppressCovMessage                VARCHAR(50)
       ,@iGenManualTermLtr                  VARCHAR(50)
       ,@iNcpdpDefaultRejectCode            VARCHAR(50)
       ,@iNcpdpRejectDesc                   VARCHAR(50)
       ,@iRemarkCode                        VARCHAR(50)
       ,@iRemarkDesc                        VARCHAR(50)
       ,@iPreDetCOBProcess                  VARCHAR(50)
       ,@iPreDetCarryRules                  VARCHAR(50)
       ,@iReinstatePrompt                   VARCHAR(50)
       ,@iConcurrentBilling                 VARCHAR(50)
       ,@iEligProcID                        VARCHAR(50)
       ,@iEligProcDesc                      VARCHAR(55)
       ,@iAlginEffectiveDate                VARCHAR(50)
       ,@iAutoReverseMemberPTD              VARCHAR(50)
       ,@iWarningPromptForGroupBilling      VARCHAR(50)
       ,@iCarrierRequired                   VARCHAR(50)
       ,@iLanguageCodeFormat                VARCHAR(50)
       ,@iAdjustProvTaxWithholding          VARCHAR(50)
       ,@iCommonCodeLimitHistoryDisplay     VARCHAR(50)
       ,@iEligLoadAutoFinalize              VARCHAR(50)
       ,@iByPassPTD                         VARCHAR(50)
       ,@iProvDispType                      VARCHAR(50)
       ,@iProvDirSortOrder                  VARCHAR(50)
       ,@iACHEnabled                        VARCHAR(50)
       ,@iACHFileFormat                     VARCHAR(50)
       ,@iCSArchiveMonths                   VARCHAR(50)
       ,@iEligLoadReport                    VARCHAR(50)
       ,@iImageExtension                    VARCHAR(50)
       ,@iRunCapitation                     VARCHAR(50)
       ,@iProduce277                        VARCHAR(50)
       ,@iPosPayFileFormat                  VARCHAR(50)
       ,@iCCFileFormat                      VARCHAR(50)
       ,@iGroup_Trans                       VARCHAR(50)
       ,@iEmailHours                        INT
       ,@iEmailList                         VARCHAR(200)
       ,@iX12_835Version                    VARCHAR(50)
       ,@iX12_835GE02                       VARCHAR(50)
       ,@iX12_835ISA08                      VARCHAR(50)
       ,@iX12_835GS02                       VARCHAR(50)
       ,@iX12_835GS03                       VARCHAR(50)
       ,@iX12_835GS06                       VARCHAR(50)
       ,@iX12_835TRN03                      VARCHAR(50)
       ,@iX12_835ExtractADA                 VARCHAR(50)
       ,@iGlobalOutputType                  VARCHAR(50)
       ,@iX12_834CapturePremium             VARCHAR(50)
       ,@iX12_834Version                    VARCHAR(50)
       ,@iEthnicityCodeSet                  VARCHAR(50)
       ,@iX12_837Version                    VARCHAR(50)
       ,@iIncludeCoverageInExtract          VARCHAR(50)
       ,@iPaymentIntegrityClientID          VARCHAR(50)
       ,@iAcknowledgmentEmailList           VARCHAR(200)
       ,@iCheckReconSetsExternalCheckNumber VARCHAR(50)
       ,@iFFMBaselineTradingPartnerID       VARCHAR(100)
	   ,@iFFMBaselineMemberIDPointer		VARCHAR(20)		-- SP41
	   ,@iFFMExchangeMemberIDPointer		VARCHAR(20)		-- SP41
	   ,@iFFMIssuerMemberIDPointer			VARCHAR(20)		-- SP41 
	   ,@iFFMIssuerPolicyIDPointer			VARCHAR(20)		-- SP43
       ,@iAdditionalEOPRecordValuesID       VARCHAR(50)
       ,@iAdditionalEOPRecordValuesDesc     VARCHAR(100)
       ,@iPortalSuppressInvoiceGroupListID  VARCHAR(20)		-- SP39
       ,@iPortalSuppressInvoiceGroupListDesc VARCHAR(100)	-- SP39
	   ,@iPayeeIdentificationCodeQualifier  VARCHAR(200)	-- SP47
       ,@iDualSidedAcct                     VARCHAR(50)
       ,@iNegInvProcess                     VARCHAR(50)
       ,@iDefCensusMonths                   VARCHAR(50)
       ,@iDisbEarnedOnly                    VARCHAR(50)
       ,@iRetroAddCutoff                    VARCHAR(50)
       ,@iRollingBalancePTD                 VARCHAR(50)
       ,@iSuspenseGroupID                   VARCHAR(50)
       ,@iSuspenseGroupDesc                 VARCHAR(50)
       ,@iACHAggregation                    VARCHAR(50)
       ,@iAllowRefundInterest               VARCHAR(50)
       ,@iSeparateACHProcess                VARCHAR(50)
       ,@iPreNoteProcess                    VARCHAR(50)
       ,@iNPPPeriods                        VARCHAR(50)
	   ,@InvoiceTraceGroupID				VARCHAR(50)		-- SP45  
	   ,@InvoiceTraceGroupName				VARCHAR(50)		-- SP45 
       ,@iInstaMedLockBoxABA                VARCHAR(50)
       ,@iInstaMedLockBoxBA                 VARCHAR(50)
       ,@iInstaMedLockBoxBD                 VARCHAR(50)
	   ,@iInstaMedPayerID                   VARCHAR(50)		-- SP52
       ,@iInvCollection                     VARCHAR(50)
       ,@iFlushSusGrp2Cancel                VARCHAR(50)
       ,@iMaxDollarID                       VARCHAR(50)
       ,@iMaxDollarDesc                     VARCHAR(100)
       ,@iRFFLimitID                        VARCHAR(50)
       ,@iRFFLimitDesc                      VARCHAR(100)
	   ,@iSequestrationID					VARCHAR(50)			
       ,@iSequestrationDesc				    VARCHAR(100)		
       ,@iMaxEOCLines                       VARCHAR(50)
	   ,@iClaimInterestCalcType             VARCHAR(50)  
       ,@iSSOEnabled                        VARCHAR(50)
       ,@iSSOPath                           VARCHAR(50)
       ,@iSSORedirectUrl                    VARCHAR(50)
       ,@iMemberIDMask                      VARCHAR(100)
       ,@iFirstBillingRun                   VARCHAR(50)
       ,@iAPTCBalancingStartDate            DATETIME
       ,@iMultiplePortalInsurers            VARCHAR(50)
       ,@iDisplayInactive                   VARCHAR(50)
	   ,@iProviderMatchingServiceEnabled	VARCHAR(50)
       ,@iProviderMatchingServiceURL		VARCHAR(100) 
       ,@iProviderMatchingAPIKey			VARCHAR(100) 
       ,@iInstaMedAutoPay                   VARCHAR(50)
       ,@iInstaMedClientID                  VARCHAR(100)
       ,@iBL_SHL_Enabled                    VARCHAR(100)
       ,@iBL_SHL_LoadProvEnabled            VARCHAR(100)
       ,@iBL_SHL_URL                        VARCHAR(100)
       ,@iBL_SHL_ClientID                   VARCHAR(100)
       ,@iBL_SHL_UserID                     VARCHAR(100)
       ,@iProvExtractVersion                VARCHAR(50)
       ,@iClaimExtractVersion               VARCHAR(50)
       ,@iClaimsExtractVersion              VARCHAR(50)
       ,@iFinanceLetterVersion              VARCHAR(50)
	   ,@iEODVersion						VARCHAR(50)		-- SP41  
       ,@InvoiceExtractShortVersion         VARCHAR(50)
       ,@iMemberExtractVersion              VARCHAR(50)
       ,@iSuppressSSN                       VARCHAR(50)
       ,@iEOBVersion                        VARCHAR(50)
       ,@iEOPVersion                        VARCHAR(50)		
       ,@oStatus                            INT
       ,@oMessage                           VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GlobalValues') IS NOT NULL
	DROP TABLE #GlobalValues

CREATE TABLE #GlobalValues
      (SearchID                           VARCHAR(200)
      ,iEntity                            VARCHAR(50)       DEFAULT('Global_Values')
      ,iRecordKey1                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey2                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey3                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey4                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey5                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey6                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey7                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey8                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey9                        VARCHAR(50)       DEFAULT('0')
      ,iRecordKey10                       VARCHAR(50)       DEFAULT('0')
      ,iAction                            VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate                      VARCHAR(30)       DEFAULT('')
      ,iUserID                            VARCHAR(25)       DEFAULT('')
      ,iCompanyName                       VARCHAR(100)
      ,iCompanyAddress1                   VARCHAR(100)
      ,iCompanyAddress2                   VARCHAR(100)
      ,iCompanyCity                       VARCHAR(100)
      ,iCompanyState                      VARCHAR(100)
      ,iCompanyZipCode                    VARCHAR(100)
      ,iCompanyPhone                      VARCHAR(100)
      ,iCompanyFax                        VARCHAR(100)
      ,iCompanyTaxID                      VARCHAR(100)
      ,iCompanyTCC                        VARCHAR(100)
      ,iCompanyABA                        VARCHAR(100)
      ,iCompanyBankAcctType               VARCHAR(100)
      ,iCompanyBankAcctNum                VARCHAR(100)
      ,iCompanyContactName                VARCHAR(100)
      ,iCompanyContactPhone               VARCHAR(100)
      ,iCompanyContactExt                 VARCHAR(100)
      ,iCompanyContactEmail               VARCHAR(100)
      ,iCompanyBillingContact             VARCHAR(100)
      ,iCompanyTollFreePhone              VARCHAR(100)
      ,iCompanySenderQualifier            VARCHAR(50)
      ,iCompanySenderID                   VARCHAR(50)
      ,iCompanyDefaultInsuranceCarrier    VARCHAR(50)
      ,iInsuranceCarrierName              VARCHAR(50)
      ,iProcessingStates                  VARCHAR(100)
      ,iCompanyDefaultLOB                 VARCHAR(50)
      ,iPasswordRuleID                    VARCHAR(50)
      ,iPasswordRuleDesc                  VARCHAR(100)
      ,iSessionTimeout                    VARCHAR(50)
      ,iTimeoutWarning                    VARCHAR(50)
      ,iDuplicateMemberCheck              VARCHAR(50)
      ,iMaxClaimAge                       VARCHAR(50)
      ,iMedicaidInsuranceCarrier          VARCHAR(50)
      ,iMedicaidCarrierName               VARCHAR(50)
      ,iADAShow                           VARCHAR(50)
      ,iDentalEncounterShow               VARCHAR(50)
      ,iPharmacyShow                      VARCHAR(50)
      ,iHCFAShow                          VARCHAR(50)
      ,iHCFAEncounterShow                 VARCHAR(50)
      ,iUBShow                            VARCHAR(50)
      ,iPredetYears                       VARCHAR(50)
      ,iProvW9                            VARCHAR(50)
      ,iResubFlag                         VARCHAR(50)
      ,iClaimType                         VARCHAR(50)
      ,iAuthTimeSpan                      INT
      ,iInitialAssignmentCode             VARCHAR(50)
      ,iClaimNumberIncomingInd            VARCHAR(50)
      ,iClaimNumberManualInd              VARCHAR(50)
      ,iDefRateID                         VARCHAR(55)
      ,iDefRateDesc                       VARCHAR(55)
      ,iToothNumberingSystem              VARCHAR(50)
      ,iDOITermReason                     VARCHAR(50)
      ,iAutoGenMemID                      VARCHAR(50)
      ,iForceClear                        VARCHAR(50)
      ,iForceClearCC                      VARCHAR(50)
      ,iPCPMaint                          VARCHAR(50)
      ,iCCAuthCodeStore                   VARCHAR(50)
      ,iCascadePlanToDependents           VARCHAR(50)
      ,iCascadeGroup                      VARCHAR(50)
      ,iCascadeMember                     VARCHAR(50)
      ,iSuppressCovMessage                VARCHAR(50)
      ,iGenManualTermLtr                  VARCHAR(50)
      ,iNcpdpDefaultRejectCode            VARCHAR(50)
      ,iNcpdpRejectDesc                   VARCHAR(50)
      ,iRemarkCode                        VARCHAR(50)
      ,iRemarkDesc                        VARCHAR(50)
      ,iPreDetCOBProcess                  VARCHAR(50)
      ,iPreDetCarryRules                  VARCHAR(50)
      ,iReinstatePrompt                   VARCHAR(50)
      ,iConcurrentBilling                 VARCHAR(50)
      ,iEligProcID                        VARCHAR(50)
      ,iEligProcDesc                      VARCHAR(55)
      ,iAlginEffectiveDate                VARCHAR(50)
      ,iAutoReverseMemberPTD              VARCHAR(50)
      ,iWarningPromptForGroupBilling      VARCHAR(50)
      ,iCarrierRequired                   VARCHAR(50)
      ,iLanguageCodeFormat                VARCHAR(50)
      ,iAdjustProvTaxWithholding          VARCHAR(50)
      ,iCommonCodeLimitHistoryDisplay     VARCHAR(50)
      ,iEligLoadAutoFinalize              VARCHAR(50)
      ,iByPassPTD                         VARCHAR(50)
      ,iProvDispType                      VARCHAR(50)
      ,iProvDirSortOrder                  VARCHAR(50)
      ,iACHEnabled                        VARCHAR(50)
      ,iACHFileFormat                     VARCHAR(50)
      ,iCSArchiveMonths                   VARCHAR(50)
      ,iEligLoadReport                    VARCHAR(50)
      ,iImageExtension                    VARCHAR(50)
      ,iRunCapitation                     VARCHAR(50)
      ,iProduce277                        VARCHAR(50)
      ,iPosPayFileFormat                  VARCHAR(50)
      ,iCCFileFormat                      VARCHAR(50)
      ,iGroup_Trans                       VARCHAR(50)
      ,iEmailHours                        INT
      ,iEmailList                         VARCHAR(200)
      ,iX12_835Version                    VARCHAR(50)
      ,iX12_835GE02                       VARCHAR(50)
      ,iX12_835ISA08                      VARCHAR(50)
      ,iX12_835GS02                       VARCHAR(50)
      ,iX12_835GS03                       VARCHAR(50)
      ,iX12_835GS06                       VARCHAR(50)
      ,iX12_835TRN03                      VARCHAR(50)
      ,iX12_835ExtractADA                 VARCHAR(50)
      ,iGlobalOutputType                  VARCHAR(50)
      ,iX12_834CapturePremium             VARCHAR(50)
      ,iX12_834Version                    VARCHAR(50)
      ,iEthnicityCodeSet                  VARCHAR(50)
      ,iX12_837Version                    VARCHAR(50)
      ,iIncludeCoverageInExtract          VARCHAR(50)
      ,iPaymentIntegrityClientID          VARCHAR(50)
      ,iAcknowledgmentEmailList           VARCHAR(200)
      ,iCheckReconSetsExternalCheckNumber VARCHAR(50)
      ,iFFMBaselineTradingPartnerID       VARCHAR(100)
	  ,iFFMBaselineMemberIDPointer		  VARCHAR(20)		-- SP41
	  ,iFFMExchangeMemberIDPointer		  VARCHAR(20)		-- SP41
	  ,iFFMIssuerMemberIDPointer		  VARCHAR(20)		-- SP41 
	  ,iFFMIssuerPolicyIDPointer		  VARCHAR(20)		-- SP43
      ,iAdditionalEOPRecordValuesID       VARCHAR(50)
      ,iAdditionalEOPRecordValuesDesc     VARCHAR(100)
      ,iPortalSuppressInvoiceGroupListID  VARCHAR(20)		-- SP39
      ,iPortalSuppressInvoiceGroupListDesc VARCHAR(100)		-- SP39
	  ,iPayeeIdentificationCodeQualifier  VARCHAR(200)		-- SP47
      ,iDualSidedAcct                     VARCHAR(50)
      ,iNegInvProcess                     VARCHAR(50)
      ,iDefCensusMonths                   VARCHAR(50)
      ,iDisbEarnedOnly                    VARCHAR(50)
      ,iRetroAddCutoff                    VARCHAR(50)
      ,iRollingBalancePTD                 VARCHAR(50)
      ,iSuspenseGroupID                   VARCHAR(50)
      ,iSuspenseGroupDesc                 VARCHAR(50)
      ,iACHAggregation                    VARCHAR(50)
      ,iAllowRefundInterest               VARCHAR(50)
      ,iSeparateACHProcess                VARCHAR(50)
      ,iPreNoteProcess                    VARCHAR(50)
      ,iNPPPeriods                        VARCHAR(50)
	  ,InvoiceTraceGroupID				  VARCHAR(50)		-- SP45  
	  ,InvoiceTraceGroupName			  VARCHAR(50)		-- SP45 
      ,iInstaMedLockBoxABA                VARCHAR(50)
      ,iInstaMedLockBoxBA                 VARCHAR(50)
      ,iInstaMedLockBoxBD                 VARCHAR(50)
	  ,iInstaMedPayerID                   VARCHAR(50)		-- SP52
      ,iInvCollection                     VARCHAR(50)
      ,iFlushSusGrp2Cancel                VARCHAR(50)
      ,iMaxDollarID                       VARCHAR(50)
      ,iMaxDollarDesc                     VARCHAR(100)
      ,iRFFLimitID                        VARCHAR(50)
      ,iRFFLimitDesc                      VARCHAR(100)
	  ,iSequestrationID					  VARCHAR(50)		
      ,iSequestrationDesc				  VARCHAR(100)		
      ,iMaxEOCLines                       VARCHAR(50)
	  ,iClaimInterestCalcType             VARCHAR(1)  
      ,iSSOEnabled                        VARCHAR(50)
      ,iSSOPath                           VARCHAR(50)
      ,iSSORedirectUrl                    VARCHAR(50)
      ,iMemberIDMask                      VARCHAR(100)
      ,iFirstBillingRun                   VARCHAR(50)
      ,iAPTCBalancingStartDate            DATETIME
      ,iMultiplePortalInsurers            VARCHAR(50)
      ,iDisplayInactive                   VARCHAR(50)
	  ,iProviderMatchingServiceEnabled	  VARCHAR(50)
      ,iProviderMatchingServiceURL		  VARCHAR(100) 
      ,iProviderMatchingAPIKey			  VARCHAR(100) 
      ,iInstaMedAutoPay                   VARCHAR(50)
      ,iInstaMedClientID                  VARCHAR(100)
      ,iBL_SHL_Enabled                    VARCHAR(100)
      ,iBL_SHL_LoadProvEnabled            VARCHAR(100)
      ,iBL_SHL_URL                        VARCHAR(100)
      ,iBL_SHL_ClientID                   VARCHAR(100)
      ,iBL_SHL_UserID                     VARCHAR(100)
      ,iProvExtractVersion                VARCHAR(50)
      ,iClaimExtractVersion               VARCHAR(50)
      ,iClaimsExtractVersion              VARCHAR(50)
      ,iFinanceLetterVersion              VARCHAR(50)
	  ,iEODVersion						  VARCHAR(50)		-- SP41  
      ,InvoiceExtractShortVersion         VARCHAR(50)
      ,iMemberExtractVersion              VARCHAR(50)
      ,iSuppressSSN                       VARCHAR(50)
      ,iEOBVersion                        VARCHAR(50)
	  ,iEOPVersion						  VARCHAR(50)
      ,oStatus                            INT
      ,oMessage                           VARCHAR(250)
      ,record_id                          INT
      ,static_gid                         INT)

IF Object_ID('tempdb.dbo.#Global_Populate') IS NOT NULL
	DROP TABLE #Global_Populate

CREATE TABLE #Global_Populate
      (CompanyName							VARCHAR(100)  
      ,CompanyAddress1						VARCHAR(100)  
      ,CompanyAddress2						VARCHAR(100)  
      ,CompanyCity							VARCHAR(100)  
      ,CompanyState							VARCHAR(100)  
      ,CompanyZipCode						VARCHAR(100)  
      ,CompanyPhone							VARCHAR(100)  
      ,CompanyFax							VARCHAR(100)  
      ,CompanyTaxID							VARCHAR(100)  
      ,CompanyTCC							VARCHAR(100)  
      ,CompanyABA							VARCHAR(100)  
      ,Dummy_Field1							VARCHAR(10)
      ,CompanyBankAcctType					VARCHAR(100)  
      ,CompanyBankAcctNum					VARCHAR(100)  
      ,CompanyContactName					VARCHAR(100)  
      ,CompanyContactPhone					VARCHAR(100)  
      ,CompanyContactExt					VARCHAR(100)  
      ,CompanyContactEmail					VARCHAR(100)  
      ,CompanyBillingContact				VARCHAR(100)  
      ,CompanyTollFreePhone					VARCHAR(100)  
      ,CompanySenderQualifier				VARCHAR(50)  
      ,CompanySenderID						VARCHAR(50)  
      ,CompanyDefaultInsuranceCarrier		VARCHAR(50)  
      ,DefaultInsCarrierDesc				VARCHAR(100)  
      ,ProcessingStates						VARCHAR(100)  
      ,CompanyDefaultLOB					VARCHAR(50)  
      ,PasswordRuleID						VARCHAR(50)  
      ,PasswordRuleDesc						VARCHAR(100)  
      ,SessionTimeout						VARCHAR(50)  
      ,TimeoutWarning						VARCHAR(50)  
      ,Dummy_Field2							VARCHAR(50)
      ,Dummy_Field3							VARCHAR(50)
      ,DuplicateMemberCheck					VARCHAR(50)  
      ,MaxClaimAge							VARCHAR(55)  
      ,MedicaidInsuranceCarrier				VARCHAR(25)  
      ,MedicaidCarrierName					VARCHAR(50)  
      ,ADAShow								VARCHAR(50)
      ,DentalEncounterShow					VARCHAR(50)  
      ,PharmacyShow							VARCHAR(50)
      ,HCFAShow								VARCHAR(50)
      ,HCFAEncounterShow					VARCHAR(50)
      ,UBShow								VARCHAR(50)
      ,PredetYears							INT  
      ,ProvW9								VARCHAR(50)
      ,ResubFlag							VARCHAR(50)
      ,ClaimType							VARCHAR(50)
      ,AuthTimeSpan							INT  
      ,InitialAssignmentCode				VARCHAR(50)  
      ,ClaimNumberIncomingInd				VARCHAR(50)  
      ,ClaimNumberManualInd					VARCHAR(50)  
      ,DefRateID							VARCHAR(55)  
      ,DefRateDesc							VARCHAR(55)  
      ,ToothNumberingSystem					VARCHAR(50)
      ,DOITermReason						VARCHAR(20)  
      ,AutoGenMemID							VARCHAR(50)
      ,ForceClear							VARCHAR(50)
      ,ForceClearCC							VARCHAR(50)
      ,PCPMaint								VARCHAR(10)  
      ,CCAuthCodeStore						VARCHAR(50)
      ,CascadePlanToDependents				VARCHAR(50)
      ,CascadeGroup							VARCHAR(50)
      ,CascadeMember						VARCHAR(50)
      ,SupCovMessage						VARCHAR(50)
      ,GenManualTermLtr						VARCHAR(50)
      ,NcpdpDefaultRejectCode				VARCHAR(2)  
      ,Dummy_Field4							VARCHAR(10)
      ,RemarkCode							VARCHAR(4)  
      ,Dummy_Field5							VARCHAR(10)
      ,PreDetCOBProcess						VARCHAR(50)
      ,PreDetCarryRules						VARCHAR(50)
      ,ReinstatePrompt						VARCHAR(50)
      ,ConcurrentBilling					VARCHAR(50)
      ,EligProcID							VARCHAR(25)  
      ,EligProcDesc							VARCHAR(55)  
      ,AlginEffectiveDate					VARCHAR(50)  
      ,AutoReverseMemberPTD					VARCHAR(50)
      ,WarningPromptForGroupBilling			VARCHAR(50)
      ,CarrierRequired						VARCHAR(50) 
      ,LanguageCodeFormat					VARCHAR(50)
      ,AdjustProvTaxWithholding				VARCHAR(50)  
      ,CommonCodeLimitHistoryDisplay		VARCHAR(50) 
      ,EligLoadAutoFinalize					VARCHAR(50)
      ,BypassPTD							VARCHAR(50)
      ,Dummy_Field6							VARCHAR(10)
      ,Dummy_Field7							VARCHAR(10)
      ,Dummy_Field8							VARCHAR(10)
      ,ProvDispType							VARCHAR(50)
      ,ProvDirSortOrder						VARCHAR(5)  
      ,ACHEnabled							VARCHAR(50)
      ,ACHFileFormat						VARCHAR(25)  
      ,CSArchiveMonths						VARCHAR(5)  
      ,EligLoadReport						VARCHAR(50)
      ,ImageExtension						VARCHAR(20)  
      ,RunCapitation						VARCHAR(50)
      ,Produce277							VARCHAR(50)
      ,PosPayFileFormat						VARCHAR(50)
      ,CCFileFormat							VARCHAR(50)
      ,GroupTrans							VARCHAR(50)
      ,EmailHours							INT  
      ,EmailList							VARCHAR(200)  
      ,X12_835Version						VARCHAR(20)  
      ,X12_835GE02							VARCHAR(20)  
      ,X12_835ISA08							VARCHAR(20)  
      ,X12_835GS02							VARCHAR(20)  
      ,X12_835GS03							VARCHAR(20)  
      ,X12_835GS06							VARCHAR(20)  
      ,X12_835TRN03							VARCHAR(20)  
      ,X12_835ExtractADA					VARCHAR(50)
      ,GlobalOutputType						VARCHAR(20)  
      ,X12_834CapturePremium				VARCHAR(50)
      ,X12_834Version						VARCHAR(20)  
      ,EthnicityCodeSet						VARCHAR(10) 
      ,X12_837Version						VARCHAR(20)  
      ,LastExtract							VARCHAR(50)
      ,PaymentIntegrityClientID				VARCHAR(25)  
      ,AcknowledgmentEmailList				VARCHAR(200)  
      ,CheckReconSetsExternalCheckNumber	VARCHAR(50)
      ,FFMBaselineTradingPartnerID			VARCHAR(100) 
	  ,FFMBaselineMemberIDPointer		    VARCHAR(100)	-- SP41  
	  ,FFMExchangeMemberIDPointer			VARCHAR(100)	-- SP41  
	  ,FFMIssuerMemberIDPointer				VARCHAR(100)	-- SP41
	  ,FFMIssuerPolicyIDPointer				VARCHAR(100)	-- SP43
      --,Dummy_Field9							VARCHAR(10)
      ,AdditionalEOPRecordValuesID			VARCHAR(20)  
      ,AdditionalEOPRecordValuesDesc		VARCHAR(100)  
      ,PortalSuppressInvoiceGroupListID		VARCHAR(20)		-- SP39
      ,PortalSuppressInvoiceGroupListDesc	VARCHAR(100)	-- SP39
	  ,PayeeIdentificationCodeQualifier		VARCHAR(200)	-- SP47
	  ,Dummy_Field90						VARCHAR(50)		-- SP47
      ,Dummy_Field10						VARCHAR(10)
      ,Dummy_Field11						VARCHAR(10)
      ,DualSided							VARCHAR(50)
      ,NegInvProcess						VARCHAR(50)
      ,DefCensusMonths						VARCHAR(50)
      ,DisbEarnedOnly						VARCHAR(50)
      ,RetroAddCutoff						VARCHAR(50) 
      ,RollingBalancePTD					VARCHAR(50)
      ,SuspenseGroupID						VARCHAR(50)  
      ,SuspenseGroupName					VARCHAR(50)  
      ,ACHAggregation						VARCHAR(50)
      ,AllowRefundInterest					VARCHAR(50)
      ,SeparateACHProcess					VARCHAR(50)
      ,PreNoteProcess						VARCHAR(50)
      ,NPPMonths							VARCHAR(50) 
      ,Dummy_Field12						VARCHAR(10)
	  ,InvoiceTraceGroupID					VARCHAR(50)
	  ,InvoiceTraceGroupName				VARCHAR(50)
      ,Dummy_Field13						VARCHAR(10)
      ,Dummy_Field14						VARCHAR(10)
      ,InstaMedLockBoxBN					VARCHAR(50)   
      ,Dummy_Field15						VARCHAR(10)
      ,InstaMedLockBoxBA					VARCHAR(50) 
      ,InstaMedLockBoxBD					VARCHAR(50) 
	  ,iInstaMedPayerID						VARCHAR(50)		-- SP52
	  ,Dummy_Field101						VARCHAR(100)	-- SP52
      ,InvCollection						VARCHAR(50)
      ,Dummy_Field16						VARCHAR(50)
      ,FlushSusGrp2Cancel					VARCHAR(50)
      ,Dummy_Field17						VARCHAR(10)
      ,Dummy_Field42						VARCHAR(10)		-- SP38
      ,Dummy_Field43						VARCHAR(10)		-- SP38
      ,Dummy_Field44						VARCHAR(10)		-- SP38
      ,Dummy_Field45						VARCHAR(10)		-- SP38
      ,MAXDollarID							VARCHAR(20)  
      ,MAXDollarDesc						VARCHAR(100)  
      ,RFFLimitId							VARCHAR(20)  
      ,RFFLimitDesc							VARCHAR(100)  
	  ,SequestrationID						VARCHAR(50)		-- SP39
      ,SequestrationDesc					VARCHAR(100)	-- SP39
      ,MaxEOCLines							VARCHAR(10)  
      ,Dummy_Field18						VARCHAR(10)
	  ,ClaimInterestCalcType				VARCHAR(10)		-- SP38
	  ,Dummy_Field46						VARCHAR(10)		-- SP38			
      ,Dummy_Field19						VARCHAR(10)
      ,Dummy_Field20						VARCHAR(10)
      ,SSOEnable							VARCHAR(50)
      ,SSOPath								VARCHAR(50) 
      ,SSORedirectUrl						VARCHAR(50) 
      ,MemberIDMask							VARCHAR(100) 
      ,FirstBillingRun						VARCHAR(10)  
      ,APTCBalancingStartDate				DATETIME  
      ,MultiplePortalInsurers				VARCHAR(50)
      ,DisplayInactive						VARCHAR(50)
      ,Dummy_Field21						VARCHAR(10)
      ,Dummy_Field22						VARCHAR(10)
	  ,ProviderMatchingServiceEnabled		VARCHAR(50)		-- SP40
      ,ProviderMatchingServiceURL			VARCHAR(100)	-- SP40
      ,ProviderMatchingAPIKey				VARCHAR(100)	-- SP40
	  ,Dummy_Field23						VARCHAR(10)
      ,Dummy_Field24						VARCHAR(10)
      ,Dummy_Field25						VARCHAR(10)
	  ,InstaMedAutoPay						VARCHAR(50)
      ,InstaMedClientID						VARCHAR(100)  
      ,Dummy_Field26						VARCHAR(10)
      ,Dummy_Field27						VARCHAR(10)

      --,BL_SHL_Enabled						VARCHAR(100)	-- SP52
      --,BL_SHL_LoadProvEnabled				VARCHAR(100)	-- SP52
      --,BL_SHL_URL							VARCHAR(100) 	-- SP52
      --,BL_SHL_ClientID					VARCHAR(100)	-- SP52   
      --,BL_SHL_UserID						VARCHAR(100)	-- SP52 

      ,Dummy_Field28						VARCHAR(10)
      ,Dummy_Field29						VARCHAR(10)
      --,Dummy_Field30						VARCHAR(10)		-- SP52
      --,Dummy_Field31						VARCHAR(10)		-- SP52
      --,Dummy_Field32						VARCHAR(10)		-- SP52

      ,ProvExtractVersion					VARCHAR(50)  
      ,ClaimExtractVersion					VARCHAR(50)  
      ,ClaimsExtractVersion					VARCHAR(50) 

      ,Dummy_Field33						VARCHAR(10)
      ,Dummy_Field34						VARCHAR(10)
      ,Dummy_Field35						VARCHAR(10)

      ,FinanceLetterVersion					VARCHAR(50)
      ,EODVersion							VARCHAR(10)		-- SP41
      ,InvoiceExtractShortVersion			VARCHAR(50)
      ,Dummy_Field37						VARCHAR(10)
      ,Dummy_Field38						VARCHAR(10)
      ,Dummy_Field39						VARCHAR(10)
      ,MemberExtractVersion					VARCHAR(50)
      ,SuppressSSN							VARCHAR(50)
      ,Dummy_Field40						VARCHAR(10)
      ,Dummy_Field41						VARCHAR(10)
      ,EOBVersion							VARCHAR(50)
	  ,EOPVersion							VARCHAR(50)		-- SP39
      ,date_time_created					VARCHAR(50)  
      ,user_id_created						VARCHAR(50)  
      ,date_time_modified					VARCHAR(50)  
      ,[user_id]							VARCHAR(50)  
      ,form_id								VARCHAR(50))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GlobalValues
      (SearchID
      ,iCompanyName                       
      ,iCompanyAddress1                   
      ,iCompanyAddress2                   
      ,iCompanyCity                       
      ,iCompanyState                      
      ,iCompanyZipCode                    
      ,iCompanyPhone                      
      ,iCompanyFax                        
      ,iCompanyTaxID                      
      ,iCompanyTCC                        
      ,iCompanyABA                        
      ,iCompanyBankAcctType               
      ,iCompanyBankAcctNum                
      ,iCompanyContactName                
      ,iCompanyContactPhone               
      ,iCompanyContactExt                 
      ,iCompanyContactEmail               
      ,iCompanyBillingContact             
      ,iCompanyTollFreePhone              
      ,iCompanySenderQualifier            
      ,iCompanySenderID                   
      ,iCompanyDefaultInsuranceCarrier    
      ,iProcessingStates                  
      ,iCompanyDefaultLOB                 
      ,iPasswordRuleID                    
      ,iSessionTimeout                    
      ,iTimeoutWarning                    
      ,iDuplicateMemberCheck              
      ,iMaxClaimAge                       
      ,iMedicaidInsuranceCarrier          
      ,iADAShow                           
      ,iDentalEncounterShow               
      ,iPharmacyShow                      
      ,iHCFAShow                          
      ,iHCFAEncounterShow                 
      ,iUBShow                            
      ,iPredetYears                       
      ,iProvW9                            
      ,iResubFlag                         
      ,iClaimType                         
      ,iAuthTimeSpan                      
      ,iInitialAssignmentCode             
      ,iClaimNumberIncomingInd            
      ,iClaimNumberManualInd              
      ,iDefRateID                         
      ,iToothNumberingSystem              
      ,iDOITermReason                     
      ,iAutoGenMemID                      
      ,iForceClear                        
      ,iForceClearCC                      
      ,iPCPMaint                          
      ,iCCAuthCodeStore                   
      ,iCascadePlanToDependents           
      ,iCascadeGroup                      
      ,iCascadeMember                     
      ,iSuppressCovMessage                
      ,iGenManualTermLtr                  
      ,iPreDetCOBProcess                  
      ,iPreDetCarryRules                  
      ,iReinstatePrompt                   
      ,iConcurrentBilling                 
      ,iEligProcID                        
      ,iAlginEffectiveDate                
      ,iAutoReverseMemberPTD              
      ,iWarningPromptForGroupBilling      
      ,iCarrierRequired                   
      ,iLanguageCodeFormat                
      ,iAdjustProvTaxWithholding          
      ,iCommonCodeLimitHistoryDisplay     
      ,iEligLoadAutoFinalize              
      ,iByPassPTD                         
      ,iProvDispType                      
      ,iProvDirSortOrder                  
      ,iACHEnabled                        
      ,iACHFileFormat                     
      ,iCSArchiveMonths                   
      ,iEligLoadReport                    
      ,iImageExtension                    
      ,iRunCapitation                     
      ,iProduce277                        
      ,iPosPayFileFormat                  
      ,iCCFileFormat                      
      ,iGroup_Trans                       
      ,iEmailHours                        
      ,iEmailList                         
      ,iX12_835Version                    
      ,iX12_835GE02                       
      ,iX12_835ISA08                      
      ,iX12_835GS02                       
      ,iX12_835GS03                       
      ,iX12_835GS06                       
      ,iX12_835TRN03                      
      ,iX12_835ExtractADA                 
      ,iGlobalOutputType                  
      ,iX12_834CapturePremium             
      ,iX12_834Version                    
      ,iEthnicityCodeSet                  
      ,iX12_837Version                    
      ,iIncludeCoverageInExtract          
      ,iPaymentIntegrityClientID          
      ,iAcknowledgmentEmailList           
      ,iCheckReconSetsExternalCheckNumber 
      ,iFFMBaselineTradingPartnerID       
	  ,iFFMBaselineMemberIDPointer			-- SP41
	  ,iFFMExchangeMemberIDPointer			-- SP41
	  ,iFFMIssuerMemberIDPointer			-- SP41 
	  ,iFFMIssuerPolicyIDPointer			-- SP43   
      ,iAdditionalEOPRecordValuesID    
      ,iPortalSuppressInvoiceGroupListID	-- SP39
	  ,iPayeeIdentificationCodeQualifier	-- SP47
      ,iDualSidedAcct                     
      ,iNegInvProcess                     
      ,iDefCensusMonths                   
      ,iDisbEarnedOnly                    
      ,iRetroAddCutoff                    
      ,iRollingBalancePTD                 
      ,iSuspenseGroupID                   
      ,iACHAggregation                    
      ,iAllowRefundInterest               
      ,iSeparateACHProcess                
      ,iPreNoteProcess                    
      ,iNPPPeriods     
	  ,InvoiceTraceGroupID                   
      ,iInstaMedLockBoxABA                
      ,iInstaMedLockBoxBA   
	  ,iInstaMedPayerID						-- SP52
      ,iInvCollection                     
      ,iFlushSusGrp2Cancel                
      ,iMaxDollarID                       
      ,iRFFLimitID    
	  ,iSequestrationID				               
      ,iMaxEOCLines  
	  ,iClaimInterestCalcType                              
      ,iProvExtractVersion                
      ,iClaimExtractVersion               
      ,iClaimsExtractVersion              
      ,iFinanceLetterVersion   
	  ,iEODVersion           
      ,InvoiceExtractShortVersion         
      ,iMemberExtractVersion              
      ,iSuppressSSN                       
      ,iEOBVersion   
	  ,iEOPVersion					                    
      ,record_id
      ,static_gid)
SELECT SearchID
      --,ISNULL([SearchEntityValue], '')
      ,ISNULL([*Common_CompanyName], '')
      ,ISNULL([*Common_CompanyAddress1], '')
      ,ISNULL([Common_CompanyAddress2], '')
      ,ISNULL([*Common_CompanyCity], '')
      ,ISNULL([*Common_CompanyState], '')
      ,ISNULL([*Common_CompanyZipCode], '')
      ,ISNULL([*Common_CompanyPhone], '')
      ,ISNULL([*Common_CompanyFax], '')
      ,ISNULL([*Common_CompanyTaxID], '')
      ,ISNULL([Common_CompanyTCC], '')
      ,ISNULL([*Common_CompanyABA], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_CompanyBankAcctType]), '')
      ,ISNULL([*Common_CompanyBankAcctNum], '')
      ,ISNULL([*Common_CompanyContactName], '')
      ,ISNULL([*Common_CompanyContactPhone], '')
      ,ISNULL([Common_CompanyContactExt], '')
      ,ISNULL([*Common_CompanyContactEmail], '')
      ,ISNULL([*Common_CompanyBillingContact], '')
      ,ISNULL([Common_CompanyTollFreeNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_X12SenderQualifier]), '')
      ,ISNULL([Common_X12SenderIdentifier], '')
      ,ISNULL([Common_CompanyDefaultCarrier], '')
      ,ISNULL([Common_ProcessingState(s)], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_CompanySystemLOB]), '')
      ,ISNULL([Common_PasswordRuleID], '')
      ,ISNULL([Common_SessionTimeout(Min)], '')
      ,ISNULL([Common_TimeoutWarning(Sec)], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_DuplicateMemberCheck]), '')
      ,ISNULL([Processing_MaxClaimAge], '')
      ,ISNULL([Processing_MedicaidInsuranceCarrier], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowADAClaim]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowDentalEncounterClaim]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowPharmacyClaim]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowCMS1500Claim]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowCMS1500EncounterClaim]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Processing_ShowUBClaim]), '')
      ,ISNULL([Processing_PreDeterminationExpYears], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_DefaultProviderW9]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_ResubmitterFlag]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_DefaultClaimType]), '')
      ,ISNULL([Processing_AuthTimeSpan], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_InitialAssignmentCode]), '')
      ,ISNULL([*Processing_IncomingClaimNumIdentifier], '')
      ,ISNULL([*Processing_ManualClaimNumIdentifier], '')
      ,ISNULL([Processing_DefaultRateTableID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_ToothNumberingSystem]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_DOITermReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_AutoGenerateMemberID]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_ForceCheckClear]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_ForceDuplicateCreditCardCharges]), '')
      ,ISNULL([Processing_PCPMaintenanceReason], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_CreditCardAuthNumStorage]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_CascadePlanToDependents]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_CascadeTermToSubGroups]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_CascadeTermToMembers]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_SuppressManuallyBuildCoverageMessage]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_GenManualRequestedLettersOnTermedMem]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_PTE_PRED_EnforceCOBEdits]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_PTE_PRED_CarryFwdOffsets]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_PromptForReinstatementRules]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_ConcurrentBilling]), '')
      ,ISNULL([Processing_EligibilityProcessingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_AlignMemberEffectiveDates]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_AutoReversePTD]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_WarningPromptForGroupBilling]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_CarrierRequired]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_LanguageCodeFormat]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_AdjustProviderTaxWithholdingForPriorYears]), '')
      ,ISNULL([Processing_CommonCodeLimitationHistoryDisplay], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_EligibilityLoadAutoFinalize]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_BypassGroupPTDForPreDates]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_DefaultProvDirectoryStyle]), '')
      ,ISNULL([ImportExport_ProviderDirectorySortOrder], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_ACHEnabled]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_ACHFileFormat]), '')
      ,ISNULL([ImportExport_CSArchiveMonths], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_EligLoadReport]), '')
      ,ISNULL([ImportExport_ImageExtension], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_RunCapitation]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_Produce277]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_PositivePayFileFormat]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_CreditCardFileFormat]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_UseGroupTranslation]), '')
      ,ISNULL([ImportExport_HoursBeforeEscalatingFileLoad], '')
      ,ISNULL([ImportExport_FileLoadEmailList], '')
      ,ISNULL([ImportExport_277_835Version], '')
      ,ISNULL([ImportExport_277_835GroupControlNumber_GE02], '')
      ,ISNULL([ImportExport_277_835InterchangeRcvrID_ISA08], '')
      ,ISNULL([ImportExport_277_835SenderCode_GS02], '')
      ,ISNULL([ImportExport_277_835ReceiverCode_GS03], '')
      ,ISNULL([ImportExport_277_835GroupControlNbr_GS06], '')
      ,ISNULL([ImportExport_277_835OriginatingCoID_TRN03], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_Extract835ADAModifiers]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_GlobalOutputType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_X12834Capture_StorePremium]), '')
      ,ISNULL([ImportExport_834X12Outbound], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_834X12EthnicityCodeSet]), '')
      ,ISNULL([ImportExport_837X12Outbound], '')
      ,ISNULL([ImportExport_LastExtract], '')
      ,ISNULL([ImportExport_PaymentIntegrityClientID], '')
      ,ISNULL([ImportExport_999AcknowledgmentEmailList], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_ImportExtCheckTraceViaCheckRecon]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_FFMBaselineTradingPartnerID]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ImportExport_FFMBaselineExchangeSubscriberIDPointer), '')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ImportExport_FFMBaselineExchangeMemberIDPointer), '')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ImportExport_FFMBaselineIssuerMemberIDPointer), '')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ImportExport_FFMBaselineIssuerPolicyIDPointer), '')
      ,ISNULL([ImportExport_EOP835AdditionalRecordValuesID], '')
      ,NULL --ISNULL([PortalSuppressInvoiceGroupListID], '')   	-- SP39
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ImportExport_PayeeIdentificationCodeQualifier), 'EXF') -- SP47
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_DualSidedAccounting]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_ApplyCreditsAutomaticallyDuringInvoicing]), '')
      ,ISNULL([Finance_MaxRetroCensusMonths], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_DisbursementEarned]), '')
      ,ISNULL([Finance_MaxRetroAddCutoff], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_RollingBalancePTD]), '')
      ,ISNULL([Finance_DefaultSuspenseGroupID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_PerformPremiumOutboundACHAggregation]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_AllowRefundInterest]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_SeparateElecPaymentProcess]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_ProcessACHPreNote]), '')
      ,ISNULL([Finance_NumOfRetroactiveMonthsCosideredByNPP], '')
	  ,ISNULL([Finance_InvoiceTraceGroupID], '')
      ,ISNULL([Finance_LockBoxABANumber], '')
      ,ISNULL([Finance_LockBoxBankAccount], '')
	  ,ISNULL([Finance_InstamedPayerID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_InvCollectionToPullCurrentARBalance]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_XferToCanceledEntityViaClearsSuspAcct]), '')
      ,ISNULL([Finance_HighDollarClaimRuleID], '')
      ,ISNULL([Finance_RFFPaymentLimitRuleID], '')  
      ,ISNULL([Finance_SequestrationAdjustmentID], '')  
      ,ISNULL([Finance_MaxNumOfTransactionsPerClaimCheck], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_IntCalcTypeForLateClaimsPymts]), '')  
      ,ISNULL([*Extracts_ProviderExtractVersion], '')
      ,ISNULL([*Extracts_ClaimExtractVersion], '')
      ,ISNULL([*Extracts_GreatPlainsClaimsExtractVersion], '')
      ,ISNULL([*Extracts_FinanceLettersVersion], '')
	  ,ISNULL([*Extracts_EODVersion], '')
      ,ISNULL([*Extracts_InvoiceExtractShortFormatVersion], '')
      ,ISNULL([*Extracts_MemberExtractVersion], '')
      ,ISNULL([Extracts_SuppressSSN], '')
      ,ISNULL([*Extracts_EOBVersion], '')
      ,ISNULL([*Extracts_EOPVersion], '')		
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GlobalValues
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GlobalValues
   SET iUserID  = @user

UPDATE #GlobalValues
   SET iCompanyTollFreePhone = NULL
 WHERE iCompanyTollFreePhone = '<genrnd>'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GlobalValues_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iRecordKey1
       ,iRecordKey2
       ,iRecordKey3
       ,iRecordKey4
       ,iRecordKey5
       ,iRecordKey6
       ,iRecordKey7
       ,iRecordKey8
       ,iRecordKey9
       ,iRecordKey10
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iCompanyName
       ,iCompanyAddress1
       ,iCompanyAddress2
       ,iCompanyCity
       ,iCompanyState
       ,iCompanyZipCode
       ,iCompanyPhone
       ,iCompanyFax
       ,iCompanyTaxID
       ,iCompanyTCC
       ,iCompanyABA
       ,iCompanyBankAcctType
       ,iCompanyBankAcctNum
       ,iCompanyContactName
       ,iCompanyContactPhone
       ,iCompanyContactExt
       ,iCompanyContactEmail
       ,iCompanyBillingContact
       ,iCompanyTollFreePhone
       ,iCompanySenderQualifier
       ,iCompanySenderID
       ,iCompanyDefaultInsuranceCarrier
       ,iInsuranceCarrierName
       ,iProcessingStates
       ,iCompanyDefaultLOB
       ,iPasswordRuleID
       ,iPasswordRuleDesc
       ,iSessionTimeout
       ,iTimeoutWarning
       ,iDuplicateMemberCheck
       ,iMaxClaimAge
       ,iMedicaidInsuranceCarrier
       ,iMedicaidCarrierName
       ,iADAShow
       ,iDentalEncounterShow
       ,iPharmacyShow
       ,iHCFAShow
       ,iHCFAEncounterShow
       ,iUBShow
       ,iPredetYears
       ,iProvW9
       ,iResubFlag
       ,iClaimType
       ,iAuthTimeSpan
       ,iInitialAssignmentCode
       ,iClaimNumberIncomingInd
       ,iClaimNumberManualInd
       ,iDefRateID
       ,iDefRateDesc
       ,iToothNumberingSystem
       ,iDOITermReason
       ,iAutoGenMemID
       ,iForceClear
       ,iForceClearCC
       ,iPCPMaint
       ,iCCAuthCodeStore
       ,iCascadePlanToDependents
       ,iCascadeGroup
       ,iCascadeMember
       ,iSuppressCovMessage
       ,iGenManualTermLtr
       ,iNcpdpDefaultRejectCode
       ,iNcpdpRejectDesc
       ,iRemarkCode
       ,iRemarkDesc
       ,iPreDetCOBProcess
       ,iPreDetCarryRules
       ,iReinstatePrompt
       ,iConcurrentBilling
       ,iEligProcID
       ,iEligProcDesc
       ,iAlginEffectiveDate
       ,iAutoReverseMemberPTD
       ,iWarningPromptForGroupBilling
       ,iCarrierRequired
       ,iLanguageCodeFormat
       ,iAdjustProvTaxWithholding
       ,iCommonCodeLimitHistoryDisplay
       ,iEligLoadAutoFinalize
       ,iByPassPTD
       ,iProvDispType
       ,iProvDirSortOrder
       ,iACHEnabled
       ,iACHFileFormat
       ,iCSArchiveMonths
       ,iEligLoadReport
       ,iImageExtension
       ,iRunCapitation
       ,iProduce277
       ,iPosPayFileFormat
       ,iCCFileFormat
       ,iGroup_Trans
       ,iEmailHours
       ,iEmailList
       ,iX12_835Version
       ,iX12_835GE02
       ,iX12_835ISA08
       ,iX12_835GS02
       ,iX12_835GS03
       ,iX12_835GS06
       ,iX12_835TRN03
       ,iX12_835ExtractADA
       ,iGlobalOutputType
       ,iX12_834CapturePremium
       ,iX12_834Version
       ,iEthnicityCodeSet
       ,iX12_837Version
       ,iIncludeCoverageInExtract
       ,iPaymentIntegrityClientID
       ,iAcknowledgmentEmailList
       ,iCheckReconSetsExternalCheckNumber
       ,iFFMBaselineTradingPartnerID
	   ,iFFMBaselineMemberIDPointer			-- SP41
	   ,iFFMExchangeMemberIDPointer			-- SP41
	   ,iFFMIssuerMemberIDPointer			-- SP41  
	   ,iFFMIssuerPolicyIDPointer			-- SP43
       ,iAdditionalEOPRecordValuesID
       ,iAdditionalEOPRecordValuesDesc
	   ,iPortalSuppressInvoiceGroupListID  
       ,iPortalSuppressInvoiceGroupListDesc 
	   ,iPayeeIdentificationCodeQualifier	-- SP47
       ,iDualSidedAcct
       ,iNegInvProcess
       ,iDefCensusMonths
       ,iDisbEarnedOnly
       ,iRetroAddCutoff
       ,iRollingBalancePTD
       ,iSuspenseGroupID
       ,iSuspenseGroupDesc
       ,iACHAggregation
       ,iAllowRefundInterest
       ,iSeparateACHProcess
       ,iPreNoteProcess
       ,iNPPPeriods
	   ,InvoiceTraceGroupID					-- SP45  
	   ,InvoiceTraceGroupName				-- SP45 
       ,iInstaMedLockBoxABA
       ,iInstaMedLockBoxBA
       ,iInstaMedLockBoxBD
	   ,iInstaMedPayerID					-- SP52
       ,iInvCollection
       ,iFlushSusGrp2Cancel
       ,iMaxDollarID
       ,iMaxDollarDesc
       ,iRFFLimitID
       ,iRFFLimitDesc
	   ,iSequestrationID				
	   ,iSequestrationDesc				
       ,iMaxEOCLines
	   ,iClaimInterestCalcType         
       ,iSSOEnabled
       ,iSSOPath
       ,iSSORedirectUrl
       ,iMemberIDMask
       ,iFirstBillingRun
       ,iAPTCBalancingStartDate
       ,iMultiplePortalInsurers
       ,iDisplayInactive
	   ,iProviderMatchingServiceEnabled	 
       ,iProviderMatchingServiceURL		 
       ,iProviderMatchingAPIKey			 
       ,iBL_SHL_Enabled
       ,iBL_SHL_LoadProvEnabled
       ,iBL_SHL_URL
       ,iBL_SHL_ClientID
       ,iBL_SHL_UserID
       ,iInstaMedAutoPay
       ,iInstaMedClientID
       ,iProvExtractVersion
       ,iClaimExtractVersion
       ,iClaimsExtractVersion
       ,iFinanceLetterVersion
	   ,iEODVersion
       ,InvoiceExtractShortVersion
       ,iMemberExtractVersion
       ,iSuppressSSN
       ,iEOBVersion
	   ,iEOPVersion						
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #GlobalValues

   OPEN GlobalValues_Cursor
  FETCH NEXT FROM GlobalValues_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iRecordKey1
       ,@iRecordKey2
       ,@iRecordKey3
       ,@iRecordKey4
       ,@iRecordKey5
       ,@iRecordKey6
       ,@iRecordKey7
       ,@iRecordKey8
       ,@iRecordKey9
       ,@iRecordKey10
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iCompanyName
       ,@iCompanyAddress1
       ,@iCompanyAddress2
       ,@iCompanyCity
       ,@iCompanyState
       ,@iCompanyZipCode
       ,@iCompanyPhone
       ,@iCompanyFax
       ,@iCompanyTaxID
       ,@iCompanyTCC
       ,@iCompanyABA
       ,@iCompanyBankAcctType
       ,@iCompanyBankAcctNum
       ,@iCompanyContactName
       ,@iCompanyContactPhone
       ,@iCompanyContactExt
       ,@iCompanyContactEmail
       ,@iCompanyBillingContact
       ,@iCompanyTollFreePhone
       ,@iCompanySenderQualifier
       ,@iCompanySenderID
       ,@iCompanyDefaultInsuranceCarrier
       ,@iInsuranceCarrierName
       ,@iProcessingStates
       ,@iCompanyDefaultLOB
       ,@iPasswordRuleID
       ,@iPasswordRuleDesc
       ,@iSessionTimeout
       ,@iTimeoutWarning
       ,@iDuplicateMemberCheck
       ,@iMaxClaimAge
       ,@iMedicaidInsuranceCarrier
       ,@iMedicaidCarrierName
       ,@iADAShow
       ,@iDentalEncounterShow
       ,@iPharmacyShow
       ,@iHCFAShow
       ,@iHCFAEncounterShow
       ,@iUBShow
       ,@iPredetYears
       ,@iProvW9
       ,@iResubFlag
       ,@iClaimType
       ,@iAuthTimeSpan
       ,@iInitialAssignmentCode
       ,@iClaimNumberIncomingInd
       ,@iClaimNumberManualInd
       ,@iDefRateID
       ,@iDefRateDesc
       ,@iToothNumberingSystem
       ,@iDOITermReason
       ,@iAutoGenMemID
       ,@iForceClear
       ,@iForceClearCC
       ,@iPCPMaint
       ,@iCCAuthCodeStore
       ,@iCascadePlanToDependents
       ,@iCascadeGroup
       ,@iCascadeMember
       ,@iSuppressCovMessage
       ,@iGenManualTermLtr
       ,@iNcpdpDefaultRejectCode
       ,@iNcpdpRejectDesc
       ,@iRemarkCode
       ,@iRemarkDesc
       ,@iPreDetCOBProcess
       ,@iPreDetCarryRules
       ,@iReinstatePrompt
       ,@iConcurrentBilling
       ,@iEligProcID
       ,@iEligProcDesc
       ,@iAlginEffectiveDate
       ,@iAutoReverseMemberPTD
       ,@iWarningPromptForGroupBilling
       ,@iCarrierRequired
       ,@iLanguageCodeFormat
       ,@iAdjustProvTaxWithholding
       ,@iCommonCodeLimitHistoryDisplay
       ,@iEligLoadAutoFinalize
       ,@iByPassPTD
       ,@iProvDispType
       ,@iProvDirSortOrder
       ,@iACHEnabled
       ,@iACHFileFormat
       ,@iCSArchiveMonths
       ,@iEligLoadReport
       ,@iImageExtension
       ,@iRunCapitation
       ,@iProduce277
       ,@iPosPayFileFormat
       ,@iCCFileFormat
       ,@iGroup_Trans
       ,@iEmailHours
       ,@iEmailList
       ,@iX12_835Version
       ,@iX12_835GE02
       ,@iX12_835ISA08
       ,@iX12_835GS02
       ,@iX12_835GS03
       ,@iX12_835GS06
       ,@iX12_835TRN03
       ,@iX12_835ExtractADA
       ,@iGlobalOutputType
       ,@iX12_834CapturePremium
       ,@iX12_834Version
       ,@iEthnicityCodeSet
       ,@iX12_837Version
       ,@iIncludeCoverageInExtract
       ,@iPaymentIntegrityClientID
       ,@iAcknowledgmentEmailList
       ,@iCheckReconSetsExternalCheckNumber
       ,@iFFMBaselineTradingPartnerID
	   ,@iFFMBaselineMemberIDPointer			-- SP41
	   ,@iFFMExchangeMemberIDPointer			-- SP41
	   ,@iFFMIssuerMemberIDPointer				-- SP41  
	   ,@iFFMIssuerPolicyIDPointer				-- SP43
       ,@iAdditionalEOPRecordValuesID
       ,@iAdditionalEOPRecordValuesDesc
       ,@iPortalSuppressInvoiceGroupListID		-- SP39
       ,@iPortalSuppressInvoiceGroupListDesc	-- SP39
	   ,@iPayeeIdentificationCodeQualifier		-- SP47
       ,@iDualSidedAcct
       ,@iNegInvProcess
       ,@iDefCensusMonths
       ,@iDisbEarnedOnly
       ,@iRetroAddCutoff
       ,@iRollingBalancePTD
       ,@iSuspenseGroupID
       ,@iSuspenseGroupDesc
       ,@iACHAggregation
       ,@iAllowRefundInterest
       ,@iSeparateACHProcess
       ,@iPreNoteProcess
       ,@iNPPPeriods
	   ,@InvoiceTraceGroupID					-- SP45  
	   ,@InvoiceTraceGroupName					-- SP45 
       ,@iInstaMedLockBoxABA
       ,@iInstaMedLockBoxBA
       ,@iInstaMedLockBoxBD
	   ,@iInstaMedPayerID						-- SP52
       ,@iInvCollection
       ,@iFlushSusGrp2Cancel
       ,@iMaxDollarID
       ,@iMaxDollarDesc
       ,@iRFFLimitID
       ,@iRFFLimitDesc
	   ,@iSequestrationID			
       ,@iSequestrationDesc			
       ,@iMaxEOCLines
	   ,@iClaimInterestCalcType		
       ,@iSSOEnabled
       ,@iSSOPath
       ,@iSSORedirectUrl
       ,@iMemberIDMask
       ,@iFirstBillingRun
       ,@iAPTCBalancingStartDate
       ,@iMultiplePortalInsurers
       ,@iDisplayInactive
	   ,@iProviderMatchingServiceEnabled	 
       ,@iProviderMatchingServiceURL		 
       ,@iProviderMatchingAPIKey
       ,@iBL_SHL_Enabled
       ,@iBL_SHL_LoadProvEnabled
       ,@iBL_SHL_URL
       ,@iBL_SHL_ClientID
       ,@iBL_SHL_UserID
       ,@iInstaMedAutoPay
       ,@iInstaMedClientID
       ,@iProvExtractVersion
       ,@iClaimExtractVersion
       ,@iClaimsExtractVersion
       ,@iFinanceLetterVersion
	   ,@iEODVersion					-- SP41
       ,@InvoiceExtractShortVersion
       ,@iMemberExtractVersion
       ,@iSuppressSSN
       ,@iEOBVersion
	   ,@iEOPVersion				
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			--Get the existing values
			TRUNCATE TABLE #Global_Populate
			INSERT INTO #Global_Populate
			  EXEC dbo.prGlobalParamPopulate

			-- Update any values that need to be updated
			SELECT TOP 1              
			       @iCompanyName						= CASE WHEN ISNULL(@iCompanyName, '') = ''							THEN GP.CompanyName						ELSE @iCompanyName END
                  ,@iCompanyAddress1					= CASE WHEN ISNULL(@iCompanyAddress1, '') = ''						THEN GP.CompanyAddress1					ELSE @iCompanyAddress1 END
                  ,@iCompanyAddress2					= CASE WHEN ISNULL(@iCompanyAddress2, '') = ''						THEN GP.CompanyAddress2					ELSE @iCompanyAddress2 END
                  ,@iCompanyCity						= CASE WHEN ISNULL(@iCompanyCity, '') = ''							THEN GP.CompanyCity						ELSE @iCompanyCity END
                  ,@iCompanyState						= CASE WHEN ISNULL(@iCompanyState, '') = ''							THEN GP.CompanyState					ELSE @iCompanyState END
                  ,@iCompanyZipCode						= CASE WHEN ISNULL(@iCompanyZipCode, '') = ''						THEN GP.CompanyZipCode					ELSE @iCompanyZipCode END
                  ,@iCompanyPhone						= CASE WHEN ISNULL(@iCompanyPhone, '') = ''							THEN GP.CompanyPhone					ELSE @iCompanyPhone END
                  ,@iCompanyFax							= CASE WHEN ISNULL(@iCompanyFax, '') = ''							THEN GP.CompanyFax						ELSE @iCompanyFax END
                  ,@iCompanyTaxID						= CASE WHEN ISNULL(@iCompanyTaxID, '') = ''							THEN GP.CompanyTaxID					ELSE @iCompanyTaxID END
                  ,@iCompanyTCC							= CASE WHEN ISNULL(@iCompanyTCC, '') = ''							THEN GP.CompanyTCC						ELSE @iCompanyTCC END
                  ,@iCompanyABA							= CASE WHEN ISNULL(@iCompanyABA, '') = ''							THEN GP.CompanyABA						ELSE @iCompanyABA END
                  ,@iCompanyBankAcctType				= CASE WHEN ISNULL(@iCompanyBankAcctType, '') = ''					THEN GP.CompanyBankAcctType				ELSE @iCompanyBankAcctType END
                  ,@iCompanyBankAcctNum					= CASE WHEN ISNULL(@iCompanyBankAcctNum, '') = ''					THEN GP.CompanyBankAcctNum				ELSE @iCompanyBankAcctNum END
                  ,@iCompanyContactName					= CASE WHEN ISNULL(@iCompanyContactName, '') = ''					THEN GP.CompanyContactName				ELSE @iCompanyContactName END
                  ,@iCompanyContactPhone				= CASE WHEN ISNULL(@iCompanyContactPhone, '') = ''					THEN GP.CompanyContactPhone				ELSE @iCompanyContactPhone END
                  ,@iCompanyContactExt					= CASE WHEN ISNULL(@iCompanyContactExt, '') = ''					THEN GP.CompanyContactExt				ELSE @iCompanyContactExt END
                  ,@iCompanyContactEmail				= CASE WHEN ISNULL(@iCompanyContactEmail, '') = ''					THEN GP.CompanyContactEmail				ELSE @iCompanyContactEmail END
                  ,@iCompanyBillingContact				= CASE WHEN ISNULL(@iCompanyBillingContact, '') = ''				THEN GP.CompanyBillingContact			ELSE @iCompanyBillingContact END
                  ,@iCompanyTollFreePhone				= CASE WHEN ISNULL(@iCompanyTollFreePhone, '') = ''					THEN GP.CompanyTollFreePhone			ELSE @iCompanyTollFreePhone END
                  ,@iCompanySenderQualifier				= CASE WHEN ISNULL(@iCompanySenderQualifier, '') = ''				THEN GP.CompanySenderQualifier			ELSE @iCompanySenderQualifier END
                  ,@iCompanySenderID					= CASE WHEN ISNULL(@iCompanySenderID, '') = ''						THEN GP.CompanySenderID					ELSE @iCompanySenderID END
                  ,@iCompanyDefaultInsuranceCarrier		= CASE WHEN ISNULL(@iCompanyDefaultInsuranceCarrier, '') = ''		THEN GP.CompanyDefaultInsuranceCarrier	ELSE @iCompanyDefaultInsuranceCarrier END
                  ,@iInsuranceCarrierName				= CASE WHEN ISNULL(@iInsuranceCarrierName, '') = ''					THEN GP.DefaultInsCarrierDesc ELSE @iInsuranceCarrierName END
                  ,@iProcessingStates					= CASE WHEN ISNULL(@iProcessingStates, '') = ''						THEN GP.ProcessingStates ELSE @iProcessingStates END
                  ,@iCompanyDefaultLOB					= CASE WHEN ISNULL(@iCompanyDefaultLOB, '') = ''					THEN GP.CompanyDefaultLOB ELSE @iCompanyDefaultLOB END
                  ,@iPasswordRuleID						= CASE WHEN ISNULL(@iPasswordRuleID, '') = ''						THEN GP.PasswordRuleID ELSE @iPasswordRuleID END
                  ,@iPasswordRuleDesc					= CASE WHEN ISNULL(@iPasswordRuleDesc, '') = ''						THEN GP.PasswordRuleDesc ELSE @iPasswordRuleDesc END
                  ,@iSessionTimeout						= CASE WHEN ISNULL(@iSessionTimeout, '') = ''						THEN GP.SessionTimeout ELSE @iSessionTimeout END
                  ,@iTimeoutWarning						= CASE WHEN ISNULL(@iTimeoutWarning, '') = ''						THEN GP.TimeoutWarning ELSE @iTimeoutWarning END
                  ,@iDuplicateMemberCheck				= CASE WHEN ISNULL(@iDuplicateMemberCheck, '') = ''					THEN GP.DuplicateMemberCheck ELSE @iDuplicateMemberCheck END
                  ,@iMaxClaimAge						= CASE WHEN ISNULL(@iMaxClaimAge, '') = ''							THEN GP.MaxClaimAge ELSE @iMaxClaimAge END
                  ,@iMedicaidInsuranceCarrier			= CASE WHEN ISNULL(@iMedicaidInsuranceCarrier, '') = ''				THEN GP.MedicaidInsuranceCarrier ELSE @iMedicaidInsuranceCarrier END
                  ,@iMedicaidCarrierName				= CASE WHEN ISNULL(@iMedicaidCarrierName, '') = ''					THEN GP.MedicaidCarrierName ELSE @iMedicaidCarrierName END
                  ,@iADAShow							= CASE WHEN ISNULL(@iADAShow, '') = ''								THEN GP.ADAShow ELSE @iADAShow END
                  ,@iDentalEncounterShow				= CASE WHEN ISNULL(@iDentalEncounterShow, '') = ''					THEN GP.DentalEncounterShow ELSE @iDentalEncounterShow END
                  ,@iPharmacyShow						= CASE WHEN ISNULL(@iPharmacyShow, '') = ''							THEN GP.PharmacyShow ELSE @iPharmacyShow END
                  ,@iHCFAShow							= CASE WHEN ISNULL(@iHCFAShow, '') = ''								THEN GP.HCFAShow ELSE @iHCFAShow END
                  ,@iHCFAEncounterShow					= CASE WHEN ISNULL(@iHCFAEncounterShow, '') = ''					THEN GP.HCFAEncounterShow ELSE @iHCFAEncounterShow END
                  ,@iUBShow								= CASE WHEN ISNULL(@iUBShow, '') = ''								THEN GP.UBShow ELSE @iUBShow END
                  ,@iPredetYears						= CASE WHEN ISNULL(@iPredetYears, '') = ''							THEN GP.PredetYears ELSE @iPredetYears END
                  ,@iProvW9								= CASE WHEN ISNULL(@iProvW9, '') = ''								THEN GP.ProvW9 ELSE @iProvW9 END
                  ,@iResubFlag							= CASE WHEN ISNULL(@iResubFlag, '') = ''							THEN GP.ResubFlag ELSE @iResubFlag END
                  ,@iClaimType							= CASE WHEN ISNULL(@iClaimType, '') = ''							THEN GP.ClaimType ELSE @iClaimType END
                  ,@iAuthTimeSpan						= CASE WHEN ISNULL(@iAuthTimeSpan, '') = ''							THEN GP.AuthTimeSpan ELSE @iAuthTimeSpan END
                  ,@iInitialAssignmentCode				= CASE WHEN ISNULL(@iInitialAssignmentCode, '') = ''				THEN GP.InitialAssignmentCode ELSE @iInitialAssignmentCode END
                  ,@iClaimNumberIncomingInd				= CASE WHEN ISNULL(@iClaimNumberIncomingInd, '') = ''				THEN GP.ClaimNumberIncomingInd ELSE @iClaimNumberIncomingInd END
                  ,@iClaimNumberManualInd				= CASE WHEN ISNULL(@iClaimNumberManualInd, '') = ''					THEN GP.ClaimNumberManualInd ELSE @iClaimNumberManualInd END
                  ,@iDefRateID							= CASE WHEN ISNULL(@iDefRateID, '') = ''							THEN GP.DefRateID ELSE @iDefRateID END
                  ,@iDefRateDesc						= CASE WHEN ISNULL(@iDefRateDesc, '') = ''							THEN GP.DefRateDesc ELSE @iDefRateDesc END
                  ,@iToothNumberingSystem				= CASE WHEN ISNULL(@iToothNumberingSystem, '') = ''					THEN GP.ToothNumberingSystem ELSE @iToothNumberingSystem END
                  ,@iDOITermReason						= CASE WHEN ISNULL(@iDOITermReason, '') = ''						THEN GP.DOITermReason ELSE @iDOITermReason END
                  ,@iAutoGenMemID						= CASE WHEN ISNULL(@iAutoGenMemID, '') = ''							THEN GP.AutoGenMemID ELSE @iAutoGenMemID END
                  ,@iForceClear							= CASE WHEN ISNULL(@iForceClear, '') = ''							THEN GP.ForceClear ELSE @iForceClear END
                  ,@iForceClearCC						= CASE WHEN ISNULL(@iForceClearCC, '') = ''							THEN GP.ForceClearCC ELSE @iForceClearCC END
                  ,@iPCPMaint							= CASE WHEN ISNULL(@iPCPMaint, '') = ''								THEN GP.PCPMaint ELSE @iPCPMaint END
                  ,@iCCAuthCodeStore					= CASE WHEN ISNULL(@iCCAuthCodeStore, '') = ''						THEN GP.CCAuthCodeStore ELSE @iCCAuthCodeStore END
                  ,@iCascadePlanToDependents			= CASE WHEN ISNULL(@iCascadePlanToDependents, '') = ''				THEN GP.CascadePlanToDependents ELSE @iCascadePlanToDependents END
                  ,@iCascadeGroup						= CASE WHEN ISNULL(@iCascadeGroup, '') = ''							THEN GP.CascadeGroup ELSE @iCascadeGroup END
                  ,@iCascadeMember						= CASE WHEN ISNULL(@iCascadeMember, '') = ''						THEN GP.CascadeMember ELSE @iCascadeMember END
                  ,@iSuppressCovMessage					= CASE WHEN ISNULL(@iSuppressCovMessage, '') = ''					THEN GP.SupCovMessage ELSE @iSuppressCovMessage END
                  ,@iGenManualTermLtr					= CASE WHEN ISNULL(@iGenManualTermLtr, '') = ''						THEN GP.GenManualTermLtr ELSE @iGenManualTermLtr END
                  ,@iNcpdpDefaultRejectCode				= CASE WHEN ISNULL(@iNcpdpDefaultRejectCode, '') = ''				THEN GP.NcpdpDefaultRejectCode ELSE @iNcpdpDefaultRejectCode END
                  ,@iRemarkCode							= CASE WHEN ISNULL(@iRemarkCode, '') = ''							THEN GP.RemarkCode ELSE @iRemarkCode END
                  ,@iPreDetCOBProcess					= CASE WHEN ISNULL(@iPreDetCOBProcess, '') = ''						THEN GP.PreDetCOBProcess ELSE @iPreDetCOBProcess END
                  ,@iPreDetCarryRules					= CASE WHEN ISNULL(@iPreDetCarryRules, '') = ''						THEN GP.PreDetCarryRules ELSE @iPreDetCarryRules END
                  ,@iReinstatePrompt					= CASE WHEN ISNULL(@iReinstatePrompt, '') = ''						THEN GP.ReinstatePrompt ELSE @iReinstatePrompt END
                  ,@iConcurrentBilling					= CASE WHEN ISNULL(@iConcurrentBilling, '') = ''					THEN GP.ConcurrentBilling ELSE @iConcurrentBilling END
                  ,@iEligProcID							= CASE WHEN ISNULL(@iEligProcID, '') = ''							THEN GP.EligProcID ELSE @iEligProcID END
                  ,@iEligProcDesc						= CASE WHEN ISNULL(@iEligProcDesc, '') = ''							THEN GP.EligProcDesc ELSE @iEligProcDesc END
                  ,@iAlginEffectiveDate					= CASE WHEN ISNULL(@iAlginEffectiveDate, '') = ''					THEN GP.AlginEffectiveDate ELSE @iAlginEffectiveDate END
                  ,@iAutoReverseMemberPTD				= CASE WHEN ISNULL(@iAutoReverseMemberPTD, '') = ''					THEN GP.AutoReverseMemberPTD ELSE @iAutoReverseMemberPTD END
                  ,@iWarningPromptForGroupBilling		= CASE WHEN ISNULL(@iWarningPromptForGroupBilling, '') = ''			THEN GP.WarningPromptForGroupBilling ELSE @iWarningPromptForGroupBilling END
                  ,@iCarrierRequired					= CASE WHEN ISNULL(@iCarrierRequired, '') = ''						THEN GP.CarrierRequired ELSE @iCarrierRequired END
                  ,@iLanguageCodeFormat					= CASE WHEN ISNULL(@iLanguageCodeFormat, '') = ''					THEN GP.LanguageCodeFormat ELSE @iLanguageCodeFormat END
                  ,@iAdjustProvTaxWithholding			= CASE WHEN ISNULL(@iAdjustProvTaxWithholding, '') = ''				THEN GP.AdjustProvTaxWithholding ELSE @iAdjustProvTaxWithholding END
                  ,@iCommonCodeLimitHistoryDisplay		= CASE WHEN ISNULL(@iCommonCodeLimitHistoryDisplay, '') = ''		THEN GP.CommonCodeLimitHistoryDisplay ELSE @iCommonCodeLimitHistoryDisplay END
                  ,@iEligLoadAutoFinalize				= CASE WHEN ISNULL(@iEligLoadAutoFinalize, '') = ''					THEN GP.EligLoadAutoFinalize ELSE @iEligLoadAutoFinalize END
                  ,@iByPassPTD							= CASE WHEN ISNULL(@iByPassPTD, '') = ''							THEN GP.BypassPTD ELSE @iByPassPTD END
                  ,@iProvDispType						= CASE WHEN ISNULL(@iProvDispType, '') = ''							THEN GP.ProvDispType ELSE @iProvDispType END
                  ,@iProvDirSortOrder					= CASE WHEN ISNULL(@iProvDirSortOrder, '') = ''						THEN GP.ProvDirSortOrder ELSE @iProvDirSortOrder END
                  ,@iACHEnabled							= CASE WHEN ISNULL(@iACHEnabled, '') = ''							THEN GP.ACHEnabled ELSE @iACHEnabled END
                  ,@iACHFileFormat						= CASE WHEN ISNULL(@iACHFileFormat, '') = ''						THEN GP.ACHFileFormat ELSE @iACHFileFormat END
                  ,@iCSArchiveMonths					= CASE WHEN ISNULL(@iCSArchiveMonths, '') = ''						THEN GP.CSArchiveMonths ELSE @iCSArchiveMonths END
                  ,@iEligLoadReport						= CASE WHEN ISNULL(@iEligLoadReport, '') = ''						THEN GP.EligLoadReport ELSE @iEligLoadReport END
                  ,@iImageExtension						= CASE WHEN ISNULL(@iImageExtension, '') = ''						THEN GP.ImageExtension ELSE @iImageExtension END
                  ,@iRunCapitation						= CASE WHEN ISNULL(@iRunCapitation, '') = ''						THEN GP.RunCapitation ELSE @iRunCapitation END
                  ,@iProduce277							= CASE WHEN ISNULL(@iProduce277, '') = ''							THEN GP.Produce277 ELSE @iProduce277 END
                  ,@iPosPayFileFormat					= CASE WHEN ISNULL(@iPosPayFileFormat, '') = ''						THEN GP.PosPayFileFormat ELSE @iPosPayFileFormat END
                  ,@iCCFileFormat						= CASE WHEN ISNULL(@iCCFileFormat, '') = ''							THEN GP.CCFileFormat ELSE @iCCFileFormat END
                  ,@iGroup_Trans						= CASE WHEN ISNULL(@iGroup_Trans, '') = ''							THEN GP.GroupTrans ELSE @iGroup_Trans END
                  ,@iEmailHours							= CASE WHEN ISNULL(@iEmailHours, '') = ''							THEN GP.EmailHours ELSE @iEmailHours END
                  ,@iEmailList							= CASE WHEN ISNULL(@iEmailList, '') = ''							THEN GP.EmailList ELSE @iEmailList END
                  ,@iX12_835Version						= CASE WHEN ISNULL(@iX12_835Version, '') = ''						THEN GP.X12_835Version ELSE @iX12_835Version END
                  ,@iX12_835GE02						= CASE WHEN ISNULL(@iX12_835GE02, '') = ''							THEN GP.X12_835GE02 ELSE @iX12_835GE02 END
                  ,@iX12_835ISA08						= CASE WHEN ISNULL(@iX12_835ISA08, '') = ''							THEN GP.X12_835ISA08 ELSE @iX12_835ISA08 END
                  ,@iX12_835GS02						= CASE WHEN ISNULL(@iX12_835GS02, '') = ''							THEN GP.X12_835GS02 ELSE @iX12_835GS02 END
                  ,@iX12_835GS03						= CASE WHEN ISNULL(@iX12_835GS03, '') = ''							THEN GP.X12_835GS03 ELSE @iX12_835GS03 END
                  ,@iX12_835GS06						= CASE WHEN ISNULL(@iX12_835GS06, '') = ''							THEN GP.X12_835GS06 ELSE @iX12_835GS06 END
                  ,@iX12_835TRN03						= CASE WHEN ISNULL(@iX12_835TRN03, '') = ''							THEN GP.X12_835TRN03 ELSE @iX12_835TRN03 END
                  ,@iX12_835ExtractADA					= CASE WHEN ISNULL(@iX12_835ExtractADA, '') = ''					THEN GP.X12_835ExtractADA ELSE @iX12_835ExtractADA END
                  ,@iGlobalOutputType					= CASE WHEN ISNULL(@iGlobalOutputType, '') = ''						THEN GP.GlobalOutputType ELSE @iGlobalOutputType END
                  ,@iX12_834CapturePremium				= CASE WHEN ISNULL(@iX12_834CapturePremium, '') = ''				THEN GP.X12_834CapturePremium ELSE @iX12_834CapturePremium END
                  ,@iX12_834Version						= CASE WHEN ISNULL(@iX12_834Version, '') = ''						THEN GP.X12_834Version ELSE @iX12_834Version END
                  ,@iEthnicityCodeSet					= CASE WHEN ISNULL(@iEthnicityCodeSet, '') = ''						THEN GP.EthnicityCodeSet ELSE @iEthnicityCodeSet END
                  ,@iX12_837Version						= CASE WHEN ISNULL(@iX12_837Version, '') = ''						THEN GP.X12_837Version ELSE @iX12_837Version END
                  ,@iIncludeCoverageInExtract			= CASE WHEN ISNULL(@iIncludeCoverageInExtract, '') = ''				THEN GP.LastExtract ELSE @iIncludeCoverageInExtract END
                  ,@iPaymentIntegrityClientID			= CASE WHEN ISNULL(@iPaymentIntegrityClientID, '') = ''				THEN GP.PaymentIntegrityClientID ELSE @iPaymentIntegrityClientID END
                  ,@iAcknowledgmentEmailList			= CASE WHEN ISNULL(@iAcknowledgmentEmailList, '') = ''				THEN GP.AcknowledgmentEmailList ELSE @iAcknowledgmentEmailList END
                  ,@iCheckReconSetsExternalCheckNumber	= CASE WHEN ISNULL(@iCheckReconSetsExternalCheckNumber, '') = ''	THEN GP.CheckReconSetsExternalCheckNumber ELSE @iCheckReconSetsExternalCheckNumber END
                  ,@iFFMBaselineTradingPartnerID		= CASE WHEN ISNULL(@iFFMBaselineTradingPartnerID, '') = ''			THEN GP.FFMBaselineTradingPartnerID ELSE @iFFMBaselineTradingPartnerID END
				  ,@iFFMBaselineMemberIDPointer			= CASE WHEN ISNULL(@iFFMBaselineMemberIDPointer, '') = ''			THEN GP.FFMBaselineMemberIDPointer ELSE @iFFMBaselineMemberIDPointer END
                  ,@iFFMExchangeMemberIDPointer			= CASE WHEN ISNULL(@iFFMExchangeMemberIDPointer, '') = ''			THEN GP.FFMExchangeMemberIDPointer ELSE @iFFMExchangeMemberIDPointer END
				  ,@iFFMIssuerMemberIDPointer			= CASE WHEN ISNULL(@iFFMIssuerMemberIDPointer, '') = ''				THEN GP.FFMIssuerMemberIDPointer ELSE @iFFMIssuerMemberIDPointer END
				  ,@iFFMIssuerPolicyIDPointer			= CASE WHEN ISNULL(@iFFMIssuerPolicyIDPointer, '') = ''				THEN GP.FFMIssuerPolicyIDPointer ELSE @iFFMIssuerPolicyIDPointer END
				  ,@iAdditionalEOPRecordValuesID		= CASE WHEN ISNULL(@iAdditionalEOPRecordValuesID, '') = ''			THEN GP.AdditionalEOPRecordValuesID ELSE @iAdditionalEOPRecordValuesID END
                  ,@iAdditionalEOPRecordValuesDesc		= CASE WHEN ISNULL(@iAdditionalEOPRecordValuesDesc, '') = ''		THEN GP.AdditionalEOPRecordValuesDesc ELSE @iAdditionalEOPRecordValuesDesc END
                  ,@iPortalSuppressInvoiceGroupListID	= CASE WHEN ISNULL(@iPortalSuppressInvoiceGroupListID, '') = ''		THEN GP.PortalSuppressInvoiceGroupListID ELSE @iPortalSuppressInvoiceGroupListID END		-- SP39
                  ,@iPortalSuppressInvoiceGroupListDesc	= CASE WHEN ISNULL(@iPortalSuppressInvoiceGroupListDesc, '') = ''	THEN GP.PortalSuppressInvoiceGroupListDesc ELSE @iPortalSuppressInvoiceGroupListDesc END	-- SP39
                  ,@iPayeeIdentificationCodeQualifier	= CASE WHEN ISNULL(@iPayeeIdentificationCodeQualifier, '') = ''		THEN GP.PayeeIdentificationCodeQualifier ELSE @iPayeeIdentificationCodeQualifier END		-- SP47
				  ,@iDualSidedAcct						= CASE WHEN ISNULL(@iDualSidedAcct, '') = ''						THEN GP.DualSided ELSE @iDualSidedAcct END
                  ,@iNegInvProcess						= CASE WHEN ISNULL(@iNegInvProcess, '') = ''						THEN GP.NegInvProcess ELSE @iNegInvProcess END
                  ,@iDefCensusMonths					= CASE WHEN ISNULL(@iDefCensusMonths, '') = ''						THEN GP.DefCensusMonths ELSE @iDefCensusMonths END
                  ,@iDisbEarnedOnly						= CASE WHEN ISNULL(@iDisbEarnedOnly, '') = ''						THEN GP.DisbEarnedOnly ELSE @iDisbEarnedOnly END
                  ,@iRetroAddCutoff						= CASE WHEN ISNULL(@iRetroAddCutoff, '') = ''						THEN GP.RetroAddCutoff ELSE @iRetroAddCutoff END
                  ,@iRollingBalancePTD					= CASE WHEN ISNULL(@iRollingBalancePTD, '') = ''					THEN GP.RollingBalancePTD ELSE @iRollingBalancePTD END
                  ,@iSuspenseGroupID					= CASE WHEN ISNULL(@iSuspenseGroupID, '') = ''						THEN GP.SuspenseGroupID ELSE @iSuspenseGroupID END
                  ,@iSuspenseGroupDesc					= CASE WHEN ISNULL(@iSuspenseGroupDesc, '') = ''					THEN GP.SuspenseGroupName ELSE @iSuspenseGroupDesc END
                  ,@iACHAggregation						= CASE WHEN ISNULL(@iACHAggregation, '') = ''						THEN GP.ACHAggregation ELSE @iACHAggregation END
                  ,@iAllowRefundInterest				= CASE WHEN ISNULL(@iAllowRefundInterest, '') = ''					THEN GP.AllowRefundInterest ELSE @iAllowRefundInterest END
                  ,@iSeparateACHProcess					= CASE WHEN ISNULL(@iSeparateACHProcess, '') = ''					THEN GP.SeparateACHProcess ELSE @iSeparateACHProcess END
                  ,@iPreNoteProcess						= CASE WHEN ISNULL(@iPreNoteProcess, '') = ''						THEN GP.PreNoteProcess ELSE @iPreNoteProcess END
                  ,@iNPPPeriods							= CASE WHEN ISNULL(@iNPPPeriods, '') = ''							THEN GP.NPPMonths ELSE @iNPPPeriods END
                  ,@InvoiceTraceGroupID					= CASE WHEN ISNULL(@InvoiceTraceGroupID, '') = ''					THEN GP.InvoiceTraceGroupID ELSE @InvoiceTraceGroupID END
				  ,@InvoiceTraceGroupName				= CASE WHEN ISNULL(@InvoiceTraceGroupName, '') = ''					THEN GP.InvoiceTraceGroupName ELSE @InvoiceTraceGroupName END
				  ,@iInstaMedLockBoxABA					= CASE WHEN ISNULL(@iInstaMedLockBoxABA, '') = ''					THEN GP.InstaMedLockBoxBN ELSE @iInstaMedLockBoxABA END
                  ,@iInstaMedLockBoxBA					= CASE WHEN ISNULL(@iInstaMedLockBoxBA, '') = ''					THEN GP.InstaMedLockBoxBA ELSE @iInstaMedLockBoxBA END
                  ,@iInstaMedLockBoxBD					= CASE WHEN ISNULL(@iInstaMedLockBoxBD, '') = ''					THEN GP.InstaMedLockBoxBD ELSE @iInstaMedLockBoxBD END
                  ,@iInstaMedPayerID					= CASE WHEN ISNULL(@iInstaMedPayerID, '') = ''						THEN GP.iInstaMedPayerID ELSE @iInstaMedPayerID END
				  ,@iInvCollection						= CASE WHEN ISNULL(@iInvCollection, '') = ''						THEN GP.InvCollection ELSE @iInvCollection END
                  ,@iFlushSusGrp2Cancel					= CASE WHEN ISNULL(@iFlushSusGrp2Cancel, '') = ''					THEN GP.FlushSusGrp2Cancel ELSE @iFlushSusGrp2Cancel END
                  ,@iMaxDollarID						= CASE WHEN ISNULL(@iMaxDollarID, '') = ''							THEN GP.MAXDollarID ELSE @iMaxDollarID END
                  ,@iMaxDollarDesc						= CASE WHEN ISNULL(@iMaxDollarDesc, '') = ''						THEN GP.MAXDollarDesc ELSE @iMaxDollarDesc END
                  ,@iRFFLimitID							= CASE WHEN ISNULL(@iRFFLimitID, '') = ''							THEN GP.RFFLimitId ELSE @iRFFLimitID END
                  ,@iRFFLimitDesc						= CASE WHEN ISNULL(@iRFFLimitDesc, '') = ''							THEN GP.RFFLimitDesc ELSE @iRFFLimitDesc END
				  ,@iSequestrationID					= CASE WHEN ISNULL(@iSequestrationID, '') = ''						THEN GP.SequestrationID ELSE @iSequestrationID END  -- SP39
                  ,@iSequestrationDesc					= CASE WHEN ISNULL(@iSequestrationDesc, '') = ''					THEN GP.SequestrationDesc ELSE @iSequestrationDesc END	-- SP39
                  ,@iMaxEOCLines						= CASE WHEN ISNULL(@iMaxEOCLines, '') = ''							THEN GP.MaxEOCLines ELSE @iMaxEOCLines END
				  ,@iClaimInterestCalcType				= CASE WHEN ISNULL(@iClaimInterestCalcType, '') = ''				THEN GP.ClaimInterestCalcType ELSE @iClaimInterestCalcType END	-- SP38
                  ,@iSSOEnabled							= CASE WHEN ISNULL(@iSSOEnabled, '') = ''							THEN GP.SSOEnable ELSE @iSSOEnabled END
                  ,@iSSOPath							= CASE WHEN ISNULL(@iSSOPath, '') = ''								THEN GP.SSOPath ELSE @iSSOPath END
                  ,@iSSORedirectUrl						= CASE WHEN ISNULL(@iSSORedirectUrl, '') = ''						THEN GP.SSORedirectUrl ELSE @iSSORedirectUrl END
                  ,@iMemberIDMask						= CASE WHEN ISNULL(@iMemberIDMask, '') = ''							THEN GP.MemberIDMask ELSE @iMemberIDMask END
                  ,@iFirstBillingRun					= CASE WHEN ISNULL(@iFirstBillingRun, '') = ''						THEN GP.FirstBillingRun ELSE @iFirstBillingRun END
                  ,@iAPTCBalancingStartDate				= CASE WHEN ISNULL(@iAPTCBalancingStartDate, '') = ''				THEN GP.APTCBalancingStartDate ELSE @iAPTCBalancingStartDate END
                  ,@iMultiplePortalInsurers				= CASE WHEN ISNULL(@iMultiplePortalInsurers, '') = ''				THEN GP.MultiplePortalInsurers ELSE @iMultiplePortalInsurers END
                  ,@iDisplayInactive					= CASE WHEN ISNULL(@iDisplayInactive, '') = ''						THEN GP.DisplayInactive ELSE @iDisplayInactive END
                  ,@iProviderMatchingServiceEnabled		= GP.ProviderMatchingServiceEnabled
				  ,@iProviderMatchingServiceURL			= GP.ProviderMatchingServiceURL
				  ,@iProviderMatchingAPIKey				= GP.ProviderMatchingAPIKey
				  --,@iBL_SHL_Enabled					= CASE WHEN ISNULL(@iBL_SHL_Enabled, '') = ''						THEN GP.BL_SHL_Enabled ELSE @iBL_SHL_Enabled END
                  --,@iBL_SHL_LoadProvEnabled			= CASE WHEN ISNULL(@iBL_SHL_LoadProvEnabled, '') = ''				THEN GP.BL_SHL_LoadProvEnabled ELSE @iBL_SHL_LoadProvEnabled END
                  --,@iBL_SHL_URL						= CASE WHEN ISNULL(@iBL_SHL_URL, '') = ''							THEN GP.BL_SHL_URL ELSE @iBL_SHL_URL END
                  --,@iBL_SHL_ClientID					= CASE WHEN ISNULL(@iBL_SHL_ClientID, '') = ''						THEN GP.BL_SHL_ClientID ELSE @iBL_SHL_ClientID END
                  --,@iBL_SHL_UserID					= CASE WHEN ISNULL(@iBL_SHL_UserID, '') = ''						THEN GP.BL_SHL_UserID ELSE @iBL_SHL_UserID END
                  ,@iInstaMedAutoPay					= CASE WHEN ISNULL(@iInstaMedAutoPay, '') = ''						THEN GP.InstaMedAutoPay ELSE @iInstaMedAutoPay END
                  ,@iInstaMedClientID					= CASE WHEN ISNULL(@iInstaMedClientID, '') = ''						THEN GP.InstaMedClientID ELSE @iInstaMedClientID END
                  ,@iProvExtractVersion					= CASE WHEN ISNULL(@iProvExtractVersion, '') = ''					THEN GP.ProvExtractVersion ELSE @iProvExtractVersion END
                  ,@iClaimExtractVersion				= CASE WHEN ISNULL(@iClaimExtractVersion, '') = ''					THEN GP.ClaimExtractVersion ELSE @iClaimExtractVersion END
                  ,@iClaimsExtractVersion				= CASE WHEN ISNULL(@iClaimsExtractVersion, '') = ''					THEN GP.ClaimsExtractVersion ELSE @iClaimsExtractVersion END
                  ,@iFinanceLetterVersion				= CASE WHEN ISNULL(@iFinanceLetterVersion, '') = ''					THEN GP.FinanceLetterVersion ELSE @iFinanceLetterVersion END
                  ,@iEODVersion							= CASE WHEN ISNULL(@iEODVersion, '') = ''							THEN GP.EODVersion ELSE @iEODVersion END	-- SP41
				  ,@InvoiceExtractShortVersion			= CASE WHEN ISNULL(@InvoiceExtractShortVersion, '') = ''			THEN GP.InvoiceExtractShortVersion ELSE @InvoiceExtractShortVersion END
                  ,@iMemberExtractVersion				= CASE WHEN ISNULL(@iMemberExtractVersion, '') = ''					THEN GP.MemberExtractVersion ELSE @iMemberExtractVersion END
                  ,@iSuppressSSN						= CASE WHEN ISNULL(@iSuppressSSN, '') = ''							THEN GP.SuppressSSN ELSE @iSuppressSSN END
                  ,@iEOBVersion							= CASE WHEN ISNULL(@iEOBVersion, '') = ''							THEN GP.EOBVersion ELSE @iEOBVersion END
				  ,@iEOPVersion							= CASE WHEN ISNULL(@iEOPVersion, '') = ''							THEN GP.EOPVersion ELSE @iEOPVersion END	-- SP39
			  FROM #Global_Populate GP

			EXEC dbo.prGlobalParamModify
				 @iEntity
				,@iRecordKey1
				,@iRecordKey2
				,@iRecordKey3
				,@iRecordKey4
				,@iRecordKey5
				,@iRecordKey6
				,@iRecordKey7
				,@iRecordKey8
				,@iRecordKey9
				,@iRecordKey10
				,@iAction
				,@iModifiedDate
				,@iUserID
				,@iCompanyName
				,@iCompanyAddress1
				,@iCompanyAddress2
				,@iCompanyCity
				,@iCompanyState
				,@iCompanyZipCode
				,@iCompanyPhone
				,@iCompanyFax
				,@iCompanyTaxID
				,@iCompanyTCC
				,@iCompanyABA
				,@iCompanyBankAcctType
				,@iCompanyBankAcctNum
				,@iCompanyContactName
				,@iCompanyContactPhone
				,@iCompanyContactExt
				,@iCompanyContactEmail
				,@iCompanyBillingContact
				,@iCompanyTollFreePhone
				,@iCompanySenderQualifier
				,@iCompanySenderID
				,@iCompanyDefaultInsuranceCarrier
				,@iInsuranceCarrierName
				,@iProcessingStates
				,@iCompanyDefaultLOB
				,@iPasswordRuleID
				,@iPasswordRuleDesc
				,@iSessionTimeout
				,@iTimeoutWarning
				,@iDuplicateMemberCheck
				,@iMaxClaimAge
				,@iMedicaidInsuranceCarrier
				,@iMedicaidCarrierName
				,@iADAShow
				,@iDentalEncounterShow
				,@iPharmacyShow
				,@iHCFAShow
				,@iHCFAEncounterShow
				,@iUBShow
				,@iPredetYears
				,@iProvW9
				,@iResubFlag
				,@iClaimType
				,@iAuthTimeSpan
				,@iInitialAssignmentCode
				,@iClaimNumberIncomingInd
				,@iClaimNumberManualInd
				,@iDefRateID
				,@iDefRateDesc
				,@iToothNumberingSystem
				,@iDOITermReason
				,@iAutoGenMemID
				,@iForceClear
				,@iForceClearCC
				,@iPCPMaint
				,@iCCAuthCodeStore
				,@iCascadePlanToDependents
				,@iCascadeGroup
				,@iCascadeMember
				,@iSuppressCovMessage
				,@iGenManualTermLtr
				,@iNcpdpDefaultRejectCode
				,@iNcpdpRejectDesc
				,@iRemarkCode
				,@iRemarkDesc
				,@iPreDetCOBProcess
				,@iPreDetCarryRules
				,@iReinstatePrompt
				,@iConcurrentBilling
				,@iEligProcID
				,@iEligProcDesc
				,@iAlginEffectiveDate
				,@iAutoReverseMemberPTD
				,@iWarningPromptForGroupBilling
				,@iCarrierRequired
				,@iLanguageCodeFormat
				,@iAdjustProvTaxWithholding
				,@iCommonCodeLimitHistoryDisplay
				,@iEligLoadAutoFinalize
				,@iByPassPTD
				,@iProvDispType
				,@iProvDirSortOrder
				,@iACHEnabled
				,@iACHFileFormat
				,@iCSArchiveMonths
				,@iEligLoadReport
				,@iImageExtension
				,@iRunCapitation
				,@iProduce277
				,@iPosPayFileFormat
				,@iCCFileFormat
				,@iGroup_Trans
				,@iEmailHours
				,@iEmailList
				,@iX12_835Version
				,@iX12_835GE02
				,@iX12_835ISA08
				,@iX12_835GS02
				,@iX12_835GS03
				,@iX12_835GS06
				,@iX12_835TRN03
				,@iX12_835ExtractADA
				,@iGlobalOutputType
				,@iX12_834CapturePremium
				,@iX12_834Version
				,@iEthnicityCodeSet
				,@iX12_837Version
				,@iIncludeCoverageInExtract
				,@iPaymentIntegrityClientID
				,@iAcknowledgmentEmailList
				,@iCheckReconSetsExternalCheckNumber
				,@iFFMBaselineTradingPartnerID
				,@iFFMBaselineMemberIDPointer				-- SP41
				,@iFFMExchangeMemberIDPointer				-- SP41
				,@iFFMIssuerMemberIDPointer					-- SP41  
				,@iFFMIssuerPolicyIDPointer					-- SP43
				,@iAdditionalEOPRecordValuesID
				,@iAdditionalEOPRecordValuesDesc
				,@iPortalSuppressInvoiceGroupListID			-- SP39
			    ,@iPortalSuppressInvoiceGroupListDesc		-- SP39
				,@iPayeeIdentificationCodeQualifier			-- SP47
				,@iDualSidedAcct
				,@iNegInvProcess
				,@iDefCensusMonths
				,@iDisbEarnedOnly
				,@iRetroAddCutoff
				,@iRollingBalancePTD
				,@iSuspenseGroupID
				,@iSuspenseGroupDesc
				,@iACHAggregation
				,@iAllowRefundInterest
				,@iSeparateACHProcess
				,@iPreNoteProcess
				,@iNPPPeriods
			    ,@InvoiceTraceGroupID					-- SP45  
			    ,@InvoiceTraceGroupName					-- SP45 
				,@iInstaMedLockBoxABA
				,@iInstaMedLockBoxBA
				,@iInstaMedLockBoxBD
				,@iInstaMedPayerID						-- SP52
				,@iInvCollection
				,@iFlushSusGrp2Cancel
				,@iMaxDollarID
				,@iMaxDollarDesc
				,@iRFFLimitID
				,@iRFFLimitDesc
				,@iSequestrationID				-- SP39
				,@iSequestrationDesc			-- SP39
				,@iMaxEOCLines
				,@iClaimInterestCalcType		-- SP38
				,@iSSOEnabled
				,@iSSOPath
				,@iSSORedirectUrl
				,@iMemberIDMask
				,@iFirstBillingRun
				,@iAPTCBalancingStartDate
				,@iMultiplePortalInsurers
				,@iDisplayInactive
				,@iProviderMatchingServiceEnabled	 
				,@iProviderMatchingServiceURL		 
				,@iProviderMatchingAPIKey
				,@iInstaMedAutoPay
				,@iInstaMedClientID
				--,@iBL_SHL_Enabled				-- SP52
				--,@iBL_SHL_LoadProvEnabled		-- SP52
				--,@iBL_SHL_URL					-- SP52
				--,@iBL_SHL_ClientID			-- SP52
				--,@iBL_SHL_UserID				-- SP52
				,@iProvExtractVersion
				,@iClaimExtractVersion
				,@iClaimsExtractVersion
				,@iFinanceLetterVersion
				,@iEODVersion					-- SP41
				,@InvoiceExtractShortVersion
				,@iMemberExtractVersion
				,@iSuppressSSN
				,@iEOBVersion
				,@iEOPVersion					-- SP39
				,@oStatus     = @err_num OUTPUT
				,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Missing', '', '', @status, @err_num, @err_msg

        FETCH NEXT FROM GlobalValues_Cursor
         INTO   @SearchID
			   ,@iEntity
			   ,@iRecordKey1
			   ,@iRecordKey2
			   ,@iRecordKey3
			   ,@iRecordKey4
			   ,@iRecordKey5
			   ,@iRecordKey6
			   ,@iRecordKey7
			   ,@iRecordKey8
			   ,@iRecordKey9
			   ,@iRecordKey10
			   ,@iAction
			   ,@iModifiedDate
			   ,@iUserID
			   ,@iCompanyName
			   ,@iCompanyAddress1
			   ,@iCompanyAddress2
			   ,@iCompanyCity
			   ,@iCompanyState
			   ,@iCompanyZipCode
			   ,@iCompanyPhone
			   ,@iCompanyFax
			   ,@iCompanyTaxID
			   ,@iCompanyTCC
			   ,@iCompanyABA
			   ,@iCompanyBankAcctType
			   ,@iCompanyBankAcctNum
			   ,@iCompanyContactName
			   ,@iCompanyContactPhone
			   ,@iCompanyContactExt
			   ,@iCompanyContactEmail
			   ,@iCompanyBillingContact
			   ,@iCompanyTollFreePhone
			   ,@iCompanySenderQualifier
			   ,@iCompanySenderID
			   ,@iCompanyDefaultInsuranceCarrier
			   ,@iInsuranceCarrierName
			   ,@iProcessingStates
			   ,@iCompanyDefaultLOB
			   ,@iPasswordRuleID
			   ,@iPasswordRuleDesc
			   ,@iSessionTimeout
			   ,@iTimeoutWarning
			   ,@iDuplicateMemberCheck
			   ,@iMaxClaimAge
			   ,@iMedicaidInsuranceCarrier
			   ,@iMedicaidCarrierName
			   ,@iADAShow
			   ,@iDentalEncounterShow
			   ,@iPharmacyShow
			   ,@iHCFAShow
			   ,@iHCFAEncounterShow
			   ,@iUBShow
			   ,@iPredetYears
			   ,@iProvW9
			   ,@iResubFlag
			   ,@iClaimType
			   ,@iAuthTimeSpan
			   ,@iInitialAssignmentCode
			   ,@iClaimNumberIncomingInd
			   ,@iClaimNumberManualInd
			   ,@iDefRateID
			   ,@iDefRateDesc
			   ,@iToothNumberingSystem
			   ,@iDOITermReason
			   ,@iAutoGenMemID
			   ,@iForceClear
			   ,@iForceClearCC
			   ,@iPCPMaint
			   ,@iCCAuthCodeStore
			   ,@iCascadePlanToDependents
			   ,@iCascadeGroup
			   ,@iCascadeMember
			   ,@iSuppressCovMessage
			   ,@iGenManualTermLtr
			   ,@iNcpdpDefaultRejectCode
			   ,@iNcpdpRejectDesc
			   ,@iRemarkCode
			   ,@iRemarkDesc
			   ,@iPreDetCOBProcess
			   ,@iPreDetCarryRules
			   ,@iReinstatePrompt
			   ,@iConcurrentBilling
			   ,@iEligProcID
			   ,@iEligProcDesc
			   ,@iAlginEffectiveDate
			   ,@iAutoReverseMemberPTD
			   ,@iWarningPromptForGroupBilling
			   ,@iCarrierRequired
			   ,@iLanguageCodeFormat
			   ,@iAdjustProvTaxWithholding
			   ,@iCommonCodeLimitHistoryDisplay
			   ,@iEligLoadAutoFinalize
			   ,@iByPassPTD
			   ,@iProvDispType
			   ,@iProvDirSortOrder
			   ,@iACHEnabled
			   ,@iACHFileFormat
			   ,@iCSArchiveMonths
			   ,@iEligLoadReport
			   ,@iImageExtension
			   ,@iRunCapitation
			   ,@iProduce277
			   ,@iPosPayFileFormat
			   ,@iCCFileFormat
			   ,@iGroup_Trans
			   ,@iEmailHours
			   ,@iEmailList
			   ,@iX12_835Version
			   ,@iX12_835GE02
			   ,@iX12_835ISA08
			   ,@iX12_835GS02
			   ,@iX12_835GS03
			   ,@iX12_835GS06
			   ,@iX12_835TRN03
			   ,@iX12_835ExtractADA
			   ,@iGlobalOutputType
			   ,@iX12_834CapturePremium
			   ,@iX12_834Version
			   ,@iEthnicityCodeSet
			   ,@iX12_837Version
			   ,@iIncludeCoverageInExtract
			   ,@iPaymentIntegrityClientID
			   ,@iAcknowledgmentEmailList
			   ,@iCheckReconSetsExternalCheckNumber
			   ,@iFFMBaselineTradingPartnerID
			   ,@iFFMBaselineMemberIDPointer				-- SP41
			   ,@iFFMExchangeMemberIDPointer				-- SP41
			   ,@iFFMIssuerMemberIDPointer					-- SP41  
			   ,@iFFMIssuerPolicyIDPointer					-- SP43
			   ,@iAdditionalEOPRecordValuesID
			   ,@iAdditionalEOPRecordValuesDesc
			   ,@iPortalSuppressInvoiceGroupListID			-- SP39
			   ,@iPortalSuppressInvoiceGroupListDesc		-- SP39
			   ,@iPayeeIdentificationCodeQualifier			-- SP47
			   ,@iDualSidedAcct
			   ,@iNegInvProcess
			   ,@iDefCensusMonths
			   ,@iDisbEarnedOnly
			   ,@iRetroAddCutoff
			   ,@iRollingBalancePTD
			   ,@iSuspenseGroupID
			   ,@iSuspenseGroupDesc
			   ,@iACHAggregation
			   ,@iAllowRefundInterest
			   ,@iSeparateACHProcess
			   ,@iPreNoteProcess
			   ,@iNPPPeriods
			   ,@InvoiceTraceGroupID					-- SP45  
			   ,@InvoiceTraceGroupName					-- SP45 
			   ,@iInstaMedLockBoxABA
			   ,@iInstaMedLockBoxBA
			   ,@iInstaMedLockBoxBD
			   ,@iInstaMedPayerID						-- SP52
			   ,@iInvCollection
			   ,@iFlushSusGrp2Cancel
			   ,@iMaxDollarID
			   ,@iMaxDollarDesc
			   ,@iRFFLimitID
			   ,@iRFFLimitDesc
			   ,@iSequestrationID			
			   ,@iSequestrationDesc			
			   ,@iMaxEOCLines
			   ,@iClaimInterestCalcType		
			   ,@iSSOEnabled
			   ,@iSSOPath
			   ,@iSSORedirectUrl
			   ,@iMemberIDMask
			   ,@iFirstBillingRun
			   ,@iAPTCBalancingStartDate
			   ,@iMultiplePortalInsurers
			   ,@iDisplayInactive
			   ,@iProviderMatchingServiceEnabled	 
			   ,@iProviderMatchingServiceURL		 
			   ,@iProviderMatchingAPIKey
			   ,@iBL_SHL_Enabled
			   ,@iBL_SHL_LoadProvEnabled
			   ,@iBL_SHL_URL
			   ,@iBL_SHL_ClientID
			   ,@iBL_SHL_UserID
			   ,@iInstaMedAutoPay
			   ,@iInstaMedClientID
			   ,@iProvExtractVersion
			   ,@iClaimExtractVersion
			   ,@iClaimsExtractVersion
			   ,@iFinanceLetterVersion
			   ,@iEODVersion
			   ,@InvoiceExtractShortVersion
			   ,@iMemberExtractVersion
			   ,@iSuppressSSN
			   ,@iEOBVersion
			   ,@iEOPVersion				
			   ,@oStatus
			   ,@oMessage
			   ,@record_id
			   ,@static_gid
	END

CLOSE GlobalValues_Cursor
DEALLOCATE GlobalValues_Cursor

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GlobalValues') IS NOT NULL
	DROP TABLE #GlobalValues

IF Object_ID('tempdb.dbo.#Global_Populate') IS NOT NULL
	DROP TABLE #Global_Populate

END
GO