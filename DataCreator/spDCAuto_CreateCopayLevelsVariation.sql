IF OBJECT_ID('dbo.spDCAuto_CreateCopayLevelsVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCopayLevelsVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCopayLevelsVariation
Purpose:    Create copaylevelsvariation data from CorderAutomation
Method:     CopayLevelsVariation
Screen GID: 54
Procedure:  dbo.prCopayStrategyVarAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
08/13/2021	DK				Support new fields for SP47
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCopayLevelsVariation '600-CONFIG%', 22, '600-Configuration','CopayLevelsVariation','dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCopayLevelsVariation
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

DECLARE @i_entity                 VARCHAR(50)
       ,@i_Entity_Strategy_gid    VARCHAR(20)
       ,@i_key_2_field            VARCHAR(50)
       ,@i_key_3_field            VARCHAR(50)
       ,@i_key_4_field            VARCHAR(50)
       ,@i_key_5_field            VARCHAR(100)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(50)
       ,@i_key_8_field            VARCHAR(100)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(10)
       ,@i_action                 VARCHAR(50)
       ,@i_Date_Time_Modified     VARCHAR(200)
       ,@iUserID                  VARCHAR(50)
	   ,@i_Copay_level_id		  VARCHAR(25)	= '' -- SP47
	   ,@i_Copay_level_desc		  VARCHAR(100)	= '' -- SP47
       ,@i_Effective_Date         VARCHAR(50)
       ,@i_Termination_Date       VARCHAR(50)
       ,@i_Network_Variation      VARCHAR(50)
       ,@i_Class_Variation        VARCHAR(50)
       ,@i_Product_Variation      VARCHAR(50)
       ,@i_Report_Class_Variation VARCHAR(50)
       ,@i_Time_Period            VARCHAR(50)
       ,@i_Time_Units             VARCHAR(50)
       ,@i_Time_Basis             VARCHAR(50)
       ,@i_Provider_Variation     VARCHAR(50)
       ,@i_Auth_Exists            VARCHAR(50)
       ,@i_Disp_Type              VARCHAR(50)
       ,@iAssignVariation         VARCHAR(50)
       ,@iPriority                VARCHAR(50)
       ,@i_domain_rule_id         VARCHAR(50)
       ,@i_domain_rule_desc       VARCHAR(100)
       ,@i_domain_rule_priority   VARCHAR(50)
       ,@iTaxonomyListID          VARCHAR(50)
       ,@iTaxonomyListDesc        VARCHAR(50)
       ,@iScheduleName            VARCHAR(50)
       ,@iScheduleDesc            VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(100)
	   ,@CopayLevelID			  VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CopayLevelsVariation') IS NOT NULL
	DROP TABLE #CopayLevelsVariation

CREATE TABLE #CopayLevelsVariation
      (i_entity                 VARCHAR(50)       DEFAULT('Copay_Strategy_Variation')
      ,i_Entity_Strategy_gid    VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(10)       DEFAULT('0')
      ,i_action                 VARCHAR(50)       DEFAULT('ADD')
      ,i_Date_Time_Modified     VARCHAR(200)      DEFAULT('')
      ,iUserID                  VARCHAR(50)       DEFAULT('')
      ,i_Effective_Date         VARCHAR(50)
      ,i_Termination_Date       VARCHAR(50)
      ,i_Network_Variation      VARCHAR(50)
      ,i_Class_Variation        VARCHAR(50)
      ,i_Product_Variation      VARCHAR(50)
      ,i_Report_Class_Variation VARCHAR(50)
      ,i_Time_Period            VARCHAR(50)
      ,i_Time_Units             VARCHAR(50)
      ,i_Time_Basis             VARCHAR(50)
      ,i_Provider_Variation     VARCHAR(50)
      ,i_Auth_Exists            VARCHAR(50)
      ,i_Disp_Type              VARCHAR(50)
      ,iAssignVariation         VARCHAR(50)
      ,iPriority                VARCHAR(50)
      ,i_domain_rule_id         VARCHAR(50)
      ,i_domain_rule_desc       VARCHAR(100)
      ,i_domain_rule_priority   VARCHAR(50)
      ,iTaxonomyListID          VARCHAR(50)
      ,iTaxonomyListDesc        VARCHAR(50)
      ,iScheduleName            VARCHAR(50)
      ,iScheduleDesc            VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT
	  ,CopayLevelID				VARCHAR(100))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CopayLevelsVariation
      (CopayLevelID
	  ,i_Effective_Date
      ,i_Termination_Date
      ,i_Network_Variation
      ,i_Class_Variation
      ,i_Product_Variation
      ,i_Report_Class_Variation
      ,i_Time_Period
      ,i_Time_Units
      ,i_Time_Basis
      ,i_Provider_Variation
      ,i_Auth_Exists
      ,i_Disp_Type
      ,iAssignVariation
      ,iPriority
      ,iTaxonomyListID
      ,iScheduleName
      ,record_id
      ,static_gid)
SELECT ISNULL([*CopayLevelsID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClassVariation]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CodeVariation]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportingClassVar]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UpToCoverageUnits]), '')
      ,ISNULL([NumberOfCoverageUnits], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BasisOfCoverage]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ProviderType]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AuthExists]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DispenserType]), '**')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AssignmentVariations]), '*')
      ,ISNULL([ProcessingPriority], '0')
      ,ISNULL([TaxonomyListID], '')
      ,ISNULL([*CopayScheduleID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CopayLevelsVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CopayLevelsVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CopayLevelsVariation_Cursor CURSOR FOR
 SELECT i_entity
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
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Network_Variation
       ,i_Class_Variation
       ,i_Product_Variation
       ,i_Report_Class_Variation
       ,i_Time_Period
       ,i_Time_Units
       ,i_Time_Basis
       ,i_Provider_Variation
       ,i_Auth_Exists
       ,i_Disp_Type
       ,iAssignVariation
       ,iPriority
       ,i_domain_rule_id
       ,i_domain_rule_desc
       ,i_domain_rule_priority
       ,iTaxonomyListID
       ,iTaxonomyListDesc
       ,iScheduleName
       ,iScheduleDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
	   ,CopayLevelID
   FROM #CopayLevelsVariation

   OPEN CopayLevelsVariation_Cursor
  FETCH NEXT FROM CopayLevelsVariation_Cursor
   INTO @i_entity
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
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Network_Variation
       ,@i_Class_Variation
       ,@i_Product_Variation
       ,@i_Report_Class_Variation
       ,@i_Time_Period
       ,@i_Time_Units
       ,@i_Time_Basis
       ,@i_Provider_Variation
       ,@i_Auth_Exists
       ,@i_Disp_Type
       ,@iAssignVariation
       ,@iPriority
       ,@i_domain_rule_id
       ,@i_domain_rule_desc
       ,@i_domain_rule_priority
       ,@iTaxonomyListID
       ,@iTaxonomyListDesc
       ,@iScheduleName
       ,@iScheduleDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid
	   ,@CopayLevelID

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Lookup the Copay Levels gid
		SELECT @i_Entity_Strategy_gid	= entity_gid
		  FROM Entity_Names
		 WHERE entity_identifier		= 'COPAY_STRATEGY'
		   AND entity_user_id			= @CopayLevelID

		EXEC dbo.prCopayStrategyVarAdd
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
			,@i_Copay_level_id			-- SP47
			,@i_Copay_level_desc		-- SP47
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Network_Variation
            ,@i_Class_Variation
            ,@i_Product_Variation
            ,@i_Report_Class_Variation
            ,@i_Time_Period
            ,@i_Time_Units
            ,@i_Time_Basis
            ,@i_Provider_Variation
            ,@i_Auth_Exists
            ,@i_Disp_Type
            ,@iAssignVariation
            ,@iPriority
            ,@i_domain_rule_id
            ,@i_domain_rule_desc
            ,@i_domain_rule_priority
            ,@iTaxonomyListID
            ,@iTaxonomyListDesc
            ,@iScheduleName
            ,@iScheduleDesc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @CopayLevelID, @i_Effective_Date, @i_Termination_Date, @status, @err_num, @err_msg

        FETCH NEXT FROM CopayLevelsVariation_Cursor
         INTO @i_entity
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
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Network_Variation
             ,@i_Class_Variation
             ,@i_Product_Variation
             ,@i_Report_Class_Variation
             ,@i_Time_Period
             ,@i_Time_Units
             ,@i_Time_Basis
             ,@i_Provider_Variation
             ,@i_Auth_Exists
             ,@i_Disp_Type
             ,@iAssignVariation
             ,@iPriority
             ,@i_domain_rule_id
             ,@i_domain_rule_desc
             ,@i_domain_rule_priority
             ,@iTaxonomyListID
             ,@iTaxonomyListDesc
             ,@iScheduleName
             ,@iScheduleDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
			 ,@CopayLevelID
	END

CLOSE CopayLevelsVariation_Cursor
DEALLOCATE CopayLevelsVariation_Cursor

END
GO