IF OBJECT_ID('dbo.spDCAuto_CreateMemberDependents') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberDependents AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberDependents
Purpose:    Create memberdependents data from CorderAutomation
Method:     MemberDependents
Screen GID: 12
Procedure:  dbo.prMemberAdd

Date        User            Change
---------------------------------------------------------------------------------------------
01/10/2020	DK				Original procedure
02/07/2020	DK				Changed temp table name to avoid naming conflicts
11/10/2021	DK				Fix issue with Provider Name being blank when assigning PCP for dep
04/08/2022  DK				Remove code to set the gids
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberDependents 'Census-Config-20%', 22, 'Census-Config-2001', 'MemberDependents', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberDependents
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
	   ,@child_gid					INT
	   ,@parent_gid					INT
	   ,@demographic_gid			INT
	   ,@contact_gid				INT

	   ,@current_mailing_gid		INT
	   ,@current_physical_gid		INT
	   ,@current_default_gid		INT
	   ,@mailing_gid				INT
	   ,@physical_gid				INT
	   ,@default_gid				INT

	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name               VARCHAR(50)
       ,@i_child_gid                 VARCHAR(50)
       ,@i_child_id                  VARCHAR(50)
       ,@i_parent_gid                VARCHAR(50)
       ,@i_parent_id                 VARCHAR(50)
       ,@i_iEff_Date                 VARCHAR(50)
       ,@i_iTerm_Date                VARCHAR(50)
       ,@i_Group_gid                 VARCHAR(50)
       ,@i_key_8_field               VARCHAR(50)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_key_10_field              VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_Date_Time_Modified        CHAR(200)
       ,@iUserID                     VARCHAR(25)
       ,@i_Group_id                  VARCHAR(50)
       ,@i_Group_Desc                VARCHAR(50)
       ,@i_Member_id                 VARCHAR(50)
       ,@i_Person_Code               VARCHAR(50)
       ,@i_Prefix                    VARCHAR(50)
       ,@i_First_Name                VARCHAR(50)
       ,@i_Middle_Name               VARCHAR(50)
       ,@i_Last_Name                 VARCHAR(60)
       ,@i_department_code           VARCHAR(50)
       ,@i_Salutation_Name           VARCHAR(50)
       ,@i_Suffix                    VARCHAR(50)
       ,@i_Gender                    VARCHAR(50)
       ,@i_Height                    VARCHAR(50)
       ,@i_Weight                    VARCHAR(50)
       ,@i_Ethnic                    VARCHAR(50)
       ,@i_Smoker                    VARCHAR(50)
       ,@i_visually_impaired         VARCHAR(50)
       ,@i_language1                 VARCHAR(50)
       ,@i_language1_Desc            VARCHAR(100)
       ,@iLanguageUse1               VARCHAR(50)
       ,@i_language2                 VARCHAR(50)
       ,@i_language2_Desc            VARCHAR(50)
       ,@iLanguageUse2               VARCHAR(50)
       ,@i_salary                    VARCHAR(50)
       ,@i_Birth_Date                VARCHAR(50)
       ,@i_Actual_SSN                VARCHAR(50)
       ,@i_Prior_Member_id           VARCHAR(50)
       ,@i_Hipaa_id                  VARCHAR(50)
       ,@i_Other_Parent_id           VARCHAR(50)
       ,@i_Hire_Date                 VARCHAR(50)
       ,@i_Marital_Status            VARCHAR(50)
       ,@i_Relationship_Code         VARCHAR(50)
       ,@i_Employee_Status           VARCHAR(50)
       ,@i_Employment_Status         VARCHAR(50)
       ,@i_HIPAA_Ques                VARCHAR(50)
       ,@i_HIPAA_Ans                 VARCHAR(50)
       ,@i_Address_1                 VARCHAR(55)
       ,@i_Address_2                 VARCHAR(55)
       ,@i_Zip_Code                  VARCHAR(50)
       ,@i_City                      VARCHAR(50)
       ,@i_State                     VARCHAR(50)
       ,@i_County                    VARCHAR(50)
       ,@i_Country                   VARCHAR(50)
       ,@i_Phone_Number              VARCHAR(50)
       ,@i_Extension                 VARCHAR(50)
       ,@i_Phone_Type                VARCHAR(50)
       ,@i_accepts_sms_messages      VARCHAR(50)
       ,@i_MAddress_1                VARCHAR(55)
       ,@i_MAddress_2                VARCHAR(55)
       ,@i_MZip_Code                 VARCHAR(50)
       ,@i_MCity                     VARCHAR(50)
       ,@i_MState                    VARCHAR(50)
       ,@i_MCounty                   VARCHAR(50)
       ,@i_MCountry                  VARCHAR(50)
       ,@i_Fax_Number                VARCHAR(50)
       ,@i_FExtension                VARCHAR(50)
       ,@i_FPhone_Type               VARCHAR(50)
       ,@i_Faccepts_sms_messages     VARCHAR(50)
       ,@i_Other_Phone_Number        VARCHAR(50)
       ,@i_OExtension                VARCHAR(50)
       ,@i_OPhone_Type               VARCHAR(50)
       ,@i_Oaccepts_sms_messages     VARCHAR(50)
       ,@i_Other_Phone_Number2       VARCHAR(50)
       ,@i_OExtension2               VARCHAR(50)
       ,@i_OPhone_Type2              VARCHAR(50)
       ,@i_Oaccepts_sms_messages2    VARCHAR(50)
       ,@i_Email_Address             VARCHAR(50)
       ,@i_privacy_correspondence    VARCHAR(50)
       ,@i_inv_mailing_address       VARCHAR(50)
       ,@i_InvoicePrintRulesOverride VARCHAR(50)
       ,@i_Employer_Name             VARCHAR(50)
       ,@i_Employer_Phone            VARCHAR(50)
       ,@i_Effective_Date            VARCHAR(50)
       ,@i_Termination_date          VARCHAR(50)
       ,@i_Product_Effective_Date    VARCHAR(50)
       ,@i_Default_LOB               VARCHAR(50)
       ,@i_Plan_Strat_ID             VARCHAR(50)
       ,@i_Plan_Strat_Desc           VARCHAR(150)
       ,@i_COB_Type                  VARCHAR(50)
       ,@i_Bill_Flag                 VARCHAR(50)
       ,@i_Coverage_Code             VARCHAR(50)
       ,@i_Cobra_Flag                VARCHAR(50)
       ,@i_Cobra_AR_Type             VARCHAR(50)
       ,@i_Manual_Enrollment         VARCHAR(50)
       ,@i_Term_Reason               VARCHAR(50)
       ,@i_Term_Reason_Desc          VARCHAR(100)
       ,@i_Network_ID                VARCHAR(50)
       ,@i_Network_Desc              VARCHAR(150)
       ,@i_rx_network_strategy_id    VARCHAR(50)
       ,@i_rx_network_strategy_desc  VARCHAR(100)
       ,@i_Class_ID                  VARCHAR(50)
       ,@i_Salary_Mult               VARCHAR(50)
       ,@i_Req_Vol_Amt               VARCHAR(50)
       ,@i_Apv_Vol_Amt               VARCHAR(50)
       ,@i_Orig_Apv_Vol_Amt          VARCHAR(50)
       ,@i_Vol_Approval              VARCHAR(50)
       ,@i_Monthly_Benefit           VARCHAR(50)
       ,@i_Is_Subscriber_Covered     VARCHAR(50)
       ,@i_Loop2000GroupID           VARCHAR(50)
       ,@i_REFZZMemberID             VARCHAR(50)
       ,@i_REF23MemberID             VARCHAR(50)
       ,@i_REF6OMemberID             VARCHAR(50)
       ,@i_P_Eff_Date                VARCHAR(50)
       ,@i_P_Term_Date               VARCHAR(50)
       ,@i_P_Prov_ID                 VARCHAR(60)
       ,@i_P_Prov_Name               VARCHAR(150)
       ,@i_P_Prov_Location           VARCHAR(50)
       ,@i_S_Eff_Date                VARCHAR(50)
       ,@i_S_Term_Date               VARCHAR(50)
       ,@i_S_Prov_ID                 VARCHAR(60)
       ,@i_S_Prov_Name               VARCHAR(150)
       ,@i_S_Prov_Location           VARCHAR(50)
       ,@i_Verif_Type                VARCHAR(50)
       ,@i_Edu_Institution           VARCHAR(50)
       ,@i_Verif_Eff_Date            VARCHAR(50)
       ,@i_Verif_Term_Date           VARCHAR(50)
       ,@i_Enrollment_Year           VARCHAR(50)
       ,@i_Num_Months_Enroll         VARCHAR(50)
       ,@i_Acct_Type                 VARCHAR(50)
       ,@i_Acct_Name                 VARCHAR(100)
       ,@i_ABA_Number                VARCHAR(50)
       ,@i_Institution_Name          VARCHAR(50)
       ,@i_Acct_Number               VARCHAR(50)
       ,@i_CC_Auth_Number            VARCHAR(50)
       ,@i_CC_Month                  VARCHAR(50)
       ,@i_CC_Year                   VARCHAR(50)
       ,@i_ACH_Draft_Day             VARCHAR(50)
       ,@i_Acct_Dist                 VARCHAR(50)
       ,@i_hold_Effective_Date       VARCHAR(50)
       ,@i_hold_Termination_Date     VARCHAR(50)
       ,@i_Hold_Code                 VARCHAR(50)
       ,@i_hold_apply_to_fam         VARCHAR(50)
       ,@i_code_list_id              VARCHAR(50)
       ,@i_code_list_desc            VARCHAR(100)
       ,@i_MedBEffDate               VARCHAR(50)
       ,@i_MedAEffDate               VARCHAR(50)
       ,@i_MedicareNumber            VARCHAR(50)
       ,@i_PrevGrpNumber             VARCHAR(50)
       ,@i_PrevSection               VARCHAR(50)
       ,@i_PrevMemberID              VARCHAR(50)
       ,@i_TranGrpNumber             VARCHAR(50)
       ,@i_TranSection               VARCHAR(50)
       ,@i_TranMemberID              VARCHAR(50)
       ,@i_CheckDigit                VARCHAR(50)
       ,@i_AltMemberIDEffDate        VARCHAR(50)
       ,@i_PCP_ID                    VARCHAR(50)
       ,@i_PCP_name                  VARCHAR(50)
       ,@i_PCP_prev_seen             VARCHAR(50)
       ,@i_DCP_ID                    VARCHAR(50)
       ,@i_DCP_prev_seen             VARCHAR(50)
       ,@i_presumptive_eligibility   VARCHAR(50)
       ,@RedeterminationDate         VARCHAR(50)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(300)
       ,@o_Member_gid                INT
       ,@autogen                     VARCHAR(50)
       ,@return_xml                  XML
       ,@i_rate_adj_amt              VARCHAR(50)
       ,@i_App_Type                  VARCHAR(50)
       ,@FromPortalMemberAdd         VARCHAR(50)
       ,@FromDALMemberAdd            VARCHAR(50)
       ,@isAbhPortal                 BIT
       ,@i_debug                     VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberDependentsData') IS NOT NULL
	DROP TABLE #MemberDependentsData

