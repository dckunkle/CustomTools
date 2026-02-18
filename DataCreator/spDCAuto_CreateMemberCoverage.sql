IF OBJECT_ID('dbo.spDCAuto_CreateMemberCoverage') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberCoverage AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberCoverage
Purpose:    Create membercoverage data from CorderAutomation
Method:     MemberCoverage
Screen GID: 4
Procedure:  dbo.prEligCoverageModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/22/2020	DK				Original procedure
08/23/2021  DK				Clear #Temp_Elig table each time it is called
09/29/2021	DK				Make a change to get the right LOB to modify
11/10/2021	DK				Change temp table name, #MemberCoverageDC. Also increased field lengths
11/04/2022	DK				Changes for ADD vs MODIFY 
06/27/2023	DK				For ADD, get coverage code from automation or from core
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberCoverage '200-CONFIG%', 99, '200-CONFIG','MemberCoverage', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberCoverage
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
	   ,@ssn						VARCHAR(50)
	   ,@member_id					VARCHAR(200)
	   ,@default_LOB				VARCHAR(200)
	   ,@SearchID					VARCHAR(200)

	   ,@current_eff				VARCHAR(50)
	   ,@current_term				VARCHAR(50)
	   ,@current_modified			VARCHAR(50)
	   ,@search_lob					VARCHAR(20)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name              VARCHAR(50)
       ,@i_key_1_field              VARCHAR(50)
       ,@i_key_2_field              VARCHAR(50)
       ,@i_key_3_field              VARCHAR(50)
       ,@i_key_4_field              VARCHAR(50)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(50)
       ,@i_Date_Time_Modified       VARCHAR(50)
       ,@iUserID                    VARCHAR(50)
       ,@i_effective_date           VARCHAR(50)
       ,@i_termination_date         VARCHAR(50)
       ,@i_prod_eff_date            VARCHAR(50)
       ,@i_default_lob              VARCHAR(50)
       ,@i_orig_eff_date            VARCHAR(50)
       ,@i_plan_strategy_id         VARCHAR(50)
       ,@i_plan_strategy_desc       VARCHAR(150)
       ,@i_elig_val_id              VARCHAR(50)
       ,@i_elig_val_desc            VARCHAR(75)
       ,@i_network_id               VARCHAR(50)
       ,@i_network_name             VARCHAR(50)
       ,@i_rx_network_strategy_id   VARCHAR(50)
       ,@i_rx_network_strategy_desc VARCHAR(100)
       ,@i_last_card_date           VARCHAR(50)
       ,@i_bill_flag                VARCHAR(50)
       ,@i_cob_type                 VARCHAR(50)
       ,@i_Coverage_Code            VARCHAR(50)
       ,@i_paid_thru_date           VARCHAR(50)
       ,@i_manual_enrollment        VARCHAR(50)
       ,@i_cobra_flag               VARCHAR(50)
       ,@i_cobra_ar_type            VARCHAR(200)
       ,@i_rate_adj_amt             VARCHAR(50)
       ,@i_Class_ID                 VARCHAR(50)
       ,@i_Salary_Mult              VARCHAR(50)
       ,@i_req_vol_amt              VARCHAR(50)
       ,@i_apv_vol_amt              VARCHAR(50)
       ,@i_orig_apv_vol_amt         VARCHAR(50)
       ,@i_Vol_Approval             VARCHAR(50)
       ,@i_Monthly_Benefit          VARCHAR(50)
       ,@i_Is_Subscriber_Covered    VARCHAR(50)
       ,@i_Term_Reason              VARCHAR(50)
       ,@i_Term_Reason_Desc         VARCHAR(100)
       ,@i_Loop2000GroupID          VARCHAR(50)
       ,@i_REFZZMemberID            VARCHAR(50)
       ,@i_REF23MemberID            VARCHAR(50)
       ,@i_REF6OMemberID            VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(255)
       ,@i_Pay_tol_ID               VARCHAR(50)
       ,@i_Pay_tol_Desc             VARCHAR(100)
       ,@i_DisplayResults           VARCHAR(50)
       ,@return_xml                 XML
       ,@i_eob_language             VARCHAR(50)
       ,@i_Product_Offering_id      VARCHAR(50)
       ,@i_Product_Offering_desc    VARCHAR(150)
       ,@i_apply_to_dependents      VARCHAR(50)
	   ,@screen_action				VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberCoverageDC') IS NOT NULL
	DROP TABLE #MemberCoverageDC

