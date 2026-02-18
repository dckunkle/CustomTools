IF OBJECT_ID('dbo.spDCAuto_CreateWorkflowTasks') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateWorkflowTasks AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateWorkflowTasks
Purpose:    Create workflowtasks data from CorderAutomation
Method:     WorkflowTasks
Screen GID: 502
Procedure:  dbo.prWFTaskAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/01/2019	DK				Original procedure
02/25/2022	DK				Stored Procedure name change for SP49
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWorkflowTasks '100-Config%', 22, '100-Config','WorkflowTasks','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateWorkflowTasks
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(100)
       ,@i_task_gid           VARCHAR(100)
       ,@i_key_2_field        VARCHAR(100)
       ,@i_key_3_field        VARCHAR(100)
       ,@i_key_4_field        VARCHAR(100)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(100)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(100)
       ,@i_key_9_field        VARCHAR(100)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(30)
       ,@iUserID              VARCHAR(25)
       ,@i_task_id            VARCHAR(10)
       ,@i_task_description   VARCHAR(100)
       ,@i_task_area          VARCHAR(10)
       ,@i_task_type          CHAR(1)
       ,@i_priority           INT
       ,@i_role_id            VARCHAR(10)
       ,@i_role_description   VARCHAR(100)
       ,@i_system_action      VARCHAR(50)
       ,@i_system_url         VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#WorkflowTasks') IS NOT NULL
	DROP TABLE #WorkflowTasks

CREATE TABLE #WorkflowTasks
      (i_entity_name        VARCHAR(100)      DEFAULT('Workflow_Task_Definition')
      ,i_task_gid           VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_task_id            VARCHAR(10)
      ,i_task_description   VARCHAR(100)
      ,i_task_area          VARCHAR(10)
      ,i_task_type          CHAR(1)
      ,i_priority           INT
      ,i_role_id            VARCHAR(10)
      ,i_role_description   VARCHAR(100)
      ,i_system_action      VARCHAR(50)
      ,i_system_url         VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(200)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #WorkflowTasks
      (i_task_id
      ,i_task_description
      ,i_task_area
      ,i_task_type
      ,i_priority
      ,i_role_id
      ,i_system_action
      ,i_system_url
      ,record_id
      ,static_gid)
SELECT ISNULL([*TaskID], '')
      ,ISNULL([*TaskDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TaskArea]), 'C')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TaskType]), 'X')
      ,ISNULL([*Priority], '0')
      ,ISNULL([*RoleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemAction]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemData]), 'CM')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_WorkflowTasks
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #WorkflowTasks
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE WorkflowTasks_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_task_gid
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
       ,i_task_id
       ,i_task_description
       ,i_task_area
       ,i_task_type
       ,i_priority
       ,i_role_id
       ,i_role_description
       ,i_system_action
       ,i_system_url
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #WorkflowTasks

   OPEN WorkflowTasks_Cursor
  FETCH NEXT FROM WorkflowTasks_Cursor
   INTO @i_entity_name
       ,@i_task_gid
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
       ,@i_task_id
       ,@i_task_description
       ,@i_task_area
       ,@i_task_type
       ,@i_priority
       ,@i_role_id
       ,@i_role_description
       ,@i_system_action
       ,@i_system_url
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prWFTaskAdd		--SP49 prWFTaskAddModify
             @i_entity_name
            ,@i_task_gid
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
            ,@i_task_id
            ,@i_task_description
            ,@i_task_area
            ,@i_task_type
            ,@i_priority
            ,@i_role_id
            ,@i_role_description
            ,@i_system_action
            ,@i_system_url
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.WorkFlow_Task_Definition 
				   SET Task_GID					= @static_gid 
				 WHERE record_status			= 'A'
				   AND Task_ID					= @i_task_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_task_id, @i_task_description, '', @status, @err_num, @err_msg

        FETCH NEXT FROM WorkflowTasks_Cursor
         INTO @i_entity_name
             ,@i_task_gid
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
             ,@i_task_id
             ,@i_task_description
             ,@i_task_area
             ,@i_task_type
             ,@i_priority
             ,@i_role_id
             ,@i_role_description
             ,@i_system_action
             ,@i_system_url
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE WorkflowTasks_Cursor
DEALLOCATE WorkflowTasks_Cursor

END
GO