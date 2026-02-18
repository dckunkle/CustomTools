/**************************************************************************************************
Name:       spDCAuto_CreateWorkflowRoles
Purpose:    Create workflowroles data from CorderAutomation

Screen:     500
Method:     WorkflowRoles
Procedure:  dbo.prWFRolesAddModify
Entity:     Workflow_Roles

Date        User            Change
---------------------------------------------------------------------------------------------
Date        User            Change
---------------------------------------------------------------------------------------------
11/01/2019	DK				Original procedure
07/21/2020	DK				Add pause to avoid PK Violation
08/26/2022	DK				Additional fields for SP48
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWorkflowRoles '100-Config%', 22, 'WorkflowRoles'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateWorkflowRoles
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_role_gid           VARCHAR(100)
       ,@i_key_2_field        VARCHAR(100)
       ,@i_key_3_field        VARCHAR(100)
       ,@i_key_4_field        VARCHAR(100)
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
       ,@i_critical_level     VARCHAR(50)
       ,@i_error_level        VARCHAR(50)
       ,@i_resub_queue        VARCHAR(50)
       ,@i_Functional_Area    VARCHAR(50)
       ,@i_Resp_Dept          VARCHAR(50)
       ,@i_Pend_Reason        VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#WorkflowRoles') IS NOT NULL
	DROP TABLE #WorkflowRoles

CREATE TABLE #WorkflowRoles
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Workflow_Roles')
      ,i_role_gid           VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field        VARCHAR(100)      DEFAULT('0')
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
      ,i_critical_level     VARCHAR(50)
      ,i_error_level        VARCHAR(50)
      ,i_resub_queue        VARCHAR(50)
      ,i_Functional_Area    VARCHAR(50)
      ,i_Resp_Dept          VARCHAR(50)
      ,i_Pend_Reason        VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
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
BEGIN TRY

    INSERT INTO #WorkflowRoles
          (SearchID
          ,i_role_id
          ,i_role_description
          ,i_critical_level
          ,i_error_level
          ,i_resub_queue
          ,i_Functional_Area
          ,i_Resp_Dept
          ,i_Pend_Reason
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*RoleID], '')
		  ,ISNULL([*RoleDescription], '')
          ,ISNULL([*WarningLevel], '0')
          ,ISNULL([*CriticalLevel], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ResubmitOption]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FunctionalArea]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ResponsibleDepartment]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PendReason]), '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_WorkflowRoles
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #WorkflowRoles
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
DECLARE WorkflowRoles_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_role_gid
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
       ,i_date_time_modified
       ,iUserID
       ,i_role_id
       ,i_role_description
       ,i_critical_level
       ,i_error_level
       ,i_resub_queue
       ,i_Functional_Area
       ,i_Resp_Dept
       ,i_Pend_Reason
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #WorkflowRoles

   OPEN WorkflowRoles_Cursor
  FETCH NEXT FROM WorkflowRoles_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_role_gid
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
       ,@i_date_time_modified
       ,@iUserID
       ,@i_role_id
       ,@i_role_description
       ,@i_critical_level
       ,@i_error_level
       ,@i_resub_queue
       ,@i_Functional_Area
       ,@i_Resp_Dept
       ,@i_Pend_Reason
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

			EXEC dbo.prWFRolesAddModify
                 @i_entity_name
                ,@i_role_gid
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
                ,@i_date_time_modified
                ,@iUserID
                ,@i_role_id
                ,@i_role_description
                ,@i_critical_level
                ,@i_error_level
                ,@i_resub_queue
                ,@i_Functional_Area			-- SP48
                ,@i_Resp_Dept				-- SP48
                ,@i_Pend_Reason				-- SP48
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Workflow_Roles 
				   SET Role_GID					= @static_gid 
				 WHERE record_status			= 'A'
				   AND Role_ID					= @i_role_id

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_role_id, @i_role_description, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM WorkflowRoles_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_role_gid
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
             ,@i_date_time_modified
             ,@iUserID
             ,@i_role_id
             ,@i_role_description
             ,@i_critical_level
             ,@i_error_level
             ,@i_resub_queue
             ,@i_Functional_Area
             ,@i_Resp_Dept
             ,@i_Pend_Reason
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE WorkflowRoles_Cursor
DEALLOCATE WorkflowRoles_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#WorkflowRoles') IS NOT NULL
	DROP TABLE #WorkflowRoles

END
GO

