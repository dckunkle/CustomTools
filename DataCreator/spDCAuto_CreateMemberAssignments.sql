IF OBJECT_ID('dbo.spDCAuto_CreateMemberAssignments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberAssignments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberAssignments
Purpose:    Create memberassignments data from CorderAutomation
Method:     MemberAssignments
Screen GID: 3023
Procedure:  dbo.prBR_AssignmentAdd

Date        User            Change
---------------------------------------------------------------------------------------------
04/08/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberAssignments '100-Config%', 22, 'MemberAssignments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberAssignments
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
	   ,@group_gid					INT
	   ,@broker_sid					INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_assign_gid         VARCHAR(50)
       ,@i_group_gid          VARCHAR(50)
       ,@i_member_gid         VARCHAR(50)
       ,@i_agency_gid         VARCHAR(50)
       ,@i_cr_gid             VARCHAR(50)
       ,@i_grouper_gid        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_assign_type        VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_group_id           VARCHAR(50)
       ,@i_group_name         VARCHAR(100)
       ,@i_member_id          VARCHAR(50)
       ,@i_member_name        VARCHAR(100)
       ,@i_agency_id          VARCHAR(50)
       ,@i_agency_desc        VARCHAR(100)
       ,@i_broker_id          VARCHAR(50)
       ,@i_broker_desc        VARCHAR(100)
       ,@i_GrouperID          VARCHAR(50)
       ,@i_GrouperDesc        VARCHAR(100)
       ,@i_system_lob         VARCHAR(50)
       ,@i_custom_lob         VARCHAR(50)
       ,@i_Commission_id      VARCHAR(50)
       ,@i_Commission_desc    VARCHAR(100)
       ,@i_primary_agent      VARCHAR(50)
       ,@i_business_assoc     VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_span_type          VARCHAR(50)
       ,@i_span_value         VARCHAR(50)
       ,@i_aggregate_date     VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)
       ,@i_DisplayResults     VARCHAR(50)
       ,@i_App_Type           VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberAssignments') IS NOT NULL
	DROP TABLE #MemberAssignments

