IF OBJECT_ID('dbo.spDCAuto_CreateProvidersHospitalAccreditation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProvidersHospitalAccreditation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProvidersHospitalAccreditation
Purpose:    Create providershospitalaccreditation data from CorderAutomation
Method:     ProvidersHospitalAccreditation
Screen GID: 11004
Procedure:  dbo.prHospitalAccreditationAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProvidersHospitalAccreditation '100-Config%', 22, 'ProvidersHospitalAccreditation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProvidersHospitalAccreditation
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

DECLARE @i_entity_name         VARCHAR(50)
       ,@i_key_1_field         VARCHAR(50)
       ,@i_key_2_field         VARCHAR(50)
       ,@i_key_3_field         VARCHAR(50)
       ,@i_key_4_field         VARCHAR(50)
       ,@i_key_5_field         VARCHAR(50)
       ,@i_key_6_field         VARCHAR(100)
       ,@i_key_7_field         VARCHAR(50)
       ,@i_key_8_field         VARCHAR(50)
       ,@i_key_9_field         VARCHAR(50)
       ,@i_key_10_field        VARCHAR(50)
       ,@i_action              VARCHAR(10)
       ,@i_date_time_modified  VARCHAR(50)
       ,@i_userID              VARCHAR(25)
       ,@i_Type                VARCHAR(50)
       ,@i_accreditationTitle  VARCHAR(255)
       ,@i_organizationName    VARCHAR(255)
       ,@i_accreditationStatus VARCHAR(50)
       ,@i_effectiveDate       DATETIME
       ,@i_WebsiteURL          VARCHAR(255)
       ,@o_status              INT
       ,@o_message             VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProvidersHospitalAccreditation') IS NOT NULL
	DROP TABLE #ProvidersHospitalAccreditation

CREATE TABLE #ProvidersHospitalAccreditation
      (SearchID              VARCHAR(200)
      ,i_entity_name         VARCHAR(50)       DEFAULT('HospitalAccreditation')
      ,i_key_1_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified  VARCHAR(50)       DEFAULT('')
      ,i_userID              VARCHAR(25)       DEFAULT('')
      ,i_Type                VARCHAR(50)
      ,i_accreditationTitle  VARCHAR(255)
      ,i_organizationName    VARCHAR(255)
      ,i_accreditationStatus VARCHAR(50)
      ,i_effectiveDate       DATETIME
      ,i_WebsiteURL          VARCHAR(255)
      ,o_status              INT
      ,o_message             VARCHAR(255)
      ,record_id             INT
      ,static_gid            INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ProvidersHospitalAccreditation
      (SearchID
      ,i_Type
      ,i_accreditationTitle
      ,i_organizationName
      ,i_accreditationStatus
      ,i_effectiveDate
      ,i_WebsiteURL
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Type]), 'A')
      ,ISNULL([AccreditationTitle], '')
      ,ISNULL([OrganizationName], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AccreditationStatus]), 'A')
      ,ISNULL([AccreditationDate], '01/01/1900')
      ,ISNULL([OrganizationURL], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ProviderHospitalAcc
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ProvidersHospitalAccreditation
   SET i_userID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ProvidersHospitalAccreditation_Cursor CURSOR FOR
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
       ,i_userID
       ,i_Type
       ,i_accreditationTitle
       ,i_organizationName
       ,i_accreditationStatus
       ,i_effectiveDate
       ,i_WebsiteURL
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #ProvidersHospitalAccreditation

   OPEN ProvidersHospitalAccreditation_Cursor
  FETCH NEXT FROM ProvidersHospitalAccreditation_Cursor
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
       ,@i_userID
       ,@i_Type
       ,@i_accreditationTitle
       ,@i_organizationName
       ,@i_accreditationStatus
       ,@i_effectiveDate
       ,@i_WebsiteURL
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the Provider ID 
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			-- Find the provider's gid
			SELECT @i_key_1_field		= P.provider_gid
			  FROM Provider				P
			 WHERE P.record_status		= 'A'
			   AND P.provider_id		= @SearchID

			EXEC dbo.prHospitalAccreditationAddModify
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
            ,@i_userID
            ,@i_Type
            ,@i_accreditationTitle
            ,@i_organizationName
            ,@i_accreditationStatus
            ,@i_effectiveDate
            ,@i_WebsiteURL
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Type, @i_accreditationTitle, @status, @err_num, @err_msg

        FETCH NEXT FROM ProvidersHospitalAccreditation_Cursor
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
             ,@i_userID
             ,@i_Type
             ,@i_accreditationTitle
             ,@i_organizationName
             ,@i_accreditationStatus
             ,@i_effectiveDate
             ,@i_WebsiteURL
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE ProvidersHospitalAccreditation_Cursor
DEALLOCATE ProvidersHospitalAccreditation_Cursor

END
GO