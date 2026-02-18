IF OBJECT_ID('dbo.spDCAuto_CreateGroupRateAssignment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupRateAssignment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupRateAssignment
Purpose:    Create grouprateassignment data from CorderAutomation
Method:     GroupRateAssignment
Screen GID: 71
Procedure:  dbo.prBARGroup_Rate_Assoc_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
12/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupRateAssignment '100-Config%', 22, 'GroupRateAssignment'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupRateAssignment
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

DECLARE @i_entity_name        VARCHAR(100)
       ,@i_entity_type        VARCHAR(50)
       ,@i_entity_gid         VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(30)
       ,@i_lob                VARCHAR(50)
       ,@i_Plan_Strategy_gid  VARCHAR(20)
       ,@i_Rate_Table_gid     VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_old_smoking_ind    VARCHAR(100)
       ,@iSID                 VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@l_modified_date      VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@l_entity_id          VARCHAR(50)
       ,@l_entity_name        VARCHAR(50)
       ,@l_effective_date     VARCHAR(50)
       ,@l_termination_date   VARCHAR(20)
       ,@l_renewal_time_span  VARCHAR(50)
       ,@l_renewal_span_value INT
       ,@l_renewal_date       VARCHAR(50)
       ,@l_lob                VARCHAR(50)
       ,@l_calc_type          VARCHAR(30)
       ,@l_plan_strategy_id   VARCHAR(50)
       ,@l_plan_strategy_name VARCHAR(50)
       ,@iRegionDefID         VARCHAR(50)
       ,@iRegionDefDesc       VARCHAR(50)
       ,@iVolumeStartRange    VARCHAR(50)
       ,@iVolumeEndRange      VARCHAR(50)
       ,@iTimeBasis           VARCHAR(50)
       ,@i_smoking_ind        VARCHAR(50)
       ,@l_rate_id            VARCHAR(55)
       ,@l_rate_description   VARCHAR(55)
       ,@l_surcharge_id       VARCHAR(50)
       ,@l_surcharge_desc     VARCHAR(50)
       ,@l_surcharge_type     VARCHAR(50)
       ,@l_rates_emp_dob      VARCHAR(50)
       ,@i_NPP_param_id       VARCHAR(50)
       ,@i_NPP_param_desc     VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupRateAssignment') IS NOT NULL
	DROP TABLE #GroupRateAssignment

CREATE TABLE #GroupRateAssignment
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Group_Rate_Association')
      ,i_entity_type        VARCHAR(50)       DEFAULT('0')
      ,i_entity_gid         VARCHAR(50)       DEFAULT('0')
      ,i_effective_date     VARCHAR(50)       DEFAULT('0')
      ,i_termination_date   VARCHAR(30)       DEFAULT('0')
      ,i_lob                VARCHAR(50)       DEFAULT('0')
      ,i_Plan_Strategy_gid  VARCHAR(20)       DEFAULT('0')
      ,i_Rate_Table_gid     VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_old_smoking_ind    VARCHAR(100)      DEFAULT('0')
      ,iSID                 VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date      VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,l_entity_id          VARCHAR(50)
      ,l_entity_name        VARCHAR(50)
      ,l_effective_date     VARCHAR(50)
      ,l_termination_date   VARCHAR(20)
      ,l_renewal_time_span  VARCHAR(50)
      ,l_renewal_span_value INT
      ,l_renewal_date       VARCHAR(50)
      ,l_lob                VARCHAR(50)
      ,l_calc_type          VARCHAR(30)
      ,l_plan_strategy_id   VARCHAR(50)
      ,l_plan_strategy_name VARCHAR(50)
      ,iRegionDefID         VARCHAR(50)
      ,iRegionDefDesc       VARCHAR(50)
      ,iVolumeStartRange    VARCHAR(50)
      ,iVolumeEndRange      VARCHAR(50)
      ,iTimeBasis           VARCHAR(50)
      ,i_smoking_ind        VARCHAR(50)
      ,l_rate_id            VARCHAR(55)
      ,l_rate_description   VARCHAR(55)
      ,l_surcharge_id       VARCHAR(50)
      ,l_surcharge_desc     VARCHAR(50)
      ,l_surcharge_type     VARCHAR(50)
      ,l_rates_emp_dob      VARCHAR(50)
      ,i_NPP_param_id       VARCHAR(50)
      ,i_NPP_param_desc     VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#GroupLOBs') IS NOT NULL
	DROP TABLE #GroupLOBs

CREATE TABLE #GroupLOBs
      (field_number			INT
	  ,reference_type		VARCHAR(200)
	  ,short_description	VARCHAR(200)
	  ,description			VARCHAR(200)
	  ,sequence_num			INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupRateAssignment
      (SearchID
      ,l_entity_id
      ,l_effective_date
      ,l_termination_date
      ,l_renewal_time_span
      ,l_renewal_span_value
      ,l_renewal_date
      ,l_lob
      ,l_calc_type
      ,l_plan_strategy_id
      ,iRegionDefID
      ,iVolumeStartRange
      ,iVolumeEndRange
      ,iTimeBasis
      ,i_smoking_ind
      ,l_rate_id
      ,l_surcharge_id
      ,l_surcharge_type
      ,l_rates_emp_dob
      ,i_NPP_param_id
      ,record_id
      ,static_gid)
SELECT ISNULL([*GroupID], '')
      ,ISNULL([*GroupID], '')
      ,ISNULL([*EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*RenewalTimeBasis]), 'Y')
      ,ISNULL([*TimeSpanValue], '1')
      ,ISNULL([*RenewalDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOB]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CalculationType]), '1')
      ,ISNULL([PlanStrategyID], '')
      ,ISNULL([RegionDefID], '')
      ,ISNULL([*VolumeStartRange], '0')
      ,ISNULL([*VolumeEndRange], '9999999999')
      ,ISNULL([*UpToYrsOfCov], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SmokingIndicator]), 'U')
      ,ISNULL([*RateTableID], '')
      ,ISNULL([SurchargeAssocID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SurchargeCalcType]), 'B')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RatesByEmpDOB]), 'N')
      ,ISNULL([NonPayParamDefID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupRateAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupRateAssignment
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupRateAssignment_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_entity_type
       ,i_entity_gid
       ,i_effective_date
       ,i_termination_date
       ,i_lob
       ,i_Plan_Strategy_gid
       ,i_Rate_Table_gid
       ,i_key_8_field
       ,i_old_smoking_ind
       ,iSID
       ,i_action
       ,l_modified_date
       ,iUserID
       ,l_entity_id
       ,l_entity_name
       ,l_effective_date
       ,l_termination_date
       ,l_renewal_time_span
       ,l_renewal_span_value
       ,l_renewal_date
       ,l_lob
       ,l_calc_type
       ,l_plan_strategy_id
       ,l_plan_strategy_name
       ,iRegionDefID
       ,iRegionDefDesc
       ,iVolumeStartRange
       ,iVolumeEndRange
       ,iTimeBasis
       ,i_smoking_ind
       ,l_rate_id
       ,l_rate_description
       ,l_surcharge_id
       ,l_surcharge_desc
       ,l_surcharge_type
       ,l_rates_emp_dob
       ,i_NPP_param_id
       ,i_NPP_param_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupRateAssignment

   OPEN GroupRateAssignment_Cursor
  FETCH NEXT FROM GroupRateAssignment_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_entity_type
       ,@i_entity_gid
       ,@i_effective_date
       ,@i_termination_date
       ,@i_lob
       ,@i_Plan_Strategy_gid
       ,@i_Rate_Table_gid
       ,@i_key_8_field
       ,@i_old_smoking_ind
       ,@iSID
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@l_entity_id
       ,@l_entity_name
       ,@l_effective_date
       ,@l_termination_date
       ,@l_renewal_time_span
       ,@l_renewal_span_value
       ,@l_renewal_date
       ,@l_lob
       ,@l_calc_type
       ,@l_plan_strategy_id
       ,@l_plan_strategy_name
       ,@iRegionDefID
       ,@iRegionDefDesc
       ,@iVolumeStartRange
       ,@iVolumeEndRange
       ,@iTimeBasis
       ,@i_smoking_ind
       ,@l_rate_id
       ,@l_rate_description
       ,@l_surcharge_id
       ,@l_surcharge_desc
       ,@l_surcharge_type
       ,@l_rates_emp_dob
       ,@i_NPP_param_id
       ,@i_NPP_param_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the GID for the group
			SELECT @i_entity_gid		= G.group_gid
			  FROM Groups				G
			 WHERE G.group_id			= @SearchID
			   AND G.record_status		= 'A'

			-- Determine if the user specified an LOB and if not default it to the correct LOB
			TRUNCATE TABLE #GroupLOBs
			INSERT INTO #GroupLOBs
			EXEC prGroupVaryLOBCombo 'Group_Rate_Association', 'G', @i_entity_gid, '', '', '', '0', '0', '0', '0', '', 'ADD', '', '', 'LOB', '9', @l_entity_id

			SELECT TOP 1
			       @l_lob = CASE WHEN @l_lob = '' THEN G.short_description ELSE @l_lob END
			  FROM #GroupLOBs	G
			 

			EXEC dbo.prBARGroup_Rate_Assoc_Add_Modify
				 @i_entity_name
				,@i_entity_type
				,@i_entity_gid
				,@i_effective_date
				,@i_termination_date
				,@i_lob
				,@i_Plan_Strategy_gid
				,@i_Rate_Table_gid
				,@i_key_8_field
				,@i_old_smoking_ind
				,@iSID
				,@i_action
				,@l_modified_date
				,@iUserID
				,@l_entity_id
				,@l_entity_name
				,@l_effective_date
				,@l_termination_date
				,@l_renewal_time_span
				,@l_renewal_span_value
				,@l_renewal_date
				,@l_lob
				,@l_calc_type
				,@l_plan_strategy_id
				,@l_plan_strategy_name
				,@iRegionDefID
				,@iRegionDefDesc
				,@iVolumeStartRange
				,@iVolumeEndRange
				,@iTimeBasis
				,@i_smoking_ind
				,@l_rate_id
				,@l_rate_description
				,@l_surcharge_id
				,@l_surcharge_desc
				,@l_surcharge_type
				,@l_rates_emp_dob
				,@i_NPP_param_id
				,@i_NPP_param_desc
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @l_rate_id, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupRateAssignment_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_entity_type
             ,@i_entity_gid
             ,@i_effective_date
             ,@i_termination_date
             ,@i_lob
             ,@i_Plan_Strategy_gid
             ,@i_Rate_Table_gid
             ,@i_key_8_field
             ,@i_old_smoking_ind
             ,@iSID
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@l_entity_id
             ,@l_entity_name
             ,@l_effective_date
             ,@l_termination_date
             ,@l_renewal_time_span
             ,@l_renewal_span_value
             ,@l_renewal_date
             ,@l_lob
             ,@l_calc_type
             ,@l_plan_strategy_id
             ,@l_plan_strategy_name
             ,@iRegionDefID
             ,@iRegionDefDesc
             ,@iVolumeStartRange
             ,@iVolumeEndRange
             ,@iTimeBasis
             ,@i_smoking_ind
             ,@l_rate_id
             ,@l_rate_description
             ,@l_surcharge_id
             ,@l_surcharge_desc
             ,@l_surcharge_type
             ,@l_rates_emp_dob
             ,@i_NPP_param_id
             ,@i_NPP_param_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupRateAssignment_Cursor
DEALLOCATE GroupRateAssignment_Cursor

END
GO