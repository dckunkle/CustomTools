IF OBJECT_ID('dbo.spDCAuto_CreatePriceSchedule') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePriceSchedule AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePriceSchedule
Purpose:    Create priceschedule data from CorderAutomation
Method:     PriceSchedule
Screen GID: 52
Procedure:  dbo.prScheduleNameAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/07/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePriceSchedule '100-Config%', 22, 'PriceSchedule'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePriceSchedule
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

DECLARE @i_entity             VARCHAR(20)
       ,@i_Sched_GID          VARCHAR(100)
       ,@i_key_2_field        VARCHAR(30)
       ,@i_key_3_field        VARCHAR(30)
       ,@i_key_4_field        VARCHAR(20)
       ,@i_key_5_field        VARCHAR(100)
       ,@i_key_6_field        VARCHAR(30)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(30)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(20)
       ,@i_action             VARCHAR(80)
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Schedule_ID        VARCHAR(50)
       ,@i_Schedule_Name      VARCHAR(50)
       ,@i_Comparison_Flag    VARCHAR(50)
       ,@i_Comparison_Flag_2  VARCHAR(50)
       ,@i_StopLossAmount     VARCHAR(50)
       ,@i_StopLossOption     VARCHAR(50)
       ,@i_StopLossSchedID    VARCHAR(50)
       ,@i_StopLossSchedDesc  VARCHAR(50)
       ,@i_ExceptionListID    VARCHAR(50)
       ,@i_ExceptionListDesc  VARCHAR(50)
       ,@i_MinPayAmount       VARCHAR(50)
       ,@i_MinPayFlag         VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)
       ,@i_MaxCopay_Option    VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PriceSchedule') IS NOT NULL
	DROP TABLE #PriceSchedule

CREATE TABLE #PriceSchedule
      (i_entity             VARCHAR(20)       DEFAULT('Price_Schedule_Name')
      ,i_Sched_GID          VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(20)       DEFAULT('0')
      ,i_action             VARCHAR(80)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(200)      DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Schedule_ID        VARCHAR(50)
      ,i_Schedule_Name      VARCHAR(50)
      ,i_Comparison_Flag    VARCHAR(50)
      ,i_Comparison_Flag_2  VARCHAR(50)
      ,i_StopLossAmount     VARCHAR(50)
      ,i_StopLossOption     VARCHAR(50)
      ,i_StopLossSchedID    VARCHAR(50)
      ,i_StopLossSchedDesc  VARCHAR(50)
      ,i_ExceptionListID    VARCHAR(50)
      ,i_ExceptionListDesc  VARCHAR(50)
      ,i_MinPayAmount       VARCHAR(50)
      ,i_MinPayFlag         VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,i_MaxCopay_Option    VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PriceSchedule
      (i_Schedule_ID
      ,i_Schedule_Name
      ,i_Comparison_Flag
      ,i_Comparison_Flag_2
      ,i_StopLossAmount
      ,i_StopLossOption
      ,i_StopLossSchedID
      ,i_ExceptionListID
	  ,i_MinPayAmount
	  ,i_MinPayFlag
      ,record_id
      ,static_gid)
SELECT ISNULL([*PriceScheduleID], '')
      ,ISNULL([*ScheduleDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AllowedAlgorithm]), 'F')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApprovedAlgorithm]), 'F')
      ,ISNULL([StopLossAmount], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([StopLossOption]), '')
      ,ISNULL([StopLossPriceSchedID], '')
      ,ISNULL([StopLossExceptionListID], '')
      ,ISNULL([MinimumPaymentAmount], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MinimumPaymentProcessing]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PriceSchedule
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PriceSchedule
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PriceSchedule_Cursor CURSOR FOR
 SELECT i_entity
       ,i_Sched_GID
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
       ,i_Comparison_Flag_2
       ,i_StopLossAmount
       ,i_StopLossOption
       ,i_StopLossSchedID
       ,i_StopLossSchedDesc
       ,i_ExceptionListID
       ,i_ExceptionListDesc
       ,i_MinPayAmount
       ,i_MinPayFlag
       ,o_status
       ,o_message
       ,i_MaxCopay_Option
       ,record_id
       ,static_gid
   FROM #PriceSchedule

   OPEN PriceSchedule_Cursor
  FETCH NEXT FROM PriceSchedule_Cursor
   INTO @i_entity
       ,@i_Sched_GID
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
       ,@i_Comparison_Flag_2
       ,@i_StopLossAmount
       ,@i_StopLossOption
       ,@i_StopLossSchedID
       ,@i_StopLossSchedDesc
       ,@i_ExceptionListID
       ,@i_ExceptionListDesc
       ,@i_MinPayAmount
       ,@i_MinPayFlag
       ,@o_status
       ,@o_message
       ,@i_MaxCopay_Option
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		BEGIN TRY
			EXEC dbo.prScheduleNameAddModify
				 @i_entity
				,@i_Sched_GID
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
				,@i_Comparison_Flag_2
				,@i_StopLossAmount
				,@i_StopLossOption
				,@i_StopLossSchedID
				,@i_StopLossSchedDesc
				,@i_ExceptionListID
				,@i_ExceptionListDesc
				,@i_MinPayAmount
				,@i_MinPayFlag
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT
				--,@i_MaxCopay_Option

		END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

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

        FETCH NEXT FROM PriceSchedule_Cursor
         INTO @i_entity
             ,@i_Sched_GID
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
             ,@i_Comparison_Flag_2
             ,@i_StopLossAmount
             ,@i_StopLossOption
             ,@i_StopLossSchedID
             ,@i_StopLossSchedDesc
             ,@i_ExceptionListID
             ,@i_ExceptionListDesc
             ,@i_MinPayAmount
             ,@i_MinPayFlag
             ,@o_status
             ,@o_message
             ,@i_MaxCopay_Option
             ,@record_id
             ,@static_gid
	END

CLOSE PriceSchedule_Cursor
DEALLOCATE PriceSchedule_Cursor

END
GO