CREATE TABLE #MemberDependentsData
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Member')
      ,i_child_gid                 VARCHAR(50)       DEFAULT('0')
      ,i_child_id                  VARCHAR(50)       DEFAULT('0')
      ,i_parent_gid                VARCHAR(50)       DEFAULT('0')
      ,i_parent_id                 VARCHAR(50)       DEFAULT('0')
      ,i_iEff_Date                 VARCHAR(50)       DEFAULT('0')
      ,i_iTerm_Date                VARCHAR(50)       DEFAULT('0')
      ,i_Group_gid                 VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified        CHAR(200)         DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,i_Group_id                  VARCHAR(50)
      ,i_Group_Desc                VARCHAR(50)
      ,i_Member_id                 VARCHAR(50)
      ,i_Person_Code               VARCHAR(50)
      ,i_Prefix                    VARCHAR(50)
      ,i_First_Name                VARCHAR(50)
      ,i_Middle_Name               VARCHAR(50)
      ,i_Last_Name                 VARCHAR(60)
      ,i_department_code           VARCHAR(50)
      ,i_Salutation_Name           VARCHAR(50)
      ,i_Suffix                    VARCHAR(50)
      ,i_Gender                    VARCHAR(50)
      ,i_Height                    VARCHAR(50)
      ,i_Weight                    VARCHAR(50)
      ,i_Ethnic                    VARCHAR(50)
      ,i_Smoker                    VARCHAR(50)
      ,i_visually_impaired         VARCHAR(50)
      ,i_language1                 VARCHAR(50)
      ,i_language1_Desc            VARCHAR(100)
      ,iLanguageUse1               VARCHAR(50)
      ,i_language2                 VARCHAR(50)
      ,i_language2_Desc            VARCHAR(50)
      ,iLanguageUse2               VARCHAR(50)
      ,i_salary                    VARCHAR(50)
      ,i_Birth_Date                VARCHAR(50)
      ,i_Actual_SSN                VARCHAR(50)
      ,i_Prior_Member_id           VARCHAR(50)
      ,i_Hipaa_id                  VARCHAR(50)
      ,i_Other_Parent_id           VARCHAR(50)
      ,i_Hire_Date                 VARCHAR(50)
      ,i_Marital_Status            VARCHAR(50)
      ,i_Relationship_Code         VARCHAR(50)
      ,i_Employee_Status           VARCHAR(50)
      ,i_Employment_Status         VARCHAR(50)
      ,i_HIPAA_Ques                VARCHAR(50)
      ,i_HIPAA_Ans                 VARCHAR(50)
      ,i_Address_1                 VARCHAR(55)
      ,i_Address_2                 VARCHAR(55)
      ,i_Zip_Code                  VARCHAR(50)
      ,i_City                      VARCHAR(50)
      ,i_State                     VARCHAR(50)
      ,i_County                    VARCHAR(50)
      ,i_Country                   VARCHAR(50)
      ,i_Phone_Number              VARCHAR(50)
      ,i_Extension                 VARCHAR(50)
      ,i_Phone_Type                VARCHAR(50)
      ,i_accepts_sms_messages      VARCHAR(50)
      ,i_MAddress_1                VARCHAR(55)
      ,i_MAddress_2                VARCHAR(55)
      ,i_MZip_Code                 VARCHAR(50)
      ,i_MCity                     VARCHAR(50)
      ,i_MState                    VARCHAR(50)
      ,i_MCounty                   VARCHAR(50)
      ,i_MCountry                  VARCHAR(50)
      ,i_Fax_Number                VARCHAR(50)
      ,i_FExtension                VARCHAR(50)
      ,i_FPhone_Type               VARCHAR(50)
      ,i_Faccepts_sms_messages     VARCHAR(50)
      ,i_Other_Phone_Number        VARCHAR(50)
      ,i_OExtension                VARCHAR(50)
      ,i_OPhone_Type               VARCHAR(50)
      ,i_Oaccepts_sms_messages     VARCHAR(50)
      ,i_Other_Phone_Number2       VARCHAR(50)
      ,i_OExtension2               VARCHAR(50)
      ,i_OPhone_Type2              VARCHAR(50)
      ,i_Oaccepts_sms_messages2    VARCHAR(50)
      ,i_Email_Address             VARCHAR(50)
      ,i_privacy_correspondence    VARCHAR(50)
      ,i_inv_mailing_address       VARCHAR(50)
      ,i_InvoicePrintRulesOverride VARCHAR(50)
      ,i_Employer_Name             VARCHAR(50)
      ,i_Employer_Phone            VARCHAR(50)
      ,i_Effective_Date            VARCHAR(50)
      ,i_Termination_date          VARCHAR(50)
      ,i_Product_Effective_Date    VARCHAR(50)
      ,i_Default_LOB               VARCHAR(50)
      ,i_Plan_Strat_ID             VARCHAR(50)
      ,i_Plan_Strat_Desc           VARCHAR(150)
      ,i_COB_Type                  VARCHAR(50)
      ,i_Bill_Flag                 VARCHAR(50)
      ,i_Coverage_Code             VARCHAR(50)
      ,i_Cobra_Flag                VARCHAR(50)
      ,i_Cobra_AR_Type             VARCHAR(50)
      ,i_Manual_Enrollment         VARCHAR(50)
      ,i_Term_Reason               VARCHAR(50)
      ,i_Term_Reason_Desc          VARCHAR(100)
      ,i_Network_ID                VARCHAR(50)
      ,i_Network_Desc              VARCHAR(150)
      ,i_rx_network_strategy_id    VARCHAR(50)
      ,i_rx_network_strategy_desc  VARCHAR(100)
      ,i_Class_ID                  VARCHAR(50)
      ,i_Salary_Mult               VARCHAR(50)
      ,i_Req_Vol_Amt               VARCHAR(50)
      ,i_Apv_Vol_Amt               VARCHAR(50)
      ,i_Orig_Apv_Vol_Amt          VARCHAR(50)
      ,i_Vol_Approval              VARCHAR(50)
      ,i_Monthly_Benefit           VARCHAR(50)
      ,i_Is_Subscriber_Covered     VARCHAR(50)
      ,i_Loop2000GroupID           VARCHAR(50)
      ,i_REFZZMemberID             VARCHAR(50)
      ,i_REF23MemberID             VARCHAR(50)
      ,i_REF6OMemberID             VARCHAR(50)
      ,i_P_Eff_Date                VARCHAR(50)
      ,i_P_Term_Date               VARCHAR(50)
      ,i_P_Prov_ID                 VARCHAR(60)
      ,i_P_Prov_Name               VARCHAR(150)
      ,i_P_Prov_Location           VARCHAR(50)
      ,i_S_Eff_Date                VARCHAR(50)
      ,i_S_Term_Date               VARCHAR(50)
      ,i_S_Prov_ID                 VARCHAR(60)
      ,i_S_Prov_Name               VARCHAR(150)
      ,i_S_Prov_Location           VARCHAR(50)
      ,i_Verif_Type                VARCHAR(50)
      ,i_Edu_Institution           VARCHAR(50)
      ,i_Verif_Eff_Date            VARCHAR(50)
      ,i_Verif_Term_Date           VARCHAR(50)
      ,i_Enrollment_Year           VARCHAR(50)
      ,i_Num_Months_Enroll         VARCHAR(50)
      ,i_Acct_Type                 VARCHAR(50)
      ,i_Acct_Name                 VARCHAR(100)
      ,i_ABA_Number                VARCHAR(50)
      ,i_Institution_Name          VARCHAR(50)
      ,i_Acct_Number               VARCHAR(50)
      ,i_CC_Auth_Number            VARCHAR(50)
      ,i_CC_Month                  VARCHAR(50)
      ,i_CC_Year                   VARCHAR(50)
      ,i_ACH_Draft_Day             VARCHAR(50)
      ,i_Acct_Dist                 VARCHAR(50)
      ,i_hold_Effective_Date       VARCHAR(50)
      ,i_hold_Termination_Date     VARCHAR(50)
      ,i_Hold_Code                 VARCHAR(50)
      ,i_hold_apply_to_fam         VARCHAR(50)
      ,i_code_list_id              VARCHAR(50)
      ,i_code_list_desc            VARCHAR(100)
      ,i_MedBEffDate               VARCHAR(50)
      ,i_MedAEffDate               VARCHAR(50)
      ,i_MedicareNumber            VARCHAR(50)
      ,i_PrevGrpNumber             VARCHAR(50)
      ,i_PrevSection               VARCHAR(50)
      ,i_PrevMemberID              VARCHAR(50)
      ,i_TranGrpNumber             VARCHAR(50)
      ,i_TranSection               VARCHAR(50)
      ,i_TranMemberID              VARCHAR(50)
      ,i_CheckDigit                VARCHAR(50)
      ,i_AltMemberIDEffDate        VARCHAR(50)
      ,i_PCP_ID                    VARCHAR(50)
      ,i_PCP_name                  VARCHAR(50)
      ,i_PCP_prev_seen             VARCHAR(50)
      ,i_DCP_ID                    VARCHAR(50)
      ,i_DCP_prev_seen             VARCHAR(50)
      ,i_presumptive_eligibility   VARCHAR(50)
      ,RedeterminationDate         VARCHAR(50)
      ,o_status                    INT
      ,o_message                   VARCHAR(300)
      ,o_Member_gid                INT
      ,autogen                     VARCHAR(50)
      ,return_xml                  XML
      ,i_rate_adj_amt              VARCHAR(50)
      ,i_App_Type                  VARCHAR(50)
      ,FromPortalMemberAdd         VARCHAR(50)
      ,FromDALMemberAdd            VARCHAR(50)
      ,isAbhPortal                 BIT
      ,i_debug                     VARCHAR(50)
      ,record_id                   INT
      ,static_gid                  INT)


IF OBJECT_ID('tempdb.dbo.#MemberDependentsScreen') IS NOT NULL
	DROP TABLE #MemberDependentsScreen

