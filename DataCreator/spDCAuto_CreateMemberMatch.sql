IF OBJECT_ID('dbo.spDCAuto_CreateMemberMatch') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberMatch AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberMatch
Purpose:    Create membermatch data from CorderAutomation
Method:     MemberMatch
Screen GID: 164
Procedure:  dbo.prMemberMatchAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberMatch '100-Config%', 22, 'MemberMatch'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberMatch
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

DECLARE @i_entity_name           VARCHAR(50)
       ,@i_key_entity_gid        VARCHAR(100)
       ,@i_key_member_match_ID   VARCHAR(50)
       ,@i_key_member_match_Desc VARCHAR(50)
       ,@i_key_4_field           VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(50)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(10)
       ,@i_date_time_modified    VARCHAR(50)
       ,@iUserID                 VARCHAR(25)
       ,@i_member_match_ID       VARCHAR(50)
       ,@i_member_match_desc     VARCHAR(50)
       ,@i_Type                  VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberMatch') IS NOT NULL
	DROP TABLE #MemberMatch

CREATE TABLE #MemberMatch
      (SearchID                VARCHAR(200)
      ,i_entity_name           VARCHAR(50)       DEFAULT('MEMBER_MATCHING')
      ,i_key_entity_gid        VARCHAR(100)      DEFAULT('0')
      ,i_key_member_match_ID   VARCHAR(50)       DEFAULT('0')
      ,i_key_member_match_Desc VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified    VARCHAR(50)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_member_match_ID       VARCHAR(50)
      ,i_member_match_desc     VARCHAR(50)
      ,i_Type                  VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(250)
      ,record_id               INT
      ,static_gid              INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberMatch
      (SearchID
      ,i_member_match_ID
      ,i_member_match_desc
      ,i_Type
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*MemberMatchID], '')
      ,ISNULL([*MemberMatchDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Type]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberMatch
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberMatch
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberMatch_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_entity_gid
       ,i_key_member_match_ID
       ,i_key_member_match_Desc
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
       ,i_member_match_ID
       ,i_member_match_desc
       ,i_Type
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberMatch

   OPEN MemberMatch_Cursor
  FETCH NEXT FROM MemberMatch_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_entity_gid
       ,@i_key_member_match_ID
       ,@i_key_member_match_Desc
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
       ,@i_member_match_ID
       ,@i_member_match_desc
       ,@i_Type
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prMemberMatchAddModify
             @i_entity_name
            ,@i_key_entity_gid
            ,@i_key_member_match_ID
            ,@i_key_member_match_Desc
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
            ,@i_member_match_ID
            ,@i_member_match_desc
            ,@i_Type
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'MEMBER_MATCHING'
				   AND entity_user_id			= @i_member_match_ID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_member_match_ID, @i_member_match_desc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberMatch_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_entity_gid
             ,@i_key_member_match_ID
             ,@i_key_member_match_Desc
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
             ,@i_member_match_ID
             ,@i_member_match_desc
             ,@i_Type
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberMatch_Cursor
DEALLOCATE MemberMatch_Cursor

END
GO