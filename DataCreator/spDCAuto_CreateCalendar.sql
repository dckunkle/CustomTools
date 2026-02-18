IF OBJECT_ID('dbo.spDCAuto_CreateCalendar') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCalendar AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCalendar
Purpose:    Create coverage codes from CorderAutomation

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCalendar '100-Config%', 22, 'Calendar'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCalendar
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

DECLARE	@i_Entity_name 			VARCHAR(50)
       ,@i_Calendar_Gid 		VARCHAR(50)
       ,@i_key_2_field 			VARCHAR(50)
       ,@i_key_3_field 			VARCHAR(50)
       ,@i_key_4_field 			VARCHAR(50)
       ,@i_key_5_field 			VARCHAR(50)
       ,@i_key_6_field 			VARCHAR(50)
       ,@i_key_7_field 			VARCHAR(50)
       ,@i_key_8_field 			VARCHAR(50)
       ,@i_key_9_field 			VARCHAR(50)
       ,@i_key_10_field 		VARCHAR(50)
       ,@i_action 				VARCHAR(10)
       ,@i_modified_date 		VARCHAR(50)
       ,@iUserID 				VARCHAR(25)
       ,@l_Calendar_id 			VARCHAR(20)
       ,@l_Calendar_description	VARCHAR(100)
       ,@l_effective_date 		VARCHAR(20)
       ,@l_termination_date 	VARCHAR(20)
       ,@l_frequency 			VARCHAR(30)
       ,@l_run_date_day_option 	VARCHAR(10)
       ,@l_handling 			VARCHAR(50)
       ,@iScheduleID 			VARCHAR(20)
       ,@iScheduleName 			VARCHAR(50)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Calendars') IS NOT NULL
	DROP TABLE #Calendars

CREATE TABLE #Calendars
      (i_Entity_name 			VARCHAR(50)		DEFAULT('Calendar')
      ,i_Calendar_Gid 			VARCHAR(50)		DEFAULT('0')
      ,i_key_2_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_3_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_4_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_5_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_6_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_7_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_8_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_9_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_10_field 			VARCHAR(50)		DEFAULT('0')
      ,i_action 				VARCHAR(10)		DEFAULT('ADD')
      ,i_modified_date 			VARCHAR(50)		DEFAULT('')
      ,iUserID 					VARCHAR(25)		DEFAULT('')
      ,l_Calendar_id 			VARCHAR(20)		
      ,l_Calendar_description 	VARCHAR(100)		
      ,l_effective_date 		VARCHAR(20)		DEFAULT('GETDATE()')
      ,l_termination_date 		VARCHAR(20)		DEFAULT('9999-12-31')
      ,l_frequency 				VARCHAR(30)		
      ,l_run_date_day_option 	VARCHAR(10)		DEFAULT('0')
      ,l_handling 				VARCHAR(50)		
      ,iScheduleID 				VARCHAR(20)		
      ,iScheduleName 			VARCHAR(50)
	  ,record_id				INT
	  ,gid						INT)

--*************************************************************************************************
-- Populate the table with data to be created
--*************************************************************************************************
INSERT INTO #Calendars
      (l_Calendar_id
      ,l_Calendar_description
      ,l_effective_date
      ,l_termination_date
      ,l_frequency
      ,l_run_date_day_option
      ,l_handling
      ,iScheduleID
	  ,record_id
	  ,gid)
SELECT ISNULL([*CalendarID], '')
	  ,ISNULL([*CalendarDesc], '')
	  ,ISNULL([*EffectiveDate], GETDATE())
	  ,ISNULL([*TerminationDate], '9999-12-31')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue(Frequency), 'A')
	  ,ISNULL([*RunDateDayOption], '1')
	  ,CASE WHEN ISNULL(WeekendHandling, '') = '<partial>On Date' THEN 'D'
	        WHEN ISNULL(WeekendHandling, '') = ''				 THEN ''
		END
	  ,ISNULL(ScheduleID, '')
	  ,RecordID
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_Calendar
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Calendars
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Calendar_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Calendar_Gid
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
       ,i_modified_date
       ,iUserID
       ,l_Calendar_id
       ,l_Calendar_description
       ,l_effective_date
       ,l_termination_date
       ,l_frequency
       ,l_run_date_day_option
       ,l_handling
       ,iScheduleID
       ,iScheduleName
	   ,record_id
	   ,gid

   FROM #Calendars


   OPEN Calendar_Cursor
  FETCH NEXT FROM Calendar_Cursor
   INTO @i_Entity_name
       ,@i_Calendar_Gid
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
       ,@i_modified_date
       ,@iUserID
       ,@l_Calendar_id
       ,@l_Calendar_description
       ,@l_effective_date
       ,@l_termination_date
       ,@l_frequency
       ,@l_run_date_day_option
       ,@l_handling
       ,@iScheduleID
       ,@iScheduleName
	   ,@record_id
	   ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC prCalendar_Add_Modify 
			 @i_Entity_name
			,@i_Calendar_Gid
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
			,@i_modified_date
			,@iUserID
			,@l_Calendar_id
			,@l_Calendar_description
			,@l_effective_date
			,@l_termination_date
			,@l_frequency
			,@l_run_date_day_option
			,@l_handling
			,@iScheduleID
			,@iScheduleName
			,@o_status				= @err_num	OUTPUT
			,@o_message				= @err_msg	OUTPUT

		-- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Calendar 
				   SET calendar_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND calendar_id				= @l_Calendar_id

			END
						
		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @l_Calendar_id, @l_Calendar_description, '', @status, @err_num, @err_msg

		FETCH NEXT FROM Calendar_Cursor
		 INTO @i_Entity_name
		     ,@i_Calendar_Gid
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
		     ,@i_modified_date
		     ,@iUserID
		     ,@l_Calendar_id
		     ,@l_Calendar_description
		     ,@l_effective_date
		     ,@l_termination_date
		     ,@l_frequency
		     ,@l_run_date_day_option
		     ,@l_handling
		     ,@iScheduleID
		     ,@iScheduleName
		     ,@record_id
			 ,@static_gid
 
	END

CLOSE Calendar_Cursor
DEALLOCATE Calendar_Cursor

END
GO