CREATE TABLE #MemberCoverageDC
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('New_Elig_Coverage')
      ,i_key_1_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field             VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified       VARCHAR(30)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,i_effective_date           VARCHAR(50)
      ,i_termination_date         VARCHAR(50)
      ,i_prod_eff_date            VARCHAR(50)
      ,i_default_lob              VARCHAR(50)
      ,i_orig_eff_date            VARCHAR(50)
      ,i_plan_strategy_id         VARCHAR(50)
      ,i_plan_strategy_desc       VARCHAR(150)
      ,i_elig_val_id              VARCHAR(50)
      ,i_elig_val_desc            VARCHAR(75)
      ,i_network_id               VARCHAR(50)
      ,i_network_name             VARCHAR(50)
      ,i_rx_network_strategy_id   VARCHAR(50)
      ,i_rx_network_strategy_desc VARCHAR(100)
      ,i_last_card_date           VARCHAR(50)
      ,i_bill_flag                VARCHAR(50)
      ,i_cob_type                 VARCHAR(50)
      ,i_Coverage_Code            VARCHAR(50)
      ,i_paid_thru_date           VARCHAR(50)
      ,i_manual_enrollment        VARCHAR(50)
      ,i_cobra_flag               VARCHAR(50)
      ,i_cobra_ar_type            VARCHAR(200)
      ,i_rate_adj_amt             VARCHAR(50)
      ,i_Class_ID                 VARCHAR(50)
      ,i_Salary_Mult              VARCHAR(50)
      ,i_req_vol_amt              VARCHAR(50)
      ,i_apv_vol_amt              VARCHAR(50)
      ,i_orig_apv_vol_amt         VARCHAR(50)
      ,i_Vol_Approval             VARCHAR(50)
      ,i_Monthly_Benefit          VARCHAR(50)
      ,i_Is_Subscriber_Covered    VARCHAR(50)
      ,i_Term_Reason              VARCHAR(50)
      ,i_Term_Reason_Desc         VARCHAR(100)
      ,i_Loop2000GroupID          VARCHAR(50)
      ,i_REFZZMemberID            VARCHAR(50)
      ,i_REF23MemberID            VARCHAR(50)
      ,i_REF6OMemberID            VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(255)
      ,i_Pay_tol_ID               VARCHAR(50)
      ,i_Pay_tol_Desc             VARCHAR(100)
      ,i_DisplayResults           VARCHAR(50)
      ,return_xml                 XML
      ,i_eob_language             VARCHAR(50)
      ,i_Product_Offering_id      VARCHAR(50)
      ,i_Product_Offering_desc    VARCHAR(150)
      ,i_apply_to_dependents      VARCHAR(50)
	  ,screen_action			  VARCHAR(100)
      ,record_id                  INT
      ,static_gid                 INT)

--Do not change the name of this teporary table, must remain #Temp_Elig
IF OBJECT_ID('tempdb.dbo.#Temp_Elig') IS NOT NULL
	DROP TABLE #Temp_Elig