CREATE TABLE #MemberAssignments
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('BR_GR')
      ,i_assign_gid         VARCHAR(50)       DEFAULT('0')
      ,i_group_gid          VARCHAR(50)       DEFAULT('0')
      ,i_member_gid         VARCHAR(50)       DEFAULT('0')
      ,i_agency_gid         VARCHAR(50)       DEFAULT('0')
      ,i_cr_gid             VARCHAR(50)       DEFAULT('0')
      ,i_grouper_gid        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_assign_type        VARCHAR(50)       DEFAULT('MEMBER')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_group_id           VARCHAR(50)
      ,i_group_name         VARCHAR(100)
      ,i_member_id          VARCHAR(50)
      ,i_member_name        VARCHAR(100)
      ,i_agency_id          VARCHAR(50)
      ,i_agency_desc        VARCHAR(100)
      ,i_broker_id          VARCHAR(50)
      ,i_broker_desc        VARCHAR(100)
      ,i_GrouperID          VARCHAR(50)
      ,i_GrouperDesc        VARCHAR(100)
      ,i_system_lob         VARCHAR(50)
      ,i_custom_lob         VARCHAR(50)
      ,i_Commission_id      VARCHAR(50)
      ,i_Commission_desc    VARCHAR(100)
      ,i_primary_agent      VARCHAR(50)
      ,i_business_assoc     VARCHAR(50)
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_span_type          VARCHAR(50)
      ,i_span_value         VARCHAR(50)
      ,i_aggregate_date     VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,i_DisplayResults     VARCHAR(50)
      ,i_App_Type           VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberAssignments
      (SearchID
      ,i_group_id
      ,i_member_id
      ,i_agency_id
      ,i_broker_id
      ,i_GrouperID
      ,i_system_lob
      ,i_custom_lob
      ,i_Commission_id
      ,i_primary_agent
      ,i_business_assoc
      ,i_effective_date
      ,i_termination_date
      ,i_span_type
      ,i_span_value
      ,i_aggregate_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*GroupId], '')
      ,ISNULL([MemberId], '')
      ,ISNULL([AgencyId], '')
      ,ISNULL([BrokerId], '')
      ,ISNULL([AgencyBrkGrprId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLob]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Lob]), '******')
      ,ISNULL([CommissionId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PrimaryAgent]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BusiAsscocAgrmnt]), 'Y')
      ,ISNULL([*EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TierSpanType]), 'Y')
      ,ISNULL([TierSpanValue], '0')
      ,ISNULL([StartAggrDate], '01/01/1900')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberAssignments
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberAssignments
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberAssignments_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_assign_gid
       ,i_group_gid
       ,i_member_gid
       ,i_agency_gid
       ,i_cr_gid
       ,i_grouper_gid
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_assign_type
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_group_id
       ,i_group_name
       ,i_member_id
       ,i_member_name
       ,i_agency_id
       ,i_agency_desc
       ,i_broker_id
       ,i_broker_desc
       ,i_GrouperID
       ,i_GrouperDesc
       ,i_system_lob
       ,i_custom_lob
       ,i_Commission_id
       ,i_Commission_desc
       ,i_primary_agent
       ,i_business_assoc
       ,i_effective_date
       ,i_termination_date
       ,i_span_type
       ,i_span_value
       ,i_aggregate_date
       ,o_status
       ,o_message
       ,i_DisplayResults
       ,i_App_Type
       ,record_id
       ,static_gid
   FROM #MemberAssignments

   OPEN MemberAssignments_Cursor
  FETCH NEXT FROM MemberAssignments_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_assign_gid
       ,@i_group_gid
       ,@i_member_gid
       ,@i_agency_gid
       ,@i_cr_gid
       ,@i_grouper_gid
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_assign_type
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_group_id
       ,@i_group_name
       ,@i_member_id
       ,@i_member_name
       ,@i_agency_id
       ,@i_agency_desc
       ,@i_broker_id
       ,@i_broker_desc
       ,@i_GrouperID
       ,@i_GrouperDesc
       ,@i_system_lob
       ,@i_custom_lob
       ,@i_Commission_id
       ,@i_Commission_desc
       ,@i_primary_agent
       ,@i_business_assoc
       ,@i_effective_date
       ,@i_termination_date
       ,@i_span_type
       ,@i_span_value
       ,@i_aggregate_date
       ,@o_status
       ,@o_message
       ,@i_DisplayResults
       ,@i_App_Type
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prBR_AssignmentAdd
				 @i_entity_name
				,@i_assign_gid
				,@i_group_gid
				,@i_member_gid
				,@i_agency_gid
				,@i_cr_gid
				,@i_grouper_gid
				,@i_key_7_field
				,@i_key_8_field
				,@i_key_9_field
				,@i_assign_type
				,@i_action
				,@i_Date_Time_Modified
				,@iUserID
				,@i_group_id
				,@i_group_name
				,@i_member_id
				,@i_member_name
				,@i_agency_id
				,@i_agency_desc
				,@i_broker_id
				,@i_broker_desc
				,@i_GrouperID
				,@i_GrouperDesc
				,@i_system_lob
				,@i_custom_lob
				,@i_Commission_id
				,@i_Commission_desc
				,@i_primary_agent
				,@i_business_assoc
				,@i_effective_date
				,@i_termination_date
				,@i_span_type
				,@i_span_value
				,@i_aggregate_date
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
				SELECT @group_gid				= G.group_gid
				  FROM Groups					G
				 WHERE G.record_status			= 'A'
				   AND G.group_id				= @i_group_id

				SELECT @current_gid				= BA.broker_assignment_gid
				      ,@broker_sid				= BA.Broker_Assignment_sid
				  FROM dbo.Broker_Assignment	BA
				 WHERE BA.record_status			= 'A'
				   AND BA.entity_type			= 'GROUP'
				   AND BA.entity_gid			= @group_gid
				   AND BA.user_id_created		= @user

				UPDATE dbo.Broker_Assignment
				   SET broker_assignment_gid	= @static_gid
				 WHERE Broker_Assignment_sid	= @broker_sid
				   

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_agency_id, @i_Commission_id, @status, @err_num, @err_msg

        FETCH NEXT FROM MemberAssignments_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_assign_gid
             ,@i_group_gid
             ,@i_member_gid
             ,@i_agency_gid
             ,@i_cr_gid
             ,@i_grouper_gid
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_assign_type
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_group_id
             ,@i_group_name
             ,@i_member_id
             ,@i_member_name
             ,@i_agency_id
             ,@i_agency_desc
             ,@i_broker_id
             ,@i_broker_desc
             ,@i_GrouperID
             ,@i_GrouperDesc
             ,@i_system_lob
             ,@i_custom_lob
             ,@i_Commission_id
             ,@i_Commission_desc
             ,@i_primary_agent
             ,@i_business_assoc
             ,@i_effective_date
             ,@i_termination_date
             ,@i_span_type
             ,@i_span_value
             ,@i_aggregate_date
             ,@o_status
             ,@o_message
             ,@i_DisplayResults
             ,@i_App_Type
             ,@record_id
             ,@static_gid
	END

CLOSE MemberAssignments_Cursor
DEALLOCATE MemberAssignments_Cursor

END
GO