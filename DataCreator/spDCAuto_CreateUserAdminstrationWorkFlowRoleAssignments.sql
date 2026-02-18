IF OBJECT_ID('dbo.spDCAuto_CreateUserAdminstrationWorkFlowRoleAssignments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateUserAdminstrationWorkFlowRoleAssignments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateUserAdminstrationWorkFlowRoleAssignments
Purpose:    Create useradminstrationworkflowroleassignments data from CorderAutomation
Method:     UserAdminstrationWorkFlowRoleAssignments
Screen GID: 506
Procedure:  dbo.prUserRoleAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/03/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateUserAdminstrationWorkFlowRoleAssignments '100-Config%', 22, 'UserAdminstrationWorkFlowRoleAssignments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateUserAdminstrationWorkFlowRoleAssignments
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

DECLARE @i_entity_name        VARCHAR(200)
       ,@i_key_user_gid       VARCHAR(50)
       ,@i_key_role_type      VARCHAR(20)
       ,@i_key_role_gid       VARCHAR(50)
       ,@i_key_effective_date VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@i_role_id            VARCHAR(50)
       ,@i_role_description   VARCHAR(100)
       ,@i_priority           VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#UserAdminstrationWorkFlowRoleAssignments') IS NOT NULL
	DROP TABLE #UserAdminstrationWorkFlowRoleAssignments

CREATE TABLE #UserAdminstrationWorkFlowRoleAssignments
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(200)      DEFAULT('Workflow_User_Roles')
      ,i_key_user_gid       VARCHAR(50)       DEFAULT('0')
      ,i_key_role_type      VARCHAR(20)       DEFAULT('W')
      ,i_key_role_gid       VARCHAR(50)       DEFAULT('N')
      ,i_key_effective_date VARCHAR(50)       DEFAULT('')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_role_id            VARCHAR(50)
      ,i_role_description   VARCHAR(100)
      ,i_priority           VARCHAR(50)
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #UserAdminstrationWorkFlowRoleAssignments
      (SearchID
      ,i_role_id
      ,i_priority
      ,i_effective_date
      ,i_termination_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*RoleID], '')
      ,ISNULL([*Priority], '0')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_UserAdministrationWorkFlowRoleAssign
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #UserAdminstrationWorkFlowRoleAssignments
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE UserAdminstrationWorkFlowRoleAssignments_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_user_gid
       ,i_key_role_type
       ,i_key_role_gid
       ,i_key_effective_date
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_role_id
       ,i_role_description
       ,i_priority
       ,i_effective_date
       ,i_termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #UserAdminstrationWorkFlowRoleAssignments

   OPEN UserAdminstrationWorkFlowRoleAssignments_Cursor
  FETCH NEXT FROM UserAdminstrationWorkFlowRoleAssignments_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_user_gid
       ,@i_key_role_type
       ,@i_key_role_gid
       ,@i_key_effective_date
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_role_id
       ,@i_role_description
       ,@i_priority
       ,@i_effective_date
       ,@i_termination_date
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Find the User gid
			SELECT @i_key_user_gid		= SU.User_GID
			  FROM Security_Users		SU
			 WHERE SU.record_status		= 'A'
			   AND SU.System_User_ID	= @SearchID

			-- Get the proper description for the role
			SELECT @i_role_description	= WR.Role_Description
			  FROM WorkFlow_Roles		WR
			 WHERE WR.record_status		= 'A'
			   AND WR.Role_ID			= @i_role_id

			EXEC dbo.prUserRoleAddModify
             @i_entity_name
            ,@i_key_user_gid
            ,@i_key_role_type
            ,@i_key_role_gid
            ,@i_key_effective_date
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_role_id
            ,@i_role_description
            ,@i_priority
            ,@i_effective_date
            ,@i_termination_date
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_role_id, @i_role_description, @status, @err_num, @err_msg

        FETCH NEXT FROM UserAdminstrationWorkFlowRoleAssignments_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_user_gid
             ,@i_key_role_type
             ,@i_key_role_gid
             ,@i_key_effective_date
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_role_id
             ,@i_role_description
             ,@i_priority
             ,@i_effective_date
             ,@i_termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE UserAdminstrationWorkFlowRoleAssignments_Cursor
DEALLOCATE UserAdminstrationWorkFlowRoleAssignments_Cursor

END
GO