/**************************************************************************************************
Name:       spDCAuto_CreateStateProcessingParameters
Purpose:    Create stateprocessingparameters data from CorderAutomation

Screen:     93
Method:     StateProcessingParameters
Procedure:  dbo.prState_Withhold_Add_Modify
Entity:     State_Withhold

Date        User            Change
---------------------------------------------------------------------------------------------
11/01/2019	DK				Original procedure
07/28/2022	DK				Make SP51 changes
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateStateProcessingParameters '100-Config%', 22, '100-Config', 'StateProcessingParameters', '100AutoConfig'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateStateProcessingParameters
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

DECLARE @i_Entity_name           VARCHAR(50)
       ,@i_State_Withhold_Gid    VARCHAR(100)
       ,@i_Date_Time_Modified    VARCHAR(50)
       ,@i_User_Id               VARCHAR(50)
       ,@i_key_4_field           VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(100)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(100)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(50)
       ,@l_modified_date         VARCHAR(50)
       ,@iUserID                 VARCHAR(25)
       ,@i_State_Code            VARCHAR(50)
       ,@i_class_code            VARCHAR(50)
       ,@i_AssgnType             VARCHAR(50)
       ,@i_Effective_Date        VARCHAR(50)
       ,@i_Termination_Date      VARCHAR(50)
       ,@i_penalty_sched_ID      VARCHAR(50)
       ,@i_penalty_sched_Desc    VARCHAR(50)
       ,@i_Withhold_id           VARCHAR(50)
       ,@i_Withhold_desc         VARCHAR(100)
       ,@i_Member_Delay_notify   VARCHAR(50)
       ,@i_Provider_Delay_notify VARCHAR(50)
       ,@i_recoup_days           VARCHAR(50)
       ,@i_recoup_minimum        VARCHAR(50)
       ,@i_Send_EOP_to_Patient   VARCHAR(50)		-- SP51
       ,@i_Privacy_dependent_Age VARCHAR(50)		-- SP51
       ,@o_status                INT
       ,@o_message               VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#StateProcessingParameters') IS NOT NULL
	DROP TABLE #StateProcessingParameters

CREATE TABLE #StateProcessingParameters
      (SearchID                VARCHAR(200)
      ,i_Entity_name           VARCHAR(50)       DEFAULT('State_Withhold')
      ,i_State_Withhold_Gid    VARCHAR(100)      DEFAULT('0')
      ,i_Date_Time_Modified    VARCHAR(50)       DEFAULT('0')
      ,i_User_Id               VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(50)       DEFAULT('ADD')
      ,l_modified_date         VARCHAR(50)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_State_Code            VARCHAR(50)
      ,i_class_code            VARCHAR(50)
      ,i_AssgnType             VARCHAR(50)
      ,i_Effective_Date        VARCHAR(50)
      ,i_Termination_Date      VARCHAR(50)
      ,i_penalty_sched_ID      VARCHAR(50)
      ,i_penalty_sched_Desc    VARCHAR(50)
      ,i_Withhold_id           VARCHAR(50)
      ,i_Withhold_desc         VARCHAR(100)
      ,i_Member_Delay_notify   VARCHAR(50)
      ,i_Provider_Delay_notify VARCHAR(50)
      ,i_recoup_days           VARCHAR(50)
      ,i_recoup_minimum        VARCHAR(50)
      ,i_Send_EOP_to_Patient   VARCHAR(50)
      ,i_Privacy_dependent_Age VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(250)
      ,record_id               INT
      ,static_gid              INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #StateProcessingParameters
          (SearchID
          ,i_State_Code
          ,i_class_code
          ,i_AssgnType
          ,i_Effective_Date
          ,i_Termination_Date
          ,i_penalty_sched_ID
          ,i_Withhold_id
          ,i_Member_Delay_notify
          ,i_Provider_Delay_notify
          ,i_recoup_days
          ,i_recoup_minimum
		  ,i_Send_EOP_to_Patient
          ,i_Privacy_dependent_Age
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*State]), '**')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractClassCode]), '**')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AssignmentType]), 'P')
		  ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
		  ,ISNULL([*TerminationDate], '12/31/9999')
		  ,ISNULL([PenaltyID], '')
		  ,ISNULL([WithholdID], '')
		  ,ISNULL([MemberDelayNotificationDays], '0')
		  ,ISNULL([ProviderDelayNotificationDays], '0')
		  ,ISNULL([RecoupAllowanceDays], '0')
		  ,ISNULL([RecoupMiniumAmount], '0.00')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SendEOPToPatient]), 'Y')
		  ,ISNULL([PrivacyDependentAge], '18')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_StateProcessingParameters
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #StateProcessingParameters
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
DECLARE StateProcessingParameters_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_State_Withhold_Gid
       ,i_Date_Time_Modified
       ,i_User_Id
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_State_Code
       ,i_class_code
       ,i_AssgnType
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_penalty_sched_ID
       ,i_penalty_sched_Desc
       ,i_Withhold_id
       ,i_Withhold_desc
       ,i_Member_Delay_notify
       ,i_Provider_Delay_notify
       ,i_recoup_days
       ,i_recoup_minimum
       ,i_Send_EOP_to_Patient
       ,i_Privacy_dependent_Age
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #StateProcessingParameters

   OPEN StateProcessingParameters_Cursor
  FETCH NEXT FROM StateProcessingParameters_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_State_Withhold_Gid
       ,@i_Date_Time_Modified
       ,@i_User_Id
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_State_Code
       ,@i_class_code
       ,@i_AssgnType
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_penalty_sched_ID
       ,@i_penalty_sched_Desc
       ,@i_Withhold_id
       ,@i_Withhold_desc
       ,@i_Member_Delay_notify
       ,@i_Provider_Delay_notify
       ,@i_recoup_days
       ,@i_recoup_minimum
       ,@i_Send_EOP_to_Patient
       ,@i_Privacy_dependent_Age
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

			EXEC dbo.prState_Withhold_Add_Modify
                 @i_Entity_name
                ,@i_State_Withhold_Gid
                ,@i_Date_Time_Modified
                ,@i_User_Id
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@l_modified_date
                ,@iUserID
                ,@i_State_Code
                ,@i_class_code
                ,@i_AssgnType
                ,@i_Effective_Date
                ,@i_Termination_Date
                ,@i_penalty_sched_ID
                ,@i_penalty_sched_Desc
                ,@i_Withhold_id
                ,@i_Withhold_desc
                ,@i_Member_Delay_notify
                ,@i_Provider_Delay_notify
                ,@i_recoup_days
                ,@i_recoup_minimum
                ,@i_Send_EOP_to_Patient					-- SP51
                ,@i_Privacy_dependent_Age				-- SP51
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				SELECT @i_class_code = LEFT(@i_class_code, 1)

				-- Update to the static gid
				UPDATE dbo.State_Withhold 
				   SET state_withhold_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND state_code				= @i_State_Code
				   AND class_code				= @i_class_code
				   AND assignment_type			= @i_AssgnType
				   AND effective_date			= @i_Effective_Date
			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_State_Code, @i_class_code, @i_AssgnType, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM StateProcessingParameters_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_State_Withhold_Gid
             ,@i_Date_Time_Modified
             ,@i_User_Id
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_State_Code
             ,@i_class_code
             ,@i_AssgnType
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_penalty_sched_ID
             ,@i_penalty_sched_Desc
             ,@i_Withhold_id
             ,@i_Withhold_desc
             ,@i_Member_Delay_notify
             ,@i_Provider_Delay_notify
             ,@i_recoup_days
             ,@i_recoup_minimum
             ,@i_Send_EOP_to_Patient
             ,@i_Privacy_dependent_Age
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE StateProcessingParameters_Cursor
DEALLOCATE StateProcessingParameters_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#StateProcessingParameters') IS NOT NULL
	DROP TABLE #StateProcessingParameters

END
GO

