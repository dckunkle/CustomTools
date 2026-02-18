IF OBJECT_ID('dbo.spDCAuto_CreateBenefitStrategyVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBenefitStrategyVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBenefitStrategyVariation
Purpose:    Create benefitstrategyvariation data from CorderAutomation
Method:     BenefitStrategyVariation
Screen GID: 139
Procedure:  dbo.prBenefitStrategyVarAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
09/02/2021	DK				Accommodate additional fields added for SP47
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBenefitStrategyVariation '100-Config%', 22, 'BenefitStrategyVariation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBenefitStrategyVariation
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

DECLARE @i_entity                VARCHAR(20)
       ,@i_Entity_Strategy_gid   VARCHAR(20)
       ,@i_key_2_field           VARCHAR(150)
       ,@i_key_3_field           VARCHAR(150)
       ,@i_key_4_field           VARCHAR(100)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(100)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(100)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(100)
       ,@i_action                VARCHAR(10)
       ,@i_Date_Time_Modified    VARCHAR(100)
       ,@iUserID                 VARCHAR(50)
	   ,@i_Strategy_ID           VARCHAR(100)	--SP47
       ,@i_Strategy_Desc         VARCHAR(50)	--SP47
       ,@i_Effective_Date        VARCHAR(150)
       ,@i_Termination_Date      VARCHAR(150)
       ,@i_Network_Variation     VARCHAR(50)
       ,@i_Class_Variation       VARCHAR(50)
       ,@i_Benefit_Rule_ID       VARCHAR(100)
       ,@i_Benefit_Rule_Desc     VARCHAR(50)
       ,@i_Network_Grouping_ID   VARCHAR(100)
       ,@i_Network_Grouping_Desc VARCHAR(50)
       ,@i_Class_Grouping_ID     VARCHAR(100)
       ,@i_Class_Grouping_Desc   VARCHAR(50)
       ,@i_Code_List_ID          VARCHAR(20)
       ,@i_Code_List_Desc        VARCHAR(50)
       ,@i_Time_Period           VARCHAR(50)
       ,@i_Time_Units            VARCHAR(50)
       ,@i_Time_Basis            VARCHAR(50)
       ,@i_Rpt_Class_Variation   VARCHAR(50)
       ,@i_PlanStratDisplay      VARCHAR(20)
       ,@iPerTooth               VARCHAR(50)
       ,@iDiagID                 VARCHAR(100)
       ,@iDiagDesc               VARCHAR(200)
       ,@iPOSListID              VARCHAR(100)
       ,@iPOSListDesc            VARCHAR(200)
       ,@iTOBListID              VARCHAR(100)
       ,@iTOBListDesc            VARCHAR(200)
       ,@iAccidentBenefit        VARCHAR(50)
       ,@i_domain_rule_id        VARCHAR(50)
       ,@i_domain_rule_desc      VARCHAR(100)
       ,@i_domain_rule_priority  VARCHAR(50)
       ,@i_single_member_accum   VARCHAR(50)
       ,@oStatus                 INT
       ,@oMessage                VARCHAR(100)
	   ,@SearchID				 VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BenefitStrategyVariation') IS NOT NULL
	DROP TABLE #BenefitStrategyVariation

CREATE TABLE #BenefitStrategyVariation
      (i_entity                VARCHAR(20)       DEFAULT('Benefit_Strategy')
      ,i_Entity_Strategy_gid   VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field           VARCHAR(150)      DEFAULT('0')
      ,i_key_3_field           VARCHAR(150)      DEFAULT('0')
      ,i_key_4_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(100)      DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified    VARCHAR(100)      DEFAULT('')
      ,iUserID                 VARCHAR(50)       DEFAULT('')
	  ,i_Strategy_ID           VARCHAR(100)	--SP47
      ,i_Strategy_Desc         VARCHAR(50)	--SP47
      ,i_Effective_Date        VARCHAR(150)
      ,i_Termination_Date      VARCHAR(150)
      ,i_Network_Variation     VARCHAR(50)
      ,i_Class_Variation       VARCHAR(50)
      ,i_Benefit_Rule_ID       VARCHAR(100)
      ,i_Benefit_Rule_Desc     VARCHAR(50)
      ,i_Network_Grouping_ID   VARCHAR(100)
      ,i_Network_Grouping_Desc VARCHAR(50)
      ,i_Class_Grouping_ID     VARCHAR(100)
      ,i_Class_Grouping_Desc   VARCHAR(50)
      ,i_Code_List_ID          VARCHAR(20)
      ,i_Code_List_Desc        VARCHAR(50)
      ,i_Time_Period           VARCHAR(50)
      ,i_Time_Units            VARCHAR(50)
      ,i_Time_Basis            VARCHAR(50)
      ,i_Rpt_Class_Variation   VARCHAR(50)
      ,i_PlanStratDisplay      VARCHAR(20)
      ,iPerTooth               VARCHAR(50)
      ,iDiagID                 VARCHAR(100)
      ,iDiagDesc               VARCHAR(200)
      ,iPOSListID              VARCHAR(100)
      ,iPOSListDesc            VARCHAR(200)
      ,iTOBListID              VARCHAR(100)
      ,iTOBListDesc            VARCHAR(200)
      ,iAccidentBenefit        VARCHAR(50)
      ,i_domain_rule_id        VARCHAR(50)
      ,i_domain_rule_desc      VARCHAR(100)
      ,i_domain_rule_priority  VARCHAR(50)
      ,i_single_member_accum   VARCHAR(50)
      ,oStatus                 INT
      ,oMessage                VARCHAR(100)
      ,record_id               INT
      ,static_gid              INT
	  ,SearchID				   VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BenefitStrategyVariation
      (SearchID
	  ,i_Effective_Date
      ,i_Termination_Date
      ,i_Network_Variation
      ,i_Class_Variation
      ,i_Benefit_Rule_ID
      ,i_Network_Grouping_ID
      ,i_Class_Grouping_ID
      ,i_Code_List_ID
      ,i_Time_Period
      ,i_Time_Units
      ,i_Time_Basis
      ,i_Rpt_Class_Variation
      ,i_PlanStratDisplay
      ,iPerTooth
      ,iDiagID
      ,iPOSListID
      ,iTOBListID
      ,iAccidentBenefit
      ,i_single_member_accum
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], 'TODAY')
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenefitClassVariation]), '0')
      ,ISNULL([*BenefitRuleID], '')
      ,ISNULL([NetworkGroupingID], '')
      ,ISNULL([ClassGroupingID], '')
      ,ISNULL([CodeListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UptoCoverageUnits]), '')
      ,ISNULL([NumberofCoverageUnits], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BasisofCoverage]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportingClassVar]), '******')
      ,ISNULL([UsedinPlanSummBeneDisp], 'Y')
      ,ISNULL([PerToothBenefitStrat], 'N')
      ,ISNULL([DiagnosisValidationID], '')
      ,ISNULL([POSListID], '')
      ,ISNULL([TOBListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AccidentBenefit]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SingleMemberVariation]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BenefitStrategyVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BenefitStrategyVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BenefitStrategyVariation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity
       ,i_Entity_Strategy_gid
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
	   ,i_Strategy_ID	--SP47
       ,i_Strategy_Desc	--SP47
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Network_Variation
       ,i_Class_Variation
       ,i_Benefit_Rule_ID
       ,i_Benefit_Rule_Desc
       ,i_Network_Grouping_ID
       ,i_Network_Grouping_Desc
       ,i_Class_Grouping_ID
       ,i_Class_Grouping_Desc
       ,i_Code_List_ID
       ,i_Code_List_Desc
       ,i_Time_Period
       ,i_Time_Units
       ,i_Time_Basis
       ,i_Rpt_Class_Variation
       ,i_PlanStratDisplay
       ,iPerTooth
       ,iDiagID
       ,iDiagDesc
       ,iPOSListID
       ,iPOSListDesc
       ,iTOBListID
       ,iTOBListDesc
       ,iAccidentBenefit
       ,i_domain_rule_id
       ,i_domain_rule_desc
       ,i_domain_rule_priority
       ,i_single_member_accum
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #BenefitStrategyVariation

   OPEN BenefitStrategyVariation_Cursor
  FETCH NEXT FROM BenefitStrategyVariation_Cursor
   INTO @SearchID
       ,@i_entity
       ,@i_Entity_Strategy_gid
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
	   ,@i_Strategy_ID		--SP47
       ,@i_Strategy_Desc	--SP47
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Network_Variation
       ,@i_Class_Variation
       ,@i_Benefit_Rule_ID
       ,@i_Benefit_Rule_Desc
       ,@i_Network_Grouping_ID
       ,@i_Network_Grouping_Desc
       ,@i_Class_Grouping_ID
       ,@i_Class_Grouping_Desc
       ,@i_Code_List_ID
       ,@i_Code_List_Desc
       ,@i_Time_Period
       ,@i_Time_Units
       ,@i_Time_Basis
       ,@i_Rpt_Class_Variation
       ,@i_PlanStratDisplay
       ,@iPerTooth
       ,@iDiagID
       ,@iDiagDesc
       ,@iPOSListID
       ,@iPOSListDesc
       ,@iTOBListID
       ,@iTOBListDesc
       ,@iAccidentBenefit
       ,@i_domain_rule_id
       ,@i_domain_rule_desc
       ,@i_domain_rule_priority
       ,@i_single_member_accum
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get gid of the Benefit Strategy
			SELECT @i_Entity_Strategy_gid	= entity_gid
			  FROM Entity_Names
			 WHERE entity_identifier		= 'BENEFIT_STRATEGY' 
			   AND entity_user_id			= @SearchID

			EXEC dbo.prBenefitStrategyVarAdd
             @i_entity
            ,@i_Entity_Strategy_gid
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
			,@i_Strategy_ID		--SP47
            ,@i_Strategy_Desc	--SP47
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Network_Variation
            ,@i_Class_Variation
            ,@i_Benefit_Rule_ID
            ,@i_Benefit_Rule_Desc
            ,@i_Network_Grouping_ID
            ,@i_Network_Grouping_Desc
            ,@i_Class_Grouping_ID
            ,@i_Class_Grouping_Desc
            ,@i_Code_List_ID
            ,@i_Code_List_Desc
            ,@i_Time_Period
            ,@i_Time_Units
            ,@i_Time_Basis
            ,@i_Rpt_Class_Variation
            ,@i_PlanStratDisplay
            ,@iPerTooth
            ,@iDiagID
            ,@iDiagDesc
            ,@iPOSListID
            ,@iPOSListDesc
            ,@iTOBListID
            ,@iTOBListDesc
            ,@iAccidentBenefit
            ,@i_domain_rule_id
            ,@i_domain_rule_desc
            ,@i_domain_rule_priority
            ,@i_single_member_accum
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Network_Variation, @i_Benefit_Rule_ID, @status, @err_num, @err_msg

        FETCH NEXT FROM BenefitStrategyVariation_Cursor
         INTO @SearchID
		     ,@i_entity
             ,@i_Entity_Strategy_gid
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
			 ,@i_Strategy_ID		--SP47
             ,@i_Strategy_Desc		--SP47
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Network_Variation
             ,@i_Class_Variation
             ,@i_Benefit_Rule_ID
             ,@i_Benefit_Rule_Desc
             ,@i_Network_Grouping_ID
             ,@i_Network_Grouping_Desc
             ,@i_Class_Grouping_ID
             ,@i_Class_Grouping_Desc
             ,@i_Code_List_ID
             ,@i_Code_List_Desc
             ,@i_Time_Period
             ,@i_Time_Units
             ,@i_Time_Basis
             ,@i_Rpt_Class_Variation
             ,@i_PlanStratDisplay
             ,@iPerTooth
             ,@iDiagID
             ,@iDiagDesc
             ,@iPOSListID
             ,@iPOSListDesc
             ,@iTOBListID
             ,@iTOBListDesc
             ,@iAccidentBenefit
             ,@i_domain_rule_id
             ,@i_domain_rule_desc
             ,@i_domain_rule_priority
             ,@i_single_member_accum
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE BenefitStrategyVariation_Cursor
DEALLOCATE BenefitStrategyVariation_Cursor

END
GO