IF OBJECT_ID('dbo.spDCAuto_CreateCopaySchedulesVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCopaySchedulesVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCopaySchedulesVariation
Purpose:    Create copayschedulesvariation data from CorderAutomation

Screen:     48
Method:     CopaySchedulesVariation
Procedure:  dbo.prCopayScheduleAddModify 
Entity:     Copay_Schedule

Date        User            Change
---------------------------------------------------------------------------------------------
04/21/2022	DK				Original procedure
05/03/2022  DK				Updated stored procedure name (SP50)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCopaySchedulesVariation '600-Config%', 22, '600-Config','CopaySchedulesVariation','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCopaySchedulesVariation
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

DECLARE @i_entity_name           VARCHAR(50)
       ,@i_Copay_Schedule_gid    VARCHAR(50)
       ,@i_Copay_Sequence_Number VARCHAR(50)
       ,@i_key_3_field           VARCHAR(50)
       ,@i_key_4_field           VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(100)
       ,@i_key_7_field           VARCHAR(100)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(50)
       ,@i_Date_Time_Modified    VARCHAR(50)
       ,@iUserID                 VARCHAR(50)
       ,@Schedule_ID             VARCHAR(50)
       ,@Schedule_Name           VARCHAR(50)
       ,@i_Copay_Source          VARCHAR(50)
       ,@i_Copay_Type            VARCHAR(100)
       ,@i_Copay_Calc_Type       VARCHAR(50)
       ,@i_Sequence_Number       VARCHAR(50)
       ,@i_DAW_Code              VARCHAR(50)
       ,@i_Diff_Option           VARCHAR(50)
       ,@i_Copay_Percent         VARCHAR(50)
       ,@i_Dollar_Amount         VARCHAR(50)
       ,@i_Min_Copay             VARCHAR(50)
       ,@i_Max_Copay             VARCHAR(50)
       ,@i_Min_Percent           VARCHAR(50)
       ,@i_Max_Percent           VARCHAR(50)
       ,@i_Decrement_Percent     VARCHAR(50)
       ,@i_Increment_Percent     VARCHAR(50)
       ,@i_Incentive_Base_Date   VARCHAR(50)
       ,@i_Copay_Multiplier      VARCHAR(50)
       ,@i_Step_ID               VARCHAR(50)
       ,@i_Step_Desc             VARCHAR(50)
       ,@i_Fee_Schedule_ID       VARCHAR(50)
       ,@i_Fee_Schedule_Desc     VARCHAR(100)
       ,@i_pro_pol_1_id          VARCHAR(50)
       ,@i_pro_pol_1_desc        VARCHAR(50)
       ,@i_pro_pol_2_id          VARCHAR(50)
       ,@i_pro_pol_2_desc        VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(255)

PRINT 'Stuff'
--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CopaySchedulesVariation') IS NOT NULL
	DROP TABLE #CopaySchedulesVariation

CREATE TABLE #CopaySchedulesVariation
      (SearchID                VARCHAR(200)
      ,i_entity_name           VARCHAR(50)       DEFAULT('Copay_Schedule')
      ,i_Copay_Schedule_gid    VARCHAR(50)       DEFAULT('0')
      ,i_Copay_Sequence_Number VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(100)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(100)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(50)       DEFAULT('ADD')
      ,i_Date_Time_Modified    VARCHAR(50)       DEFAULT('')
      ,iUserID                 VARCHAR(50)       DEFAULT('')
      ,Schedule_ID             VARCHAR(50)
      ,Schedule_Name           VARCHAR(50)
      ,i_Copay_Source          VARCHAR(50)
      ,i_Copay_Type            VARCHAR(100)
      ,i_Copay_Calc_Type       VARCHAR(50)
      ,i_Sequence_Number       VARCHAR(50)
      ,i_DAW_Code              VARCHAR(50)
      ,i_Diff_Option           VARCHAR(50)
      ,i_Copay_Percent         VARCHAR(50)
      ,i_Dollar_Amount         VARCHAR(50)
      ,i_Min_Copay             VARCHAR(50)
      ,i_Max_Copay             VARCHAR(50)
      ,i_Min_Percent           VARCHAR(50)
      ,i_Max_Percent           VARCHAR(50)
      ,i_Decrement_Percent     VARCHAR(50)
      ,i_Increment_Percent     VARCHAR(50)
      ,i_Incentive_Base_Date   VARCHAR(50)
      ,i_Copay_Multiplier      VARCHAR(50)
      ,i_Step_ID               VARCHAR(50)
      ,i_Step_Desc             VARCHAR(50)
      ,i_Fee_Schedule_ID       VARCHAR(50)
      ,i_Fee_Schedule_Desc     VARCHAR(100)
      ,i_pro_pol_1_id          VARCHAR(50)
      ,i_pro_pol_1_desc        VARCHAR(50)
      ,i_pro_pol_2_id          VARCHAR(50)
      ,i_pro_pol_2_desc        VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(255)
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

    INSERT INTO #CopaySchedulesVariation
          (SearchID
		  ,Schedule_ID
          ,i_Copay_Source
          ,i_Copay_Type
          ,i_Copay_Calc_Type
          ,i_Sequence_Number
          ,i_DAW_Code
          ,i_Diff_Option
          ,i_Copay_Percent
          ,i_Dollar_Amount
          ,i_Min_Copay
          ,i_Max_Copay
          ,i_Min_Percent
          ,i_Max_Percent
          ,i_Decrement_Percent
          ,i_Increment_Percent
          ,i_Incentive_Base_Date
          ,i_Copay_Multiplier
          ,i_Step_ID
          ,i_Fee_Schedule_ID
          ,i_pro_pol_1_id
          ,i_pro_pol_2_id
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*CopaySchedID], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CopaySource]), 'T')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CopayType]), 'F')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CalcType]), 'M')
		  ,ISNULL([*SequenceNumber], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DAWCode]), '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DifferentialOption]), '0')
		  ,ISNULL([CopayPercent], '0')
		  ,ISNULL([DollarAmount], '0.00')
		  ,ISNULL([MinCopayAmount], '0.00')
		  ,ISNULL([MaxCopayAmount], '0.00')
		  ,ISNULL([MinIncPercent], '0')
		  ,ISNULL([MaxIncPercent], '0')
		  ,ISNULL([DecrementPcnt], '0')
		  ,ISNULL([IncrementPcnt], '0')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IncentiveBaseDate]), 'N')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CopayMultiplierBasis]), '')
		  ,ISNULL([ScheduleStepID], '')
		  ,ISNULL([FeeScheduleLookup], '')
		  ,ISNULL([RemarkCodeID1], '')
		  ,ISNULL([RemarkCodeID2], '')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_CopaySchedulesVariation
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CopaySchedulesVariation
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
DECLARE CopaySchedulesVariation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Copay_Schedule_gid
       ,i_Copay_Sequence_Number
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
       ,Schedule_ID
       ,Schedule_Name
       ,i_Copay_Source
       ,i_Copay_Type
       ,i_Copay_Calc_Type
       ,i_Sequence_Number
       ,i_DAW_Code
       ,i_Diff_Option
       ,i_Copay_Percent
       ,i_Dollar_Amount
       ,i_Min_Copay
       ,i_Max_Copay
       ,i_Min_Percent
       ,i_Max_Percent
       ,i_Decrement_Percent
       ,i_Increment_Percent
       ,i_Incentive_Base_Date
       ,i_Copay_Multiplier
       ,i_Step_ID
       ,i_Step_Desc
       ,i_Fee_Schedule_ID
       ,i_Fee_Schedule_Desc
       ,i_pro_pol_1_id
       ,i_pro_pol_1_desc
       ,i_pro_pol_2_id
       ,i_pro_pol_2_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CopaySchedulesVariation

   OPEN CopaySchedulesVariation_Cursor
  FETCH NEXT FROM CopaySchedulesVariation_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Copay_Schedule_gid
       ,@i_Copay_Sequence_Number
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
       ,@Schedule_ID
       ,@Schedule_Name
       ,@i_Copay_Source
       ,@i_Copay_Type
       ,@i_Copay_Calc_Type
       ,@i_Sequence_Number
       ,@i_DAW_Code
       ,@i_Diff_Option
       ,@i_Copay_Percent
       ,@i_Dollar_Amount
       ,@i_Min_Copay
       ,@i_Max_Copay
       ,@i_Min_Percent
       ,@i_Max_Percent
       ,@i_Decrement_Percent
       ,@i_Increment_Percent
       ,@i_Incentive_Base_Date
       ,@i_Copay_Multiplier
       ,@i_Step_ID
       ,@i_Step_Desc
       ,@i_Fee_Schedule_ID
       ,@i_Fee_Schedule_Desc
       ,@i_pro_pol_1_id
       ,@i_pro_pol_1_desc
       ,@i_pro_pol_2_id
       ,@i_pro_pol_2_desc
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

			-- Lookup the Copay Schedule gid
			SELECT @i_Copay_Schedule_gid	= SN.schedule_gid
				  ,@Schedule_Name			= SN.schedule_name
			  FROM dbo.Schedule_Names		SN
			 WHERE SN.schedule_id			= @Schedule_ID
			   AND SN.Record_Status			= 'A'
			   AND SN.schedule_entity		= 'C'

			IF @i_Copay_Schedule_gid <> 0 
				BEGIN

			EXEC dbo.prCopayScheduleAdd		-- SP50			prCopayScheduleAddModify 
                 @i_entity_name
                ,@i_Copay_Schedule_gid
                ,@i_Copay_Sequence_Number
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
                ,@Schedule_ID
                ,@Schedule_Name
                ,@i_Copay_Source
                ,@i_Copay_Type
                ,@i_Copay_Calc_Type
                ,@i_Sequence_Number
                ,@i_DAW_Code
                ,@i_Diff_Option
                ,@i_Copay_Percent
                ,@i_Dollar_Amount
                ,@i_Min_Copay
                ,@i_Max_Copay
                ,@i_Min_Percent
                ,@i_Max_Percent
                ,@i_Decrement_Percent
                ,@i_Increment_Percent
                ,@i_Incentive_Base_Date
                ,@i_Copay_Multiplier
                ,@i_Step_ID
                ,@i_Step_Desc
                ,@i_Fee_Schedule_ID
                ,@i_Fee_Schedule_Desc
                ,@i_pro_pol_1_id
                ,@i_pro_pol_1_desc
                ,@i_pro_pol_2_id
                ,@i_pro_pol_2_desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT
				END
			ELSE
				BEGIN
					SELECT @err_num = 116
						  ,@err_msg	= 'The copay schedule was not found.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @Schedule_ID, @i_Copay_Type, @i_Dollar_Amount, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CopaySchedulesVariation_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Copay_Schedule_gid
             ,@i_Copay_Sequence_Number
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
             ,@Schedule_ID
             ,@Schedule_Name
             ,@i_Copay_Source
             ,@i_Copay_Type
             ,@i_Copay_Calc_Type
             ,@i_Sequence_Number
             ,@i_DAW_Code
             ,@i_Diff_Option
             ,@i_Copay_Percent
             ,@i_Dollar_Amount
             ,@i_Min_Copay
             ,@i_Max_Copay
             ,@i_Min_Percent
             ,@i_Max_Percent
             ,@i_Decrement_Percent
             ,@i_Increment_Percent
             ,@i_Incentive_Base_Date
             ,@i_Copay_Multiplier
             ,@i_Step_ID
             ,@i_Step_Desc
             ,@i_Fee_Schedule_ID
             ,@i_Fee_Schedule_Desc
             ,@i_pro_pol_1_id
             ,@i_pro_pol_1_desc
             ,@i_pro_pol_2_id
             ,@i_pro_pol_2_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CopaySchedulesVariation_Cursor
DEALLOCATE CopaySchedulesVariation_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CopaySchedulesVariation') IS NOT NULL
	DROP TABLE #CopaySchedulesVariation

END
GO

