IF OBJECT_ID('dbo.spDCAuto_CreateAgencyContacts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAgencyContacts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAgencyContacts
Purpose:    Create agencycontacts data from CorderAutomation
Method:     AgencyContacts
Screen GID: 275
Procedure:  dbo.prBRBHContactAdd

Date        User            Change
---------------------------------------------------------------------------------------------
04/08/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAgencyContacts '100-Config%', 22, 'AgencyContacts'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAgencyContacts
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

DECLARE @i_entity_name        VARCHAR(100)
       ,@i_entity_gid         VARCHAR(100)
       ,@i_key_2_Gid          VARCHAR(100)
       ,@i_key_3_field        VARCHAR(100)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(20)
       ,@iUserID              VARCHAR(25)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_contact_purpose    VARCHAR(100)
       ,@i_Contact_ID         VARCHAR(50)
       ,@i_Name_Prefix        VARCHAR(50)
       ,@i_First_Name         VARCHAR(100)
       ,@i_Middle_Name        VARCHAR(100)
       ,@i_Last_Name          VARCHAR(100)
       ,@i_Name_Suffix        VARCHAR(100)
       ,@i_business_name      VARCHAR(100)
       ,@i_gender             VARCHAR(100)
       ,@i_birth_date         VARCHAR(100)
       ,@i_actual_SSN         VARCHAR(100)
       ,@i_Hipaa_Id           VARCHAR(50)
       ,@i_Email_Address      VARCHAR(50)
       ,@i_Phone_Number       VARCHAR(50)
       ,@i_Extension          VARCHAR(50)
       ,@i_Other_Phone_Number VARCHAR(50)
       ,@i_Fax_Number         VARCHAR(50)
       ,@i_Salutation_Name    VARCHAR(50)
       ,@i_Address_Type       VARCHAR(50)
       ,@i_Address_1          VARCHAR(55)
       ,@i_Address_2          VARCHAR(55)
       ,@i_Zip_Code           VARCHAR(50)
       ,@i_City               VARCHAR(50)
       ,@i_State              VARCHAR(50)
       ,@i_Country            VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AgencyContacts') IS NOT NULL
	DROP TABLE #AgencyContacts

CREATE TABLE #AgencyContacts
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(100)      DEFAULT('AGENCY_CONTACT')
      ,i_entity_gid         VARCHAR(100)      DEFAULT('0')
      ,i_key_2_Gid          VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(20)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_contact_purpose    VARCHAR(100)
      ,i_Contact_ID         VARCHAR(50)
      ,i_Name_Prefix        VARCHAR(50)
      ,i_First_Name         VARCHAR(100)
      ,i_Middle_Name        VARCHAR(100)
      ,i_Last_Name          VARCHAR(100)
      ,i_Name_Suffix        VARCHAR(100)
      ,i_business_name      VARCHAR(100)
      ,i_gender             VARCHAR(100)
      ,i_birth_date         VARCHAR(100)
      ,i_actual_SSN         VARCHAR(100)
      ,i_Hipaa_Id           VARCHAR(50)
      ,i_Email_Address      VARCHAR(50)
      ,i_Phone_Number       VARCHAR(50)
      ,i_Extension          VARCHAR(50)
      ,i_Other_Phone_Number VARCHAR(50)
      ,i_Fax_Number         VARCHAR(50)
      ,i_Salutation_Name    VARCHAR(50)
      ,i_Address_Type       VARCHAR(50)
      ,i_Address_1          VARCHAR(55)
      ,i_Address_2          VARCHAR(55)
      ,i_Zip_Code           VARCHAR(50)
      ,i_City               VARCHAR(50)
      ,i_State              VARCHAR(50)
      ,i_Country            VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

IF OBJECT_ID('tempdb.dbo.#AgencyContactInformation') IS NOT NULL
	DROP TABLE #AgencyContactInformation

CREATE TABLE #AgencyContactInformation
      (l_contact_gid		INT
      ,l_Name_Prefix        VARCHAR(200)
      ,l_First_Name         VARCHAR(200) 
      ,l_Middle_Name        VARCHAR(200)  
      ,l_Last_Name          VARCHAR(200) 
      ,l_Name_Suffix        VARCHAR(200) 
      ,l_business_name      VARCHAR(200)  
      ,l_gender             VARCHAR(200)  
      ,l_birth_date         VARCHAR(200)  
      ,l_actual_SSN         VARCHAR(200)  
      ,l_Hipaa_id           VARCHAR(200)
      ,l_Email_Address      VARCHAR(200)  
      ,l_Phone_Number       VARCHAR(200) 
      ,l_Extension          VARCHAR(200)
      ,l_Other_Phone_Number VARCHAR(200)
      ,l_Fax_Number         VARCHAR(200)
      ,l_Salutation_Name    VARCHAR(200)
      ,l_Address_Type       VARCHAR(200)
      ,l_Address_1          VARCHAR(200)
      ,l_Address_2          VARCHAR(200)
      ,l_Zip_Code           VARCHAR(200)
      ,l_City               VARCHAR(200)
      ,l_State              VARCHAR(200)
      ,l_Country            VARCHAR(200)
	  ,status				INT
	  ,message				VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (address1			VARCHAR(200)
      ,address2   		VARCHAR(200)
      ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
      --,County  			VARCHAR(200)
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
INSERT INTO #AgencyContacts
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_contact_purpose
      ,i_Contact_ID
      ,i_Name_Prefix
      ,i_Email_Address
      ,i_Phone_Number
      ,i_Extension
      ,i_Other_Phone_Number
      ,i_Fax_Number
      ,i_Salutation_Name
      ,i_Address_Type
      ,i_Address_1
      ,i_Address_2
      ,i_Zip_Code
      ,i_City
      ,i_State
      ,i_Country
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContactPurpose]), '')
      ,ISNULL([*ContactID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Perfix]), '')
      ,ISNULL([EmailAddress], '')
      ,ISNULL([PhoneNo], '0000000000')
      ,ISNULL([Extension], '')
      ,ISNULL([OtherPoneNo], '0000000000')
      ,ISNULL([FaxPhoneNo], '')
      ,ISNULL([Salutations], '0000000000')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AddressPurpose]), 'M')
      ,ISNULL([*AddressLine1], '')
      ,ISNULL([AddressLine2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ZipCode]), 'Missing')
      ,ISNULL([*City], '')
      ,ISNULL([State], 'UT')
      ,ISNULL([*Country], 'US')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AgencyContacts
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AgencyContacts
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AgencyContacts_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_entity_gid
       ,i_key_2_Gid
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
       ,i_effective_date
       ,i_termination_date
       ,i_contact_purpose
       ,i_Contact_ID
       ,i_Name_Prefix
       ,i_First_Name
       ,i_Middle_Name
       ,i_Last_Name
       ,i_Name_Suffix
       ,i_business_name
       ,i_gender
       ,i_birth_date
       ,i_actual_SSN
       ,i_Hipaa_Id
       ,i_Email_Address
       ,i_Phone_Number
       ,i_Extension
       ,i_Other_Phone_Number
       ,i_Fax_Number
       ,i_Salutation_Name
       ,i_Address_Type
       ,i_Address_1
       ,i_Address_2
       ,i_Zip_Code
       ,i_City
       ,i_State
       ,i_Country
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AgencyContacts

   OPEN AgencyContacts_Cursor
  FETCH NEXT FROM AgencyContacts_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_entity_gid
       ,@i_key_2_Gid
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
       ,@i_effective_date
       ,@i_termination_date
       ,@i_contact_purpose
       ,@i_Contact_ID
       ,@i_Name_Prefix
       ,@i_First_Name
       ,@i_Middle_Name
       ,@i_Last_Name
       ,@i_Name_Suffix
       ,@i_business_name
       ,@i_gender
       ,@i_birth_date
       ,@i_actual_SSN
       ,@i_Hipaa_Id
       ,@i_Email_Address
       ,@i_Phone_Number
       ,@i_Extension
       ,@i_Other_Phone_Number
       ,@i_Fax_Number
       ,@i_Salutation_Name
       ,@i_Address_Type
       ,@i_Address_1
       ,@i_Address_2
       ,@i_Zip_Code
       ,@i_City
       ,@i_State
       ,@i_Country
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the agency ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			-- Get the gid for the agency
			SELECT @i_entity_gid	= A.Agency_GID
			  FROM Agency			A
			 WHERE A.record_status	= 'A'
			   AND A.Agency_ID		= @SearchID

			-- Get the initial contact information for the contact gid provided
			TRUNCATE TABLE #AgencyContactInformation
			  INSERT INTO #AgencyContactInformation
			    EXEC prConBrokerAddTabOff 'Broker_Contact', '', '', '', @i_Contact_ID, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'ADD', 0, 0, ''

			SELECT @i_Name_Prefix		= CASE WHEN ISNULL(@i_Name_Prefix, '') = ''			THEN MC.l_Name_Prefix			ELSE @i_Name_Prefix			END
				  ,@i_First_Name  		= CASE WHEN ISNULL(@i_First_Name, '') = ''			THEN MC.l_First_Name			ELSE @i_First_Name			END
				  ,@i_Middle_Name  		= CASE WHEN ISNULL(@i_Middle_Name, '') = ''			THEN MC.l_Middle_Name			ELSE @i_Middle_Name			END
				  ,@i_Last_Name    		= CASE WHEN ISNULL(@i_Last_Name, '') = ''			THEN MC.l_Last_Name				ELSE @i_Last_Name			END
				  ,@i_Name_Suffix   	= CASE WHEN ISNULL(@i_Name_Suffix, '') = ''			THEN MC.l_Name_Suffix			ELSE @i_Name_Suffix			END
				  ,@i_business_name  	= CASE WHEN ISNULL(@i_business_name, '') = ''		THEN MC.l_business_name			ELSE @i_business_name		END
				  ,@i_gender    		= CASE WHEN ISNULL(@i_gender, '') = ''				THEN MC.l_gender				ELSE @i_gender				END
				  ,@i_birth_date 		= CASE WHEN ISNULL(@i_birth_date, '') = ''			THEN MC.l_birth_date			ELSE @i_birth_date			END	
				  ,@i_actual_SSN  		= CASE WHEN ISNULL(@i_actual_SSN, '') = ''			THEN MC.l_actual_SSN			ELSE @i_actual_SSN			END
				  ,@i_Hipaa_Id    		= CASE WHEN ISNULL(@i_Hipaa_Id, '') = ''			THEN MC.l_Hipaa_id				ELSE @i_Hipaa_Id			END
				  ,@i_Email_Address 	= CASE WHEN ISNULL(@i_Email_Address, '') = ''		THEN MC.l_Email_Address			ELSE @i_Email_Address		END
				  ,@i_Phone_Number  	= CASE WHEN ISNULL(@i_Phone_Number, '') = ''		THEN MC.l_Phone_Number			ELSE @i_Phone_Number		END
				  ,@i_Extension    		= CASE WHEN ISNULL(@i_Extension, '') = ''			THEN MC.l_Extension				ELSE @i_Extension			END
				  ,@i_Other_Phone_Number= CASE WHEN ISNULL(@i_Other_Phone_Number, '') = ''	THEN MC.l_Other_Phone_Number	ELSE @i_Other_Phone_Number	END
				  ,@i_Fax_Number   		= CASE WHEN ISNULL(@i_Fax_Number, '') = ''			THEN MC.l_Fax_Number			ELSE @i_Fax_Number			END
				  ,@i_Salutation_Name 	= CASE WHEN ISNULL(@i_Salutation_Name, '') = ''		THEN MC.l_Salutation_Name		ELSE @i_Salutation_Name		END
				  ,@i_Address_Type 		= CASE WHEN ISNULL(@i_Address_Type, '') = ''		THEN MC.l_Address_Type			ELSE @i_Address_Type		END
				  ,@i_Address_1   		= CASE WHEN ISNULL(@i_Address_1, '') = ''			THEN MC.l_Address_1				ELSE @i_Address_1			END
				  ,@i_Address_2 		= CASE WHEN ISNULL(@i_Address_2, '') = ''			THEN MC.l_Address_2				ELSE @i_Address_2			END
				  ,@i_Zip_Code  		= CASE WHEN ISNULL(@i_Zip_Code, '') = ''			THEN MC.l_Zip_Code				ELSE @i_Zip_Code			END
				  ,@i_City     			= CASE WHEN ISNULL(@i_City, '') = ''				THEN MC.l_City					ELSE @i_City				END
				  ,@i_State     		= CASE WHEN ISNULL(@i_State, '') = ''				THEN MC.l_State					ELSE @i_State				END
				  ,@i_Country			= CASE WHEN ISNULL(@i_Country, '') = ''				THEN MC.l_Country				ELSE @i_Country				END
			  FROM #AgencyContactInformation MC

			-- Get any missing pieces of the address that would normally be populated in the UI
			TRUNCATE TABLE #Addresses
			INSERT INTO #Addresses
			  EXEC prConBrokerAddTabOff 'Address', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', @i_address_1, @i_address_2, @i_zip_Code, @i_city, @i_State, @i_Country, 'ADD', 0, 0, ''

			--Get the preferred city name
			TRUNCATE TABLE #City
			INSERT INTO #City
			  EXEC prCityVaryCombo 'CITY', '6', @i_zip_Code

			SELECT TOP 1
				   @i_address_1			= A.address1
				  ,@i_address_2			= A.address2
			 	  ,@i_zip_Code			= A.zip
				  ,@i_State				= A.state
				  ,@i_Country			= A.country 
			FROM #Addresses				A

			SELECT TOP 1
				  @i_city				= CASE WHEN ISNULL(@i_city, '') = '' THEN C.Short_Desc ELSE @i_city END
			  FROM #City				C

			EXEC dbo.prBRBHContactAdd
				 @i_entity_name
				,@i_entity_gid
				,@i_key_2_Gid
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
				,@i_effective_date
				,@i_termination_date
				,@i_contact_purpose
				,@i_Contact_ID
				,@i_Name_Prefix
				,@i_First_Name
				,@i_Middle_Name
				,@i_Last_Name
				,@i_Name_Suffix
				,@i_business_name
				,@i_gender
				,@i_birth_date
				,@i_actual_SSN
				,@i_Hipaa_Id
				,@i_Email_Address
				,@i_Phone_Number
				,@i_Extension
				,@i_Other_Phone_Number
				,@i_Fax_Number
				,@i_Salutation_Name
				,@i_Address_Type
				,@i_Address_1
				,@i_Address_2
				,@i_Zip_Code
				,@i_City
				,@i_State
				,@i_Country
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Contact_ID, @i_contact_purpose, @status, @err_num, @err_msg

        FETCH NEXT FROM AgencyContacts_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_entity_gid
             ,@i_key_2_Gid
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
             ,@i_effective_date
             ,@i_termination_date
             ,@i_contact_purpose
             ,@i_Contact_ID
             ,@i_Name_Prefix
             ,@i_First_Name
             ,@i_Middle_Name
             ,@i_Last_Name
             ,@i_Name_Suffix
             ,@i_business_name
             ,@i_gender
             ,@i_birth_date
             ,@i_actual_SSN
             ,@i_Hipaa_Id
             ,@i_Email_Address
             ,@i_Phone_Number
             ,@i_Extension
             ,@i_Other_Phone_Number
             ,@i_Fax_Number
             ,@i_Salutation_Name
             ,@i_Address_Type
             ,@i_Address_1
             ,@i_Address_2
             ,@i_Zip_Code
             ,@i_City
             ,@i_State
             ,@i_Country
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AgencyContacts_Cursor
DEALLOCATE AgencyContacts_Cursor

END
GO