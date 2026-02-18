IF OBJECT_ID('dbo.spDCAuto_CreateCodeFrequencySubCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeFrequencySubCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeFrequencySubCodes
Purpose:    Create codefrequencysubcodes data from CorderAutomation
Method:     CodeFrequencySubCodes
Screen GID: 46
Procedure:  dbo.prProcXCheckAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
10/25/2021	DK				Added DropDwon function to Diagnosis Validation Logic
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeFrequencySubCodes '100-Config%', 22, 'CodeFrequencySubCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeFrequencySubCodes
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

DECLARE @i_entity_name                         VARCHAR(50)
       ,@i_Procedure_XCheck_gid                VARCHAR(50)
       ,@i_Procedure_XCheck_sid                VARCHAR(50)
       ,@i_key_3_field                         VARCHAR(50)
       ,@i_key_4_field                         VARCHAR(50)
       ,@i_key_5_field                         VARCHAR(50)
       ,@i_key_6_field                         VARCHAR(50)
       ,@i_key_7_field                         VARCHAR(50)
       ,@i_key_8_field                         VARCHAR(50)
       ,@i_key_9_field                         VARCHAR(50)
       ,@i_key_10_field                        VARCHAR(50)
       ,@i_action                              VARCHAR(10)
       ,@i_date_time_modified                  VARCHAR(30)
       ,@iUserID                               VARCHAR(25)
       ,@iImportCodeFreqID                     VARCHAR(50)
       ,@iImportCodeFreqDesc                   VARCHAR(50)
       ,@iEffective_Date                       VARCHAR(50)
       ,@iTermination_Date                     VARCHAR(50)
       ,@iSub_Code_ID                          VARCHAR(50)
       ,@iSub_Code_Desc                        VARCHAR(300)
       ,@iSub_List_Group_ID                    VARCHAR(50)
       ,@iSub_List_Group_Desc                  VARCHAR(50)
       ,@iAgeCalcUnit                          VARCHAR(50)
       ,@iAge_Calc_Option                      VARCHAR(50)
       ,@iMinimum_Age_Range                    INT
       ,@iMaximum_Age_Range                    INT
       ,@iDiagnosis_Grouper                    VARCHAR(50)
       ,@iDiagnosis_Validation_Logic           VARCHAR(50)
       ,@iUse_Member_Diagnosis                 VARCHAR(50)
       ,@iDiagnosis_Validation_ID              VARCHAR(50)
       ,@iDiagnosis_Val_Desc                   VARCHAR(50)
       ,@iSub_POS_ID                           VARCHAR(50)
       ,@iSub_POS_Desc                         VARCHAR(50)
       ,@iPOSListID                            VARCHAR(50)
       ,@iPOSListDesc                          VARCHAR(50)
       ,@iModifier                             VARCHAR(50)
       ,@iTypeOfBill                           VARCHAR(50)
       ,@iTOBListID                            VARCHAR(50)
       ,@iTOBListDesc                          VARCHAR(50)
       ,@iTooth_type_in                        VARCHAR(50)
       ,@iSubmittedToothNumber                 VARCHAR(50)
       ,@iSubmittedToothNumberListID           VARCHAR(50)
       ,@iSubmittedToothNumberListDescription  VARCHAR(500)
       ,@iSubmittedToothSurface                VARCHAR(50)
       ,@iSubmittedToothSurfaceListID          VARCHAR(50)
       ,@iSubmittedToothSurfaceListDescription VARCHAR(500)
       ,@iTime_Span_Increment                  VARCHAR(50)
       ,@iTime_Span_Value                      INT
       ,@iDateOption                           VARCHAR(50)
       ,@iCode_List_Group_ID                   VARCHAR(50)
       ,@iCode_List_Group_Desc                 VARCHAR(50)
       ,@iSame_Area                            VARCHAR(50)
       ,@iStatus_of_Hist_Claim                 VARCHAR(50)
       ,@iSame_Diagnosis                       VARCHAR(50)
       ,@iSame_POS                             VARCHAR(50)
       ,@iSame_MOD                             VARCHAR(50)
       ,@iSame_TOB                             VARCHAR(50)
       ,@iTooth_type_out                       VARCHAR(50)
       ,@iSame_Provider                        VARCHAR(50)
       ,@iSpecialty                            VARCHAR(50)
       ,@iViolation_Frequency                  BIGINT
       ,@iViolation_Basis                      VARCHAR(50)
       ,@iViolation_Review                     VARCHAR(50)
       ,@iDocs_Override                        VARCHAR(50)
       ,@iGrntd_Svc_Cnt                        BIGINT
       ,@iUse_for_for_CSR_Display              VARCHAR(50)
       ,@ibenefit_limit_type                   INT
       ,@icsr_display_history                  VARCHAR(50)
       ,@iRemark_Code_ID_1                     VARCHAR(50)
       ,@iRemark_Code_Desc                     VARCHAR(490)
       ,@iRemark_Code_ID_2                     VARCHAR(50)
       ,@iRemark_Code_Desc2                    VARCHAR(490)
       ,@iAction_Code                          VARCHAR(50)
       ,@iCode_Desc                            VARCHAR(300)
       ,@i_domain_rule_id                      VARCHAR(50)
       ,@i_domain_rule_desc                    VARCHAR(100)
       ,@i_domain_rule_priority                VARCHAR(50)
       ,@o_status                              INT
       ,@o_message                             VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeFrequencySubCodes') IS NOT NULL
	DROP TABLE #CodeFrequencySubCodes

CREATE TABLE #CodeFrequencySubCodes
      (SearchID                              VARCHAR(200)
      ,i_entity_name                         VARCHAR(50)       DEFAULT('Proc_XCheck')
      ,i_Procedure_XCheck_gid                VARCHAR(50)       DEFAULT('0')
      ,i_Procedure_XCheck_sid                VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                        VARCHAR(50)       DEFAULT('0')
      ,i_action                              VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified                  VARCHAR(30)       DEFAULT('')
      ,iUserID                               VARCHAR(25)       DEFAULT('')
      ,iImportCodeFreqID                     VARCHAR(50)
      ,iImportCodeFreqDesc                   VARCHAR(50)
      ,iEffective_Date                       VARCHAR(50)
      ,iTermination_Date                     VARCHAR(50)
      ,iSub_Code_ID                          VARCHAR(50)
      ,iSub_Code_Desc                        VARCHAR(300)
      ,iSub_List_Group_ID                    VARCHAR(50)
      ,iSub_List_Group_Desc                  VARCHAR(50)
      ,iAgeCalcUnit                          VARCHAR(50)
      ,iAge_Calc_Option                      VARCHAR(50)
      ,iMinimum_Age_Range                    INT
      ,iMaximum_Age_Range                    INT
      ,iDiagnosis_Grouper                    VARCHAR(50)
      ,iDiagnosis_Validation_Logic           VARCHAR(50)
      ,iUse_Member_Diagnosis                 VARCHAR(50)
      ,iDiagnosis_Validation_ID              VARCHAR(50)
      ,iDiagnosis_Val_Desc                   VARCHAR(50)
      ,iSub_POS_ID                           VARCHAR(50)
      ,iSub_POS_Desc                         VARCHAR(50)
      ,iPOSListID                            VARCHAR(50)
      ,iPOSListDesc                          VARCHAR(50)
      ,iModifier                             VARCHAR(50)
      ,iTypeOfBill                           VARCHAR(50)
      ,iTOBListID                            VARCHAR(50)
      ,iTOBListDesc                          VARCHAR(50)
      ,iTooth_type_in                        VARCHAR(50)
      ,iSubmittedToothNumber                 VARCHAR(50)
      ,iSubmittedToothNumberListID           VARCHAR(50)
      ,iSubmittedToothNumberListDescription  VARCHAR(500)
      ,iSubmittedToothSurface                VARCHAR(50)
      ,iSubmittedToothSurfaceListID          VARCHAR(50)
      ,iSubmittedToothSurfaceListDescription VARCHAR(500)
      ,iTime_Span_Increment                  VARCHAR(50)
      ,iTime_Span_Value                      INT
      ,iDateOption                           VARCHAR(50)
      ,iCode_List_Group_ID                   VARCHAR(50)
      ,iCode_List_Group_Desc                 VARCHAR(50)
      ,iSame_Area                            VARCHAR(50)
      ,iStatus_of_Hist_Claim                 VARCHAR(50)
      ,iSame_Diagnosis                       VARCHAR(50)
      ,iSame_POS                             VARCHAR(50)
      ,iSame_MOD                             VARCHAR(50)
      ,iSame_TOB                             VARCHAR(50)
      ,iTooth_type_out                       VARCHAR(50)
      ,iSame_Provider                        VARCHAR(50)
      ,iSpecialty                            VARCHAR(50)
      ,iViolation_Frequency                  BIGINT
      ,iViolation_Basis                      VARCHAR(50)
      ,iViolation_Review                     VARCHAR(50)
      ,iDocs_Override                        VARCHAR(50)
      ,iGrntd_Svc_Cnt                        BIGINT
      ,iUse_for_for_CSR_Display              VARCHAR(50)
      ,ibenefit_limit_type                   INT
      ,icsr_display_history                  VARCHAR(50)
      ,iRemark_Code_ID_1                     VARCHAR(50)
      ,iRemark_Code_Desc                     VARCHAR(490)
      ,iRemark_Code_ID_2                     VARCHAR(50)
      ,iRemark_Code_Desc2                    VARCHAR(490)
      ,iAction_Code                          VARCHAR(50)
      ,iCode_Desc                            VARCHAR(300)
      ,i_domain_rule_id                      VARCHAR(50)
      ,i_domain_rule_desc                    VARCHAR(100)
      ,i_domain_rule_priority                VARCHAR(50)
      ,o_status                              INT
      ,o_message                             VARCHAR(100)
      ,record_id                             INT
      ,static_gid                            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeFrequencySubCodes
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
      ,iTooth_type_in
      ,iSubmittedToothNumber
      ,iSubmittedToothNumberListID
      ,iSubmittedToothSurface
      ,iSubmittedToothSurfaceListID

      ,iTime_Span_Increment
      ,iTime_Span_Value
      ,iDateOption
      ,iCode_List_Group_ID
	  ,iSame_Area
      ,iStatus_of_Hist_Claim
      ,iSame_Diagnosis
      ,iSame_POS
      ,iSame_MOD
      ,iSame_TOB
      ,iTooth_type_out
      ,iSame_Provider
      ,iSpecialty
      ,iViolation_Frequency
      ,iViolation_Basis
      ,iViolation_Review
      ,iDocs_Override
      ,iGrntd_Svc_Cnt
      ,iUse_for_for_CSR_Display
      ,ibenefit_limit_type
      ,icsr_display_history
      ,iRemark_Code_ID_1
      ,iRemark_Code_ID_2
	  ,iAction_Code
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL([Common_SubCodeId], '')
      ,ISNULL([Common_SubListGroupId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AgeCalcBasis]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AgeCalcOption]), '1')
      ,ISNULL([Common_MinAgeRange], '')
      ,ISNULL([Common_MaxAgeRange], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiagGrouper]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiagValidationLogic]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_UseMemberDiag]), 'N')
      ,ISNULL([Common_DiagValidationId], '')
      ,ISNULL([Common_SubPosId], '')
      ,ISNULL([Common_SubPosListId], '')
      ,ISNULL([Common_SubModifier], '**')
      ,ISNULL([Common_SubTypeOfBill], '')
      ,ISNULL([Common_SubTobListId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubToothType]), '00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubToothNum]), '')
      ,ISNULL([Common_SubToothNumListId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubToothSurface]), '')
      ,ISNULL([Common_SubToothSurfaceListId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_TimeSpanIncrement]), 'M')

      ,ISNULL([RuleOptions_TimeSpanValue], '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_StartingPeriodOption]), 'D')
      ,ISNULL([*RuleOptions_CodeListGroupId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameMouthArea]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_StatusOfHistClaim]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameHistDiag]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameHistPos]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameHistModifier]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameHistTypeOfBill]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_HistToothType]), '00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_SameProvider]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_Speciality]), 'Y')
      ,ISNULL([RuleOptions_ViolationFrequency], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_ViolationBasis]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_ViolationReview]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_DocsOverride]), '')
      ,ISNULL([RuleOptions_GuranteedSvcCnt], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_UseForCsrDisplay]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_CsrDispBenefitLimType]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleOptions_CsrDisplayHistory]), 'N')
      ,ISNULL([RuleOptions_RemarkCodeId1], '')
      ,ISNULL([RuleOptions_RemarkCodeId2], '')
      ,ISNULL([RuleOptions_ActionCode], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeFrequencySubCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeFrequencySubCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeFrequencySubCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Procedure_XCheck_gid
       ,i_Procedure_XCheck_sid
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
       ,iImportCodeFreqID
       ,iImportCodeFreqDesc
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
       ,iTooth_type_in
       ,iSubmittedToothNumber
       ,iSubmittedToothNumberListID
       ,iSubmittedToothNumberListDescription
       ,iSubmittedToothSurface
       ,iSubmittedToothSurfaceListID
       ,iSubmittedToothSurfaceListDescription
       ,iTime_Span_Increment
       ,iTime_Span_Value
       ,iDateOption
       ,iCode_List_Group_ID
       ,iCode_List_Group_Desc
       ,iSame_Area
       ,iStatus_of_Hist_Claim
       ,iSame_Diagnosis
       ,iSame_POS
       ,iSame_MOD
       ,iSame_TOB
       ,iTooth_type_out
       ,iSame_Provider
       ,iSpecialty
       ,iViolation_Frequency
       ,iViolation_Basis
       ,iViolation_Review
       ,iDocs_Override
       ,iGrntd_Svc_Cnt
       ,iUse_for_for_CSR_Display
       ,ibenefit_limit_type
       ,icsr_display_history
       ,iRemark_Code_ID_1
       ,iRemark_Code_Desc
       ,iRemark_Code_ID_2
       ,iRemark_Code_Desc2
       ,iAction_Code
       ,iCode_Desc
       ,i_domain_rule_id
       ,i_domain_rule_desc
       ,i_domain_rule_priority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeFrequencySubCodes

   OPEN CodeFrequencySubCodes_Cursor
  FETCH NEXT FROM CodeFrequencySubCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Procedure_XCheck_gid
       ,@i_Procedure_XCheck_sid
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
       ,@iImportCodeFreqID
       ,@iImportCodeFreqDesc
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
       ,@iTooth_type_in
       ,@iSubmittedToothNumber
       ,@iSubmittedToothNumberListID
       ,@iSubmittedToothNumberListDescription
       ,@iSubmittedToothSurface
       ,@iSubmittedToothSurfaceListID
       ,@iSubmittedToothSurfaceListDescription
       ,@iTime_Span_Increment
       ,@iTime_Span_Value
       ,@iDateOption
       ,@iCode_List_Group_ID
       ,@iCode_List_Group_Desc
       ,@iSame_Area
       ,@iStatus_of_Hist_Claim
       ,@iSame_Diagnosis
       ,@iSame_POS
       ,@iSame_MOD
       ,@iSame_TOB
       ,@iTooth_type_out
       ,@iSame_Provider
       ,@iSpecialty
       ,@iViolation_Frequency
       ,@iViolation_Basis
       ,@iViolation_Review
       ,@iDocs_Override
       ,@iGrntd_Svc_Cnt
       ,@iUse_for_for_CSR_Display
       ,@ibenefit_limit_type
       ,@icsr_display_history
       ,@iRemark_Code_ID_1
       ,@iRemark_Code_Desc
       ,@iRemark_Code_ID_2
       ,@iRemark_Code_Desc2
       ,@iAction_Code
       ,@iCode_Desc
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

			-- Get the Frequency gid
			SELECT @i_Procedure_XCheck_gid	= entity_gid
			  FROM Entity_Names
			 WHERE entity_identifier		= 'PROCEDURE_XCHECK'
			   AND entity_user_id			= @SearchID
			   AND record_status			= 'A'

			EXEC dbo.prProcXCheckAdd
             @i_entity_name
            ,@i_Procedure_XCheck_gid
            ,@i_Procedure_XCheck_sid
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
            ,@iImportCodeFreqID
            ,@iImportCodeFreqDesc
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
            ,@iTooth_type_in
            ,@iSubmittedToothNumber
            ,@iSubmittedToothNumberListID
            ,@iSubmittedToothNumberListDescription
            ,@iSubmittedToothSurface
            ,@iSubmittedToothSurfaceListID
            ,@iSubmittedToothSurfaceListDescription
            ,@iTime_Span_Increment
            ,@iTime_Span_Value
            ,@iDateOption
            ,@iCode_List_Group_ID
            ,@iCode_List_Group_Desc
            ,@iSame_Area
            ,@iStatus_of_Hist_Claim
            ,@iSame_Diagnosis
            ,@iSame_POS
            ,@iSame_MOD
            ,@iSame_TOB
            ,@iTooth_type_out
            ,@iSame_Provider
            ,@iSpecialty
            ,@iViolation_Frequency
            ,@iViolation_Basis
            ,@iViolation_Review
            ,@iDocs_Override
            ,@iGrntd_Svc_Cnt
            ,@iUse_for_for_CSR_Display
            ,@ibenefit_limit_type
            ,@icsr_display_history
            ,@iRemark_Code_ID_1
            ,@iRemark_Code_Desc
            ,@iRemark_Code_ID_2
            ,@iRemark_Code_Desc2
            ,@iAction_Code
            ,@iCode_Desc
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
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iCode_List_Group_ID, @iCode_List_Group_Desc, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeFrequencySubCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Procedure_XCheck_gid
             ,@i_Procedure_XCheck_sid
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
             ,@iImportCodeFreqID
             ,@iImportCodeFreqDesc
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
             ,@iTooth_type_in
             ,@iSubmittedToothNumber
             ,@iSubmittedToothNumberListID
             ,@iSubmittedToothNumberListDescription
             ,@iSubmittedToothSurface
             ,@iSubmittedToothSurfaceListID
             ,@iSubmittedToothSurfaceListDescription
             ,@iTime_Span_Increment
             ,@iTime_Span_Value
             ,@iDateOption
             ,@iCode_List_Group_ID
             ,@iCode_List_Group_Desc
             ,@iSame_Area
             ,@iStatus_of_Hist_Claim
             ,@iSame_Diagnosis
             ,@iSame_POS
             ,@iSame_MOD
             ,@iSame_TOB
             ,@iTooth_type_out
             ,@iSame_Provider
             ,@iSpecialty
             ,@iViolation_Frequency
             ,@iViolation_Basis
             ,@iViolation_Review
             ,@iDocs_Override
             ,@iGrntd_Svc_Cnt
             ,@iUse_for_for_CSR_Display
             ,@ibenefit_limit_type
             ,@icsr_display_history
             ,@iRemark_Code_ID_1
             ,@iRemark_Code_Desc
             ,@iRemark_Code_ID_2
             ,@iRemark_Code_Desc2
             ,@iAction_Code
             ,@iCode_Desc
             ,@i_domain_rule_id
             ,@i_domain_rule_desc
             ,@i_domain_rule_priority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeFrequencySubCodes_Cursor
DEALLOCATE CodeFrequencySubCodes_Cursor

END
GO