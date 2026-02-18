IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocationsSpecialties') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocationsSpecialties AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocationsSpecialties
Purpose:    Create servicelocationsspecialties data from CorderAutomation
Method:     ServiceLocationsSpecialties
Screen GID: 143
Procedure:  dbo.prPMSpecialtyAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
03/22/2021	DK				Update logic that determines if there is only one SL to add 
                            the specialty to
09/21/2022	DK				Reset the variables used to search for the service location
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocationsSpecialties '100-Config%', 22, 'ServiceLocationsSpecialties'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocationsSpecialties
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

SELECT @pattern						= @i_pattern
	  ,@log_id						= @i_log_id
	  ,@method						= @i_method
	  ,@test_case_name				= @i_test_case_name
	  ,@user						= @i_user

DECLARE @i_entity_name				VARCHAR(20)
       ,@i_Provider_gid				VARCHAR(50)
       ,@i_Location_gid				VARCHAR(20)
       ,@i_Business_gid				VARCHAR(50)
       ,@i_key_4_field				VARCHAR(20)
       ,@i_key_5_field				VARCHAR(50)
       ,@i_key_6_field				VARCHAR(50)
       ,@i_key_7_field				VARCHAR(50)
       ,@i_key_8_field				VARCHAR(50)
       ,@i_key_9_field				VARCHAR(50)
       ,@i_key_10_field				VARCHAR(50)
       ,@i_action					VARCHAR(10)
       ,@i_date_time_modified		VARCHAR(30)
       ,@iUserID					VARCHAR(100)
       ,@i_specialty_id				VARCHAR(50)
       ,@i_special_desc				VARCHAR(20)
       ,@i_treat_as_specialty		VARCHAR(50)
       ,@i_treat_specialty_desc		VARCHAR(100)
       ,@i_primary_indicator		VARCHAR(50)
       ,@i_dental_school			VARCHAR(100)
       ,@i_dental_grad_year			VARCHAR(50)
       ,@i_residency_comp_date		VARCHAR(50)
       ,@i_board_elig_date			VARCHAR(50)
       ,@i_board_cert_date			VARCHAR(50)
       ,@i_board_name				VARCHAR(50)
	   ,@i_board_cert_url			VARCHAR(255)  
       ,@i_print_as_specialty		VARCHAR(50)
       ,@i_spi_id					VARCHAR(60)
       ,@i_npi_id					VARCHAR(50)
       ,@i_sp_npi_verif				VARCHAR(50)
       ,@i_scheduled_date			VARCHAR(50)
       ,@i_experation_date			VARCHAR(50)
       ,@i_Recertification_date		VARCHAR(50)
       ,@i_reporting_type			VARCHAR(50)
       ,@i_State_Rpt_type			VARCHAR(50)
       ,@i_HMS_Specialty_ID			VARCHAR(50)
       ,@o_status					INT
       ,@o_message					VARCHAR(100)
       ,@i_DisplayResults			VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsSpecialties') IS NOT NULL
	DROP TABLE #ServiceLocationsSpecialties

