IF OBJECT_ID('dbo.spDCAuto_CreatePenalty') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePenalty AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePenalty
Purpose:    Create penalty data from CorderAutomation
Method:     Penalty
Screen GID: 127
Procedure:  dbo.prLate_Pay_Penalty_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
12/10/2019	DK				Remove fields i_ELE_compound and i_PPR_compound from call to SP
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names
08/13/2021  DK				Support new fields from SP47
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePenalty '100-Config%', 22, 'Penalty'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePenalty
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

DECLARE @i_Entity_name                  VARCHAR(100)
       ,@i_Late_Pay_Penalty_Gid         VARCHAR(150)
       ,@i_key_2_field                  VARCHAR(50)
       ,@i_key_3_field                  VARCHAR(50)
       ,@i_key_4_field                  VARCHAR(50)
       ,@i_key_5_field                  VARCHAR(50)
       ,@i_key_6_field                  VARCHAR(50)
       ,@i_key_7_field                  VARCHAR(50)
       ,@i_key_8_field                  VARCHAR(50)
       ,@i_key_9_field                  VARCHAR(50)
       ,@i_key_10_field                 VARCHAR(50)
       ,@i_action                       VARCHAR(50)
       ,@l_modified_date                VARCHAR(50)
       ,@iUserID                        VARCHAR(50)
       ,@i_Late_Pay_Penalty_id          VARCHAR(50)
       ,@i_Late_Pay_Penalty_Description VARCHAR(50)
       ,@i_ELE_Base_date                VARCHAR(50)
       ,@i_PPR_Base_date                VARCHAR(50)
       ,@i_ELE_penalty_days             VARCHAR(50)
       ,@i_PPR_penalty_days             VARCHAR(50)
	   ,@iELEWorkdaysOnly               VARCHAR(50)
       ,@iPPRWorkDaysOnly               VARCHAR(50)
       ,@iELEHolidayScheduleID          VARCHAR(50)
       ,@iPPRHolidayScheduleID          VARCHAR(50)
       ,@iELEHolidayScheduleDesc        VARCHAR(125)
       ,@iPPRHolidayScheduleDesc        VARCHAR(125)
       ,@iELECalcBase                   VARCHAR(50)
       ,@iPPRCalcBase                   VARCHAR(50)
       ,@i_ELE_accrual_method           VARCHAR(50)
       ,@i_PPR_accrual_method           VARCHAR(50)
       ,@i_ELE_penalty_percent          VARCHAR(50)
       ,@i_PPR_penalty_percent          VARCHAR(50)
       ,@i_ELE_max_percent              VARCHAR(50)
       ,@i_PPR_max_percent              VARCHAR(50)
       ,@i_ELE_max_amount               VARCHAR(50)
       ,@i_PPR_max_amount               VARCHAR(50)
       ,@i_ELE_min_amount               VARCHAR(50)
       ,@i_PPR_min_amount               VARCHAR(50)
	   ,@iELESecAccrualMethod           VARCHAR(50)
       ,@iPPRSecAccrualMethod           VARCHAR(50)
       ,@iELESecPenaltyPercent          VARCHAR(50)
       ,@iPPRSecPenaltyPercent          VARCHAR(50)
       ,@i_ELE_do_alap                  VARCHAR(50)
       ,@i_PPR_do_alap                  VARCHAR(50)
       ,@i_ELE_alap_days                INT
       ,@i_PPR_alap_days                INT
       ,@i_ELE_alap_date                VARCHAR(50)
       ,@i_PPR_alap_date                VARCHAR(50)
       ,@o_status                       INT
       ,@o_message                      VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Penalty') IS NOT NULL
	DROP TABLE #Penalty

