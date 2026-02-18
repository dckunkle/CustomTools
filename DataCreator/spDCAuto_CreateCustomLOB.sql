IF OBJECT_ID('dbo.spDCAuto_CreateCustomLOB') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCustomLOB AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCustomLOB
Purpose:    Read data from CoreAutomation and create the test data

Date        User            Change
---------------------------------------------------------------------------------------------
10/17/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCustomLOB 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCustomLOB
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

DECLARE	@i_entity_name			VARCHAR(50)		
       ,@i_key_group_id			VARCHAR(50)		
       ,@i_key_user_lob			VARCHAR(50)		
       ,@i_key_3_field			VARCHAR(50)		
       ,@i_key_4_field			VARCHAR(50)		
       ,@i_key_5_field			VARCHAR(50)		
       ,@i_key_6_field			VARCHAR(50)		
       ,@i_key_7_field			VARCHAR(50)		
       ,@i_key_8_field			VARCHAR(50)		
       ,@i_key_9_field			VARCHAR(50)		
       ,@i_key_10_field			VARCHAR(50)		
       ,@i_action				VARCHAR(10)		
       ,@i_Date_Time_Modified	VARCHAR(30)
       ,@iUserid				VARCHAR(25)		
       ,@i_group_id				VARCHAR(50)
       ,@i_user_lob				VARCHAR(6)
       ,@i_user_lob_desc		VARCHAR(50)
       ,@i_default_lob			CHAR(1)
       ,@i_produce_sum			CHAR(1)
       ,@i_produce_cert			CHAR(1)
       ,@i_produce_policy		CHAR(1)
       ,@i_default_class		VARCHAR(25)
       ,@i_def_class_desc		VARCHAR(50)		
       ,@i_pcp_required			CHAR(1)
       ,@i_cost_required		CHAR(1)
       ,@i_volume_based			CHAR(1)
       ,@i_rate_divisor			CHAR(1)
       ,@i_Enforce_Vol_Prec		CHAR(1)
       ,@i_rounding				CHAR(1)
       ,@i_spouse_based			CHAR(1)
       ,@i_beneficiary_all		CHAR(1)
       ,@i_prompt_pcp_change	CHAR(1)
       ,@i_payment_tol_id		VARCHAR(30)
       ,@i_payment_tol_desc		VARCHAR(100)	
       ,@iNPPParamID			VARCHAR(25)
       ,@iNPPParamDesc			VARCHAR(50)		
       ,@Active_COBRA_Contract	CHAR(1)
       ,@cobra_equivalent_lob	VARCHAR(6)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CustomLOB') IS NOT NULL
	DROP TABLE #CustomLOB

CREATE TABLE #CustomLOB
      (i_entity_name			VARCHAR(50)		DEFAULT('Custom_LOB')
      ,i_key_group_id			VARCHAR(50)		DEFAULT('0')
      ,i_key_user_lob			VARCHAR(50)		DEFAULT('0')
      ,i_key_3_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_4_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_5_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_6_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_7_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_8_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_9_field			VARCHAR(50)		DEFAULT('0')
      ,i_key_10_field			VARCHAR(50)		DEFAULT('0')
      ,i_action					VARCHAR(10)		DEFAULT('ADD')
      ,i_Date_Time_Modified		VARCHAR(30)		DEFAULT('')
      ,iUserid					VARCHAR(25)		DEFAULT('')
      ,i_group_id				VARCHAR(50)
      ,i_user_lob				VARCHAR(20)		
      ,i_user_lob_desc			VARCHAR(100)	
      ,i_default_lob			VARCHAR(50)
      ,i_produce_sum			VARCHAR(20)		
      ,i_produce_cert			VARCHAR(20)		
      ,i_produce_policy			VARCHAR(20)		
      ,i_default_class			VARCHAR(25)
      ,i_def_class_desc			VARCHAR(50)		DEFAULT('')	
      ,i_pcp_required			VARCHAR(30)		
      ,i_cost_required			VARCHAR(20)		
      ,i_volume_based			VARCHAR(20)		
      ,i_rate_divisor			VARCHAR(20)		
      ,i_Enforce_Vol_Prec		VARCHAR(20)		
      ,i_rounding				VARCHAR(30)		
      ,i_spouse_based			VARCHAR(50)		
      ,i_beneficiary_all		VARCHAR(20)		
      ,i_prompt_pcp_change		VARCHAR(50)		
      ,i_payment_tol_id			VARCHAR(50)
      ,i_payment_tol_desc		VARCHAR(100)	DEFAULT('')	
      ,iNPPParamID				VARCHAR(50)
      ,iNPPParamDesc			VARCHAR(50)		DEFAULT('')		
      ,Active_COBRA_Contract	VARCHAR(20)		
      ,cobra_equivalent_lob		VARCHAR(30)
	  ,record_id				INT)

--*************************************************************************************************
-- Populate the table with data to be created
--*************************************************************************************************
INSERT INTO #CustomLOB
      (i_group_id
	  ,i_user_lob
	  ,i_user_lob_desc
	  ,i_default_lob
	  ,i_produce_sum
	  ,i_produce_cert
	  ,i_produce_policy
	  ,i_default_class
	  ,i_pcp_required
	  ,i_cost_required
	  ,i_volume_based
	  ,i_rate_divisor
	  ,i_Enforce_Vol_Prec
	  ,i_rounding
	  ,i_spouse_based
	  ,i_beneficiary_all
	  ,i_prompt_pcp_change
	  ,i_payment_tol_id
	  ,iNPPParamID
	  ,Active_COBRA_Contract
	  ,cobra_equivalent_lob
	  ,record_id)
