IF OBJECT_ID('dbo.spDCAuto_CreateClaimAuthorizations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateClaimAuthorizations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateClaimAuthorizations
Purpose:    Create claimauthorizations data from CorderAutomation

Screen:     900
Method:     ClaimAuthorizations
Procedure:  dbo.prAuthAddModify 
Entity:     AUTH

Date        User            Change
---------------------------------------------------------------------------------------------
02/07/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateClaimAuthorizations 'Kraken-CONFIG-20%', 22, 'Kraken-Config', 'ClaimAuthorizations', 'KrakenConfig2001'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateClaimAuthorizations
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

	   ,@business_unit_id			VARCHAR(100)
	   ,@business_gid				INT

	   ,@location_id				VARCHAR(100)
	   ,@location_gid				INT

	   ,@provider_gid				INT
	   ,@service_location_sid		INT
	   ,@full_name					VARCHAR(200)
	   ,@first_name					VARCHAR(100)
	   ,@last_name					VARCHAR(100)
	   ,@birth_date					VARCHAR(20)

	   ,@pos_code					VARCHAR(50)
	   ,@pos_desc					VARCHAR(50)
	   ,@diag_type					VARCHAR(50)

	   ,@V0							VARCHAR(50)
	   ,@V1							VARCHAR(50)
	   ,@V2							VARCHAR(50)
	   ,@V3							VARCHAR(50)
	   ,@V4							VARCHAR(50)
	   ,@V5							VARCHAR(50)
	   ,@V6							VARCHAR(50)
	   ,@V7							VARCHAR(50)
	   ,@V8							VARCHAR(50)
	   ,@V9							VARCHAR(50)
	   ,@V10						VARCHAR(50)
	   ,@V11						VARCHAR(50)
	   ,@V12						VARCHAR(50)
	   ,@V13						VARCHAR(50)
	   ,@V14						VARCHAR(50)

	   ,@xml						VARCHAR(4000)
	   ,@medical_count				INT

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntity                 VARCHAR(50)
       ,@iAuthGID                VARCHAR(50)
       ,@iKeyField2              VARCHAR(50)
       ,@iKeyField3              VARCHAR(50)
       ,@iKeyField4              VARCHAR(50)
       ,@iKeyField5              VARCHAR(50)
       ,@iKeyField6              VARCHAR(50)
       ,@iKeyField7              VARCHAR(50)
       ,@iKeyField8              VARCHAR(50)
       ,@iKeyField9              VARCHAR(50)
       ,@iKeyField10             VARCHAR(50)
       ,@iAction                 VARCHAR(10)
       ,@iDateModified           VARCHAR(50)
       ,@iUserID                 VARCHAR(25)
       ,@iMember_ID              VARCHAR(50)
       ,@iMember_Info            VARCHAR(200)
       ,@iRendering_Physician_ID VARCHAR(50)
       ,@iRendering_Info         VARCHAR(50)
       ,@iRendering_Location_ID  VARCHAR(200)
       ,@iReferring_Physician_ID VARCHAR(50)
       ,@iReferring_Info         VARCHAR(50)
       ,@iFacility_ID            VARCHAR(50)
       ,@iFacility_Info          VARCHAR(50)
       ,@iAdmitting_Physician_ID VARCHAR(50)
       ,@iAdmitting_Info         VARCHAR(50)
       ,@iAssisting_Physician_ID VARCHAR(50)
       ,@iAssisting_Info         VARCHAR(50)
       ,@iOther_Physician_ID     VARCHAR(50)
       ,@iOther_Info             VARCHAR(50)
       ,@iAnesthesia_Flag        VARCHAR(50)
       ,@iAuth_Number            VARCHAR(50)
       ,@iDate_Requested         VARCHAR(50)
       ,@iAuth_Status            VARCHAR(50)
       ,@iDate_Submitted         VARCHAR(50)
       ,@iAuthType               VARCHAR(50)
       ,@iNotes                  VARCHAR(500)
       ,@iStatus_Start_Date      VARCHAR(50)
       ,@iStatus_End_Date        VARCHAR(50)
       ,@iExpedited_Flag         VARCHAR(50)
       ,@iAuth_Extension_Flag    VARCHAR(50)
       ,@iService_Term_Date      VARCHAR(50)
       ,@iRequest_Method         VARCHAR(50)
       ,@iAppeal_Exists          VARCHAR(50)
       ,@iPay_as_In_Network      VARCHAR(50)
       ,@iServiceInfo            VARCHAR(4000)
       ,@iAppends                VARCHAR(50)
       ,@iAppeal_Status          VARCHAR(50)
       ,@iExternal_Audit         VARCHAR(50)
       ,@iAppeal_Start_Date      VARCHAR(50)
       ,@iAppeal_End_Date        VARCHAR(50)
       ,@iAppeal_Notes           VARCHAR(500)
       ,@oStatus                 INT
       ,@oMessage                VARCHAR(250)
       ,@return_xml              XML
	   ,@TCID					 VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ClaimAuthorizations') IS NOT NULL
	DROP TABLE #ClaimAuthorizations

CREATE TABLE #ClaimAuthorizations
      (SearchID                VARCHAR(200)
      ,iEntity                 VARCHAR(50)       DEFAULT('AUTH')
      ,iAuthGID                VARCHAR(50)       DEFAULT('0')
      ,iKeyField2              VARCHAR(50)       DEFAULT('0')
      ,iKeyField3              VARCHAR(50)       DEFAULT('0')
      ,iKeyField4              VARCHAR(50)       DEFAULT('0')
      ,iKeyField5              VARCHAR(50)       DEFAULT('0')
      ,iKeyField6              VARCHAR(50)       DEFAULT('0')
      ,iKeyField7              VARCHAR(50)       DEFAULT('0')
      ,iKeyField8              VARCHAR(50)       DEFAULT('0')
      ,iKeyField9              VARCHAR(50)       DEFAULT('0')
      ,iKeyField10             VARCHAR(50)       DEFAULT('0')
      ,iAction                 VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified           VARCHAR(50)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,iMember_ID              VARCHAR(50)
      ,iMember_Info            VARCHAR(200)
      ,iRendering_Physician_ID VARCHAR(50)
      ,iRendering_Info         VARCHAR(50)
      ,iRendering_Location_ID  VARCHAR(200)
      ,iReferring_Physician_ID VARCHAR(50)
      ,iReferring_Info         VARCHAR(50)
      ,iFacility_ID            VARCHAR(50)
      ,iFacility_Info          VARCHAR(50)
      ,iAdmitting_Physician_ID VARCHAR(50)
      ,iAdmitting_Info         VARCHAR(50)
      ,iAssisting_Physician_ID VARCHAR(50)
      ,iAssisting_Info         VARCHAR(50)
      ,iOther_Physician_ID     VARCHAR(50)
      ,iOther_Info             VARCHAR(50)
      ,iAnesthesia_Flag        VARCHAR(50)
      ,iAuth_Number            VARCHAR(50)
      ,iDate_Requested         VARCHAR(50)
      ,iAuth_Status            VARCHAR(50)
      ,iDate_Submitted         VARCHAR(50)
      ,iAuthType               VARCHAR(50)
      ,iNotes                  VARCHAR(500)
      ,iStatus_Start_Date      VARCHAR(50)
      ,iStatus_End_Date        VARCHAR(50)
      ,iExpedited_Flag         VARCHAR(50)
      ,iAuth_Extension_Flag    VARCHAR(50)
      ,iService_Term_Date      VARCHAR(50)
      ,iRequest_Method         VARCHAR(50)
      ,iAppeal_Exists          VARCHAR(50)
      ,iPay_as_In_Network      VARCHAR(50)
      ,iServiceInfo            VARCHAR(4000)
      ,iAppends                VARCHAR(50)
      ,iAppeal_Status          VARCHAR(50)
      ,iExternal_Audit         VARCHAR(50)
      ,iAppeal_Start_Date      VARCHAR(50)
      ,iAppeal_End_Date        VARCHAR(50)
      ,iAppeal_Notes           VARCHAR(500)
      ,oStatus                 INT
      ,oMessage                VARCHAR(250)
      ,return_xml              XML
      ,record_id               INT
      ,static_gid              INT
	  ,TCID					   VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

IF OBJECT_ID('tempdb.dbo.#MedicalAuthorizations') IS NOT NULL
	DROP TABLE #MedicalAuthorizations

CREATE TABLE #MedicalAuthorizations
      (pos_code		VARCHAR(50)
	  ,pos_desc		VARCHAR(50)
	  ,diag_type	VARCHAR(50)
	  ,V0			VARCHAR(50)
	  ,V1			VARCHAR(50)
	  ,V2			VARCHAR(50)
	  ,V3			VARCHAR(50)
	  ,V4			VARCHAR(50)
	  ,V5			VARCHAR(50)
	  ,V6			VARCHAR(50)
	  ,V7			VARCHAR(50)
	  ,V8			VARCHAR(50)
	  ,V9			VARCHAR(50)
	  ,V10			VARCHAR(50)
	  ,V11			VARCHAR(50)
	  ,V12			VARCHAR(50)
	  ,V13			VARCHAR(50)
	  ,V14			VARCHAR(50)
	  ,TCID			VARCHAR(200))

IF OBJECT_ID('tempdb.dbo.#DentalAuthorizations') IS NOT NULL
	DROP TABLE #DentalAuthorizations

CREATE TABLE #DentalAuthorizations
      (pos_code		VARCHAR(50)
	  ,pos_desc		VARCHAR(50)
	  ,diag_type	VARCHAR(50)
	  ,V0			VARCHAR(50)
	  ,V1			VARCHAR(50)
	  ,V2			VARCHAR(50)
	  ,V3			VARCHAR(50)
	  ,V4			VARCHAR(50)
	  ,V5			VARCHAR(50)
	  ,V6			VARCHAR(50)
	  ,V7			VARCHAR(50)
	  ,V8			VARCHAR(50)
	  ,V9			VARCHAR(50)
	  ,V10			VARCHAR(50)
	  ,V11			VARCHAR(50)
	  ,V12			VARCHAR(50)
	  ,V13			VARCHAR(50)
	  ,V14			VARCHAR(50)
	  ,TCID			VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #ClaimAuthorizations
          (SearchID
          ,iMember_ID
          ,iMember_Info
		  ,iRendering_Physician_ID
		  ,iRendering_Location_ID
          ,iReferring_Physician_ID
          ,iFacility_ID
          ,iAdmitting_Physician_ID
          ,iAssisting_Physician_ID
          ,iOther_Physician_ID
		  ,iOther_Info
          ,iAnesthesia_Flag
          ,iAuth_Number
		  ,iDate_Requested
          ,iAuth_Status
          ,iDate_Submitted
          ,iAuthType
		  ,iNotes
          ,iStatus_Start_Date
          ,iStatus_End_Date
          ,iExpedited_Flag
          ,iAuth_Extension_Flag
          ,iService_Term_Date
          ,iRequest_Method
          ,iAppeal_Exists
          ,iPay_as_In_Network
          ,iServiceInfo
          ,iAppeal_Status
          ,iExternal_Audit
          ,iAppeal_Start_Date
          ,iAppeal_End_Date
          ,iAppeal_Notes
          ,record_id
          ,static_gid
		  ,TCID)
    SELECT SearchID
          ,ISNULL([*Common_MemberID], '')
          ,ISNULL([*Common_MemberInfo], '')
          ,ISNULL([*Common_RenderingPhysicianID], '')
          ,ISNULL([Common_RenderingLocation], '')
          ,ISNULL([Common_ReferringPhysicianID], '')
          ,ISNULL([Common_FacilityID], '')
          ,ISNULL([Common_AdmittingPhysicianID], '')
          ,ISNULL([Common_AssistingPhysicianID], '')
          ,ISNULL([Common_OtherPhysicianID], '')
          ,ISNULL([Common_OtherPhysicianName], '')
          ,ISNULL([Common_AnesthesiaIncluded], 'N/A')
          ,ISNULL([*Common_AuthNumber], '')
          ,ISNULL([*Common_DateRequested], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_AuthStatus]), 'A')
		  ,CONVERT(VARCHAR(10), GETDATE(), 101)
          ,ISNULL([Common_AuthType], '')
          ,ISNULL([Common_Notes], '')
          ,ISNULL([*Common_StatusStartDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*Common_StatusEndDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ExpeditedFlag]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AuthExtensionFlag]), 'N')
          ,ISNULL([Common_ServiceTerminationDate], '12/31/999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_RequestedMethod]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_AppealExists]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SysOverridePayAsInNW]), '')
          ,ISNULL([Common_ServiceInfoButton], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Appeals_AuthAppealStatus]), '')
          ,ISNULL([Appeals_ExtAuditEntity], '')
          ,ISNULL([Appeals_AuthAppealStartDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([Appeals_AuthAppealEndDate], '12/31/9999')
          ,ISNULL([Appeals_Notes], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
		  ,ISNULL(TCID, '')
      FROM COREAUTO.CoreAutomation.dbo.TD_ClaimAuth
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #ClaimAuthorizations
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
DECLARE ClaimAuthorizations_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iAuthGID
       ,iKeyField2
       ,iKeyField3
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iMember_ID
       ,iMember_Info
       ,iRendering_Physician_ID
       ,iRendering_Info
       ,iRendering_Location_ID
       ,iReferring_Physician_ID
       ,iReferring_Info
       ,iFacility_ID
       ,iFacility_Info
       ,iAdmitting_Physician_ID
       ,iAdmitting_Info
       ,iAssisting_Physician_ID
       ,iAssisting_Info
       ,iOther_Physician_ID
       ,iOther_Info
       ,iAnesthesia_Flag
       ,iAuth_Number
       ,iDate_Requested
       ,iAuth_Status
       ,iDate_Submitted
       ,iAuthType
       ,iNotes
       ,iStatus_Start_Date
       ,iStatus_End_Date
       ,iExpedited_Flag
       ,iAuth_Extension_Flag
       ,iService_Term_Date
       ,iRequest_Method
       ,iAppeal_Exists
       ,iPay_as_In_Network
       ,iServiceInfo
       ,iAppends
       ,iAppeal_Status
       ,iExternal_Audit
       ,iAppeal_Start_Date
       ,iAppeal_End_Date
       ,iAppeal_Notes
       ,oStatus
       ,oMessage
       ,return_xml
       ,record_id
       ,static_gid
	   ,TCID
   FROM #ClaimAuthorizations

   OPEN ClaimAuthorizations_Cursor
  FETCH NEXT FROM ClaimAuthorizations_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iAuthGID
       ,@iKeyField2
       ,@iKeyField3
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iMember_ID
       ,@iMember_Info
       ,@iRendering_Physician_ID
       ,@iRendering_Info
       ,@iRendering_Location_ID
       ,@iReferring_Physician_ID
       ,@iReferring_Info
       ,@iFacility_ID
       ,@iFacility_Info
       ,@iAdmitting_Physician_ID
       ,@iAdmitting_Info
       ,@iAssisting_Physician_ID
       ,@iAssisting_Info
       ,@iOther_Physician_ID
       ,@iOther_Info
       ,@iAnesthesia_Flag
       ,@iAuth_Number
       ,@iDate_Requested
       ,@iAuth_Status
       ,@iDate_Submitted
       ,@iAuthType
       ,@iNotes
       ,@iStatus_Start_Date
       ,@iStatus_End_Date
       ,@iExpedited_Flag
       ,@iAuth_Extension_Flag
       ,@iService_Term_Date
       ,@iRequest_Method
       ,@iAppeal_Exists
       ,@iPay_as_In_Network
       ,@iServiceInfo
       ,@iAppends
       ,@iAppeal_Status
       ,@iExternal_Audit
       ,@iAppeal_Start_Date
       ,@iAppeal_End_Date
       ,@iAppeal_Notes
       ,@oStatus
       ,@oMessage
       ,@return_xml
       ,@record_id
       ,@static_gid
	   ,@TCID

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			--*************************************************************************************************
			-- Determine the gids for the service location, generate error is any are not found
			--*************************************************************************************************
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @business_unit_id		= token FROM #Tokens WHERE token_order = 1
			SELECT @location_id				= token FROM #Tokens WHERE token_order = 2

			SELECT @business_gid			= ISNULL(BU.business_gid, 0)
			  FROM dbo.Business_Units		BU
			 WHERE BU.business_unit_id		= @business_unit_id
			   AND BU.record_status			= 'A'

			SELECT @location_gid			= ISNULL(L.location_gid, 0)
			  FROM dbo.Locations			L
			 WHERE L.location_id			= @location_id
			   AND L.record_status			= 'A'

			SELECT @provider_gid			= ISNULL(P.provider_gid, 0)
			  FROM dbo.Provider				P
			 WHERE P.provider_id			= @iRendering_Physician_ID
			   AND P.record_status			= 'A'

			SELECT @service_location_sid	= ISNULL(PL.Provider_Link_sid, 0)
			  FROM dbo.Provider_Link		PL
			 WHERE PL.provider_gid			= @provider_gid
			   AND PL.business_gid			= @business_gid
			   AND PL.location_gid			= @location_gid
			   AND PL.record_status			= 'A'

			IF @business_gid = 0 BEGIN SELECT @err_num = 100, @err_msg = 'Could not determine the business_gid from the data in the SearchID field' GOTO LOG_ERROR END
			IF @location_gid = 0 BEGIN SELECT @err_num = 101, @err_msg = 'Could not determine the location_gid from the data in the SearchID field' GOTO LOG_ERROR END
			IF @provider_gid = 0 BEGIN SELECT @err_num = 102, @err_msg = 'Could not determine the provider_gid from the data in the Common_ReferringPhysicianID field' GOTO LOG_ERROR END
			IF @service_location_sid = 0 BEGIN SELECT @err_num = 103, @err_msg = 'Could not find a service location for the combination of provider ID, business unit ID and location ID' GOTO LOG_ERROR END

			SELECT @iRendering_Location_ID = CONVERT(VARCHAR(10), @provider_gid) + ':' + CONVERT(VARCHAR(10), @business_gid) + ':' + CONVERT(VARCHAR(10), @location_gid)

			--*************************************************************************************************
			-- Determine the gid for the member, log an error if no member can be found
			--*************************************************************************************************
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@iMember_Info, ', DOB: ')
			SELECT @full_name	= token FROM #Tokens WHERE token_order = 1
			SELECT @birth_date	= token FROM #Tokens WHERE token_order = 2
			SELECT @birth_date	= SUBSTRING(@birth_date, 7, 999)

			IF CHARINDEX(' ', @full_name) > 0 
				BEGIN 
					SELECT @first_name = SUBSTRING(@full_name, 1, CHARINDEX(' ', @full_name))
					SELECT @last_name = SUBSTRING(@full_name, CHARINDEX(' ', @full_name) + 1, 99999)
				END

			SELECT @iMember_Info			= ISNULL(EC.child_gid, 0)
			  FROM dbo.Eligibility_Coverage	EC
			  JOIN dbo.Contacts				C
			    ON EC.child_gid				= C.contact_gid
			 WHERE EC.record_status			= 'A'
			   AND C.record_status			= 'A'
			   AND EC.member_id				= @iMember_ID
			   AND C.birth_date				= @birth_date
			   AND C.first_name				= @first_name
			   AND C.last_name				= @last_name
			
			IF @iMember_Info = 0 BEGIN SELECT @err_num = 105, @err_msg = 'Could not determine the contact gid for the member based on the first name, last name, birth date and member ID' GOTO LOG_ERROR END

			--*************************************************************************************************
			-- Gather the medical authorization details and format them properly
			--*************************************************************************************************
			SELECT @TCID = @TCID + '%'
			SELECT @medical_count = 0


			TRUNCATE TABLE #MedicalAuthorizations

			INSERT INTO #MedicalAuthorizations
			      (pos_code
				  ,pos_desc
				  ,diag_type
				  ,V0
				  ,V1
				  ,V2
				  ,V3
				  ,V4
				  ,V5
				  ,V6
				  ,V7
				  ,V8
				  ,V9
				  ,V10
				  ,V11
				  ,V12
				  ,V13
				  ,V14
				  ,TCID)
			SELECT ISNULL([ClaimsAuthMedical_MedPOSID], '')
				  ,ISNULL([ClaimsAuthMedical_MedPOSIDDesc], '')
				  ,ISNULL([ClaimsAuthMedical_DiagType], '10')
				  ,ISNULL([ClaimsAuthMedical_StartDate], CONVERT(VARCHAR(10), GETDATE(), 101))
			      ,ISNULL([ClaimsAuthMedical_EndDate], CONVERT(VARCHAR(10), GETDATE(), 101))
			      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClaimsAuthMedical_Status]), '')
			      ,ISNULL([*ClaimsAuthMedical_CodeID], '')
			      ,ISNULL([ClaimsAuthMedical_Diagnosis], '')
			      ,ISNULL([ClaimsAuthMedical_Mod], '')
			      ,ISNULL([ClaimsAuthMedical_RequestedUnits], '')
			      ,ISNULL([ClaimsAuthMedical_ApprovedUnits], '')
				  ,ISNULL([ClaimsAuthMedical_UnitFee], '')
			      ,ISNULL([ClaimsAuthMedical_RemarkCode], '')
			      ,ISNULL([ClaimsAuthMedical_RemarkCode2], '')
			      ,ISNULL([ClaimsAuthMedical_RemarkCode3], '')
			      ,ISNULL([ClaimsAuthMedical_RemarkCode4], '')
			      ,ISNULL([ClaimsAuthMedical_UsedUnits], '')
				  ,ISNULL([ClaimsAuthMedical_FeePercentage], '')
				  ,TCID
			  FROM COREAUTO.CoreAutomation.dbo.TD_ClaimAuthMedical
			 WHERE TCID LIKE @TCID

			DECLARE MedicalAuthorizations_Cursor CURSOR FOR
			 SELECT pos_code, pos_desc, diag_type, V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14
			   FROM #MedicalAuthorizations
			  ORDER BY TCID

			  OPEN MedicalAuthorizations_Cursor
			 FETCH NEXT FROM MedicalAuthorizations_Cursor
			  INTO @pos_code, @pos_desc, @diag_type, @V0, @V1, @V2, @V3, @V4, @V5, @V6, @V7, @V8, @V9, @V10, @V11, @V12, @V13, @V14

			WHILE @@FETCH_STATUS = 0
				BEGIN

					IF @medical_count = 0
						BEGIN
							SELECT @xml = '<SData><Data type=''MEDICAL'' pos_code=''' + @pos_code + ''' pos_desc=''' + @pos_desc + ''' diag_type=''' + @diag_type + '''>'
						END
			
					SELECT @xml = @xml + '<MED id=''' + CONVERT(VARCHAR(10), @medical_count) + ''' V0=''' + @V0 + ''' V1=''' + @V1 + ''' V2=''' + @V2 + ''' V3=''' + @V3 + ''''
					SELECT @xml = @xml + ' V4=''' + @V4 + ''' V5=''' + @V5 + ''' V6=''' + @V6 + ''' V7=''' + @V7 + ''' V8=''' + @V8 + ''' V9=''' + @V9 + ''''
					SELECT @xml = @xml + ' V10=''' + @V10 + ''' V11=''' + @V11 + ''' V12=''' + @V12 + ''' V13=''' + @V13 + ''' V14=''' + @V14 + ''' />'

					SET @medical_count = @medical_count + 1

					FETCH NEXT FROM MedicalAuthorizations_Cursor
			         INTO @pos_code, @pos_desc, @diag_type, @V0, @V1, @V2, @V3, @V4, @V5, @V6, @V7, @V8, @V9, @V10, @V11, @V12, @V13, @V14

				END

			CLOSE MedicalAuthorizations_Cursor
			DEALLOCATE MedicalAuthorizations_Cursor

			SELECT @xml = @xml + '</Data></SData>'
			SELECT @iServiceInfo = @xml

			EXEC dbo.prAuthAddModify 
                 @iEntity
                ,@iAuthGID
                ,@iKeyField2
                ,@iKeyField3
                ,@iKeyField4
                ,@iKeyField5
                ,@iKeyField6
                ,@iKeyField7
                ,@iKeyField8
                ,@iKeyField9
                ,@iKeyField10
                ,@iAction
                ,@iDateModified
                ,@iUserID
                ,@iMember_ID
                ,@iMember_Info
                ,@iRendering_Physician_ID
                ,@iRendering_Info
                ,@iRendering_Location_ID
                ,@iReferring_Physician_ID
                ,@iReferring_Info
                ,@iFacility_ID
                ,@iFacility_Info
                ,@iAdmitting_Physician_ID
                ,@iAdmitting_Info
                ,@iAssisting_Physician_ID
                ,@iAssisting_Info
                ,@iOther_Physician_ID
                ,@iOther_Info
                ,@iAnesthesia_Flag
                ,@iAuth_Number
                ,@iDate_Requested
                ,@iAuth_Status
                ,@iDate_Submitted
                ,@iAuthType
                ,@iNotes
                ,@iStatus_Start_Date
                ,@iStatus_End_Date
                ,@iExpedited_Flag
                ,@iAuth_Extension_Flag
                ,@iService_Term_Date
                ,@iRequest_Method
                ,@iAppeal_Exists
                ,@iPay_as_In_Network
                ,@iServiceInfo
                ,@iAppends
                ,@iAppeal_Status
                ,@iExternal_Audit
                ,@iAppeal_Start_Date
                ,@iAppeal_End_Date
                ,@iAppeal_Notes
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT
				,@return_xml  = '<root><results status_code="900" screen_gid="900" Value="Y" ErrorType=""/></root>' 

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		LOG_ERROR:
		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iMember_ID, @iRendering_Physician_ID, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM ClaimAuthorizations_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iAuthGID
             ,@iKeyField2
             ,@iKeyField3
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iMember_ID
             ,@iMember_Info
             ,@iRendering_Physician_ID
             ,@iRendering_Info
             ,@iRendering_Location_ID
             ,@iReferring_Physician_ID
             ,@iReferring_Info
             ,@iFacility_ID
             ,@iFacility_Info
             ,@iAdmitting_Physician_ID
             ,@iAdmitting_Info
             ,@iAssisting_Physician_ID
             ,@iAssisting_Info
             ,@iOther_Physician_ID
             ,@iOther_Info
             ,@iAnesthesia_Flag
             ,@iAuth_Number
             ,@iDate_Requested
             ,@iAuth_Status
             ,@iDate_Submitted
             ,@iAuthType
             ,@iNotes
             ,@iStatus_Start_Date
             ,@iStatus_End_Date
             ,@iExpedited_Flag
             ,@iAuth_Extension_Flag
             ,@iService_Term_Date
             ,@iRequest_Method
             ,@iAppeal_Exists
             ,@iPay_as_In_Network
             ,@iServiceInfo
             ,@iAppends
             ,@iAppeal_Status
             ,@iExternal_Audit
             ,@iAppeal_Start_Date
             ,@iAppeal_End_Date
             ,@iAppeal_Notes
             ,@oStatus
             ,@oMessage
             ,@return_xml
             ,@record_id
             ,@static_gid
			 ,@TCID
	END

CLOSE ClaimAuthorizations_Cursor
DEALLOCATE ClaimAuthorizations_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#ClaimAuthorizations') IS NOT NULL
	DROP TABLE #ClaimAuthorizations

IF OBJECT_ID('tempdb.dbo.#MedicalAuthorizations') IS NOT NULL
	DROP TABLE #MedicalAuthorizations

IF OBJECT_ID('tempdb.dbo.#DentalAuthorizations') IS NOT NULL
	DROP TABLE #DentalAuthorizations
END
GO

