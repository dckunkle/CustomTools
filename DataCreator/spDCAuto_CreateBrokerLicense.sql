IF OBJECT_ID('dbo.spDCAuto_CreateBrokerLicense') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBrokerLicense AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBrokerLicense
Purpose:    Create brokerlicense data from CorderAutomation

Screen:     869
Method:     BrokerLicense
Procedure:  dbo.prLicenseAddModify 
Entity:     Broker_License

Date        User            Change
---------------------------------------------------------------------------------------------
02/03/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBrokerLicense '400-Config%', 22, '400-Config', 'BrokerLicense', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBrokerLicense
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

DECLARE @i_entity_name            VARCHAR(50)
       ,@i_entity_gid             INT
       ,@i_License_gid            VARCHAR(50)
       ,@i_parent_identifier      VARCHAR(100)
       ,@i_key_4_field            VARCHAR(10)
       ,@i_key_5_field            VARCHAR(10)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(100)
       ,@i_key_8_field            VARCHAR(100)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(100)
       ,@i_action                 VARCHAR(10)
       ,@i_date_time_modified     VARCHAR(100)
       ,@i_UserID                 VARCHAR(25)
       ,@i_Agency_Id              VARCHAR(50)
       ,@i_Agency_Name            VARCHAR(50)
       ,@i_License_State          VARCHAR(50)
       ,@i_License_ID             VARCHAR(50)
       ,@i_eff_date               VARCHAR(50)
       ,@i_term_date              VARCHAR(50)
       ,@i_License_Status         VARCHAR(50)
       ,@i_Term_Reason            VARCHAR(50)
       ,@i_lob_grouper_id         VARCHAR(50)
       ,@i_lob_grouper_desc       VARCHAR(100)
       ,@i_custom_lob             VARCHAR(50)
       ,@i_carrier_code           VARCHAR(50)
       ,@i_insurance_carrier_desc VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BrokerLicense') IS NOT NULL
	DROP TABLE #BrokerLicense

CREATE TABLE #BrokerLicense
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(50)       DEFAULT('Broker_License')
      ,i_entity_gid             INT				  DEFAULT('0')
      ,i_License_gid            VARCHAR(50)       DEFAULT('0')
      ,i_parent_identifier      VARCHAR(100)      DEFAULT('Broker')
      ,i_key_4_field            VARCHAR(10)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(10)       DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(100)      DEFAULT('0')
      ,i_key_8_field            VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(100)      DEFAULT('0')
      ,i_action                 VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(100)      DEFAULT('')
      ,i_UserID                 VARCHAR(25)       DEFAULT('')
      ,i_Agency_Id              VARCHAR(50)
      ,i_Agency_Name            VARCHAR(50)
      ,i_License_State          VARCHAR(50)
      ,i_License_ID             VARCHAR(50)
      ,i_eff_date               VARCHAR(50)
      ,i_term_date              VARCHAR(50)
      ,i_License_Status         VARCHAR(50)
      ,i_Term_Reason            VARCHAR(50)
      ,i_lob_grouper_id         VARCHAR(50)
      ,i_lob_grouper_desc       VARCHAR(100)
      ,i_custom_lob             VARCHAR(50)
      ,i_carrier_code           VARCHAR(50)
      ,i_insurance_carrier_desc VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BrokerLicense
          (SearchID
          ,i_License_State
          ,i_License_ID
          ,i_eff_date
          ,i_term_date
          ,i_License_Status
          ,i_Term_Reason
          ,i_lob_grouper_id
          ,i_custom_lob
          ,i_carrier_code
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*LicenseState], '')
          ,ISNULL([*LicenseID], '')
          ,ISNULL([*LicenseEffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*LicenseTermDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LicenseStatus]), 'A')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TerminationReason]), '')
          ,ISNULL([LOBGrouperID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '*')
          ,ISNULL([InsuranceCarrierID], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BrokerLicense
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BrokerLicense
       SET i_UserID  = @user

	   SELECT * FROM #BrokerLicense
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
DECLARE BrokerLicense_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_entity_gid
       ,i_License_gid
       ,i_parent_identifier
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
       ,i_Agency_Id
       ,i_Agency_Name
       ,i_License_State
       ,i_License_ID
       ,i_eff_date
       ,i_term_date
       ,i_License_Status
       ,i_Term_Reason
       ,i_lob_grouper_id
       ,i_lob_grouper_desc
       ,i_custom_lob
       ,i_carrier_code
       ,i_insurance_carrier_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BrokerLicense

   OPEN BrokerLicense_Cursor
  FETCH NEXT FROM BrokerLicense_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_entity_gid
       ,@i_License_gid
       ,@i_parent_identifier
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
       ,@i_Agency_Id
       ,@i_Agency_Name
       ,@i_License_State
       ,@i_License_ID
       ,@i_eff_date
       ,@i_term_date
       ,@i_License_Status
       ,@i_Term_Reason
       ,@i_lob_grouper_id
       ,@i_lob_grouper_desc
       ,@i_custom_lob
       ,@i_carrier_code
       ,@i_insurance_carrier_desc
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

			SELECT @i_entity_gid			= CR.entity_gid
			      ,@i_key_4_field			= CR.contact_relation_gid
			  FROM dbo.Contact_Relation		CR
			 WHERE record_status			= 'A'
			   AND misc_1					= @SearchID
			   AND entity_identifier		= 'BROKER'

			EXEC dbo.prLicenseAddModify 
                 @i_entity_name
                ,@i_entity_gid
                ,@i_License_gid
                ,@i_parent_identifier
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
                ,@i_Agency_Id
                ,@i_Agency_Name
                ,@i_License_State
                ,@i_License_ID
                ,@i_eff_date
                ,@i_term_date
                ,@i_License_Status
                ,@i_Term_Reason
                ,@i_lob_grouper_id
                ,@i_lob_grouper_desc
                ,@i_custom_lob
                ,@i_carrier_code
                ,@i_insurance_carrier_desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Broker_License 
				   SET License_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_gid				= @i_entity_gid
				   AND license_id				= @i_License_ID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_License_State, @i_License_ID, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BrokerLicense_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_entity_gid
             ,@i_License_gid
             ,@i_parent_identifier
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
             ,@i_Agency_Id
             ,@i_Agency_Name
             ,@i_License_State
             ,@i_License_ID
             ,@i_eff_date
             ,@i_term_date
             ,@i_License_Status
             ,@i_Term_Reason
             ,@i_lob_grouper_id
             ,@i_lob_grouper_desc
             ,@i_custom_lob
             ,@i_carrier_code
             ,@i_insurance_carrier_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BrokerLicense_Cursor
DEALLOCATE BrokerLicense_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BrokerLicense') IS NOT NULL
	DROP TABLE #BrokerLicense

END
GO

