IF OBJECT_ID('dbo.spDCAuto_CreateTransactionSchedules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTransactionSchedules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTransactionSchedules
Purpose:    Create transaction Schedules from CoreAutomation data

Date        User            Change
---------------------------------------------------------------------------------------------
10/21/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTransactionSchedules '100-Config%', 22, '400-TestCase-302-001','TransactionSchedules','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTransactionSchedules
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

DECLARE	@i_Entity_name 				VARCHAR(50)
       ,@i_Check_Prod_Params_Gid 	VARCHAR(50)
       ,@i_Calendar_Gid 			VARCHAR(50)
       ,@i_Date_Time_Modified 		VARCHAR(50)
       ,@i_User_Id 					VARCHAR(25)
       ,@i_key_5_field 				VARCHAR(50)
       ,@i_key_6_field 				VARCHAR(50)
       ,@i_key_7_field 				VARCHAR(50)
       ,@i_key_8_field 				VARCHAR(50)
       ,@i_key_9_field 				VARCHAR(50)
       ,@i_key_10_field 			VARCHAR(50)
       ,@i_action 					VARCHAR(10)
       ,@l_modified_date 			VARCHAR(50)
       ,@iUserID 					VARCHAR(25)
       ,@i_Check_Prod_Params_Id 	VARCHAR(50)
       ,@i_Check_Prod_Params_Desc	VARCHAR(50)
       ,@i_Process_Type 			VARCHAR(100)
       ,@i_affiliation_id 			VARCHAR(100)
       ,@i_Calendar_Id 				VARCHAR(50)
       ,@i_Calendar_Desc 			VARCHAR(80)
       ,@i_stage_negatives 			VARCHAR(20)
       ,@i_stage_voids 				VARCHAR(20)
       ,@i_Mem_stage_negatives 		VARCHAR(20)
       ,@i_Mem_stage_voids 			VARCHAR(20)
       ,@i_stage_paid_thru 			VARCHAR(20)
       ,@i_on_demand 				VARCHAR(20)
       ,@i_eob_for_duplicate 		VARCHAR(20)
       ,@i_stage_min_check_amt 		VARCHAR(20)
       ,@i_Mbr_Min_Check_Amt 		VARCHAR(20)
       ,@i_Prov_Min_Check_Amt 		VARCHAR(20)
       ,@i_Brok_Min_Check_Amt 		VARCHAR(20)
       ,@i_Max_int_Calc_Days 		VARCHAR(20)
       ,@i_pay_to_address_source 	VARCHAR(150)
	   ,@iAutoRecoupRuleID          VARCHAR(30)			-- SP46
	   ,@iAutoRecoupRuleDesc        VARCHAR(100)		-- SP46
       ,@iHoldTPAFees 				VARCHAR(20)
       ,@iHoldCommission 			VARCHAR(20)
       ,@iReleasePTD 				VARCHAR(50)
       ,@iHoldReceiptDays 			VARCHAR(20)
       ,@iLicenseRequired 			VARCHAR(20)
       ,@iStageMissingLicense 		VARCHAR(20)
       ,@iOverrideAgencyID 			VARCHAR(50)
       ,@iOverrideAgencyName 		VARCHAR(50)
       ,@iOverrideBrokerID 			VARCHAR(50)
       ,@iOverrideBrokerName 		VARCHAR(50)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TransactionSchedules') IS NOT NULL
	DROP TABLE #TransactionSchedules

CREATE TABLE #TransactionSchedules
      (i_Entity_name 			VARCHAR(50)		DEFAULT('Check_Prod_Params')
      ,i_Check_Prod_Params_Gid 	VARCHAR(50)		DEFAULT('0')
      ,i_Calendar_Gid 			VARCHAR(50)		DEFAULT('0')
      ,i_Date_Time_Modified 	VARCHAR(50)		DEFAULT('0')
      ,i_User_Id 				VARCHAR(25)		DEFAULT('0')
      ,i_key_5_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_6_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_7_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_8_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_9_field 			VARCHAR(50)		DEFAULT('0')
      ,i_key_10_field 			VARCHAR(50)		DEFAULT('0')
      ,i_action 				VARCHAR(10)		DEFAULT('ADD')
      ,l_modified_date 			VARCHAR(50)		DEFAULT('')
      ,iUserID 					VARCHAR(25)		DEFAULT('')
      ,i_Check_Prod_Params_Id 	VARCHAR(50)		
      ,i_Check_Prod_Params_Desc VARCHAR(50)		
      ,i_Process_Type 			VARCHAR(100)	
      ,i_affiliation_id 		VARCHAR(100)	
      ,i_Calendar_Id 			VARCHAR(50)		
      ,i_Calendar_Desc 			VARCHAR(20)		
      ,i_stage_negatives 		VARCHAR(20)		
      ,i_stage_voids 			VARCHAR(20)		
      ,i_Mem_stage_negatives 	VARCHAR(20)		
      ,i_Mem_stage_voids 		VARCHAR(20)		
      ,i_stage_paid_thru 		VARCHAR(20)		
      ,i_on_demand 				VARCHAR(20)		
      ,i_eob_for_duplicate 		VARCHAR(20)		
      ,i_stage_min_check_amt 	VARCHAR(20)		
      ,i_Mbr_Min_Check_Amt 		VARCHAR(20)		
      ,i_Prov_Min_Check_Amt 	VARCHAR(20)		
      ,i_Brok_Min_Check_Amt 	VARCHAR(20)		
      ,i_Max_int_Calc_Days 		VARCHAR(150)	
      ,i_pay_to_address_source 	VARCHAR(20)		
	  ,iAutoRecoupRuleID        VARCHAR(30)			-- SP46      
	  ,iAutoRecoupRuleDesc      VARCHAR(100)		-- SP46   
      ,iHoldTPAFees 			VARCHAR(20)		
      ,iHoldCommission 			VARCHAR(50)		
      ,iReleasePTD 				VARCHAR(20)		
      ,iHoldReceiptDays 		VARCHAR(20)		
      ,iLicenseRequired 		VARCHAR(20)		
      ,iStageMissingLicense 	VARCHAR(50)		
      ,iOverrideAgencyID 		VARCHAR(25)		
      ,iOverrideAgencyName 		VARCHAR(50)			
      ,iOverrideBrokerID 		VARCHAR(25)		
      ,iOverrideBrokerName 		VARCHAR(50)			
	  ,record_id				INT
	  ,gid						INT)

--*************************************************************************************************
-- Populate the table with data to be created
--*************************************************************************************************
INSERT INTO #TransactionSchedules
      (i_Check_Prod_Params_Id
      ,i_Check_Prod_Params_Desc
      ,i_Process_Type
      ,i_affiliation_id
      ,i_Calendar_Id
      ,i_stage_negatives
      ,i_stage_voids
      ,i_Mem_stage_negatives
      ,i_Mem_stage_voids
      ,i_stage_paid_thru
      ,i_on_demand
      ,i_eob_for_duplicate
      ,i_stage_min_check_amt
      ,i_Mbr_Min_Check_Amt
      ,i_Prov_Min_Check_Amt
      ,i_Brok_Min_Check_Amt
      ,i_Max_int_Calc_Days
      ,i_pay_to_address_source
	  ,iAutoRecoupRuleID
      ,iHoldTPAFees
      ,iHoldCommission
      ,iReleasePTD
      ,iHoldReceiptDays
      ,iLicenseRequired
      ,iStageMissingLicense
      ,iOverrideAgencyID
      ,iOverrideBrokerID
	  ,record_id
	  ,gid)
SELECT ISNULL([*TransID],'')
      ,ISNULL([*TransDesc],'')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProcessType]),'')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(Affiliation),'******')
      ,ISNULL([*CalendarID],'')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProviderStageNegativeAdj),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProviderStageVoids),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(MemberStageNegativeAdj),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(MemberStageVoids),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ValidatePaidThruDate),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProduceRFFOnDemand),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ProduceDuplicateEOB),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(StageMemProClaimsIfMinChAmtNotMet),'N')
      ,ISNULL([*MemberMinCheckAmt],'0.00')
      ,ISNULL([*BizUnitProMinCheckAmt],'0.00')
      ,ISNULL([*BrokerAgencyMinCheckAmt],'0.00')
      ,ISNULL(MaxDaysPostFutureChecks,'0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(PayToAddressSource),'B')
	  ,ISNULL([AutoRecoupRuleID],'')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(HoldTPAFeesfromCarrierPay),'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(HoldCommissionfromCarrierPay),'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(ReleasepaybasedonPTD),'N')
      ,ISNULL(HoldCashReceiptDays,'0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(LicenseReqPerCarrier),'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue(StageforMissingLicense),'N')
      ,ISNULL(OverrideAgencyID,'')
      ,ISNULL(OverrideBrokerID,'')
	  ,RecordID
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_TransactionSchedules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TransactionSchedules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Transaction_Schedule_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Check_Prod_Params_Gid
       ,i_Calendar_Gid
       ,i_Date_Time_Modified
       ,i_User_Id
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_Check_Prod_Params_Id
       ,i_Check_Prod_Params_Desc
       ,i_Process_Type
       ,i_affiliation_id
       ,i_Calendar_Id
       ,i_Calendar_Desc
       ,i_stage_negatives
       ,i_stage_voids
       ,i_Mem_stage_negatives
       ,i_Mem_stage_voids
       ,i_stage_paid_thru
       ,i_on_demand
       ,i_eob_for_duplicate
       ,i_stage_min_check_amt
       ,i_Mbr_Min_Check_Amt
       ,i_Prov_Min_Check_Amt
       ,i_Brok_Min_Check_Amt
       ,i_Max_int_Calc_Days
       ,i_pay_to_address_source
	   ,iAutoRecoupRuleID				-- SP46      
	   ,iAutoRecoupRuleDesc				-- SP46  
       ,iHoldTPAFees
       ,iHoldCommission
       ,iReleasePTD
       ,iHoldReceiptDays
       ,iLicenseRequired
       ,iStageMissingLicense
       ,iOverrideAgencyID
       ,iOverrideAgencyName
       ,iOverrideBrokerID
       ,iOverrideBrokerName
	   ,record_id
	   ,gid
   FROM #TransactionSchedules


   OPEN Transaction_Schedule_Cursor
  FETCH NEXT FROM Transaction_Schedule_Cursor
   INTO @i_Entity_name
       ,@i_Check_Prod_Params_Gid
       ,@i_Calendar_Gid
       ,@i_Date_Time_Modified
       ,@i_User_Id
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_Check_Prod_Params_Id
       ,@i_Check_Prod_Params_Desc
       ,@i_Process_Type
       ,@i_affiliation_id
       ,@i_Calendar_Id
       ,@i_Calendar_Desc
       ,@i_stage_negatives
       ,@i_stage_voids
       ,@i_Mem_stage_negatives
       ,@i_Mem_stage_voids
       ,@i_stage_paid_thru
       ,@i_on_demand
       ,@i_eob_for_duplicate
       ,@i_stage_min_check_amt
       ,@i_Mbr_Min_Check_Amt
       ,@i_Prov_Min_Check_Amt
       ,@i_Brok_Min_Check_Amt
       ,@i_Max_int_Calc_Days
       ,@i_pay_to_address_source
	   ,@iAutoRecoupRuleID				-- SP46      
	   ,@iAutoRecoupRuleDesc			-- SP46 
       ,@iHoldTPAFees
       ,@iHoldCommission
       ,@iReleasePTD
       ,@iHoldReceiptDays
       ,@iLicenseRequired
       ,@iStageMissingLicense
       ,@iOverrideAgencyID
       ,@iOverrideAgencyName
       ,@iOverrideBrokerID
       ,@iOverrideBrokerName
	   ,@record_id
	   ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC prCheck_Prod_Params_Add_Modify 
			 @i_Entity_name
		    ,@i_Check_Prod_Params_Gid
		    ,@i_Calendar_Gid
		    ,@i_Date_Time_Modified
		    ,@i_User_Id
		    ,@i_key_5_field
		    ,@i_key_6_field
		    ,@i_key_7_field
		    ,@i_key_8_field
		    ,@i_key_9_field
		    ,@i_key_10_field
		    ,@i_action
		    ,@l_modified_date
		    ,@iUserID
		    ,@i_Check_Prod_Params_Id
		    ,@i_Check_Prod_Params_Desc
		    ,@i_Process_Type
		    ,@i_affiliation_id
		    ,@i_Calendar_Id
		    ,@i_Calendar_Desc
		    ,@i_stage_negatives
		    ,@i_stage_voids
		    ,@i_Mem_stage_negatives
		    ,@i_Mem_stage_voids
		    ,@i_stage_paid_thru
		    ,@i_on_demand
		    ,@i_eob_for_duplicate
		    ,@i_stage_min_check_amt
		    ,@i_Mbr_Min_Check_Amt
		    ,@i_Prov_Min_Check_Amt
		    ,@i_Brok_Min_Check_Amt
		    ,@i_Max_int_Calc_Days
		    ,@i_pay_to_address_source
			,@iAutoRecoupRuleID				-- SP46      
	        ,@iAutoRecoupRuleDesc			-- SP46 
		    ,@iHoldTPAFees
		    ,@iHoldCommission
		    ,@iReleasePTD
		    ,@iHoldReceiptDays
		    ,@iLicenseRequired
		    ,@iStageMissingLicense
		    ,@iOverrideAgencyID
		    ,@iOverrideAgencyName
		    ,@iOverrideBrokerID
		    ,@iOverrideBrokerName
			,@o_status				= @err_num	OUTPUT
			,@o_message				= @err_msg	OUTPUT

			-- Update the GIDs
				IF ISNULL(@static_gid, 0) > 0
					BEGIN

						SELECT @current_gid			= ISNULL(entity_gid, 0)
						  FROM dbo.Entity_Names
						 WHERE entity_identifier	= 'Check_Prod_Params'
						   AND entity_user_id		= @i_Check_Prod_Params_Id
						   AND record_status		= 'A'

						UPDATE dbo.Entity_Names 
						   SET entity_gid			= @static_gid 
						 WHERE entity_identifier	= 'Check_Prod_Params'
						   AND entity_user_id		= @i_Check_Prod_Params_Id
						   AND record_status		= 'A'

						UPDATE Check_Prod_Params
						   SET check_prod_params_gid	= @static_gid
						 WHERE check_prod_params_gid	= @current_gid
						   AND record_status			= 'A'

					END
		
		-- Log details
		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Check_Prod_Params_Id, @i_Check_Prod_Params_Desc, '', @status, @err_num, @err_msg

		FETCH NEXT FROM Transaction_Schedule_Cursor
		 INTO @i_Entity_name
		     ,@i_Check_Prod_Params_Gid
		     ,@i_Calendar_Gid
		     ,@i_Date_Time_Modified
		     ,@i_User_Id
		     ,@i_key_5_field
		     ,@i_key_6_field
		     ,@i_key_7_field
		     ,@i_key_8_field
		     ,@i_key_9_field
		     ,@i_key_10_field
		     ,@i_action
		     ,@l_modified_date
		     ,@iUserID
		     ,@i_Check_Prod_Params_Id
		     ,@i_Check_Prod_Params_Desc
		     ,@i_Process_Type
		     ,@i_affiliation_id
		     ,@i_Calendar_Id
		     ,@i_Calendar_Desc
		     ,@i_stage_negatives
		     ,@i_stage_voids
		     ,@i_Mem_stage_negatives
	         ,@i_Mem_stage_voids
		     ,@i_stage_paid_thru
		     ,@i_on_demand
		     ,@i_eob_for_duplicate
		     ,@i_stage_min_check_amt
		     ,@i_Mbr_Min_Check_Amt
		     ,@i_Prov_Min_Check_Amt
		     ,@i_Brok_Min_Check_Amt
		     ,@i_Max_int_Calc_Days
		     ,@i_pay_to_address_source
			 ,@iAutoRecoupRuleID			-- SP46      
			 ,@iAutoRecoupRuleDesc			-- SP46 
		     ,@iHoldTPAFees
		     ,@iHoldCommission
		     ,@iReleasePTD
		     ,@iHoldReceiptDays
		     ,@iLicenseRequired
		     ,@iStageMissingLicense
		     ,@iOverrideAgencyID
		     ,@iOverrideAgencyName
		     ,@iOverrideBrokerID
		     ,@iOverrideBrokerName
		     ,@record_id
 			 ,@static_gid

	END

CLOSE Transaction_Schedule_Cursor
DEALLOCATE Transaction_Schedule_Cursor

END
GO