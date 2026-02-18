/**************************************************************************************************
Name:       spDCAuto_CreateEligibilityValidationVariations
Purpose:    Create eligibilityvalidationvariations data from CorderAutomation

Screen:     9
Method:     EligibilityValidationVariations
Procedure:  dbo.prEligValidationAddModify
Entity:     Eligibility_Validation

Date        User            Change
---------------------------------------------------------------------------------------------
02/22/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateEligibilityValidationVariations 'Setup%', 22, 'InitialSetup','EligibilityValidationVariations','400-Config'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateEligibilityValidationVariations
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
       ,@i_elig_validation_gid       VARCHAR(50)
       ,@i_elig_sid                  VARCHAR(50)
       ,@i_key_3_field               VARCHAR(50)
       ,@i_key_4_field               VARCHAR(50)
       ,@i_key_5_field               VARCHAR(50)
       ,@i_key_6_field               VARCHAR(50)
       ,@i_key_7_field               VARCHAR(50)
       ,@i_key_8_field               VARCHAR(50)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_key_10_field              VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_date_time_modified        VARCHAR(30)
       ,@iUserID                     VARCHAR(25)
       ,@i_elig_validation_id        VARCHAR(50)
       ,@i_elig_val_description      VARCHAR(75)
       ,@i_effective_date            VARCHAR(50)
       ,@i_termination_date          VARCHAR(50)
       ,@i_state                     VARCHAR(50)
       ,@i_subscriber_covd           VARCHAR(50)
       ,@i_subscriber_dob            VARCHAR(50)
       ,@i_subscriber_age_minimum    VARCHAR(50)
       ,@i_subscriber_age_limit      VARCHAR(50)
       ,@i_subscriber_age_option     VARCHAR(50)
       ,@i_spouses_covd              VARCHAR(50)
       ,@i_spouse_dob                VARCHAR(50)
       ,@i_spouses_age_minimum       VARCHAR(50)
       ,@i_spouses_age_limit         VARCHAR(50)
       ,@i_spouses_age_option        VARCHAR(50)
       ,@i_dependents_covd           VARCHAR(50)
       ,@i_dependent_dob             VARCHAR(50)
       ,@i_dependent_age_minimum     VARCHAR(50)
       ,@i_dependent_age_limit       VARCHAR(50)
       ,@i_dependent_age_option      VARCHAR(50)
       ,@i_students_covd             VARCHAR(50)
       ,@i_student_age_minimum       VARCHAR(50)
       ,@i_student_age_limit         VARCHAR(50)
       ,@i_student_age_option        VARCHAR(50)
       ,@i_irs_dependent_covd        VARCHAR(50)
       ,@i_adult_dep_covd            VARCHAR(50)
       ,@i_irs_age_minimum           VARCHAR(50)
       ,@i_irs_age_limit             VARCHAR(50)
       ,@i_irs_dependent_age_option  VARCHAR(50)
       ,@i_domestic_partner_covd     VARCHAR(50)
       ,@i_disabled_dep_covered      VARCHAR(50)
       ,@i_emp_min_hours             VARCHAR(50)
       ,@i_verify_cob_65             VARCHAR(50)
       ,@i_max_age_to_view_dep_info  VARCHAR(50)
       ,@i_enable_ptd_logic          VARCHAR(50)
       ,@i_min_claim_amt             VARCHAR(50)
       ,@i_COBFrequencyOption        VARCHAR(50)
       ,@i_COBStepTherapyOption      VARCHAR(50)
       ,@i_AutoMembers               VARCHAR(50)
       ,@i_AutoClaims                VARCHAR(50)
       ,@i_waiting_period_option     VARCHAR(50)
       ,@i_new_emp_wait_period       VARCHAR(50)
       ,@i_new_emp_wait_amount       VARCHAR(50)
       ,@i_new_emp_wait_period_2     VARCHAR(50)
       ,@i_new_emp_wait_amount_2     VARCHAR(50)
       ,@i_reinstatement_period      VARCHAR(50)
       ,@i_rehire_wait_days          VARCHAR(50)
       ,@i_retro_time_period         VARCHAR(50)
       ,@i_retro_num_periods         VARCHAR(50)
       ,@i_pcp_coverage_start_period VARCHAR(50)
       ,@i_coverage_term_period      VARCHAR(50)
       ,@i_pcp_coverage_term_period  VARCHAR(50)
       ,@i_hire_period_desc          VARCHAR(250)
       ,@i_TermID                    VARCHAR(50)
       ,@i_TermDesc                  VARCHAR(100)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(200)
       ,@return_xml                  XML

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#EligibilityValidationVariations') IS NOT NULL
	DROP TABLE #EligibilityValidationVariations

CREATE TABLE #EligibilityValidationVariations
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Eligibility_Validation')
      ,i_elig_validation_gid       VARCHAR(50)       DEFAULT('0')
      ,i_elig_sid                  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified        VARCHAR(30)       DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,i_elig_validation_id        VARCHAR(50)
      ,i_elig_val_description      VARCHAR(75)
      ,i_effective_date            VARCHAR(50)
      ,i_termination_date          VARCHAR(50)
      ,i_state                     VARCHAR(50)
      ,i_subscriber_covd           VARCHAR(50)
      ,i_subscriber_dob            VARCHAR(50)
      ,i_subscriber_age_minimum    VARCHAR(50)
      ,i_subscriber_age_limit      VARCHAR(50)
      ,i_subscriber_age_option     VARCHAR(50)
      ,i_spouses_covd              VARCHAR(50)
      ,i_spouse_dob                VARCHAR(50)
      ,i_spouses_age_minimum       VARCHAR(50)
      ,i_spouses_age_limit         VARCHAR(50)
      ,i_spouses_age_option        VARCHAR(50)
      ,i_dependents_covd           VARCHAR(50)
      ,i_dependent_dob             VARCHAR(50)
      ,i_dependent_age_minimum     VARCHAR(50)
      ,i_dependent_age_limit       VARCHAR(50)
      ,i_dependent_age_option      VARCHAR(50)
      ,i_students_covd             VARCHAR(50)
      ,i_student_age_minimum       VARCHAR(50)
      ,i_student_age_limit         VARCHAR(50)
      ,i_student_age_option        VARCHAR(50)
      ,i_irs_dependent_covd        VARCHAR(50)
      ,i_adult_dep_covd            VARCHAR(50)
      ,i_irs_age_minimum           VARCHAR(50)
      ,i_irs_age_limit             VARCHAR(50)
      ,i_irs_dependent_age_option  VARCHAR(50)
      ,i_domestic_partner_covd     VARCHAR(50)
      ,i_disabled_dep_covered      VARCHAR(50)
      ,i_emp_min_hours             VARCHAR(50)
      ,i_verify_cob_65             VARCHAR(50)
      ,i_max_age_to_view_dep_info  VARCHAR(50)
      ,i_enable_ptd_logic          VARCHAR(50)
      ,i_min_claim_amt             VARCHAR(50)
      ,i_COBFrequencyOption        VARCHAR(50)
      ,i_COBStepTherapyOption      VARCHAR(50)
      ,i_AutoMembers               VARCHAR(50)
      ,i_AutoClaims                VARCHAR(50)
      ,i_waiting_period_option     VARCHAR(50)
      ,i_new_emp_wait_period       VARCHAR(50)
      ,i_new_emp_wait_amount       VARCHAR(50)
      ,i_new_emp_wait_period_2     VARCHAR(50)
      ,i_new_emp_wait_amount_2     VARCHAR(50)
      ,i_reinstatement_period      VARCHAR(50)
      ,i_rehire_wait_days          VARCHAR(50)
      ,i_retro_time_period         VARCHAR(50)
      ,i_retro_num_periods         VARCHAR(50)
      ,i_pcp_coverage_start_period VARCHAR(50)
      ,i_coverage_term_period      VARCHAR(50)
      ,i_pcp_coverage_term_period  VARCHAR(50)
      ,i_hire_period_desc          VARCHAR(250)
      ,i_TermID                    VARCHAR(50)
      ,i_TermDesc                  VARCHAR(100)
      ,o_status                    INT
      ,o_message                   VARCHAR(200)
      ,return_xml                  XML
      ,record_id                   INT
      ,static_gid                  INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #EligibilityValidationVariations
          (SearchID
          ,i_effective_date
          ,i_termination_date
          ,i_state
          ,i_subscriber_covd
          ,i_subscriber_dob
          ,i_subscriber_age_minimum
          ,i_subscriber_age_limit
          ,i_subscriber_age_option
          ,i_spouses_covd
          ,i_spouse_dob
          ,i_spouses_age_minimum
          ,i_spouses_age_limit
          ,i_spouses_age_option
          ,i_dependents_covd
          ,i_dependent_dob
          ,i_dependent_age_minimum
          ,i_dependent_age_limit
          ,i_dependent_age_option
          ,i_students_covd
          ,i_student_age_minimum
          ,i_student_age_limit
          ,i_student_age_option
          ,i_irs_dependent_covd
          ,i_adult_dep_covd
          ,i_irs_age_minimum
          ,i_irs_age_limit
          ,i_irs_dependent_age_option
          ,i_domestic_partner_covd
          ,i_disabled_dep_covered
          ,i_emp_min_hours
          ,i_verify_cob_65
          ,i_max_age_to_view_dep_info
		  ,i_enable_ptd_logic
          ,i_min_claim_amt
          ,i_COBFrequencyOption
		  ,i_COBStepTherapyOption
          ,i_AutoMembers
          ,i_AutoClaims
		  ,i_waiting_period_option
          ,i_new_emp_wait_period
          ,i_new_emp_wait_amount
		  ,i_new_emp_wait_period_2
          ,i_new_emp_wait_amount_2
          ,i_reinstatement_period
          ,i_rehire_wait_days
          ,i_pcp_coverage_start_period
          ,i_coverage_term_period
		  ,i_pcp_coverage_term_period
		  ,i_hire_period_desc
          ,i_TermID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*Common_TerminationDate], '12/31/9999')
          ,ISNULL([*Common_State], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubscriberCovered]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubDOBRequired]), 'Y')
          ,ISNULL([Common_SubAgeMinimum], '0')
          ,ISNULL([Common_SubAgeLimit], '999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SubAgeOption]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SpouseCovered]), 'Y')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SpsDOBRequired]), 'Y')
          ,ISNULL([Common_SpsAgeMinimum], '0')
          ,ISNULL([Common_SpsAgeLimit], '999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SpsAgeOption]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DepCovered]), 'Y')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DepDOBRequired]), 'Y')
          ,ISNULL([Common_DepAgeMinimum], '0')
          ,ISNULL([Common_DepAgeLimit], '18')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DepAgeOption]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_StudentsCovered]), 'Y')
          ,ISNULL([Common_StudentAgeMiminum], '0')
          ,ISNULL([Common_StudentAgeLimit], '22')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_StudentAgeOption]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_IRSDepCovered]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AdultDepCovered]), 'N')
          ,ISNULL([Common_IRSDepAgeMinimum], '0')
          ,ISNULL([Common_IRSDepAgeLimit], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_IRSDepAgeOption]), '')
          ,ISNULL([Common_DomesticPartnerCovered], 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_HandicappedDepCovered]), 'N')
          ,ISNULL([Common_MinimumHoursWorked], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_VerifyCOBAtAge65]), 'N')
          ,ISNULL([Common_MaxAgeToViewDependentInfo], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_EnableIndividualClaimTolerance]), 'N')
          ,ISNULL([Common_IgnorePTDWhenClaimLessThan], '0.00')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CodeFrequency]), 'G')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CodeStepTherapy]), 'G')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AutoUpdateAllMembers]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AutoResubmitMembersClaims]), 'N')
          ,ISNULL([PeriodValid_NewHireWaitPerOption], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_NewHireWaitPeriod1]), 'D')
          ,ISNULL([PeriodValid_NewHireWaitUnits1], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_NewHireWaitPeriod2]), 'D')
          ,ISNULL([PeriodValid_NewHireWaitUnits2], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_ReinstatementPeriod]), 'Y')
          ,ISNULL([PeriodValid_ReinstatementUnits], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_PCPStartPeriod]), 'D')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_CoverageTermPeriod]), 'D')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PeriodValid_PCPTermPeriod]), 'D')
          ,ISNULL([PeriodValid_HirePeriodDesc], '')
          ,ISNULL([PeriodValid_TermDefinitionID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], -1)
      FROM COREAUTO.CoreAutomation.dbo.TD_EligibilityValidationVariations
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #EligibilityValidationVariations
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
DECLARE EligibilityValidationVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_elig_validation_gid
       ,i_elig_sid
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
       ,i_elig_validation_id
       ,i_elig_val_description
       ,i_effective_date
       ,i_termination_date
       ,i_state
       ,i_subscriber_covd
       ,i_subscriber_dob
       ,i_subscriber_age_minimum
       ,i_subscriber_age_limit
       ,i_subscriber_age_option
       ,i_spouses_covd
       ,i_spouse_dob
       ,i_spouses_age_minimum
       ,i_spouses_age_limit
       ,i_spouses_age_option
       ,i_dependents_covd
       ,i_dependent_dob
       ,i_dependent_age_minimum
       ,i_dependent_age_limit
       ,i_dependent_age_option
       ,i_students_covd
       ,i_student_age_minimum
       ,i_student_age_limit
       ,i_student_age_option
       ,i_irs_dependent_covd
       ,i_adult_dep_covd
       ,i_irs_age_minimum
       ,i_irs_age_limit
       ,i_irs_dependent_age_option
       ,i_domestic_partner_covd
       ,i_disabled_dep_covered
       ,i_emp_min_hours
       ,i_verify_cob_65
       ,i_max_age_to_view_dep_info
       ,i_enable_ptd_logic
       ,i_min_claim_amt
       ,i_COBFrequencyOption
       ,i_COBStepTherapyOption
       ,i_AutoMembers
       ,i_AutoClaims
       ,i_waiting_period_option
       ,i_new_emp_wait_period
       ,i_new_emp_wait_amount
       ,i_new_emp_wait_period_2
       ,i_new_emp_wait_amount_2
       ,i_reinstatement_period
       ,i_rehire_wait_days
       ,i_retro_time_period
       ,i_retro_num_periods
       ,i_pcp_coverage_start_period
       ,i_coverage_term_period
       ,i_pcp_coverage_term_period
       ,i_hire_period_desc
       ,i_TermID
       ,i_TermDesc
       ,o_status
       ,o_message
       ,return_xml
       ,record_id
       ,static_gid
   FROM #EligibilityValidationVariations

   OPEN EligibilityValidationVariations_Cursor
  FETCH NEXT FROM EligibilityValidationVariations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_elig_validation_gid
       ,@i_elig_sid
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
       ,@i_elig_validation_id
       ,@i_elig_val_description
       ,@i_effective_date
       ,@i_termination_date
       ,@i_state
       ,@i_subscriber_covd
       ,@i_subscriber_dob
       ,@i_subscriber_age_minimum
       ,@i_subscriber_age_limit
       ,@i_subscriber_age_option
       ,@i_spouses_covd
       ,@i_spouse_dob
       ,@i_spouses_age_minimum
       ,@i_spouses_age_limit
       ,@i_spouses_age_option
       ,@i_dependents_covd
       ,@i_dependent_dob
       ,@i_dependent_age_minimum
       ,@i_dependent_age_limit
       ,@i_dependent_age_option
       ,@i_students_covd
       ,@i_student_age_minimum
       ,@i_student_age_limit
       ,@i_student_age_option
       ,@i_irs_dependent_covd
       ,@i_adult_dep_covd
       ,@i_irs_age_minimum
       ,@i_irs_age_limit
       ,@i_irs_dependent_age_option
       ,@i_domestic_partner_covd
       ,@i_disabled_dep_covered
       ,@i_emp_min_hours
       ,@i_verify_cob_65
       ,@i_max_age_to_view_dep_info
       ,@i_enable_ptd_logic
       ,@i_min_claim_amt
       ,@i_COBFrequencyOption
       ,@i_COBStepTherapyOption
       ,@i_AutoMembers
       ,@i_AutoClaims
       ,@i_waiting_period_option
       ,@i_new_emp_wait_period
       ,@i_new_emp_wait_amount
       ,@i_new_emp_wait_period_2
       ,@i_new_emp_wait_amount_2
       ,@i_reinstatement_period
       ,@i_rehire_wait_days
       ,@i_retro_time_period
       ,@i_retro_num_periods
       ,@i_pcp_coverage_start_period
       ,@i_coverage_term_period
       ,@i_pcp_coverage_term_period
       ,@i_hire_period_desc
       ,@i_TermID
       ,@i_TermDesc
       ,@o_status
       ,@o_message
       ,@return_xml
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @i_elig_validation_id = ''

			SELECT @i_elig_validation_id	= EN.entity_user_id
			      ,@i_elig_validation_gid	= EN.entity_gid
			  FROM dbo.Entity_Names			EN
			 WHERE record_status			= 'A'
			   AND entity_identifier		= 'Eligibility_Validation'
			   AND entity_user_id			= @SearchID

			IF @i_elig_validation_id <> ''
				BEGIN

					EXEC dbo.prEligValidationAddModify
						 @i_entity_name
						,@i_elig_validation_gid
						,@i_elig_sid
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
						,@i_elig_validation_id
						,@i_elig_val_description
						,@i_effective_date
						,@i_termination_date
						,@i_state
						,@i_subscriber_covd
						,@i_subscriber_dob
						,@i_subscriber_age_minimum
						,@i_subscriber_age_limit
						,@i_subscriber_age_option
						,@i_spouses_covd
						,@i_spouse_dob
						,@i_spouses_age_minimum
						,@i_spouses_age_limit
						,@i_spouses_age_option
						,@i_dependents_covd
						,@i_dependent_dob
						,@i_dependent_age_minimum
						,@i_dependent_age_limit
						,@i_dependent_age_option
						,@i_students_covd
						,@i_student_age_minimum
						,@i_student_age_limit
						,@i_student_age_option
						,@i_irs_dependent_covd
						,@i_adult_dep_covd
						,@i_irs_age_minimum
						,@i_irs_age_limit
						,@i_irs_dependent_age_option
						,@i_domestic_partner_covd
						,@i_disabled_dep_covered
						,@i_emp_min_hours
						,@i_verify_cob_65
						,@i_max_age_to_view_dep_info
						,@i_enable_ptd_logic
						,@i_min_claim_amt
						,@i_COBFrequencyOption
						,@i_COBStepTherapyOption
						,@i_AutoMembers
						,@i_AutoClaims
						,@i_waiting_period_option
						,@i_new_emp_wait_period
						,@i_new_emp_wait_amount
						,@i_new_emp_wait_period_2
						,@i_new_emp_wait_amount_2
						,@i_reinstatement_period
						,@i_rehire_wait_days
						,@i_retro_time_period
						,@i_retro_num_periods
						,@i_pcp_coverage_start_period
						,@i_coverage_term_period
						,@i_pcp_coverage_term_period
						,@i_hire_period_desc
						,@i_TermID
						,@i_TermDesc
						,@o_status     = @err_num OUTPUT
						,@o_message    = @err_msg OUTPUT
						--,@return_xml
				END
			ELSE
				BEGIN
					SELECT @err_num = 1016
					      ,@err_msg = 'Eligibility Validation, ' + @SearchID + ', could not be found.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_state, @i_effective_date, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM EligibilityValidationVariations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_elig_validation_gid
             ,@i_elig_sid
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
             ,@i_elig_validation_id
             ,@i_elig_val_description
             ,@i_effective_date
             ,@i_termination_date
             ,@i_state
             ,@i_subscriber_covd
             ,@i_subscriber_dob
             ,@i_subscriber_age_minimum
             ,@i_subscriber_age_limit
             ,@i_subscriber_age_option
             ,@i_spouses_covd
             ,@i_spouse_dob
             ,@i_spouses_age_minimum
             ,@i_spouses_age_limit
             ,@i_spouses_age_option
             ,@i_dependents_covd
             ,@i_dependent_dob
             ,@i_dependent_age_minimum
             ,@i_dependent_age_limit
             ,@i_dependent_age_option
             ,@i_students_covd
             ,@i_student_age_minimum
             ,@i_student_age_limit
             ,@i_student_age_option
             ,@i_irs_dependent_covd
             ,@i_adult_dep_covd
             ,@i_irs_age_minimum
             ,@i_irs_age_limit
             ,@i_irs_dependent_age_option
             ,@i_domestic_partner_covd
             ,@i_disabled_dep_covered
             ,@i_emp_min_hours
             ,@i_verify_cob_65
             ,@i_max_age_to_view_dep_info
             ,@i_enable_ptd_logic
             ,@i_min_claim_amt
             ,@i_COBFrequencyOption
             ,@i_COBStepTherapyOption
             ,@i_AutoMembers
             ,@i_AutoClaims
             ,@i_waiting_period_option
             ,@i_new_emp_wait_period
             ,@i_new_emp_wait_amount
             ,@i_new_emp_wait_period_2
             ,@i_new_emp_wait_amount_2
             ,@i_reinstatement_period
             ,@i_rehire_wait_days
             ,@i_retro_time_period
             ,@i_retro_num_periods
             ,@i_pcp_coverage_start_period
             ,@i_coverage_term_period
             ,@i_pcp_coverage_term_period
             ,@i_hire_period_desc
             ,@i_TermID
             ,@i_TermDesc
             ,@o_status
             ,@o_message
             ,@return_xml
             ,@record_id
             ,@static_gid
	END

CLOSE EligibilityValidationVariations_Cursor
DEALLOCATE EligibilityValidationVariations_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#EligibilityValidationVariations') IS NOT NULL
	DROP TABLE #EligibilityValidationVariations

END
GO