CREATE TABLE #Temp_Elig  
      (effective_date           VARCHAR(50)  
      ,termination_date         VARCHAR(50)  
      ,prod_effective_date      VARCHAR(50)  
      ,default_lob              VARCHAR(50)  
      ,orig_eff_date            VARCHAR(50)  
      ,dummy_field3             VARCHAR(25)  
      ,plan_strategy_id         VARCHAR(50)  
      ,plan_strategy_desc       VARCHAR(150)  
      ,product_offering_id      VARCHAR(50)     
      ,product_offering_desc    VARCHAR(150)    
      ,elig_validation_id       VARCHAR(50)  
      ,elig_val_description     VARCHAR(100)  
      ,network_search_id        VARCHAR(50)  
      ,network_search_name      VARCHAR(100)  
      ,rx_network_strategy_id   VARCHAR(25)  
      ,rx_network_strategy_desc VARCHAR(100)  
      ,pay_tol_id               VARCHAR(30)  
      ,pay_tol_desc             VARCHAR(100)  
      ,date_of_last_id_card     VARCHAR(50)  
      ,bill_flag                VARCHAR(50)  
      ,cob_type                 VARCHAR(50)  
      ,coverage_code            VARCHAR(50)  
      ,paid_thru_date           VARCHAR(50)  
      ,manual_enrollement       VARCHAR(10)  
      ,cobra_flag               VARCHAR(50)  
      ,cobra_ar_type            VARCHAR(50)  
      ,rate_adj_amt             MONEY  
      ,eob_language             VARCHAR(8)  
      ,class_id                 VARCHAR(6)  
      ,salary_multiplier        VARCHAR(20)  
      ,req_vol_amt              VARCHAR(20)  
      ,apv_vol_amt              VARCHAR(20)  
      ,orig_apv_vol_amt         VARCHAR(20)  
      ,vol_approval             CHAR(1)  
      ,monthly_benefit          DECIMAL(12,2)  
      ,Is_Subscriber_Covered    CHAR(1)             
      ,dummy_field4             VARCHAR(10)  
      ,term_reasons_code        VARCHAR(6)  
      ,term_reasons_desc        VARCHAR(50)            
      ,Loop2000GroupID          varchar(50)  
      ,REFZZMemberID            varchar(50)  
      ,REF23MemberID            varchar(50)  
      ,REF6OMemberID            varchar(50)  
      ,date_time_created        VARCHAR(50)  
      ,user_id_created          VARCHAR(50)  
      ,date_time_modified       VARCHAR(50)  
      ,[user_id]                VARCHAR(50)  
      ,form_id                  VARCHAR(50))  

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberCoverageDC
      (SearchID
      ,i_effective_date           
      ,i_termination_date         
      ,i_prod_eff_date            
      ,i_default_lob              
      ,i_orig_eff_date            
      ,i_plan_strategy_id         
      ,i_elig_val_id              
      ,i_network_id               
      ,i_bill_flag                
      ,i_cob_type                 
      ,i_Coverage_Code            
      ,i_paid_thru_date           
      ,i_manual_enrollment        
      ,i_cobra_flag               
      ,i_cobra_ar_type            
      ,i_rate_adj_amt             
      ,i_Class_ID                 
      ,i_Salary_Mult              
      ,i_req_vol_amt              
      ,i_apv_vol_amt              
      ,i_orig_apv_vol_amt         
      ,i_Vol_Approval             
      ,i_Monthly_Benefit          
      ,i_Is_Subscriber_Covered    
      ,i_Term_Reason              
      ,i_Loop2000GroupID          
      ,i_REFZZMemberID            
      ,i_REF23MemberID            
      ,i_REF6OMemberID  
	  ,screen_action          
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Coverage_EffectiveDt], '')
      ,ISNULL([*Coverage_TerminationDt], '12/31/9999')
      ,ISNULL([Coverage_ProdEffDt], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_LOB]), '')
      ,ISNULL([Coverage_OrigEffDate], '')
      ,ISNULL([Coverage_PlanStratID], '')
      ,ISNULL([Coverage_EligValidationID], '')
      ,ISNULL([Coverage_SuperNetwrkID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_BillFlg]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_COBType]), 'E')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CoverageCd]), 'EMP')
      ,ISNULL([Coverage_PaidThroughDate], '00/00/0000')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_ManualEnroll]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CobraFlg]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Coverage_CobraARType]), 'G')
      ,ISNULL([Coverage_RateAdjustAmt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_EmplyeClassID]), '')
      ,ISNULL([Coverage_SalaryMult], '0.00')
      ,ISNULL([Coverage_ReqVolAmt], '0.00')
      ,ISNULL([Coverage_ApprVolAmt], '0.00')
      ,ISNULL([Coverage_OrigApprVolAmt], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_VolAppr]), '')
      ,ISNULL([Coverage_MonBenefit], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Coverage_SubsCovrd]), 'Y')
      ,ISNULL([Coverage_TermReasonCd], '')
      ,ISNULL([CarrierGroupID], '')
      ,ISNULL([REF*ZZCarrierMemID], '')
      ,ISNULL([REF*23CarrierIndID], '')
      ,ISNULL([PolicyIDEnrollID], '')
	  ,ISNULL([ACTION],'')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberEligCoverage
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberCoverageDC
   SET iUserID  = @user

UPDATE #MemberCoverageDC
   SET i_action			= 'MODIFY'
 WHERE screen_action	= 'MODIFY_EXIT'
 
