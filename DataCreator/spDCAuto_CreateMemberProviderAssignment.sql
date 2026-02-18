IF OBJECT_ID('dbo.spDCAuto_CreateMemberProviderAssignment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberProviderAssignment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberProviderAssignment
Purpose:    Create memberproviderassignment data from CorderAutomation
Method:     MemberProviderAssignment
Screen GID: 2100
Procedure:  dbo.prMemberProviderAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
01/21/2020	DK				Use the social security number to determine the GIDs for the member
01/26/2021	DK				Add error trapping for the first insert
01/26/2021	DK				Expanded provider location due to truncation error 60-->400
09/13/2021	DK				Change @err_num to VARCHAR to allow for non-numeric error
06/09/2022  DK				Add override (@return_xml) for status code 550
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberProviderAssignment 'ClaimUI-Config-3000%', 22, 'ClaimUI-Config-3000','MemberProviderAssignment', 'ClaimUIConfig3000'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberProviderAssignment
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
       ,@err_num					VARCHAR(200)
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT

	   ,@provider_gid				INT
	   ,@business_gid				INT
	   ,@business_id				VARCHAR(200)
	   ,@location_gid				INT
	   ,@ssn						VARCHAR(50)
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_pcp_gid            VARCHAR(50)
       ,@i_pcp_type           VARCHAR(50)
       ,@i_child_gid          VARCHAR(50)
       ,@i_parent_gid         VARCHAR(80)
       ,@i_group_gid          VARCHAR(50)
       ,@i_eff_date           VARCHAR(80)
       ,@i_term_date          VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_lob                VARCHAR(50)
       ,@i_member_id          VARCHAR(100)
       ,@i_action             VARCHAR(100)
       ,@i_date_time_modified VARCHAR(200)
       ,@iUserID              VARCHAR(50)
       ,@i_prov_type          VARCHAR(50)
       ,@i_default_lob        VARCHAR(50)
       ,@i_prov_eff_date      VARCHAR(50)
       ,@i_prov_term_date     VARCHAR(50)
       ,@i_prov_id            VARCHAR(60)
       ,@i_prov_name          VARCHAR(150)
       ,@i_prov_location      VARCHAR(400)
       ,@i_apply_to_deps      VARCHAR(50)
       ,@i_mtn_reason         VARCHAR(50)
       ,@i_overlap_mtn_reason VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)
       ,@i_disp_results       VARCHAR(50)
       ,@return_xml           XML

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberProviderAssignment') IS NOT NULL
	DROP TABLE #MemberProviderAssignment

