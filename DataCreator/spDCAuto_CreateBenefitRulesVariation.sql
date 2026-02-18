IF OBJECT_ID('dbo.spDCAuto_CreateBenefitRulesVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBenefitRulesVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBenefitRulesVariation
Purpose:    Create benefitrulesvariation data from CorderAutomation

Screen:     66
Method:     BenefitRulesVariation
Procedure:  dbo.prBenefitPlanAdd 
Entity:     Benefit_Plan

Date        User            Change
---------------------------------------------------------------------------------------------
04/21/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBenefitRulesVariation 'RFF-Int-Config-1%', 22, 'RFF-Int-Config-1000','BenefitRulesVariation','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBenefitRulesVariation
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

DECLARE @i_Entity_Name          VARCHAR(50)
       ,@i_Rule_gid             VARCHAR(50)
       ,@i_Old_Effective_date   VARCHAR(50)
       ,@i_Old_Termination_Date VARCHAR(50)
       ,@i_Rule_sid             VARCHAR(50)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_Date_Time_Modified   VARCHAR(50)
       ,@iUserID                VARCHAR(25)
       ,@iBenefitRuleID         VARCHAR(50)
       ,@iBenefitRuleDesc       VARCHAR(100)
       ,@i_Effective_Date       VARCHAR(50)
       ,@i_Termination_Date     VARCHAR(50)
       ,@i_Accum_Bene_Periods   VARCHAR(50)
       ,@i_Accum_Num_Periods    VARCHAR(50)
       ,@i_Start_Month          VARCHAR(50)
       ,@i_Start_Day            VARCHAR(50)
       ,@i_Start_Date_option    VARCHAR(50)
       ,@i_Benefit_Type         VARCHAR(50)
       ,@i_Dollar_Amount        VARCHAR(50)
       ,@i_Limit_Amount         VARCHAR(50)
       ,@i_Bonus_Amount         VARCHAR(50)
       ,@i_One_Time             VARCHAR(50)
       ,@i_Ind_Met_Rule         VARCHAR(50)
       ,@i_Ind_Met_Count        INT
       ,@i_Wait_Period          VARCHAR(50)
       ,@i_Wait_Num_Periods     VARCHAR(50)
       ,@i_Rule_Action          VARCHAR(50)
       ,@i_Rule_Priority        VARCHAR(50)
       ,@iIncludeCopay          VARCHAR(50)
       ,@i_Carry_Forward        VARCHAR(50)
       ,@iCarryForwardLimit     VARCHAR(50)
       ,@iCarryForwardUnit      VARCHAR(50)
       ,@iReimburseFlag         VARCHAR(50)
       ,@iApplyToIncident       VARCHAR(50)
       ,@iAccidentLimitAmount   VARCHAR(50)
       ,@iSameProvider          VARCHAR(50)
       ,@i_pro_pol_1_id         VARCHAR(50)
       ,@i_pro_pol_1_desc       VARCHAR(50)
       ,@i_pro_pol_2_id         VARCHAR(50)
       ,@i_pro_pol_2_desc       VARCHAR(50)
       ,@i_hp_deductible        VARCHAR(50)
       ,@i_hp_percentage        VARCHAR(50)
       ,@oStatus                INT
       ,@oMessage               VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BenefitRulesVariation') IS NOT NULL
	DROP TABLE #BenefitRulesVariation

CREATE TABLE #BenefitRulesVariation
      (SearchID               VARCHAR(200)
      ,i_Entity_Name          VARCHAR(50)       DEFAULT('Benefit_Plan')
      ,i_Rule_gid             VARCHAR(50)       DEFAULT('0')
      ,i_Old_Effective_date   VARCHAR(50)       DEFAULT('0')
      ,i_Old_Termination_Date VARCHAR(50)       DEFAULT('0')
      ,i_Rule_sid             VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified   VARCHAR(50)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,iBenefitRuleID         VARCHAR(50)
      ,iBenefitRuleDesc       VARCHAR(100)
      ,i_Effective_Date       VARCHAR(50)
      ,i_Termination_Date     VARCHAR(50)
      ,i_Accum_Bene_Periods   VARCHAR(50)
      ,i_Accum_Num_Periods    VARCHAR(50)
      ,i_Start_Month          VARCHAR(50)
      ,i_Start_Day            VARCHAR(50)
      ,i_Start_Date_option    VARCHAR(50)
      ,i_Benefit_Type         VARCHAR(50)
      ,i_Dollar_Amount        VARCHAR(50)
      ,i_Limit_Amount         VARCHAR(50)
      ,i_Bonus_Amount         VARCHAR(50)
      ,i_One_Time             VARCHAR(50)
      ,i_Ind_Met_Rule         VARCHAR(50)
      ,i_Ind_Met_Count        INT
      ,i_Wait_Period          VARCHAR(50)
      ,i_Wait_Num_Periods     VARCHAR(50)
      ,i_Rule_Action          VARCHAR(50)
      ,i_Rule_Priority        VARCHAR(50)
      ,iIncludeCopay          VARCHAR(50)
      ,i_Carry_Forward        VARCHAR(50)
      ,iCarryForwardLimit     VARCHAR(50)
      ,iCarryForwardUnit      VARCHAR(50)
      ,iReimburseFlag         VARCHAR(50)
      ,iApplyToIncident       VARCHAR(50)
      ,iAccidentLimitAmount   VARCHAR(50)
      ,iSameProvider          VARCHAR(50)
      ,i_pro_pol_1_id         VARCHAR(50)
      ,i_pro_pol_1_desc       VARCHAR(50)
      ,i_pro_pol_2_id         VARCHAR(50)
      ,i_pro_pol_2_desc       VARCHAR(50)
      ,i_hp_deductible        VARCHAR(50)
      ,i_hp_percentage        VARCHAR(50)
      ,oStatus                INT
      ,oMessage               VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BenefitRulesVariation
          (SearchID
          ,i_Effective_Date
          ,i_Termination_Date
          ,i_Accum_Bene_Periods
          ,i_Accum_Num_Periods
          ,i_Start_Month
          ,i_Start_Day
          ,i_Start_Date_option
          ,i_Benefit_Type
          ,i_Dollar_Amount
          ,i_Limit_Amount
          ,i_Bonus_Amount
          ,i_One_Time
          ,i_Ind_Met_Rule
          ,i_Ind_Met_Count
          ,i_Wait_Period
          ,i_Wait_Num_Periods
          ,i_Rule_Action
          ,i_Rule_Priority
          ,iIncludeCopay
          ,i_Carry_Forward
          ,iCarryForwardLimit
          ,iCarryForwardUnit
          ,iReimburseFlag
          ,iApplyToIncident
          ,iAccidentLimitAmount
          ,iSameProvider
          ,i_pro_pol_1_id
          ,i_pro_pol_2_id
          ,i_hp_deductible
          ,i_hp_percentage
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL([Common_*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
		  ,ISNULL([Common_*TerminationDate], '12/31/9999')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AccBenePeriod]), 'Y')
		  ,ISNULL([Common_AccNumPeriods], '1')
		  ,ISNULL([Common_AccBeneStartMonth], '0')
		  ,ISNULL([Common_AccBeneStartDay], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_StartDateOption]), 'C')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_BenefitType]), '11')
		  ,ISNULL([Common_DollarAmount], '0.00')
		  ,ISNULL([Common_LimitAmount], '0')
		  ,ISNULL([Common_AdditionalMaxAmount], '0.00')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_LimittoOneTime]), 'N')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_FamilyMetRule]), '')
		  ,ISNULL([Common_MetCount], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_WaitPeriod]), 'N')
		  ,ISNULL([Common_WaitNumPeriods], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_RuleAction]), 'A')
		  ,ISNULL([Common_RulePriority], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MonetaryInclusions]), 'A')
		  ,ISNULL([Common_CarryForwardMonths], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CarryForwardLimitBasis]), 'N')
		  ,ISNULL([Common_CarryForwardLimitUnits], '0.00')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ReimbRemainMaxtoPatient]), 'N')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ApplytoIncidents]), 'N')
		  ,ISNULL([Common_AccidentLimitAmount], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SameProvider]), 'N')
		  ,ISNULL([Common_RemarkCode1], '')
		  ,ISNULL([Common_RemarkCode2], '')
		  ,ISNULL([info_HPDeductible], '0.00')
		  ,ISNULL([info_HPPercentage], '0')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BenefitRulesVariation
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BenefitRulesVariation
       SET iUserID  = @user


