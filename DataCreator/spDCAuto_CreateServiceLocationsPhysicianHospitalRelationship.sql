IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocationsPhysicianHospitalRelationship') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocationsPhysicianHospitalRelationship AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocationsPhysicianHospitalRelationship
Purpose:    Create servicelocationsphysicianhospitalrelationship data from CorderAutomation
Method:     ServiceLocationsPhysicianHospitalRelationship
Screen GID: 11005
Procedure:  dbo.prPhysHospitalProvRelAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocationsPhysicianHospitalRelationship '100-Config%', 22, 'ServiceLocationsPhysicianHospitalRelationship'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocationsPhysicianHospitalRelationship
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

	   ,@provider_id				VARCHAR(200)
	   ,@location_id				VARCHAR(200)
	   ,@business_id				VARCHAR(200)
	   ,@service_location_count		INT

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name          VARCHAR(20)
       ,@i_key_1_field          VARCHAR(20)
       ,@i_key_2_field          VARCHAR(50)
       ,@i_key_3_field          VARCHAR(50)
       ,@i_key_4_field          VARCHAR(20)
       ,@i_key_5_field          VARCHAR(20)
       ,@i_key_6_field          VARCHAR(10)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(50)
       ,@i_UserID               VARCHAR(25)
       ,@i_effectiveDate        VARCHAR(50)
       ,@i_terminationDate      VARCHAR(50)
       ,@i_hospitalProviderID   VARCHAR(60)
       ,@i_hospitalProviderName VARCHAR(100)
       ,@i_printDir             VARCHAR(50)
       ,@i_relType              VARCHAR(50)
       ,@o_status               INT
       ,@o_message              VARCHAR(100)
       ,@i_displayResults       VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsPhysicianHospitalRelationship') IS NOT NULL
	DROP TABLE #ServiceLocationsPhysicianHospitalRelationship

CREATE TABLE #ServiceLocationsPhysicianHospitalRelationship
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(20)       DEFAULT('PhysHospitalProvRel')
      ,i_key_1_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(10)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(50)       DEFAULT('')
      ,i_UserID               VARCHAR(25)       DEFAULT('')
      ,i_effectiveDate        VARCHAR(50)
      ,i_terminationDate      VARCHAR(50)
      ,i_hospitalProviderID   VARCHAR(60)
      ,i_hospitalProviderName VARCHAR(100)
      ,i_printDir             VARCHAR(50)
      ,i_relType              VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(100)
      ,i_displayResults       VARCHAR(50)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ServiceLocationsPhysicianHospitalRelationship
      (SearchID
      ,i_effectiveDate
      ,i_terminationDate
      ,i_hospitalProviderID
      ,i_printDir
      ,i_relType
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], '01/01/1900')
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([*HosProviderID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PrintinDirectory]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RelationshipType]), 'P')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocationPhyHosRel
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ServiceLocationsPhysicianHospitalRelationship
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocationsPhysicianHospitalRelationship_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_field
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
       ,i_date_time_modified
       ,i_UserID
       ,i_effectiveDate
       ,i_terminationDate
       ,i_hospitalProviderID
       ,i_hospitalProviderName
       ,i_printDir
       ,i_relType
       ,o_status
       ,o_message
       ,i_displayResults
       ,record_id
       ,static_gid
   FROM #ServiceLocationsPhysicianHospitalRelationship

   OPEN ServiceLocationsPhysicianHospitalRelationship_Cursor
  FETCH NEXT FROM ServiceLocationsPhysicianHospitalRelationship_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_field
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
       ,@i_date_time_modified
       ,@i_UserID
       ,@i_effectiveDate
       ,@i_terminationDate
       ,@i_hospitalProviderID
       ,@i_hospitalProviderName
       ,@i_printDir
       ,@i_relType
       ,@o_status
       ,@o_message
       ,@i_displayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Split the search criteria into the provider and location IDs
		TRUNCATE TABLE #Tokens
		INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')

		SELECT @provider_id = token FROM #Tokens WHERE token_order = 1
		SELECT @location_id	= token FROM #Tokens WHERE token_order = 2
		SELECT @business_id	= token FROM #Tokens WHERE token_order = 3

		SELECT @provider_id	= ISNULL(@provider_id, '')
		SELECT @location_id = ISNULL(@location_id, '')
		SELECT @business_id	= ISNULL(@business_id, '')

		-- Make sure there is only one service location 
		SELECT @service_location_count = COUNT(*)
		  FROM Provider_Link			PL
		  JOIN Provider					P
			ON PL.provider_gid			= P.provider_gid
		  JOIN Locations				L
			ON PL.location_gid			= L.location_gid
		  JOIN Business_Units			BU
		    ON PL.business_gid			= BU.business_gid
		  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
			              WHEN provider_id = @provider_id		THEN 1
					      ELSE 0 END)
			AND 1 = (CASE WHEN @location_id = ''				THEN 1 
			              WHEN location_id = @location_id		THEN 1
				          ELSE 0 END)
			AND 1 = (CASE WHEN @business_id = ''				THEN 1 
			              WHEN business_unit_id = @business_id	THEN 1
				          ELSE 0 END)
			AND PL.record_status		= 'A'
			AND P.record_status			= 'A'
			AND L.record_status			= 'A'
			AND BU.record_status		= 'A'

		IF @service_location_count != 1
			BEGIN

				SELECT @status	= 'Error' 
					    ,@err_num	= 16
						,@err_msg	= 'The search criteria, SearchID, does not match to a single service location. Cannot add specialty record.'
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id,@i_hospitalProviderID, @status, @err_num, @err_msg
					
			END
		ELSE
			BEGIN

				BEGIN TRY

					SELECT @i_key_1_field			= PL.provider_gid
						  ,@i_key_2_field			= PL.location_gid
						  ,@i_key_3_field			= PL.business_gid
					  FROM Provider_Link			PL
					  JOIN Provider					P
						ON PL.provider_gid			= P.provider_gid
					  JOIN Locations				L
						ON PL.location_gid			= L.location_gid
					  JOIN Business_Units			BU
						ON PL.business_gid			= BU.business_gid
					  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
									  WHEN provider_id = @provider_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @location_id = ''				THEN 1 
									  WHEN location_id = @location_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @business_id = ''				THEN 1 
									  WHEN business_unit_id = @business_id	THEN 1
									  ELSE 0 END)
						AND PL.record_status		= 'A'
						AND P.record_status			= 'A'
						AND L.record_status			= 'A'
						AND BU.record_status		= 'A'

					EXEC dbo.prPhysHospitalProvRelAddModify
					 @i_entity_name
					,@i_key_1_field
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
					,@i_date_time_modified
					,@i_UserID
					,@i_effectiveDate
					,@i_terminationDate
					,@i_hospitalProviderID
					,@i_hospitalProviderName
					,@i_printDir
					,@i_relType
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT

				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @i_hospitalProviderID, @status, @err_num, @err_msg

        FETCH NEXT FROM ServiceLocationsPhysicianHospitalRelationship_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_field
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
             ,@i_date_time_modified
             ,@i_UserID
             ,@i_effectiveDate
             ,@i_terminationDate
             ,@i_hospitalProviderID
             ,@i_hospitalProviderName
             ,@i_printDir
             ,@i_relType
             ,@o_status
             ,@o_message
             ,@i_displayResults
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocationsPhysicianHospitalRelationship_Cursor
DEALLOCATE ServiceLocationsPhysicianHospitalRelationship_Cursor

END
GO