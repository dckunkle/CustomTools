IF OBJECT_ID('dbo.spDCAuto_CreateSuperNetworksServiceArea') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateSuperNetworksServiceArea AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateSuperNetworksServiceArea
Purpose:    Create supernetworksservicearea data from CorderAutomation
Method:     SuperNetworksServiceArea
Screen GID: 113
Procedure:  dbo.prNet_ProvOrAttrNameToSup_AddMod

Date        User            Change
---------------------------------------------------------------------------------------------
11/15/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateSuperNetworksServiceArea '100-Config%', 22, 'SuperNetworksServiceArea'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateSuperNetworksServiceArea
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

DECLARE @i_entity_name                         VARCHAR(50)
       ,@i_Network_Search_gid                  VARCHAR(50)
       ,@i_Network_gid                         VARCHAR(20)
       ,@i_Old_Network_ID                      VARCHAR(20)
       ,@i_Old_Network_Name                    VARCHAR(50)
       ,@i_Old_effective_date                  VARCHAR(50)
       ,@i_Old_termination_date                VARCHAR(50)
       ,@i_Old_price_strategy_gid              VARCHAR(50)
       ,@i_Old_copay_strategy_gid              VARCHAR(50)
       ,@i_Old_Network_SID                     VARCHAR(50)
       ,@i_key_10_field                        VARCHAR(50)
       ,@i_action                              VARCHAR(10)
       ,@i_date_time_modified                  VARCHAR(50)
       ,@iUserID                               VARCHAR(25)
       ,@i_Network_Id                          VARCHAR(50)
       ,@i_Network_Desc                        VARCHAR(50)
       ,@i_effective_date                      VARCHAR(50)
       ,@i_termination_date                    VARCHAR(50)
       ,@i_Network_Priority                    VARCHAR(50)
       ,@i_Coverage_Denied                     VARCHAR(50)
       ,@i_Price_Strategy_Id                   VARCHAR(50)
       ,@i_Price_Strategy_Desc                 VARCHAR(50)
       ,@i_Copay_Strategy_Id                   VARCHAR(50)
       ,@i_Copay_Strategy_Desc                 VARCHAR(50)
       ,@i_Coverage_Strategy_Id                VARCHAR(50)
       ,@i_Coverage_Strategy_Desc              VARCHAR(50)
       ,@iCodePairingID                        VARCHAR(50)
       ,@iCodePairingDesc                      VARCHAR(50)
       ,@iBenefitStrategyID                    VARCHAR(50)
       ,@iBenefitStrategyDesc                  VARCHAR(50)
       ,@i_Network_Priority_Provider_Directory VARCHAR(50)
       ,@o_status                              INT
       ,@o_message                             VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#SuperNetworksServiceArea') IS NOT NULL
	DROP TABLE #SuperNetworksServiceArea

