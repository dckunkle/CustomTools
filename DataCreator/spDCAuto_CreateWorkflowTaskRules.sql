IF OBJECT_ID('dbo.spDCAuto_CreateWorkflowTaskRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateWorkflowTaskRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateWorkflowTaskRules
Purpose:    Create workflowtaskrules data from CorderAutomation
Method:     WorkflowTaskRules
Screen GID: 503
Procedure:  dbo.prWFRulesAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/03/2020	DK				Original procedure
02/25/2022  DK				Stored procedure name change for SP49
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWorkflowTaskRules '100-Config%', 22, 'WorkflowTaskRules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateWorkflowTaskRules
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
	   ,@task_gid					INT
	   ,@next_task_gid				INT

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name           VARCHAR(100)
       ,@i_rule_gid              VARCHAR(50)
       ,@i_key_2_field           VARCHAR(100)
       ,@i_key_3_field           VARCHAR(100)
       ,@i_key_4_field           VARCHAR(100)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(100)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(10)
       ,@i_date_time_modified    VARCHAR(30)
       ,@iUserID                 VARCHAR(25)
       ,@i_task_id               VARCHAR(50)
       ,@i_task_description      VARCHAR(100)
       ,@i_rule_type             VARCHAR(50)
       ,@i_response_value        VARCHAR(50)
       ,@i_next_task_id          VARCHAR(50)
       ,@i_next_task_description VARCHAR(100)
       ,@i_override_priority     VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#WorkflowTaskRules') IS NOT NULL
	DROP TABLE #WorkflowTaskRules

CREATE TABLE #WorkflowTaskRules
      (SearchID                VARCHAR(200)
      ,i_entity_name           VARCHAR(100)      DEFAULT('Workflow_Rules')
      ,i_rule_gid              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified    VARCHAR(30)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_task_id               VARCHAR(50)
      ,i_task_description      VARCHAR(100)
      ,i_rule_type             VARCHAR(50)
      ,i_response_value        VARCHAR(50)
      ,i_next_task_id          VARCHAR(50)
      ,i_next_task_description VARCHAR(100)
      ,i_override_priority     VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(255)
      ,record_id               INT
      ,static_gid              INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #WorkflowTaskRules
      (SearchID
      ,i_task_id
      ,i_rule_type
      ,i_response_value
      ,i_next_task_id
      ,i_override_priority
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*TaskID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RuleType]), 'X')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ResponseValue]), '')
      ,ISNULL([*NextTaskID], '')
      ,ISNULL([OverridePriority], '0')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_WorkflowTaskRules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #WorkflowTaskRules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE WorkflowTaskRules_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_rule_gid
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
       ,i_rule_type
       ,i_response_value
       ,i_next_task_id
       ,i_next_task_description
       ,i_override_priority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #WorkflowTaskRules

   OPEN WorkflowTaskRules_Cursor
  FETCH NEXT FROM WorkflowTaskRules_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_rule_gid
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
       ,@i_rule_type
       ,@i_response_value
       ,@i_next_task_id
       ,@i_next_task_description
       ,@i_override_priority
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prWFRulesAdd				--SP49 prWFRulesAddModify
             @i_entity_name
            ,@i_rule_gid
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
            ,@i_rule_type
            ,@i_response_value
            ,@i_next_task_id
            ,@i_next_task_description
            ,@i_override_priority
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

  --      -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				SELECT @task_gid				= WTD.Task_GID
				  FROM WorkFlow_Task_Definition	WTD
				 WHERE WTD.record_status		= 'A'
				   AND WTD.Task_ID				= @i_task_id

				SELECT @next_task_gid			= WTD.Task_GID
				  FROM WorkFlow_Task_Definition	WTD
				 WHERE WTD.record_status		= 'A'
				   AND WTD.Task_ID				= @i_next_task_id

				-- Get the current gid
				SELECT @current_gid				= WR.Rule_GID
				  FROM dbo.WorkFlow_Rules		WR
				 WHERE WR.record_status			= 'A'
				   AND WR.Task_GID				= @task_gid
				   AND WR.Next_Task_GID			= @next_task_gid

				-- Update to the static gid
				UPDATE dbo.WorkFlow_Rules 
				   SET Rule_GID					= @static_gid 
				 WHERE record_status			= 'A'
				   AND Rule_GID					= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_task_id, @i_rule_type, '', @status, @err_num, @err_msg

        FETCH NEXT FROM WorkflowTaskRules_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_rule_gid
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
             ,@i_rule_type
             ,@i_response_value
             ,@i_next_task_id
             ,@i_next_task_description
             ,@i_override_priority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE WorkflowTaskRules_Cursor
DEALLOCATE WorkflowTaskRules_Cursor

END
GO