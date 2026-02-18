IF OBJECT_ID('dbo.spDCAuto_CreateMemberRaceEthnicityLanguage') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberRaceEthnicityLanguage AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberRaceEthnicityLanguage
Purpose:    Create memberraceethnicitylanguage data from CorderAutomation
Method:     MemberRaceEthnicityLanguage
Screen GID: 950
Procedure:  dbo.prRaceEthnicityLanguage_AddModify 

Date        User            Change
---------------------------------------------------------------------------------------------
02/18/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberRaceEthnicityLanguage '100-Config%', 22, 'MemberRaceEthnicityLanguage'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberRaceEthnicityLanguage
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

DECLARE @i_entity_name                              VARCHAR(50)
       ,@i_key_1_child_gid                          VARCHAR(50)
       ,@i_key_2_parent_gid                         VARCHAR(50)
       ,@i_key_3_group_gid                          VARCHAR(50)
       ,@i_key_4_identified_race                    VARCHAR(50)
       ,@i_key_5_identified_ethnicity               VARCHAR(50)
       ,@i_key_6_preferred_language                 VARCHAR(50)
       ,@i_key_7_preferred_other_language           VARCHAR(50)
       ,@i_key_8_Member_Race_Ethnicity_Language_sid VARCHAR(50)
       ,@i_key_9_field                              VARCHAR(50)
       ,@i_key_10_field                             VARCHAR(50)
       ,@iAction                                    VARCHAR(10)
       ,@i_date_time_modified                       VARCHAR(20)
       ,@i_user_id                                  VARCHAR(20)
       ,@i_Stored_Ethnicity                         VARCHAR(50)
       ,@i_Member_Identified_Race                   VARCHAR(50)
       ,@i_Member_Identified_Ethnicity              VARCHAR(50)
       ,@i_Stored_Language_1                        VARCHAR(50)
       ,@i_Stored_Language_1_Use                    VARCHAR(50)
       ,@i_Stored_Language_2                        VARCHAR(50)
       ,@i_Stored_Language_2_Use                    VARCHAR(50)
       ,@i_Member_Preferred_Language                VARCHAR(50)
       ,@i_preferred_other_language                 VARCHAR(100)
       ,@o_status                                   INT
       ,@o_message                                  VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberRaceEthnicityLanguage') IS NOT NULL
	DROP TABLE #MemberRaceEthnicityLanguage

