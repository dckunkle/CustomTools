IF OBJECT_ID('dbo.spDCAuto_CreateCodeStepTherapySubmittedCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeStepTherapySubmittedCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeStepTherapySubmittedCodes
Purpose:    Create codesteptherapysubmittedcodes data from CorderAutomation
Method:     CodeStepTherapySubmittedCodes
Screen GID: 43
Procedure:  dbo.prProcStepTherapyAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeStepTherapySubmittedCodes '100-Config%', 22, 'CodeStepTherapySubmittedCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeStepTherapySubmittedCodes
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

DECLARE @i_entity_name               VARCHAR(50)
       ,@i_Step_therapy_gid          VARCHAR(50)
       ,@i_old_effective_date        VARCHAR(50)
       ,@i_old_termination_date      VARCHAR(50)
       ,@i_old_procedure_id          VARCHAR(50)
       ,@i_old_priority              VARCHAR(50)
       ,@i_key_6_field               VARCHAR(50)
       ,@i_key_7_field               VARCHAR(50)
       ,@i_key_8_field               VARCHAR(50)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_Step_Therapy_SID          VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_date_time_modified        VARCHAR(30)
       ,@iUserID                     VARCHAR(25)
       ,@iImportStepTherapyID        VARCHAR(50)
       ,@iImportStepTherapyDesc      VARCHAR(50)
       ,@iEffective_Date             VARCHAR(50)
       ,@iTermination_Date           VARCHAR(50)
       ,@iSub_Code_ID                VARCHAR(50)
       ,@iSub_Code_Desc              VARCHAR(300)
       ,@iSub_List_Group_ID          VARCHAR(50)
       ,@iSub_List_Group_Desc        VARCHAR(50)
       ,@iAgeCalcUnit                VARCHAR(50)
       ,@iAge_Calc_Option            VARCHAR(50)
       ,@iMinimum_Age_Range          INT
       ,@iMaximum_Age_Range          INT
       ,@iDiagnosis_Grouper          VARCHAR(50)
       ,@iDiagnosis_Validation_Logic VARCHAR(50)
       ,@iUse_Member_Diagnosis       VARCHAR(50)
       ,@iDiagnosis_Validation_ID    VARCHAR(50)
       ,@iDiagnosis_Val_Desc         VARCHAR(50)
       ,@iSub_POS_ID                 VARCHAR(50)
       ,@iSub_POS_Desc               VARCHAR(50)
       ,@iPOSListID                  VARCHAR(50)
       ,@iPOSListDesc                VARCHAR(50)
       ,@iModifier                   VARCHAR(50)
       ,@iTypeOfBill                 VARCHAR(50)
       ,@iTOBListID                  VARCHAR(50)
       ,@iTOBListDesc                VARCHAR(50)
       ,@iPriority                   INT
       ,@iTime_Period                VARCHAR(50)
       ,@iDateOption                 VARCHAR(50)
       ,@iSvcDateRestrict            VARCHAR(50)
       ,@iMin_Number_of_Periods      INT
       ,@iMax_Number_of_Periods      INT
       ,@iCode_List_Group_ID         VARCHAR(50)
       ,@iCode_List_Group_Desc       VARCHAR(50)
       ,@iHistFFOption               VARCHAR(50)
       ,@iDeny_Flag                  VARCHAR(50)
       ,@iSame_Area                  VARCHAR(50)
       ,@iStatus_of_Hist_Claim       VARCHAR(50)
       ,@iSame_Diagnosis             VARCHAR(50)
       ,@iSame_POS                   VARCHAR(50)
       ,@iSame_MOD                   VARCHAR(50)
       ,@iSame_TOB                   VARCHAR(50)
       ,@iTooth_Type_In              VARCHAR(50)
       ,@iTooth_Type_Out             VARCHAR(50)
       ,@iSame_Provider              VARCHAR(50)
       ,@iSpecialty                  VARCHAR(50)
       ,@iRemark_Code                VARCHAR(50)
       ,@iRemark_Desc                VARCHAR(490)
       ,@iRemark_Code_2              VARCHAR(50)
       ,@iRemark_Desc_2              VARCHAR(490)
       ,@iAction_Code                VARCHAR(50)
       ,@iCode_Desc                  VARCHAR(300)
       ,@iCode_Rule_ID               VARCHAR(50)
       ,@iCode_Rule_Desc             VARCHAR(50)
       ,@i_domain_rule_id            VARCHAR(50)
       ,@i_domain_rule_desc          VARCHAR(100)
       ,@i_domain_rule_priority      VARCHAR(50)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(255)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeStepTherapySubmittedCodes') IS NOT NULL
	DROP TABLE #CodeStepTherapySubmittedCodes

CREATE TABLE #CodeStepTherapySubmittedCodes
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Proc_Step_Therapy')
      ,i_Step_therapy_gid          VARCHAR(50)       DEFAULT('0')
      ,i_old_effective_date        VARCHAR(50)       DEFAULT('0')
      ,i_old_termination_date      VARCHAR(50)       DEFAULT('0')
      ,i_old_procedure_id          VARCHAR(50)       DEFAULT('0')
      ,i_old_priority              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_Step_Therapy_SID          VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified        VARCHAR(30)       DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,iImportStepTherapyID        VARCHAR(50)
      ,iImportStepTherapyDesc      VARCHAR(50)
      ,iEffective_Date             VARCHAR(50)
      ,iTermination_Date           VARCHAR(50)
      ,iSub_Code_ID                VARCHAR(50)
      ,iSub_Code_Desc              VARCHAR(300)
      ,iSub_List_Group_ID          VARCHAR(50)
      ,iSub_List_Group_Desc        VARCHAR(50)
      ,iAgeCalcUnit                VARCHAR(50)
      ,iAge_Calc_Option            VARCHAR(50)
      ,iMinimum_Age_Range          INT
      ,iMaximum_Age_Range          INT
      ,iDiagnosis_Grouper          VARCHAR(50)
      ,iDiagnosis_Validation_Logic VARCHAR(50)
      ,iUse_Member_Diagnosis       VARCHAR(50)
      ,iDiagnosis_Validation_ID    VARCHAR(50)
      ,iDiagnosis_Val_Desc         VARCHAR(50)
      ,iSub_POS_ID                 VARCHAR(50)
      ,iSub_POS_Desc               VARCHAR(50)
      ,iPOSListID                  VARCHAR(50)
      ,iPOSListDesc                VARCHAR(50)
      ,iModifier                   VARCHAR(50)
      ,iTypeOfBill                 VARCHAR(50)
      ,iTOBListID                  VARCHAR(50)
      ,iTOBListDesc                VARCHAR(50)
      ,iPriority                   INT
      ,iTime_Period                VARCHAR(50)
      ,iDateOption                 VARCHAR(50)
      ,iSvcDateRestrict            VARCHAR(50)
      ,iMin_Number_of_Periods      INT
      ,iMax_Number_of_Periods      INT
      ,iCode_List_Group_ID         VARCHAR(50)
      ,iCode_List_Group_Desc       VARCHAR(50)
      ,iHistFFOption               VARCHAR(50)
      ,iDeny_Flag                  VARCHAR(50)
      ,iSame_Area                  VARCHAR(50)
      ,iStatus_of_Hist_Claim       VARCHAR(50)
      ,iSame_Diagnosis             VARCHAR(50)
      ,iSame_POS                   VARCHAR(50)
      ,iSame_MOD                   VARCHAR(50)
      ,iSame_TOB                   VARCHAR(50)
      ,iTooth_Type_In              VARCHAR(50)
      ,iTooth_Type_Out             VARCHAR(50)
      ,iSame_Provider              VARCHAR(50)
      ,iSpecialty                  VARCHAR(50)
      ,iRemark_Code                VARCHAR(50)
      ,iRemark_Desc                VARCHAR(490)
      ,iRemark_Code_2              VARCHAR(50)
      ,iRemark_Desc_2              VARCHAR(490)
      ,iAction_Code                VARCHAR(50)
      ,iCode_Desc                  VARCHAR(300)
      ,iCode_Rule_ID               VARCHAR(50)
      ,iCode_Rule_Desc             VARCHAR(50)
      ,i_domain_rule_id            VARCHAR(50)
      ,i_domain_rule_desc          VARCHAR(100)
      ,i_domain_rule_priority      VARCHAR(50)
      ,o_status                    INT
      ,o_message                   VARCHAR(255)
      ,record_id                   INT
      ,static_gid                  INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeStepTherapySubmittedCodes
      (SearchID
      ,iEffective_Date
      ,iTermination_Date
      ,iSub_Code_ID
      ,iSub_List_Group_ID
      ,iAgeCalcUnit
      ,iAge_Calc_Option
      ,iMinimum_Age_Range
      ,iMaximum_Age_Range
      ,iDiagnosis_Grouper
      ,iDiagnosis_Validation_Logic
      ,iUse_Member_Diagnosis
      ,iDiagnosis_Validation_ID
      ,iSub_POS_ID
      ,iPOSListID
      ,iModifier
      ,iTypeOfBill
      ,iTOBListID
      ,iPriority
      ,iTime_Period
      ,iDateOption
      ,iSvcDateRestrict
      ,iMin_Number_of_Periods
      ,iMax_Number_of_Periods
      ,iCode_List_Group_ID
      ,iDeny_Flag
      ,iSame_Area
      ,iStatus_of_Hist_Claim
      ,iSame_Diagnosis
      ,iSame_POS
      ,iSame_MOD
      ,iSame_TOB
      ,iTooth_Type_In
      ,iTooth_Type_Out
      ,iSame_Provider
      ,iSpecialty
      ,iRemark_Code
      ,iRemark_Code_2
      ,iAction_Code
      ,iCode_Rule_ID 
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL([Common_SubCodeId], '')
      ,ISNULL([Common_SubListGroupId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AgeCalcBasis]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AgeCalcOption]), '1')
      ,ISNULL([Common_MinAgeRange], '0')
      ,ISNULL([Common_MaxAgeRange], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiagGrouper]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiagValidationLogic]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseMemberDiag]), 'N')
      ,ISNULL([Common_DiagValidationId], '')
      ,ISNULL([Common_SubPosId], '')
      ,ISNULL([Common_SubPosListId], '')
      ,ISNULL([Common_SubModifier], '**')
      ,ISNULL([Common_SubTypeOfBill], '')
      ,ISNULL([Common_SubTobListId], '')
      ,ISNULL([*RuleOpt_Priority], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_TimePeriod]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_StartingPeriodOption]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_Restrict to Prior Claims]), 'Y')
      ,ISNULL([RuleOpt_MinNumofPeriods], '0')
      ,ISNULL([RuleOpt_MaxNumofPeriods], '0')
      ,ISNULL([RuleOpt_CodeListGroupID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_DenyFlag]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameMouthArea]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_StatusofHistClaim]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameHistDiag]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameHistPOS]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameHistModifier]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameHistTypeofBill]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_ToothTypeIn]), 'DF')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_ToothTypeOut]), 'DF')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_SameProvider]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOpt_Specialty]), 'N')
      ,ISNULL([RuleOpt_RemarkCode], '')
      ,ISNULL([RuleOpt_RemarkCode2], '')
      ,ISNULL([RuleOpt_ActionCode], '')
      ,ISNULL([RuleOpt_CodeRuleID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeStepTherapySubmittedCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeStepTherapySubmittedCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeStepTherapySubmittedCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Step_therapy_gid
       ,i_old_effective_date
       ,i_old_termination_date
       ,i_old_procedure_id
       ,i_old_priority
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Step_Therapy_SID
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,iImportStepTherapyID
       ,iImportStepTherapyDesc
       ,iEffective_Date
       ,iTermination_Date
       ,iSub_Code_ID
       ,iSub_Code_Desc
       ,iSub_List_Group_ID
       ,iSub_List_Group_Desc
       ,iAgeCalcUnit
       ,iAge_Calc_Option
       ,iMinimum_Age_Range
       ,iMaximum_Age_Range
       ,iDiagnosis_Grouper
       ,iDiagnosis_Validation_Logic
       ,iUse_Member_Diagnosis
       ,iDiagnosis_Validation_ID
       ,iDiagnosis_Val_Desc
       ,iSub_POS_ID
       ,iSub_POS_Desc
       ,iPOSListID
       ,iPOSListDesc
       ,iModifier
       ,iTypeOfBill
       ,iTOBListID
       ,iTOBListDesc
       ,iPriority
       ,iTime_Period
       ,iDateOption
       ,iSvcDateRestrict
       ,iMin_Number_of_Periods
       ,iMax_Number_of_Periods
       ,iCode_List_Group_ID
       ,iCode_List_Group_Desc
       ,iHistFFOption
       ,iDeny_Flag
       ,iSame_Area
       ,iStatus_of_Hist_Claim
       ,iSame_Diagnosis
       ,iSame_POS
       ,iSame_MOD
       ,iSame_TOB
       ,iTooth_Type_In
       ,iTooth_Type_Out
       ,iSame_Provider
       ,iSpecialty
       ,iRemark_Code
       ,iRemark_Desc
       ,iRemark_Code_2
       ,iRemark_Desc_2
       ,iAction_Code
       ,iCode_Desc
       ,iCode_Rule_ID
       ,iCode_Rule_Desc
       ,i_domain_rule_id
       ,i_domain_rule_desc
       ,i_domain_rule_priority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeStepTherapySubmittedCodes

   OPEN CodeStepTherapySubmittedCodes_Cursor
  FETCH NEXT FROM CodeStepTherapySubmittedCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Step_therapy_gid
       ,@i_old_effective_date
       ,@i_old_termination_date
       ,@i_old_procedure_id
       ,@i_old_priority
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Step_Therapy_SID
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@iImportStepTherapyID
       ,@iImportStepTherapyDesc
       ,@iEffective_Date
       ,@iTermination_Date
       ,@iSub_Code_ID
       ,@iSub_Code_Desc
       ,@iSub_List_Group_ID
       ,@iSub_List_Group_Desc
       ,@iAgeCalcUnit
       ,@iAge_Calc_Option
       ,@iMinimum_Age_Range
       ,@iMaximum_Age_Range
       ,@iDiagnosis_Grouper
       ,@iDiagnosis_Validation_Logic
       ,@iUse_Member_Diagnosis
       ,@iDiagnosis_Validation_ID
       ,@iDiagnosis_Val_Desc
       ,@iSub_POS_ID
       ,@iSub_POS_Desc
       ,@iPOSListID
       ,@iPOSListDesc
       ,@iModifier
       ,@iTypeOfBill
       ,@iTOBListID
       ,@iTOBListDesc
       ,@iPriority
       ,@iTime_Period
       ,@iDateOption
       ,@iSvcDateRestrict
       ,@iMin_Number_of_Periods
       ,@iMax_Number_of_Periods
       ,@iCode_List_Group_ID
       ,@iCode_List_Group_Desc
       ,@iHistFFOption
       ,@iDeny_Flag
       ,@iSame_Area
       ,@iStatus_of_Hist_Claim
       ,@iSame_Diagnosis
       ,@iSame_POS
       ,@iSame_MOD
       ,@iSame_TOB
       ,@iTooth_Type_In
       ,@iTooth_Type_Out
       ,@iSame_Provider
       ,@iSpecialty
       ,@iRemark_Code
       ,@iRemark_Desc
       ,@iRemark_Code_2
       ,@iRemark_Desc_2
       ,@iAction_Code
       ,@iCode_Desc
       ,@iCode_Rule_ID
       ,@iCode_Rule_Desc
       ,@i_domain_rule_id
       ,@i_domain_rule_desc
       ,@i_domain_rule_priority
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the Auth Match
			SELECT @i_Step_therapy_gid		= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'PROCEDURE_STEP_THERAPY'

			EXEC dbo.prProcStepTherapyAdd
             @i_entity_name
            ,@i_Step_therapy_gid
            ,@i_old_effective_date
            ,@i_old_termination_date
            ,@i_old_procedure_id
            ,@i_old_priority
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_Step_Therapy_SID
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@iImportStepTherapyID
            ,@iImportStepTherapyDesc
            ,@iEffective_Date
            ,@iTermination_Date
            ,@iSub_Code_ID
            ,@iSub_Code_Desc
            ,@iSub_List_Group_ID
            ,@iSub_List_Group_Desc
            ,@iAgeCalcUnit
            ,@iAge_Calc_Option
            ,@iMinimum_Age_Range
            ,@iMaximum_Age_Range
            ,@iDiagnosis_Grouper
            ,@iDiagnosis_Validation_Logic
            ,@iUse_Member_Diagnosis
            ,@iDiagnosis_Validation_ID
            ,@iDiagnosis_Val_Desc
            ,@iSub_POS_ID
            ,@iSub_POS_Desc
            ,@iPOSListID
            ,@iPOSListDesc
            ,@iModifier
            ,@iTypeOfBill
            ,@iTOBListID
            ,@iTOBListDesc
            ,@iPriority
            ,@iTime_Period
            ,@iDateOption
            ,@iSvcDateRestrict
            ,@iMin_Number_of_Periods
            ,@iMax_Number_of_Periods
            ,@iCode_List_Group_ID
            ,@iCode_List_Group_Desc
            ,@iHistFFOption
            ,@iDeny_Flag
            ,@iSame_Area
            ,@iStatus_of_Hist_Claim
            ,@iSame_Diagnosis
            ,@iSame_POS
            ,@iSame_MOD
            ,@iSame_TOB
            ,@iTooth_Type_In
            ,@iTooth_Type_Out
            ,@iSame_Provider
            ,@iSpecialty
            ,@iRemark_Code
            ,@iRemark_Desc
            ,@iRemark_Code_2
            ,@iRemark_Desc_2
            ,@iAction_Code
            ,@iCode_Desc
            ,@iCode_Rule_ID
            ,@iCode_Rule_Desc
            ,@i_domain_rule_id
            ,@i_domain_rule_desc
            ,@i_domain_rule_priority
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iEffective_Date, @iPriority, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeStepTherapySubmittedCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Step_therapy_gid
             ,@i_old_effective_date
             ,@i_old_termination_date
             ,@i_old_procedure_id
             ,@i_old_priority
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Step_Therapy_SID
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@iImportStepTherapyID
             ,@iImportStepTherapyDesc
             ,@iEffective_Date
             ,@iTermination_Date
             ,@iSub_Code_ID
             ,@iSub_Code_Desc
             ,@iSub_List_Group_ID
             ,@iSub_List_Group_Desc
             ,@iAgeCalcUnit
             ,@iAge_Calc_Option
             ,@iMinimum_Age_Range
             ,@iMaximum_Age_Range
             ,@iDiagnosis_Grouper
             ,@iDiagnosis_Validation_Logic
             ,@iUse_Member_Diagnosis
             ,@iDiagnosis_Validation_ID
             ,@iDiagnosis_Val_Desc
             ,@iSub_POS_ID
             ,@iSub_POS_Desc
             ,@iPOSListID
             ,@iPOSListDesc
             ,@iModifier
             ,@iTypeOfBill
             ,@iTOBListID
             ,@iTOBListDesc
             ,@iPriority
             ,@iTime_Period
             ,@iDateOption
             ,@iSvcDateRestrict
             ,@iMin_Number_of_Periods
             ,@iMax_Number_of_Periods
             ,@iCode_List_Group_ID
             ,@iCode_List_Group_Desc
             ,@iHistFFOption
             ,@iDeny_Flag
             ,@iSame_Area
             ,@iStatus_of_Hist_Claim
             ,@iSame_Diagnosis
             ,@iSame_POS
             ,@iSame_MOD
             ,@iSame_TOB
             ,@iTooth_Type_In
             ,@iTooth_Type_Out
             ,@iSame_Provider
             ,@iSpecialty
             ,@iRemark_Code
             ,@iRemark_Desc
             ,@iRemark_Code_2
             ,@iRemark_Desc_2
             ,@iAction_Code
             ,@iCode_Desc
             ,@iCode_Rule_ID
             ,@iCode_Rule_Desc
             ,@i_domain_rule_id
             ,@i_domain_rule_desc
             ,@i_domain_rule_priority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeStepTherapySubmittedCodes_Cursor
DEALLOCATE CodeStepTherapySubmittedCodes_Cursor

END
GO