END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BenefitRulesVariation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_Name
       ,i_Rule_gid
       ,i_Old_Effective_date
       ,i_Old_Termination_Date
       ,i_Rule_sid
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,iBenefitRuleID
       ,iBenefitRuleDesc
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Accum_Bene_Periods
       ,i_Accum_Num_Periods
       ,i_Start_Month
       ,i_Start_Day
       ,i_Start_Date_option
       ,i_Benefit_Type
       ,i_Dollar_Amount
       ,i_Limit_Amount
       ,i_Bonus_Amount
       ,i_One_Time
       ,i_Ind_Met_Rule
       ,i_Ind_Met_Count
       ,i_Wait_Period
       ,i_Wait_Num_Periods
       ,i_Rule_Action
       ,i_Rule_Priority
       ,iIncludeCopay
       ,i_Carry_Forward
       ,iCarryForwardLimit
       ,iCarryForwardUnit
       ,iReimburseFlag
       ,iApplyToIncident
       ,iAccidentLimitAmount
       ,iSameProvider
       ,i_pro_pol_1_id
       ,i_pro_pol_1_desc
       ,i_pro_pol_2_id
       ,i_pro_pol_2_desc
       ,i_hp_deductible
       ,i_hp_percentage
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #BenefitRulesVariation

   OPEN BenefitRulesVariation_Cursor
  FETCH NEXT FROM BenefitRulesVariation_Cursor
   INTO @SearchID
       ,@i_Entity_Name
       ,@i_Rule_gid
       ,@i_Old_Effective_date
       ,@i_Old_Termination_Date
       ,@i_Rule_sid
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@iBenefitRuleID
       ,@iBenefitRuleDesc
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Accum_Bene_Periods
       ,@i_Accum_Num_Periods
       ,@i_Start_Month
       ,@i_Start_Day
       ,@i_Start_Date_option
       ,@i_Benefit_Type
       ,@i_Dollar_Amount
       ,@i_Limit_Amount
       ,@i_Bonus_Amount
       ,@i_One_Time
       ,@i_Ind_Met_Rule
       ,@i_Ind_Met_Count
       ,@i_Wait_Period
       ,@i_Wait_Num_Periods
       ,@i_Rule_Action
       ,@i_Rule_Priority
       ,@iIncludeCopay
       ,@i_Carry_Forward
       ,@iCarryForwardLimit
       ,@iCarryForwardUnit
       ,@iReimburseFlag
       ,@iApplyToIncident
       ,@iAccidentLimitAmount
       ,@iSameProvider
       ,@i_pro_pol_1_id
       ,@i_pro_pol_1_desc
       ,@i_pro_pol_2_id
       ,@i_pro_pol_2_desc
       ,@i_hp_deductible
       ,@i_hp_percentage
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the Benefit Rule
			SELECT @i_Rule_gid				= EN.entity_gid
			      ,@iBenefitRuleID			= EN.entity_user_id
				  ,@iBenefitRuleDesc		= EN.entity_user_name
			  FROM dbo.Entity_Names			EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_user_id		= @SearchID
			   AND EN.entity_identifier		= 'BENEFIT_PLAN'

			EXEC dbo.prBenefitPlanAdd 
                 @i_Entity_Name
                ,@i_Rule_gid
                ,@i_Old_Effective_date
                ,@i_Old_Termination_Date
                ,@i_Rule_sid
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@iBenefitRuleID
                ,@iBenefitRuleDesc
                ,@i_Effective_Date
                ,@i_Termination_Date
                ,@i_Accum_Bene_Periods
                ,@i_Accum_Num_Periods
                ,@i_Start_Month
                ,@i_Start_Day
                ,@i_Start_Date_option
                ,@i_Benefit_Type
                ,@i_Dollar_Amount
                ,@i_Limit_Amount
                ,@i_Bonus_Amount
                ,@i_One_Time
                ,@i_Ind_Met_Rule
                ,@i_Ind_Met_Count
                ,@i_Wait_Period
                ,@i_Wait_Num_Periods
                ,@i_Rule_Action
                ,@i_Rule_Priority
                ,@iIncludeCopay
                ,@i_Carry_Forward
                ,@iCarryForwardLimit
                ,@iCarryForwardUnit
                ,@iReimburseFlag
                ,@iApplyToIncident
                ,@iAccidentLimitAmount
                ,@iSameProvider
                ,@i_pro_pol_1_id
                ,@i_pro_pol_1_desc
                ,@i_pro_pol_2_id
                ,@i_pro_pol_2_desc
                ,@i_hp_deductible
                ,@i_hp_percentage
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iBenefitRuleID, @i_Effective_Date, @i_Benefit_Type, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BenefitRulesVariation_Cursor
         INTO @SearchID
             ,@i_Entity_Name
             ,@i_Rule_gid
             ,@i_Old_Effective_date
             ,@i_Old_Termination_Date
             ,@i_Rule_sid
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@iBenefitRuleID
             ,@iBenefitRuleDesc
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Accum_Bene_Periods
             ,@i_Accum_Num_Periods
             ,@i_Start_Month
             ,@i_Start_Day
             ,@i_Start_Date_option
             ,@i_Benefit_Type
             ,@i_Dollar_Amount
             ,@i_Limit_Amount
             ,@i_Bonus_Amount
             ,@i_One_Time
             ,@i_Ind_Met_Rule
             ,@i_Ind_Met_Count
             ,@i_Wait_Period
             ,@i_Wait_Num_Periods
             ,@i_Rule_Action
             ,@i_Rule_Priority
             ,@iIncludeCopay
             ,@i_Carry_Forward
             ,@iCarryForwardLimit
             ,@iCarryForwardUnit
             ,@iReimburseFlag
             ,@iApplyToIncident
             ,@iAccidentLimitAmount
             ,@iSameProvider
             ,@i_pro_pol_1_id
             ,@i_pro_pol_1_desc
             ,@i_pro_pol_2_id
             ,@i_pro_pol_2_desc
             ,@i_hp_deductible
             ,@i_hp_percentage
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE BenefitRulesVariation_Cursor
DEALLOCATE BenefitRulesVariation_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BenefitRulesVariation') IS NOT NULL
	DROP TABLE #BenefitRulesVariation

END
GO

