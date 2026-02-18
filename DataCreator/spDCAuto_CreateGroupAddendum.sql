IF OBJECT_ID('dbo.spDCAuto_CreateGroupAddendum') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupAddendum AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupAddendum
Purpose:    Create groupaddendum data from CorderAutomation
Method:     GroupAddendum
Screen GID: 6069
Procedure:  dbo.prContractAddendumAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupAddendum '100-Config%', 22, 'GroupAddendum'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupAddendum
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

DECLARE @i_entity_name                  VARCHAR(50)
       ,@i_key_addendum_gid             VARCHAR(50)
       ,@i_key_addendum_id              VARCHAR(50)
       ,@i_key_3_field                  VARCHAR(50)
       ,@i_key_4_field                  VARCHAR(50)
       ,@i_key_5_field                  VARCHAR(50)
       ,@i_key_6_field                  VARCHAR(50)
       ,@i_key_7_field                  VARCHAR(50)
       ,@i_key_8_field                  VARCHAR(50)
       ,@i_key_9_field                  VARCHAR(50)
       ,@i_key_10_field                 VARCHAR(50)
       ,@i_action                       VARCHAR(10)
       ,@i_date_time_modified           VARCHAR(50)
       ,@iUserID                        VARCHAR(25)
       ,@i_addendum_id                  VARCHAR(50)
       ,@i_addendum_desc                VARCHAR(100)
       ,@i_orig_addendum_id             VARCHAR(50)
       ,@i_orig_addendum_desc           VARCHAR(50)
       ,@i_approv_loa_Unit_period       VARCHAR(50)
       ,@i_BeneStored                   VARCHAR(50)
       ,@i_approv_loa_period            VARCHAR(50)
       ,@i_approv_loa_id                VARCHAR(50)
       ,@i_approv_loa_desc              VARCHAR(500)
       ,@i_definition_of_earnings_id    VARCHAR(50)
       ,@i_definition_of_earnings_desc  VARCHAR(500)
       ,@i_life_ben_type                VARCHAR(50)
       ,@i_salary_multiplier            VARCHAR(50)
       ,@i_min_coverage_amt             VARCHAR(50)
       ,@i_max_coverage_amt             VARCHAR(50)
       ,@i_guar_issue_amt               VARCHAR(50)
       ,@i_emp_round_prec_bl            VARCHAR(50)
       ,@i_emp_age_reduction            VARCHAR(50)
       ,@i_emp_age_red_desc             VARCHAR(100)
       ,@i_emp_base_add_bene            VARCHAR(50)
       ,@i_add_life_multiplier          VARCHAR(50)
       ,@i_emp_base_24hr                VARCHAR(50)
       ,@i_salary_bracket_id            VARCHAR(50)
       ,@i_salary_bracket_desc          VARCHAR(500)
       ,@i_Base_Carrier                 VARCHAR(50)
       ,@i_Base_Seat                    VARCHAR(50)
       ,@i_Base_AirBag                  VARCHAR(50)
       ,@i_Base_Repatriation            VARCHAR(50)
       ,@i_spouse_life_amt              VARCHAR(50)
       ,@i_each_child_life_amt          VARCHAR(50)
       ,@i_child_age_limit              VARCHAR(50)
       ,@i_child_student_age_limit      VARCHAR(50)
       ,@i_spouse_age_reduction         VARCHAR(50)
       ,@i_spouse_age_red_desc          VARCHAR(100)
       ,@i_child_age_reduction          VARCHAR(50)
       ,@i_child_age_red_desc           VARCHAR(100)
       ,@i_child_agevol_bracket_id      VARCHAR(50)
       ,@i_child_agevol_bracket_desc    VARCHAR(500)
       ,@i_spouse_guar_issue_amt        VARCHAR(50)
       ,@i_child_guar_issue_amt         VARCHAR(50)
       ,@i_spo_round_prec_bl            VARCHAR(50)
       ,@i_chi_round_prec_bl            VARCHAR(50)
       ,@i_accel_discount_amt           VARCHAR(50)
       ,@i_percent_death_bene           VARCHAR(50)
       ,@i_max_accel_bene_amt           VARCHAR(50)
       ,@i_waiver_premium               VARCHAR(50)
       ,@i_conversion_option            VARCHAR(50)
       ,@i_sv_type                      VARCHAR(50)
       ,@i_sv_min_coverage_amt          VARCHAR(50)
       ,@i_comb_max_cov_amt             VARCHAR(50)
       ,@i_sv_guar_issue_amt            VARCHAR(50)
       ,@i_comb_max_mult_salary         VARCHAR(50)
       ,@i_sv_emp_age_reduction         VARCHAR(50)
       ,@i_sv_emp_age_red_desc          VARCHAR(100)
       ,@i_sv_emp_round_prec            VARCHAR(50)
       ,@i_sv_emp_add_bene              VARCHAR(50)
       ,@i_sv_add_life_multiplier       VARCHAR(50)
       ,@i_sv_emp_base_24hr             VARCHAR(50)
       ,@i_sv_salary_bracket_id         VARCHAR(50)
       ,@i_sv_salary_bracket_desc       VARCHAR(500)
       ,@i_sv_Carrier                   VARCHAR(50)
       ,@i_sv_Seat                      VARCHAR(50)
       ,@i_sv_AirBag                    VARCHAR(50)
       ,@i_sv_Repatriation              VARCHAR(50)
       ,@i_sv_spouse_min_cov_amt        VARCHAR(50)
       ,@i_sv_spouse_bene_max           VARCHAR(50)
       ,@i_sv_spouse_guar_issue_amt     VARCHAR(50)
       ,@i_sv_spouse_max_bene_perc      VARCHAR(50)
       ,@i_sv_spouse_age_reduction      VARCHAR(50)
       ,@i_sv_spouse_age_red_desc       VARCHAR(100)
       ,@i_sv_spo_round_prec            VARCHAR(50)
       ,@i_sv_each_child_life_amt       VARCHAR(50)
       ,@i_sv_dep_max_bene_perc         VARCHAR(50)
       ,@i_sv_child_age_limit           VARCHAR(50)
       ,@i_sv_child_student_age_limit   VARCHAR(50)
       ,@i_sv_child_age_reduction       VARCHAR(50)
       ,@i_sv_child_age_red_desc        VARCHAR(100)
       ,@i_sv_child_agevol_bracket_id   VARCHAR(50)
       ,@i_sv_child_agevol_bracket_desc VARCHAR(500)
       ,@i_sv_chi_round_prec            VARCHAR(50)
       ,@i_sv_accel_discount_amt        VARCHAR(50)
       ,@i_sv_percent_death_bene        VARCHAR(50)
       ,@i_sv_max_accel_bene_amt        VARCHAR(50)
       ,@i_sv_waiver_premium            VARCHAR(50)
       ,@i_sv_conversion_option         VARCHAR(50)
       ,@i_portability                  VARCHAR(50)
       ,@i_ltd_type                     VARCHAR(50)
       ,@i_Benefit_Amt                  VARCHAR(50)
       ,@i_bene_prcnt_monthly_income    VARCHAR(50)
       ,@i_min_monthly_bene_amt         VARCHAR(50)
       ,@i_min_monthly_bene_per         VARCHAR(50)
       ,@i_max_monthly_bene_amt         VARCHAR(50)
       ,@i_max_monthly_bene_per         VARCHAR(50)
       ,@i_ltd_guar_issue_amt           VARCHAR(50)
       ,@i_elimination_period           VARCHAR(50)
       ,@i_preex_look_back              VARCHAR(50)
       ,@i_TreatmentFree                VARCHAR(50)
       ,@i_preex_covered                VARCHAR(50)
       ,@i_definition_of_disability     VARCHAR(50)
       ,@i_bene_duration_schedule       VARCHAR(50)
       ,@i_bene_duration_schedule_desc  VARCHAR(100)
       ,@i_emp_round_prec_ld            VARCHAR(50)
       ,@i_max_duration                 VARCHAR(50)
       ,@i_ltd_survivor                 VARCHAR(50)
       ,@i_Benefit_Multiple             VARCHAR(50)
       ,@i_Mental_Ill                   VARCHAR(50)
       ,@i_Mental_Option                VARCHAR(50)
       ,@i_Substance                    VARCHAR(50)
       ,@i_Substance_Option             VARCHAR(50)
       ,@i_Other_Abuse                  VARCHAR(50)
       ,@i_Other_Option                 VARCHAR(50)
       ,@i_Credit_Max                   VARCHAR(50)
       ,@i_Credit_Months                VARCHAR(50)
       ,@i_Credit_Therafter             VARCHAR(50)
       ,@i_Credit_Year_Max              VARCHAR(50)
       ,@i_Rehabilitation               VARCHAR(50)
       ,@i_Rehab_Benefit                VARCHAR(50)
       ,@i_Protect_Amt                  VARCHAR(50)
       ,@i_Protect_Percent              VARCHAR(50)
       ,@i_Pension_ID                   VARCHAR(50)
       ,@i_Pension_Desc                 VARCHAR(100)
       ,@i_integration                  VARCHAR(50)
       ,@i_ltd_maternity                VARCHAR(50)
       ,@i_Age_Limit                    VARCHAR(50)
       ,@i_COL_Allowance                VARCHAR(50)
       ,@i_COL_Freeze                   VARCHAR(50)
       ,@i_Work_Mod                     VARCHAR(50)
       ,@i_Earnings                     VARCHAR(50)
       ,@i_Diseases                     VARCHAR(50)
       ,@i_Sight_Loss                   VARCHAR(50)
       ,@i_Add_Benefit                  VARCHAR(50)
       ,@i_ltd_residual_disability      VARCHAR(50)
       ,@i_mental_illness               VARCHAR(50)
       ,@i_w2_responsibility            VARCHAR(50)
       ,@i_std_type                     VARCHAR(50)
       ,@i_min_weekly_bene_amt          VARCHAR(50)
       ,@i_max_weekly_bene_amt          VARCHAR(50)
       ,@i_bene_prcnt_weekly_income     VARCHAR(50)
       ,@i_max_weekly_amt_prcnt_salary  VARCHAR(50)
       ,@i_std_max_duration             VARCHAR(50)
       ,@i_std_guar_issue_amt           VARCHAR(50)
       ,@i_waiting_period_accident      VARCHAR(50)
       ,@i_waiting_period_sick          VARCHAR(50)
       ,@i_std_preex_look_back          VARCHAR(50)
       ,@i_std_preex_covered            VARCHAR(50)
       ,@i_std_survivor                 VARCHAR(50)
       ,@i_survivor_bene_multiple       VARCHAR(50)
       ,@i_std_24hr_coverage            VARCHAR(50)
       ,@i_first_day_hospital           VARCHAR(50)
       ,@i_partially_disability         VARCHAR(50)
       ,@i_std_maternity                VARCHAR(50)
       ,@i_st_w2_responsibility         VARCHAR(50)
       ,@i_maternity_benefits           VARCHAR(50)
       ,@i_maternity_benefit_id         VARCHAR(50)
       ,@i_maternity_benefit_desc       VARCHAR(500)
       ,@i_emp_round_prec_sd            VARCHAR(50)
       ,@i_buy_min_weekly_bene_amt      VARCHAR(50)
       ,@i_buy_max_weekly_bene_amt      VARCHAR(50)
       ,@i_buy_max_weekly_amt_prcnt_sal VARCHAR(50)
       ,@o_status                       INT
       ,@o_message                      VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupAddendum') IS NOT NULL
	DROP TABLE #GroupAddendum

