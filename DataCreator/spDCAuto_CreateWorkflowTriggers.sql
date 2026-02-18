IF OBJECT_ID('dbo.spDCAuto_CreateWorkflowTriggers') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateWorkflowTriggers AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateWorkflowTriggers
Purpose:    Create workflowtriggers data from CorderAutomation
Method:     WorkflowTriggers
Screen GID: 501
Procedure:  dbo.prWFTriggersAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/01/2019	DK				Original procedure
03/18/2022	DK				Add stored procedure change SP49
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWorkflowTriggers '100-Config%', 22, '100-Config','WorkflowTriggers','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateWorkflowTriggers
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

DECLARE @i_entity_name         VARCHAR(100)
       ,@i_trigger_gid         VARCHAR(100)
       ,@i_key_2_field         VARCHAR(100)
       ,@i_key_3_field         VARCHAR(50)
       ,@i_key_4_field         VARCHAR(100)
       ,@i_key_5_field         VARCHAR(100)
       ,@i_key_6_field         VARCHAR(100)
       ,@i_key_7_field         VARCHAR(100)
       ,@i_key_8_field         VARCHAR(100)
       ,@i_key_9_field         VARCHAR(100)
       ,@i_key_10_field        VARCHAR(100)
       ,@i_action              VARCHAR(10)
       ,@i_date_time_modified  VARCHAR(30)
       ,@iUserID               VARCHAR(25)
       ,@i_trigger_id          VARCHAR(10)
       ,@i_trigger_description VARCHAR(100)
       ,@i_role_id             VARCHAR(10)
       ,@i_role_description    VARCHAR(100)
       ,@i_object_name         VARCHAR(10)
       ,@i_object_action       VARCHAR(10)
       ,@i_object_field        VARCHAR(10)
       ,@i_object_datatype     VARCHAR(8)
       ,@i_object_operator     VARCHAR(8)
       ,@i_field_value         VARCHAR(50)
       ,@i_task_id             VARCHAR(10)
       ,@i_task_decription     VARCHAR(100)
       ,@o_status              INT
       ,@o_message             VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#WorkflowTriggers') IS NOT NULL
	DROP TABLE #WorkflowTriggers

CREATE TABLE #WorkflowTriggers
      (i_entity_name         VARCHAR(100)      DEFAULT('Workflow_Triggers')
      ,i_trigger_gid         VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_8_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_10_field        VARCHAR(100)      DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified  VARCHAR(30)       DEFAULT('')
      ,iUserID               VARCHAR(25)       DEFAULT('')
      ,i_trigger_id          VARCHAR(100)
      ,i_trigger_description VARCHAR(100)
      ,i_role_id             VARCHAR(100)
      ,i_role_description    VARCHAR(100)
      ,i_object_name         VARCHAR(100)
      ,i_object_action       VARCHAR(100)
      ,i_object_field        VARCHAR(100)
      ,i_object_datatype     VARCHAR(100)
      ,i_object_operator     VARCHAR(100)
      ,i_field_value         VARCHAR(100)
      ,i_task_id             VARCHAR(100)
      ,i_task_decription     VARCHAR(100)
      ,o_status              INT
      ,o_message             VARCHAR(200)
      ,record_id             INT
      ,static_gid            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #WorkflowTriggers
      (i_trigger_id
      ,i_trigger_description
      ,i_role_id
      ,i_object_name
      ,i_object_action
      ,i_object_field
      ,i_object_datatype
      ,i_object_operator
      ,i_field_value
      ,i_task_id
      ,record_id
      ,static_gid)
SELECT ISNULL([*TriggerID], '')
      ,ISNULL([*TriggerDescription], '')
      ,ISNULL([RoleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ObjectName]), 'ACHR')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ObjectAction]), 'CAC')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ObjectField]), 'ACCDNT')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DataType]), 'VRCHR')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Operator]), '=')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FieldValue]), '')
      ,ISNULL([*TaskID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_WorkflowTriggers
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #WorkflowTriggers
   SET iUserID  = @user

SELECT * FROM #WorkflowTriggers

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE WorkflowTriggers_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_trigger_gid
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
       ,i_trigger_id
       ,i_trigger_description
       ,i_role_id
       ,i_role_description
       ,i_object_name
       ,i_object_action
       ,i_object_field
       ,i_object_datatype
       ,i_object_operator
       ,i_field_value
       ,i_task_id
       ,i_task_decription
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #WorkflowTriggers

   OPEN WorkflowTriggers_Cursor
  FETCH NEXT FROM WorkflowTriggers_Cursor
   INTO @i_entity_name
       ,@i_trigger_gid
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
       ,@i_trigger_id
       ,@i_trigger_description
       ,@i_role_id
       ,@i_role_description
       ,@i_object_name
       ,@i_object_action
       ,@i_object_field
       ,@i_object_datatype
       ,@i_object_operator
       ,@i_field_value
       ,@i_task_id
       ,@i_task_decription
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prWFTriggersAdd
             @i_entity_name
            ,@i_trigger_gid
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
            ,@i_trigger_id
            ,@i_trigger_description
            ,@i_role_id
            ,@i_role_description
            ,@i_object_name
            ,@i_object_action
            ,@i_object_field
            ,@i_object_datatype
            ,@i_object_operator
            ,@i_field_value
            ,@i_task_id
            ,@i_task_decription
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.WorkFlow_Triggers 
				   SET Trigger_GID				= @static_gid 
				 WHERE record_status			= 'A'
				   AND Trigger_ID				= @i_trigger_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_trigger_id, @i_trigger_description, @i_role_id, @status, @err_num, @err_msg

        FETCH NEXT FROM WorkflowTriggers_Cursor
         INTO @i_entity_name
             ,@i_trigger_gid
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
             ,@i_trigger_id
             ,@i_trigger_description
             ,@i_role_id
             ,@i_role_description
             ,@i_object_name
             ,@i_object_action
             ,@i_object_field
             ,@i_object_datatype
             ,@i_object_operator
             ,@i_field_value
             ,@i_task_id
             ,@i_task_decription
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE WorkflowTriggers_Cursor
DEALLOCATE WorkflowTriggers_Cursor

END
GO