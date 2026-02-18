IF OBJECT_ID('dbo.spDCAuto_CreateGroupOnHold') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupOnHold AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupOnHold
Purpose:    Create grouponhold data from CorderAutomation
Method:     GroupOnHold
Screen GID: 26
Procedure:  dbo.prGroupHolds_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/18/2019	DK				Original procedure
01/08/2020	DK				Change the automation table name to TD_GroupOnHold
01/22/2020	DK				Fix join between EC and Group tables to get the correct GID for the group
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupOnHold '100-Config%', 22, 'GroupOnHold'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupOnHold
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

DECLARE @i_entity_name        VARCHAR(20)
       ,@i_key_1_field        VARCHAR(20)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Effective_Date     VARCHAR(50)
       ,@i_Termination_Date   VARCHAR(50)
       ,@i_Hold_Code          VARCHAR(50)
       ,@i_code_list_id       VARCHAR(50)
       ,@i_code_list_desc     VARCHAR(100)
       ,@i_Comment            VARCHAR(200)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupOnHold') IS NOT NULL
	DROP TABLE #GroupOnHold

CREATE TABLE #GroupOnHold
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(20)       DEFAULT('GROUP_HOLDS')
      ,i_key_1_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(200)      DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Effective_Date     VARCHAR(50)
      ,i_Termination_Date   VARCHAR(50)
      ,i_Hold_Code          VARCHAR(50)
      ,i_code_list_id       VARCHAR(50)
      ,i_code_list_desc     VARCHAR(100)
      ,i_Comment            VARCHAR(200)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupOnHold
      (SearchID
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Hold_Code
      ,i_code_list_id
      ,i_Comment
      ,record_id
      ,static_gid)
SELECT ISNULL([*MemberOrGroupID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*HoldCodes]), '')
      ,ISNULL([CodeListID], '')
      ,ISNULL([Comments], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupOnHold
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupOnHold
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupOnHold_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_field
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Hold_Code
       ,i_code_list_id
       ,i_code_list_desc
       ,i_Comment
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupOnHold

   OPEN GroupOnHold_Cursor
  FETCH NEXT FROM GroupOnHold_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_field
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Hold_Code
       ,@i_code_list_id
       ,@i_code_list_desc
       ,@i_Comment
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the group information to pass to the populate stored procedure
			SELECT @i_key_1_field			= EC.child_gid
				  ,@i_key_2_field			= EC.child_identifier
			      ,@i_key_3_field			= EC.parent_gid
				  ,@i_key_4_field			= EC.parent_identifier
				  ,@i_key_5_field			= EC.effective_date
				  ,@i_key_6_field			= EC.termination_date
				  ,@i_key_7_field			= EC.group_gid
				  ,@i_key_8_field			= ''
				  ,@i_key_9_field			= EC.default_lob
			  FROM Groups					G
			  JOIN Eligibility_Coverage		EC
			    ON G.group_gid				= EC.child_gid			-- 01/22/2020
			 WHERE G.group_id				= @SearchID
			   AND G.record_status			= 'A'
			   AND EC.record_status			= 'A'

			EXEC dbo.prGroupHolds_AddModify
				 @i_entity_name
				,@i_key_1_field
				,@i_key_2_field
				,@i_key_3_field
				,@i_key_4_field
				,@i_key_5_field
				,@i_key_6_field
				,@i_key_7_field
				,@i_key_8_field
				,@i_key_9_field
				,@i_key_10_field
				,@i_action
				,@i_Date_Time_Modified
				,@iUserID
				,@i_Effective_Date
				,@i_Termination_Date
				,@i_Hold_Code
				,@i_code_list_id
				,@i_code_list_desc
				,@i_Comment
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Hold_Code, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupOnHold_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_field
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Hold_Code
             ,@i_code_list_id
             ,@i_code_list_desc
             ,@i_Comment
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupOnHold_Cursor
DEALLOCATE GroupOnHold_Cursor

END
GO