CREATE TABLE #Penalty
      (SearchID                       VARCHAR(200)
      ,i_Entity_name                  VARCHAR(100)      DEFAULT('Late_Pay_Penalty')
      ,i_Late_Pay_Penalty_Gid         VARCHAR(150)      DEFAULT('0')
      ,i_key_2_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                 VARCHAR(50)       DEFAULT('0')
      ,i_action                       VARCHAR(50)       DEFAULT('ADD')
      ,l_modified_date                VARCHAR(50)       DEFAULT('')
      ,iUserID                        VARCHAR(50)       DEFAULT('')
      ,i_Late_Pay_Penalty_id          VARCHAR(50)
      ,i_Late_Pay_Penalty_Description VARCHAR(50)
      ,i_ELE_Base_date                VARCHAR(50)
      ,i_PPR_Base_date                VARCHAR(50)
      ,i_ELE_penalty_days             VARCHAR(50)
      ,i_PPR_penalty_days             VARCHAR(50)
	  ,iELEWorkdaysOnly               VARCHAR(50)
      ,iPPRWorkDaysOnly               VARCHAR(50)
      ,iELEHolidayScheduleID          VARCHAR(50)
      ,iPPRHolidayScheduleID          VARCHAR(50)
      ,iELEHolidayScheduleDesc        VARCHAR(125)
      ,iPPRHolidayScheduleDesc        VARCHAR(125)
      ,iELECalcBase                   VARCHAR(50)
      ,iPPRCalcBase                   VARCHAR(50)
      ,i_ELE_accrual_method           VARCHAR(50)
      ,i_PPR_accrual_method           VARCHAR(50)
      ,i_ELE_penalty_percent          VARCHAR(50)
      ,i_PPR_penalty_percent          VARCHAR(50)
      ,i_ELE_max_percent              VARCHAR(50)
      ,i_PPR_max_percent              VARCHAR(50)
      ,i_ELE_max_amount               VARCHAR(50)
      ,i_PPR_max_amount               VARCHAR(50)
      ,i_ELE_min_amount               VARCHAR(50)
      ,i_PPR_min_amount               VARCHAR(50)
      ,iELESecAccrualMethod           VARCHAR(50)
      ,iPPRSecAccrualMethod           VARCHAR(50)
      ,iELESecPenaltyPercent          VARCHAR(50)
      ,iPPRSecPenaltyPercent          VARCHAR(50)
      ,i_ELE_do_alap                  VARCHAR(50)
      ,i_PPR_do_alap                  VARCHAR(50)
      ,i_ELE_alap_days                INT
      ,i_PPR_alap_days                INT
      ,i_ELE_alap_date                VARCHAR(50)
      ,i_PPR_alap_date                VARCHAR(50)
      ,o_status                       INT
      ,o_message                      VARCHAR(255)
      ,record_id                      INT
      ,static_gid                     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Penalty
      (SearchID
      ,i_Late_Pay_Penalty_id
      ,i_Late_Pay_Penalty_Description
      ,i_ELE_Base_date
      ,i_PPR_Base_date
      ,i_ELE_penalty_days
      ,i_PPR_penalty_days
	  ,iELEWorkdaysOnly
      ,iPPRWorkDaysOnly
      ,iELEHolidayScheduleID
      ,iPPRHolidayScheduleID
      ,iELECalcBase
      ,iPPRCalcBase
      ,i_ELE_accrual_method
      ,i_PPR_accrual_method
      ,i_ELE_penalty_percent
      ,i_PPR_penalty_percent
      ,i_ELE_max_percent
      ,i_PPR_max_percent
      ,i_ELE_max_amount
      ,i_PPR_max_amount
      ,i_ELE_min_amount
      ,i_PPR_min_amount
	  ,iELESecAccrualMethod
      ,iPPRSecAccrualMethod
      ,iELESecPenaltyPercent
      ,iPPRSecPenaltyPercent
      ,i_ELE_do_alap
      ,i_PPR_do_alap
      ,i_ELE_alap_days
      ,i_PPR_alap_days
      ,i_ELE_alap_date
      ,i_PPR_alap_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*PenaltyID], '')
      ,ISNULL([*PenaltyIDDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicBaseDate]), 'R')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperBaseDate]), 'R')
      ,ISNULL([*ElectronicPenaltyDays], '0')
      ,ISNULL([*PaperPenaltyDays], '0')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicPenaltyWorkDays]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperPenaltyWorkDays]), 'N')
      ,ISNULL([ElectronicHolidayScheduleID], '')
      ,ISNULL([PaperHolidayScheduleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicCalculationBase]), 'NA')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperCalculationBase]), 'NA')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicAccrualMethod]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperAccrualMethod]), 'A')
      ,ISNULL([ElectronicPenaltyPercent], '0.00')
      ,ISNULL([PaperPenaltyPercent], '0.00')
      ,ISNULL([ElectronicMaxPercent], '0.00')
      ,ISNULL([PaperMaxPercent], '0.00')
      ,ISNULL([ElectronicMaxAmount], '0.00')
      ,ISNULL([PaperMaxAmount], '0.00')
      ,ISNULL([ElectronicMinThreshold], '0.00')
      ,ISNULL([PaperMinThreshold], '0.00')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicSecondaryAccrualMethod]), 'A')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperSecondaryAccrualMethod]), 'A')
      ,ISNULL([ElectronicSecondaryPenaltyPercent], '0.00')
      ,ISNULL([PaperSecondaryPenaltyPercent], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicALAPProcessing]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperALAPProcessing]), 'N')
      ,ISNULL([ElectronicALAPWaitDays], '0')
      ,ISNULL([PaperALAPWaitDays], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ElectronicALAPBaseDate]), 'R')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperALAPBaseDate]), 'R')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Penalty
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Penalty
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Penalty_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_Late_Pay_Penalty_Gid
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
       ,l_modified_date
       ,iUserID
       ,i_Late_Pay_Penalty_id
       ,i_Late_Pay_Penalty_Description
       ,i_ELE_Base_date
       ,i_PPR_Base_date
       ,i_ELE_penalty_days
       ,i_PPR_penalty_days
	   ,iELEWorkdaysOnly			-- SP47
       ,iPPRWorkDaysOnly			-- SP47
       ,iELEHolidayScheduleID		-- SP47
       ,iPPRHolidayScheduleID		-- SP47
       ,iELEHolidayScheduleDesc		-- SP47
       ,iPPRHolidayScheduleDesc		-- SP47
       ,iELECalcBase				-- SP47
       ,iPPRCalcBase				-- SP47
       ,i_ELE_accrual_method
       ,i_PPR_accrual_method
       ,i_ELE_penalty_percent
       ,i_PPR_penalty_percent
       ,i_ELE_max_percent
       ,i_PPR_max_percent
       ,i_ELE_max_amount
       ,i_PPR_max_amount
       ,i_ELE_min_amount
       ,i_PPR_min_amount
	   ,iELESecAccrualMethod		-- SP47		
       ,iPPRSecAccrualMethod		-- SP47
       ,iELESecPenaltyPercent		-- SP47
       ,iPPRSecPenaltyPercent		-- SP47
       ,i_ELE_do_alap
       ,i_PPR_do_alap
       ,i_ELE_alap_days
       ,i_PPR_alap_days
       ,i_ELE_alap_date
       ,i_PPR_alap_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Penalty

   OPEN Penalty_Cursor
  FETCH NEXT FROM Penalty_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_Late_Pay_Penalty_Gid
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
       ,@l_modified_date
       ,@iUserID
       ,@i_Late_Pay_Penalty_id
       ,@i_Late_Pay_Penalty_Description
       ,@i_ELE_Base_date
       ,@i_PPR_Base_date
       ,@i_ELE_penalty_days
       ,@i_PPR_penalty_days
	   ,@iELEWorkdaysOnly			-- SP47
       ,@iPPRWorkDaysOnly			-- SP47
       ,@iELEHolidayScheduleID		-- SP47
       ,@iPPRHolidayScheduleID		-- SP47
       ,@iELEHolidayScheduleDesc	-- SP47
       ,@iPPRHolidayScheduleDesc	-- SP47
       ,@iELECalcBase				-- SP47
       ,@iPPRCalcBase				-- SP47
       ,@i_ELE_accrual_method
       ,@i_PPR_accrual_method
       ,@i_ELE_penalty_percent
       ,@i_PPR_penalty_percent
       ,@i_ELE_max_percent
       ,@i_PPR_max_percent
       ,@i_ELE_max_amount
       ,@i_PPR_max_amount
       ,@i_ELE_min_amount
       ,@i_PPR_min_amount
       ,@iELESecAccrualMethod		-- SP47
       ,@iPPRSecAccrualMethod		-- SP47
       ,@iELESecPenaltyPercent		-- SP47
       ,@iPPRSecPenaltyPercent		-- SP47
       ,@i_ELE_do_alap
       ,@i_PPR_do_alap
       ,@i_ELE_alap_days
       ,@i_PPR_alap_days
       ,@i_ELE_alap_date
       ,@i_PPR_alap_date
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prLate_Pay_Penalty_Add_Modify
             @i_Entity_name
            ,@i_Late_Pay_Penalty_Gid
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
            ,@l_modified_date
            ,@iUserID
            ,@i_Late_Pay_Penalty_id
            ,@i_Late_Pay_Penalty_Description
            ,@i_ELE_Base_date
            ,@i_PPR_Base_date
            ,@i_ELE_penalty_days
            ,@i_PPR_penalty_days
			,@iELEWorkdaysOnly		-- SP47
		    ,@iPPRWorkDaysOnly		-- SP47
		    ,@iELEHolidayScheduleID		-- SP47
		    ,@iPPRHolidayScheduleID		-- SP47
		    ,@iELEHolidayScheduleDesc		-- SP47
		    ,@iPPRHolidayScheduleDesc		-- SP47
		    ,@iELECalcBase		-- SP47
		    ,@iPPRCalcBase		-- SP47
            ,@i_ELE_accrual_method
            ,@i_PPR_accrual_method
            ,@i_ELE_penalty_percent
            ,@i_PPR_penalty_percent
            ,@i_ELE_max_percent
            ,@i_PPR_max_percent
            ,@i_ELE_max_amount
            ,@i_PPR_max_amount
            ,@i_ELE_min_amount
            ,@i_PPR_min_amount
            ,@iELESecAccrualMethod		-- SP47
			,@iPPRSecAccrualMethod		-- SP47
			,@iELESecPenaltyPercent		-- SP47
			,@iPPRSecPenaltyPercent		-- SP47
            ,@i_ELE_do_alap
            ,@i_PPR_do_alap
            ,@i_ELE_alap_days
            ,@i_PPR_alap_days
            ,@i_ELE_alap_date
            ,@i_PPR_alap_date
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

				-- Get the current gid
				SELECT @current_gid				= entity_gid
				  FROM dbo.Entity_Names
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Late_Pay_Penalty'
				   AND entity_user_id			= @i_Late_Pay_Penalty_id

				-- Update to the static gid
				UPDATE dbo.Late_Pay_Penalty 
				   SET late_pay_penalty_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND late_pay_penalty_gid		= @current_gid

				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Late_Pay_Penalty'
				   AND entity_user_id			= @i_Late_Pay_Penalty_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Late_Pay_Penalty_id, @i_Late_Pay_Penalty_Description, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Penalty_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_Late_Pay_Penalty_Gid
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
             ,@l_modified_date
             ,@iUserID
             ,@i_Late_Pay_Penalty_id
             ,@i_Late_Pay_Penalty_Description
             ,@i_ELE_Base_date
             ,@i_PPR_Base_date
             ,@i_ELE_penalty_days
             ,@i_PPR_penalty_days
			 ,@iELEWorkdaysOnly		-- SP47
			 ,@iPPRWorkDaysOnly		-- SP47
			 ,@iELEHolidayScheduleID		-- SP47
			 ,@iPPRHolidayScheduleID		-- SP47
			 ,@iELEHolidayScheduleDesc		-- SP47
			 ,@iPPRHolidayScheduleDesc		-- SP47
			 ,@iELECalcBase		-- SP47
			 ,@iPPRCalcBase		-- SP47
             ,@i_ELE_accrual_method
             ,@i_PPR_accrual_method
             ,@i_ELE_penalty_percent
             ,@i_PPR_penalty_percent
             ,@i_ELE_max_percent
             ,@i_PPR_max_percent
             ,@i_ELE_max_amount
             ,@i_PPR_max_amount
             ,@i_ELE_min_amount
             ,@i_PPR_min_amount
             ,@iELESecAccrualMethod		-- SP47
			 ,@iPPRSecAccrualMethod		-- SP47
			 ,@iELESecPenaltyPercent		-- SP47
			 ,@iPPRSecPenaltyPercent		-- SP47
             ,@i_ELE_do_alap
             ,@i_PPR_do_alap
             ,@i_ELE_alap_days
             ,@i_PPR_alap_days
             ,@i_ELE_alap_date
             ,@i_PPR_alap_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Penalty_Cursor
DEALLOCATE Penalty_Cursor

END
GO