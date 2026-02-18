IF OBJECT_ID('dbo.spDCAuto_CreatePriceStrategyVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePriceStrategyVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePriceStrategyVariation
Purpose:    Create pricestrategyvariation data from CorderAutomation
Method:     PriceStrategyVariation
Screen GID: 200
Procedure:  dbo.prStrategyVarAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePriceStrategyVariation '100-Config%', 22, 'PriceStrategyVariation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePriceStrategyVariation
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
       ,@i_key_2_field            VARCHAR(30)
       ,@i_key_3_field            VARCHAR(30)
       ,@i_key_4_field            VARCHAR(30)
       ,@i_key_5_field            VARCHAR(50)
       ,@i_key_6_field            VARCHAR(20)
       ,@i_key_7_field            VARCHAR(20)
       ,@i_key_8_field            VARCHAR(50)
       ,@i_key_9_field            VARCHAR(30)
       ,@i_key_10_field           VARCHAR(10)
       ,@i_action                 VARCHAR(40)
       ,@i_Date_Time_Modified     VARCHAR(30)
       ,@iUserID                  VARCHAR(50)
       ,@i_Effective_Date         VARCHAR(20)
       ,@i_Termination_Date       VARCHAR(50)
       ,@i_Network_Variation      VARCHAR(20)
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
       ,@iTaxonomyListID          VARCHAR(50)
       ,@iTaxonomyListDesc        VARCHAR(50)
       ,@iScheduleName            VARCHAR(50)
       ,@iScheduleDesc            VARCHAR(50)
       ,@iDomainID                VARCHAR(50)
       ,@iDomainDesc              VARCHAR(100)
       ,@iDomainPriority          VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(100)
	   ,@SearchID				  VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PriceStrategyVariation') IS NOT NULL
	DROP TABLE #PriceStrategyVariation

CREATE TABLE #PriceStrategyVariation
      (i_entity                 VARCHAR(50)       DEFAULT('Price_Strategy_Variation')
      ,i_Entity_Strategy_gid    VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field            VARCHAR(30)       DEFAULT('0')
      ,i_key_3_field            VARCHAR(30)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(30)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field            VARCHAR(20)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(20)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(30)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(10)       DEFAULT('0')
      ,i_action                 VARCHAR(40)       DEFAULT('ADD')
      ,i_Date_Time_Modified     VARCHAR(30)       DEFAULT('')
      ,iUserID                  VARCHAR(50)       DEFAULT('')
      ,i_Effective_Date         VARCHAR(20)
      ,i_Termination_Date       VARCHAR(50)
      ,i_Network_Variation      VARCHAR(20)
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
      ,iTaxonomyListID          VARCHAR(50)
      ,iTaxonomyListDesc        VARCHAR(50)
      ,iScheduleName            VARCHAR(50)
      ,iScheduleDesc            VARCHAR(50)
      ,iDomainID                VARCHAR(50)
      ,iDomainDesc              VARCHAR(100)
      ,iDomainPriority          VARCHAR(50)		DEFAULT('9999')
      ,o_status                 INT
      ,o_message                VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT
	  ,SearchID					VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PriceStrategyVariation
      (SearchID
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
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClassVariation]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CodeVariation]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportingClassVar]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CoverageTimePeriod]), '')
      ,ISNULL([NumberofTimeUnits], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BasisofTime]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ProviderType]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AuthExists]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DispenserType]), '**')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AssignmentVariation]), '*')
      ,ISNULL([ProcessingPriority], '0')
      ,ISNULL([TaxonomyListID], '')
      ,ISNULL([*PriceScheduleID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PriceStrategyVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PriceStrategyVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PriceStrategyVariation_Cursor CURSOR FOR
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
       ,iTaxonomyListDesc
       ,iScheduleName
       ,iScheduleDesc
       ,iDomainID
       ,iDomainDesc
       ,iDomainPriority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PriceStrategyVariation

   OPEN PriceStrategyVariation_Cursor
  FETCH NEXT FROM PriceStrategyVariation_Cursor
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
       ,@iTaxonomyListID
       ,@iTaxonomyListDesc
       ,@iScheduleName
       ,@iScheduleDesc
       ,@iDomainID
       ,@iDomainDesc
       ,@iDomainPriority
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			--Find the Price Startegy GID
			SELECT @i_Entity_Strategy_gid	= entity_gid
			  FROM Entity_Names	
			 WHERE entity_identifier		= 'PRICE_STRATEGY'
			   AND entity_user_id			= @SearchID
			   AND record_status			= 'A'

			EXEC dbo.prStrategyVarAdd
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
            ,@iTaxonomyListID
            ,@iTaxonomyListDesc
            ,@iScheduleName
            ,@iScheduleDesc
            ,@iDomainID
            ,@iDomainDesc
            ,@iDomainPriority
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Effective_Date, @iScheduleName, @status, @err_num, @err_msg

        FETCH NEXT FROM PriceStrategyVariation_Cursor
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
             ,@iTaxonomyListID
             ,@iTaxonomyListDesc
             ,@iScheduleName
             ,@iScheduleDesc
             ,@iDomainID
             ,@iDomainDesc
             ,@iDomainPriority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PriceStrategyVariation_Cursor
DEALLOCATE PriceStrategyVariation_Cursor

END
GO