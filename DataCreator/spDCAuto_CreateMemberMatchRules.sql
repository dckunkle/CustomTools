IF OBJECT_ID('dbo.spDCAuto_CreateMemberMatchRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberMatchRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberMatchRules
Purpose:    Create membermatchrules data from CorderAutomation
Method:     MemberMatchRules
Screen GID: 21
Procedure:  dbo.prMemberMatchRuleAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/26/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberMatchRules '100-Config%', 22, 'MemberMatchRules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberMatchRules
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

DECLARE @i_entity_name                VARCHAR(20)
       ,@i_key_RuleGid                VARCHAR(20)
       ,@i_key_member_match_rules_gid VARCHAR(50)
       ,@i_key_3_field                VARCHAR(10)
       ,@iHeaderType                  VARCHAR(50)
       ,@i_key_5_field                VARCHAR(50)
       ,@i_key_6_field                VARCHAR(50)
       ,@i_key_7_field                VARCHAR(50)
       ,@i_key_8_field                VARCHAR(10)
       ,@i_key_9_field                VARCHAR(10)
       ,@i_key_10_field               VARCHAR(10)
       ,@i_action                     VARCHAR(10)
       ,@i_date_time_modified         VARCHAR(10)
       ,@iUserID                      VARCHAR(25)
       ,@i_Effective_date             VARCHAR(50)
       ,@i_Termination_date           VARCHAR(10)
       ,@i_Type                       VARCHAR(50)
       ,@i_Priority                   VARCHAR(50)
       ,@i_SSN                        VARCHAR(50)
       ,@i_Member_id_rule             VARCHAR(50)
       ,@i_Alias_rule                 VARCHAR(10)
       ,@i_Other_Parent_id_rule       VARCHAR(50)
       ,@i_REF17MemberID              VARCHAR(10)
       ,@i_REF23MemberID              VARCHAR(50)
       ,@i_REF6OMemberID              VARCHAR(10)
       ,@i_REFZZMemberID              VARCHAR(50)
       ,@i_Last_name_rule             VARCHAR(50)
       ,@i_Last_Name_max_chars        VARCHAR(50)
       ,@i_First_name_rule            VARCHAR(50)
       ,@i_First_Name_max_chars       VARCHAR(50)
       ,@i_Middle_name_rule           VARCHAR(50)
       ,@i_Middle_Name_max_chars      VARCHAR(50)
       ,@i_relationship_rule          VARCHAR(10)
       ,@i_Birth_date_rule            VARCHAR(10)
       ,@i_Person_code_rule           VARCHAR(50)
       ,@i_gender_rule                VARCHAR(50)
       ,@o_status                     INT
       ,@o_message                    VARCHAR(1000)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberMatchRules') IS NOT NULL
	DROP TABLE #MemberMatchRules

CREATE TABLE #MemberMatchRules
      (SearchID                     VARCHAR(200)
      ,i_entity_name                VARCHAR(20)       DEFAULT('MEMBER_MATCH_RULE')
      ,i_key_RuleGid                VARCHAR(20)       DEFAULT('0')
      ,i_key_member_match_rules_gid VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                VARCHAR(10)       DEFAULT('0')
      ,iHeaderType                  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                VARCHAR(10)       DEFAULT('0')
      ,i_key_9_field                VARCHAR(10)       DEFAULT('0')
      ,i_key_10_field               VARCHAR(10)       DEFAULT('0')
      ,i_action                     VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified         VARCHAR(10)       DEFAULT('')
      ,iUserID                      VARCHAR(25)       DEFAULT('')
      ,i_Effective_date             VARCHAR(50)
      ,i_Termination_date           VARCHAR(10)
      ,i_Type                       VARCHAR(50)
      ,i_Priority                   VARCHAR(50)
      ,i_SSN                        VARCHAR(50)
      ,i_Member_id_rule             VARCHAR(50)
      ,i_Alias_rule                 VARCHAR(10)
      ,i_Other_Parent_id_rule       VARCHAR(50)
      ,i_REF17MemberID              VARCHAR(10)
      ,i_REF23MemberID              VARCHAR(50)
      ,i_REF6OMemberID              VARCHAR(10)
      ,i_REFZZMemberID              VARCHAR(50)
      ,i_Last_name_rule             VARCHAR(50)
      ,i_Last_Name_max_chars        VARCHAR(50)
      ,i_First_name_rule            VARCHAR(50)
      ,i_First_Name_max_chars       VARCHAR(50)
      ,i_Middle_name_rule           VARCHAR(50)
      ,i_Middle_Name_max_chars      VARCHAR(50)
      ,i_relationship_rule          VARCHAR(10)
      ,i_Birth_date_rule            VARCHAR(10)
      ,i_Person_code_rule           VARCHAR(50)
      ,i_gender_rule                VARCHAR(50)
      ,o_status                     INT
      ,o_message                    VARCHAR(1000)
      ,record_id                    INT
      ,static_gid                   INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberMatchRules
      (SearchID
      ,i_Effective_date             
      ,i_Termination_date           
      ,i_Priority                   
      ,i_SSN                        
      ,i_Member_id_rule             
      ,i_Alias_rule                
      ,i_Other_Parent_id_rule       
      ,i_REF17MemberID              
      ,i_REF23MemberID              
      ,i_REF6OMemberID             
      ,i_REFZZMemberID             
      ,i_Last_name_rule             
      ,i_Last_Name_max_chars        
      ,i_First_name_rule            
      ,i_First_Name_max_chars      
      ,i_Middle_name_rule           
      ,i_Middle_Name_max_chars     
      ,i_relationship_rule        
      ,i_Birth_date_rule            
      ,i_Person_code_rule           
      ,i_gender_rule               
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([*Priority], '-1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SSN]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MemberID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Alias]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OtherParentID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([REF*17HIPAAID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([REF*23CarrierIndivudualID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PolicyID/EnrollmentID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([REF*ZZCarrierMemberID]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LastName]), 'N')
      ,ISNULL([MaxChars1], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FirstName]), 'N')
      ,ISNULL([MaxChars2], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MiddleName]), 'N')
      ,ISNULL([MaxChars3], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RelaionShip]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DateofBirth]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PersonCode]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Gender]), 'N')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberMatchRules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberMatchRules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberMatchRules_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_RuleGid
       ,i_key_member_match_rules_gid
       ,i_key_3_field
       ,iHeaderType
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Effective_date
       ,i_Termination_date
       ,i_Type
       ,i_Priority
       ,i_SSN
       ,i_Member_id_rule
       ,i_Alias_rule
       ,i_Other_Parent_id_rule
       ,i_REF17MemberID
       ,i_REF23MemberID
       ,i_REF6OMemberID
       ,i_REFZZMemberID
       ,i_Last_name_rule
       ,i_Last_Name_max_chars
       ,i_First_name_rule
       ,i_First_Name_max_chars
       ,i_Middle_name_rule
       ,i_Middle_Name_max_chars
       ,i_relationship_rule
       ,i_Birth_date_rule
       ,i_Person_code_rule
       ,i_gender_rule
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberMatchRules

   OPEN MemberMatchRules_Cursor
  FETCH NEXT FROM MemberMatchRules_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_RuleGid
       ,@i_key_member_match_rules_gid
       ,@i_key_3_field
       ,@iHeaderType
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Effective_date
       ,@i_Termination_date
       ,@i_Type
       ,@i_Priority
       ,@i_SSN
       ,@i_Member_id_rule
       ,@i_Alias_rule
       ,@i_Other_Parent_id_rule
       ,@i_REF17MemberID
       ,@i_REF23MemberID
       ,@i_REF6OMemberID
       ,@i_REFZZMemberID
       ,@i_Last_name_rule
       ,@i_Last_Name_max_chars
       ,@i_First_name_rule
       ,@i_First_Name_max_chars
       ,@i_Middle_name_rule
       ,@i_Middle_Name_max_chars
       ,@i_relationship_rule
       ,@i_Birth_date_rule
       ,@i_Person_code_rule
       ,@i_gender_rule
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the GID for the proper member match
			SELECT @i_key_RuleGid			= EN.entity_gid
			      ,@iHeaderType				= SUBSTRING(EN.support_codes, 3, 1)		-- Get the type
			  FROM Entity_Names				EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_identifier		= 'MEMBER_MATCHING'
			   AND EN.entity_user_id		= @SearchID

			EXEC dbo.prMemberMatchRuleAddModify
             @i_entity_name
            ,@i_key_RuleGid
            ,@i_key_member_match_rules_gid
            ,@i_key_3_field
            ,@iHeaderType
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Effective_date
            ,@i_Termination_date
            ,@i_Type
            ,@i_Priority
            ,@i_SSN
            ,@i_Member_id_rule
            ,@i_Alias_rule
            ,@i_Other_Parent_id_rule
            ,@i_REF17MemberID
            ,@i_REF23MemberID
            ,@i_REF6OMemberID
            ,@i_REFZZMemberID
            ,@i_Last_name_rule
            ,@i_Last_Name_max_chars
            ,@i_First_name_rule
            ,@i_First_Name_max_chars
            ,@i_Middle_name_rule
            ,@i_Middle_Name_max_chars
            ,@i_relationship_rule
            ,@i_Birth_date_rule
            ,@i_Person_code_rule
            ,@i_gender_rule
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Member_id_rule, '', @status, @err_num, @err_msg

        FETCH NEXT FROM MemberMatchRules_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_RuleGid
             ,@i_key_member_match_rules_gid
             ,@i_key_3_field
             ,@iHeaderType
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Effective_date
             ,@i_Termination_date
             ,@i_Type
             ,@i_Priority
             ,@i_SSN
             ,@i_Member_id_rule
             ,@i_Alias_rule
             ,@i_Other_Parent_id_rule
             ,@i_REF17MemberID
             ,@i_REF23MemberID
             ,@i_REF6OMemberID
             ,@i_REFZZMemberID
             ,@i_Last_name_rule
             ,@i_Last_Name_max_chars
             ,@i_First_name_rule
             ,@i_First_Name_max_chars
             ,@i_Middle_name_rule
             ,@i_Middle_Name_max_chars
             ,@i_relationship_rule
             ,@i_Birth_date_rule
             ,@i_Person_code_rule
             ,@i_gender_rule
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberMatchRules_Cursor
DEALLOCATE MemberMatchRules_Cursor

END
GO