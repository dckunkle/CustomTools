IF OBJECT_ID('dbo.spDCAuto_CreateMemberOnHold') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberOnHold AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberOnHold
Purpose:    Create memberonhold data from CorderAutomation
Method:     MemberOnHold
Screen GID: 3023
Procedure:  dbo.prMemberHolds_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/08/2020	DK				Original procedure
04/13/2020	DK				Add token table
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberOnHold '100-Config%', 22, 'MemberOnHold'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberOnHold
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
       ,@i_key_3_field        VARCHAR(10)
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
       ,@i_apply_to_fam       VARCHAR(50)
       ,@i_code_list_id       VARCHAR(50)
       ,@i_code_list_desc     VARCHAR(100)
       ,@i_comment            VARCHAR(200)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)
       ,@i_disp_results       VARCHAR(50)
       ,@return_xml           XML

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberOnHold') IS NOT NULL
	DROP TABLE #MemberOnHold

CREATE TABLE #MemberOnHold
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(20)       DEFAULT('MEMBER_HOLDS')
      ,i_key_1_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(10)       DEFAULT('0')
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
      ,i_apply_to_fam       VARCHAR(50)
      ,i_code_list_id       VARCHAR(50)
      ,i_code_list_desc     VARCHAR(100)
      ,i_comment            VARCHAR(200)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,i_disp_results       VARCHAR(50)
      ,return_xml           XML
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberOnHold
      (SearchID
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Hold_Code
      ,i_apply_to_fam
      ,i_code_list_id
      ,i_comment
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*HoldCodes]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApplyToFamily]), 'Y')
      ,ISNULL([CodeListID], '')
      ,ISNULL([Comments], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberOnHold
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberOnHold
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberOnHold_Cursor CURSOR FOR
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
       ,i_apply_to_fam
       ,i_code_list_id
       ,i_code_list_desc
       ,i_comment
       ,o_status
       ,o_message
       ,i_disp_results
       ,return_xml
       ,record_id
       ,static_gid
   FROM #MemberOnHold

   OPEN MemberOnHold_Cursor
  FETCH NEXT FROM MemberOnHold_Cursor
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
       ,@i_apply_to_fam
       ,@i_code_list_id
       ,@i_code_list_desc
       ,@i_comment
       ,@o_status
       ,@o_message
       ,@i_disp_results
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

			--Get the GIDs for the member
			SELECT @i_key_1_field			= EC.child_gid
			      ,@i_key_3_field			= EC.parent_gid
				  ,@i_key_7_field			= EC.group_gid
			  FROM Eligibility_Coverage		EC
			 WHERE EC.record_status			= 'A'
			   AND EC.member_id				= @SearchID
			   AND EC.child_gid				= EC.parent_gid

			EXEC dbo.prMemberHolds_AddModify
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
            ,@i_apply_to_fam
            ,@i_code_list_id
            ,@i_code_list_desc
            ,@i_comment
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Hold_Code, '', @status, @err_num, @err_msg

        FETCH NEXT FROM MemberOnHold_Cursor
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
             ,@i_apply_to_fam
             ,@i_code_list_id
             ,@i_code_list_desc
             ,@i_comment
             ,@o_status
             ,@o_message
             ,@i_disp_results
             ,@return_xml
             ,@record_id
             ,@static_gid
	END

CLOSE MemberOnHold_Cursor
DEALLOCATE MemberOnHold_Cursor

END
GO