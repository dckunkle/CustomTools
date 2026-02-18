IF OBJECT_ID('dbo.spDCAuto_CreateGroupCoverageAdditionalLOB') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupCoverageAdditionalLOB AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupCoverageAdditionalLOB
Purpose:    Create groupcoverage data from CorderAutomation
Method:     GroupCoverage
Screen GID: 3022
Procedure:  dbo.prEligCoverageModifyWrapper

Date        User            Change
---------------------------------------------------------------------------------------------
12/16/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupCoverageAdditionalLOB '100-Config%', 22, 'GroupCoverage'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupCoverageAdditionalLOB
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

DECLARE @i_entity_name              VARCHAR(50)
       ,@i_key_1_field              VARCHAR(50)
       ,@i_key_2_field              VARCHAR(100)
       ,@i_key_3_field              VARCHAR(50)
       ,@i_key_4_field              VARCHAR(50)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(10)
       ,@i_Date_Time_Modified       VARCHAR(30)
       ,@iUserID                    VARCHAR(25)
       ,@i_effective_date           VARCHAR(50)
       ,@i_termination_date         VARCHAR(50)
       ,@i_default_lob              VARCHAR(10)
       ,@i_orig_eff_date            VARCHAR(20)
       ,@i_plan_strategy_id         VARCHAR(50)
       ,@i_plan_strategy_desc       VARCHAR(50)
       ,@i_Product_Offering_id      VARCHAR(50)
       ,@i_Product_Offering_desc    VARCHAR(150)
       ,@i_elig_val_id              VARCHAR(50)
       ,@i_elig_val_desc            VARCHAR(75)
       ,@i_network_id               VARCHAR(50)
       ,@i_network_name             VARCHAR(50)
       ,@i_rx_network_strategy_id   VARCHAR(50)
       ,@i_rx_network_strategy_desc VARCHAR(100)
       ,@i_Pay_tol_ID               VARCHAR(50)
       ,@i_Pay_tol_Desc             VARCHAR(100)
       ,@i_bill_flag                VARCHAR(50)
       ,@i_cob_type                 VARCHAR(50)
       ,@i_paid_thru_date           VARCHAR(50)
       ,@i_eob_language             VARCHAR(50)
       ,@i_Class_ID                 VARCHAR(50)
       ,@i_req_vol_amt              VARCHAR(50)
       ,@i_apv_vol_amt              VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(255)
       ,@return_xml                 XML
       ,@i_coverage_code            VARCHAR(50)
       ,@i_apply_to_dependents      VARCHAR(50)
       ,@i_user_gid                 INT
       ,@iIsSubscriberCovered       VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupCoverageAdditional') IS NOT NULL
	DROP TABLE #GroupCoverageAdditional

CREATE TABLE #GroupCoverageAdditional
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('Grp_Elig_Coverage')
      ,i_key_1_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field              VARCHAR(100)      DEFAULT('0')
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
      ,i_default_lob              VARCHAR(10)
      ,i_orig_eff_date            VARCHAR(20)
      ,i_plan_strategy_id         VARCHAR(50)       DEFAULT('')
      ,i_plan_strategy_desc       VARCHAR(50)       DEFAULT('')
      ,i_Product_Offering_id      VARCHAR(50)       DEFAULT('')
      ,i_Product_Offering_desc    VARCHAR(150)      DEFAULT('')
      ,i_elig_val_id              VARCHAR(50)       DEFAULT('')
      ,i_elig_val_desc            VARCHAR(75)       DEFAULT('')
      ,i_network_id               VARCHAR(50)       DEFAULT('')
      ,i_network_name             VARCHAR(50)       DEFAULT('')		--DEFAULT('Network')
      ,i_rx_network_strategy_id   VARCHAR(50)       DEFAULT('')
      ,i_rx_network_strategy_desc VARCHAR(100)      DEFAULT('')
      ,i_Pay_tol_ID               VARCHAR(50)       DEFAULT('')
      ,i_Pay_tol_Desc             VARCHAR(100)      DEFAULT('')
      ,i_bill_flag                VARCHAR(50)
      ,i_cob_type                 VARCHAR(50)
      ,i_paid_thru_date           VARCHAR(50)
      ,i_eob_language             VARCHAR(50)
      ,i_Class_ID                 VARCHAR(50)
      ,i_req_vol_amt              VARCHAR(50)
      ,i_apv_vol_amt              VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(255)
      ,return_xml                 XML
      ,i_coverage_code            VARCHAR(50)
      ,i_apply_to_dependents      VARCHAR(50)
      ,i_user_gid                 INT
      ,iIsSubscriberCovered       VARCHAR(50)
      ,record_id                  INT
      ,static_gid                 INT)