CREATE TABLE #MemberRaceEthnicityLanguage
      (SearchID                                   VARCHAR(200)
      ,i_entity_name                              VARCHAR(50)       DEFAULT('Race_Ethnicity_Language')
      ,i_key_1_child_gid                          VARCHAR(50)       DEFAULT('0')
      ,i_key_2_parent_gid                         VARCHAR(50)       DEFAULT('0')
      ,i_key_3_group_gid                          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_identified_race                    VARCHAR(50)       DEFAULT('0')
      ,i_key_5_identified_ethnicity               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_preferred_language                 VARCHAR(50)       DEFAULT('0')
      ,i_key_7_preferred_other_language           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_Member_Race_Ethnicity_Language_sid VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                             VARCHAR(50)       DEFAULT('0')
      ,iAction                                    VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified                       VARCHAR(20)       DEFAULT('')
      ,i_user_id                                  VARCHAR(20)       DEFAULT('')
      ,i_Stored_Ethnicity                         VARCHAR(50)
      ,i_Member_Identified_Race                   VARCHAR(50)
      ,i_Member_Identified_Ethnicity              VARCHAR(50)
      ,i_Stored_Language_1                        VARCHAR(50)
      ,i_Stored_Language_1_Use                    VARCHAR(50)
      ,i_Stored_Language_2                        VARCHAR(50)
      ,i_Stored_Language_2_Use                    VARCHAR(50)
      ,i_Member_Preferred_Language                VARCHAR(50)
      ,i_preferred_other_language                 VARCHAR(100)
      ,o_status                                   INT
      ,o_message                                  VARCHAR(255)
      ,record_id                                  INT
      ,static_gid                                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberRaceEthnicityLanguage
      (SearchID
	  ,i_Member_Identified_Race
      ,i_Member_Identified_Ethnicity
      ,i_Member_Preferred_Language
	  ,i_preferred_other_language
      ,record_id
      ,static_gid)
SELECT SearchID
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MemberIndentifiedRace]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MemberIdentifiedEthnicity]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MemberPreferredLanguage]), '')
      ,ISNULL([OtherLanguage], '')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberRaceEthnicityLanguage
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberRaceEthnicityLanguage
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberRaceEthnicityLanguage_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_child_gid
       ,i_key_2_parent_gid
       ,i_key_3_group_gid
       ,i_key_4_identified_race
       ,i_key_5_identified_ethnicity
       ,i_key_6_preferred_language
       ,i_key_7_preferred_other_language
       ,i_key_8_Member_Race_Ethnicity_Language_sid
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,i_date_time_modified
       ,i_user_id
       ,i_Stored_Ethnicity
       ,i_Member_Identified_Race
       ,i_Member_Identified_Ethnicity
       ,i_Stored_Language_1
       ,i_Stored_Language_1_Use
       ,i_Stored_Language_2
       ,i_Stored_Language_2_Use
       ,i_Member_Preferred_Language
       ,i_preferred_other_language
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberRaceEthnicityLanguage

   OPEN MemberRaceEthnicityLanguage_Cursor
  FETCH NEXT FROM MemberRaceEthnicityLanguage_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_child_gid
       ,@i_key_2_parent_gid
       ,@i_key_3_group_gid
       ,@i_key_4_identified_race
       ,@i_key_5_identified_ethnicity
       ,@i_key_6_preferred_language
       ,@i_key_7_preferred_other_language
       ,@i_key_8_Member_Race_Ethnicity_Language_sid
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@i_date_time_modified
       ,@i_user_id
       ,@i_Stored_Ethnicity
       ,@i_Member_Identified_Race
       ,@i_Member_Identified_Ethnicity
       ,@i_Stored_Language_1
       ,@i_Stored_Language_1_Use
       ,@i_Stored_Language_2
       ,@i_Stored_Language_2_Use
       ,@i_Member_Preferred_Language
       ,@i_preferred_other_language
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			--Get the GIDs for the member
			SELECT @i_key_1_child_gid		= EC.child_gid
			      ,@i_key_2_parent_gid		= EC.parent_gid
				  ,@i_key_3_group_gid		= EC.group_gid
			  FROM Eligibility_Coverage		EC
			 WHERE EC.record_status			= 'A'
			   AND EC.member_id				= @SearchID
			   AND EC.child_gid				= EC.parent_gid		-- Get the subscriber gids

			EXEC dbo.prRaceEthnicityLanguage_AddModify 
				 @i_entity_name
				,@i_key_1_child_gid
				,@i_key_2_parent_gid
				,@i_key_3_group_gid
				,@i_key_4_identified_race
				,@i_key_5_identified_ethnicity
				,@i_key_6_preferred_language
				,@i_key_7_preferred_other_language
				,@i_key_8_Member_Race_Ethnicity_Language_sid
				,@i_key_9_field
				,@i_key_10_field
				,@iAction
				,@i_date_time_modified
				,@i_user_id
				,@i_Stored_Ethnicity
				,@i_Member_Identified_Race
				,@i_Member_Identified_Ethnicity
				,@i_Stored_Language_1
				,@i_Stored_Language_1_Use
				,@i_Stored_Language_2
				,@i_Stored_Language_2_Use
				,@i_Member_Preferred_Language
				,@i_preferred_other_language
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Member_Identified_Race, @i_Member_Identified_Ethnicity, @status, @err_num, @err_msg

        FETCH NEXT FROM MemberRaceEthnicityLanguage_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_child_gid
             ,@i_key_2_parent_gid
             ,@i_key_3_group_gid
             ,@i_key_4_identified_race
             ,@i_key_5_identified_ethnicity
             ,@i_key_6_preferred_language
             ,@i_key_7_preferred_other_language
             ,@i_key_8_Member_Race_Ethnicity_Language_sid
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@i_date_time_modified
             ,@i_user_id
             ,@i_Stored_Ethnicity
             ,@i_Member_Identified_Race
             ,@i_Member_Identified_Ethnicity
             ,@i_Stored_Language_1
             ,@i_Stored_Language_1_Use
             ,@i_Stored_Language_2
             ,@i_Stored_Language_2_Use
             ,@i_Member_Preferred_Language
             ,@i_preferred_other_language
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberRaceEthnicityLanguage_Cursor
DEALLOCATE MemberRaceEthnicityLanguage_Cursor

END
GO