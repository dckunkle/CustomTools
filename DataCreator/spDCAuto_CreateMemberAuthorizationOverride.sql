IF OBJECT_ID('dbo.spDCAuto_CreateMemberAuthorizationOverride') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberAuthorizationOverride AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberAuthorizationOverride
Purpose:    Create memberauthorizationoverride data from CorderAutomation

Screen:     160
Method:     MemberAuthorizationOverride
Procedure:  dbo.prPriorAuthAdd 
Entity:     Prior_Authorization

Date        User            Change
---------------------------------------------------------------------------------------------
03/04/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberAuthorizationOverride 'Kraken-Config%', 22, 'Kraken-Config','MemberAuthorizationOverride', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberAuthorizationOverride
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
       ,@i_child_gid                    VARCHAR(50)
       ,@i_child_id                     VARCHAR(50)
       ,@i_parent_gid                   VARCHAR(75)
       ,@i_parent_id                    VARCHAR(75)
       ,@i_group_gid                    VARCHAR(50)
       ,@i_effective_date               VARCHAR(75)
       ,@i_termination_date             VARCHAR(75)
       ,@i_key_8_field                  VARCHAR(75)
       ,@i_key_9_field                  VARCHAR(50)
       ,@i_member_id                    VARCHAR(75)
       ,@i_action                       VARCHAR(75)
       ,@i_date_time_modified           VARCHAR(75)
       ,@iUserID                        VARCHAR(75)
       ,@s_group_id                     VARCHAR(75)
       ,@s_member_id                    VARCHAR(75)
       ,@pa_effective_date              VARCHAR(75)
       ,@pa_termination_date            VARCHAR(75)
       ,@pa_num_uses                    VARCHAR(75)
       ,@pa_treatment_from_date         VARCHAR(75)
       ,@pa_treatment_to_date           VARCHAR(75)
       ,@pa_procedure_id                VARCHAR(75)
       ,@i_procedure_name               VARCHAR(75)
       ,@pa_tooth_number                VARCHAR(75)
       ,@pa_surface                     VARCHAR(75)
       ,@pa_class                       VARCHAR(75)
       ,@pa_override_xcheck_rules       VARCHAR(75)
       ,@pa_override_age_limit          VARCHAR(75)
       ,@pa_override_step_therapy       VARCHAR(75)
       ,@pa_override_Elig_Holds         VARCHAR(75)
       ,@pa_override_provider_holds     VARCHAR(50)
       ,@pa_override_Benefits           VARCHAR(75)
       ,@pa_override_group_holds        VARCHAR(75)
       ,@pa_override_elig_age_limits    VARCHAR(50)
       ,@pa_override_coverage_code      VARCHAR(75)
       ,@pa_exclude_benefits            VARCHAR(50)
       ,@pa_exclude_from_xcheck         VARCHAR(75)
       ,@pa_override_predet_requirement VARCHAR(50)
       ,@pa_price_type_override         VARCHAR(75)
       ,@pa_price_amount                VARCHAR(75)
       ,@pa_assignment_override         VARCHAR(50)
       ,@pa_Pay_from_source             VARCHAR(50)
       ,@pa_pay_as_procedure            VARCHAR(50)
       ,@i_pay_as_procedure_name        VARCHAR(50)
       ,@pa_pay_as_class                VARCHAR(50)
       ,@pa_diagnosis_type              VARCHAR(50)
       ,@pa_diagnosis_code              VARCHAR(50)
       ,@i_diagnosis_code_desc          VARCHAR(100)
       ,@pa_processing_policy           VARCHAR(50)
       ,@i_processing_policy_desc       VARCHAR(50)
       ,@pa_pay_as_tooth                VARCHAR(50)
       ,@pa_pay_as_surf                 VARCHAR(50)
       ,@pa_prior_auth_id               VARCHAR(50)
       ,@pa_last_used_date              VARCHAR(50)
       ,@pa_num_times_used              VARCHAR(50)
       ,@i_domain_rule_id               VARCHAR(50)
       ,@i_domain_rule_desc             VARCHAR(100)
       ,@i_domain_rule_priority         VARCHAR(50)
       ,@o_status                       INT
       ,@o_message                      VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberAuthorizationOverride') IS NOT NULL
	DROP TABLE #MemberAuthorizationOverride

