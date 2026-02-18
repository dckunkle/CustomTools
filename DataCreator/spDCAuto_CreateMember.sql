IF OBJECT_ID('dbo.spDCAuto_CreateMember') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMember AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMember
Purpose:    Create member data from CorderAutomation
Method:     Member
Screen GID: 12
Procedure:  dbo.prMemberAdd

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
10/20/2020	DK				Lookup plan description when adding a member
12/20/2021	DK				Add GetDateValue to RedeterminationDate
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMember '300-TestCase-201%', 22, 'Member', '','Junk'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMember
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
	   ,@parent_gid					INT
	   ,@child_gid					INT
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
IF OBJECT_ID('tempdb.dbo.#MemberToAdd') IS NOT NULL
	DROP TABLE #MemberToAdd

CREATE TABLE #MemberToAdd
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)     DEFAULT('Member')
      ,i_child_gid                 VARCHAR(50)     DEFAULT('0')
      ,i_child_id                  VARCHAR(50)     DEFAULT('0')
      ,i_parent_gid                VARCHAR(50)     DEFAULT('0')
      ,i_parent_id                 VARCHAR(50)     DEFAULT('0')
      ,i_iEff_Date                 VARCHAR(50)     DEFAULT('0')
      ,i_iTerm_Date                VARCHAR(50)     DEFAULT('0')
      ,i_Group_gid                 VARCHAR(50)     DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)     DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)     DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)     DEFAULT('0')
      ,i_action                    VARCHAR(10)     DEFAULT('ADD')
      ,i_Date_Time_Modified        CHAR(200)       DEFAULT('')
      ,iUserID                     VARCHAR(25)     DEFAULT('')
      ,i_Group_id                  VARCHAR(50)
      ,i_Group_Desc                VARCHAR(50)
      ,i_Member_id                 VARCHAR(50)
      ,i_Person_Code               VARCHAR(50)	   DEFAULT('001')
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

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (address1			VARCHAR(200) 
      ,address2			VARCHAR(200)
      ,zip				VARCHAR(100)   
      ,city				VARCHAR(100)  
      ,state			VARCHAR(100)   
      ,blank			VARCHAR(100)  
      ,county			VARCHAR(100)
      ,country			VARCHAR(100)
	  ,status			INT
	  ,message			VARCHAR(4000))


IF OBJECT_ID('tempdb.dbo.#City') IS NOT NULL
	DROP TABLE #City

CREATE TABLE #City
      (FieldNumber		VARCHAR(200)  
      ,Reference_Type 	VARCHAR(200)
      ,Short_Desc		VARCHAR(200)
      ,Description   	VARCHAR(200)
      ,Seq_Num			VARCHAR(200))  

IF OBJECT_ID('tempdb.dbo.#ServiceLocations') IS NOT NULL
	DROP TABLE #ServiceLocations

CREATE TABLE #ServiceLocations
      (FieldNumber		VARCHAR(200)  
      ,Reference_Type 	VARCHAR(200)
      ,Short_Desc		VARCHAR(200)
      ,Description   	VARCHAR(200)
      ,Seq_Num			VARCHAR(200)) 

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberToAdd
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
      ,i_Loop2000GroupID
      ,i_REFZZMemberID
      ,i_REF23MemberID
      ,i_REF6OMemberID  
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
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CoverageCd]), 'EMP')
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
	  ,ISNULL(Coverage_CarrGroupID, '')
	  ,ISNULL(Coverage_REFZZCarrMbrID, '')
	  ,ISNULL(Coverage_REF23CarrIndID, '')
	  ,ISNULL(Coverage_PolEnrollID, '')
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
      ,ISNULL(dbo.fnDCAuto_GetDateValue([Misc_RedeterminationDate]), '00/00/0000')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Member
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberToAdd
   SET iUserID  = @user

-- Update the phone types
UPDATE MTA
   SET i_Phone_Type				= SAV1.Short_Desc
      ,i_FPhone_Type			= SAV2.Short_Desc
	  ,i_OPhone_Type			= SAV3.Short_Desc
	  ,i_OPhone_Type2			= SAV4.Short_Desc
  FROM #MemberToAdd				MTA
  JOIN System_Action_Values		SAV1
    ON MTA.i_Phone_Type			= SAV1.Description
  JOIN System_Action_Values		SAV2
    ON MTA.i_FPhone_Type		= SAV2.Description
  JOIN System_Action_Values		SAV3
    ON MTA.i_OPhone_Type		= SAV3.Description
  JOIN System_Action_Values		SAV4
    ON MTA.i_OPhone_Type2		= SAV4.Description
 WHERE SAV1.record_status		= 'A'
   AND SAV1.Reference_Type		= '*PHNTP'
   AND SAV2.record_status		= 'A'
   AND SAV2.Reference_Type		= '*PHNTP'
   AND SAV3.record_status		= 'A'
   AND SAV3.Reference_Type		= '*PHNTP'
   AND SAV4.record_status		= 'A'
   AND SAV4.Reference_Type		= '*PHNTP'

-- Update the Plan Description
UPDATE MTA
   SET i_Plan_Strat_Desc		= PSN.plan_strategy_desc
  FROM #MemberToAdd				MTA
  JOIN Plan_Strategy_Names		PSN
    ON MTA.i_Plan_Strat_ID		= PSN.plan_strategy_id
 WHERE PSN.record_status		= 'A'

