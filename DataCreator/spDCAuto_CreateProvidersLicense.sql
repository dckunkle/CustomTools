IF OBJECT_ID('dbo.spDCAuto_CreateProvidersLicense') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProvidersLicense AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProvidersLicense
Purpose:    Create providerslicense/certificates data from CorderAutomation
Method:     ProvidersLicense/Certificates
Screen GID: 141
Procedure:  dbo.prPMLicenseAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProvidersLicense '100-Config%', 22, 'ProvidersLicense/Certificates'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProvidersLicense
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_Provider_gid       VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(20)
       ,@i_key_4_field        VARCHAR(20)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(20)
       ,@i_key_8_field        VARCHAR(100)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(10)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(20)
       ,@iUserID              VARCHAR(25)
       ,@i_license_id         VARCHAR(50)
       ,@i_license_type       VARCHAR(50)
       ,@i_license_date       VARCHAR(50)
       ,@i_license_term_date  VARCHAR(50)
       ,@i_license_state      VARCHAR(50)
       ,@i_practice_in        VARCHAR(50)
       ,@i_verify_start_date  VARCHAR(50)
       ,@i_verify_date        VARCHAR(50)
       ,@i_verifier_name      VARCHAR(50)
       ,@i_verifier_phone     VARCHAR(50)
       ,@i_BAC                VARCHAR(50)
       ,@i_Bus_Code           VARCHAR(50)
       ,@i_Schedule           VARCHAR(50)
       ,@i_location_id        VARCHAR(55)
       ,@i_location_desc      VARCHAR(55)
       ,@i_address_1          VARCHAR(55)
       ,@i_address_2          VARCHAR(55)
       ,@i_zip_code           VARCHAR(50)
       ,@i_city               VARCHAR(50)
       ,@i_state              VARCHAR(50)
       ,@i_county             VARCHAR(50)
       ,@i_country            VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)
       ,@i_display_results    VARCHAR(50)
       ,@i_ex_prov            VARCHAR(50)
	   ,@SearchID			  VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProvidersLicense') IS NOT NULL
	DROP TABLE #ProvidersLicense

