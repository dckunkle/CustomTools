IF OBJECT_ID('dbo.spDCAuto_CreateBusinessUnitsLicensesCertificates') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBusinessUnitsLicensesCertificates AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnitsLicensesCertificates
Purpose:    Create businessunitslicensescertificates data from CorderAutomation

Screen:     202
Method:     BusinessUnitsLicensesCertificates
Procedure:  dbo.prBULicense_AddModify
Entity:     License_Relation

Date        User            Change
---------------------------------------------------------------------------------------------
12/21/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnitsLicensesCertificates '500-Config%', 22, '500-Config', 'BusinessUnitsLicensesCertificates', '500autoconfig'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnitsLicensesCertificates
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

DECLARE @i_Entity_name       VARCHAR(50)
       ,@i_entity_gid        VARCHAR(75)
       ,@i_entity_type       VARCHAR(75)
       ,@i_record_sid        VARCHAR(75)
       ,@i_key_4_field       VARCHAR(50)
       ,@i_key_5_field       VARCHAR(50)
       ,@i_key_6_field       VARCHAR(50)
       ,@i_key_7_field       VARCHAR(50)
       ,@i_key_8_field       VARCHAR(50)
       ,@i_key_9_field       VARCHAR(50)
       ,@i_key_10_field      VARCHAR(50)
       ,@i_action            VARCHAR(10)
       ,@l_modified_date     VARCHAR(30)
       ,@iUserID             VARCHAR(25)
       ,@i_license_id        VARCHAR(50)
       ,@i_license_type      VARCHAR(50)
       ,@i_license_date      VARCHAR(50)
       ,@i_license_term_date VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnitsLicensesCertificates') IS NOT NULL
	DROP TABLE #BusinessUnitsLicensesCertificates

CREATE TABLE #BusinessUnitsLicensesCertificates
      (SearchID            VARCHAR(200)
      ,i_Entity_name       VARCHAR(50)       DEFAULT('License_Relation')
      ,i_entity_gid        VARCHAR(75)       DEFAULT('0')
      ,i_entity_type       VARCHAR(75)       DEFAULT('0')
      ,i_record_sid        VARCHAR(75)       DEFAULT('0')
      ,i_key_4_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field      VARCHAR(50)       DEFAULT('0')
      ,i_action            VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date     VARCHAR(30)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,i_license_id        VARCHAR(50)
      ,i_license_type      VARCHAR(50)
      ,i_license_date      VARCHAR(50)
      ,i_license_term_date VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(100)
      ,record_id           INT
      ,static_gid          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BusinessUnitsLicensesCertificates
          (SearchID
          ,i_license_id
          ,i_license_type
          ,i_license_date
          ,i_license_term_date
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*LicenseNumber],'')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LicenseType]), 'GM')
          ,ISNULL([OriginalDateOfIssue], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([ExpirationDate], '12/31/9999')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnitLicensesCertificates
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BusinessUnitsLicensesCertificates
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
DECLARE BusinessUnitsLicensesCertificates_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_entity_gid
       ,i_entity_type
       ,i_record_sid
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_license_id
       ,i_license_type
       ,i_license_date
       ,i_license_term_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BusinessUnitsLicensesCertificates

   OPEN BusinessUnitsLicensesCertificates_Cursor
  FETCH NEXT FROM BusinessUnitsLicensesCertificates_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_entity_gid
       ,@i_entity_type
       ,@i_record_sid
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_license_id
       ,@i_license_type
       ,@i_license_date
       ,@i_license_term_date
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

			SELECT @i_entity_gid		= BU.business_gid
			  FROM dbo.Business_Units	BU
			 WHERE BU.business_unit_id	= @SearchID
			   AND BU.record_status		= 'A'

			EXEC dbo.prBULicense_AddModify
                 @i_Entity_name
                ,@i_entity_gid
                ,@i_entity_type
                ,@i_record_sid
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@l_modified_date
                ,@iUserID
                ,@i_license_id
                ,@i_license_type
                ,@i_license_date
                ,@i_license_term_date
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_license_id, @i_license_type, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BusinessUnitsLicensesCertificates_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_entity_gid
             ,@i_entity_type
             ,@i_record_sid
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_license_id
             ,@i_license_type
             ,@i_license_date
             ,@i_license_term_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnitsLicensesCertificates_Cursor
DEALLOCATE BusinessUnitsLicensesCertificates_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BusinessUnitsLicensesCertificates') IS NOT NULL
	DROP TABLE #BusinessUnitsLicensesCertificates

END
GO