CREATE TABLE #GroupAddendum
      (SearchID                       VARCHAR(200)
      ,i_entity_name                  VARCHAR(50)       DEFAULT('CONTRACT_ADDENDUM')
      ,i_key_addendum_gid             VARCHAR(50)       DEFAULT('0')
      ,i_key_addendum_id              VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                 VARCHAR(50)       DEFAULT('0')
      ,i_action                       VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified           VARCHAR(50)       DEFAULT('')
      ,iUserID                        VARCHAR(25)       DEFAULT('')
      ,i_addendum_id                  VARCHAR(50)
      ,i_addendum_desc                VARCHAR(100)
      ,i_orig_addendum_id             VARCHAR(50)
      ,i_orig_addendum_desc           VARCHAR(50)
      ,i_approv_loa_Unit_period       VARCHAR(50)
      ,i_BeneStored                   VARCHAR(50)
      ,i_approv_loa_period            VARCHAR(50)
      ,i_approv_loa_id                VARCHAR(50)
      ,i_approv_loa_desc              VARCHAR(500)
      ,i_definition_of_earnings_id    VARCHAR(50)
      ,i_definition_of_earnings_desc  VARCHAR(500)
      ,i_life_ben_type                VARCHAR(50)
      ,i_salary_multiplier            VARCHAR(50)
      ,i_min_coverage_amt             VARCHAR(50)
      ,i_max_coverage_amt             VARCHAR(50)
      ,i_guar_issue_amt               VARCHAR(50)
      ,i_emp_round_prec_bl            VARCHAR(50)
      ,i_emp_age_reduction            VARCHAR(50)
      ,i_emp_age_red_desc             VARCHAR(100)
      ,i_emp_base_add_bene            VARCHAR(50)
      ,i_add_life_multiplier          VARCHAR(50)
      ,i_emp_base_24hr                VARCHAR(50)
      ,i_salary_bracket_id            VARCHAR(50)
      ,i_salary_bracket_desc          VARCHAR(500)
      ,i_Base_Carrier                 VARCHAR(50)
      ,i_Base_Seat                    VARCHAR(50)
      ,i_Base_AirBag                  VARCHAR(50)
      ,i_Base_Repatriation            VARCHAR(50)
      ,i_spouse_life_amt              VARCHAR(50)
      ,i_each_child_life_amt          VARCHAR(50)
      ,i_child_age_limit              VARCHAR(50)
      ,i_child_student_age_limit      VARCHAR(50)
      ,i_spouse_age_reduction         VARCHAR(50)
      ,i_spouse_age_red_desc          VARCHAR(100)
      ,i_child_age_reduction          VARCHAR(50)
      ,i_child_age_red_desc           VARCHAR(100)
      ,i_child_agevol_bracket_id      VARCHAR(50)
      ,i_child_agevol_bracket_desc    VARCHAR(500)
      ,i_spouse_guar_issue_amt        VARCHAR(50)
      ,i_child_guar_issue_amt         VARCHAR(50)
      ,i_spo_round_prec_bl            VARCHAR(50)
      ,i_chi_round_prec_bl            VARCHAR(50)
      ,i_accel_discount_amt           VARCHAR(50)
      ,i_percent_death_bene           VARCHAR(50)
      ,i_max_accel_bene_amt           VARCHAR(50)
      ,i_waiver_premium               VARCHAR(50)
      ,i_conversion_option            VARCHAR(50)
      ,i_sv_type                      VARCHAR(50)
      ,i_sv_min_coverage_amt          VARCHAR(50)
      ,i_comb_max_cov_amt             VARCHAR(50)
      ,i_sv_guar_issue_amt            VARCHAR(50)
      ,i_comb_max_mult_salary         VARCHAR(50)
      ,i_sv_emp_age_reduction         VARCHAR(50)
      ,i_sv_emp_age_red_desc          VARCHAR(100)
      ,i_sv_emp_round_prec            VARCHAR(50)
      ,i_sv_emp_add_bene              VARCHAR(50)
      ,i_sv_add_life_multiplier       VARCHAR(50)
      ,i_sv_emp_base_24hr             VARCHAR(50)
      ,i_sv_salary_bracket_id         VARCHAR(50)
      ,i_sv_salary_bracket_desc       VARCHAR(500)
      ,i_sv_Carrier                   VARCHAR(50)
      ,i_sv_Seat                      VARCHAR(50)
      ,i_sv_AirBag                    VARCHAR(50)
      ,i_sv_Repatriation              VARCHAR(50)
      ,i_sv_spouse_min_cov_amt        VARCHAR(50)
      ,i_sv_spouse_bene_max           VARCHAR(50)
      ,i_sv_spouse_guar_issue_amt     VARCHAR(50)
      ,i_sv_spouse_max_bene_perc      VARCHAR(50)
      ,i_sv_spouse_age_reduction      VARCHAR(50)
      ,i_sv_spouse_age_red_desc       VARCHAR(100)
      ,i_sv_spo_round_prec            VARCHAR(50)
      ,i_sv_each_child_life_amt       VARCHAR(50)
      ,i_sv_dep_max_bene_perc         VARCHAR(50)
      ,i_sv_child_age_limit           VARCHAR(50)
      ,i_sv_child_student_age_limit   VARCHAR(50)
      ,i_sv_child_age_reduction       VARCHAR(50)
      ,i_sv_child_age_red_desc        VARCHAR(100)
      ,i_sv_child_agevol_bracket_id   VARCHAR(50)
      ,i_sv_child_agevol_bracket_desc VARCHAR(500)
      ,i_sv_chi_round_prec            VARCHAR(50)
      ,i_sv_accel_discount_amt        VARCHAR(50)
      ,i_sv_percent_death_bene        VARCHAR(50)
      ,i_sv_max_accel_bene_amt        VARCHAR(50)
      ,i_sv_waiver_premium            VARCHAR(50)
      ,i_sv_conversion_option         VARCHAR(50)
      ,i_portability                  VARCHAR(50)
      ,i_ltd_type                     VARCHAR(50)
      ,i_Benefit_Amt                  VARCHAR(50)
      ,i_bene_prcnt_monthly_income    VARCHAR(50)
      ,i_min_monthly_bene_amt         VARCHAR(50)
      ,i_min_monthly_bene_per         VARCHAR(50)
      ,i_max_monthly_bene_amt         VARCHAR(50)
      ,i_max_monthly_bene_per         VARCHAR(50)
      ,i_ltd_guar_issue_amt           VARCHAR(50)
      ,i_elimination_period           VARCHAR(50)
      ,i_preex_look_back              VARCHAR(50)
      ,i_TreatmentFree                VARCHAR(50)
      ,i_preex_covered                VARCHAR(50)
      ,i_definition_of_disability     VARCHAR(50)
      ,i_bene_duration_schedule       VARCHAR(50)
      ,i_bene_duration_schedule_desc  VARCHAR(100)
      ,i_emp_round_prec_ld            VARCHAR(50)
      ,i_max_duration                 VARCHAR(50)
      ,i_ltd_survivor                 VARCHAR(50)
      ,i_Benefit_Multiple             VARCHAR(50)
      ,i_Mental_Ill                   VARCHAR(50)
      ,i_Mental_Option                VARCHAR(50)
      ,i_Substance                    VARCHAR(50)
      ,i_Substance_Option             VARCHAR(50)
      ,i_Other_Abuse                  VARCHAR(50)
      ,i_Other_Option                 VARCHAR(50)
      ,i_Credit_Max                   VARCHAR(50)
      ,i_Credit_Months                VARCHAR(50)
      ,i_Credit_Therafter             VARCHAR(50)
      ,i_Credit_Year_Max              VARCHAR(50)
      ,i_Rehabilitation               VARCHAR(50)
      ,i_Rehab_Benefit                VARCHAR(50)
      ,i_Protect_Amt                  VARCHAR(50)
      ,i_Protect_Percent              VARCHAR(50)
      ,i_Pension_ID                   VARCHAR(50)
      ,i_Pension_Desc                 VARCHAR(100)
      ,i_integration                  VARCHAR(50)
      ,i_ltd_maternity                VARCHAR(50)
      ,i_Age_Limit                    VARCHAR(50)
      ,i_COL_Allowance                VARCHAR(50)
      ,i_COL_Freeze                   VARCHAR(50)
      ,i_Work_Mod                     VARCHAR(50)
      ,i_Earnings                     VARCHAR(50)
      ,i_Diseases                     VARCHAR(50)
      ,i_Sight_Loss                   VARCHAR(50)
      ,i_Add_Benefit                  VARCHAR(50)
      ,i_ltd_residual_disability      VARCHAR(50)
      ,i_mental_illness               VARCHAR(50)
      ,i_w2_responsibility            VARCHAR(50)
      ,i_std_type                     VARCHAR(50)
      ,i_min_weekly_bene_amt          VARCHAR(50)
      ,i_max_weekly_bene_amt          VARCHAR(50)
      ,i_bene_prcnt_weekly_income     VARCHAR(50)
      ,i_max_weekly_amt_prcnt_salary  VARCHAR(50)
      ,i_std_max_duration             VARCHAR(50)
      ,i_std_guar_issue_amt           VARCHAR(50)
      ,i_waiting_period_accident      VARCHAR(50)
      ,i_waiting_period_sick          VARCHAR(50)
      ,i_std_preex_look_back          VARCHAR(50)
      ,i_std_preex_covered            VARCHAR(50)
      ,i_std_survivor                 VARCHAR(50)
      ,i_survivor_bene_multiple       VARCHAR(50)
      ,i_std_24hr_coverage            VARCHAR(50)
      ,i_first_day_hospital           VARCHAR(50)
      ,i_partially_disability         VARCHAR(50)
      ,i_std_maternity                VARCHAR(50)
      ,i_st_w2_responsibility         VARCHAR(50)
      ,i_maternity_benefits           VARCHAR(50)
      ,i_maternity_benefit_id         VARCHAR(50)
      ,i_maternity_benefit_desc       VARCHAR(500)
      ,i_emp_round_prec_sd            VARCHAR(50)
      ,i_buy_min_weekly_bene_amt      VARCHAR(50)
      ,i_buy_max_weekly_bene_amt      VARCHAR(50)
      ,i_buy_max_weekly_amt_prcnt_sal VARCHAR(50)
      ,o_status                       INT
      ,o_message                      VARCHAR(200)
      ,record_id                      INT
      ,static_gid                     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupAddendum
      (SearchID
      ,i_addendum_id                  
      ,i_addendum_desc                
      ,i_orig_addendum_id             
      ,i_approv_loa_Unit_period       
      ,i_BeneStored                   
      ,i_approv_loa_period            
      ,i_approv_loa_id                
      ,i_definition_of_earnings_id    
      ,i_life_ben_type                
      ,i_salary_multiplier            
      ,i_min_coverage_amt             
      ,i_max_coverage_amt             
      ,i_guar_issue_amt               
      ,i_emp_round_prec_bl            
      ,i_emp_age_reduction            
      ,i_emp_base_add_bene            
      ,i_add_life_multiplier          
      ,i_emp_base_24hr                
      ,i_salary_bracket_id            
      ,i_Base_Carrier                 
      ,i_Base_Seat                    
      ,i_Base_AirBag                  
      ,i_Base_Repatriation            
      ,i_spouse_life_amt              
      ,i_each_child_life_amt          
      ,i_child_age_limit              
      ,i_child_student_age_limit      
      ,i_spouse_age_reduction         
      ,i_child_age_reduction          
      ,i_child_agevol_bracket_id      
      ,i_spouse_guar_issue_amt        
      ,i_child_guar_issue_amt         
      ,i_spo_round_prec_bl            
      ,i_chi_round_prec_bl            
      ,i_accel_discount_amt           
      ,i_percent_death_bene           
      ,i_max_accel_bene_amt           
      ,i_waiver_premium               
      ,i_conversion_option            
      ,i_sv_type                      
      ,i_sv_min_coverage_amt          
      ,i_comb_max_cov_amt             
      ,i_sv_guar_issue_amt            
      ,i_comb_max_mult_salary         
      ,i_sv_emp_age_reduction         
      ,i_sv_emp_round_prec            
      ,i_sv_emp_add_bene              
      ,i_sv_add_life_multiplier       
      ,i_sv_emp_base_24hr             
      ,i_sv_salary_bracket_id         
      ,i_sv_Carrier                   
      ,i_sv_Seat                      
      ,i_sv_AirBag                    
      ,i_sv_Repatriation              
      ,i_sv_spouse_min_cov_amt        
      ,i_sv_spouse_bene_max           
      ,i_sv_spouse_guar_issue_amt     
      ,i_sv_spouse_max_bene_perc      
      ,i_sv_spouse_age_reduction      
      ,i_sv_spo_round_prec            
      ,i_sv_each_child_life_amt       
      ,i_sv_dep_max_bene_perc         
      ,i_sv_child_age_limit           
      ,i_sv_child_student_age_limit   
      ,i_sv_child_age_reduction       
      ,i_sv_child_agevol_bracket_id   
      ,i_sv_chi_round_prec            
      ,i_sv_accel_discount_amt        
      ,i_sv_percent_death_bene        
      ,i_sv_max_accel_bene_amt        
      ,i_sv_waiver_premium            
      ,i_sv_conversion_option         
      ,i_portability                  
      ,i_ltd_type                     
      ,i_Benefit_Amt                  
      ,i_bene_prcnt_monthly_income    
      ,i_min_monthly_bene_amt         
      ,i_min_monthly_bene_per         
      ,i_max_monthly_bene_amt         
      ,i_max_monthly_bene_per         
      ,i_ltd_guar_issue_amt           
      ,i_elimination_period           
      ,i_preex_look_back              
      ,i_TreatmentFree                
      ,i_preex_covered                
      ,i_definition_of_disability     
      ,i_bene_duration_schedule       
      ,i_emp_round_prec_ld            
      ,i_max_duration                 
      ,i_ltd_survivor                 
      ,i_Benefit_Multiple             
      ,i_Mental_Ill                   
      ,i_Mental_Option                
      ,i_Substance                    
      ,i_Substance_Option             
      ,i_Other_Abuse                  
      ,i_Other_Option                 
      ,i_Credit_Max                   
      ,i_Credit_Months                
      ,i_Credit_Therafter             
      ,i_Credit_Year_Max              
      ,i_Rehabilitation               
      ,i_Rehab_Benefit                
      ,i_Protect_Amt                  
      ,i_Protect_Percent              
      ,i_Pension_ID                   
      ,i_integration                  
      ,i_ltd_maternity                
      ,i_Age_Limit                    
      ,i_COL_Allowance                
      ,i_COL_Freeze                   
      ,i_Work_Mod                     
      ,i_Earnings                     
      ,i_Diseases                     
      ,i_Sight_Loss                   
      ,i_Add_Benefit                  
      ,i_ltd_residual_disability      
      ,i_mental_illness               
      ,i_w2_responsibility            
      ,i_std_type                     
      ,i_min_weekly_bene_amt          
      ,i_max_weekly_bene_amt          
      ,i_bene_prcnt_weekly_income     
      ,i_max_weekly_amt_prcnt_salary  
      ,i_std_max_duration             
      ,i_std_guar_issue_amt           
      ,i_waiting_period_accident      
      ,i_waiting_period_sick          
      ,i_std_preex_look_back          
      ,i_std_preex_covered            
      ,i_std_survivor                 
      ,i_survivor_bene_multiple       
      ,i_std_24hr_coverage            
      ,i_first_day_hospital           
      ,i_partially_disability         
      ,i_std_maternity                
      ,i_st_w2_responsibility         
      ,i_maternity_benefits           
      ,i_maternity_benefit_id         
      ,i_emp_round_prec_sd            
      ,i_buy_min_weekly_bene_amt      
      ,i_buy_max_weekly_bene_amt      
      ,i_buy_max_weekly_amt_prcnt_sal 
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_AddendumID], '')
      ,ISNULL([*Common_Description], '')
      ,ISNULL([Common_CopyFromAddendumID], '')
      ,ISNULL([Common_ApprovedLeaveofAbsenceUnits], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BeneficiariesStored]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ApprovedLeaveofAbsencePeriod]), 'Days')
      ,ISNULL([Common_ApprovedLeaveofAbsenceID], '')
      ,ISNULL([Common_DefinitionofEarningsID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_LifeBenefitType]), 'F')
      ,ISNULL([BaseLifeADD_SalaryMultiplier], '0.00')
      ,ISNULL([BaseLifeADD_MinimumCoverageAmt], '0')
      ,ISNULL([BaseLifeADD_MaximumCoverageAmt], '0')
      ,ISNULL([BaseLifeADD_GuaranteedIssueAmt], '0')
      ,ISNULL([BaseLifeADD_EmployeeRoundingPrecision], 'A')
      ,ISNULL([BaseLifeADD_EmployeeAgeReduction], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_AD&DBenefit]), 'N')
      ,ISNULL([BaseLifeADD_AD&DLifeBenefitMultiplier], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_AD&DOccupationalCoverage]), 'Y')
      ,ISNULL([BaseLifeADD_SalaryBracketID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_CommonCarrier]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_SeatBeltCoverage]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_AirBagCoverage]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_RepatriationCoverage]), 'Y')
      ,ISNULL([BaseLifeADD_SpouseLifeAmt], '0')
      ,ISNULL([BaseLifeADD_EachChildLifeAmt], '0')
      ,ISNULL([BaseLifeADD_ChildAgeLimit], '0')
      ,ISNULL([BaseLifeADD_ChildStudentAgeLimit], '0')
      ,ISNULL([BaseLifeADD_SpouseAgeReduction], '')
      ,ISNULL([BaseLifeADD_ChildAgeReduction], '')
      ,ISNULL([BaseLifeADD_ChildAgeVolumeBracketID], '')
      ,ISNULL([BaseLifeADD_SpouseGuaranteedIssueAmt], '0')
      ,ISNULL([BaseLifeADD_ChildGuaranteedIssueAmt], '0')
      ,ISNULL([BaseLifeADD_SpouseRoundingPrecision], 'A')
      ,ISNULL([BaseLifeADD_ChildRoundingPrecision], 'A')
      ,ISNULL([BaseLifeADD_DiscountAmt], '0')
      ,ISNULL([BaseLifeADD_PeroftheDeathBenefit], '0.00')
      ,ISNULL([BaseLifeADD_MaxAcceleratedLivingBenefitAmt], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_WaiverofPremium]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BaseLifeADD_ConversionOption]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_Type]), 'S')
      ,ISNULL([SuppVolLife_MinimumCoverageAmt], '0')
      ,ISNULL([SuppVolLife_CombinedMaximumCoverageAmt], '0')
      ,ISNULL([SuppVolLife_GuaranteedIssueAmt], '0')
      ,ISNULL([SuppVolLife_CombinedMaximumMultipleofSalary], '0.00')
      ,ISNULL([SuppVolLife_EmployeeAgeReduction], '')
      ,ISNULL([SuppVolLife_EmployeeRoundingPrecision], 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_AD&DBenefit]), 'Y')
      ,ISNULL([SuppVolLife_AD&DLifeBenefitMultiplier], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_AD&DOccupationalCoverage]), 'Y')
      ,ISNULL([SuppVolLife_SalaryBracketID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_CommonCarrier]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_SeatBeltCoverage]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_AirBagCoverage]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_RepatriationCoverage]), 'Y')
      ,ISNULL([SuppVolLife_SpouseMinimumLifeAmt], '0')
      ,ISNULL([SuppVolLife_SpouseBenefitMaximum], '0')
      ,ISNULL([SuppVolLife_SpouseGuaranteedIssueAmt], '0')
      ,ISNULL([SuppVolLife_SpouseMaximumBenefitPerofEEBenefit], '0.00')
      ,ISNULL([SuppVolLife_SpouseAgeReduction], '')
      ,ISNULL([SuppVolLife_SpouseRoundingPrecision], 'A')
      ,ISNULL([SuppVolLife_EachChildLifeAmt], '0')
      ,ISNULL([SuppVolLife_ChildMaximumBenefitPerofEEBenefit], '0.00')
      ,ISNULL([SuppVolLife_ChildAgeLimit], '0')
      ,ISNULL([SuppVolLife_ChildStudentAgeLimit], '0')
      ,ISNULL([SuppVolLife_ChildAgeReduction], '')
      ,ISNULL([SuppVolLife_ChildAge_VolumeBracketID], '')
      ,ISNULL([SuppVolLife_ChildRoundingPrecision], 'A')
      ,ISNULL([SuppVolLife_DiscountAmt], '0')
      ,ISNULL([SuppVolLife_PeroftheDeathBenefit], '0.00')
      ,ISNULL([SuppVolLife_MaxAccelerated_LivingBenefitAmt], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_WaiverofPremium]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_ConversionOption]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuppVolLife_Portability]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_LTDType]), 'B')
      ,ISNULL([LongTermDis_BenefitAmtofMonthlyIncome], '0')
      ,ISNULL([LongTermDis_BenefitPerofMonthlyIncome], '0')
      ,ISNULL([LongTermDis_MinimumMonthlyBenefitAmt], '0')
      ,ISNULL([LongTermDis_MinimumMonthlyBenefitPer], '0')
      ,ISNULL([LongTermDis_MaximumMonthlyBenefitAmt], '0')
      ,ISNULL([LongTermDis_MaximumMonthlyBenefitPer], '0')
      ,ISNULL([LongTermDis_GuaranteedIssueAmt], '0')
      ,ISNULL([LongTermDis_EliminationPeriodDays], '0')
      ,ISNULL([LongTermDis_Pre-ExLookBackmonths], '0')
      ,ISNULL([LongTermDis_TreatmentFreemonths], '0')
      ,ISNULL([LongTermDis_Pre-ExCoveredmonths], '0')
      ,ISNULL([LongTermDis_DefinitionofDisability], '')
      ,ISNULL([LongTermDis_BenefitDurationSchedule], '')
      ,ISNULL([LongTermDis_EmployeeRoundingPrecision], 'A')
      ,ISNULL([LongTermDis_MaximumDuration], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_SurvivorBenefit]), 'Y')
      ,ISNULL([LongTermDis_SurvivorBenefitMultiple], '')
      ,ISNULL([LongTermDis_MentalIllness], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_PerOption1]), '')
      ,ISNULL([LongTermDis_SubstanceAbuse], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_PerOption2]), '')
      ,ISNULL([LongTermDis_MenIll_SubsAbuse], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_PerOption3]), '')
      ,ISNULL([LongTermDis_FamilyCareCreditMaxDed], '0')
      ,ISNULL([LongTermDis_FamilyCareCreditMaxDedMonths], '0')
      ,ISNULL([LongTermDis_FamilyCareCreditMaxDedThereafter], '0')
      ,ISNULL([LongTermDis_FamilyCareCreditCalendarYearMax], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_RehabilitationBonus]), 'N')
      ,ISNULL([LongTermDis_RehabilitationBenefitMultiple], '')
      ,ISNULL([LongTermDis_BusinessProtectionBenefitAmt], '0')
      ,ISNULL([LongTermDis_BusinessProtectionBenefitPer], '0')
      ,ISNULL([LongTermDis_PensionContributionID], '')
      ,ISNULL([LongTermDis_Integration], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_Maternity]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_PolicyAgeLimit]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_CostofLivingAllowanceCOLA]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_CostofLivingFreeze]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_WorkplaceModification]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_ExtendedEarnings]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_Infectious&ContagiousDiseases]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_AD&LossofSight]), 'N')
      ,ISNULL([LongTermDis_AdditionalBenefit], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_ResidualDisability]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_MentalIllnessSubstanceAbuse]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LongTermDis_W_2Responsibility]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_STDType]), 'B')
      ,ISNULL([ShortTermDis_MinimumWeeklyBenefitAmt], '0')
      ,ISNULL([ShortTermDis_MaximumWeeklyBenefitAmt], '0')
      ,ISNULL([ShortTermDis_BenefitPerofWeeklyIncome], '0.00')
      ,ISNULL([ShortTermDis_MaximumWeeklyBenefitAmtPerofSal], '0.00')
      ,ISNULL([ShortTermDis_MaximumDurationWeeks], '0')
      ,ISNULL([ShortTermDis_GuaranteedIssueAmt], '0')
      ,ISNULL([ShortTermDis_WaitingPeriodAccidentDays], '0')
      ,ISNULL([ShortTermDis_WaitingPeriodSicknessDays], '0')
      ,ISNULL([ShortTermDis_Pre_ExLookBackmonths], '0')
      ,ISNULL([ShortTermDis_Pre_ExCovered], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_SurvivorBenefit]), 'Y')
      ,ISNULL([ShortTermDis_SurvivorBenefitMultiple], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_24HrCoverage]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_FirstDayHospital]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_PartialDisability]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_Maternity]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_W_2Responsibility]), 'Carrier')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ShortTermDis_MaternityBenefits]), 'S')
      ,ISNULL([ShortTermDis_MaternityBenefitID], '')
      ,ISNULL([ShortTermDis_EmployeeRoundingPrecision], 'A')
      ,ISNULL([ShortTermDis_Buy_up_MinimumWeeklyBenefitAmt], '0')
      ,ISNULL([ShortTermDis_Buy_up_MaximumWeeklyBenefitAmt], '0')
      ,ISNULL([ShortTermDis_Buy_up_MaxWeeklyBenAmtPerofSal], '0.00')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupAddendum
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupAddendum
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupAddendum_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_addendum_gid
       ,i_key_addendum_id
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_addendum_id
       ,i_addendum_desc
       ,i_orig_addendum_id
       ,i_orig_addendum_desc
       ,i_approv_loa_Unit_period
       ,i_BeneStored
       ,i_approv_loa_period
       ,i_approv_loa_id
       ,i_approv_loa_desc
       ,i_definition_of_earnings_id
       ,i_definition_of_earnings_desc
       ,i_life_ben_type
       ,i_salary_multiplier
       ,i_min_coverage_amt
       ,i_max_coverage_amt
       ,i_guar_issue_amt
       ,i_emp_round_prec_bl
       ,i_emp_age_reduction
       ,i_emp_age_red_desc
       ,i_emp_base_add_bene
       ,i_add_life_multiplier
       ,i_emp_base_24hr
       ,i_salary_bracket_id
       ,i_salary_bracket_desc
       ,i_Base_Carrier
       ,i_Base_Seat
       ,i_Base_AirBag
       ,i_Base_Repatriation
       ,i_spouse_life_amt
       ,i_each_child_life_amt
       ,i_child_age_limit
       ,i_child_student_age_limit
       ,i_spouse_age_reduction
       ,i_spouse_age_red_desc
       ,i_child_age_reduction
       ,i_child_age_red_desc
       ,i_child_agevol_bracket_id
       ,i_child_agevol_bracket_desc
       ,i_spouse_guar_issue_amt
       ,i_child_guar_issue_amt
       ,i_spo_round_prec_bl
       ,i_chi_round_prec_bl
       ,i_accel_discount_amt
       ,i_percent_death_bene
       ,i_max_accel_bene_amt
       ,i_waiver_premium
       ,i_conversion_option
       ,i_sv_type
       ,i_sv_min_coverage_amt
       ,i_comb_max_cov_amt
       ,i_sv_guar_issue_amt
       ,i_comb_max_mult_salary
       ,i_sv_emp_age_reduction
       ,i_sv_emp_age_red_desc
       ,i_sv_emp_round_prec
       ,i_sv_emp_add_bene
       ,i_sv_add_life_multiplier
       ,i_sv_emp_base_24hr
       ,i_sv_salary_bracket_id
       ,i_sv_salary_bracket_desc
       ,i_sv_Carrier
       ,i_sv_Seat
       ,i_sv_AirBag
       ,i_sv_Repatriation
       ,i_sv_spouse_min_cov_amt
       ,i_sv_spouse_bene_max
       ,i_sv_spouse_guar_issue_amt
       ,i_sv_spouse_max_bene_perc
       ,i_sv_spouse_age_reduction
       ,i_sv_spouse_age_red_desc
       ,i_sv_spo_round_prec
       ,i_sv_each_child_life_amt
       ,i_sv_dep_max_bene_perc
       ,i_sv_child_age_limit
       ,i_sv_child_student_age_limit
       ,i_sv_child_age_reduction
       ,i_sv_child_age_red_desc
       ,i_sv_child_agevol_bracket_id
       ,i_sv_child_agevol_bracket_desc
       ,i_sv_chi_round_prec
       ,i_sv_accel_discount_amt
       ,i_sv_percent_death_bene
       ,i_sv_max_accel_bene_amt
       ,i_sv_waiver_premium
       ,i_sv_conversion_option
       ,i_portability
       ,i_ltd_type
       ,i_Benefit_Amt
       ,i_bene_prcnt_monthly_income
       ,i_min_monthly_bene_amt
       ,i_min_monthly_bene_per
       ,i_max_monthly_bene_amt
       ,i_max_monthly_bene_per
       ,i_ltd_guar_issue_amt
       ,i_elimination_period
       ,i_preex_look_back
       ,i_TreatmentFree
       ,i_preex_covered
       ,i_definition_of_disability
       ,i_bene_duration_schedule
       ,i_bene_duration_schedule_desc
       ,i_emp_round_prec_ld
       ,i_max_duration
       ,i_ltd_survivor
       ,i_Benefit_Multiple
       ,i_Mental_Ill
       ,i_Mental_Option
       ,i_Substance
       ,i_Substance_Option
       ,i_Other_Abuse
       ,i_Other_Option
       ,i_Credit_Max
       ,i_Credit_Months
       ,i_Credit_Therafter
       ,i_Credit_Year_Max
       ,i_Rehabilitation
       ,i_Rehab_Benefit
       ,i_Protect_Amt
       ,i_Protect_Percent
       ,i_Pension_ID
       ,i_Pension_Desc
       ,i_integration
       ,i_ltd_maternity
       ,i_Age_Limit
       ,i_COL_Allowance
       ,i_COL_Freeze
       ,i_Work_Mod
       ,i_Earnings
       ,i_Diseases
       ,i_Sight_Loss
       ,i_Add_Benefit
       ,i_ltd_residual_disability
       ,i_mental_illness
       ,i_w2_responsibility
       ,i_std_type
       ,i_min_weekly_bene_amt
       ,i_max_weekly_bene_amt
       ,i_bene_prcnt_weekly_income
       ,i_max_weekly_amt_prcnt_salary
       ,i_std_max_duration
       ,i_std_guar_issue_amt
       ,i_waiting_period_accident
       ,i_waiting_period_sick
       ,i_std_preex_look_back
       ,i_std_preex_covered
       ,i_std_survivor
       ,i_survivor_bene_multiple
       ,i_std_24hr_coverage
       ,i_first_day_hospital
       ,i_partially_disability
       ,i_std_maternity
       ,i_st_w2_responsibility
       ,i_maternity_benefits
       ,i_maternity_benefit_id
       ,i_maternity_benefit_desc
       ,i_emp_round_prec_sd
       ,i_buy_min_weekly_bene_amt
       ,i_buy_max_weekly_bene_amt
       ,i_buy_max_weekly_amt_prcnt_sal
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupAddendum

   OPEN GroupAddendum_Cursor
  FETCH NEXT FROM GroupAddendum_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_addendum_gid
       ,@i_key_addendum_id
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_addendum_id
       ,@i_addendum_desc
       ,@i_orig_addendum_id
       ,@i_orig_addendum_desc
       ,@i_approv_loa_Unit_period
       ,@i_BeneStored
       ,@i_approv_loa_period
       ,@i_approv_loa_id
       ,@i_approv_loa_desc
       ,@i_definition_of_earnings_id
       ,@i_definition_of_earnings_desc
       ,@i_life_ben_type
       ,@i_salary_multiplier
       ,@i_min_coverage_amt
       ,@i_max_coverage_amt
       ,@i_guar_issue_amt
       ,@i_emp_round_prec_bl
       ,@i_emp_age_reduction
       ,@i_emp_age_red_desc
       ,@i_emp_base_add_bene
       ,@i_add_life_multiplier
       ,@i_emp_base_24hr
       ,@i_salary_bracket_id
       ,@i_salary_bracket_desc
       ,@i_Base_Carrier
       ,@i_Base_Seat
       ,@i_Base_AirBag
       ,@i_Base_Repatriation
       ,@i_spouse_life_amt
       ,@i_each_child_life_amt
       ,@i_child_age_limit
       ,@i_child_student_age_limit
       ,@i_spouse_age_reduction
       ,@i_spouse_age_red_desc
       ,@i_child_age_reduction
       ,@i_child_age_red_desc
       ,@i_child_agevol_bracket_id
       ,@i_child_agevol_bracket_desc
       ,@i_spouse_guar_issue_amt
       ,@i_child_guar_issue_amt
       ,@i_spo_round_prec_bl
       ,@i_chi_round_prec_bl
       ,@i_accel_discount_amt
       ,@i_percent_death_bene
       ,@i_max_accel_bene_amt
       ,@i_waiver_premium
       ,@i_conversion_option
       ,@i_sv_type
       ,@i_sv_min_coverage_amt
       ,@i_comb_max_cov_amt
       ,@i_sv_guar_issue_amt
       ,@i_comb_max_mult_salary
       ,@i_sv_emp_age_reduction
       ,@i_sv_emp_age_red_desc
       ,@i_sv_emp_round_prec
       ,@i_sv_emp_add_bene
       ,@i_sv_add_life_multiplier
       ,@i_sv_emp_base_24hr
       ,@i_sv_salary_bracket_id
       ,@i_sv_salary_bracket_desc
       ,@i_sv_Carrier
       ,@i_sv_Seat
       ,@i_sv_AirBag
       ,@i_sv_Repatriation
       ,@i_sv_spouse_min_cov_amt
       ,@i_sv_spouse_bene_max
       ,@i_sv_spouse_guar_issue_amt
       ,@i_sv_spouse_max_bene_perc
       ,@i_sv_spouse_age_reduction
       ,@i_sv_spouse_age_red_desc
       ,@i_sv_spo_round_prec
       ,@i_sv_each_child_life_amt
       ,@i_sv_dep_max_bene_perc
       ,@i_sv_child_age_limit
       ,@i_sv_child_student_age_limit
       ,@i_sv_child_age_reduction
       ,@i_sv_child_age_red_desc
       ,@i_sv_child_agevol_bracket_id
       ,@i_sv_child_agevol_bracket_desc
       ,@i_sv_chi_round_prec
       ,@i_sv_accel_discount_amt
       ,@i_sv_percent_death_bene
       ,@i_sv_max_accel_bene_amt
       ,@i_sv_waiver_premium
       ,@i_sv_conversion_option
       ,@i_portability
       ,@i_ltd_type
       ,@i_Benefit_Amt
       ,@i_bene_prcnt_monthly_income
       ,@i_min_monthly_bene_amt
       ,@i_min_monthly_bene_per
       ,@i_max_monthly_bene_amt
       ,@i_max_monthly_bene_per
       ,@i_ltd_guar_issue_amt
       ,@i_elimination_period
       ,@i_preex_look_back
       ,@i_TreatmentFree
       ,@i_preex_covered
       ,@i_definition_of_disability
       ,@i_bene_duration_schedule
       ,@i_bene_duration_schedule_desc
       ,@i_emp_round_prec_ld
       ,@i_max_duration
       ,@i_ltd_survivor
       ,@i_Benefit_Multiple
       ,@i_Mental_Ill
       ,@i_Mental_Option
       ,@i_Substance
       ,@i_Substance_Option
       ,@i_Other_Abuse
       ,@i_Other_Option
       ,@i_Credit_Max
       ,@i_Credit_Months
       ,@i_Credit_Therafter
       ,@i_Credit_Year_Max
       ,@i_Rehabilitation
       ,@i_Rehab_Benefit
       ,@i_Protect_Amt
       ,@i_Protect_Percent
       ,@i_Pension_ID
       ,@i_Pension_Desc
       ,@i_integration
       ,@i_ltd_maternity
       ,@i_Age_Limit
       ,@i_COL_Allowance
       ,@i_COL_Freeze
       ,@i_Work_Mod
       ,@i_Earnings
       ,@i_Diseases
       ,@i_Sight_Loss
       ,@i_Add_Benefit
       ,@i_ltd_residual_disability
       ,@i_mental_illness
       ,@i_w2_responsibility
       ,@i_std_type
       ,@i_min_weekly_bene_amt
       ,@i_max_weekly_bene_amt
       ,@i_bene_prcnt_weekly_income
       ,@i_max_weekly_amt_prcnt_salary
       ,@i_std_max_duration
       ,@i_std_guar_issue_amt
       ,@i_waiting_period_accident
       ,@i_waiting_period_sick
       ,@i_std_preex_look_back
       ,@i_std_preex_covered
       ,@i_std_survivor
       ,@i_survivor_bene_multiple
       ,@i_std_24hr_coverage
       ,@i_first_day_hospital
       ,@i_partially_disability
       ,@i_std_maternity
       ,@i_st_w2_responsibility
       ,@i_maternity_benefits
       ,@i_maternity_benefit_id
       ,@i_maternity_benefit_desc
       ,@i_emp_round_prec_sd
       ,@i_buy_min_weekly_bene_amt
       ,@i_buy_max_weekly_bene_amt
       ,@i_buy_max_weekly_amt_prcnt_sal
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prContractAddendumAdd
             @i_entity_name
            ,@i_key_addendum_gid
            ,@i_key_addendum_id
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_addendum_id
            ,@i_addendum_desc
            ,@i_orig_addendum_id
            ,@i_orig_addendum_desc
            ,@i_approv_loa_Unit_period
            ,@i_BeneStored
            ,@i_approv_loa_period
            ,@i_approv_loa_id
            ,@i_approv_loa_desc
            ,@i_definition_of_earnings_id
            ,@i_definition_of_earnings_desc
            ,@i_life_ben_type
            ,@i_salary_multiplier
            ,@i_min_coverage_amt
            ,@i_max_coverage_amt
            ,@i_guar_issue_amt
            ,@i_emp_round_prec_bl
            ,@i_emp_age_reduction
            ,@i_emp_age_red_desc
            ,@i_emp_base_add_bene
            ,@i_add_life_multiplier
            ,@i_emp_base_24hr
            ,@i_salary_bracket_id
            ,@i_salary_bracket_desc
            ,@i_Base_Carrier
            ,@i_Base_Seat
            ,@i_Base_AirBag
            ,@i_Base_Repatriation
            ,@i_spouse_life_amt
            ,@i_each_child_life_amt
            ,@i_child_age_limit
            ,@i_child_student_age_limit
            ,@i_spouse_age_reduction
            ,@i_spouse_age_red_desc
            ,@i_child_age_reduction
            ,@i_child_age_red_desc
            ,@i_child_agevol_bracket_id
            ,@i_child_agevol_bracket_desc
            ,@i_spouse_guar_issue_amt
            ,@i_child_guar_issue_amt
            ,@i_spo_round_prec_bl
            ,@i_chi_round_prec_bl
            ,@i_accel_discount_amt
            ,@i_percent_death_bene
            ,@i_max_accel_bene_amt
            ,@i_waiver_premium
            ,@i_conversion_option
            ,@i_sv_type
            ,@i_sv_min_coverage_amt
            ,@i_comb_max_cov_amt
            ,@i_sv_guar_issue_amt
            ,@i_comb_max_mult_salary
            ,@i_sv_emp_age_reduction
            ,@i_sv_emp_age_red_desc
            ,@i_sv_emp_round_prec
            ,@i_sv_emp_add_bene
            ,@i_sv_add_life_multiplier
            ,@i_sv_emp_base_24hr
            ,@i_sv_salary_bracket_id
            ,@i_sv_salary_bracket_desc
            ,@i_sv_Carrier
            ,@i_sv_Seat
            ,@i_sv_AirBag
            ,@i_sv_Repatriation
            ,@i_sv_spouse_min_cov_amt
            ,@i_sv_spouse_bene_max
            ,@i_sv_spouse_guar_issue_amt
            ,@i_sv_spouse_max_bene_perc
            ,@i_sv_spouse_age_reduction
            ,@i_sv_spouse_age_red_desc
            ,@i_sv_spo_round_prec
            ,@i_sv_each_child_life_amt
            ,@i_sv_dep_max_bene_perc
            ,@i_sv_child_age_limit
            ,@i_sv_child_student_age_limit
            ,@i_sv_child_age_reduction
            ,@i_sv_child_age_red_desc
            ,@i_sv_child_agevol_bracket_id
            ,@i_sv_child_agevol_bracket_desc
            ,@i_sv_chi_round_prec
            ,@i_sv_accel_discount_amt
            ,@i_sv_percent_death_bene
            ,@i_sv_max_accel_bene_amt
            ,@i_sv_waiver_premium
            ,@i_sv_conversion_option
            ,@i_portability
            ,@i_ltd_type
            ,@i_Benefit_Amt
            ,@i_bene_prcnt_monthly_income
            ,@i_min_monthly_bene_amt
            ,@i_min_monthly_bene_per
            ,@i_max_monthly_bene_amt
            ,@i_max_monthly_bene_per
            ,@i_ltd_guar_issue_amt
            ,@i_elimination_period
            ,@i_preex_look_back
            ,@i_TreatmentFree
            ,@i_preex_covered
            ,@i_definition_of_disability
            ,@i_bene_duration_schedule
            ,@i_bene_duration_schedule_desc
            ,@i_emp_round_prec_ld
            ,@i_max_duration
            ,@i_ltd_survivor
            ,@i_Benefit_Multiple
            ,@i_Mental_Ill
            ,@i_Mental_Option
            ,@i_Substance
            ,@i_Substance_Option
            ,@i_Other_Abuse
            ,@i_Other_Option
            ,@i_Credit_Max
            ,@i_Credit_Months
            ,@i_Credit_Therafter
            ,@i_Credit_Year_Max
            ,@i_Rehabilitation
            ,@i_Rehab_Benefit
            ,@i_Protect_Amt
            ,@i_Protect_Percent
            ,@i_Pension_ID
            ,@i_Pension_Desc
            ,@i_integration
            ,@i_ltd_maternity
            ,@i_Age_Limit
            ,@i_COL_Allowance
            ,@i_COL_Freeze
            ,@i_Work_Mod
            ,@i_Earnings
            ,@i_Diseases
            ,@i_Sight_Loss
            ,@i_Add_Benefit
            ,@i_ltd_residual_disability
            ,@i_mental_illness
            ,@i_w2_responsibility
            ,@i_std_type
            ,@i_min_weekly_bene_amt
            ,@i_max_weekly_bene_amt
            ,@i_bene_prcnt_weekly_income
            ,@i_max_weekly_amt_prcnt_salary
            ,@i_std_max_duration
            ,@i_std_guar_issue_amt
            ,@i_waiting_period_accident
            ,@i_waiting_period_sick
            ,@i_std_preex_look_back
            ,@i_std_preex_covered
            ,@i_std_survivor
            ,@i_survivor_bene_multiple
            ,@i_std_24hr_coverage
            ,@i_first_day_hospital
            ,@i_partially_disability
            ,@i_std_maternity
            ,@i_st_w2_responsibility
            ,@i_maternity_benefits
            ,@i_maternity_benefit_id
            ,@i_maternity_benefit_desc
            ,@i_emp_round_prec_sd
            ,@i_buy_min_weekly_bene_amt
            ,@i_buy_max_weekly_bene_amt
            ,@i_buy_max_weekly_amt_prcnt_sal
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

				SELECT @current_gid				= addendum_gid
				  FROM Contract_Addendum
				 WHERE addendum_id				= @i_addendum_id

				-- Update to the static gid
				UPDATE dbo.Contract_Addendum 
				   SET addendum_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND addendum_gid				= @current_gid

				SELECT @current_gid				= LTD_GID
				  FROM Contract_Addendum
				 WHERE addendum_id				= @i_addendum_id

				-- Update to the static gid
				UPDATE dbo.Long_Term_Disability 
				   SET LTD_GID					= @static_gid 
				 WHERE record_status			= 'A'
				   AND LTD_GID					= @current_gid

				UPDATE Contract_Addendum
				   SET LTD_GID					= @static_gid
				 WHERE record_status			= 'A'
				   AND addendum_gid				= @static_gid
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_addendum_id, @i_addendum_desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupAddendum_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_addendum_gid
             ,@i_key_addendum_id
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_addendum_id
             ,@i_addendum_desc
             ,@i_orig_addendum_id
             ,@i_orig_addendum_desc
             ,@i_approv_loa_Unit_period
             ,@i_BeneStored
             ,@i_approv_loa_period
             ,@i_approv_loa_id
             ,@i_approv_loa_desc
             ,@i_definition_of_earnings_id
             ,@i_definition_of_earnings_desc
             ,@i_life_ben_type
             ,@i_salary_multiplier
             ,@i_min_coverage_amt
             ,@i_max_coverage_amt
             ,@i_guar_issue_amt
             ,@i_emp_round_prec_bl
             ,@i_emp_age_reduction
             ,@i_emp_age_red_desc
             ,@i_emp_base_add_bene
             ,@i_add_life_multiplier
             ,@i_emp_base_24hr
             ,@i_salary_bracket_id
             ,@i_salary_bracket_desc
             ,@i_Base_Carrier
             ,@i_Base_Seat
             ,@i_Base_AirBag
             ,@i_Base_Repatriation
             ,@i_spouse_life_amt
             ,@i_each_child_life_amt
             ,@i_child_age_limit
             ,@i_child_student_age_limit
             ,@i_spouse_age_reduction
             ,@i_spouse_age_red_desc
             ,@i_child_age_reduction
             ,@i_child_age_red_desc
             ,@i_child_agevol_bracket_id
             ,@i_child_agevol_bracket_desc
             ,@i_spouse_guar_issue_amt
             ,@i_child_guar_issue_amt
             ,@i_spo_round_prec_bl
             ,@i_chi_round_prec_bl
             ,@i_accel_discount_amt
             ,@i_percent_death_bene
             ,@i_max_accel_bene_amt
             ,@i_waiver_premium
             ,@i_conversion_option
             ,@i_sv_type
             ,@i_sv_min_coverage_amt
             ,@i_comb_max_cov_amt
             ,@i_sv_guar_issue_amt
             ,@i_comb_max_mult_salary
             ,@i_sv_emp_age_reduction
             ,@i_sv_emp_age_red_desc
             ,@i_sv_emp_round_prec
             ,@i_sv_emp_add_bene
             ,@i_sv_add_life_multiplier
             ,@i_sv_emp_base_24hr
             ,@i_sv_salary_bracket_id
             ,@i_sv_salary_bracket_desc
             ,@i_sv_Carrier
             ,@i_sv_Seat
             ,@i_sv_AirBag
             ,@i_sv_Repatriation
             ,@i_sv_spouse_min_cov_amt
             ,@i_sv_spouse_bene_max
             ,@i_sv_spouse_guar_issue_amt
             ,@i_sv_spouse_max_bene_perc
             ,@i_sv_spouse_age_reduction
             ,@i_sv_spouse_age_red_desc
             ,@i_sv_spo_round_prec
             ,@i_sv_each_child_life_amt
             ,@i_sv_dep_max_bene_perc
             ,@i_sv_child_age_limit
             ,@i_sv_child_student_age_limit
             ,@i_sv_child_age_reduction
             ,@i_sv_child_age_red_desc
             ,@i_sv_child_agevol_bracket_id
             ,@i_sv_child_agevol_bracket_desc
             ,@i_sv_chi_round_prec
             ,@i_sv_accel_discount_amt
             ,@i_sv_percent_death_bene
             ,@i_sv_max_accel_bene_amt
             ,@i_sv_waiver_premium
             ,@i_sv_conversion_option
             ,@i_portability
             ,@i_ltd_type
             ,@i_Benefit_Amt
             ,@i_bene_prcnt_monthly_income
             ,@i_min_monthly_bene_amt
             ,@i_min_monthly_bene_per
             ,@i_max_monthly_bene_amt
             ,@i_max_monthly_bene_per
             ,@i_ltd_guar_issue_amt
             ,@i_elimination_period
             ,@i_preex_look_back
             ,@i_TreatmentFree
             ,@i_preex_covered
             ,@i_definition_of_disability
             ,@i_bene_duration_schedule
             ,@i_bene_duration_schedule_desc
             ,@i_emp_round_prec_ld
             ,@i_max_duration
             ,@i_ltd_survivor
             ,@i_Benefit_Multiple
             ,@i_Mental_Ill
             ,@i_Mental_Option
             ,@i_Substance
             ,@i_Substance_Option
             ,@i_Other_Abuse
             ,@i_Other_Option
             ,@i_Credit_Max
             ,@i_Credit_Months
             ,@i_Credit_Therafter
             ,@i_Credit_Year_Max
             ,@i_Rehabilitation
             ,@i_Rehab_Benefit
             ,@i_Protect_Amt
             ,@i_Protect_Percent
             ,@i_Pension_ID
             ,@i_Pension_Desc
             ,@i_integration
             ,@i_ltd_maternity
             ,@i_Age_Limit
             ,@i_COL_Allowance
             ,@i_COL_Freeze
             ,@i_Work_Mod
             ,@i_Earnings
             ,@i_Diseases
             ,@i_Sight_Loss
             ,@i_Add_Benefit
             ,@i_ltd_residual_disability
             ,@i_mental_illness
             ,@i_w2_responsibility
             ,@i_std_type
             ,@i_min_weekly_bene_amt
             ,@i_max_weekly_bene_amt
             ,@i_bene_prcnt_weekly_income
             ,@i_max_weekly_amt_prcnt_salary
             ,@i_std_max_duration
             ,@i_std_guar_issue_amt
             ,@i_waiting_period_accident
             ,@i_waiting_period_sick
             ,@i_std_preex_look_back
             ,@i_std_preex_covered
             ,@i_std_survivor
             ,@i_survivor_bene_multiple
             ,@i_std_24hr_coverage
             ,@i_first_day_hospital
             ,@i_partially_disability
             ,@i_std_maternity
             ,@i_st_w2_responsibility
             ,@i_maternity_benefits
             ,@i_maternity_benefit_id
             ,@i_maternity_benefit_desc
             ,@i_emp_round_prec_sd
             ,@i_buy_min_weekly_bene_amt
             ,@i_buy_max_weekly_bene_amt
             ,@i_buy_max_weekly_amt_prcnt_sal
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupAddendum_Cursor
DEALLOCATE GroupAddendum_Cursor

END
GO