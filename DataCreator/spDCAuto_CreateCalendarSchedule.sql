IF OBJECT_ID('dbo.spDCAuto_CreateCalendarSchedule') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCalendarSchedule AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCalendarSchedule
Purpose:    Create calendarschedule data from CorderAutomation
Method:     CalendarSchedule
Screen GID: 56
Procedure:  dbo.prDetailRuleNameAdd

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCalendarSchedule '100-Config%', 22, 'CalendarSchedule'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCalendarSchedule
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
       ,@i_Rule_gid           VARCHAR(200)
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
       ,@i_Date_Time_Modified CHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Rule_id            VARCHAR(100)
       ,@i_Rule_name          VARCHAR(500)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CalendarSchedule') IS NOT NULL
	DROP TABLE #CalendarSchedule

CREATE TABLE #CalendarSchedule
      (i_entity_name        VARCHAR(100)      DEFAULT('Calendar_Schedule')
      ,i_Rule_gid           VARCHAR(200)      DEFAULT('0')
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
      ,i_Date_Time_Modified CHAR(200)		  DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Rule_id            VARCHAR(100)
      ,i_Rule_name          VARCHAR(500)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CalendarSchedule
      (i_Rule_id
      ,i_Rule_name
      ,record_id
      ,static_gid)
SELECT ISNULL([*CalendarScheduleId], '')
      ,ISNULL([*CalendarScheduleDesc], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CalendarSchedule
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CalendarSchedule
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CalendarSchedule_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_Rule_gid
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
       ,i_Rule_id
       ,i_Rule_name
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CalendarSchedule

   OPEN CalendarSchedule_Cursor
  FETCH NEXT FROM CalendarSchedule_Cursor
   INTO @i_entity_name
       ,@i_Rule_gid
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
       ,@i_Rule_id
       ,@i_Rule_name
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prDetailRuleNameAdd
             @i_entity_name
            ,@i_Rule_gid
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
            ,@i_Rule_id
            ,@i_Rule_name
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Calendar_Schedule'
				   AND entity_user_id			= @i_Rule_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Rule_id, @i_Rule_name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM CalendarSchedule_Cursor
         INTO @i_entity_name
             ,@i_Rule_gid
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
             ,@i_Rule_id
             ,@i_Rule_name
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CalendarSchedule_Cursor
DEALLOCATE CalendarSchedule_Cursor

END
GO