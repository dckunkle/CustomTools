IF OBJECT_ID('dbo.spDCAuto_CreateJobAdministration') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateJobAdministration AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateJobAdministration
Purpose:    Create jobadministration data from CorderAutomation
Method:     JobAdministration
Screen GID: 390
Procedure:  dbo.prJobAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateJobAdministration '100-Config%', 22, 'JobAdministration'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateJobAdministration
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

DECLARE @i_entity_name         VARCHAR(20)
       ,@o_job_gid             VARCHAR(50)
       ,@o_job_category        VARCHAR(30)
       ,@o_job_start_time      VARCHAR(50)
       ,@o_job_end_time        VARCHAR(20)
       ,@o_day                 VARCHAR(20)
       ,@o_job_status          VARCHAR(30)
       ,@i_key_7_field         VARCHAR(100)
       ,@i_key_8_field         VARCHAR(100)
       ,@i_key_9_field         VARCHAR(50)
       ,@i_key_10_field        VARCHAR(50)
       ,@i_action              VARCHAR(10)
       ,@i_blank               VARCHAR(50)
       ,@i_UserID              VARCHAR(25)
       ,@i_New_Job_ID          VARCHAR(10)
       ,@i_New_Job_Desc        VARCHAR(50)
       ,@i_New_Job_Category    VARCHAR(255)
       ,@i_New_Job_Start       VARCHAR(4)
       ,@i_New_Job_End         VARCHAR(4)
       ,@i_New_Job_Day         VARCHAR(6)
       ,@i_NewRunDateDayOption VARCHAR(15)
       ,@i_New_Job_Status      VARCHAR(1)
       ,@i_Notification_email  VARCHAR(250)
       ,@o_status              INT
       ,@o_message             VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#JobAdministration') IS NOT NULL
	DROP TABLE #JobAdministration

CREATE TABLE #JobAdministration
      (i_entity_name         VARCHAR(20)       DEFAULT('Job_Admin')
      ,o_job_gid             VARCHAR(50)       DEFAULT('0')
      ,o_job_category        VARCHAR(30)       DEFAULT('0')
      ,o_job_start_time      VARCHAR(50)       DEFAULT('0')
      ,o_job_end_time        VARCHAR(20)       DEFAULT('0')
      ,o_day                 VARCHAR(20)       DEFAULT('0')
      ,o_job_status          VARCHAR(30)       DEFAULT('0')
      ,i_key_7_field         VARCHAR(100)       DEFAULT('0')
      ,i_key_8_field         VARCHAR(100)       DEFAULT('0')
      ,i_key_9_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,i_blank               VARCHAR(50)       DEFAULT('')
      ,i_UserID              VARCHAR(25)       DEFAULT('')
      ,i_New_Job_ID          VARCHAR(10)
      ,i_New_Job_Desc        VARCHAR(50)
      ,i_New_Job_Category    VARCHAR(255)
      ,i_New_Job_Start       VARCHAR(4)
      ,i_New_Job_End         VARCHAR(4)
      ,i_New_Job_Day         VARCHAR(6)
      ,i_NewRunDateDayOption VARCHAR(15)
      ,i_New_Job_Status      VARCHAR(1)
      ,i_Notification_email  VARCHAR(250)
      ,o_status              INT
      ,o_message             VARCHAR(255)
      ,record_id             INT
      ,static_gid            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #JobAdministration
      (i_New_Job_ID
      ,i_New_Job_Desc
      ,i_New_Job_Category
      ,i_New_Job_Start
      ,i_New_Job_End
      ,i_New_Job_Day
      ,i_NewRunDateDayOption
      ,i_New_Job_Status
      ,i_Notification_email
      ,record_id
      ,static_gid)
SELECT ISNULL([*JobID], '')
      ,ISNULL([*JobDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Category]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*StartTime]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*EndTime]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Day]), 'EVE')
      ,ISNULL([RunDateDayOption], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Status]), 'D')
      ,ISNULL([EmailNotification], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_JobAdministration
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #JobAdministration
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE JobAdministration_Cursor CURSOR FOR
 SELECT i_entity_name
       ,o_job_gid
       ,o_job_category
       ,o_job_start_time
       ,o_job_end_time
       ,o_day
       ,o_job_status
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_blank
       ,i_UserID
       ,i_New_Job_ID
       ,i_New_Job_Desc
       ,i_New_Job_Category
       ,i_New_Job_Start
       ,i_New_Job_End
       ,i_New_Job_Day
       ,i_NewRunDateDayOption
       ,i_New_Job_Status
       ,i_Notification_email
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #JobAdministration

   OPEN JobAdministration_Cursor
  FETCH NEXT FROM JobAdministration_Cursor
   INTO @i_entity_name
       ,@o_job_gid
       ,@o_job_category
       ,@o_job_start_time
       ,@o_job_end_time
       ,@o_day
       ,@o_job_status
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_blank
       ,@i_UserID
       ,@i_New_Job_ID
       ,@i_New_Job_Desc
       ,@i_New_Job_Category
       ,@i_New_Job_Start
       ,@i_New_Job_End
       ,@i_New_Job_Day
       ,@i_NewRunDateDayOption
       ,@i_New_Job_Status
       ,@i_Notification_email
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prJobAddModify
             @i_entity_name
            ,@o_job_gid
            ,@o_job_category
            ,@o_job_start_time
            ,@o_job_end_time
            ,@o_day
            ,@o_job_status
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_blank
            ,@i_UserID
            ,@i_New_Job_ID
            ,@i_New_Job_Desc
            ,@i_New_Job_Category
            ,@i_New_Job_Start
            ,@i_New_Job_End
            ,@i_New_Job_Day
            ,@i_NewRunDateDayOption
            ,@i_New_Job_Status
            ,@i_Notification_email
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

			SET @err_num = ISNULL(@err_num, 0)

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Batch_Job_Definition 
				   SET job_gid				= @static_gid 
				 WHERE record_status		= 'A'
				   AND job_id				= @i_New_Job_ID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_New_Job_ID, @i_New_Job_Desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM JobAdministration_Cursor
         INTO @i_entity_name
             ,@o_job_gid
             ,@o_job_category
             ,@o_job_start_time
             ,@o_job_end_time
             ,@o_day
             ,@o_job_status
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_blank
             ,@i_UserID
             ,@i_New_Job_ID
             ,@i_New_Job_Desc
             ,@i_New_Job_Category
             ,@i_New_Job_Start
             ,@i_New_Job_End
             ,@i_New_Job_Day
             ,@i_NewRunDateDayOption
             ,@i_New_Job_Status
             ,@i_Notification_email
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE JobAdministration_Cursor
DEALLOCATE JobAdministration_Cursor

END
GO