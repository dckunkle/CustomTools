IF OBJECT_ID('dbo.spDCAuto_CreateCopaySchedules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCopaySchedules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCopaySchedules
Purpose:    Create copayschedules data from CorderAutomation
Method:     CopaySchedules
Screen GID: 53
Procedure:  dbo.prScheduleNameAddModWrapper

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCopaySchedules '100-Config%', 22, 'CopaySchedules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCopaySchedules
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

DECLARE @i_entity             VARCHAR(50)
       ,@i_Key_1_field        VARCHAR(100)
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
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Schedule_ID        VARCHAR(50)
       ,@i_Schedule_Name      VARCHAR(50)
       ,@i_Comparison_Flag    VARCHAR(50)
       ,@i_MaxCopay_Option    VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CopaySchedules') IS NOT NULL
	DROP TABLE #CopaySchedules

CREATE TABLE #CopaySchedules
      (i_entity             VARCHAR(50)       DEFAULT('Copay_Schedule_Name')
      ,i_Key_1_field        VARCHAR(100)      DEFAULT('0')
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
      ,i_Date_Time_Modified VARCHAR(200)      DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Schedule_ID        VARCHAR(50)
      ,i_Schedule_Name      VARCHAR(50)
      ,i_Comparison_Flag    VARCHAR(50)
      ,i_MaxCopay_Option    VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CopaySchedules
      (i_Schedule_ID
      ,i_Schedule_Name
      ,i_Comparison_Flag
      ,i_MaxCopay_Option
      ,record_id
      ,static_gid)
SELECT ISNULL([*ID], '')
      ,ISNULL([*Description], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ComparisonFlag]), 'F')
      ,ISNULL([MaxCopay], 'Y')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CopaySchedules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CopaySchedules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CopaySchedules_Cursor CURSOR FOR
 SELECT i_entity
       ,i_Key_1_field
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
       ,i_Schedule_ID
       ,i_Schedule_Name
       ,i_Comparison_Flag
       ,i_MaxCopay_Option
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CopaySchedules

   OPEN CopaySchedules_Cursor
  FETCH NEXT FROM CopaySchedules_Cursor
   INTO @i_entity
       ,@i_Key_1_field
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
       ,@i_Schedule_ID
       ,@i_Schedule_Name
       ,@i_Comparison_Flag
       ,@i_MaxCopay_Option
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prScheduleNameAddModWrapper
             @i_entity
            ,@i_Key_1_field
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
            ,@i_Schedule_ID
            ,@i_Schedule_Name
            ,@i_Comparison_Flag
            ,@i_MaxCopay_Option
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Schedule_Names 
				   SET schedule_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND schedule_id				= @i_Schedule_ID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Schedule_ID, @i_Schedule_Name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM CopaySchedules_Cursor
         INTO @i_entity
             ,@i_Key_1_field
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
             ,@i_Schedule_ID
             ,@i_Schedule_Name
             ,@i_Comparison_Flag
             ,@i_MaxCopay_Option
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CopaySchedules_Cursor
DEALLOCATE CopaySchedules_Cursor

END
GO