CREATE TABLE #ServiceLocationsSpecialties
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(20)       DEFAULT('Prov_Specialties')
      ,i_Provider_gid         VARCHAR(50)       DEFAULT('0')
      ,i_Location_gid         VARCHAR(20)       DEFAULT('0')
      ,i_Business_gid         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserID                VARCHAR(100)      DEFAULT('')
      ,i_specialty_id         VARCHAR(50)
      ,i_special_desc         VARCHAR(20)
      ,i_treat_as_specialty   VARCHAR(50)
      ,i_treat_specialty_desc VARCHAR(100)
      ,i_primary_indicator    VARCHAR(50)
      ,i_dental_school        VARCHAR(100)
      ,i_dental_grad_year     VARCHAR(50)
      ,i_residency_comp_date  VARCHAR(50)
      ,i_board_elig_date      VARCHAR(50)
      ,i_board_cert_date      VARCHAR(50)
      ,i_board_name           VARCHAR(50)
	  ,i_board_cert_url       varchar(255)		DEFAULT('')
      ,i_print_as_specialty   VARCHAR(50)
      ,i_spi_id               VARCHAR(60)
      ,i_npi_id               VARCHAR(50)
      ,i_sp_npi_verif         VARCHAR(50)
      ,i_scheduled_date       VARCHAR(50)
      ,i_experation_date      VARCHAR(50)
      ,i_Recertification_date VARCHAR(50)
      ,i_reporting_type       VARCHAR(50)
      ,i_State_Rpt_type       VARCHAR(50)
      ,i_HMS_Specialty_ID     VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(100)
      ,i_DisplayResults       VARCHAR(50)
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
INSERT INTO #ServiceLocationsSpecialties
      (SearchID
      ,i_specialty_id
      ,i_treat_as_specialty
      ,i_primary_indicator
      ,i_dental_school
      ,i_dental_grad_year
      ,i_residency_comp_date
      ,i_board_elig_date
      ,i_board_cert_date
      ,i_board_name
	  ,i_board_cert_url
      ,i_print_as_specialty
      ,i_spi_id
      ,i_npi_id
      ,i_sp_npi_verif
      ,i_scheduled_date
      ,i_experation_date
      ,i_Recertification_date
      ,i_reporting_type
      ,i_State_Rpt_type
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Specialty], '')
      ,ISNULL([*SpecializingIn], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PrimaryIndicator]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([School]), '')
      ,ISNULL([GradYear], '1900')
      ,ISNULL([ResCompletionDate], '01/01/1900')
      ,ISNULL([BoardElgDate], '01/01/1900')
      ,ISNULL([BoardCertDate], '01/01/1900')
      ,ISNULL([NameofCertBoard], '')
      ,ISNULL([BoardCertURL], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SpecializinginDir]), 'N')
      ,ISNULL([SPIID], '')
      ,ISNULL([NPIID], '')
      ,ISNULL([NPIVerification], '01/01/1900')
      ,ISNULL([SchedforSpecBoard], '01/01/1900')
      ,ISNULL([ExpDate], '01/01/1900')
      ,ISNULL([RecertDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportingType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SpecStateReporting]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocationSpecialties
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ServiceLocationsSpecialties
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocationsSpecialties_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Provider_gid
       ,i_Location_gid
       ,i_Business_gid
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_specialty_id
       ,i_special_desc
       ,i_treat_as_specialty
       ,i_treat_specialty_desc
       ,i_primary_indicator
       ,i_dental_school
       ,i_dental_grad_year
       ,i_residency_comp_date
       ,i_board_elig_date
       ,i_board_cert_date
       ,i_board_name
	   ,i_board_cert_url
       ,i_print_as_specialty
       ,i_spi_id
       ,i_npi_id
       ,i_sp_npi_verif
       ,i_scheduled_date
       ,i_experation_date
       ,i_Recertification_date
       ,i_reporting_type
       ,i_State_Rpt_type
       ,i_HMS_Specialty_ID
       ,o_status
       ,o_message
       ,i_DisplayResults
       ,record_id
       ,static_gid
   FROM #ServiceLocationsSpecialties

   OPEN ServiceLocationsSpecialties_Cursor
  FETCH NEXT FROM ServiceLocationsSpecialties_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Provider_gid
       ,@i_Location_gid
       ,@i_Business_gid
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_specialty_id
       ,@i_special_desc
       ,@i_treat_as_specialty
       ,@i_treat_specialty_desc
       ,@i_primary_indicator
       ,@i_dental_school
       ,@i_dental_grad_year
       ,@i_residency_comp_date
       ,@i_board_elig_date
       ,@i_board_cert_date
       ,@i_board_name
	   ,@i_board_cert_url
       ,@i_print_as_specialty
       ,@i_spi_id
       ,@i_npi_id
       ,@i_sp_npi_verif
       ,@i_scheduled_date
       ,@i_experation_date
       ,@i_Recertification_date
       ,@i_reporting_type
       ,@i_State_Rpt_type
       ,@i_HMS_Specialty_ID
       ,@o_status
       ,@o_message
       ,@i_DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @provider_id	= ''
		SELECT @location_id = ''
		SELECT @business_id	= ''

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
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @i_specialty_id, @status, @err_num, @err_msg
					
			END
		ELSE
			BEGIN

				BEGIN TRY

					SELECT @i_Provider_gid			= PL.provider_gid
						  ,@i_Location_gid			= PL.location_gid
						  ,@i_Business_gid			= PL.business_gid
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

					EXEC dbo.prPMSpecialtyAdd
						@i_entity_name
					,@i_Provider_gid
					,@i_Location_gid
					,@i_Business_gid
					,@i_key_4_field
					,@i_key_5_field
					,@i_key_6_field
					,@i_key_7_field
					,@i_key_8_field
					,@i_key_9_field
					,@i_key_10_field
					,@i_action
					,@i_date_time_modified
					,@iUserID
					,@i_specialty_id
					,@i_special_desc
					,@i_treat_as_specialty
					,@i_treat_specialty_desc
					,@i_primary_indicator
					,@i_dental_school
					,@i_dental_grad_year
					,@i_residency_comp_date
					,@i_board_elig_date
					,@i_board_cert_date
					,@i_board_name
					,@i_board_cert_url
					,@i_print_as_specialty
					,@i_spi_id
					,@i_npi_id
					,@i_sp_npi_verif
					,@i_scheduled_date
					,@i_experation_date
					,@i_Recertification_date
					,@i_reporting_type
					,@i_State_Rpt_type
					,@i_HMS_Specialty_ID
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT

				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH

			SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
			EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @i_specialty_id, @status, @err_num, @err_msg

		END 

        FETCH NEXT FROM ServiceLocationsSpecialties_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Provider_gid
             ,@i_Location_gid
             ,@i_Business_gid
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_specialty_id
             ,@i_special_desc
             ,@i_treat_as_specialty
             ,@i_treat_specialty_desc
             ,@i_primary_indicator
             ,@i_dental_school
             ,@i_dental_grad_year
             ,@i_residency_comp_date
             ,@i_board_elig_date
             ,@i_board_cert_date
             ,@i_board_name
			 ,@i_board_cert_url
             ,@i_print_as_specialty
             ,@i_spi_id
             ,@i_npi_id
             ,@i_sp_npi_verif
             ,@i_scheduled_date
             ,@i_experation_date
             ,@i_Recertification_date
             ,@i_reporting_type
             ,@i_State_Rpt_type
             ,@i_HMS_Specialty_ID
             ,@o_status
             ,@o_message
             ,@i_DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocationsSpecialties_Cursor
DEALLOCATE ServiceLocationsSpecialties_Cursor

END
GO