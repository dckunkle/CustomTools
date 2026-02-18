IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocationsProviderAffiliation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocationsProviderAffiliation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocationsProviderAffiliation
Purpose:    Create servicelocationsprovideraffiliation data from CorderAutomation
Method:     ServiceLocationsProviderAffiliation
Screen GID: 600
Procedure:  dbo.prPMAff_AddMod

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
09/15/2022  DK				Use the ProviderID and LocationID fields to search for a service location
02/14/2023	DK				Expand Contract ID field to 200 characters
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocationsProviderAffiliation 'Ragnarok-Config%', 22, 'Ragnarok-Config','ServiceLocationsProviderAffiliation', 'RagnarokConfig'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocationsProviderAffiliation
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_provider_id		  VARCHAR(60)
	   ,@i_location_id		  VARCHAR(50)
       ,@i_Provider_gid       VARCHAR(50)
       ,@i_Location_gid       VARCHAR(200)
       ,@i_Business_gid       INT
       ,@i_Aff_id             VARCHAR(100)
       ,@i_Eff_Date           VARCHAR(50)
       ,@i_Term_Date          VARCHAR(50)
       ,@i_affiliation_sid    VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(50)
       ,@i_date_time_modified VARCHAR(20)
       ,@iUserID              VARCHAR(100)
       ,@i_in_eff_date        VARCHAR(50)
       ,@i_in_term_date       VARCHAR(50)
       ,@i_in_aff_id          VARCHAR(50)
       ,@i_in_directory       VARCHAR(50)
       ,@i_contract_id        VARCHAR(200)
       ,@i_npi_id             VARCHAR(50)
       ,@i_npi_verif          VARCHAR(50)
       ,@i_in_filed_fee       VARCHAR(50)
       ,@i_fee_description    VARCHAR(100)
       ,@i_lookup_id          VARCHAR(50)
       ,@i_lookup_desc        VARCHAR(100)
       ,@i_accept_new_pat     VARCHAR(50)
       ,@i_term_reason        VARCHAR(50)
       ,@i_sup_amount         VARCHAR(50)
       ,@i_min_guarantee      VARCHAR(50)
       ,@i_max_allowance      VARCHAR(50)
       ,@iIsPCP               VARCHAR(50)
       ,@iWithholdID          VARCHAR(50)
       ,@iWithholdDesc        VARCHAR(100)
       ,@iCap_ratetable_ID    VARCHAR(50)
       ,@iCap_ratetable_desc  VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)
       ,@i_DisplayResults     VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsProviderAffiliation') IS NOT NULL
	DROP TABLE #ServiceLocationsProviderAffiliation

