IF OBJECT_ID('dbo.spDCAuto_CreatePriceScheduleVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePriceScheduleVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePriceScheduleVariation
Purpose:    Create priceschedulevariation data from CorderAutomation
Method:     PriceScheduleVariation
Screen GID: 55
Procedure:  dbo.prPriceScheduleAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePriceScheduleVariation '100-Config%', 22, 'PriceScheduleVariation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePriceScheduleVariation
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

DECLARE @i_entity_name           VARCHAR(100)
       ,@i_Price_Schedule_gid    VARCHAR(80)
       ,@i_Price_Sequence_Number VARCHAR(20)
       ,@i_key_3_field           VARCHAR(50)
       ,@i_key_4_field           VARCHAR(20)
       ,@i_key_5_field           VARCHAR(20)
       ,@i_key_6_field           VARCHAR(20)
       ,@i_key_7_field           VARCHAR(100)
       ,@i_key_8_field           VARCHAR(100)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(100)
       ,@i_action                VARCHAR(10)
       ,@i_Date_Time_Modified    VARCHAR(20)
       ,@iUserID                 VARCHAR(25)
       ,@i_Price_Source          VARCHAR(20)
       ,@i_Price_Type            VARCHAR(50)
       ,@i_Sequence_Number       VARCHAR(50)
       ,@i_Markup_Amount         VARCHAR(50)
       ,@i_Flat_Fee              VARCHAR(50)
       ,@i_Dispensing_Fee        VARCHAR(50)
       ,@i_Price_Multiplier      VARCHAR(50)
       ,@i_Step_ID               VARCHAR(50)
       ,@i_Step_Desc             VARCHAR(50)
       ,@i_Fee_Lookup_ID         VARCHAR(50)
       ,@i_Fee_Lookup_Desc       VARCHAR(50)
       ,@i_pro_pol_1_id          VARCHAR(50)
       ,@i_pro_pol_1_desc        VARCHAR(50)
       ,@i_pro_pol_2_id          VARCHAR(50)
       ,@i_pro_pol_2_desc        VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(200)
	   ,@SearchID				 VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PriceScheduleVariation') IS NOT NULL
	DROP TABLE #PriceScheduleVariation

CREATE TABLE #PriceScheduleVariation
      (i_entity_name           VARCHAR(100)      DEFAULT('Price_Schedule')
      ,i_Price_Schedule_gid    VARCHAR(80)       DEFAULT('0')
      ,i_Price_Sequence_Number VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(20)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_8_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(100)      DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified    VARCHAR(20)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_Price_Source          VARCHAR(20)
      ,i_Price_Type            VARCHAR(50)
      ,i_Sequence_Number       VARCHAR(50)
      ,i_Markup_Amount         VARCHAR(50)
      ,i_Flat_Fee              VARCHAR(50)
      ,i_Dispensing_Fee        VARCHAR(50)
      ,i_Price_Multiplier      VARCHAR(50)
      ,i_Step_ID               VARCHAR(50)
      ,i_Step_Desc             VARCHAR(50)
      ,i_Fee_Lookup_ID         VARCHAR(50)
      ,i_Fee_Lookup_Desc       VARCHAR(50)
      ,i_pro_pol_1_id          VARCHAR(50)
      ,i_pro_pol_1_desc        VARCHAR(50)
      ,i_pro_pol_2_id          VARCHAR(50)
      ,i_pro_pol_2_desc        VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(200)
      ,record_id               INT
      ,static_gid              INT
	  ,SearchID				   VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PriceScheduleVariation
      (SearchID
	  ,i_Price_Source
      ,i_Price_Type
      ,i_Sequence_Number
      ,i_Markup_Amount
      ,i_Flat_Fee
      ,i_Dispensing_Fee
      ,i_Price_Multiplier
      ,i_Step_ID
      ,i_Fee_Lookup_ID
      ,i_pro_pol_1_id
      ,i_pro_pol_2_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PriceSource]), 'AGG')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PriceType]), 'FEE')
      ,ISNULL([*SequenceNumber], '0')
      ,ISNULL([MarkupPercent], '0.00')
      ,ISNULL([FlatDollarAmount], '0.00')
      ,ISNULL([DispensingFee], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContractBasis]), '')
      ,ISNULL([ScheduleStepID], '')
      ,ISNULL([FeeScheduleLookup], '')
      ,ISNULL([RemarkCode1], '')
      ,ISNULL([RemarkCode2], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PriceScheduleVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PriceScheduleVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PriceScheduleVariation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Price_Schedule_gid
       ,i_Price_Sequence_Number
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
       ,i_Price_Source
       ,i_Price_Type
       ,i_Sequence_Number
       ,i_Markup_Amount
       ,i_Flat_Fee
       ,i_Dispensing_Fee
       ,i_Price_Multiplier
       ,i_Step_ID
       ,i_Step_Desc
       ,i_Fee_Lookup_ID
       ,i_Fee_Lookup_Desc
       ,i_pro_pol_1_id
       ,i_pro_pol_1_desc
       ,i_pro_pol_2_id
       ,i_pro_pol_2_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PriceScheduleVariation

   OPEN PriceScheduleVariation_Cursor
  FETCH NEXT FROM PriceScheduleVariation_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Price_Schedule_gid
       ,@i_Price_Sequence_Number
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
       ,@i_Price_Source
       ,@i_Price_Type
       ,@i_Sequence_Number
       ,@i_Markup_Amount
       ,@i_Flat_Fee
       ,@i_Dispensing_Fee
       ,@i_Price_Multiplier
       ,@i_Step_ID
       ,@i_Step_Desc
       ,@i_Fee_Lookup_ID
       ,@i_Fee_Lookup_Desc
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

			-- Lookup the Copay Levels gid
			SELECT @i_Price_Schedule_gid	= schedule_gid
			  FROM Schedule_Names
		     WHERE schedule_id				= @SearchID
			   AND Record_Status			= 'A'

			EXEC dbo.prPriceScheduleAddModify
             @i_entity_name
            ,@i_Price_Schedule_gid
            ,@i_Price_Sequence_Number
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
            ,@i_Price_Source
            ,@i_Price_Type
            ,@i_Sequence_Number
            ,@i_Markup_Amount
            ,@i_Flat_Fee
            ,@i_Dispensing_Fee
            ,@i_Price_Multiplier
            ,@i_Step_ID
            ,@i_Step_Desc
            ,@i_Fee_Lookup_ID
            ,@i_Fee_Lookup_Desc
            ,@i_pro_pol_1_id
            ,@i_pro_pol_1_desc
            ,@i_pro_pol_2_id
            ,@i_pro_pol_2_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Price_Source, @i_Price_Type, @status, @err_num, @err_msg

        FETCH NEXT FROM PriceScheduleVariation_Cursor
         INTO @SearchID
			 ,@i_entity_name
             ,@i_Price_Schedule_gid
             ,@i_Price_Sequence_Number
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
             ,@i_Price_Source
             ,@i_Price_Type
             ,@i_Sequence_Number
             ,@i_Markup_Amount
             ,@i_Flat_Fee
             ,@i_Dispensing_Fee
             ,@i_Price_Multiplier
             ,@i_Step_ID
             ,@i_Step_Desc
             ,@i_Fee_Lookup_ID
             ,@i_Fee_Lookup_Desc
             ,@i_pro_pol_1_id
             ,@i_pro_pol_1_desc
             ,@i_pro_pol_2_id
             ,@i_pro_pol_2_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PriceScheduleVariation_Cursor
DEALLOCATE PriceScheduleVariation_Cursor

END
GO