CREATE TABLE #ProvidersLicense
      (i_entity_name        VARCHAR(50)       DEFAULT('Prov_Licenses')
      ,i_Provider_gid       VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(10)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(20)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_license_id         VARCHAR(50)
      ,i_license_type       VARCHAR(50)
      ,i_license_date       VARCHAR(50)
      ,i_license_term_date  VARCHAR(50)
      ,i_license_state      VARCHAR(50)
      ,i_practice_in        VARCHAR(50)
      ,i_verify_start_date  VARCHAR(50)
      ,i_verify_date        VARCHAR(50)
      ,i_verifier_name      VARCHAR(50)
      ,i_verifier_phone     VARCHAR(50)
      ,i_BAC                VARCHAR(50)
      ,i_Bus_Code           VARCHAR(50)
      ,i_Schedule           VARCHAR(50)
      ,i_location_id        VARCHAR(55)
      ,i_location_desc      VARCHAR(55)
      ,i_address_1          VARCHAR(55)
      ,i_address_2          VARCHAR(55)
      ,i_zip_code           VARCHAR(50)
      ,i_city               VARCHAR(50)
      ,i_state              VARCHAR(50)
      ,i_county             VARCHAR(50)
      ,i_country            VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,i_display_results    VARCHAR(50)
      ,i_ex_prov            VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT
	  ,SearchID				VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ProvidersLicense
      (SearchID
	  ,i_license_id
      ,i_license_type
      ,i_license_date
      ,i_license_term_date
      ,i_license_state
      ,i_practice_in
      ,i_verify_start_date
      ,i_verify_date
      ,i_verifier_name
      ,i_verifier_phone
      ,i_BAC
      ,i_Bus_Code
      ,i_Schedule
      ,i_location_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*LicenseNumber], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicenseType]), '01')
      ,ISNULL([OrigDateOfIssue], '01/01/1900')
      ,ISNULL([ExpirationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([StateOfRegistration]), '')
      ,ISNULL([CurrentlyPracticeInState], '')
      ,ISNULL([VerProcessStarted], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([DateVerified], '12/31/9999')
      ,ISNULL([VerifierName], '')
      ,ISNULL([VerifierPhone], '')
      ,ISNULL([BAC], '')
      ,ISNULL([BusActivitySubCode], '')
      ,ISNULL([Schedule], '')
      ,ISNULL([LocationID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ProviderLicense
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ProvidersLicense
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ProvidersLicense_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Provider_gid
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
       ,iUserID
       ,i_license_id
       ,i_license_type
       ,i_license_date
       ,i_license_term_date
       ,i_license_state
       ,i_practice_in
       ,i_verify_start_date
       ,i_verify_date
       ,i_verifier_name
       ,i_verifier_phone
       ,i_BAC
       ,i_Bus_Code
       ,i_Schedule
       ,i_location_id
       ,i_location_desc
       ,i_address_1
       ,i_address_2
       ,i_zip_code
       ,i_city
       ,i_state
       ,i_county
       ,i_country
       ,o_status
       ,o_message
       ,i_display_results
       ,i_ex_prov
       ,record_id
       ,static_gid
   FROM #ProvidersLicense

   OPEN ProvidersLicense_Cursor
  FETCH NEXT FROM ProvidersLicense_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Provider_gid
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
       ,@iUserID
       ,@i_license_id
       ,@i_license_type
       ,@i_license_date
       ,@i_license_term_date
       ,@i_license_state
       ,@i_practice_in
       ,@i_verify_start_date
       ,@i_verify_date
       ,@i_verifier_name
       ,@i_verifier_phone
       ,@i_BAC
       ,@i_Bus_Code
       ,@i_Schedule
       ,@i_location_id
       ,@i_location_desc
       ,@i_address_1
       ,@i_address_2
       ,@i_zip_code
       ,@i_city
       ,@i_state
       ,@i_county
       ,@i_country
       ,@o_status
       ,@o_message
       ,@i_display_results
       ,@i_ex_prov
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
			
			-- Get the provider_gid for the 
			SELECT @i_Provider_gid	= provider_gid
			  FROM dbo.Provider
			 WHERE provider_id		= @SearchID
			   AND record_status	= 'A'

			EXEC dbo.prPMLicenseAdd
             @i_entity_name
            ,@i_Provider_gid
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
            ,@iUserID
            ,@i_license_id
            ,@i_license_type
            ,@i_license_date
            ,@i_license_term_date
            ,@i_license_state
            ,@i_practice_in
            ,@i_verify_start_date
            ,@i_verify_date
            ,@i_verifier_name
            ,@i_verifier_phone
            ,@i_BAC
            ,@i_Bus_Code
            ,@i_Schedule
            ,@i_location_id
            ,@i_location_desc
            ,@i_address_1
            ,@i_address_2
            ,@i_zip_code
            ,@i_city
            ,@i_state
            ,@i_county
            ,@i_country
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT


        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_license_id, @i_license_type, @i_license_state, @status, @err_num, @err_msg

        FETCH NEXT FROM ProvidersLicense_Cursor
         INTO @SearchID
		     ,@i_entity_name
             ,@i_Provider_gid
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
             ,@iUserID
             ,@i_license_id
             ,@i_license_type
             ,@i_license_date
             ,@i_license_term_date
             ,@i_license_state
             ,@i_practice_in
             ,@i_verify_start_date
             ,@i_verify_date
             ,@i_verifier_name
             ,@i_verifier_phone
             ,@i_BAC
             ,@i_Bus_Code
             ,@i_Schedule
             ,@i_location_id
             ,@i_location_desc
             ,@i_address_1
             ,@i_address_2
             ,@i_zip_code
             ,@i_city
             ,@i_state
             ,@i_county
             ,@i_country
             ,@o_status
             ,@o_message
             ,@i_display_results
             ,@i_ex_prov
             ,@record_id
             ,@static_gid
	END

CLOSE ProvidersLicense_Cursor
DEALLOCATE ProvidersLicense_Cursor

END
GO