IF OBJECT_ID('tempdb.dbo.#GroupCoverageAdditionalPopulate') IS NOT NULL
	DROP TABLE #GroupCoverageAdditionalPopulate

CREATE TABLE #GroupCoverageAdditionalPopulate
      (effective_date			VARCHAR(50)  
      ,termination_date         VARCHAR(50)  
      ,prod_effective_date      VARCHAR(50)  
      ,default_lob              VARCHAR(50)  
      ,orig_eff_date            VARCHAR(50)  
      ,dummy_field3             VARCHAR(25)  
      ,plan_strategy_id         VARCHAR(50)  
      ,plan_strategy_desc       VARCHAR(150)  
      ,elig_validation_id		VARCHAR(50)  
      ,elig_val_description     VARCHAR(100)  
      ,network_search_id        VARCHAR(50)  
      ,network_search_name      VARCHAR(100)  
      ,rx_network_strategy_id   VARCHAR(25)  
      ,rx_network_strategy_desc VARCHAR(100)  
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

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupCoverageAdditional
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_default_lob
      ,i_orig_eff_date
      ,i_plan_strategy_id
      ,i_Product_Offering_id
      ,i_elig_val_id
      ,i_network_id
      ,i_Pay_tol_ID
      ,i_bill_flag
      ,i_cob_type
      ,i_paid_thru_date
      ,i_eob_language
      ,i_Class_ID
      ,i_req_vol_amt
      ,i_apv_vol_amt
      ,record_id
      ,static_gid)