SELECT ISNULL(GroupID,'')
	  ,ISNULL([*LOB],'')
	  ,ISNULL([*LOBDesc],'')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(SystemLOB),'D')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProducePlanSummaries),'Y')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProduceCertificates),'Y')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProducePolicies),'Y')
	  ,ISNULL(DefaultReportingClass,'')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(PCPRequired),'N')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(SubmittedCostReq),'Y')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(VolumeBasedRating),'N')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(RateDivisor),'1')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(EnforceVolumePrecision),'Y')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(RoundingPrecision),'A')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(AgeRatingBasis),'N')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(BeneficiariesAllowed),'N')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(PromptPCPChange),'N')
	  ,ISNULL(PaymentToleranceID,'')
	  ,ISNULL(NonPaymentPaamDefID,'')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ActiveCOBRAContract),'N')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(COBRAEquivalentLOB),'')
	  ,RecordID
  FROM COREAUTO.CoreAutomation.dbo.TD_CustomLOB
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CustomLOB
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE LOB_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_key_group_id
       ,i_key_user_lob
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
       ,iUserid
       ,i_group_id
       ,i_user_lob
       ,i_user_lob_desc
       ,i_default_lob
       ,i_produce_sum
       ,i_produce_cert
       ,i_produce_policy
       ,i_default_class
       ,i_def_class_desc
       ,i_pcp_required
       ,i_cost_required
       ,i_volume_based
       ,i_rate_divisor
       ,i_Enforce_Vol_Prec
       ,i_rounding
       ,i_spouse_based
       ,i_beneficiary_all
       ,i_prompt_pcp_change
       ,i_payment_tol_id
       ,i_payment_tol_desc
       ,iNPPParamID
       ,iNPPParamDesc
       ,Active_COBRA_Contract
       ,cobra_equivalent_lob
	   ,record_id
   FROM #CustomLOB
  ORDER BY i_user_lob ASC

   OPEN LOB_Cursor
  FETCH NEXT FROM LOB_Cursor
   INTO @i_entity_name
       ,@i_key_group_id
       ,@i_key_user_lob
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
       ,@iUserid
       ,@i_group_id
       ,@i_user_lob
       ,@i_user_lob_desc
       ,@i_default_lob
       ,@i_produce_sum
       ,@i_produce_cert
       ,@i_produce_policy
       ,@i_default_class
       ,@i_def_class_desc
       ,@i_pcp_required
       ,@i_cost_required
       ,@i_volume_based
       ,@i_rate_divisor
       ,@i_Enforce_Vol_Prec
       ,@i_rounding
       ,@i_spouse_based
       ,@i_beneficiary_all
       ,@i_prompt_pcp_change
       ,@i_payment_tol_id
       ,@i_payment_tol_desc
       ,@iNPPParamID
       ,@iNPPParamDesc
       ,@Active_COBRA_Contract
       ,@cobra_equivalent_lob
	   ,@record_id

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC prGroupCustomLOBAddModify 
			 @i_entity_name
			,@i_key_group_id
			,@i_key_user_lob
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
			,@iUserid
			,@i_group_id
			,@i_user_lob
			,@i_user_lob_desc
			,@i_default_lob
			,@i_produce_sum
			,@i_produce_cert
			,@i_produce_policy
			,@i_default_class
			,@i_def_class_desc
			,@i_pcp_required
			,@i_cost_required
			,@i_volume_based
			,@i_rate_divisor
			,@i_Enforce_Vol_Prec
			,@i_rounding
			,@i_spouse_based
			,@i_beneficiary_all
			,@i_prompt_pcp_change
			,@i_payment_tol_id
			,@i_payment_tol_desc
			,@iNPPParamID
			,@iNPPParamDesc
			,@Active_COBRA_Contract
			,@cobra_equivalent_lob
			,@o_status				= @err_num	OUTPUT
			,@o_message				= @err_msg	OUTPUT

		-- Log details
		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_user_lob, @i_user_lob_desc, @i_default_lob, @status, @err_num, @err_msg

		FETCH NEXT FROM LOB_Cursor
		 INTO @i_entity_name
			 ,@i_key_group_id
			 ,@i_key_user_lob
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
			 ,@iUserid
			 ,@i_group_id
			 ,@i_user_lob
			 ,@i_user_lob_desc
			 ,@i_default_lob
			 ,@i_produce_sum
			 ,@i_produce_cert
			 ,@i_produce_policy
			 ,@i_default_class
			 ,@i_def_class_desc
			 ,@i_pcp_required
			 ,@i_cost_required
			 ,@i_volume_based
			 ,@i_rate_divisor
			 ,@i_Enforce_Vol_Prec
			 ,@i_rounding
			 ,@i_spouse_based
			 ,@i_beneficiary_all
			 ,@i_prompt_pcp_change
			 ,@i_payment_tol_id
			 ,@i_payment_tol_desc
			 ,@iNPPParamID
			 ,@iNPPParamDesc
			 ,@Active_COBRA_Contract
			 ,@cobra_equivalent_lob
			 ,@record_id
 
	END

CLOSE LOB_Cursor
DEALLOCATE LOB_Cursor

END
GO