CREATE TABLE #SuperNetworksServiceArea
      (SearchID                              VARCHAR(200)
      ,i_entity_name                         VARCHAR(50)       DEFAULT('Service_Area_To_SuperNet')
      ,i_Network_Search_gid                  VARCHAR(50)       DEFAULT('0')
      ,i_Network_gid                         VARCHAR(20)       DEFAULT('0')
      ,i_Old_Network_ID                      VARCHAR(20)       DEFAULT('0')
      ,i_Old_Network_Name                    VARCHAR(50)       DEFAULT('0')
      ,i_Old_effective_date                  VARCHAR(50)       DEFAULT('0')
      ,i_Old_termination_date                VARCHAR(50)       DEFAULT('0')
      ,i_Old_price_strategy_gid              VARCHAR(50)       DEFAULT('0')
      ,i_Old_copay_strategy_gid              VARCHAR(50)       DEFAULT('0')
      ,i_Old_Network_SID                     VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                        VARCHAR(50)       DEFAULT('0')
      ,i_action                              VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified                  VARCHAR(50)       DEFAULT('')
      ,iUserID                               VARCHAR(25)       DEFAULT('')
      ,i_Network_Id                          VARCHAR(50)
      ,i_Network_Desc                        VARCHAR(50)
      ,i_effective_date                      VARCHAR(50)
      ,i_termination_date                    VARCHAR(50)
      ,i_Network_Priority                    VARCHAR(50)
      ,i_Coverage_Denied                     VARCHAR(50)
      ,i_Price_Strategy_Id                   VARCHAR(50)
      ,i_Price_Strategy_Desc                 VARCHAR(50)
      ,i_Copay_Strategy_Id                   VARCHAR(50)
      ,i_Copay_Strategy_Desc                 VARCHAR(50)
      ,i_Coverage_Strategy_Id                VARCHAR(50)
      ,i_Coverage_Strategy_Desc              VARCHAR(50)
      ,iCodePairingID                        VARCHAR(50)
      ,iCodePairingDesc                      VARCHAR(50)
      ,iBenefitStrategyID                    VARCHAR(50)
      ,iBenefitStrategyDesc                  VARCHAR(50)
      ,i_Network_Priority_Provider_Directory VARCHAR(50)
      ,o_status                              INT
      ,o_message                             VARCHAR(255)
      ,record_id                             INT
      ,static_gid                            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #SuperNetworksServiceArea
      (SearchID
      ,i_Network_Id
      ,i_effective_date
      ,i_termination_date
      ,i_Network_Priority
      ,i_Coverage_Denied
      ,i_Price_Strategy_Id
      ,i_Copay_Strategy_Id
      ,i_Coverage_Strategy_Id
      ,iCodePairingID
      ,iBenefitStrategyID
      ,i_Network_Priority_Provider_Directory
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*AffNetID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([ClaimAdjNwPriority], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CovDenied]), 'N')
      ,ISNULL([PriceStrategyID], '')
      ,ISNULL([CopayLevelsID], '')
      ,ISNULL([CodeLimitationsID], '')
      ,ISNULL([CodePairingID], '')
      ,ISNULL([BenefitStrategyID], '')
      ,ISNULL([ProvDirNwPriority], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_SuperNetworksServiceArea
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #SuperNetworksServiceArea
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE SuperNetworksServiceArea_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Network_Search_gid
       ,i_Network_gid
       ,i_Old_Network_ID
       ,i_Old_Network_Name
       ,i_Old_effective_date
       ,i_Old_termination_date
       ,i_Old_price_strategy_gid
       ,i_Old_copay_strategy_gid
       ,i_Old_Network_SID
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Network_Id
       ,i_Network_Desc
       ,i_effective_date
       ,i_termination_date
       ,i_Network_Priority
       ,i_Coverage_Denied
       ,i_Price_Strategy_Id
       ,i_Price_Strategy_Desc
       ,i_Copay_Strategy_Id
       ,i_Copay_Strategy_Desc
       ,i_Coverage_Strategy_Id
       ,i_Coverage_Strategy_Desc
       ,iCodePairingID
       ,iCodePairingDesc
       ,iBenefitStrategyID
       ,iBenefitStrategyDesc
       ,i_Network_Priority_Provider_Directory
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #SuperNetworksServiceArea

   OPEN SuperNetworksServiceArea_Cursor
  FETCH NEXT FROM SuperNetworksServiceArea_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Network_Search_gid
       ,@i_Network_gid
       ,@i_Old_Network_ID
       ,@i_Old_Network_Name
       ,@i_Old_effective_date
       ,@i_Old_termination_date
       ,@i_Old_price_strategy_gid
       ,@i_Old_copay_strategy_gid
       ,@i_Old_Network_SID
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Network_Id
       ,@i_Network_Desc
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Network_Priority
       ,@i_Coverage_Denied
       ,@i_Price_Strategy_Id
       ,@i_Price_Strategy_Desc
       ,@i_Copay_Strategy_Id
       ,@i_Copay_Strategy_Desc
       ,@i_Coverage_Strategy_Id
       ,@i_Coverage_Strategy_Desc
       ,@iCodePairingID
       ,@iCodePairingDesc
       ,@iBenefitStrategyID
       ,@iBenefitStrategyDesc
       ,@i_Network_Priority_Provider_Directory
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the gid for the Super Network
			SELECT @i_Network_Search_gid			= network_search_gid
			  FROM Provider_Network_Search_Names
			 WHERE network_search_id				= @SearchID
			   AND record_status					= 'A'

			EXEC dbo.prNet_ProvOrAttrNameToSup_AddMod
             @i_entity_name
            ,@i_Network_Search_gid
            ,@i_Network_gid
            ,@i_Old_Network_ID
            ,@i_Old_Network_Name
            ,@i_Old_effective_date
            ,@i_Old_termination_date
            ,@i_Old_price_strategy_gid
            ,@i_Old_copay_strategy_gid
            ,@i_Old_Network_SID
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Network_Id
            ,@i_Network_Desc
            ,@i_effective_date
            ,@i_termination_date
            ,@i_Network_Priority
            ,@i_Coverage_Denied
            ,@i_Price_Strategy_Id
            ,@i_Price_Strategy_Desc
            ,@i_Copay_Strategy_Id
            ,@i_Copay_Strategy_Desc
            ,@i_Coverage_Strategy_Id
            ,@i_Coverage_Strategy_Desc
            ,@iCodePairingID
            ,@iCodePairingDesc
            ,@iBenefitStrategyID
            ,@iBenefitStrategyDesc
            ,@i_Network_Priority_Provider_Directory
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Network_Id, '', @status, @err_num, @err_msg

        FETCH NEXT FROM SuperNetworksServiceArea_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Network_Search_gid
             ,@i_Network_gid
             ,@i_Old_Network_ID
             ,@i_Old_Network_Name
             ,@i_Old_effective_date
             ,@i_Old_termination_date
             ,@i_Old_price_strategy_gid
             ,@i_Old_copay_strategy_gid
             ,@i_Old_Network_SID
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Network_Id
             ,@i_Network_Desc
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Network_Priority
             ,@i_Coverage_Denied
             ,@i_Price_Strategy_Id
             ,@i_Price_Strategy_Desc
             ,@i_Copay_Strategy_Id
             ,@i_Copay_Strategy_Desc
             ,@i_Coverage_Strategy_Id
             ,@i_Coverage_Strategy_Desc
             ,@iCodePairingID
             ,@iCodePairingDesc
             ,@iBenefitStrategyID
             ,@iBenefitStrategyDesc
             ,@i_Network_Priority_Provider_Directory
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE SuperNetworksServiceArea_Cursor
DEALLOCATE SuperNetworksServiceArea_Cursor

END
GO