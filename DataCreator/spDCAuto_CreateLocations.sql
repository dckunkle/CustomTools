IF OBJECT_ID('dbo.spDCAuto_CreateLocations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateLocations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateLocations
Purpose:    Create locations data from CorderAutomation
Method:     Locations
Screen GID: 2050
Procedure:  dbo.prPMProviderLocationAddMod

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateLocations '100-Config%', 22, 'Locations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateLocations
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

DECLARE @i_entity_name        VARCHAR(20)
       ,@i_location_gid       VARCHAR(200)
       ,@i_key_2_field        VARCHAR(200)
       ,@i_key_3_field        VARCHAR(200)
       ,@i_key_4_field        VARCHAR(20)
       ,@i_key_5_field        VARCHAR(100)
       ,@i_key_6_field        VARCHAR(20)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(100)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_location_id        VARCHAR(50)
       ,@i_location_desc      VARCHAR(100)
       ,@i_address_1          VARCHAR(55)
       ,@i_address_2          VARCHAR(55)
       ,@i_zip                VARCHAR(50)
       ,@i_city               VARCHAR(50)
       ,@i_state              VARCHAR(50)
       ,@i_county             VARCHAR(50)
       ,@i_country            VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Locations') IS NOT NULL
	DROP TABLE #Locations

CREATE TABLE #Locations
      (i_entity_name        VARCHAR(20)       DEFAULT('Prov_Loc')
      ,i_location_gid       VARCHAR(200)      DEFAULT('0')
      ,i_key_2_field        VARCHAR(200)      DEFAULT('0')
      ,i_key_3_field        VARCHAR(200)      DEFAULT('0')
      ,i_key_4_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_location_id        VARCHAR(50)
      ,i_location_desc      VARCHAR(100)
      ,i_address_1          VARCHAR(55)
      ,i_address_2          VARCHAR(55)
      ,i_zip                VARCHAR(50)
      ,i_city               VARCHAR(50)
      ,i_state              VARCHAR(50)
      ,i_county             VARCHAR(50)
      ,i_country            VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (location_id		VARCHAR(200)  
      ,location_name 	VARCHAR(200)
      ,address1			VARCHAR(200)
      ,address2   		VARCHAR(200)
      ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
      ,County  			VARCHAR(200)
      ,Country 			VARCHAR(200) 
      ,status  			INT
      ,Message			VARCHAR(200))  

IF OBJECT_ID('tempdb.dbo.#City') IS NOT NULL
	DROP TABLE #City

CREATE TABLE #City
      (FieldNumber		VARCHAR(200)  
      ,Reference_Type 	VARCHAR(200)
      ,Short_Desc		VARCHAR(200)
      ,Description   	VARCHAR(200)
      ,Seq_Num			VARCHAR(200))  

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Locations
      (i_location_id
      ,i_location_desc
      ,i_address_1
      ,i_address_2
      ,i_zip
      ,i_city
      ,i_state
      ,i_county
      ,i_country
      ,record_id
      ,static_gid)
SELECT ISNULL([LocationID], '')
      ,ISNULL([LocationName], '')
      ,ISNULL([*Address1], '')
      ,ISNULL([Address2], '')
      ,ISNULL([*Zip], '')
      ,ISNULL([*City], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([State]), '')
      ,ISNULL([County], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Country]), 'US')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Location
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Locations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Locations_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_location_gid
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
       ,i_location_id
       ,i_location_desc
       ,i_address_1
       ,i_address_2
       ,i_zip
       ,i_city
       ,i_state
       ,i_county
       ,i_country
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Locations

   OPEN Locations_Cursor
  FETCH NEXT FROM Locations_Cursor
   INTO @i_entity_name
       ,@i_location_gid
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
       ,@i_location_id
       ,@i_location_desc
       ,@i_address_1
       ,@i_address_2
       ,@i_zip
       ,@i_city
       ,@i_state
       ,@i_county
       ,@i_country
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get any missing pieces of the address that would normally be populated in the UI
			TRUNCATE TABLE #Addresses
			INSERT INTO #Addresses
			  EXEC prPMProvLocTabOff 'Zip', @i_location_id, @i_location_desc, @i_address_1, @i_address_2, @i_zip, @i_city, @i_state, @i_county, @i_country, 'ADD', 0, 0, ''

			--Get the preferred city name
			TRUNCATE TABLE #City
			INSERT INTO #City
			  EXEC prCityVaryCombo 'CITY', '6', @i_zip

			SELECT TOP 1
				   @i_address_1			= C.address1
				  ,@i_address_2			= C.address2
			 	  ,@i_zip				= C.zip
				  ,@i_State				= COALESCE(@i_State, C.state, '')
				  ,@i_county			= COALESCE(@i_county, C.county, '')
				  ,@i_Country			= COALESCE(@i_Country, C.country, '')
			FROM #Addresses				C

			SELECT TOP 1
				  @i_city				= COALESCE(@i_city, C.Short_Desc, '')
			  FROM #City				C

			EXEC dbo.prPMProviderLocationAddMod
             @i_entity_name
            ,@i_location_gid
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
            ,@i_location_id
            ,@i_location_desc
            ,@i_address_1
            ,@i_address_2
            ,@i_zip
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

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Locations 
				   SET location_gid				= @static_gid 
				 WHERE location_id				= @i_location_id
				   AND record_status			= 'A'

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_location_id, @i_address_1, @i_city, @status, @err_num, @err_msg

        FETCH NEXT FROM Locations_Cursor
         INTO @i_entity_name
             ,@i_location_gid
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
             ,@i_location_id
             ,@i_location_desc
             ,@i_address_1
             ,@i_address_2
             ,@i_zip
             ,@i_city
             ,@i_state
             ,@i_county
             ,@i_country
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Locations_Cursor
DEALLOCATE Locations_Cursor

END
GO