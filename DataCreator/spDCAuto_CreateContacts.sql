IF OBJECT_ID('dbo.spDCAuto_CreateContacts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateContacts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateContacts
Purpose:    Create contacts data from CorderAutomation
Method:     Contacts
Screen GID: 59
Procedure:  dbo.prContactAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
08/31/2022	DK				Changes for MAX length testing
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateContacts 'Max-Config%', 22, 'Max-Config', 'Contacts', 'DKUNKLE'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateContacts
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

DECLARE @i_entity_name              VARCHAR(50)
       ,@i_key_1_field              VARCHAR(50)
       ,@i_key_2_field              VARCHAR(50)
       ,@i_key_3_field              VARCHAR(50)
       ,@i_key_4_field              VARCHAR(20)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(50)
       ,@i_Date_Time_Modified       VARCHAR(50)
       ,@iUserID                    VARCHAR(25)
       ,@i_Contact_ID               VARCHAR(20)
       ,@i_Name_Prefix              VARCHAR(50)
       ,@i_First_Name               VARCHAR(60)
       ,@i_Middle_Name              VARCHAR(30)
       ,@i_Last_Name                VARCHAR(70)
       ,@i_Name_Suffix              VARCHAR(50)
       ,@i_gender                   VARCHAR(50)
       ,@i_birth_date               VARCHAR(50)
       ,@i_actual_SSN               VARCHAR(50)
       ,@i_Hipaa_Id                 VARCHAR(20)
       ,@i_national_producer_number VARCHAR(50)
       ,@i_Email_Address            VARCHAR(20)
       ,@i_Phone_Number             VARCHAR(50)
       ,@i_Extension                VARCHAR(100)
       ,@i_Other_Phone_Number       VARCHAR(50)
       ,@i_Fax_Number               VARCHAR(50)
       ,@i_Salutation_Name          VARCHAR(20)
       ,@i_Address_Type             VARCHAR(50)
       ,@i_Address_1                VARCHAR(85)
       ,@i_Address_2                VARCHAR(55)
       ,@i_Zip_Code                 VARCHAR(50)
       ,@i_City                     VARCHAR(50)
       ,@i_State                    VARCHAR(50)
       ,@i_county                   VARCHAR(50)
       ,@i_Country                  VARCHAR(50)
       ,@i_Marital_Status           VARCHAR(50)
       ,@i_Employer_Name            VARCHAR(50)
       ,@i_Employer_Phone_Number    VARCHAR(50)
       ,@i_Business_Name            VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Contacts') IS NOT NULL
	DROP TABLE #Contacts

CREATE TABLE #Contacts
      (i_entity_name              VARCHAR(50)       DEFAULT('Contacts')
      ,i_key_1_field              VARCHAR(10)       DEFAULT('0')
      ,i_key_2_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field              VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field             VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(50)       DEFAULT('ADD')
      ,i_Date_Time_Modified       VARCHAR(50)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,i_Contact_ID               VARCHAR(20)		DEFAULT('N')
      ,i_Name_Prefix              VARCHAR(50)
      ,i_First_Name               VARCHAR(60)
      ,i_Middle_Name              VARCHAR(50)
      ,i_Last_Name                VARCHAR(70)
      ,i_Name_Suffix              VARCHAR(20)
      ,i_gender                   VARCHAR(50)
      ,i_birth_date               VARCHAR(50)
      ,i_actual_SSN               VARCHAR(50)
      ,i_Hipaa_Id                 VARCHAR(20)
      ,i_national_producer_number VARCHAR(50)
      ,i_Email_Address            VARCHAR(20)
      ,i_Phone_Number             VARCHAR(50)
      ,i_Extension                VARCHAR(100)
      ,i_Other_Phone_Number       VARCHAR(50)
      ,i_Fax_Number               VARCHAR(50)
      ,i_Salutation_Name          VARCHAR(20)
      ,i_Address_Type             VARCHAR(50)
      ,i_Address_1                VARCHAR(85)
      ,i_Address_2                VARCHAR(55)
      ,i_Zip_Code                 VARCHAR(50)
      ,i_City                     VARCHAR(50)
      ,i_State                    VARCHAR(50)
      ,i_county                   VARCHAR(50)
      ,i_Country                  VARCHAR(50)
      ,i_Marital_Status           VARCHAR(50)
      ,i_Employer_Name            VARCHAR(50)
      ,i_Employer_Phone_Number    VARCHAR(50)
      ,i_Business_Name            VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(255)
      ,record_id                  INT
      ,static_gid                 INT)

IF OBJECT_ID('tempdb.dbo.#Addresses') IS NOT NULL
	DROP TABLE #Addresses

CREATE TABLE #Addresses
      (address1			VARCHAR(200)
	  ,address2			VARCHAR(200)
	  ,zip				VARCHAR(200)
      ,city  			VARCHAR(200)
      ,state  			VARCHAR(200) 
	  ,county			VARCHAR(200)
      ,country 			VARCHAR(200) 
      ,status  			INT
      ,message			VARCHAR(200))   

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Contacts
      (i_Name_Prefix
      ,i_First_Name
      ,i_Middle_Name
      ,i_Last_Name
      ,i_Name_Suffix
      ,i_gender
      ,i_birth_date
      ,i_actual_SSN
      ,i_Hipaa_Id
      ,i_national_producer_number
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
      ,i_Marital_Status
      ,i_Employer_Name
      ,i_Employer_Phone_Number
      ,i_Business_Name
      ,record_id
      ,static_gid)
SELECT ISNULL(dbo.fnDCAuto_GetDropdownValue([Prefix]), '')
      ,ISNULL([FirstName], '')
      ,ISNULL([MiddleName], '')
      ,ISNULL([*LastName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Suffix]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Gender]), 'U')
      ,ISNULL([BirthDate], '00/00/0000')
      ,ISNULL([ActualSSN], '000000000')
      ,ISNULL([HIPAAID], '')
      ,ISNULL([NationalProducerNumber], '000000000')
      ,ISNULL([EmailAddress], '')
      ,ISNULL([*PhoneNumber], '0000000000')
      ,ISNULL([Extension], '')
      ,ISNULL([OtherPhoneNumber], '0000000000')
      ,ISNULL([FaxPhoneNumber], '0000000000')
      ,ISNULL([Salutations], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AddressPurpose]), 'M')
      ,ISNULL([*AddrLine1], '')
      ,ISNULL([AddrLine2], '')
      ,ISNULL([*ZipCode], '')
      ,ISNULL([*City], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*State]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Country]), 'US')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MaritalStatus]), '')
      ,ISNULL(REPLACE([EmployerName], '<key>TAB', ''), '')
      ,ISNULL([EmployerPhone], '0000000000')
      ,ISNULL([BusinessName], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Contacts
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Contacts
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Contacts_Cursor CURSOR FOR
 SELECT i_entity_name
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
       ,i_Date_Time_Modified
       ,iUserID
       ,i_Contact_ID
       ,i_Name_Prefix
       ,i_First_Name
       ,i_Middle_Name
       ,i_Last_Name
       ,i_Name_Suffix
       ,i_gender
       ,i_birth_date
       ,i_actual_SSN
       ,i_Hipaa_Id
       ,i_national_producer_number
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
       ,i_county
       ,i_Country
       ,i_Marital_Status
       ,i_Employer_Name
       ,i_Employer_Phone_Number
       ,i_Business_Name
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Contacts

   OPEN Contacts_Cursor
  FETCH NEXT FROM Contacts_Cursor
   INTO @i_entity_name
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
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_Contact_ID
       ,@i_Name_Prefix
       ,@i_First_Name
       ,@i_Middle_Name
       ,@i_Last_Name
       ,@i_Name_Suffix
       ,@i_gender
       ,@i_birth_date
       ,@i_actual_SSN
       ,@i_Hipaa_Id
       ,@i_national_producer_number
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
       ,@i_county
       ,@i_Country
       ,@i_Marital_Status
       ,@i_Employer_Name
       ,@i_Employer_Phone_Number
       ,@i_Business_Name
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Get any missing pieces of the address that would normally be populated in the UI, if needed
		TRUNCATE TABLE #Addresses
		IF @i_Contact_ID != ''
			BEGIN

				INSERT INTO #Addresses
					EXEC prContactPopulateTabOff 'Address', 'N', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', @i_Address_1, @i_Address_2, @i_Zip_Code, @i_City, @i_State, @i_county, @i_Country, 
					                            '', '', '', '', 'ADD', 0, 0, ''

				SELECT TOP 1
					   @i_Address_1			= C.address1
					  ,@i_Address_2			= C.address2
					  ,@i_Zip_Code			= C.zip
					  ,@i_City				= C.city
				  	  ,@i_State				= C.state
					  ,@i_county			= C.county
					  ,@i_Country			= C.country
				  FROM #Addresses			C

			END
			

		EXEC dbo.prContactAddModify
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
            ,@i_Date_Time_Modified
            ,@iUserID
            ,@i_Contact_ID
            ,@i_Name_Prefix
            ,@i_First_Name
            ,@i_Middle_Name
            ,@i_Last_Name
            ,@i_Name_Suffix
            ,@i_gender
            ,@i_birth_date
            ,@i_actual_SSN
            ,@i_Hipaa_Id
            ,@i_national_producer_number
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
            ,@i_county
            ,@i_Country
            ,@i_Marital_Status
            ,@i_Employer_Name
            ,@i_Employer_Phone_Number
            ,@i_Business_Name
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the Contact GID
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Get the current contact gid
				SELECT @current_gid				= C.contact_gid
				  FROM dbo.Contacts				C
				 WHERE record_status			= 'A'
				   AND C.last_name				= @i_Last_Name
				   AND first_name				= @i_First_Name
				   AND C.actual_ssn				= @i_actual_SSN

				-- Update to the static gid
				UPDATE dbo.Contacts 
				   SET contact_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND contact_gid				= @current_gid

				UPDATE dbo.Contact_Relation 
				   SET contact_gid				= @static_gid 
					  ,contact_relation_gid		= @static_gid
				 WHERE record_status			= 'A'
				   AND contact_gid				= @current_gid

				-- Get the current demographic gid
				SELECT @current_gid				= CR.demographic_gid
				  FROM dbo.Contact_Relation		CR
				 WHERE CR.contact_gid			= @static_gid

				-- Update the demographic_gid
				UPDATE dbo.Demographics 
				   SET demographic_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND demographic_gid			= @current_gid

				UPDATE dbo.Contact_Relation
				   SET demographic_gid			= @static_gid
				 WHERE demographic_gid			= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_First_Name, @i_Last_Name, @i_actual_SSN, @status, @err_num, @err_msg

        FETCH NEXT FROM Contacts_Cursor
         INTO @i_entity_name
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
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_Contact_ID
             ,@i_Name_Prefix
             ,@i_First_Name
             ,@i_Middle_Name
             ,@i_Last_Name
             ,@i_Name_Suffix
             ,@i_gender
             ,@i_birth_date
             ,@i_actual_SSN
             ,@i_Hipaa_Id
             ,@i_national_producer_number
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
             ,@i_county
             ,@i_Country
             ,@i_Marital_Status
             ,@i_Employer_Name
             ,@i_Employer_Phone_Number
             ,@i_Business_Name
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Contacts_Cursor
DEALLOCATE Contacts_Cursor

END
GO