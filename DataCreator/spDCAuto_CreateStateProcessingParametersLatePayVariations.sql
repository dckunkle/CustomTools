IF OBJECT_ID('dbo.spDCAuto_CreateStateProcessingParametersLatePayVariations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateStateProcessingParametersLatePayVariations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateStateProcessingParametersLatePayVariations
Purpose:    Create stateprocessingparameterslatepayvariations data from CorderAutomation
Method:     StateProcessingParametersLatePayVariations
Screen GID: 7002
Procedure:  dbo.prStateLOBVariation_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
10/20/2023	DK				Added ability to choose Provider vs Member
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateStateProcessingParametersLatePayVariations '100-Config%', 22, 'StateProcessingParametersLatePayVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateStateProcessingParametersLatePayVariations
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
	   ,@assignment_type			VARCHAR(20)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_Entity_name     VARCHAR(100)
       ,@i_state_gid       VARCHAR(100)
       ,@i_variation_gid   VARCHAR(100)
       ,@i_key_3_field     VARCHAR(100)
       ,@i_key_4_field     VARCHAR(100)
       ,@i_key_5_field     VARCHAR(100)
       ,@i_key_6_field     VARCHAR(100)
       ,@i_key_7_field     VARCHAR(50)
       ,@i_key_8_field     VARCHAR(50)
       ,@i_key_9_field     VARCHAR(50)
       ,@i_key_10_field    VARCHAR(50)
       ,@i_action          VARCHAR(10)
       ,@l_modified_date   VARCHAR(30)
       ,@iUserID           VARCHAR(25)
       ,@i_system_lob      VARCHAR(50)
       ,@i_custom_lob      VARCHAR(50)
       ,@iGroupID          VARCHAR(100)
       ,@iGroupName        VARCHAR(100)
       ,@iGroupList        VARCHAR(100)
       ,@iGroupListName    VARCHAR(100)
       ,@iAffiliationID    VARCHAR(100)
       ,@iAffiliationName  VARCHAR(100)
       ,@iSuperNetWorkID   VARCHAR(100)
       ,@iSuperNetWorkName VARCHAR(100)
       ,@iBusinessUnitID   VARCHAR(100)
       ,@iBusinessUnitName VARCHAR(50)
       ,@iLocationID       VARCHAR(50)
       ,@iLocationName     VARCHAR(100)
       ,@iPlanStrategyID   VARCHAR(50)
       ,@iPlanStrategyName VARCHAR(100)
       ,@iPLanList         VARCHAR(100)
       ,@iPLanListName     VARCHAR(100)
       ,@iClaimType        VARCHAR(100)
       ,@i_network_status  VARCHAR(50)
       ,@iSingleTier       VARCHAR(50)
       ,@iPriority         INT
       ,@i_from_date       VARCHAR(50)
       ,@i_to_date         VARCHAR(50)
       ,@i_late_id         VARCHAR(50)
       ,@i_late_desc       VARCHAR(100)
       ,@o_status          INT
       ,@o_message         VARCHAR(500)
       ,@return_xml        XML

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#StateProcessingParametersLatePayVariations') IS NOT NULL
	DROP TABLE #StateProcessingParametersLatePayVariations

CREATE TABLE #StateProcessingParametersLatePayVariations
      (SearchID          VARCHAR(200)
      ,i_Entity_name     VARCHAR(100)      DEFAULT('State_LOB_Variations')
      ,i_state_gid       VARCHAR(100)      DEFAULT('0')
      ,i_variation_gid   VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field     VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field     VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field     VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field     VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field    VARCHAR(50)       DEFAULT('0')
      ,i_action          VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date   VARCHAR(30)       DEFAULT('')
      ,iUserID           VARCHAR(25)       DEFAULT('')
      ,i_system_lob      VARCHAR(50)
      ,i_custom_lob      VARCHAR(50)
      ,iGroupID          VARCHAR(100)
      ,iGroupName        VARCHAR(100)
      ,iGroupList        VARCHAR(100)
      ,iGroupListName    VARCHAR(100)
      ,iAffiliationID    VARCHAR(100)
      ,iAffiliationName  VARCHAR(100)
      ,iSuperNetWorkID   VARCHAR(100)
      ,iSuperNetWorkName VARCHAR(100)
      ,iBusinessUnitID   VARCHAR(100)
      ,iBusinessUnitName VARCHAR(50)
      ,iLocationID       VARCHAR(50)
      ,iLocationName     VARCHAR(100)
      ,iPlanStrategyID   VARCHAR(50)
      ,iPlanStrategyName VARCHAR(100)
      ,iPLanList         VARCHAR(100)
      ,iPLanListName     VARCHAR(100)
      ,iClaimType        VARCHAR(100)
      ,i_network_status  VARCHAR(50)
      ,iSingleTier       VARCHAR(50)
      ,iPriority         INT
      ,i_from_date       VARCHAR(50)
      ,i_to_date         VARCHAR(50)
      ,i_late_id         VARCHAR(50)
      ,i_late_desc       VARCHAR(100)
      ,o_status          INT
      ,o_message         VARCHAR(500)
      ,return_xml        XML
      ,record_id         INT
      ,static_gid        INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #StateProcessingParametersLatePayVariations
      (SearchID
      ,i_system_lob
      ,i_custom_lob
      ,iGroupID
      ,iGroupList
      ,iAffiliationID
      ,iSuperNetWorkID
      ,iBusinessUnitID
      ,iLocationID
      ,iPlanStrategyID
      ,iPLanList
	  ,iClaimType
      ,i_network_status
      ,iSingleTier
      ,iPriority
      ,i_from_date
      ,i_to_date
      ,i_late_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '******')
      ,ISNULL([GroupID], '')
      ,ISNULL([GroupListID], '')
      ,ISNULL([AffiliationID], '')
      ,ISNULL([SuperNetworkID], '')
      ,ISNULL([BusinessUnitID], '')
      ,ISNULL([LocationID], '')
      ,ISNULL([PlanStrategyID], '')
      ,ISNULL([PlanListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClaimType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkStatus]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SingleTierCalculation]), 'N')
      ,ISNULL([Priority], '9999')
      ,ISNULL([DaysFrom], '')
      ,ISNULL([DaysTo], '')
      ,ISNULL([*PenaltyID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_StateProcessingParametersLatePayVariations
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #StateProcessingParametersLatePayVariations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE StateProcessingParametersLatePayVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_state_gid
       ,i_variation_gid
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
       ,i_system_lob
       ,i_custom_lob
       ,iGroupID
       ,iGroupName
       ,iGroupList
       ,iGroupListName
       ,iAffiliationID
       ,iAffiliationName
       ,iSuperNetWorkID
       ,iSuperNetWorkName
       ,iBusinessUnitID
       ,iBusinessUnitName
       ,iLocationID
       ,iLocationName
       ,iPlanStrategyID
       ,iPlanStrategyName
       ,iPLanList
       ,iPLanListName
       ,iClaimType
       ,i_network_status
       ,iSingleTier
       ,iPriority
       ,i_from_date
       ,i_to_date
       ,i_late_id
       ,i_late_desc
       ,o_status
       ,o_message
       ,return_xml
       ,record_id
       ,static_gid
   FROM #StateProcessingParametersLatePayVariations

   OPEN StateProcessingParametersLatePayVariations_Cursor
  FETCH NEXT FROM StateProcessingParametersLatePayVariations_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_state_gid
       ,@i_variation_gid
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
       ,@i_system_lob
       ,@i_custom_lob
       ,@iGroupID
       ,@iGroupName
       ,@iGroupList
       ,@iGroupListName
       ,@iAffiliationID
       ,@iAffiliationName
       ,@iSuperNetWorkID
       ,@iSuperNetWorkName
       ,@iBusinessUnitID
       ,@iBusinessUnitName
       ,@iLocationID
       ,@iLocationName
       ,@iPlanStrategyID
       ,@iPlanStrategyName
       ,@iPLanList
       ,@iPLanListName
       ,@iClaimType
       ,@i_network_status
       ,@iSingleTier
       ,@iPriority
       ,@i_from_date
       ,@i_to_date
       ,@i_late_id
       ,@i_late_desc
       ,@o_status
       ,@o_message
       ,@return_xml
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			-- Get the state
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1
			SELECT @SearchID = dbo.fnDCAuto_GetDropdownValue(@SearchID)

			-- Get the provider or member
			SELECT @assignment_type = token FROM #Tokens WHERE token_order = 2
			SELECT @assignment_type = CASE WHEN @assignment_type = 'Provider' THEN 'P' 
			                               WHEN @assignment_type = 'Member'   THEN 'M' 
										   ELSE 'P' 
									   END

			--Get the gid for the Auth Match
			SELECT @i_state_gid				= SW.state_withhold_gid
			  FROM State_Withhold			SW
			 WHERE SW.record_status			= 'A'
			   AND SW.state_code			= @SearchID
			   AND SW.assignment_type		= @assignment_type

			EXEC dbo.prStateLOBVariation_Add
             @i_Entity_name
            ,@i_state_gid
            ,@i_variation_gid
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
            ,@i_system_lob
            ,@i_custom_lob
            ,@iGroupID
            ,@iGroupName
            ,@iGroupList
            ,@iGroupListName
            ,@iAffiliationID
            ,@iAffiliationName
            ,@iSuperNetWorkID
            ,@iSuperNetWorkName
            ,@iBusinessUnitID
            ,@iBusinessUnitName
            ,@iLocationID
            ,@iLocationName
            ,@iPlanStrategyID
            ,@iPlanStrategyName
            ,@iPLanList
            ,@iPLanListName
            ,@iClaimType
            ,@i_network_status
            ,@iSingleTier
            ,@iPriority
            ,@i_from_date
            ,@i_to_date
            ,@i_late_id
            ,@i_late_desc
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

				-- Update to the static gid
				UPDATE dbo.State_LOB_Variations 
				   SET state_variation_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND state_withhold_gid		= @i_state_gid
				   AND system_lob				= @i_system_lob
				   AND custom_lob				= @i_custom_lob
				   AND network_status			= @i_network_status
				   AND Late_Pay_Penalty_GID		= (SELECT entity_gid
				                                     FROM Entity_Names			EN
													WHERE EN.record_status		= 'A'
													  AND EN.entity_identifier	= 'Late_Pay_Penalty'
													  AND EN.entity_user_id		= @i_late_id)
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_custom_lob, @i_late_id, @status, @err_num, @err_msg

        FETCH NEXT FROM StateProcessingParametersLatePayVariations_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_state_gid
             ,@i_variation_gid
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
             ,@i_system_lob
             ,@i_custom_lob
             ,@iGroupID
             ,@iGroupName
             ,@iGroupList
             ,@iGroupListName
             ,@iAffiliationID
             ,@iAffiliationName
             ,@iSuperNetWorkID
             ,@iSuperNetWorkName
             ,@iBusinessUnitID
             ,@iBusinessUnitName
             ,@iLocationID
             ,@iLocationName
             ,@iPlanStrategyID
             ,@iPlanStrategyName
             ,@iPLanList
             ,@iPLanListName
             ,@iClaimType
             ,@i_network_status
             ,@iSingleTier
             ,@iPriority
             ,@i_from_date
             ,@i_to_date
             ,@i_late_id
             ,@i_late_desc
             ,@o_status
             ,@o_message
             ,@return_xml
             ,@record_id
             ,@static_gid
	END

CLOSE StateProcessingParametersLatePayVariations_Cursor
DEALLOCATE StateProcessingParametersLatePayVariations_Cursor

END
GO