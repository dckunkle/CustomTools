IF OBJECT_ID('dbo.spDCAuto_CreateBrokerContact') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBrokerContact AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBrokerContact
Purpose:    Create brokercontact data from CorderAutomation

Screen:     275
Method:     BrokerContact
Procedure:  dbo.prBRBHContactAdd
Entity:     BROKER_CONTACT

Date        User            Change
---------------------------------------------------------------------------------------------
02/11/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBrokerContact '100-Config%', 22, 'BrokerContact'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBrokerContact
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

DECLARE @i_entity_name        VARCHAR(20)
       ,@i_entity_gid         VARCHAR(20)
       ,@i_key_2_Gid          VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
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
       ,@i_contact_purpose    VARCHAR(20)
       ,@i_Contact_ID         VARCHAR(50)
       ,@i_Name_Prefix        VARCHAR(50)
       ,@i_First_Name         VARCHAR(50)
       ,@i_Middle_Name        VARCHAR(50)
       ,@i_Last_Name          VARCHAR(100)
       ,@i_Name_Suffix        VARCHAR(100)
       ,@i_business_name      VARCHAR(50)
       ,@i_gender             VARCHAR(50)
       ,@i_birth_date         VARCHAR(10)
       ,@i_actual_SSN         VARCHAR(50)
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
IF OBJECT_ID('tempdb.dbo.#BrokerContact') IS NOT NULL
	DROP TABLE #BrokerContact

CREATE TABLE #BrokerContact
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(20)       DEFAULT('BROKER_CONTACT')
      ,i_entity_gid         VARCHAR(20)       DEFAULT('0')
      ,i_key_2_Gid          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
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
      ,i_contact_purpose    VARCHAR(20)
      ,i_Contact_ID         VARCHAR(50)
      ,i_Name_Prefix        VARCHAR(50)
      ,i_First_Name         VARCHAR(50)
      ,i_Middle_Name        VARCHAR(50)
      ,i_Last_Name          VARCHAR(100)
      ,i_Name_Suffix        VARCHAR(100)
      ,i_business_name      VARCHAR(50)
      ,i_gender             VARCHAR(50)
      ,i_birth_date         VARCHAR(10)
      ,i_actual_SSN         VARCHAR(50)
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

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BrokerContact
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
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Prefix]), '')
          ,ISNULL([Email], '')
          ,ISNULL([PhoneNumber], '0000000000')
          ,ISNULL([Extension], '')
          ,ISNULL([OtherPhone], '0000000000')
          ,ISNULL([FaxPhone], '0000000000')
          ,ISNULL([Salutation], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AddressPurpose]), 'M')
          ,ISNULL([*AddressLine1], '')
          ,ISNULL([AddressLine2], '')
          ,ISNULL([ZipCode], '')
          ,ISNULL([City], '')
          ,ISNULL([State], 'UT')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Country]), '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BrokerContact
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BrokerContact
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
DECLARE BrokerContact_Cursor CURSOR FOR
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
   FROM #BrokerContact

   OPEN BrokerContact_Cursor
  FETCH NEXT FROM BrokerContact_Cursor
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

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @i_entity_gid		= ISNULL(CR.contact_relation_gid, 0)
			  FROM dbo.Contact_Relation	CR
			 WHERE CR.record_status		= 'A'
			   AND CR.misc_1			= @SearchID

			IF @i_entity_gid = 0 BEGIN SELECT @err_num = 100, @err_msg = 'The broker ID provided in the SearchID field could not be found.' GOTO LOG_ERROR END

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

		LOG_ERROR:
		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Contact_ID, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BrokerContact_Cursor
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

CLOSE BrokerContact_Cursor
DEALLOCATE BrokerContact_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BrokerContact') IS NOT NULL
	DROP TABLE #BrokerContact

END
GO