UPDATE MTA
   SET i_Network_Desc					= PNSN.network_search_name
  FROM #MemberToAdd						MTA
  JOIN Provider_Network_Search_Names	PNSN 
    ON MTA.i_Network_ID					= PNSN.network_search_id
 WHERE PNSN.record_status				= 'A'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Member_Cursor CURSOR FOR
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
   FROM #MemberToAdd

   OPEN Member_Cursor
  FETCH NEXT FROM Member_Cursor
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
			
			-- Update the Address 
			TRUNCATE TABLE #Addresses
			INSERT INTO #Addresses
			  EXEC prMemberPopulateTabOff 'Address', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', @i_Address_1, @i_Address_2, @i_Zip_Code, '', '', '', 'US', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'ADD', 0, 0, ''

			--Get the preferred city name
			TRUNCATE TABLE #City
			INSERT INTO #City
			  EXEC prCityVaryCombo 'CITY', '6', @i_Zip_Code

			SELECT TOP 1
				   @i_address_1			= A.address1
				  ,@i_address_2			= A.address2
			 	  ,@i_zip_Code			= A.zip
				  ,@i_State				= CASE WHEN ISNULL(@i_state, '') = '' THEN A.state ELSE @i_state END
				  ,@i_county			= CASE WHEN ISNULL(@i_county, '') = '' THEN A.county ELSE @i_county END
				  ,@i_Country			= CASE WHEN ISNULL(@i_Country, '') = '' THEN A.country ELSE @i_Country END
			FROM #Addresses				A

			SELECT TOP 1
				  @i_city				= CASE WHEN ISNULL(@i_city, '') = '' THEN C.Short_Desc ELSE @i_city END 
			  FROM #City				C

			-- Update the Mailing Address 
			TRUNCATE TABLE #Addresses
			INSERT INTO #Addresses
			  EXEC prMemberPopulateTabOff 'Address2', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', @i_MAddress_1, @i_MAddress_2, @i_MZip_Code, '', '', '', 'US', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'ADD', 0, 0, ''

			--Get the preferred city name
			TRUNCATE TABLE #City
			INSERT INTO #City
			  EXEC prCityVaryCombo 'CITY', '6', @i_MZip_Code

			SELECT TOP 1
				   @i_MAddress_1		= A.address1
				  ,@i_MAddress_2		= A.address2
			 	  ,@i_MZip_Code			= A.zip
				  ,@i_MState			= CASE WHEN ISNULL(@i_MState, '') = '' THEN A.state ELSE @i_MState END
				  ,@i_MCounty			= CASE WHEN ISNULL(@i_MCounty, '') = '' THEN A.county ELSE @i_MCounty END
				  ,@i_MCountry			= CASE WHEN ISNULL(@i_MCountry, '') = '' THEN A.country ELSE @i_MCountry END
			FROM #Addresses				A

			SELECT TOP 1
				  @i_MCity				= CASE WHEN ISNULL(@i_MCity, '') = '' THEN C.Short_Desc ELSE @i_MCity END 
			  FROM #City				C

			--If assigning a PCP, get the service location information
			IF ISNULL(@i_P_Prov_ID, '') <> '' 
				BEGIN

					TRUNCATE TABLE #ServiceLocations
					  INSERT INTO #ServiceLocations
						EXEC prBuildMemberLocationCombo 'SvcLocation1','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,@i_P_Prov_ID ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,0 ,'' ,'N' ,'' 

					SELECT TOP 1
					       @i_P_Prov_Location	= Short_Desc
					  FROM #ServiceLocations

					SELECT @i_P_Prov_Location
				END

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
            --,@o_Member_gid
            --,@autogen
            --,@return_xml
            --,@i_rate_adj_amt
            --,@i_App_Type
            --,@FromPortalMemberAdd
            --,@FromDALMemberAdd
            --,@isAbhPortal
            --,@i_debug

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
				   AND EC.child_gid				= EC.parent_gid		-- Make sure to get subscriber only

				UPDATE Eligibility_Coverage
				   SET child_gid				= @static_gid
				      ,parent_gid				= @static_gid
				 WHERE child_gid				= @child_gid
				   AND parent_gid				= @parent_gid

				UPDATE dbo.Contacts
				   SET contact_gid				= @static_gid
				 WHERE contact_gid				= @child_gid

				UPDATE dbo.Entity_Paid_Thru	
				   SET parent_gid				= @static_gid
					  ,child_gid				= @static_gid
				 WHERE parent_gid				= @parent_gid
				   AND child_gid				= @child_gid
				   AND record_status			= 'A'

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
					  ,demographic_gid			=  CASE WHEN (entity_identifier = 'MEMBER' AND contact_purpose_flag = 'PHYS') 
					                                      OR (entity_identifier = 'CONTACT_DEFAULT') THEN @physical_gid
					                                    WHEN entity_identifier = 'MEMBER' AND contact_purpose_flag = 'MAIL' THEN @mailing_gid
													    ELSE @static_gid
												    END				 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @child_gid

				UPDATE dbo.Demographics
				   SET demographic_gid			= @physical_gid
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @current_physical_gid

				UPDATE dbo.Demographics
				   SET demographic_gid			= @mailing_gid
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @current_mailing_gid

				UPDATE dbo.Demographics
				   SET demographic_gid			= @default_gid
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @current_default_gid

				UPDATE dbo.Census_Transaction
				   SET parent_entity_gid		= @static_gid
				      ,child_entity_gid			= @static_gid
				 WHERE parent_entity_gid		= @parent_gid
				   AND child_entity_gid			= @child_gid
				   AND parent_entity_type		= 'M'
				   AND child_entity_type		= 'M'
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Member_id, @i_First_Name, @i_Last_Name, @status, @err_num, @err_msg

        FETCH NEXT FROM Member_Cursor
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

CLOSE Member_Cursor
DEALLOCATE Member_Cursor

END
GO