--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberCoverage_Cursor CURSOR FOR
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
       ,i_effective_date
       ,i_termination_date
       ,i_prod_eff_date
       ,i_default_lob
       ,i_orig_eff_date
       ,i_plan_strategy_id
       ,i_plan_strategy_desc
       ,i_elig_val_id
       ,i_elig_val_desc
       ,i_network_id
       ,i_network_name
       ,i_rx_network_strategy_id
       ,i_rx_network_strategy_desc
       ,i_last_card_date
       ,i_bill_flag
       ,i_cob_type
       ,i_Coverage_Code
       ,i_paid_thru_date
       ,i_manual_enrollment
       ,i_cobra_flag
       ,i_cobra_ar_type
       ,i_rate_adj_amt
       ,i_Class_ID
       ,i_Salary_Mult
       ,i_req_vol_amt
       ,i_apv_vol_amt
       ,i_orig_apv_vol_amt
       ,i_Vol_Approval
       ,i_Monthly_Benefit
       ,i_Is_Subscriber_Covered
       ,i_Term_Reason
       ,i_Term_Reason_Desc
       ,i_Loop2000GroupID
       ,i_REFZZMemberID
       ,i_REF23MemberID
       ,i_REF6OMemberID
       ,o_status
       ,o_message
       ,i_Pay_tol_ID
       ,i_Pay_tol_Desc
       ,i_DisplayResults
       ,return_xml
       ,i_eob_language
       ,i_Product_Offering_id
       ,i_Product_Offering_desc
       ,i_apply_to_dependents
       ,record_id
       ,static_gid
   FROM #MemberCoverageDC

   OPEN MemberCoverage_Cursor
  FETCH NEXT FROM MemberCoverage_Cursor
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
       ,@i_effective_date
       ,@i_termination_date
       ,@i_prod_eff_date
       ,@i_default_lob
       ,@i_orig_eff_date
       ,@i_plan_strategy_id
       ,@i_plan_strategy_desc
       ,@i_elig_val_id
       ,@i_elig_val_desc
       ,@i_network_id
       ,@i_network_name
       ,@i_rx_network_strategy_id
       ,@i_rx_network_strategy_desc
       ,@i_last_card_date
       ,@i_bill_flag
       ,@i_cob_type
       ,@i_Coverage_Code
       ,@i_paid_thru_date
       ,@i_manual_enrollment
       ,@i_cobra_flag
       ,@i_cobra_ar_type
       ,@i_rate_adj_amt
       ,@i_Class_ID
       ,@i_Salary_Mult
       ,@i_req_vol_amt
       ,@i_apv_vol_amt
       ,@i_orig_apv_vol_amt
       ,@i_Vol_Approval
       ,@i_Monthly_Benefit
       ,@i_Is_Subscriber_Covered
       ,@i_Term_Reason
       ,@i_Term_Reason_Desc
       ,@i_Loop2000GroupID
       ,@i_REFZZMemberID
       ,@i_REF23MemberID
       ,@i_REF6OMemberID
       ,@o_status
       ,@o_message
       ,@i_Pay_tol_ID
       ,@i_Pay_tol_Desc
       ,@i_DisplayResults
       ,@return_xml
       ,@i_eob_language
       ,@i_Product_Offering_id
       ,@i_Product_Offering_desc
       ,@i_apply_to_dependents
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the child and parent gids for the member
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @search_lob	= token FROM #Tokens WHERE token_order = 2
			SELECT @ssn		    = token	FROM #Tokens WHERE token_order = 1

			-- Assuming a new LOB is being added, strip off the literal LOB
			IF LEFT(@search_lob, 4) = 'LOB:' SET @search_lob = RTRIM(LTRIM(SUBSTRING(@search_lob,5,9999)))

			IF @i_action = 'MODIFY'
				BEGIN

					SELECT @i_key_1_field			= EC.child_gid
						  ,@i_key_2_field			= EC.child_identifier
						  ,@i_key_3_field			= EC.parent_gid
						  ,@i_key_4_field			= EC.parent_identifier
						  ,@i_key_5_field			= CONVERT(VARCHAR(10), EC.effective_date, 101)
						  ,@i_key_6_field			= CONVERT(VARCHAR(10), EC.termination_date, 101)
						  ,@i_key_7_field			= EC.group_gid
						  ,@i_key_8_field			= 0
						  ,@i_key_9_field			= EC.default_lob
						  ,@i_key_10_field			= EC.member_id
						  ,@i_Date_Time_Modified	= CONVERT(VARCHAR(30), EC.date_time_modified, 121)
					  FROM Eligibility_Coverage		EC
					  JOIN Contacts					C
						ON EC.child_gid				= C.contact_gid
					 WHERE EC.record_status			= 'A'
					   AND C.record_status			= 'A'
					   AND EC.child_identifier		= 'M'
					   AND EC.parent_identifier		= 'M'
					   AND C.actual_ssn				= @ssn
					   AND EC.default_lob			= @search_lob

					--Now get the initial values for the screen
					DELETE FROM #Temp_Elig
					EXEC prEligCoveragePopulate 'New_Elig_Coverage', @i_key_1_field, @i_key_2_field, @i_key_3_field, @i_key_4_field, @i_key_5_field, @i_key_6_field, @i_key_7_field, @i_key_8_field, @i_key_9_field, @i_key_10_field, 'MODIFY', 0,'','Y'
					

					-- Choose between the default value and the user's value
					SELECT TOP 1
						   @i_effective_date			= CASE WHEN ISNULL(@i_effective_date,'') = ''			THEN TE.effective_date			ELSE @i_effective_date END
						  ,@i_termination_date			= CASE WHEN ISNULL(@i_termination_date,'') = ''			THEN TE.termination_date		ELSE @i_termination_date END
						  ,@i_prod_eff_date				= CASE WHEN ISNULL(@i_prod_eff_date,'') = ''			THEN TE.prod_effective_date		ELSE @i_prod_eff_date END
						  ,@i_default_lob				= CASE WHEN ISNULL(@i_default_lob,'') = ''				THEN TE.default_lob				ELSE @i_default_lob END
						  ,@i_orig_eff_date				= CASE WHEN ISNULL(@i_orig_eff_date,'') = ''			THEN TE.orig_eff_date			ELSE @i_orig_eff_date END
						  ,@i_plan_strategy_id			= CASE WHEN ISNULL(@i_plan_strategy_id,'') = ''			THEN TE.plan_strategy_id		ELSE @i_plan_strategy_id END
						  ,@i_elig_val_id				= CASE WHEN ISNULL(@i_elig_val_id,'') = ''				THEN TE.elig_validation_id		ELSE @i_elig_val_id END
						  ,@i_network_id				= CASE WHEN ISNULL(@i_network_id,'') = ''				THEN TE.network_search_id		ELSE @i_network_id END
						  ,@i_rx_network_strategy_id	= CASE WHEN ISNULL(@i_rx_network_strategy_id,'') = ''	THEN TE.rx_network_strategy_id	ELSE @i_rx_network_strategy_id END
						  ,@i_last_card_date			= CASE WHEN ISNULL(@i_last_card_date,'') = ''			THEN TE.date_of_last_id_card	ELSE @i_last_card_date END
						  ,@i_bill_flag					= CASE WHEN ISNULL(@i_bill_flag,'') = ''				THEN TE.bill_flag				ELSE @i_bill_flag END
						  ,@i_cob_type					= CASE WHEN ISNULL(@i_cob_type,'') = ''					THEN TE.cob_type				ELSE @i_cob_type END
						  ,@i_Coverage_Code				= TE.coverage_code
						  ,@i_paid_thru_date			= CASE WHEN ISNULL(@i_paid_thru_date,'') = ''			THEN TE.paid_thru_date			ELSE @i_paid_thru_date END
						  ,@i_manual_enrollment			= CASE WHEN ISNULL(@i_manual_enrollment,'') = ''		THEN TE.manual_enrollement		ELSE @i_manual_enrollment END
						  ,@i_cobra_flag				= CASE WHEN ISNULL(@i_cobra_flag,'') = ''				THEN TE.cobra_flag				ELSE @i_cobra_flag END
						  ,@i_cobra_ar_type				= CASE WHEN ISNULL(@i_cobra_ar_type,'') = ''			THEN TE.cobra_ar_type			ELSE @i_cobra_ar_type END
						  ,@i_rate_adj_amt				= CASE WHEN ISNULL(@i_rate_adj_amt,'') = ''				THEN TE.rate_adj_amt			ELSE @i_rate_adj_amt END
						  ,@i_Class_ID					= CASE WHEN ISNULL(@i_Class_ID,'') = ''					THEN TE.class_id				ELSE @i_Class_ID END
						  ,@i_Salary_Mult				= CASE WHEN ISNULL(@i_Salary_Mult,'') = ''				THEN TE.salary_multiplier		ELSE @i_Salary_Mult END
						  ,@i_req_vol_amt				= CASE WHEN ISNULL(@i_req_vol_amt,'') = ''				THEN TE.req_vol_amt				ELSE @i_req_vol_amt END
						  ,@i_apv_vol_amt				= CASE WHEN ISNULL(@i_apv_vol_amt,'') = ''				THEN TE.apv_vol_amt				ELSE @i_apv_vol_amt END
						  ,@i_orig_apv_vol_amt			= CASE WHEN ISNULL(@i_orig_apv_vol_amt,'') = ''			THEN TE.orig_apv_vol_amt		ELSE @i_orig_apv_vol_amt END
						  ,@i_Vol_Approval				= CASE WHEN ISNULL(@i_Vol_Approval,'') = ''				THEN TE.vol_approval			ELSE @i_Vol_Approval END
						  ,@i_Monthly_Benefit			= CASE WHEN ISNULL(@i_Monthly_Benefit,'') = ''			THEN TE.monthly_benefit			ELSE @i_Monthly_Benefit END
						  ,@i_Is_Subscriber_Covered		= CASE WHEN ISNULL(@i_Is_Subscriber_Covered,'') = ''	THEN TE.Is_Subscriber_Covered	ELSE @i_Is_Subscriber_Covered END
						  ,@i_Term_Reason				= CASE WHEN ISNULL(@i_Term_Reason,'') = ''				THEN TE.term_reasons_code		ELSE @i_Term_Reason END
						  ,@i_Loop2000GroupID			= CASE WHEN ISNULL(@i_Loop2000GroupID,'') = ''			THEN TE.Loop2000GroupID			ELSE @i_Loop2000GroupID END
						  ,@i_REFZZMemberID				= CASE WHEN ISNULL(@i_REFZZMemberID,'') = ''			THEN TE.REFZZMemberID			ELSE @i_REFZZMemberID END
						  ,@i_REF23MemberID				= CASE WHEN ISNULL(@i_REF23MemberID,'') = ''			THEN TE.REF23MemberID			ELSE @i_REF23MemberID END
						  ,@i_REF6OMemberID				= CASE WHEN ISNULL(@i_REF6OMemberID,'') = ''			THEN TE.REF6OMemberID			ELSE @i_REF6OMemberID END
					  FROM #Temp_Elig		TE

				END
			
			IF @i_action = 'ADD'
				BEGIN

					SELECT @i_key_1_field			= EC.child_gid
						  ,@i_key_2_field			= EC.child_identifier
						  ,@i_key_3_field			= EC.parent_gid
						  ,@i_key_4_field			= EC.parent_identifier
						  ,@i_key_7_field			= EC.group_gid
						  ,@i_key_10_field			= EC.member_id
					  FROM Eligibility_Coverage		EC
					  JOIN Contacts					C
						ON EC.child_gid				= C.contact_gid
					 WHERE EC.record_status			= 'A'
					   AND C.record_status			= 'A'
					   AND EC.child_identifier		= 'M'
					   AND EC.parent_identifier		= 'M'
					   AND C.actual_ssn				= @ssn

					SELECT @i_key_9_field = @i_default_lob

					--Now get the initial values for the screen
					DELETE FROM #Temp_Elig
					EXEC prEligCoveragePopulate 'New_Elig_Coverage', @i_key_1_field, @i_key_2_field, @i_key_3_field, @i_key_4_field, 0, 0, @i_key_7_field, 0, @i_key_9_field, @i_key_10_field, 'ADD', 0,'','Y'

					-- Choose between the default value and the user's value
					SELECT TOP 1
						   @i_effective_date			= CASE WHEN ISNULL(@i_effective_date,'') = ''			THEN TE.effective_date			ELSE @i_effective_date END
						  ,@i_termination_date			= CASE WHEN ISNULL(@i_termination_date,'') = ''			THEN TE.termination_date		ELSE @i_termination_date END
						  ,@i_prod_eff_date				= CASE WHEN ISNULL(@i_prod_eff_date,'') = ''			THEN TE.prod_effective_date		ELSE @i_prod_eff_date END
						  ,@i_default_lob				= CASE WHEN ISNULL(@i_default_lob,'') = ''				THEN TE.default_lob				ELSE @i_default_lob END
						  ,@i_orig_eff_date				= CASE WHEN ISNULL(@i_orig_eff_date,'') = ''			THEN TE.orig_eff_date			ELSE @i_orig_eff_date END
						  ,@i_plan_strategy_id			= CASE WHEN ISNULL(@i_plan_strategy_id,'') = ''			THEN TE.plan_strategy_id		ELSE @i_plan_strategy_id END
						  ,@i_elig_val_id				= CASE WHEN ISNULL(@i_elig_val_id,'') = ''				THEN TE.elig_validation_id		ELSE @i_elig_val_id END
						  ,@i_network_id				= CASE WHEN ISNULL(@i_network_id,'') = ''				THEN TE.network_search_id		ELSE @i_network_id END
						  ,@i_rx_network_strategy_id	= CASE WHEN ISNULL(@i_rx_network_strategy_id,'') = ''	THEN TE.rx_network_strategy_id	ELSE @i_rx_network_strategy_id END
						  ,@i_last_card_date			= CASE WHEN ISNULL(@i_last_card_date,'') = ''			THEN TE.date_of_last_id_card	ELSE @i_last_card_date END
						  ,@i_bill_flag					= CASE WHEN ISNULL(@i_bill_flag,'') = ''				THEN TE.bill_flag				ELSE @i_bill_flag END
						  ,@i_cob_type					= CASE WHEN ISNULL(@i_cob_type,'') = ''					THEN TE.cob_type				ELSE @i_cob_type END
						  ,@i_Coverage_Code				= CASE WHEN ISNULL(@i_Coverage_Code,'') = ''			THEN TE.coverage_code			ELSE @i_Coverage_Code END
						  ,@i_paid_thru_date			= CASE WHEN ISNULL(@i_paid_thru_date,'') = ''			THEN TE.paid_thru_date			ELSE @i_paid_thru_date END
						  ,@i_manual_enrollment			= CASE WHEN ISNULL(@i_manual_enrollment,'') = ''		THEN TE.manual_enrollement		ELSE @i_manual_enrollment END
						  ,@i_cobra_flag				= CASE WHEN ISNULL(@i_cobra_flag,'') = ''				THEN TE.cobra_flag				ELSE @i_cobra_flag END
						  ,@i_cobra_ar_type				= CASE WHEN ISNULL(@i_cobra_ar_type,'') = ''			THEN TE.cobra_ar_type			ELSE @i_cobra_ar_type END
						  ,@i_rate_adj_amt				= CASE WHEN ISNULL(@i_rate_adj_amt,'') = ''				THEN TE.rate_adj_amt			ELSE @i_rate_adj_amt END
						  ,@i_Class_ID					= CASE WHEN ISNULL(@i_Class_ID,'') = ''					THEN TE.class_id				ELSE @i_Class_ID END
						  ,@i_Salary_Mult				= CASE WHEN ISNULL(@i_Salary_Mult,'') = ''				THEN TE.salary_multiplier		ELSE @i_Salary_Mult END
						  ,@i_req_vol_amt				= CASE WHEN ISNULL(@i_req_vol_amt,'') = ''				THEN TE.req_vol_amt				ELSE @i_req_vol_amt END
						  ,@i_apv_vol_amt				= CASE WHEN ISNULL(@i_apv_vol_amt,'') = ''				THEN TE.apv_vol_amt				ELSE @i_apv_vol_amt END
						  ,@i_orig_apv_vol_amt			= CASE WHEN ISNULL(@i_orig_apv_vol_amt,'') = ''			THEN TE.orig_apv_vol_amt		ELSE @i_orig_apv_vol_amt END
						  ,@i_Vol_Approval				= CASE WHEN ISNULL(@i_Vol_Approval,'') = ''				THEN TE.vol_approval			ELSE @i_Vol_Approval END
						  ,@i_Monthly_Benefit			= CASE WHEN ISNULL(@i_Monthly_Benefit,'') = ''			THEN TE.monthly_benefit			ELSE @i_Monthly_Benefit END
						  ,@i_Is_Subscriber_Covered		= CASE WHEN ISNULL(@i_Is_Subscriber_Covered,'') = ''	THEN TE.Is_Subscriber_Covered	ELSE @i_Is_Subscriber_Covered END
						  ,@i_Term_Reason				= CASE WHEN ISNULL(@i_Term_Reason,'') = ''				THEN TE.term_reasons_code		ELSE @i_Term_Reason END
						  ,@i_Loop2000GroupID			= CASE WHEN ISNULL(@i_Loop2000GroupID,'') = ''			THEN TE.Loop2000GroupID			ELSE @i_Loop2000GroupID END
						  ,@i_REFZZMemberID				= CASE WHEN ISNULL(@i_REFZZMemberID,'') = ''			THEN TE.REFZZMemberID			ELSE @i_REFZZMemberID END
						  ,@i_REF23MemberID				= CASE WHEN ISNULL(@i_REF23MemberID,'') = ''			THEN TE.REF23MemberID			ELSE @i_REF23MemberID END
						  ,@i_REF6OMemberID				= CASE WHEN ISNULL(@i_REF6OMemberID,'') = ''			THEN TE.REF6OMemberID			ELSE @i_REF6OMemberID END
					  FROM #Temp_Elig		TE
				END

			-- Now get the necessary descriptions (in case they have changed)
			SELECT @i_plan_strategy_desc		= dbo.fnDCAuto_GetPlanStrategyDescriptionFromID(@i_plan_strategy_id)
			      ,@i_elig_val_desc				= dbo.fnDCAuto_GetEligibilityValidationDescriptionFromID(@i_elig_val_id)
				  ,@i_network_name				= dbo.fnDCAuto_GetNetworkDescriptionFromID(@i_network_id)
				  ,@i_rx_network_strategy_desc	= ''
				  ,@i_orig_eff_date				= TRIM(@i_orig_eff_date)

		EXEC dbo.prEligCoverageModify
             @i_entity_name
            ,@i_key_1_field
            ,@i_key_2_field
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field		-- @i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_Date_Time_Modified
            ,@iUserID
            ,@i_effective_date
            ,@i_termination_date
            ,@i_prod_eff_date
            ,@i_default_lob
            ,@i_orig_eff_date
            ,@i_plan_strategy_id
            ,@i_plan_strategy_desc
            ,@i_elig_val_id
            ,@i_elig_val_desc
            ,@i_network_id
            ,@i_network_name
            ,@i_rx_network_strategy_id
            ,@i_rx_network_strategy_desc
            ,@i_last_card_date
            ,@i_bill_flag
            ,@i_cob_type
            ,@i_Coverage_Code
            ,@i_paid_thru_date
            ,@i_manual_enrollment
            ,@i_cobra_flag
            ,@i_cobra_ar_type
            ,@i_rate_adj_amt
            ,@i_Class_ID
            ,@i_Salary_Mult
            ,@i_req_vol_amt
            ,@i_apv_vol_amt
            ,@i_orig_apv_vol_amt
            ,@i_Vol_Approval
            ,@i_Monthly_Benefit
            ,@i_Is_Subscriber_Covered
            ,@i_Term_Reason
            ,@i_Term_Reason_Desc
            ,@i_Loop2000GroupID
            ,@i_REFZZMemberID
            ,@i_REF23MemberID
            ,@i_REF6OMemberID
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT
            --,@i_Pay_tol_ID
            --,@i_Pay_tol_Desc
            --,@i_DisplayResults
            --,@return_xml
            --,@i_eob_language
            --,@i_Product_Offering_id
            --,@i_Product_Offering_desc
            --,@i_apply_to_dependents

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @member_id, @ssn, @i_key_7_field, @status, @err_num, @err_msg

        FETCH NEXT FROM MemberCoverage_Cursor
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
             ,@i_effective_date
             ,@i_termination_date
             ,@i_prod_eff_date
             ,@i_default_lob
             ,@i_orig_eff_date
             ,@i_plan_strategy_id
             ,@i_plan_strategy_desc
             ,@i_elig_val_id
             ,@i_elig_val_desc
             ,@i_network_id
             ,@i_network_name
             ,@i_rx_network_strategy_id
             ,@i_rx_network_strategy_desc
             ,@i_last_card_date
             ,@i_bill_flag
             ,@i_cob_type
             ,@i_Coverage_Code
             ,@i_paid_thru_date
             ,@i_manual_enrollment
             ,@i_cobra_flag
             ,@i_cobra_ar_type
             ,@i_rate_adj_amt
             ,@i_Class_ID
             ,@i_Salary_Mult
             ,@i_req_vol_amt
             ,@i_apv_vol_amt
             ,@i_orig_apv_vol_amt
             ,@i_Vol_Approval
             ,@i_Monthly_Benefit
             ,@i_Is_Subscriber_Covered
             ,@i_Term_Reason
             ,@i_Term_Reason_Desc
             ,@i_Loop2000GroupID
             ,@i_REFZZMemberID
             ,@i_REF23MemberID
             ,@i_REF6OMemberID
             ,@o_status
             ,@o_message
             ,@i_Pay_tol_ID
             ,@i_Pay_tol_Desc
             ,@i_DisplayResults
             ,@return_xml
             ,@i_eob_language
             ,@i_Product_Offering_id
             ,@i_Product_Offering_desc
             ,@i_apply_to_dependents
             ,@record_id
             ,@static_gid
	END

CLOSE MemberCoverage_Cursor
DEALLOCATE MemberCoverage_Cursor

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberCoverageDC') IS NOT NULL
	DROP TABLE #MemberCoverageDC

IF OBJECT_ID('tempdb.dbo.#Temp_Elig') IS NOT NULL
	DROP TABLE #Temp_Elig


END
GO