SELECT ISNULL([GroupMatch], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '')
      ,ISNULL([OrigEffectiveDate], '01/01/2017')
      ,ISNULL([PlanStrategyID], '')
      ,ISNULL([ProductOfferID], '')
      ,ISNULL([EligValidationID], '')
      ,ISNULL([SuperNetworkID], '')
      ,ISNULL([PaymentToleranceID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BillFlag]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBType]), 'E')
      ,ISNULL([PayidThruDate], '01/01/1900')
      ,ISNULL([EOBLanguage], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClassID]), '')
      ,ISNULL([RequestVolAmt], '0.00')
      ,ISNULL([ApprovedVolAmt], '0.00')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupEligCoverageAdditionalLob
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupCoverageAdditional
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupCoverage_Cursor CURSOR FOR
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
       ,i_default_lob
       ,i_orig_eff_date
       ,i_plan_strategy_id
       ,i_plan_strategy_desc
       ,i_Product_Offering_id
       ,i_Product_Offering_desc
       ,i_elig_val_id
       ,i_elig_val_desc
       ,i_network_id
       ,i_network_name
       ,i_rx_network_strategy_id
       ,i_rx_network_strategy_desc
       ,i_Pay_tol_ID
       ,i_Pay_tol_Desc
       ,i_bill_flag
       ,i_cob_type
       ,i_paid_thru_date
       ,i_eob_language
       ,i_Class_ID
       ,i_req_vol_amt
       ,i_apv_vol_amt
       ,o_status
       ,o_message
       ,return_xml
       ,i_coverage_code
       ,i_apply_to_dependents
       ,i_user_gid
       ,iIsSubscriberCovered
       ,record_id
       ,static_gid
   FROM #GroupCoverageAdditional

   OPEN GroupCoverage_Cursor
  FETCH NEXT FROM GroupCoverage_Cursor
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
       ,@i_default_lob
       ,@i_orig_eff_date
       ,@i_plan_strategy_id
       ,@i_plan_strategy_desc
       ,@i_Product_Offering_id
       ,@i_Product_Offering_desc
       ,@i_elig_val_id
       ,@i_elig_val_desc
       ,@i_network_id
       ,@i_network_name
       ,@i_rx_network_strategy_id
       ,@i_rx_network_strategy_desc
       ,@i_Pay_tol_ID
       ,@i_Pay_tol_Desc
       ,@i_bill_flag
       ,@i_cob_type
       ,@i_paid_thru_date
       ,@i_eob_language
       ,@i_Class_ID
       ,@i_req_vol_amt
       ,@i_apv_vol_amt
       ,@o_status
       ,@o_message
       ,@return_xml
       ,@i_coverage_code
       ,@i_apply_to_dependents
       ,@i_user_gid
       ,@iIsSubscriberCovered
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the group information to pass to the populate stored procedure
			SELECT @i_key_1_field			= EC.child_gid
				  ,@i_key_2_field			= EC.child_identifier
			      ,@i_key_3_field			= EC.parent_gid
				  ,@i_key_4_field			= EC.parent_identifier
				  ,@i_key_5_field			= CONVERT(VARCHAR(10), EC.effective_date, 101)
				  ,@i_key_6_field			= CONVERT(VARCHAR(10), EC.termination_date, 101)
				  ,@i_key_7_field			= EC.group_gid
				  ,@i_key_8_field			= ''
				  ,@i_key_9_field			= EC.default_lob
				  ,@i_key_10_field			= G.group_id
			  FROM Groups					G
			  JOIN Eligibility_Coverage		EC
			    ON G.group_gid				= EC.child_gid
			 WHERE G.group_id				= @SearchID
			   AND G.record_status			= 'A'
			   AND EC.record_status			= 'A'

			--SELECT   @i_key_1_field
			--		,@i_key_2_field
			--		,@i_key_3_field
			--		,@i_key_4_field
			--		,@i_key_5_field
			--		,@i_key_6_field
			--		,@i_key_7_field
			--		,@i_key_8_field
			--		,@i_key_9_field
			--		,@i_key_10_field

			-- Now get the necessary descriptions
			SELECT @i_plan_strategy_desc		= dbo.fnDCAuto_GetPlanStrategyDescriptionFromID(@i_plan_strategy_id)
			      ,@i_elig_val_desc				= dbo.fnDCAuto_GetEligibilityValidationDescriptionFromID(@i_elig_val_id)
				  ,@i_network_name				= dbo.fnDCAuto_GetNetworkDescriptionFromID(@i_network_id)
				  ,@i_rx_network_strategy_desc	= ' '
 
			EXEC dbo.prEligCoverageModifyWrapper
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
				,@i_effective_date
				,@i_termination_date
				,@i_default_lob
				,@i_orig_eff_date
				,@i_plan_strategy_id
				,@i_plan_strategy_desc
				,@i_Product_Offering_id
				,@i_Product_Offering_desc
				,@i_elig_val_id
				,@i_elig_val_desc
				,@i_network_id
				,@i_network_name
				,@i_rx_network_strategy_id
				,@i_rx_network_strategy_desc
				,@i_Pay_tol_ID
				,@i_Pay_tol_Desc
				,@i_bill_flag
				,@i_cob_type
				,@i_paid_thru_date
				,@i_eob_language
				,@i_Class_ID
				,@i_req_vol_amt
				,@i_apv_vol_amt
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT
				--,@return_xml
				--,@i_coverage_code
				--,@i_apply_to_dependents
				--,@i_user_gid
				--,@iIsSubscriberCovered

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_plan_strategy_id, @i_Product_Offering_id, @status, @err_num, @err_msg

        FETCH NEXT FROM GroupCoverage_Cursor
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
             ,@i_default_lob
             ,@i_orig_eff_date
             ,@i_plan_strategy_id
             ,@i_plan_strategy_desc
             ,@i_Product_Offering_id
             ,@i_Product_Offering_desc
             ,@i_elig_val_id
             ,@i_elig_val_desc
             ,@i_network_id
             ,@i_network_name
             ,@i_rx_network_strategy_id
             ,@i_rx_network_strategy_desc
             ,@i_Pay_tol_ID
             ,@i_Pay_tol_Desc
             ,@i_bill_flag
             ,@i_cob_type
             ,@i_paid_thru_date
             ,@i_eob_language
             ,@i_Class_ID
             ,@i_req_vol_amt
             ,@i_apv_vol_amt
             ,@o_status
             ,@o_message
             ,@return_xml
             ,@i_coverage_code
             ,@i_apply_to_dependents
             ,@i_user_gid
             ,@iIsSubscriberCovered
             ,@record_id
             ,@static_gid
	END

CLOSE GroupCoverage_Cursor
DEALLOCATE GroupCoverage_Cursor

END
GO