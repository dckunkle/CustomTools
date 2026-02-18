/**************************************************************************************************
Name:       spDCAuto_CreateStateProcessingParametersLatePayVariationsTiers
Purpose:    Create stateprocessingparameterslatepayvariationstiers data from CorderAutomation

Screen:     7004
Method:     StateProcessingParametersLatePayVariationsTiers
Procedure:  dbo.prPenaltyTier_AddModify
Entity:     Penalty_Tier

Date        User            Change
---------------------------------------------------------------------------------------------
08/31/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateStateProcessingParametersLatePayVariationsTiers 'RFF-Config-2201%', 22, 'RFF-Config-2001%', 'StateProcessingParametersLatePayVariationsTiers', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateStateProcessingParametersLatePayVariationsTiers
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
	   ,@count						INT

	   ,@state						VARCHAR(10)
	   ,@priority					INT
	   ,@variation					VARCHAR(2000)
	   ,@variation_count			INT
	   ,@variation_setting			VARCHAR(200)
	   ,@lob						VARCHAR(20)
	   ,@business_unit				VARCHAR(50)
	   ,@business_gid				INT
	   ,@group						VARCHAR(50)
	   ,@group_gid					INT
	   ,@network					VARCHAR(50)
	   ,@network_gid				INT
	   ,@location					VARCHAR(50)
	   ,@location_gid				INT
	   ,@plan						VARCHAR(50)
	   ,@plan_gid					INT
	   ,@affiliation				VARCHAR(50)
	   ,@affiliation_gid			INT
	   ,@claim_type					VARCHAR(20)


SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_Entity_name   VARCHAR(50)
       ,@i_state_gid     VARCHAR(75)
       ,@iMatrixNumber   VARCHAR(75)
       ,@iVarationGid    VARCHAR(50)
       ,@i_key_4_field   VARCHAR(50)
       ,@i_key_5_field   VARCHAR(50)
       ,@i_key_6_field   VARCHAR(50)
       ,@i_key_7_field   VARCHAR(50)
       ,@i_key_8_field   VARCHAR(50)
       ,@i_key_9_field   VARCHAR(50)
       ,@i_key_10_field  VARCHAR(50)
       ,@i_action        VARCHAR(10)
       ,@l_modified_date VARCHAR(30)
       ,@iUserID         VARCHAR(25)
       ,@iDaysFrom       INT
       ,@iDaysTo         INT
       ,@iPenaltyID      VARCHAR(50)
       ,@iPenaltyDesc    VARCHAR(100)
       ,@o_status        INT
       ,@o_message       VARCHAR(500)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#StateProcessingParametersLatePayVariationsTiers') IS NOT NULL
	DROP TABLE #StateProcessingParametersLatePayVariationsTiers

CREATE TABLE #StateProcessingParametersLatePayVariationsTiers
      (SearchID        VARCHAR(200)
      ,i_Entity_name   VARCHAR(50)       DEFAULT('Penalty_Tier')
      ,i_state_gid     VARCHAR(75)       DEFAULT('0')
      ,iMatrixNumber   VARCHAR(75)       DEFAULT('0')
      ,iVarationGid    VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field  VARCHAR(50)       DEFAULT('0')
      ,i_action        VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date VARCHAR(30)       DEFAULT('')
      ,iUserID         VARCHAR(25)       DEFAULT('')
      ,iDaysFrom       INT
      ,iDaysTo         INT
      ,iPenaltyID      VARCHAR(50)
      ,iPenaltyDesc    VARCHAR(100)
      ,o_status        INT
      ,o_message       VARCHAR(500)
      ,record_id       INT
      ,static_gid      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #StateProcessingParametersLatePayVariationsTiers
          (SearchID
          ,iDaysFrom
          ,iDaysTo
          ,iPenaltyID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([DaysFrom], '')
          ,ISNULL([DaysTo], '')
          ,ISNULL([*PenaltyID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_StateProcessingParametersLatePayVariationsTiers
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #StateProcessingParametersLatePayVariationsTiers
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
DECLARE StateProcessingParametersLatePayVariationsTiers_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_state_gid
       ,iMatrixNumber
       ,iVarationGid
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
       ,iDaysFrom
       ,iDaysTo
       ,iPenaltyID
       ,iPenaltyDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #StateProcessingParametersLatePayVariationsTiers

   OPEN StateProcessingParametersLatePayVariationsTiers_Cursor
  FETCH NEXT FROM StateProcessingParametersLatePayVariationsTiers_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_state_gid
       ,@iMatrixNumber
       ,@iVarationGid
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
       ,@iDaysFrom
       ,@iDaysTo
       ,@iPenaltyID
       ,@iPenaltyDesc
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
			SELECT @state = token FROM #Tokens WHERE token_order = 1
			SELECT @state = dbo.fnDCAuto_GetDropdownValue(@SearchID)

			SELECT @variation = token FROM #Tokens WHERE token_order = 2
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@variation, ',')
			SELECT @variation_count = MAX(token_order) FROM #Tokens

			-- Set all variables to their default values
			SELECT @lob				= '******'
			      ,@plan_gid		= -1
				  ,@group_gid		= -1
				  ,@location_gid	= -1
				  ,@network_gid		= -1
				  ,@affiliation		= '******'
				  ,@business_gid	= -1
				  ,@priority		= 9999
				  ,@claim_type		= ''

			-- Loop through the variations list and set the appropriate variables
			SET @count = 0
			WHILE  @count < @variation_count
				BEGIN

					SET @count = @count + 1
					SELECT @variation_setting = TRIM(token) FROM #Tokens WHERE token_order = @count

					IF LEFT(@variation_setting, 10) = 'Priority: '			BEGIN SELECT @priority = TRIM(SUBSTRING(@variation_setting, 11, 9999)) END
					IF LEFT(@variation_setting, 5)  = 'LOB: '				BEGIN SELECT @lob = TRIM(SUBSTRING(@variation_setting, CHARINDEX('/', @variation_setting, 1) + 1, 9999)) END
					IF LEFT(@variation_setting, 15) = 'Plan Strategy: '		BEGIN SELECT @plan_gid = plan_strategy_gid FROM dbo.Plan_Strategy_Names WHERE record_status = 'A' AND plan_strategy_id = TRIM(SUBSTRING(@variation_setting, 16, 9999)) END
					IF LEFT(@variation_setting, 7)  = 'Group: '				BEGIN SELECT @group_gid = group_gid FROM dbo.Groups WHERE record_status = 'A' AND group_id = TRIM(SUBSTRING(@variation_setting, 8, 9999))  END
					IF LEFT(@variation_setting, 18) = 'Service Location: '	BEGIN SELECT @location_gid = location_gid FROM dbo.Locations WHERE record_status = 'A' AND location_id = TRIM(SUBSTRING(@variation_setting, 19, 9999)) END
					IF LEFT(@variation_setting, 15) = 'Super Network: '		BEGIN SELECT @network_gid = network_search_gid FROM Provider_Network_Search_Names WHERE record_status = 'A' AND network_search_id = TRIM(SUBSTRING(@variation_setting, 16, 9999)) END
					IF LEFT(@variation_setting, 13) = 'Affiliation: '		BEGIN SELECT @affiliation = TRIM(SUBSTRING(@variation_setting, 14, 9999)) END
					IF LEFT(@variation_setting, 15) = 'Business Unit: '		BEGIN SELECT @business_gid = business_gid FROM Business_Units WHERE record_status = 'A' AND business_unit_id = TRIM(SUBSTRING(@variation_setting, 16, 9999)) END
					IF LEFT(@variation_setting, 12) = 'Claim Type: '		BEGIN SELECT @claim_type = TRIM(SUBSTRING(@variation_setting, 13, 9999)) END

				END

			SELECT @iMatrixNumber			= ISNULL(SLV.MatrixNumber, 1)
			      ,@i_state_gid				= SW.state_withhold_gid
			  FROM State_LOB_Variations		SLV
			  JOIN State_Withhold			SW
			    ON SLV.state_withhold_gid	= SW.state_withhold_gid
			 WHERE SW.state_code			= @state
			   AND SLV.Priority				= @priority
			   AND SLV.custom_lob			= @lob
			   AND SLV.PlanStrategyGid		= @plan_gid
			   AND SLV.GroupGid				= @group_gid
			   AND SLV.LocationGid			= @location_gid
			   AND SLV.NetworkSearchGid		= @network_gid
			   AND SLV.AffiliationID		= @affiliation
			   AND SLV.BusinessGid			= @business_gid
			   AND SLV.ClaimType			= @claim_type
			   AND SLV.record_status		= 'A'
			   AND SW.record_status			= 'A'

			--SELECT @state
			--      ,@i_state_gid
			--      ,@lob				
			--      ,@plan_gid		
			--	  ,@group_gid		
			--	  ,@location_gid	
			--	  ,@network_gid		
			--	  ,@affiliation		
			--	  ,@business_gid	
			--	  ,@priority

			EXEC dbo.prPenaltyTier_AddModify
                 @i_Entity_name
                ,@i_state_gid
                ,@iMatrixNumber
                ,@iVarationGid
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
                ,@iDaysFrom
                ,@iDaysTo
                ,@iPenaltyID
                ,@iPenaltyDesc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @state, @iPenaltyID, @iDaysFrom, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM StateProcessingParametersLatePayVariationsTiers_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_state_gid
             ,@iMatrixNumber
             ,@iVarationGid
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
             ,@iDaysFrom
             ,@iDaysTo
             ,@iPenaltyID
             ,@iPenaltyDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE StateProcessingParametersLatePayVariationsTiers_Cursor
DEALLOCATE StateProcessingParametersLatePayVariationsTiers_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#StateProcessingParametersLatePayVariationsTiers') IS NOT NULL
	DROP TABLE #StateProcessingParametersLatePayVariationsTiers

END
GO