CREATE TABLE #MemberDependentsScreen
      (GroupID_1                               VARCHAR(200)
      ,GroupDesc_2                             VARCHAR(200)
      ,MemberID_3                              VARCHAR(200)
      ,PersonCode_4                            VARCHAR(200)
      ,Prefix_5                                VARCHAR(200)
      ,FirstName_6                             VARCHAR(200)
      ,MiddleName_7                            VARCHAR(200)
      ,LastName_8                              VARCHAR(200)
      ,Department_9                            VARCHAR(200)
      ,Nickname_10                             VARCHAR(200)
      ,Suffix_11                               VARCHAR(200)
      ,Gender_12                               VARCHAR(200)
      ,Height_13                               VARCHAR(200)
      ,Weight_14                               VARCHAR(200)
      ,Ethnicity_15                            VARCHAR(200)
      ,Smoker_16                               VARCHAR(200)
      ,VisuallyImpaired_17                     VARCHAR(200)
      ,Blank_18                                VARCHAR(200)
      ,Language1ID_19                          VARCHAR(200)
      ,Language1Desc_20                        VARCHAR(200)
      ,Language1Use_21                         VARCHAR(200)
      ,Blank_22                                VARCHAR(200)
      ,Language2ID_23                          VARCHAR(200)
      ,Language2Desc_24                        VARCHAR(200)
      ,Language2Use_25                         VARCHAR(200)
      ,Salary_26                               VARCHAR(200)
      ,DateofBirth_27                          VARCHAR(200)
      ,ActualSSN_28                            VARCHAR(200)
      ,PriorMemberID_29                        VARCHAR(200)
      ,HIPAAID_30                              VARCHAR(200)
      ,OtherParentID_31                        VARCHAR(200)
      ,DateofHire_32                           VARCHAR(200)
      ,MaritalStatus_33                        VARCHAR(200)
      ,RelationshipCode_34                     VARCHAR(200)
      ,EmployeeStatus_35                       VARCHAR(200)
      ,EmploymentStatus_36                     VARCHAR(200)
      ,HIPAAQuestion_37                        VARCHAR(200)
      ,HIPAAAnswer_38                          VARCHAR(200)
      ,Address_39                              VARCHAR(200)
      ,Blank_40                                VARCHAR(200)
      ,PrimaryPhysicalAddress_41               VARCHAR(200)
      ,Blank_42                                VARCHAR(200)
      ,AddressLine1_43                         VARCHAR(200)
      ,AddressLine2_44                         VARCHAR(200)
      ,ZipCode_45                              VARCHAR(200)
      ,City_46                                 VARCHAR(200)
      ,State_47                                VARCHAR(200)
      ,Blank_48                                VARCHAR(200)
      ,County_49                               VARCHAR(200)
      ,Country_50                              VARCHAR(200)
      ,PhoneNumber1_51                         VARCHAR(200)
      ,Extension_52                            VARCHAR(200)
      ,Type1_53                                VARCHAR(200)
      ,AcceptsSMSMessages1_54                  VARCHAR(200)
      ,MailingAddress_55                       VARCHAR(200)
      ,Blank_56                                VARCHAR(200)
      ,AddressLine1_57                         VARCHAR(200)
      ,AddressLine2_58                         VARCHAR(200)
      ,ZipCode_59                              VARCHAR(200)
      ,City_60                                 VARCHAR(200)
      ,State_61                                VARCHAR(200)
      ,Blank_62                                VARCHAR(200)
      ,County_63                               VARCHAR(200)
      ,Country_64                              VARCHAR(200)
      ,PhoneNumber2_65                         VARCHAR(200)
      ,Extension_66                            VARCHAR(200)
      ,Type2_67                                VARCHAR(200)
      ,AcceptsSMSMessages2_68                  VARCHAR(200)
      ,PhoneNumber3_69                         VARCHAR(200)
      ,Extension_70                            VARCHAR(200)
      ,Type3_71                                VARCHAR(200)
      ,AcceptsSMSMessages3_72                  VARCHAR(200)
      ,PhoneNumber4_73                         VARCHAR(200)
      ,Extension_74                            VARCHAR(200)
      ,Type4_75                                VARCHAR(200)
      ,AcceptsSMSMessages4_76                  VARCHAR(200)
      ,EMailAddress_77                         VARCHAR(200)
      ,PrvcyAddforCorr_78                      VARCHAR(200)
      ,MailInvoicesTo_79                       VARCHAR(200)
      ,OverrideGrpInvPrintRules_80             VARCHAR(200)
      ,EmployerName_81                         VARCHAR(200)
      ,EmployerPhoneNumber_82                  VARCHAR(200)
      ,Coverage_83                             VARCHAR(200)
      ,Blank_84                                VARCHAR(200)
      ,EffectiveDate_85                        VARCHAR(200)
      ,TerminationDate_86                      VARCHAR(200)
      ,ProductEffectiveDate_87                 VARCHAR(200)
      ,LOB_88                                  VARCHAR(200)
      ,PlanStrategyID_89                       VARCHAR(200)
      ,PlanStrategyDesc_90                     VARCHAR(200)
      ,COBType_91                              VARCHAR(200)
      ,BillFlag_92                             VARCHAR(200)
      ,CoverageCode_93                         VARCHAR(200)
      ,COBRAFlag_94                            VARCHAR(200)
      ,COBRAARType_95                          VARCHAR(200)
      ,ManualEnrollment_96                     VARCHAR(200)
      ,TermReasonCode_97                       VARCHAR(200)
      ,TermReasonDesc_98                       VARCHAR(200)
      ,SuperNetworkID_99                       VARCHAR(200)
      ,SuperNetworkDesc_100                    VARCHAR(200)
      ,PharmacyNetworkStrategyID_101           VARCHAR(200)
      ,PharmacyNetworkStrategyDescription_102  VARCHAR(200)
      ,EmployeeClassID_103                     VARCHAR(200)
      ,SalaryMultiplier_104                    VARCHAR(200)
      ,RequestedVolumeAmt_105                  VARCHAR(200)
      ,ApprovedVolumeAmt_106                   VARCHAR(200)
      ,OriginalApprovedVolumeAmt_107           VARCHAR(200)
      ,VolumeAppproval_108                     VARCHAR(200)
      ,MonthlyBenefit_109                      VARCHAR(200)
      ,IsSubscriberCovered_110                 VARCHAR(200)
      ,CarrierGroupID_111                      VARCHAR(200)
      ,REFZZCarrierMemberID_112                VARCHAR(200)
      ,REF23CarrierIndividualID_113            VARCHAR(200)
      ,PolicyIDEnrollmentID_114                VARCHAR(200)
      ,ProviderAssignment_115                  VARCHAR(200)
      ,Blank_116                               VARCHAR(200)
      ,PrimaryEffectiveDate_117                VARCHAR(200)
      ,PrimaryTerminationDate_118              VARCHAR(200)
      ,PrimaryProviderID_119                   VARCHAR(200)
      ,PrimaryProviderName_120                 VARCHAR(200)
      ,PrimaryServiceLocations_121             VARCHAR(200)
      ,Blank_122                               VARCHAR(200)
      ,SecondaryEffectiveDate_123              VARCHAR(200)
      ,SecondaryTerminationDate_124            VARCHAR(200)
      ,SecondaryProviderID_125                 VARCHAR(200)
      ,SecondaryProviderName_126               VARCHAR(200)
      ,SecondaryServiceLocations_127           VARCHAR(200)
      ,Blank_128                               VARCHAR(200)
      ,Verification_129                        VARCHAR(200)
      ,Blank_130                               VARCHAR(200)
      ,VerificationType_131                    VARCHAR(200)
      ,EduInstitution_132                      VARCHAR(200)
      ,EffectivePlacementDate_133              VARCHAR(200)
      ,TerminationDate_134                     VARCHAR(200)
      ,EnrollmentYear_135                      VARCHAR(200)
      ,NumofMonthsEnrolled_136                 VARCHAR(200)
      ,BankCreditCardInfo_137                  VARCHAR(200)
      ,Blank_138                               VARCHAR(200)
      ,AccountType_139                         VARCHAR(200)
      ,NameonAccount_140                       VARCHAR(200)
      ,ABANumber_141                           VARCHAR(200)
      ,FinancialInstitution_142                VARCHAR(200)
      ,AccountNumber_143                       VARCHAR(200)
      ,CardAuthorizationNumber_144             VARCHAR(200)
      ,CardExpirationMonth_145                 VARCHAR(200)
      ,CardExpirationYear_146                  VARCHAR(200)
      ,ACHDraftDay_147                         VARCHAR(200)
      ,AccountDistinction_148                  VARCHAR(200)
      ,Hold_149                                VARCHAR(200)
      ,Blank_150                               VARCHAR(200)
      ,EffectiveDate_151                       VARCHAR(200)
      ,TerminationDate_152                     VARCHAR(200)
      ,HoldCodes_153                           VARCHAR(200)
      ,ApplytoFamily_154                       VARCHAR(200)
      ,CodeListID_155                          VARCHAR(200)
      ,CodeListDesc_156                        VARCHAR(200)
      ,Misc_157                                VARCHAR(200)
      ,Blank_158                               VARCHAR(200)
      ,MedicarePartBEffDate_159                VARCHAR(200)
      ,MedicarePartAEffDate_160                VARCHAR(200)
      ,MedicareNumberMBI_161                   VARCHAR(200)
      ,PreviousGroupNumber_162                 VARCHAR(200)
      ,PreviousSection_163                     VARCHAR(200)
      ,PreviousMemberIDHICN_164                VARCHAR(200)
      ,TransferGroupNumber_165                 VARCHAR(200)
      ,TransferSection_166                     VARCHAR(200)
      ,TransferMemberID_167                    VARCHAR(200)
      ,CheckDigit_168                          VARCHAR(200)
      ,AlternativeMemberIDEffDate_169          VARCHAR(200)
      ,Blank_170                               VARCHAR(200)
      ,PCPID_171                               VARCHAR(200)
      ,PCPName_172                             VARCHAR(200)
      ,PCPPreviouslySeen_173                   VARCHAR(200)
      ,Blank_174                               VARCHAR(200)
      ,PCDID_175                               VARCHAR(200)
      ,PCDPreviouslySeen_176                   VARCHAR(200)
      ,PresumptiveEligibility_177              VARCHAR(200)
      ,RedeterminationDate_178                 VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#TokenData') IS NOT NULL
	DROP TABLE #TokenData

CREATE TABLE #TokenData
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberDependentsData
      (SearchID
      ,i_Group_id                  
      ,i_Member_id                 
      ,i_Prefix                    
      ,i_First_Name                
      ,i_Middle_Name               
      ,i_Last_Name                 
      ,i_department_code           
      ,i_Salutation_Name           
      ,i_Suffix                    
      ,i_Gender                    
      ,i_Height                    
      ,i_Weight                    
      ,i_Ethnic                    
      ,i_Smoker                    
      ,i_visually_impaired         
      ,i_language1                 
      ,iLanguageUse1               
      ,i_language2                 
      ,iLanguageUse2               
      ,i_salary                    
      ,i_Birth_Date                
      ,i_Actual_SSN                
      ,i_Prior_Member_id           
      ,i_Hipaa_id                  
      ,i_Other_Parent_id           
      ,i_Hire_Date                 
      ,i_Marital_Status            
      ,i_Relationship_Code         
      ,i_Employee_Status           
      ,i_Employment_Status         
      ,i_HIPAA_Ques                
      ,i_HIPAA_Ans                 
      ,i_Address_1                 
      ,i_Address_2                 
      ,i_Zip_Code                  
      ,i_City                      
      ,i_State                     
      ,i_County                    
      ,i_Country                   
      ,i_Phone_Number              
      ,i_Extension                 
      ,i_Phone_Type                
      ,i_accepts_sms_messages      
      ,i_MAddress_1                
      ,i_MAddress_2                
      ,i_MZip_Code                 
      ,i_MCity                     
      ,i_MState                    
      ,i_MCounty                   
      ,i_MCountry                  
      ,i_Fax_Number                
      ,i_FExtension                
      ,i_FPhone_Type               
      ,i_Faccepts_sms_messages     
      ,i_Other_Phone_Number        
      ,i_OExtension                
      ,i_OPhone_Type               
      ,i_Oaccepts_sms_messages     
      ,i_Other_Phone_Number2       
      ,i_OExtension2               
      ,i_OPhone_Type2              
      ,i_Oaccepts_sms_messages2    
      ,i_Email_Address             
      ,i_privacy_correspondence    
      ,i_inv_mailing_address       
      ,i_InvoicePrintRulesOverride 
      ,i_Employer_Name             
      ,i_Employer_Phone            
      ,i_Effective_Date            
      ,i_Termination_date          
      ,i_Product_Effective_Date    
      ,i_Default_LOB               
      ,i_Plan_Strat_ID             
      ,i_COB_Type                  
      ,i_Bill_Flag                 
      ,i_Coverage_Code             
      ,i_Cobra_Flag                
      ,i_Cobra_AR_Type             
      ,i_Manual_Enrollment         
      ,i_Term_Reason               
      ,i_Network_ID                
      ,i_rx_network_strategy_id    
      ,i_Class_ID                  
      ,i_Salary_Mult               
      ,i_Req_Vol_Amt               
      ,i_Apv_Vol_Amt               
      ,i_Orig_Apv_Vol_Amt          
      ,i_Vol_Approval              
      ,i_Monthly_Benefit           
      ,i_Is_Subscriber_Covered     
      ,i_P_Eff_Date                
      ,i_P_Term_Date               
      ,i_P_Prov_ID                 
      ,i_P_Prov_Location           
      ,i_S_Eff_Date                
      ,i_S_Term_Date               
      ,i_S_Prov_ID                 
      ,i_S_Prov_Location           
      ,i_Verif_Type                
      ,i_Edu_Institution           
      ,i_Verif_Eff_Date            
      ,i_Verif_Term_Date           
      ,i_Enrollment_Year           
      ,i_Num_Months_Enroll         
      ,i_Acct_Type                 
      ,i_Acct_Name                 
      ,i_ABA_Number                
      ,i_Acct_Number               
      ,i_CC_Auth_Number            
      ,i_CC_Month                  
      ,i_CC_Year                   
      ,i_ACH_Draft_Day             
      ,i_Acct_Dist                 
      ,i_hold_Effective_Date       
      ,i_hold_Termination_Date     
      ,i_Hold_Code                 
      ,i_hold_apply_to_fam         
      ,i_code_list_id              
      ,i_MedBEffDate               
      ,i_MedAEffDate               
      ,i_MedicareNumber            
      ,i_PrevGrpNumber             
      ,i_PrevSection               
      ,i_PrevMemberID              
      ,i_TranGrpNumber             
      ,i_TranSection               
      ,i_TranMemberID              
      ,i_CheckDigit                
      ,i_AltMemberIDEffDate        
      ,i_PCP_ID                    
      ,i_PCP_name                  
      ,i_PCP_prev_seen             
      ,i_DCP_ID                    
      ,i_DCP_prev_seen             
      ,i_presumptive_eligibility   
      ,RedeterminationDate         
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_GroupID], '')
      ,ISNULL([*Common_MemberID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Prefix]), '')
      ,ISNULL([Common_FirstName], '')
      ,ISNULL([Common_MiddleName], '')
      ,ISNULL([*Common_LastName], '')
      ,ISNULL([Common_Department], '')
      ,ISNULL([Common_Nickname], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Sufix]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Gender]), 'U')
      ,ISNULL([Common_Height], '')
      ,ISNULL([Common_Weight], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Ethnicity]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Smoker]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_VisuallyImpared]), 'N')
      ,ISNULL([Common_LanguageID1], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Language1Use]), '')
      ,ISNULL([Common_LanguageID2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_Language2Use]), '')
      ,ISNULL([Common_Salary], '0.00')
      ,ISNULL([Common_DateofBirth], '00/00/0000')
      ,ISNULL([Common_ActualSSN], '000000000')
      ,ISNULL([Common_PriorMemberID], '')
      ,ISNULL([Common_HIPAAID], '')
      ,ISNULL([Common_OtherParentID], '')
      ,ISNULL([Common_DateofHire], '00/00/0000')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MaritalStatus]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_RelationshipCode]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EmployeeStatus]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EmploymentStatus]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HIPAAQuestion]), 'QUES0')
      ,ISNULL([Common_HIPAAAnswer], '')
      ,ISNULL([*Addr_Address1], '')
      ,ISNULL([Addr_Address2], '')
      ,ISNULL([*Addr_ZipCode], '')
      ,ISNULL([*Addr_City], '')
      ,ISNULL([*Addr_State], '')
      ,ISNULL([Addr_County], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Addr_Country]), 'US')
      ,ISNULL([Addr_Phone1], '0000000000')
      ,ISNULL([Addr_Extension], '')
      ,ISNULL([Addr_PhoneType1], 'HOME')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_AcceptSMS1]), 'N')
      ,ISNULL([Addr_MailAdd1], '')
      ,ISNULL([Addr_MailAdd2], '')
      ,ISNULL([Addr_MailZip], '')
      ,ISNULL([Addr_MailCity], '')
      ,ISNULL([Addr_MailState], '')
      ,ISNULL([Addr_MailCounty], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_MailCountry]), 'US')
      ,ISNULL([Addr_Phone2], '0000000000')
      ,ISNULL([Addr_Extension2], '')
      ,ISNULL([Addr_PhoneType2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_AcceptSMS2]), 'N')
      ,ISNULL([Addr_Phone3], '0000000000')
      ,ISNULL([Addr_Extension3], '')
      ,ISNULL([Addr_PhoneType3], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_AcceptSMS3]), 'N')
      ,ISNULL([Addr_Phone4], '0000000000')
      ,ISNULL([Addr_Extension4], '')
      ,ISNULL([Addr_PhoneType4], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_AcceptSMS4]), 'N')
      ,ISNULL([Addr_Email], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_PrivacyAdd]), 'S')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_MailInvoicesTo]), 'S')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Addr_OverrPrintRules]), 'N')
      ,ISNULL([Addr_EmplyrName], '')
      ,ISNULL([Addr_EmplyrPhone], '0000000000')
      ,ISNULL([*Coverage_EffectiveDt], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Coverage_TerminationDt], '12/31/9999')
      ,ISNULL([Coverage_ProdEffDt], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_LOB]), '')
      ,ISNULL([Coverage_PlanStratID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_COBType]), 'E')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_BillFlg]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CoverageCd]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CobraFlg]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CobraARType]), 'G')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_ManualEnroll]), 'N')
      ,ISNULL([Coverage_TermReasonCd], '')
      ,ISNULL([Coverage_SuperNetwrkID], '')
      ,ISNULL([Coverage_RateAdjustAmt], '')
      ,ISNULL([Coverage_EmplyeClassID], '')
      ,ISNULL([Coverage_SalaryMult], '0.00')
      ,ISNULL([Coverage_ReqVolAmt], '0.00')
      ,ISNULL([Coverage_ApprVolAmt], '0.00')
      ,ISNULL([Coverage_OrigApprVolAmt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_VolAppr]), '')
      ,ISNULL([Coverage_MonBenefit], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_SubsCovrd]), 'Y')
      ,ISNULL([ProvAssign_PrimEffDate], CONVERT(VARCHAR(10), GETDATE(),101))
      ,ISNULL([ProvAssign_PrimTermDate], '12/31/9999')
      ,ISNULL([ProvAssign_PrimProvID], '')
      ,ISNULL([ProvAssign_PrimServLocs], '')
      ,ISNULL([ProvAssign_SecEffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([ProvAssign_SecTermDate], '12/31/9999')
      ,ISNULL([ProvAssign_SecProvID], '')
      ,ISNULL([ProvAssign_SecServLocs], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Verification_VerificationType]), '')
      ,ISNULL([Verification_EduInstitution], '')
      ,ISNULL([Verification_EffectivePlacementDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Verification_TermDate], '12/31/9999')
      ,ISNULL([Verification_EnrollmentYear], YEAR(GETDATE()))
      ,ISNULL([Verification_NumMonthsEnrolled], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BankCCInfo_AcctType]), '')
      ,ISNULL([BankCCInfo_NameOnAccount], '')
      ,ISNULL([BankCCInfo_ABANumber], '')
      ,ISNULL([BankCCInfo_AcctNumber], '')
      ,ISNULL([BankCCInfo_CardAuthNumber], '')
      ,ISNULL([BankCCInfo_CardExpMonth], '')
      ,ISNULL([BankCCInfo_CardExpYear], '')
      ,ISNULL([BankCCInfo_ACHDraftDay], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BankCCInfo_AcctDistinction]), '')
      ,ISNULL([Hold_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Hold_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Hold_HoldCodes]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Hold_ApplyToFam]), 'Y')
      ,ISNULL([Hold_CodeListID], '')
      ,ISNULL([Misc_MedicarePartBEffDate], '00/00/0000')
      ,ISNULL([Misc_MedicarePartAEffDate], '00/00/0000')
      ,ISNULL([Misc_MedicareNumberMBI], '')
      ,ISNULL([Misc_PrevGroupNumber], '')
      ,ISNULL([Misc_PrevSection], '')
      ,ISNULL([Misc_PrevMemberID], '')
      ,ISNULL([Misc_TransferGroupNumber], '')
      ,ISNULL([Misc_TransferSection], '')
      ,ISNULL([Misc_TransferMemberID], '')
      ,ISNULL([Misc_CheckDigit], '')
      ,ISNULL([Misc_AltMemberIDEffDate], '00/00/0000')
      ,ISNULL([Misc_PCPID], '')
      ,ISNULL([Misc_PCPName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PCPPreviouslySeen]), 'N')
      ,ISNULL([Misc_PCDID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PCDPreviouslySeen]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Misc_PresumptiveEligibility]), 'N')
      ,ISNULL([Misc_RedeterminationDate], '00/00/0000')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberDependents
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberDependentsData
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberDependents_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_child_gid
       ,i_child_id
       ,i_parent_gid
       ,i_parent_id
       ,i_iEff_Date
       ,i_iTerm_Date
       ,i_Group_gid
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_Group_id
       ,i_Group_Desc
       ,i_Member_id
       ,i_Person_Code
       ,i_Prefix
       ,i_First_Name
       ,i_Middle_Name
       ,i_Last_Name
       ,i_department_code
       ,i_Salutation_Name
       ,i_Suffix
       ,i_Gender
       ,i_Height
       ,i_Weight
       ,i_Ethnic
       ,i_Smoker
       ,i_visually_impaired
       ,i_language1
       ,i_language1_Desc
       ,iLanguageUse1
       ,i_language2
       ,i_language2_Desc
       ,iLanguageUse2
       ,i_salary
       ,i_Birth_Date
       ,i_Actual_SSN
       ,i_Prior_Member_id
       ,i_Hipaa_id
       ,i_Other_Parent_id
       ,i_Hire_Date
       ,i_Marital_Status
       ,i_Relationship_Code
       ,i_Employee_Status
       ,i_Employment_Status
       ,i_HIPAA_Ques
       ,i_HIPAA_Ans
       ,i_Address_1
       ,i_Address_2
       ,i_Zip_Code
       ,i_City
       ,i_State
       ,i_County
       ,i_Country
       ,i_Phone_Number
       ,i_Extension
       ,i_Phone_Type
       ,i_accepts_sms_messages
       ,i_MAddress_1
       ,i_MAddress_2
       ,i_MZip_Code
       ,i_MCity
       ,i_MState
       ,i_MCounty
       ,i_MCountry
       ,i_Fax_Number
       ,i_FExtension
       ,i_FPhone_Type
       ,i_Faccepts_sms_messages
       ,i_Other_Phone_Number
       ,i_OExtension
       ,i_OPhone_Type
       ,i_Oaccepts_sms_messages
       ,i_Other_Phone_Number2
       ,i_OExtension2
       ,i_OPhone_Type2
       ,i_Oaccepts_sms_messages2
       ,i_Email_Address
       ,i_privacy_correspondence
       ,i_inv_mailing_address
       ,i_InvoicePrintRulesOverride
       ,i_Employer_Name
       ,i_Employer_Phone
       ,i_Effective_Date
       ,i_Termination_date
       ,i_Product_Effective_Date
       ,i_Default_LOB
       ,i_Plan_Strat_ID
       ,i_Plan_Strat_Desc
       ,i_COB_Type
       ,i_Bill_Flag
       ,i_Coverage_Code
       ,i_Cobra_Flag
       ,i_Cobra_AR_Type
       ,i_Manual_Enrollment
       ,i_Term_Reason
       ,i_Term_Reason_Desc
       ,i_Network_ID
       ,i_Network_Desc
       ,i_rx_network_strategy_id
       ,i_rx_network_strategy_desc
       ,i_Class_ID
       ,i_Salary_Mult
       ,i_Req_Vol_Amt
       ,i_Apv_Vol_Amt
       ,i_Orig_Apv_Vol_Amt
       ,i_Vol_Approval
       ,i_Monthly_Benefit
       ,i_Is_Subscriber_Covered
       ,i_Loop2000GroupID
       ,i_REFZZMemberID
       ,i_REF23MemberID
       ,i_REF6OMemberID
       ,i_P_Eff_Date
       ,i_P_Term_Date
       ,i_P_Prov_ID
       ,i_P_Prov_Name
       ,i_P_Prov_Location
       ,i_S_Eff_Date
       ,i_S_Term_Date
       ,i_S_Prov_ID
       ,i_S_Prov_Name
       ,i_S_Prov_Location
       ,i_Verif_Type
       ,i_Edu_Institution
       ,i_Verif_Eff_Date
       ,i_Verif_Term_Date
       ,i_Enrollment_Year
       ,i_Num_Months_Enroll
       ,i_Acct_Type
       ,i_Acct_Name
       ,i_ABA_Number
       ,i_Institution_Name
       ,i_Acct_Number
       ,i_CC_Auth_Number
       ,i_CC_Month
       ,i_CC_Year
       ,i_ACH_Draft_Day
       ,i_Acct_Dist
       ,i_hold_Effective_Date
       ,i_hold_Termination_Date
       ,i_Hold_Code
       ,i_hold_apply_to_fam
       ,i_code_list_id
       ,i_code_list_desc
       ,i_MedBEffDate
       ,i_MedAEffDate
       ,i_MedicareNumber
       ,i_PrevGrpNumber
       ,i_PrevSection
       ,i_PrevMemberID
       ,i_TranGrpNumber
       ,i_TranSection
       ,i_TranMemberID
       ,i_CheckDigit
       ,i_AltMemberIDEffDate
       ,i_PCP_ID
       ,i_PCP_name
       ,i_PCP_prev_seen
       ,i_DCP_ID
       ,i_DCP_prev_seen
       ,i_presumptive_eligibility
       ,RedeterminationDate
       ,o_status
       ,o_message
       ,o_Member_gid
       ,autogen
       ,return_xml
       ,i_rate_adj_amt
       ,i_App_Type
       ,FromPortalMemberAdd
       ,FromDALMemberAdd
       ,isAbhPortal
       ,i_debug
       ,record_id
       ,static_gid
   FROM #MemberDependentsData

   OPEN MemberDependents_Cursor
  FETCH NEXT FROM MemberDependents_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_child_gid
       ,@i_child_id
       ,@i_parent_gid
       ,@i_parent_id
       ,@i_iEff_Date
       ,@i_iTerm_Date
       ,@i_Group_gid
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_Group_id
       ,@i_Group_Desc
       ,@i_Member_id
       ,@i_Person_Code
       ,@i_Prefix
       ,@i_First_Name
       ,@i_Middle_Name
       ,@i_Last_Name
       ,@i_department_code
       ,@i_Salutation_Name
       ,@i_Suffix
       ,@i_Gender
       ,@i_Height
       ,@i_Weight
       ,@i_Ethnic
       ,@i_Smoker
       ,@i_visually_impaired
       ,@i_language1
       ,@i_language1_Desc
       ,@iLanguageUse1
       ,@i_language2
       ,@i_language2_Desc
       ,@iLanguageUse2
       ,@i_salary
       ,@i_Birth_Date
       ,@i_Actual_SSN
       ,@i_Prior_Member_id
       ,@i_Hipaa_id
       ,@i_Other_Parent_id
       ,@i_Hire_Date
       ,@i_Marital_Status
       ,@i_Relationship_Code
       ,@i_Employee_Status
       ,@i_Employment_Status
       ,@i_HIPAA_Ques
       ,@i_HIPAA_Ans
       ,@i_Address_1
       ,@i_Address_2
       ,@i_Zip_Code
       ,@i_City
       ,@i_State
       ,@i_County
       ,@i_Country
       ,@i_Phone_Number
       ,@i_Extension
       ,@i_Phone_Type
       ,@i_accepts_sms_messages
       ,@i_MAddress_1
       ,@i_MAddress_2
       ,@i_MZip_Code
       ,@i_MCity
       ,@i_MState
       ,@i_MCounty
       ,@i_MCountry
       ,@i_Fax_Number
       ,@i_FExtension
       ,@i_FPhone_Type
       ,@i_Faccepts_sms_messages
       ,@i_Other_Phone_Number
       ,@i_OExtension
       ,@i_OPhone_Type
       ,@i_Oaccepts_sms_messages
       ,@i_Other_Phone_Number2
       ,@i_OExtension2
       ,@i_OPhone_Type2
       ,@i_Oaccepts_sms_messages2
       ,@i_Email_Address
       ,@i_privacy_correspondence
       ,@i_inv_mailing_address
       ,@i_InvoicePrintRulesOverride
       ,@i_Employer_Name
       ,@i_Employer_Phone
       ,@i_Effective_Date
       ,@i_Termination_date
       ,@i_Product_Effective_Date
       ,@i_Default_LOB
       ,@i_Plan_Strat_ID
       ,@i_Plan_Strat_Desc
       ,@i_COB_Type
       ,@i_Bill_Flag
       ,@i_Coverage_Code
       ,@i_Cobra_Flag
       ,@i_Cobra_AR_Type
       ,@i_Manual_Enrollment
       ,@i_Term_Reason
       ,@i_Term_Reason_Desc
       ,@i_Network_ID
       ,@i_Network_Desc
       ,@i_rx_network_strategy_id
       ,@i_rx_network_strategy_desc
       ,@i_Class_ID
       ,@i_Salary_Mult
       ,@i_Req_Vol_Amt
       ,@i_Apv_Vol_Amt
       ,@i_Orig_Apv_Vol_Amt
       ,@i_Vol_Approval
       ,@i_Monthly_Benefit
       ,@i_Is_Subscriber_Covered
       ,@i_Loop2000GroupID
       ,@i_REFZZMemberID
       ,@i_REF23MemberID
       ,@i_REF6OMemberID
       ,@i_P_Eff_Date
       ,@i_P_Term_Date
       ,@i_P_Prov_ID
       ,@i_P_Prov_Name
       ,@i_P_Prov_Location
       ,@i_S_Eff_Date
       ,@i_S_Term_Date
       ,@i_S_Prov_ID
       ,@i_S_Prov_Name
       ,@i_S_Prov_Location
       ,@i_Verif_Type
       ,@i_Edu_Institution
       ,@i_Verif_Eff_Date
       ,@i_Verif_Term_Date
       ,@i_Enrollment_Year
       ,@i_Num_Months_Enroll
       ,@i_Acct_Type
       ,@i_Acct_Name
       ,@i_ABA_Number
       ,@i_Institution_Name
       ,@i_Acct_Number
       ,@i_CC_Auth_Number
       ,@i_CC_Month
       ,@i_CC_Year
       ,@i_ACH_Draft_Day
       ,@i_Acct_Dist
       ,@i_hold_Effective_Date
       ,@i_hold_Termination_Date
       ,@i_Hold_Code
       ,@i_hold_apply_to_fam
       ,@i_code_list_id
       ,@i_code_list_desc
       ,@i_MedBEffDate
       ,@i_MedAEffDate
       ,@i_MedicareNumber
       ,@i_PrevGrpNumber
       ,@i_PrevSection
       ,@i_PrevMemberID
       ,@i_TranGrpNumber
       ,@i_TranSection
       ,@i_TranMemberID
       ,@i_CheckDigit
       ,@i_AltMemberIDEffDate
       ,@i_PCP_ID
       ,@i_PCP_name
       ,@i_PCP_prev_seen
       ,@i_DCP_ID
       ,@i_DCP_prev_seen
       ,@i_presumptive_eligibility
       ,@RedeterminationDate
       ,@o_status
       ,@o_message
       ,@o_Member_gid
       ,@autogen
       ,@return_xml
       ,@i_rate_adj_amt
       ,@i_App_Type
       ,@FromPortalMemberAdd
       ,@FromDALMemberAdd
       ,@isAbhPortal
       ,@i_debug
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the member ID of the subscriber
			TRUNCATE TABLE #TokenData
			INSERT INTO #TokenData (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #TokenData WHERE token_order = 1

			-- Get the GIDs for the member
			SELECT @i_child_gid				= EC.child_gid
			      ,@i_child_id				= EC.child_identifier
				  ,@i_parent_gid			= EC.parent_gid
				  ,@i_parent_id				= EC.parent_identifier
				  ,@i_Group_gid				= EC.group_gid
				  ,@i_key_10_field			= EC.member_id
			  FROM Eligibility_Coverage		EC
			 WHERE EC.member_id				= @SearchID
			   AND EC.child_gid				= EC.parent_gid		-- Make sure to get the subscriber
			   AND EC.record_status			= 'A'

			--SELECT @i_child_gid, @i_parent_gid, @i_Group_gid, @i_key_10_field
		
			-- Get the existing subscriber data and the new person code
			TRUNCATE TABLE #MemberDependentsScreen
			  INSERT INTO #MemberDependentsScreen
			    EXEC prMemberPopulate 'Member',@i_child_gid,@i_child_id,@i_parent_gid,@i_parent_id,'0','0',@i_Group_gid,'0','0',@SearchID,'ADD', 0,'' ,0


			-- Now update any fields that may be pre-populated from the subscriber information
			SELECT @i_Group_id					= MDS.GroupID_1
				  ,@i_Group_Desc				= MDS.GroupDesc_2
				  ,@i_Member_id					= MDS.MemberID_3
				  ,@i_Person_Code				= MDS.PersonCode_4	-- Overwrite the person code
				  ,@i_Prefix					= CASE WHEN @i_Prefix = ''						THEN MDS.Prefix_5						ELSE @i_Prefix END
				  ,@i_First_Name				= CASE WHEN @i_First_Name = ''					THEN MDS.FirstName_6					ELSE @i_First_Name END
				  ,@i_Middle_Name				= CASE WHEN @i_Middle_Name = ''					THEN MDS.MiddleName_7					ELSE @i_Middle_Name END
				  ,@i_Last_Name					= CASE WHEN @i_Last_Name = ''					THEN MDS.LastName_8						ELSE @i_Last_Name END
				  ,@i_department_code			= CASE WHEN @i_department_code = ''				THEN MDS.Department_9					ELSE @i_department_code END
				  ,@i_Salutation_Name			= CASE WHEN @i_Salutation_Name = ''				THEN MDS.Nickname_10					ELSE @i_Salutation_Name END
				  ,@i_Suffix					= CASE WHEN @i_Suffix = ''						THEN MDS.Suffix_11						ELSE @i_Suffix END
				  ,@i_Gender					= CASE WHEN @i_Gender = ''						THEN MDS.Gender_12						ELSE @i_Gender END
				  ,@i_Height					= CASE WHEN @i_Height = ''						THEN MDS.Height_13						ELSE @i_Height END
				  ,@i_Weight					= CASE WHEN @i_Weight = ''						THEN MDS.Weight_14						ELSE @i_Weight END
				  ,@i_Ethnic					= CASE WHEN @i_Ethnic = ''						THEN MDS.Ethnicity_15					ELSE @i_Ethnic END
				  ,@i_Smoker					= CASE WHEN @i_Smoker = ''						THEN MDS.Smoker_16						ELSE @i_Smoker END
				  ,@i_visually_impaired			= CASE WHEN @i_visually_impaired = ''			THEN MDS.VisuallyImpaired_17			ELSE @i_visually_impaired END
				  ,@i_language1					= CASE WHEN @i_language1 = ''					THEN MDS.Language1ID_19					ELSE @i_language1 END
				  ,@i_language1_Desc			= CASE WHEN @i_language1_Desc = ''				THEN MDS.Language1Desc_20				ELSE @i_language1_Desc END
				  ,@iLanguageUse1				= CASE WHEN @iLanguageUse1 = ''					THEN MDS.Language1Use_21				ELSE @iLanguageUse1 END
				  ,@i_language2					= CASE WHEN @i_language2 = ''					THEN MDS.Language2ID_23					ELSE @i_language2 END
				  ,@i_language2_Desc			= CASE WHEN @i_language2_Desc = ''				THEN MDS.Language2Desc_24				ELSE @i_language2_Desc END
				  --,@iLanguageUse2				= CASE WHEN @iLanguageUse2 = ''					THEN MDS.Language2Use_25				ELSE @iLanguageUse2 END
				  ,@i_salary					= CASE WHEN @i_salary = ''						THEN MDS.Salary_26						ELSE @i_salary END
				  ,@i_Birth_Date				= CASE WHEN @i_Birth_Date = ''					THEN MDS.DateofBirth_27					ELSE @i_Birth_Date END
				  ,@i_Actual_SSN				= CASE WHEN @i_Actual_SSN = ''					THEN MDS.ActualSSN_28					ELSE @i_Actual_SSN END
				  ,@i_Prior_Member_id			= CASE WHEN @i_Prior_Member_id = ''				THEN MDS.PriorMemberID_29				ELSE @i_Prior_Member_id END
				  ,@i_Hipaa_id					= CASE WHEN @i_Hipaa_id = ''					THEN MDS.HIPAAID_30						ELSE @i_Hipaa_id END
				  ,@i_Other_Parent_id			= CASE WHEN @i_Other_Parent_id = ''				THEN MDS.OtherParentID_31				ELSE @i_Other_Parent_id END
				  ,@i_Hire_Date					= CASE WHEN @i_Hire_Date = ''					THEN MDS.DateofHire_32					ELSE @i_Hire_Date END
				  ,@i_Marital_Status			= CASE WHEN @i_Marital_Status = ''				THEN MDS.MaritalStatus_33				ELSE @i_Marital_Status END
				  ,@i_Relationship_Code			= CASE WHEN @i_Relationship_Code = ''			THEN MDS.RelationshipCode_34			ELSE @i_Relationship_Code END
				  ,@i_Employee_Status			= CASE WHEN @i_Employee_Status = ''				THEN MDS.EmployeeStatus_35				ELSE @i_Employee_Status END
				  ,@i_Employment_Status			= CASE WHEN @i_Employment_Status = ''			THEN MDS.EmploymentStatus_36			ELSE @i_Employment_Status END
				  ,@i_HIPAA_Ques				= CASE WHEN @i_HIPAA_Ques = ''					THEN MDS.HIPAAQuestion_37				ELSE @i_HIPAA_Ques END
				  ,@i_HIPAA_Ans					= CASE WHEN @i_HIPAA_Ans = ''					THEN MDS.HIPAAAnswer_38					ELSE @i_HIPAA_Ans END
				  ,@i_Address_1					= CASE WHEN @i_Address_1 = ''					THEN MDS.AddressLine1_43				ELSE @i_Address_1 END
				  ,@i_Address_2					= CASE WHEN @i_Address_2 = ''					THEN MDS.AddressLine2_44				ELSE @i_Address_2 END
				  ,@i_Zip_Code					= CASE WHEN @i_Zip_Code = ''					THEN MDS.ZipCode_45						ELSE @i_Zip_Code END
				  ,@i_City						= CASE WHEN @i_City = ''						THEN MDS.City_46						ELSE @i_City END
				  ,@i_State						= CASE WHEN @i_State = ''						THEN MDS.State_47						ELSE @i_State END
				  ,@i_County					= CASE WHEN @i_County = ''						THEN MDS.County_49						ELSE @i_County END
				  ,@i_Country					= CASE WHEN @i_Country = ''						THEN MDS.Country_50						ELSE @i_Country END
				  ,@i_Phone_Number				= CASE WHEN @i_Phone_Number = ''				THEN MDS.PhoneNumber1_51				ELSE @i_Phone_Number END
				  ,@i_Extension					= CASE WHEN @i_Extension = ''					THEN MDS.Extension_52					ELSE @i_Extension END
				  ,@i_Phone_Type				= CASE WHEN @i_Phone_Type = ''					THEN MDS.Type1_53						ELSE @i_Phone_Type END
				  ,@i_accepts_sms_messages		= CASE WHEN @i_accepts_sms_messages = ''		THEN MDS.AcceptsSMSMessages1_54			ELSE @i_accepts_sms_messages END
				  ,@i_MAddress_1				= CASE WHEN @i_MAddress_1 = ''					THEN MDS.AddressLine1_57				ELSE @i_MAddress_1 END
				  ,@i_MAddress_2				= CASE WHEN @i_MAddress_2 = ''					THEN MDS.AddressLine2_58				ELSE @i_MAddress_2 END
				  ,@i_MZip_Code					= CASE WHEN @i_MZip_Code = ''					THEN MDS.ZipCode_59						ELSE @i_MZip_Code END
				  ,@i_MCity						= CASE WHEN @i_MCity = ''						THEN MDS.City_60						ELSE @i_MCity END
				  ,@i_MState					= CASE WHEN @i_MState = ''						THEN MDS.State_61						ELSE @i_MState END
				  ,@i_MCounty					= CASE WHEN @i_MCounty = ''						THEN MDS.County_63						ELSE @i_MCounty END
				  ,@i_MCountry					= CASE WHEN @i_MCountry = ''					THEN MDS.Country_64						ELSE @i_MCountry END
				  ,@i_Fax_Number				= CASE WHEN @i_Fax_Number = ''					THEN MDS.PhoneNumber2_65				ELSE @i_Fax_Number END
				  ,@i_FExtension				= CASE WHEN @i_FExtension = ''					THEN MDS.Extension_66					ELSE @i_FExtension END
				  ,@i_FPhone_Type				= CASE WHEN @i_FPhone_Type = ''					THEN MDS.Type2_67						ELSE @i_FPhone_Type END
				  ,@i_Faccepts_sms_messages		= CASE WHEN @i_Faccepts_sms_messages = ''		THEN MDS.AcceptsSMSMessages2_68			ELSE @i_Faccepts_sms_messages END
				  ,@i_Other_Phone_Number		= CASE WHEN @i_Other_Phone_Number = ''			THEN MDS.PhoneNumber3_69				ELSE @i_Other_Phone_Number END
				  ,@i_OExtension				= CASE WHEN @i_OExtension = ''					THEN MDS.Extension_70					ELSE @i_OExtension END
				  ,@i_OPhone_Type				= CASE WHEN @i_OPhone_Type = ''					THEN MDS.Type3_71						ELSE @i_OPhone_Type END
				  ,@i_Oaccepts_sms_messages		= CASE WHEN @i_Oaccepts_sms_messages = ''		THEN MDS.AcceptsSMSMessages3_72			ELSE @i_Oaccepts_sms_messages END
				  ,@i_Other_Phone_Number2		= CASE WHEN @i_Other_Phone_Number2 = ''			THEN MDS.PhoneNumber4_73				ELSE @i_Other_Phone_Number2 END
				  ,@i_OExtension2				= CASE WHEN @i_OExtension2 = ''					THEN MDS.Extension_74					ELSE @i_OExtension2 END
				  ,@i_OPhone_Type2				= CASE WHEN @i_OPhone_Type2 = ''				THEN MDS.Type4_75						ELSE @i_OPhone_Type2 END
				  ,@i_Oaccepts_sms_messages2	= CASE WHEN @i_Oaccepts_sms_messages2 = ''		THEN MDS.AcceptsSMSMessages4_76			ELSE @i_Oaccepts_sms_messages2 END
				  ,@i_Email_Address				= CASE WHEN @i_Email_Address = ''				THEN MDS.EMailAddress_77				ELSE @i_Email_Address END
				  ,@i_privacy_correspondence	= CASE WHEN @i_privacy_correspondence = ''		THEN MDS.PrvcyAddforCorr_78				ELSE @i_privacy_correspondence END
				  ,@i_inv_mailing_address		= CASE WHEN @i_inv_mailing_address = ''			THEN MDS.MailInvoicesTo_79				ELSE @i_inv_mailing_address END
				  ,@i_InvoicePrintRulesOverride	= CASE WHEN @i_InvoicePrintRulesOverride = ''	THEN MDS.OverrideGrpInvPrintRules_80	ELSE @i_InvoicePrintRulesOverride END
				  ,@i_Employer_Name				= CASE WHEN @i_Employer_Name = ''				THEN MDS.EmployerName_81				ELSE @i_Employer_Name END
				  ,@i_Employer_Phone			= CASE WHEN @i_Employer_Phone = ''				THEN MDS.EmployerPhoneNumber_82			ELSE @i_Employer_Phone END
				  ,@i_Effective_Date			= CASE WHEN @i_Effective_Date = ''				THEN MDS.EffectiveDate_85				ELSE @i_Effective_Date END
				  ,@i_Termination_date			= CASE WHEN @i_Termination_date = ''			THEN MDS.TerminationDate_86				ELSE @i_Termination_date END
				  ,@i_Product_Effective_Date	= CASE WHEN @i_Product_Effective_Date = ''		THEN MDS.ProductEffectiveDate_87		ELSE @i_Product_Effective_Date END
				  ,@i_Default_LOB				= CASE WHEN @i_Default_LOB = ''					THEN MDS.LOB_88							ELSE @i_Default_LOB END
				  ,@i_Plan_Strat_ID				= CASE WHEN @i_Plan_Strat_ID = ''				THEN MDS.PlanStrategyID_89				ELSE @i_Plan_Strat_ID END
				  ,@i_Plan_Strat_Desc			= CASE WHEN @i_Plan_Strat_Desc = ''				THEN MDS.PlanStrategyDesc_90			ELSE @i_Plan_Strat_Desc END
				  ,@i_COB_Type					= CASE WHEN @i_COB_Type = ''					THEN MDS.COBType_91						ELSE @i_COB_Type END
				  ,@i_Bill_Flag					= CASE WHEN @i_Bill_Flag = ''					THEN MDS.BillFlag_92					ELSE @i_Bill_Flag END
				  ,@i_Coverage_Code				= CASE WHEN @i_Coverage_Code = ''				THEN MDS.CoverageCode_93				ELSE @i_Coverage_Code END
				  ,@i_Cobra_Flag				= CASE WHEN @i_Cobra_Flag = ''					THEN MDS.COBRAFlag_94					ELSE @i_Cobra_Flag END
				  ,@i_Cobra_AR_Type				= CASE WHEN @i_Cobra_AR_Type = ''				THEN MDS.COBRAARType_95					ELSE @i_Cobra_AR_Type END
				  ,@i_Manual_Enrollment			= CASE WHEN @i_Manual_Enrollment = ''			THEN MDS.ManualEnrollment_96			ELSE @i_Manual_Enrollment END
				  ,@i_Term_Reason				= CASE WHEN @i_Term_Reason = ''					THEN MDS.TermReasonCode_97				ELSE @i_Term_Reason END
				  ,@i_Term_Reason_Desc			= CASE WHEN @i_Term_Reason_Desc = ''			THEN MDS.TermReasonDesc_98				ELSE @i_Term_Reason_Desc END
				  ,@i_Network_ID				= CASE WHEN @i_Network_ID = ''					THEN MDS.SuperNetworkID_99				ELSE @i_Network_ID END
				  ,@i_Network_Desc				= CASE WHEN @i_Network_Desc = ''				THEN MDS.SuperNetworkDesc_100			ELSE @i_Network_Desc END
				  ,@i_rx_network_strategy_id	= CASE WHEN @i_rx_network_strategy_id = ''		THEN MDS.PharmacyNetworkStrategyID_101  ELSE @i_rx_network_strategy_id END
				  ,@i_rx_network_strategy_desc	= CASE WHEN @i_rx_network_strategy_desc = ''	THEN MDS.PharmacyNetworkStrategyDescription_102 ELSE @i_rx_network_strategy_desc END
				  ,@i_Class_ID					= CASE WHEN @i_Class_ID = ''					THEN MDS.EmployeeClassID_103			ELSE @i_Class_ID END
				  ,@i_Salary_Mult				= CASE WHEN @i_Salary_Mult = ''					THEN MDS.SalaryMultiplier_104			ELSE @i_Salary_Mult END
				  ,@i_Req_Vol_Amt				= CASE WHEN @i_Req_Vol_Amt = ''					THEN MDS.RequestedVolumeAmt_105			ELSE @i_Req_Vol_Amt END
				  ,@i_Apv_Vol_Amt				= CASE WHEN @i_Apv_Vol_Amt = ''					THEN MDS.ApprovedVolumeAmt_106			ELSE @i_Apv_Vol_Amt END
				  ,@i_Orig_Apv_Vol_Amt			= CASE WHEN @i_Orig_Apv_Vol_Amt = ''			THEN MDS.OriginalApprovedVolumeAmt_107	ELSE @i_Orig_Apv_Vol_Amt END
				  ,@i_Vol_Approval				= CASE WHEN @i_Vol_Approval = ''				THEN MDS.VolumeAppproval_108			ELSE @i_Vol_Approval END
				  ,@i_Monthly_Benefit			= CASE WHEN @i_Monthly_Benefit = ''				THEN MDS.MonthlyBenefit_109				ELSE @i_Monthly_Benefit END
				  ,@i_Is_Subscriber_Covered		= CASE WHEN @i_Is_Subscriber_Covered = ''		THEN MDS.IsSubscriberCovered_110		ELSE @i_Is_Subscriber_Covered END
				  ,@i_Loop2000GroupID			= CASE WHEN @i_Loop2000GroupID = ''				THEN MDS.CarrierGroupID_111				ELSE @i_Loop2000GroupID END
				  ,@i_REFZZMemberID				= CASE WHEN @i_REFZZMemberID = ''				THEN MDS.REFZZCarrierMemberID_112		ELSE @i_REFZZMemberID END
				  ,@i_REF23MemberID				= CASE WHEN @i_REF23MemberID = ''				THEN MDS.REF23CarrierIndividualID_113	ELSE @i_REF23MemberID END
				  ,@i_REF6OMemberID				= CASE WHEN @i_REF6OMemberID = ''				THEN MDS.PolicyIDEnrollmentID_114		ELSE @i_REF6OMemberID END
				  ,@i_P_Eff_Date				= CASE WHEN @i_P_Eff_Date = ''					THEN MDS.PrimaryEffectiveDate_117		ELSE @i_P_Eff_Date END
				  ,@i_P_Term_Date				= CASE WHEN @i_P_Term_Date = ''					THEN MDS.PrimaryTerminationDate_118		ELSE @i_P_Term_Date END
				  ,@i_P_Prov_ID					= CASE WHEN @i_P_Prov_ID = ''					THEN MDS.PrimaryProviderID_119			ELSE @i_P_Prov_ID END
				  ,@i_P_Prov_Name				= CASE WHEN ISNULL(@i_P_Prov_Name, '') = ''		THEN MDS.PrimaryProviderName_120		ELSE @i_P_Prov_Name END
				  ,@i_P_Prov_Location			= CASE WHEN @i_P_Prov_Location = ''				THEN MDS.PrimaryServiceLocations_121	ELSE @i_P_Prov_Location END
				  ,@i_S_Eff_Date				= CASE WHEN @i_S_Eff_Date = ''					THEN MDS.SecondaryEffectiveDate_123		ELSE @i_S_Eff_Date END
				  ,@i_S_Term_Date				= CASE WHEN @i_S_Term_Date = ''					THEN MDS.SecondaryTerminationDate_124	ELSE @i_S_Term_Date END
				  ,@i_S_Prov_ID					= CASE WHEN @i_S_Prov_ID = ''					THEN MDS.SecondaryProviderID_125		ELSE @i_S_Prov_ID END
				  ,@i_S_Prov_Name				= CASE WHEN @i_S_Prov_Name = ''					THEN MDS.SecondaryProviderName_126		ELSE @i_S_Prov_Name END
				  ,@i_S_Prov_Location			= CASE WHEN @i_S_Prov_Location = ''				THEN MDS.SecondaryServiceLocations_127	ELSE @i_S_Prov_Location END
				  ,@i_Verif_Type				= CASE WHEN @i_Verif_Type = ''					THEN MDS.VerificationType_131			ELSE @i_Verif_Type END
				  ,@i_Edu_Institution			= CASE WHEN @i_Edu_Institution = ''				THEN MDS.EduInstitution_132				ELSE @i_Edu_Institution END
				  ,@i_Verif_Eff_Date			= CASE WHEN @i_Verif_Eff_Date = ''				THEN MDS.EffectivePlacementDate_133		ELSE @i_Verif_Eff_Date END
				  ,@i_Verif_Term_Date			= CASE WHEN @i_Verif_Term_Date = ''				THEN MDS.TerminationDate_134			ELSE @i_Verif_Term_Date END
				  ,@i_Enrollment_Year			= CASE WHEN @i_Enrollment_Year = ''				THEN MDS.EnrollmentYear_135				ELSE @i_Enrollment_Year END
				  ,@i_Num_Months_Enroll			= CASE WHEN @i_Num_Months_Enroll = ''			THEN MDS.NumofMonthsEnrolled_136		ELSE @i_Num_Months_Enroll END
				  ,@i_Acct_Type					= CASE WHEN @i_Acct_Type = ''					THEN MDS.AccountType_139				ELSE @i_Acct_Type END
				  ,@i_Acct_Name					= CASE WHEN @i_Acct_Name = ''					THEN MDS.NameonAccount_140				ELSE @i_Acct_Name END
				  ,@i_ABA_Number				= CASE WHEN @i_ABA_Number = ''					THEN MDS.ABANumber_141					ELSE @i_ABA_Number END
				  ,@i_Institution_Name			= CASE WHEN @i_Institution_Name = ''			THEN MDS.FinancialInstitution_142		ELSE @i_Institution_Name END
				  ,@i_Acct_Number				= CASE WHEN @i_Acct_Number = ''					THEN MDS.AccountNumber_143				ELSE @i_Acct_Number END
				  ,@i_CC_Auth_Number			= CASE WHEN @i_CC_Auth_Number = ''				THEN MDS.CardAuthorizationNumber_144	ELSE @i_CC_Auth_Number END
				  ,@i_CC_Month					= CASE WHEN @i_CC_Month = ''					THEN MDS.CardExpirationMonth_145		ELSE @i_CC_Month END
				  ,@i_CC_Year					= CASE WHEN @i_CC_Year = ''						THEN MDS.CardExpirationYear_146			ELSE @i_CC_Year END
				  ,@i_ACH_Draft_Day				= CASE WHEN @i_ACH_Draft_Day = ''				THEN MDS.ACHDraftDay_147				ELSE @i_ACH_Draft_Day END
				  ,@i_Acct_Dist					= CASE WHEN @i_Acct_Dist = ''					THEN MDS.AccountDistinction_148			ELSE @i_Acct_Dist END
				  ,@i_hold_Effective_Date		= CASE WHEN @i_hold_Effective_Date = ''			THEN MDS.EffectiveDate_151				ELSE @i_hold_Effective_Date END
				  ,@i_hold_Termination_Date		= CASE WHEN @i_hold_Termination_Date = ''		THEN MDS.TerminationDate_152			ELSE @i_hold_Termination_Date END
				  ,@i_Hold_Code					= CASE WHEN @i_Hold_Code = ''					THEN MDS.HoldCodes_153					ELSE @i_Hold_Code END
				  ,@i_hold_apply_to_fam			= CASE WHEN @i_hold_apply_to_fam = ''			THEN MDS.ApplytoFamily_154				ELSE @i_hold_apply_to_fam END
				  ,@i_code_list_id				= CASE WHEN @i_code_list_id = ''				THEN MDS.CodeListID_155					ELSE @i_code_list_id END
				  ,@i_code_list_desc			= CASE WHEN @i_code_list_desc = ''				THEN MDS.CodeListDesc_156				ELSE @i_code_list_desc END
				  ,@i_MedBEffDate				= CASE WHEN @i_MedBEffDate = ''					THEN MDS.MedicarePartBEffDate_159		ELSE @i_MedBEffDate END
				  ,@i_MedAEffDate				= CASE WHEN @i_MedAEffDate = ''					THEN MDS.MedicarePartAEffDate_160		ELSE @i_MedAEffDate END
				  ,@i_MedicareNumber			= CASE WHEN @i_MedicareNumber = ''				THEN MDS.MedicareNumberMBI_161			ELSE @i_MedicareNumber END
				  ,@i_PrevGrpNumber				= CASE WHEN @i_PrevGrpNumber = ''				THEN MDS.PreviousGroupNumber_162		ELSE @i_PrevGrpNumber END
				  ,@i_PrevSection				= CASE WHEN @i_PrevSection = ''					THEN MDS.PreviousSection_163			ELSE @i_PrevSection END
				  ,@i_PrevMemberID				= CASE WHEN @i_PrevMemberID = ''				THEN MDS.PreviousMemberIDHICN_164		ELSE @i_PrevMemberID END
				  ,@i_TranGrpNumber				= CASE WHEN @i_TranGrpNumber = ''				THEN MDS.TransferGroupNumber_165		ELSE @i_TranGrpNumber END
				  ,@i_TranSection				= CASE WHEN @i_TranSection = ''					THEN MDS.TransferSection_166			ELSE @i_TranSection END
				  ,@i_TranMemberID				= CASE WHEN @i_TranMemberID = ''				THEN MDS.TransferMemberID_167			ELSE @i_TranMemberID END
				  ,@i_CheckDigit				= CASE WHEN @i_CheckDigit = ''					THEN MDS.CheckDigit_168					ELSE @i_CheckDigit END
				  ,@i_AltMemberIDEffDate		= CASE WHEN @i_AltMemberIDEffDate = ''			THEN MDS.AlternativeMemberIDEffDate_169 ELSE @i_AltMemberIDEffDate END
				  ,@i_PCP_ID					= CASE WHEN @i_PCP_ID = ''						THEN MDS.PCPID_171						ELSE @i_PCP_ID END
				  ,@i_PCP_name					= CASE WHEN @i_PCP_name = ''					THEN MDS.PCPName_172					ELSE @i_PCP_name END
				  ,@i_PCP_prev_seen				= CASE WHEN @i_PCP_prev_seen = ''				THEN MDS.PCPPreviouslySeen_173			ELSE @i_PCP_prev_seen END
				  ,@i_DCP_ID					= CASE WHEN @i_DCP_ID = ''						THEN MDS.PCDID_175						ELSE @i_DCP_ID END
				  ,@i_DCP_prev_seen				= CASE WHEN @i_DCP_prev_seen = ''				THEN MDS.PCDPreviouslySeen_176			ELSE @i_DCP_prev_seen END
				  ,@i_presumptive_eligibility	= CASE WHEN @i_presumptive_eligibility = ''		THEN MDS.PresumptiveEligibility_177		ELSE @i_presumptive_eligibility END
				  ,@RedeterminationDate			= CASE WHEN @RedeterminationDate = ''			THEN MDS.RedeterminationDate_178		ELSE @RedeterminationDate END
			  FROM #MemberDependentsScreen	MDS

			EXEC dbo.prMemberAdd
				 @i_entity_name
				,@i_child_gid
				,@i_child_id
				,@i_parent_gid
				,@i_parent_id
				,@i_iEff_Date
				,@i_iTerm_Date
				,@i_Group_gid
				,@i_key_8_field
				,@i_key_9_field
				,@i_key_10_field
				,@i_action
				,@i_Date_Time_Modified	
				,@iUserID
				,@i_Group_id
				,@i_Group_Desc
				,@i_Member_id
				,@i_Person_Code
				,@i_Prefix
				,@i_First_Name
				,@i_Middle_Name
				,@i_Last_Name
				,@i_department_code
				,@i_Salutation_Name
				,@i_Suffix
				,@i_Gender
				,@i_Height
				,@i_Weight
				,@i_Ethnic
				,@i_Smoker
				,@i_visually_impaired
				,@i_language1
				,@i_language1_Desc
				,@iLanguageUse1
				,@i_language2
				,@i_language2_Desc
				,@iLanguageUse2
				,@i_salary
				,@i_Birth_Date
				,@i_Actual_SSN
				,@i_Prior_Member_id
				,@i_Hipaa_id
				,@i_Other_Parent_id
				,@i_Hire_Date
				,@i_Marital_Status
				,@i_Relationship_Code
				,@i_Employee_Status
				,@i_Employment_Status
				,@i_HIPAA_Ques
				,@i_HIPAA_Ans
				,@i_Address_1
				,@i_Address_2
				,@i_Zip_Code
				,@i_City
				,@i_State
				,@i_County
				,@i_Country
				,@i_Phone_Number
				,@i_Extension
				,@i_Phone_Type
				,@i_accepts_sms_messages
				,@i_MAddress_1
				,@i_MAddress_2
				,@i_MZip_Code
				,@i_MCity
				,@i_MState
				,@i_MCounty
				,@i_MCountry
				,@i_Fax_Number
				,@i_FExtension
				,@i_FPhone_Type
				,@i_Faccepts_sms_messages
				,@i_Other_Phone_Number
				,@i_OExtension
				,@i_OPhone_Type
				,@i_Oaccepts_sms_messages
				,@i_Other_Phone_Number2
				,@i_OExtension2
				,@i_OPhone_Type2
				,@i_Oaccepts_sms_messages2
				,@i_Email_Address
				,@i_privacy_correspondence
				,@i_inv_mailing_address
				,@i_InvoicePrintRulesOverride
				,@i_Employer_Name
				,@i_Employer_Phone
				,@i_Effective_Date
				,@i_Termination_date
				,@i_Product_Effective_Date
				,@i_Default_LOB
				,@i_Plan_Strat_ID
				,@i_Plan_Strat_Desc
				,@i_COB_Type
				,@i_Bill_Flag
				,@i_Coverage_Code
				,@i_Cobra_Flag
				,@i_Cobra_AR_Type
				,@i_Manual_Enrollment
				,@i_Term_Reason
				,@i_Term_Reason_Desc
				,@i_Network_ID
				,@i_Network_Desc
				,@i_rx_network_strategy_id
				,@i_rx_network_strategy_desc
				,@i_Class_ID
				,@i_Salary_Mult
				,@i_Req_Vol_Amt
				,@i_Apv_Vol_Amt
				,@i_Orig_Apv_Vol_Amt
				,@i_Vol_Approval
				,@i_Monthly_Benefit
				,@i_Is_Subscriber_Covered
				,@i_Loop2000GroupID
				,@i_REFZZMemberID
				,@i_REF23MemberID
				,@i_REF6OMemberID
				,@i_P_Eff_Date
				,@i_P_Term_Date
				,@i_P_Prov_ID
				,@i_P_Prov_Name
				,@i_P_Prov_Location
				,@i_S_Eff_Date
				,@i_S_Term_Date
				,@i_S_Prov_ID
				,@i_S_Prov_Name
				,@i_S_Prov_Location
				,@i_Verif_Type
				,@i_Edu_Institution
				,@i_Verif_Eff_Date
				,@i_Verif_Term_Date
				,@i_Enrollment_Year
				,@i_Num_Months_Enroll
				,@i_Acct_Type
				,@i_Acct_Name
				,@i_ABA_Number
				,@i_Institution_Name
				,@i_Acct_Number
				,@i_CC_Auth_Number
				,@i_CC_Month
				,@i_CC_Year
				,@i_ACH_Draft_Day
				,@i_Acct_Dist
				,@i_hold_Effective_Date
				,@i_hold_Termination_Date
				,@i_Hold_Code
				,@i_hold_apply_to_fam
				,@i_code_list_id
				,@i_code_list_desc
				,@i_MedBEffDate
				,@i_MedAEffDate
				,@i_MedicareNumber
				,@i_PrevGrpNumber
				,@i_PrevSection
				,@i_PrevMemberID
				,@i_TranGrpNumber
				,@i_TranSection
				,@i_TranMemberID
				,@i_CheckDigit
				,@i_AltMemberIDEffDate
				,@i_PCP_ID
				,@i_PCP_name
				,@i_PCP_prev_seen
				,@i_DCP_ID
				,@i_DCP_prev_seen
				,@i_presumptive_eligibility
				,@RedeterminationDate
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

				-- Create unigue gids for the different Contact_Relations records
				SELECT @physical_gid			= @static_gid + 1000000
				      ,@mailing_gid				= @static_gid + 2000000
					  ,@default_gid				= @static_gid + 3000000

				-- Update to the static gid
				SELECT @child_gid				= EC.child_gid
				      ,@parent_gid				= EC.parent_gid
				  FROM dbo.Eligibility_Coverage	EC
				 WHERE EC.record_status			= 'A'
				   AND EC.parent_identifier		= 'M'
				   AND EC.child_identifier		= 'M'
				   AND EC.member_id				= @i_Member_id
				   AND EC.person_code			= @i_Person_Code

				UPDATE Eligibility_Coverage
				   SET child_gid				= @static_gid
				      --,parent_gid				= @static_gid
				 WHERE child_gid				= @child_gid
				   AND parent_gid				= @parent_gid

				UPDATE dbo.Contacts
				   SET contact_gid				= @static_gid
				 WHERE contact_gid				= @child_gid

				SELECT @current_mailing_gid		= CR.demographic_gid
				  FROM Contact_Relation			CR
				 WHERE CR.entity_identifier		= 'MEMBER'
				   AND CR.contact_purpose_flag	= 'MAIL'
				   AND CR.contact_gid			= @child_gid

				SELECT @current_physical_gid	= CR.demographic_gid
				  FROM Contact_Relation			CR
				 WHERE CR.entity_identifier		= 'MEMBER'
				   AND CR.contact_purpose_flag	= 'PHYS'
				   AND CR.contact_gid			= @child_gid

				SELECT @current_default_gid		= CR.demographic_gid
				  FROM Contact_Relation			CR
				 WHERE CR.entity_identifier		= 'CONTACT_DEFAULT'
				   AND CR.contact_gid			= @child_gid

				UPDATE dbo.Contact_Relation		
				   SET entity_gid				= @static_gid
				      ,contact_gid				= @static_gid
				      ,contact_relation_gid		= CASE WHEN entity_identifier = 'MEMBER' AND contact_purpose_flag = 'PHYS' THEN @physical_gid
					                                   WHEN entity_identifier = 'MEMBER' AND contact_purpose_flag = 'MAIL' THEN @mailing_gid
													   WHEN entity_identifier = 'CONTACT_DEFAULT' THEN @default_gid
													   ELSE @static_gid
													END			 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @child_gid

				UPDATE dbo.Census_Transaction
				   SET parent_entity_gid		= @static_gid
				      ,child_entity_gid			= @static_gid
				 WHERE parent_entity_gid		= @parent_gid
				   AND child_entity_gid			= @child_gid
				   AND parent_entity_type		= 'M'
				   AND child_entity_type		= 'M'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_First_Name, @i_Last_Name, @status, @err_num, @err_msg

        FETCH NEXT FROM MemberDependents_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_child_gid
             ,@i_child_id
             ,@i_parent_gid
             ,@i_parent_id
             ,@i_iEff_Date
             ,@i_iTerm_Date
             ,@i_Group_gid
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_Group_id
             ,@i_Group_Desc
             ,@i_Member_id
             ,@i_Person_Code
             ,@i_Prefix
             ,@i_First_Name
             ,@i_Middle_Name
             ,@i_Last_Name
             ,@i_department_code
             ,@i_Salutation_Name
             ,@i_Suffix
             ,@i_Gender
             ,@i_Height
             ,@i_Weight
             ,@i_Ethnic
             ,@i_Smoker
             ,@i_visually_impaired
             ,@i_language1
             ,@i_language1_Desc
             ,@iLanguageUse1
             ,@i_language2
             ,@i_language2_Desc
             ,@iLanguageUse2
             ,@i_salary
             ,@i_Birth_Date
             ,@i_Actual_SSN
             ,@i_Prior_Member_id
             ,@i_Hipaa_id
             ,@i_Other_Parent_id
             ,@i_Hire_Date
             ,@i_Marital_Status
             ,@i_Relationship_Code
             ,@i_Employee_Status
             ,@i_Employment_Status
             ,@i_HIPAA_Ques
             ,@i_HIPAA_Ans
             ,@i_Address_1
             ,@i_Address_2
             ,@i_Zip_Code
             ,@i_City
             ,@i_State
             ,@i_County
             ,@i_Country
             ,@i_Phone_Number
             ,@i_Extension
             ,@i_Phone_Type
             ,@i_accepts_sms_messages
             ,@i_MAddress_1
             ,@i_MAddress_2
             ,@i_MZip_Code
             ,@i_MCity
             ,@i_MState
             ,@i_MCounty
             ,@i_MCountry
             ,@i_Fax_Number
             ,@i_FExtension
             ,@i_FPhone_Type
             ,@i_Faccepts_sms_messages
             ,@i_Other_Phone_Number
             ,@i_OExtension
             ,@i_OPhone_Type
             ,@i_Oaccepts_sms_messages
             ,@i_Other_Phone_Number2
             ,@i_OExtension2
             ,@i_OPhone_Type2
             ,@i_Oaccepts_sms_messages2
             ,@i_Email_Address
             ,@i_privacy_correspondence
             ,@i_inv_mailing_address
             ,@i_InvoicePrintRulesOverride
             ,@i_Employer_Name
             ,@i_Employer_Phone
             ,@i_Effective_Date
             ,@i_Termination_date
             ,@i_Product_Effective_Date
             ,@i_Default_LOB
             ,@i_Plan_Strat_ID
             ,@i_Plan_Strat_Desc
             ,@i_COB_Type
             ,@i_Bill_Flag
             ,@i_Coverage_Code
             ,@i_Cobra_Flag
             ,@i_Cobra_AR_Type
             ,@i_Manual_Enrollment
             ,@i_Term_Reason
             ,@i_Term_Reason_Desc
             ,@i_Network_ID
             ,@i_Network_Desc
             ,@i_rx_network_strategy_id
             ,@i_rx_network_strategy_desc
             ,@i_Class_ID
             ,@i_Salary_Mult
             ,@i_Req_Vol_Amt
             ,@i_Apv_Vol_Amt
             ,@i_Orig_Apv_Vol_Amt
             ,@i_Vol_Approval
             ,@i_Monthly_Benefit
             ,@i_Is_Subscriber_Covered
             ,@i_Loop2000GroupID
             ,@i_REFZZMemberID
             ,@i_REF23MemberID
             ,@i_REF6OMemberID
             ,@i_P_Eff_Date
             ,@i_P_Term_Date
             ,@i_P_Prov_ID
             ,@i_P_Prov_Name
             ,@i_P_Prov_Location
             ,@i_S_Eff_Date
             ,@i_S_Term_Date
             ,@i_S_Prov_ID
             ,@i_S_Prov_Name
             ,@i_S_Prov_Location
             ,@i_Verif_Type
             ,@i_Edu_Institution
             ,@i_Verif_Eff_Date
             ,@i_Verif_Term_Date
             ,@i_Enrollment_Year
             ,@i_Num_Months_Enroll
             ,@i_Acct_Type
             ,@i_Acct_Name
             ,@i_ABA_Number
             ,@i_Institution_Name
             ,@i_Acct_Number
             ,@i_CC_Auth_Number
             ,@i_CC_Month
             ,@i_CC_Year
             ,@i_ACH_Draft_Day
             ,@i_Acct_Dist
             ,@i_hold_Effective_Date
             ,@i_hold_Termination_Date
             ,@i_Hold_Code
             ,@i_hold_apply_to_fam
             ,@i_code_list_id
             ,@i_code_list_desc
             ,@i_MedBEffDate
             ,@i_MedAEffDate
             ,@i_MedicareNumber
             ,@i_PrevGrpNumber
             ,@i_PrevSection
             ,@i_PrevMemberID
             ,@i_TranGrpNumber
             ,@i_TranSection
             ,@i_TranMemberID
             ,@i_CheckDigit
             ,@i_AltMemberIDEffDate
             ,@i_PCP_ID
             ,@i_PCP_name
             ,@i_PCP_prev_seen
             ,@i_DCP_ID
             ,@i_DCP_prev_seen
             ,@i_presumptive_eligibility
             ,@RedeterminationDate
             ,@o_status
             ,@o_message
             ,@o_Member_gid
             ,@autogen
             ,@return_xml
             ,@i_rate_adj_amt
             ,@i_App_Type
             ,@FromPortalMemberAdd
             ,@FromDALMemberAdd
             ,@isAbhPortal
             ,@i_debug
             ,@record_id
             ,@static_gid
	END

CLOSE MemberDependents_Cursor
DEALLOCATE MemberDependents_Cursor

END
GO