CREATE TABLE #ServiceLocationsProviderAffiliation
      (SearchID             VARCHAR(200)
	  ,provider_id			VARCHAR(60)
	  ,location_id			VARCHAR(50)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Prov_Aff')
      ,i_Provider_gid       VARCHAR(50)       DEFAULT('0')
      ,i_Location_gid       VARCHAR(200)      DEFAULT('0')
      ,i_Business_gid       INT				  DEFAULT('0')
      ,i_Aff_id             VARCHAR(100)      DEFAULT('0')
      ,i_Eff_Date           VARCHAR(50)       DEFAULT('0')
      ,i_Term_Date          VARCHAR(50)       DEFAULT('0')
      ,i_affiliation_sid    VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(100)      DEFAULT('')
      ,i_in_eff_date        VARCHAR(50)
      ,i_in_term_date       VARCHAR(50)
      ,i_in_aff_id          VARCHAR(50)
      ,i_in_directory       VARCHAR(50)
      ,i_contract_id        VARCHAR(200)
      ,i_npi_id             VARCHAR(50)
      ,i_npi_verif          VARCHAR(50)
      ,i_in_filed_fee       VARCHAR(50)
      ,i_fee_description    VARCHAR(100)
      ,i_lookup_id          VARCHAR(50)
      ,i_lookup_desc        VARCHAR(100)
      ,i_accept_new_pat     VARCHAR(50)
      ,i_term_reason        VARCHAR(50)
      ,i_sup_amount         VARCHAR(50)
      ,i_min_guarantee      VARCHAR(50)
      ,i_max_allowance      VARCHAR(50)
      ,iIsPCP               VARCHAR(50)
      ,iWithholdID          VARCHAR(50)
      ,iWithholdDesc        VARCHAR(100)
      ,iCap_ratetable_ID    VARCHAR(50)
      ,iCap_ratetable_desc  VARCHAR(100)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,i_DisplayResults     VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ServiceLocationsProviderAffiliation
      (SearchID
	  ,provider_id
	  ,location_id
      ,i_in_eff_date
      ,i_in_term_date
      ,i_in_aff_id
      ,i_in_directory
      ,i_contract_id
      ,i_npi_id
      ,i_npi_verif
      ,i_in_filed_fee
      ,i_lookup_id
      ,i_accept_new_pat
      ,i_term_reason
      ,i_sup_amount
      ,i_min_guarantee
      ,i_max_allowance
      ,iIsPCP
      ,iWithholdID
      ,iCap_ratetable_ID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([ProviderID], '')
	  ,ISNULL([LocationID], '')
      ,ISNULL([*EffectiveDate], '')
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AffiliationID]), '******')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PrintInDir]), 'Y')
      ,ISNULL([ProviderContractID], '')
      ,ISNULL([NPIID], '')
      ,ISNULL([NPIVerification], '01/01/1900')
      ,ISNULL([FeeScheduleID], '')
      ,ISNULL([FeeLookupID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AcceptNewPatients]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TerminationReason]), '')
      ,ISNULL([SupplementalAmt], '0.00')
      ,ISNULL([MinimumGuarantee], '0.00')
      ,ISNULL([MaximunAllowance], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IsPCPWithinAffiliation]), 'N')
      ,ISNULL([WithholdID], '')
      ,ISNULL([CAPRateTableID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocationProvAff
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ServiceLocationsProviderAffiliation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocationsProviderAffiliation_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
	   ,provider_id
	   ,location_id
       ,i_Provider_gid
       ,i_Location_gid
       ,i_Business_gid
       ,i_Aff_id
       ,i_Eff_Date
       ,i_Term_Date
       ,i_affiliation_sid
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_in_eff_date
       ,i_in_term_date
       ,i_in_aff_id
       ,i_in_directory
       ,i_contract_id
       ,i_npi_id
       ,i_npi_verif
       ,i_in_filed_fee
       ,i_fee_description
       ,i_lookup_id
       ,i_lookup_desc
       ,i_accept_new_pat
       ,i_term_reason
       ,i_sup_amount
       ,i_min_guarantee
       ,i_max_allowance
       ,iIsPCP
       ,iWithholdID
       ,iWithholdDesc
       ,iCap_ratetable_ID
       ,iCap_ratetable_desc
       ,o_status
       ,o_message
       ,i_DisplayResults
       ,record_id
       ,static_gid
   FROM #ServiceLocationsProviderAffiliation

   OPEN ServiceLocationsProviderAffiliation_Cursor
  FETCH NEXT FROM ServiceLocationsProviderAffiliation_Cursor
   INTO @SearchID
       ,@i_entity_name
	   ,@i_provider_id
	   ,@i_location_id
       ,@i_Provider_gid
       ,@i_Location_gid
       ,@i_Business_gid
       ,@i_Aff_id
       ,@i_Eff_Date
       ,@i_Term_Date
       ,@i_affiliation_sid
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_in_eff_date
       ,@i_in_term_date
       ,@i_in_aff_id
       ,@i_in_directory
       ,@i_contract_id
       ,@i_npi_id
       ,@i_npi_verif
       ,@i_in_filed_fee
       ,@i_fee_description
       ,@i_lookup_id
       ,@i_lookup_desc
       ,@i_accept_new_pat
       ,@i_term_reason
       ,@i_sup_amount
       ,@i_min_guarantee
       ,@i_max_allowance
       ,@iIsPCP
       ,@iWithholdID
       ,@iWithholdDesc
       ,@iCap_ratetable_ID
       ,@iCap_ratetable_desc
       ,@o_status
       ,@o_message
       ,@i_DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @provider_id = ''
		      ,@location_id = ''
			  ,@business_id = ''

		-- Split the search criteria into the provider and location IDs
		TRUNCATE TABLE #Tokens
		INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')

		SELECT @provider_id = token FROM #Tokens WHERE token_order = 1
		SELECT @location_id	= token FROM #Tokens WHERE token_order = 2
		SELECT @business_id	= token FROM #Tokens WHERE token_order = 3

		SELECT @provider_id	= ISNULL(@provider_id, '')
		SELECT @location_id = ISNULL(@location_id, '')
		SELECT @business_id	= ISNULL(@business_id, '')

		--SELECT @record_id,@SearchID, @provider_id, @i_provider_id, @location_id, @i_location_id

		-- If the SearchID was not filled out but the ProviderID and LocationID fields were filled out use them
		IF @provider_id = '' AND @i_provider_id <> '' BEGIN SELECT @provider_id = @i_provider_id END
		IF @location_id = '' AND @i_location_id <> '' BEGIN SELECT @location_id = @i_location_id END

		-- Make sure there is only one service location 
		;WITH Service_Locations
		     (provider_gid
			 ,business_gid
			 ,location_gid)
		  AS (SELECT DISTINCT
		             PL.provider_gid
		            ,PL.business_gid
					,PL.location_gid
			    FROM Provider_Link					PL
			    JOIN Provider						P
				  ON PL.provider_gid				= P.provider_gid
			    JOIN Locations						L
			 	  ON PL.location_gid				= L.location_gid
			    JOIN Business_Units					BU
				  ON PL.business_gid				= BU.business_gid
			    WHERE 1 = (CASE WHEN @provider_id	= ''			THEN 1 
							    WHEN provider_id	= @provider_id	THEN 1
							    ELSE 0 END)
				  AND 1 = (CASE WHEN @location_id	= ''			THEN 1 
							    WHEN location_id	= @location_id	THEN 1
							    ELSE 0 END)
				  AND 1 = (CASE WHEN @business_id	= ''			 THEN 1 
							    WHEN business_unit_id = @business_id THEN 1
							    ELSE 0 END)
				  AND PL.record_status		= 'A'
				  AND P.record_status		= 'A'
				  AND L.record_status		= 'A'
				  AND BU.record_status		= 'A')

		SELECT @service_location_count = COUNT(*)
		  FROM Service_Locations

		IF @service_location_count != 1
			BEGIN

				SELECT @status	= 'Error' 
					    ,@err_num	= 16
						,@err_msg	= 'The search criteria, SearchID, does not match to a single service location. Cannot add specialty record.'
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @i_in_aff_id, @status, @err_num, @err_msg
					
			END
		ELSE
			BEGIN

				BEGIN TRY

					SELECT @i_Provider_gid				= PL.provider_gid
						  ,@i_Location_gid				= PL.location_gid
						  ,@i_Business_gid				= PL.business_gid
					  FROM Provider_Link				PL
					  JOIN Provider						P
						ON PL.provider_gid				= P.provider_gid
					  JOIN Locations					L
						ON PL.location_gid				= L.location_gid
					  JOIN Business_Units				BU
						ON PL.business_gid				= BU.business_gid
					  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
									  WHEN provider_id	= @provider_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @location_id = ''				THEN 1 
									  WHEN location_id	= @location_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @business_id = ''				THEN 1 
									  WHEN business_unit_id = @business_id	THEN 1
									  ELSE 0 END)
						AND PL.record_status			= 'A'
						AND P.record_status				= 'A'
						AND L.record_status				= 'A'
						AND BU.record_status			= 'A'

					EXEC dbo.prPMAff_AddMod
					 @i_entity_name
					,@i_Provider_gid
					,@i_Location_gid
					,@i_Business_gid
					,@i_Aff_id
					,@i_Eff_Date
					,@i_Term_Date
					,@i_affiliation_sid
					,@i_key_8_field
					,@i_key_9_field
					,@i_key_10_field
					,@i_action
					,@i_date_time_modified
					,@iUserID
					,@i_in_eff_date
					,@i_in_term_date
					,@i_in_aff_id
					,@i_in_directory
					,@i_contract_id
					,@i_npi_id
					,@i_npi_verif
					,@i_in_filed_fee
					,@i_fee_description
					,@i_lookup_id
					,@i_lookup_desc
					,@i_accept_new_pat
					,@i_term_reason
					,@i_sup_amount
					,@i_min_guarantee
					,@i_max_allowance
					,@iIsPCP
					,@iWithholdID
					,@iWithholdDesc
					,@iCap_ratetable_ID
					,@iCap_ratetable_desc
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT

				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH

			SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
			EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @i_in_aff_id, @status, @err_num, @err_msg

		END

        FETCH NEXT FROM ServiceLocationsProviderAffiliation_Cursor
         INTO @SearchID
             ,@i_entity_name
			 ,@i_provider_id
			 ,@i_location_id
             ,@i_Provider_gid
             ,@i_Location_gid
             ,@i_Business_gid
             ,@i_Aff_id
             ,@i_Eff_Date
             ,@i_Term_Date
             ,@i_affiliation_sid
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_in_eff_date
             ,@i_in_term_date
             ,@i_in_aff_id
             ,@i_in_directory
             ,@i_contract_id
             ,@i_npi_id
             ,@i_npi_verif
             ,@i_in_filed_fee
             ,@i_fee_description
             ,@i_lookup_id
             ,@i_lookup_desc
             ,@i_accept_new_pat
             ,@i_term_reason
             ,@i_sup_amount
             ,@i_min_guarantee
             ,@i_max_allowance
             ,@iIsPCP
             ,@iWithholdID
             ,@iWithholdDesc
             ,@iCap_ratetable_ID
             ,@iCap_ratetable_desc
             ,@o_status
             ,@o_message
             ,@i_DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocationsProviderAffiliation_Cursor
DEALLOCATE ServiceLocationsProviderAffiliation_Cursor

END
GO