CREATE TABLE #MemberProviderAssignment
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Prov_Assn')
      ,i_pcp_gid            VARCHAR(50)       DEFAULT('0')
      ,i_pcp_type           VARCHAR(50)       DEFAULT('0')
      ,i_child_gid          VARCHAR(50)       DEFAULT('0')
      ,i_parent_gid         VARCHAR(80)       DEFAULT('0')
      ,i_group_gid          VARCHAR(50)       DEFAULT('0')
      ,i_eff_date           VARCHAR(80)       DEFAULT('0')
      ,i_term_date          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_lob                VARCHAR(50)       DEFAULT('0')
      ,i_member_id          VARCHAR(100)      DEFAULT('0')
      ,i_action             VARCHAR(100)      DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(200)	  DEFAULT('')
      ,iUserID              VARCHAR(50)       DEFAULT('')
      ,i_prov_type          VARCHAR(50)
      ,i_default_lob        VARCHAR(50)
      ,i_prov_eff_date      VARCHAR(50)
      ,i_prov_term_date     VARCHAR(50)
      ,i_prov_id            VARCHAR(60)
      ,i_prov_name          VARCHAR(150)
      ,i_prov_location      VARCHAR(400)
      ,i_apply_to_deps      VARCHAR(50)
      ,i_mtn_reason         VARCHAR(50)
      ,i_overlap_mtn_reason VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,i_disp_results       VARCHAR(50)
      ,return_xml           XML
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
	INSERT INTO #MemberProviderAssignment
		  (SearchID
		  ,i_prov_type
		  ,i_default_lob
		  ,i_prov_eff_date
		  ,i_prov_term_date
		  ,i_prov_id
		  ,i_prov_location
		  ,i_apply_to_deps
		  ,i_mtn_reason
		  ,i_overlap_mtn_reason
		  ,record_id
		  ,static_gid)
	SELECT SearchID
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProviderType]), 'P')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOB]), '')
		  ,ISNULL([*ProviderEffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
		  ,ISNULL([*ProviderTerminationDate], '12/31/9999')
		  ,ISNULL([*ProviderID], '')
		  ,ISNULL([*ProviderServiceLocations], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Applychangestoalldependents]), 'N')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReasonForSelection]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReasonForChange]), '')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
	  FROM COREAUTO.CoreAutomation.dbo.TD_MemberPCPAssignment
	 WHERE TCID				LIKE @pattern
	   AND ActiveTestCase	= 'A'

	--*************************************************************************************************
	-- Update the user
	--*************************************************************************************************
	UPDATE #MemberProviderAssignment
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
DECLARE MemberProviderAssignment_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_pcp_gid
       ,i_pcp_type
       ,i_child_gid
       ,i_parent_gid
       ,i_group_gid
       ,i_eff_date
       ,i_term_date
       ,i_key_8_field
       ,i_lob
       ,i_member_id
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_prov_type
       ,i_default_lob
       ,i_prov_eff_date
       ,i_prov_term_date
       ,i_prov_id
       ,i_prov_name
       ,i_prov_location
       ,i_apply_to_deps
       ,i_mtn_reason
       ,i_overlap_mtn_reason
       ,o_status
       ,o_message
       ,i_disp_results
       ,return_xml
       ,record_id
       ,static_gid
   FROM #MemberProviderAssignment

   OPEN MemberProviderAssignment_Cursor
  FETCH NEXT FROM MemberProviderAssignment_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_pcp_gid
       ,@i_pcp_type
       ,@i_child_gid
       ,@i_parent_gid
       ,@i_group_gid
       ,@i_eff_date
       ,@i_term_date
       ,@i_key_8_field
       ,@i_lob
       ,@i_member_id
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_prov_type
       ,@i_default_lob
       ,@i_prov_eff_date
       ,@i_prov_term_date
       ,@i_prov_id
       ,@i_prov_name
       ,@i_prov_location
       ,@i_apply_to_deps
       ,@i_mtn_reason
       ,@i_overlap_mtn_reason
       ,@o_status
       ,@o_message
       ,@i_disp_results
       ,@return_xml
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the child and parent gids for the member
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @i_member_id = token FROM #Tokens WHERE token_order = 1
			SELECT @ssn = token			FROM #Tokens WHERE token_order = 2

			SELECT @i_child_gid				= EC.child_gid
			      ,@i_parent_gid			= EC.parent_gid
				  ,@i_group_gid				= EC.group_gid
			  FROM Eligibility_Coverage		EC
			  JOIN Contacts					C
			    ON EC.child_gid				= C.contact_gid
			 WHERE EC.record_status			= 'A'
			   AND C.record_status			= 'A'
			   AND EC.member_id				= @i_member_id
			   AND EC.child_identifier		= 'M'
			   AND EC.parent_identifier		= 'M'
			   AND C.actual_ssn				= @ssn

			-- Get the gids for the service location for the provider
			SELECT @provider_gid	= P.provider_gid
			      ,@i_prov_name		= ISNULL(LTRIM(RTRIM(name_prefix)), '') + ' ' + LTRIM(RTRIM(first_name)) + ' ' + ISNULL(LTRIM(RTRIM(Middle_initial)), '') + ' ' + LTRIM(RTRIM(Last_Name)) + ' ' + ISNULL(LTRIM(RTRIM(name_suffix)), '')  
			  FROM Provider			P
			 WHERE P.record_status	= 'A'
			   AND P.provider_id	= @i_prov_id

			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@i_prov_location, ':')
			SELECT @business_id = RTRIM(LTRIM(token)) FROM #Tokens WHERE token_order = 2


			SELECT @business_gid		= PL.business_gid
			      ,@location_gid		= PL.location_gid
			  FROM Provider_Link		PL
			  JOIN Business_Units		BU
			    ON PL.business_gid		= BU.business_gid
			 WHERE PL.record_status		= 'A'
			   AND BU.record_status		= 'A'
			   AND PL.provider_gid		= @provider_gid
			   AND BU.business_unit_id	= @business_id

			-- Set up the variables before making the call
			SELECT @i_prov_location		= CONVERT(VARCHAR(20), @provider_gid) + ':' + CONVERT(VARCHAR(20), @business_gid) + ':' + CONVERT(VARCHAR(20), @location_gid)

			EXEC dbo.prMemberProviderAddModify
             @i_entity_name
            ,@i_pcp_gid
            ,@i_pcp_type
            ,@i_child_gid
            ,@i_parent_gid
            ,@i_group_gid
            ,@i_eff_date
            ,@i_term_date
            ,@i_key_8_field
            ,@i_lob
            ,@i_member_id
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_prov_type
            ,@i_default_lob
            ,@i_prov_eff_date
            ,@i_prov_term_date
            ,@i_prov_id
            ,@i_prov_name
            ,@i_prov_location
            ,@i_apply_to_deps
            ,@i_mtn_reason
            ,@i_overlap_mtn_reason
            ,@o_status				= @err_num OUTPUT
            ,@o_message				= @err_msg OUTPUT
            ,@i_disp_results		= 'N'
            ,@return_xml			= '<root><results status_code="550" screen_gid="900" Value="Y" ErrorType=""/></root>'

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.PCP_Assignment 
				   SET pcp_gid					= @static_gid 
				 WHERE record_status			= 'A'
				   AND child_gid				= @i_child_gid
				   AND parent_gid				= @i_parent_gid
				   AND group_gid				= @i_group_gid
				   AND default_lob				= @i_default_lob
				   AND provider_gid				= @provider_gid
				   AND business_gid				= @business_gid
				   AND location_gid				= @location_gid

			END

		SELECT @status = CASE WHEN @err_num != '0' THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_member_id, @i_prov_id, '', @status, @err_num, @err_msg

        FETCH NEXT FROM MemberProviderAssignment_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_pcp_gid
             ,@i_pcp_type
             ,@i_child_gid
             ,@i_parent_gid
             ,@i_group_gid
             ,@i_eff_date
             ,@i_term_date
             ,@i_key_8_field
             ,@i_lob
             ,@i_member_id
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_prov_type
             ,@i_default_lob
             ,@i_prov_eff_date
             ,@i_prov_term_date
             ,@i_prov_id
             ,@i_prov_name
             ,@i_prov_location
             ,@i_apply_to_deps
             ,@i_mtn_reason
             ,@i_overlap_mtn_reason
             ,@o_status
             ,@o_message
             ,@i_disp_results
             ,@return_xml
             ,@record_id
             ,@static_gid
	END

CLOSE MemberProviderAssignment_Cursor
DEALLOCATE MemberProviderAssignment_Cursor

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#MemberProviderAssignment') IS NOT NULL
	DROP TABLE #MemberProviderAssignment

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

END
GO