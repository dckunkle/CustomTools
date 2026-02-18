IF OBJECT_ID('dbo.spDCAuto_CreateCalendarScheduleDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCalendarScheduleDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCalendarScheduleDetails
Purpose:    Create calendarscheduledetails data from CorderAutomation

Screen:     81
Method:     CalendarScheduleDetails
Procedure:  dbo.prCalendarSchedule_Add_Modify
Entity:     Calendar_Schedule_Det

Date        User            Change
---------------------------------------------------------------------------------------------
08/26/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCalendarScheduleDetails 'RFF-TestCase-199%', 22, 'RFF-TestCase-199%', 'CalendarScheduleDetails', 'RFF-199'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCalendarScheduleDetails
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

DECLARE @i_Entity_name   VARCHAR(50)
       ,@i_Schedule_Gid  VARCHAR(50)
       ,@iKeyDate        VARCHAR(50)
       ,@i_key_3_field   VARCHAR(50)
       ,@i_key_4_field   VARCHAR(50)
       ,@i_key_5_field   VARCHAR(50)
       ,@i_key_6_field   VARCHAR(50)
       ,@i_key_7_field   VARCHAR(50)
       ,@i_key_8_field   VARCHAR(50)
       ,@i_key_9_field   VARCHAR(50)
       ,@i_key_10_field  VARCHAR(50)
       ,@i_action        VARCHAR(50)
       ,@i_modified_date VARCHAR(50)
       ,@iUserID         VARCHAR(25)
       ,@iScheduleDate   VARCHAR(50)
       ,@o_status        INT
       ,@o_message       VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CalendarScheduleDetails') IS NOT NULL
	DROP TABLE #CalendarScheduleDetails

CREATE TABLE #CalendarScheduleDetails
      (SearchID        VARCHAR(200)
      ,i_Entity_name   VARCHAR(50)       DEFAULT('Calendar_Schedule_Det')
      ,i_Schedule_Gid  VARCHAR(50)       DEFAULT('0')
      ,iKeyDate        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field  VARCHAR(50)       DEFAULT('0')
      ,i_action        VARCHAR(50)       DEFAULT('ADD')
      ,i_modified_date VARCHAR(50)       DEFAULT('')
      ,iUserID         VARCHAR(25)       DEFAULT('')
      ,iScheduleDate   VARCHAR(50)
      ,o_status        INT
      ,o_message       VARCHAR(255)
      ,record_id       INT
      ,static_gid      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #CalendarScheduleDetails
          (SearchID
          ,iScheduleDate
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*SpecificDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_CalendarScheduleDetails
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CalendarScheduleDetails
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
DECLARE CalendarScheduleDetails_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_Schedule_Gid
       ,iKeyDate
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
       ,iScheduleDate
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CalendarScheduleDetails

   OPEN CalendarScheduleDetails_Cursor
  FETCH NEXT FROM CalendarScheduleDetails_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_Schedule_Gid
       ,@iKeyDate
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
       ,@iScheduleDate
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

			SELECT @i_Schedule_Gid		= EN.entity_gid
			  FROM Entity_Names			EN
			 WHERE EN.entity_identifier	= 'CALENDAR_SCHEDULE'
			   AND EN.record_status		= 'A'
			   AND entity_user_id		= @SearchID

			EXEC dbo.prCalendarSchedule_Add_Modify
                 @i_Entity_name
                ,@i_Schedule_Gid
                ,@iKeyDate
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
                ,@iScheduleDate
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iScheduleDate, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CalendarScheduleDetails_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_Schedule_Gid
             ,@iKeyDate
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
             ,@iScheduleDate
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CalendarScheduleDetails_Cursor
DEALLOCATE CalendarScheduleDetails_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CalendarScheduleDetails') IS NOT NULL
	DROP TABLE #CalendarScheduleDetails

END
GO