CREATE TABLE #MemberAuthorizationOverride
      (SearchID                       VARCHAR(200)
      ,i_entity_name                  VARCHAR(50)       DEFAULT('Prior_Authorization')
      ,i_child_gid                    VARCHAR(50)       DEFAULT('0')
      ,i_child_id                     VARCHAR(50)       DEFAULT('0')
      ,i_parent_gid                   VARCHAR(75)       DEFAULT('0')
      ,i_parent_id                    VARCHAR(75)       DEFAULT('0')
      ,i_group_gid                    VARCHAR(50)       DEFAULT('0')
      ,i_effective_date               VARCHAR(75)       DEFAULT('0')
      ,i_termination_date             VARCHAR(75)       DEFAULT('0')
      ,i_key_8_field                  VARCHAR(75)       DEFAULT('0')
      ,i_key_9_field                  VARCHAR(50)       DEFAULT('0')
      ,i_member_id                    VARCHAR(75)       DEFAULT('0')
      ,i_action                       VARCHAR(75)       DEFAULT('ADD')
      ,i_date_time_modified           VARCHAR(75)       DEFAULT('')
      ,iUserID                        VARCHAR(75)       DEFAULT('')
      ,s_group_id                     VARCHAR(75)
      ,s_member_id                    VARCHAR(75)
      ,pa_effective_date              VARCHAR(75)
      ,pa_termination_date            VARCHAR(75)
      ,pa_num_uses                    VARCHAR(75)
      ,pa_treatment_from_date         VARCHAR(75)
      ,pa_treatment_to_date           VARCHAR(75)
      ,pa_procedure_id                VARCHAR(75)
      ,i_procedure_name               VARCHAR(75)
      ,pa_tooth_number                VARCHAR(75)
      ,pa_surface                     VARCHAR(75)
      ,pa_class                       VARCHAR(75)
      ,pa_override_xcheck_rules       VARCHAR(75)
      ,pa_override_age_limit          VARCHAR(75)
      ,pa_override_step_therapy       VARCHAR(75)
      ,pa_override_Elig_Holds         VARCHAR(75)
      ,pa_override_provider_holds     VARCHAR(50)
      ,pa_override_Benefits           VARCHAR(75)
      ,pa_override_group_holds        VARCHAR(75)
      ,pa_override_elig_age_limits    VARCHAR(50)
      ,pa_override_coverage_code      VARCHAR(75)
      ,pa_exclude_benefits            VARCHAR(50)
      ,pa_exclude_from_xcheck         VARCHAR(75)
      ,pa_override_predet_requirement VARCHAR(50)
      ,pa_price_type_override         VARCHAR(75)
      ,pa_price_amount                VARCHAR(75)
      ,pa_assignment_override         VARCHAR(50)
      ,pa_Pay_from_source             VARCHAR(50)
      ,pa_pay_as_procedure            VARCHAR(50)
      ,i_pay_as_procedure_name        VARCHAR(50)
      ,pa_pay_as_class                VARCHAR(50)
      ,pa_diagnosis_type              VARCHAR(50)
      ,pa_diagnosis_code              VARCHAR(50)
      ,i_diagnosis_code_desc          VARCHAR(100)
      ,pa_processing_policy           VARCHAR(50)
      ,i_processing_policy_desc       VARCHAR(50)
      ,pa_pay_as_tooth                VARCHAR(50)
      ,pa_pay_as_surf                 VARCHAR(50)
      ,pa_prior_auth_id               VARCHAR(50)
      ,pa_last_used_date              VARCHAR(50)
      ,pa_num_times_used              VARCHAR(50)
      ,i_domain_rule_id               VARCHAR(50)
      ,i_domain_rule_desc             VARCHAR(100)
      ,i_domain_rule_priority         VARCHAR(50)
      ,o_status                       INT
      ,o_message                      VARCHAR(255)
      ,record_id                      INT
      ,static_gid                     INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #MemberAuthorizationOverride
          (SearchID
          ,pa_effective_date
          ,pa_termination_date
          ,pa_num_uses
          ,pa_treatment_from_date
          ,pa_treatment_to_date
          ,pa_procedure_id
          ,pa_tooth_number
          ,pa_surface
          ,pa_class
          ,pa_override_xcheck_rules
          ,pa_override_age_limit
          ,pa_override_step_therapy
          ,pa_override_Elig_Holds
          ,pa_override_provider_holds
          ,pa_override_Benefits
          ,pa_override_group_holds
          ,pa_override_elig_age_limits
          ,pa_override_coverage_code
          ,pa_exclude_benefits
          ,pa_exclude_from_xcheck
          ,pa_override_predet_requirement
          ,pa_price_type_override
          ,pa_price_amount
          ,pa_assignment_override
          ,pa_Pay_from_source
          ,pa_pay_as_procedure
          ,pa_pay_as_class
          ,pa_diagnosis_type
          ,pa_diagnosis_code
          ,pa_processing_policy
          ,pa_pay_as_tooth
          ,pa_pay_as_surf
		  ,pa_prior_auth_id
		  ,pa_last_used_date
		  ,pa_num_times_used
		  ,i_domain_rule_id               
		  ,i_domain_rule_desc             
          ,i_domain_rule_priority         
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL([*EffectiveDate], '00/00/0000')
          ,ISNULL([*TerminationDate], '00/00/0000')
          ,ISNULL([*NumberUses], '1')
          ,ISNULL([TreatmentStartDate], '00/00/0000')
          ,ISNULL([TreatmentEndDate], '00/00/0000')
          ,ISNULL([ProcedureID], '')
          ,ISNULL([ToothNumber], '')
          ,ISNULL([Surface], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Class]), '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideXCheckRules]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideAgeLimit]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideStepTherapy]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideEligHolds]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideProviderHolds]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideBenefits]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideGroupHolds]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideEligAgeLimits]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverrideCoverageCode]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ExcludeBenefits]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ExcludeFromXCheck]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OverridePreDetRequirement]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriceOverride]), '')
          ,ISNULL([Fee], '0.00')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AssignmentOverride]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaySource]), '')
          ,ISNULL([PayAsProcedure], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PayAsClass]), '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DiagnosisType]), '9')
          ,ISNULL([DiagnosisCode], '')
          ,ISNULL([RemarkCode], '')
          ,ISNULL([ChangeToTooth], '')
          ,ISNULL([ChangeToSurface], '')
		  ,'0'
		  ,CONVERT(VARCHAR(10), GETDATE(), 101)
		  ,'0'
		  ,''
		  ,''
		  ,'9999'
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_MemberAuthorizationOverride
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #MemberAuthorizationOverride
       SET iUserID  = @user

	SELECT * FROM #MemberAuthorizationOverride

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
DECLARE MemberAuthorizationOverride_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_child_gid
       ,i_child_id
       ,i_parent_gid
       ,i_parent_id
       ,i_group_gid
       ,i_effective_date
       ,i_termination_date
       ,i_key_8_field
       ,i_key_9_field
       ,i_member_id
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,s_group_id
       ,s_member_id
       ,pa_effective_date
       ,pa_termination_date
       ,pa_num_uses
       ,pa_treatment_from_date
       ,pa_treatment_to_date
       ,pa_procedure_id
       ,i_procedure_name
       ,pa_tooth_number
       ,pa_surface
       ,pa_class
       ,pa_override_xcheck_rules
       ,pa_override_age_limit
       ,pa_override_step_therapy
       ,pa_override_Elig_Holds
       ,pa_override_provider_holds
       ,pa_override_Benefits
       ,pa_override_group_holds
       ,pa_override_elig_age_limits
       ,pa_override_coverage_code
       ,pa_exclude_benefits
       ,pa_exclude_from_xcheck
       ,pa_override_predet_requirement
       ,pa_price_type_override
       ,pa_price_amount
       ,pa_assignment_override
       ,pa_Pay_from_source
       ,pa_pay_as_procedure
       ,i_pay_as_procedure_name
       ,pa_pay_as_class
       ,pa_diagnosis_type
       ,pa_diagnosis_code
       ,i_diagnosis_code_desc
       ,pa_processing_policy
       ,i_processing_policy_desc
       ,pa_pay_as_tooth
       ,pa_pay_as_surf
       ,pa_prior_auth_id
       ,pa_last_used_date
       ,pa_num_times_used
       ,i_domain_rule_id
       ,i_domain_rule_desc
       ,i_domain_rule_priority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberAuthorizationOverride

   OPEN MemberAuthorizationOverride_Cursor
  FETCH NEXT FROM MemberAuthorizationOverride_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_child_gid
       ,@i_child_id
       ,@i_parent_gid
       ,@i_parent_id
       ,@i_group_gid
       ,@i_effective_date
       ,@i_termination_date
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_member_id
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@s_group_id
       ,@s_member_id
       ,@pa_effective_date
       ,@pa_termination_date
       ,@pa_num_uses
       ,@pa_treatment_from_date
       ,@pa_treatment_to_date
       ,@pa_procedure_id
       ,@i_procedure_name
       ,@pa_tooth_number
       ,@pa_surface
       ,@pa_class
       ,@pa_override_xcheck_rules
       ,@pa_override_age_limit
       ,@pa_override_step_therapy
       ,@pa_override_Elig_Holds
       ,@pa_override_provider_holds
       ,@pa_override_Benefits
       ,@pa_override_group_holds
       ,@pa_override_elig_age_limits
       ,@pa_override_coverage_code
       ,@pa_exclude_benefits
       ,@pa_exclude_from_xcheck
       ,@pa_override_predet_requirement
       ,@pa_price_type_override
       ,@pa_price_amount
       ,@pa_assignment_override
       ,@pa_Pay_from_source
       ,@pa_pay_as_procedure
       ,@i_pay_as_procedure_name
       ,@pa_pay_as_class
       ,@pa_diagnosis_type
       ,@pa_diagnosis_code
       ,@i_diagnosis_code_desc
       ,@pa_processing_policy
       ,@i_processing_policy_desc
       ,@pa_pay_as_tooth
       ,@pa_pay_as_surf
       ,@pa_prior_auth_id
       ,@pa_last_used_date
       ,@pa_num_times_used
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

			SELECT @err_num = 0
			      ,@err_msg = ''

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @s_member_id = token FROM #Tokens WHERE token_order = 1
			SELECT @s_group_id = token FROM #Tokens WHERE token_order = 2

			SELECT @i_child_gid				= ISNULL(EC.child_gid, 0)
			      ,@i_child_id				= EC.child_identifier
				  ,@i_parent_gid			= ISNULL(EC.parent_gid, 0)
				  ,@i_parent_id				= EC.parent_identifier
				  ,@i_group_gid				= ISNULL(EC.group_gid, 0)
				  ,@i_member_id				= EC.member_id
			  FROM dbo.Eligibility_Coverage	EC
			  JOIN dbo.Groups				G
			    ON EC.group_gid				= G.group_gid
			 WHERE EC.record_status			= 'A'
			   AND G.record_status			= 'A'
			   AND EC.member_id				= @s_member_id
			   AND G.group_id				= @s_group_id

			-- Make sure valid values are being found
			IF @s_group_id	 = '' AND @err_num = 0 BEGIN SELECT @err_num = 100, @err_msg = 'Missing group ID in TD_MemberAuthorizationOverride' END
			IF @s_member_id	 = '' AND @err_num = 0 BEGIN SELECT @err_num = 101, @err_msg = 'Missing member ID in TD_MemberAuthorizationOverride' END
			IF @i_child_gid	 = 0  AND @err_num = 0 BEGIN SELECT @err_num = 102, @err_msg = 'Could not determine the child_gid for the member, ' + @s_member_id END
			IF @i_parent_gid = 0  AND @err_num = 0 BEGIN SELECT @err_num = 103, @err_msg = 'Could not determine the parent_gid for the member, ' + @s_member_id END
			IF @i_group_gid	 = 0  AND @err_num = 0 BEGIN SELECT @err_num = 104, @err_msg = 'Could not determine the group_gid for the member, ' + @s_member_id END

			IF @err_num = 0 
				BEGIN

					EXEC dbo.prPriorAuthAdd 
						 @i_entity_name
						,@i_child_gid
						,@i_child_id
						,@i_parent_gid
						,@i_parent_id
						,@i_group_gid
						,@i_effective_date
						,@i_termination_date
						,@i_key_8_field
						,@i_key_9_field
						,@i_member_id
						,@i_action
						,@i_date_time_modified
						,@iUserID
						,@s_group_id
						,@s_member_id
						,@pa_effective_date
						,@pa_termination_date
						,@pa_num_uses
						,@pa_treatment_from_date
						,@pa_treatment_to_date
						,@pa_procedure_id
						,@i_procedure_name
						,@pa_tooth_number
						,@pa_surface
						,@pa_class
						,@pa_override_xcheck_rules
						,@pa_override_age_limit
						,@pa_override_step_therapy
						,@pa_override_Elig_Holds
						,@pa_override_provider_holds
						,@pa_override_Benefits
						,@pa_override_group_holds
						,@pa_override_elig_age_limits
						,@pa_override_coverage_code
						,@pa_exclude_benefits
						,@pa_exclude_from_xcheck
						,@pa_override_predet_requirement
						,@pa_price_type_override
						,@pa_price_amount
						,@pa_assignment_override
						,@pa_Pay_from_source
						,@pa_pay_as_procedure
						,@i_pay_as_procedure_name
						,@pa_pay_as_class
						,@pa_diagnosis_type
						,@pa_diagnosis_code
						,@i_diagnosis_code_desc
						,@pa_processing_policy
						,@i_processing_policy_desc
						,@pa_pay_as_tooth
						,@pa_pay_as_surf
						,@pa_prior_auth_id
						,@pa_last_used_date
						,@pa_num_times_used
						,@i_domain_rule_id
						,@i_domain_rule_desc
						,@i_domain_rule_priority
						,@o_status     = @err_num OUTPUT
						,@o_message    = @err_msg OUTPUT

				END
        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @s_member_id, @s_group_id, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberAuthorizationOverride_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_child_gid
             ,@i_child_id
             ,@i_parent_gid
             ,@i_parent_id
             ,@i_group_gid
             ,@i_effective_date
             ,@i_termination_date
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_member_id
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@s_group_id
             ,@s_member_id
             ,@pa_effective_date
             ,@pa_termination_date
             ,@pa_num_uses
             ,@pa_treatment_from_date
             ,@pa_treatment_to_date
             ,@pa_procedure_id
             ,@i_procedure_name
             ,@pa_tooth_number
             ,@pa_surface
             ,@pa_class
             ,@pa_override_xcheck_rules
             ,@pa_override_age_limit
             ,@pa_override_step_therapy
             ,@pa_override_Elig_Holds
             ,@pa_override_provider_holds
             ,@pa_override_Benefits
             ,@pa_override_group_holds
             ,@pa_override_elig_age_limits
             ,@pa_override_coverage_code
             ,@pa_exclude_benefits
             ,@pa_exclude_from_xcheck
             ,@pa_override_predet_requirement
             ,@pa_price_type_override
             ,@pa_price_amount
             ,@pa_assignment_override
             ,@pa_Pay_from_source
             ,@pa_pay_as_procedure
             ,@i_pay_as_procedure_name
             ,@pa_pay_as_class
             ,@pa_diagnosis_type
             ,@pa_diagnosis_code
             ,@i_diagnosis_code_desc
             ,@pa_processing_policy
             ,@i_processing_policy_desc
             ,@pa_pay_as_tooth
             ,@pa_pay_as_surf
             ,@pa_prior_auth_id
             ,@pa_last_used_date
             ,@pa_num_times_used
             ,@i_domain_rule_id
             ,@i_domain_rule_desc
             ,@i_domain_rule_priority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberAuthorizationOverride_Cursor
DEALLOCATE MemberAuthorizationOverride_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#MemberAuthorizationOverride') IS NOT NULL
	DROP TABLE #MemberAuthorizationOverride

END
GO

