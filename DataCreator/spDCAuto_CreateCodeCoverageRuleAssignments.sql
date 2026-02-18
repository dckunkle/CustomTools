IF OBJECT_ID('dbo.spDCAuto_CreateCodeCoverageRuleAssignments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeCoverageRuleAssignments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeCoverageRuleAssignments
Purpose:    Create codecoverageruleassignments data from CorderAutomation
Method:     CodeCoverageRuleAssignments
Screen GID: 3017
Procedure:  dbo.prProdCovAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeCoverageRuleAssignments '100-Config%', 22, 'CodeCoverageRuleAssignments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeCoverageRuleAssignments
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
       ,@i_Product_Coverage_GID                VARCHAR(50)
       ,@i_Product_Coverage_SID                VARCHAR(50)
       ,@i_key_3_field                         VARCHAR(50)
       ,@i_key_4_field                         VARCHAR(50)
       ,@i_key_5_field                         VARCHAR(50)
       ,@i_key_6_field                         VARCHAR(50)
       ,@i_key_7_field                         VARCHAR(50)
       ,@i_key_8_field                         VARCHAR(100)
       ,@i_key_9_field                         VARCHAR(50)
       ,@i_key_10_field                        VARCHAR(50)
       ,@i_action                              VARCHAR(10)
       ,@i_date_time_modified                  VARCHAR(50)
       ,@iUserID                               VARCHAR(50)
       ,@iImpCodeCoverageID                    VARCHAR(50)
       ,@iImpCodeCoverageDesc                  VARCHAR(50)
       ,@i_Effective_Date                      VARCHAR(50)
       ,@i_Termination_Date                    VARCHAR(50)
       ,@i_Priority                            VARCHAR(50)
       ,@i_Product_List_ID                     VARCHAR(50)
       ,@i_Product_List_Desc                   VARCHAR(50)
       ,@i_Product_Qualifier                   VARCHAR(50)
       ,@i_Product_ID                          VARCHAR(100)
       ,@i_Product_Desc                        VARCHAR(80)
       ,@i_Add_Product_List_ID                 VARCHAR(50)
       ,@i_Add_Product_List_Desc               VARCHAR(50)
       ,@i_SubPosID                            VARCHAR(50)
       ,@i_SubPosDesc                          VARCHAR(50)
       ,@iPOSListID                            VARCHAR(50)
       ,@iPOSListDesc                          VARCHAR(50)
       ,@i_SubModifier                         VARCHAR(50)
       ,@i_SubTypeOfBill                       VARCHAR(50)
       ,@iTOBListID                            VARCHAR(50)
       ,@iTOBListDesc                          VARCHAR(50)
       ,@i_SubDAW                              VARCHAR(100)
       ,@i_GenericCode                         VARCHAR(50)
       ,@i_diag_matching_criteria              VARCHAR(50)
       ,@iUse_Member_Diagnosis                 VARCHAR(50)
       ,@iDiagnosisID                          VARCHAR(50)
       ,@iDiagnosisDesc                        VARCHAR(100)
       ,@ipatient_age_start                    VARCHAR(50)
       ,@ipatient_age_end                      INT
       ,@igender                               VARCHAR(50)
       ,@i_Rule_ID                             VARCHAR(50)
       ,@i_Rule_Description                    VARCHAR(50)
       ,@iUse_for_CSR_Display                  VARCHAR(50)
       ,@ibenefit_limit_type                   VARCHAR(50)
       ,@i_Domain_Rule_Id                      VARCHAR(50)
       ,@i_Domain_Rule_Desc                    VARCHAR(50)
       ,@i_Domain_Rule_Priority                VARCHAR(50)
       ,@iSubmittedToothType                   VARCHAR(50)
       ,@iSubmittedToothNumber                 VARCHAR(50)
       ,@iSubmittedToothNumberListID           VARCHAR(50)
       ,@iSubmittedToothNumberListDescription  VARCHAR(500)
       ,@iSubmittedToothSurface                VARCHAR(50)
       ,@iSubmittedToothSurfaceListID          VARCHAR(50)
       ,@iSubmittedToothSurfaceListDescription VARCHAR(500)
       ,@o_status                              INT
       ,@o_message                             VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeCoverageRuleAssignments') IS NOT NULL
	DROP TABLE #CodeCoverageRuleAssignments

CREATE TABLE #CodeCoverageRuleAssignments
      (SearchID                              VARCHAR(200)
      ,i_entity_name                         VARCHAR(50)       DEFAULT('Product_Coverage')
      ,i_Product_Coverage_GID                VARCHAR(50)       DEFAULT('0')
      ,i_Product_Coverage_SID                VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                         VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field                         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                        VARCHAR(50)       DEFAULT('0')
      ,i_action                              VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified                  VARCHAR(50)       DEFAULT('')
      ,iUserID                               VARCHAR(50)       DEFAULT('')
      ,iImpCodeCoverageID                    VARCHAR(50)
      ,iImpCodeCoverageDesc                  VARCHAR(50)
      ,i_Effective_Date                      VARCHAR(50)
      ,i_Termination_Date                    VARCHAR(50)
      ,i_Priority                            VARCHAR(50)
      ,i_Product_List_ID                     VARCHAR(50)
      ,i_Product_List_Desc                   VARCHAR(50)
      ,i_Product_Qualifier                   VARCHAR(50)
      ,i_Product_ID                          VARCHAR(100)
      ,i_Product_Desc                        VARCHAR(80)
      ,i_Add_Product_List_ID                 VARCHAR(50)
      ,i_Add_Product_List_Desc               VARCHAR(50)
      ,i_SubPosID                            VARCHAR(50)
      ,i_SubPosDesc                          VARCHAR(50)
      ,iPOSListID                            VARCHAR(50)
      ,iPOSListDesc                          VARCHAR(50)
      ,i_SubModifier                         VARCHAR(50)
      ,i_SubTypeOfBill                       VARCHAR(50)
      ,iTOBListID                            VARCHAR(50)
      ,iTOBListDesc                          VARCHAR(50)
      ,i_SubDAW                              VARCHAR(100)
      ,i_GenericCode                         VARCHAR(50)
      ,i_diag_matching_criteria              VARCHAR(50)
      ,iUse_Member_Diagnosis                 VARCHAR(50)
      ,iDiagnosisID                          VARCHAR(50)
      ,iDiagnosisDesc                        VARCHAR(100)
      ,ipatient_age_start                    VARCHAR(50)
      ,ipatient_age_end                      INT
      ,igender                               VARCHAR(50)
      ,i_Rule_ID                             VARCHAR(50)
      ,i_Rule_Description                    VARCHAR(50)
      ,iUse_for_CSR_Display                  VARCHAR(50)
      ,ibenefit_limit_type                   VARCHAR(50)
      ,i_Domain_Rule_Id                      VARCHAR(50)
      ,i_Domain_Rule_Desc                    VARCHAR(50)
      ,i_Domain_Rule_Priority                VARCHAR(50)
      ,iSubmittedToothType                   VARCHAR(50)
      ,iSubmittedToothNumber                 VARCHAR(50)
      ,iSubmittedToothNumberListID           VARCHAR(50)
      ,iSubmittedToothNumberListDescription  VARCHAR(500)
      ,iSubmittedToothSurface                VARCHAR(50)
      ,iSubmittedToothSurfaceListID          VARCHAR(50)
      ,iSubmittedToothSurfaceListDescription VARCHAR(500)
      ,o_status                              INT
      ,o_message                             VARCHAR(100)
      ,record_id                             INT
      ,static_gid                            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeCoverageRuleAssignments
      (SearchID
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Priority
      ,i_Product_List_ID
      ,i_Product_Qualifier
      ,i_Product_ID
      ,i_Add_Product_List_ID
      ,i_SubPosID
      ,iPOSListID
      ,i_SubModifier
      ,i_SubTypeOfBill
      ,iTOBListID
      ,i_SubDAW
      ,i_GenericCode
      ,i_diag_matching_criteria
      ,iUse_Member_Diagnosis
      ,iDiagnosisID
      ,ipatient_age_start
      ,ipatient_age_end
      ,igender
      ,i_Rule_ID
      ,iUse_for_CSR_Display
      ,ibenefit_limit_type
      ,iSubmittedToothType
      ,iSubmittedToothNumber
      ,iSubmittedToothNumberListID
      ,iSubmittedToothSurface
      ,iSubmittedToothSurfaceListID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([*Priority], '-1')
      ,ISNULL([CodeListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CodeQualifier]), 'N/A')
      ,ISNULL([CodeID], '')
      ,ISNULL([AddMedicalCodeID], '')
      ,ISNULL([SubPOSID], '')
      ,ISNULL([SubPOSListID], '')
      ,ISNULL([SubModifier], '')
      ,ISNULL([SubTypeOfBill], '')
      ,ISNULL([SubTOBListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubDAW]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenericCode]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DiagValidLogic]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UseMemberDiag]), 'N')
      ,ISNULL([DiagnosisValidID], '')
      ,ISNULL([PatientAgeStart], '0')
      ,ISNULL([PatientAgeEnd], '999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenderCode]), 'U')
      ,ISNULL([*CodeRuleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UseforCSRDisplay]), 'F')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CSRDispBenLimitType]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubToothType]), '00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubToothNumber]), '')
      ,ISNULL([SubToothNumberListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubToothSurface]), '')
      ,ISNULL([SubToothSurfaceListID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeCoverageRuleAssignments
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeCoverageRuleAssignments
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeCoverageRuleAssignments_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Product_Coverage_GID
       ,i_Product_Coverage_SID
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
       ,iImpCodeCoverageID
       ,iImpCodeCoverageDesc
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Priority
       ,i_Product_List_ID
       ,i_Product_List_Desc
       ,i_Product_Qualifier
       ,i_Product_ID
       ,i_Product_Desc
       ,i_Add_Product_List_ID
       ,i_Add_Product_List_Desc
       ,i_SubPosID
       ,i_SubPosDesc
       ,iPOSListID
       ,iPOSListDesc
       ,i_SubModifier
       ,i_SubTypeOfBill
       ,iTOBListID
       ,iTOBListDesc
       ,i_SubDAW
       ,i_GenericCode
       ,i_diag_matching_criteria
       ,iUse_Member_Diagnosis
       ,iDiagnosisID
       ,iDiagnosisDesc
       ,ipatient_age_start
       ,ipatient_age_end
       ,igender
       ,i_Rule_ID
       ,i_Rule_Description
       ,iUse_for_CSR_Display
       ,ibenefit_limit_type
       ,i_Domain_Rule_Id
       ,i_Domain_Rule_Desc
       ,i_Domain_Rule_Priority
       ,iSubmittedToothType
       ,iSubmittedToothNumber
       ,iSubmittedToothNumberListID
       ,iSubmittedToothNumberListDescription
       ,iSubmittedToothSurface
       ,iSubmittedToothSurfaceListID
       ,iSubmittedToothSurfaceListDescription
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeCoverageRuleAssignments

   OPEN CodeCoverageRuleAssignments_Cursor
  FETCH NEXT FROM CodeCoverageRuleAssignments_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Product_Coverage_GID
       ,@i_Product_Coverage_SID
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
       ,@iImpCodeCoverageID
       ,@iImpCodeCoverageDesc
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Priority
       ,@i_Product_List_ID
       ,@i_Product_List_Desc
       ,@i_Product_Qualifier
       ,@i_Product_ID
       ,@i_Product_Desc
       ,@i_Add_Product_List_ID
       ,@i_Add_Product_List_Desc
       ,@i_SubPosID
       ,@i_SubPosDesc
       ,@iPOSListID
       ,@iPOSListDesc
       ,@i_SubModifier
       ,@i_SubTypeOfBill
       ,@iTOBListID
       ,@iTOBListDesc
       ,@i_SubDAW
       ,@i_GenericCode
       ,@i_diag_matching_criteria
       ,@iUse_Member_Diagnosis
       ,@iDiagnosisID
       ,@iDiagnosisDesc
       ,@ipatient_age_start
       ,@ipatient_age_end
       ,@igender
       ,@i_Rule_ID
       ,@i_Rule_Description
       ,@iUse_for_CSR_Display
       ,@ibenefit_limit_type
       ,@i_Domain_Rule_Id
       ,@i_Domain_Rule_Desc
       ,@i_Domain_Rule_Priority
       ,@iSubmittedToothType
       ,@iSubmittedToothNumber
       ,@iSubmittedToothNumberListID
       ,@iSubmittedToothNumberListDescription
       ,@iSubmittedToothSurface
       ,@iSubmittedToothSurfaceListID
       ,@iSubmittedToothSurfaceListDescription
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the gid from the Code Coverage
			SELECT @i_Product_Coverage_GID	= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND  entity_identifier		= 'PRODUCT_COVERAGE_NAME'
			   AND entity_user_id			= @SearchID

			EXEC dbo.prProdCovAddModify
             @i_entity_name
            ,@i_Product_Coverage_GID
            ,@i_Product_Coverage_SID
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
            ,@iImpCodeCoverageID
            ,@iImpCodeCoverageDesc
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Priority
            ,@i_Product_List_ID
            ,@i_Product_List_Desc
            ,@i_Product_Qualifier
            ,@i_Product_ID
            ,@i_Product_Desc
            ,@i_Add_Product_List_ID
            ,@i_Add_Product_List_Desc
            ,@i_SubPosID
            ,@i_SubPosDesc
            ,@iPOSListID
            ,@iPOSListDesc
            ,@i_SubModifier
            ,@i_SubTypeOfBill
            ,@iTOBListID
            ,@iTOBListDesc
            ,@i_SubDAW
            ,@i_GenericCode
            ,@i_diag_matching_criteria
            ,@iUse_Member_Diagnosis
            ,@iDiagnosisID
            ,@iDiagnosisDesc
            ,@ipatient_age_start
            ,@ipatient_age_end
            ,@igender
            ,@i_Rule_ID
            ,@i_Rule_Description
            ,@iUse_for_CSR_Display
            ,@ibenefit_limit_type
            ,@i_Domain_Rule_Id
            ,@i_Domain_Rule_Desc
            ,@i_Domain_Rule_Priority
            ,@iSubmittedToothType
            ,@iSubmittedToothNumber
            ,@iSubmittedToothNumberListID
            ,@iSubmittedToothNumberListDescription
            ,@iSubmittedToothSurface
            ,@iSubmittedToothSurfaceListID
            ,@iSubmittedToothSurfaceListDescription
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Rule_ID, @i_Effective_Date, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeCoverageRuleAssignments_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Product_Coverage_GID
             ,@i_Product_Coverage_SID
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
             ,@iImpCodeCoverageID
             ,@iImpCodeCoverageDesc
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Priority
             ,@i_Product_List_ID
             ,@i_Product_List_Desc
             ,@i_Product_Qualifier
             ,@i_Product_ID
             ,@i_Product_Desc
             ,@i_Add_Product_List_ID
             ,@i_Add_Product_List_Desc
             ,@i_SubPosID
             ,@i_SubPosDesc
             ,@iPOSListID
             ,@iPOSListDesc
             ,@i_SubModifier
             ,@i_SubTypeOfBill
             ,@iTOBListID
             ,@iTOBListDesc
             ,@i_SubDAW
             ,@i_GenericCode
             ,@i_diag_matching_criteria
             ,@iUse_Member_Diagnosis
             ,@iDiagnosisID
             ,@iDiagnosisDesc
             ,@ipatient_age_start
             ,@ipatient_age_end
             ,@igender
             ,@i_Rule_ID
             ,@i_Rule_Description
             ,@iUse_for_CSR_Display
             ,@ibenefit_limit_type
             ,@i_Domain_Rule_Id
             ,@i_Domain_Rule_Desc
             ,@i_Domain_Rule_Priority
             ,@iSubmittedToothType
             ,@iSubmittedToothNumber
             ,@iSubmittedToothNumberListID
             ,@iSubmittedToothNumberListDescription
             ,@iSubmittedToothSurface
             ,@iSubmittedToothSurfaceListID
             ,@iSubmittedToothSurfaceListDescription
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeCoverageRuleAssignments_Cursor
DEALLOCATE CodeCoverageRuleAssignments_Cursor

END
GO