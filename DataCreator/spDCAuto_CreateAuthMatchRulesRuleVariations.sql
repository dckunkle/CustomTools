IF OBJECT_ID('dbo.spDCAuto_CreateAuthMatchRulesRuleVariations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAuthMatchRulesRuleVariations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAuthMatchRulesRuleVariations
Purpose:    Create authmatchrulesrulevariations data from CorderAutomation
Method:     AuthMatchRulesRuleVariations
Screen GID: 11000
Procedure:  dbo.prAuthMatchDetailAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAuthMatchRulesRuleVariations '100-Config%', 22, 'AuthMatchRulesRuleVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAuthMatchRulesRuleVariations
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

DECLARE @i_Entity_name              VARCHAR(50)
       ,@i_Header_GID               INT
       ,@i_Detail_SID               INT
       ,@i_key_3_field              VARCHAR(50)
       ,@i_key_4_field              VARCHAR(50)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(10)
       ,@i_date_modified            VARCHAR(50)
       ,@iUserID                    VARCHAR(25)
       ,@i_auth_match_id            VARCHAR(50)
       ,@i_auth_match_desc          VARCHAR(50)
       ,@i_effective_date           VARCHAR(50)
       ,@i_termination_date         VARCHAR(50)
       ,@i_claim_type               VARCHAR(50)
       ,@i_priority                 VARCHAR(50)
       ,@i_rendering_id_match       VARCHAR(50)
       ,@i_rendering_svc_match      VARCHAR(50)
       ,@i_rendering_tin_match      VARCHAR(50)
       ,@i_rendering_bus_match      VARCHAR(50)
       ,@i_referring_id_match       VARCHAR(50)
       ,@i_code_id_match            VARCHAR(50)
       ,@i_benefit_class_match      VARCHAR(50)
       ,@i_diagnosis_match          VARCHAR(50)
       ,@i_diagnosis_relation_match VARCHAR(50)
       ,@i_modifier_match           VARCHAR(50)
       ,@i_tooth_match              VARCHAR(50)
       ,@i_surface_match            VARCHAR(50)
       ,@i_svc_from_match           VARCHAR(50)
       ,@i_svc_to_match             VARCHAR(50)
       ,@i_svc_within_match         VARCHAR(50)
       ,@i_pos_tob_match            VARCHAR(50)
       ,@iRemarkCode                VARCHAR(50)
       ,@iRemarkDesc                VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AuthMatchRulesRuleVariations') IS NOT NULL
	DROP TABLE #AuthMatchRulesRuleVariations

CREATE TABLE #AuthMatchRulesRuleVariations
      (SearchID                   VARCHAR(200)
      ,i_Entity_name              VARCHAR(50)       DEFAULT('Auth_Match_Detail')
      ,i_Header_GID               INT       DEFAULT('0')
      ,i_Detail_SID               INT       DEFAULT('0')
      ,i_key_3_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field             VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(10)       DEFAULT('ADD')
      ,i_date_modified            VARCHAR(50)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,i_auth_match_id            VARCHAR(50)
      ,i_auth_match_desc          VARCHAR(50)
      ,i_effective_date           VARCHAR(50)
      ,i_termination_date         VARCHAR(50)
      ,i_claim_type               VARCHAR(50)
      ,i_priority                 VARCHAR(50)
      ,i_rendering_id_match       VARCHAR(50)
      ,i_rendering_svc_match      VARCHAR(50)
      ,i_rendering_tin_match      VARCHAR(50)
      ,i_rendering_bus_match      VARCHAR(50)
      ,i_referring_id_match       VARCHAR(50)
      ,i_code_id_match            VARCHAR(50)
      ,i_benefit_class_match      VARCHAR(50)
      ,i_diagnosis_match          VARCHAR(50)
      ,i_diagnosis_relation_match VARCHAR(50)
      ,i_modifier_match           VARCHAR(50)
      ,i_tooth_match              VARCHAR(50)
      ,i_surface_match            VARCHAR(50)
      ,i_svc_from_match           VARCHAR(50)
      ,i_svc_to_match             VARCHAR(50)
      ,i_svc_within_match         VARCHAR(50)
      ,i_pos_tob_match            VARCHAR(50)
      ,iRemarkCode                VARCHAR(50)
      ,iRemarkDesc                VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(100)
      ,record_id                  INT
      ,static_gid                 INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AuthMatchRulesRuleVariations
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_claim_type
      ,i_priority
      ,i_rendering_id_match
      ,i_rendering_svc_match
      ,i_rendering_tin_match
      ,i_rendering_bus_match
      ,i_referring_id_match
      ,i_code_id_match
      ,i_benefit_class_match
      ,i_diagnosis_match
      ,i_diagnosis_relation_match
      ,i_modifier_match
      ,i_tooth_match
      ,i_surface_match
      ,i_svc_from_match
      ,i_svc_to_match
      ,i_svc_within_match
      ,i_pos_tob_match
      ,iRemarkCode
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], '01/01/1900')
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ClaimType]), '')
      ,ISNULL([*Priority], '-1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RenderingID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RenderingSvcLocation]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RenderingTIN]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RenderingBusinessUnit]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReferringID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CodeID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenefitClass]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Diagnosis]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DiagnosisRelation]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Modifier_MedicalOnly]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Tooth_DentalOnly]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Surface_DentalOnly]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SvcFromDate]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SvcEndDate]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SvcWithinAuthDates]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AuthPOSToClaimPOS_TOB]), 'N')
      ,ISNULL([RemarkCode], '')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_AuthMatchRulesRuleVariations
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AuthMatchRulesRuleVariations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AuthMatchRulesRuleVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_Header_GID
       ,i_Detail_SID
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_modified
       ,iUserID
       ,i_auth_match_id
       ,i_auth_match_desc
       ,i_effective_date
       ,i_termination_date
       ,i_claim_type
       ,i_priority
       ,i_rendering_id_match
       ,i_rendering_svc_match
       ,i_rendering_tin_match
       ,i_rendering_bus_match
       ,i_referring_id_match
       ,i_code_id_match
       ,i_benefit_class_match
       ,i_diagnosis_match
       ,i_diagnosis_relation_match
       ,i_modifier_match
       ,i_tooth_match
       ,i_surface_match
       ,i_svc_from_match
       ,i_svc_to_match
       ,i_svc_within_match
       ,i_pos_tob_match
       ,iRemarkCode
       ,iRemarkDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AuthMatchRulesRuleVariations

   OPEN AuthMatchRulesRuleVariations_Cursor
  FETCH NEXT FROM AuthMatchRulesRuleVariations_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_Header_GID
       ,@i_Detail_SID
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_modified
       ,@iUserID
       ,@i_auth_match_id
       ,@i_auth_match_desc
       ,@i_effective_date
       ,@i_termination_date
       ,@i_claim_type
       ,@i_priority
       ,@i_rendering_id_match
       ,@i_rendering_svc_match
       ,@i_rendering_tin_match
       ,@i_rendering_bus_match
       ,@i_referring_id_match
       ,@i_code_id_match
       ,@i_benefit_class_match
       ,@i_diagnosis_match
       ,@i_diagnosis_relation_match
       ,@i_modifier_match
       ,@i_tooth_match
       ,@i_surface_match
       ,@i_svc_from_match
       ,@i_svc_to_match
       ,@i_svc_within_match
       ,@i_pos_tob_match
       ,@iRemarkCode
       ,@iRemarkDesc
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
			SELECT @i_Header_GID			= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'Auth_Match_Header'

			EXEC dbo.prAuthMatchDetailAddModify
             @i_Entity_name
            ,@i_Header_GID
            ,@i_Detail_SID
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_modified
            ,@iUserID
            ,@i_auth_match_id
            ,@i_auth_match_desc
            ,@i_effective_date
            ,@i_termination_date
            ,@i_claim_type
            ,@i_priority
            ,@i_rendering_id_match
            ,@i_rendering_svc_match
            ,@i_rendering_tin_match
            ,@i_rendering_bus_match
            ,@i_referring_id_match
            ,@i_code_id_match
            ,@i_benefit_class_match
            ,@i_diagnosis_match
            ,@i_diagnosis_relation_match
            ,@i_modifier_match
            ,@i_tooth_match
            ,@i_surface_match
            ,@i_svc_from_match
            ,@i_svc_to_match
            ,@i_svc_within_match
            ,@i_pos_tob_match
            ,@iRemarkCode
            ,@iRemarkDesc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_claim_type, '', @status, @err_num, @err_msg

        FETCH NEXT FROM AuthMatchRulesRuleVariations_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_Header_GID
             ,@i_Detail_SID
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_modified
             ,@iUserID
             ,@i_auth_match_id
             ,@i_auth_match_desc
             ,@i_effective_date
             ,@i_termination_date
             ,@i_claim_type
             ,@i_priority
             ,@i_rendering_id_match
             ,@i_rendering_svc_match
             ,@i_rendering_tin_match
             ,@i_rendering_bus_match
             ,@i_referring_id_match
             ,@i_code_id_match
             ,@i_benefit_class_match
             ,@i_diagnosis_match
             ,@i_diagnosis_relation_match
             ,@i_modifier_match
             ,@i_tooth_match
             ,@i_surface_match
             ,@i_svc_from_match
             ,@i_svc_to_match
             ,@i_svc_within_match
             ,@i_pos_tob_match
             ,@iRemarkCode
             ,@iRemarkDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AuthMatchRulesRuleVariations_Cursor
DEALLOCATE AuthMatchRulesRuleVariations_Cursor

END
GO