IF OBJECT_ID('dbo.spDCAuto_CreateProvidersHolds') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProvidersHolds AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProvidersHolds
Purpose:    Create providersholds data from CorderAutomation
Method:     ProvidersHolds
Screen GID: 3024
Procedure:  dbo.prProviderHolds_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProvidersHolds '100-Config%', 22, 'ProvidersHolds'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProvidersHolds
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_provider_gid       VARCHAR(50)
       ,@i_location_gid       VARCHAR(50)
       ,@i_business_gid       VARCHAR(50)
       ,@i_orig_eff_date      VARCHAR(50)
       ,@i_orig_term_date     VARCHAR(50)
       ,@i_orig_hold_code     VARCHAR(50)
       ,@i_prov_type          VARCHAR(50)
       ,@iRecordSID           VARCHAR(50)
       ,@i_Affilitaion_GID    VARCHAR(50)
       ,@i_orig_code_list     VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Effective_Date     VARCHAR(50)
       ,@i_Termination_Date   VARCHAR(50)
       ,@i_Hold_Code          VARCHAR(50)
       ,@i_code_list_id       VARCHAR(50)
       ,@i_code_list_desc     VARCHAR(100)
       ,@i_diag_list_id       VARCHAR(50)
       ,@i_diag_list_desc     VARCHAR(100)
       ,@i_diag_option        VARCHAR(50)
       ,@i_rec_name1          VARCHAR(50)
       ,@i_rec_name2          VARCHAR(50)
       ,@i_location_id        VARCHAR(50)
       ,@i_location_name      VARCHAR(100)
       ,@i_address_1          VARCHAR(55)
       ,@i_address_2          VARCHAR(55)
       ,@i_zip_code           VARCHAR(50)
       ,@i_city               VARCHAR(100)
       ,@i_state              VARCHAR(50)
       ,@i_county             VARCHAR(100)
       ,@i_country            VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProvidersHolds') IS NOT NULL
	DROP TABLE #ProvidersHolds

CREATE TABLE #ProvidersHolds
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Prov_Inc2')
      ,i_provider_gid       VARCHAR(50)       DEFAULT('0')
      ,i_location_gid       VARCHAR(50)       DEFAULT('0')
      ,i_business_gid       VARCHAR(50)       DEFAULT('0')
      ,i_orig_eff_date      VARCHAR(50)       DEFAULT('0')
      ,i_orig_term_date     VARCHAR(50)       DEFAULT('0')
      ,i_orig_hold_code     VARCHAR(50)       DEFAULT('0')
      ,i_prov_type          VARCHAR(50)       DEFAULT('0')
      ,iRecordSID           VARCHAR(50)       DEFAULT('0')
      ,i_Affilitaion_GID    VARCHAR(50)       DEFAULT('0')
      ,i_orig_code_list     VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(200)      DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Effective_Date     VARCHAR(50)
      ,i_Termination_Date   VARCHAR(50)
      ,i_Hold_Code          VARCHAR(50)
      ,i_code_list_id       VARCHAR(50)
      ,i_code_list_desc     VARCHAR(100)
      ,i_diag_list_id       VARCHAR(50)
      ,i_diag_list_desc     VARCHAR(100)
      ,i_diag_option        VARCHAR(50)
      ,i_rec_name1          VARCHAR(50)
      ,i_rec_name2          VARCHAR(50)
      ,i_location_id        VARCHAR(50)
      ,i_location_name      VARCHAR(100)
      ,i_address_1          VARCHAR(55)
      ,i_address_2          VARCHAR(55)
      ,i_zip_code           VARCHAR(50)
      ,i_city               VARCHAR(100)
      ,i_state              VARCHAR(50)
      ,i_county             VARCHAR(100)
      ,i_country            VARCHAR(100)
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
INSERT INTO #ProvidersHolds
      (SearchID
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Hold_Code
      ,i_code_list_id
      ,i_diag_list_id
      ,i_diag_option
      ,i_rec_name1
	  ,i_rec_name2
      ,i_location_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_HoldCodes]), '0')
      ,ISNULL([Common_CodeListID], '')
      ,ISNULL([Common_DiagnosisValidationID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiagnosisValidationLogic]), '')
      ,ISNULL([IRSWithhold_RecipientName], '')
      ,ISNULL([IRSWithhold_RecipientName2], '')
      ,ISNULL([IRSWithhold_LocationID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ProviderHold
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ProvidersHolds
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ProvidersHolds_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_provider_gid
       ,i_location_gid
       ,i_business_gid
       ,i_orig_eff_date
       ,i_orig_term_date
       ,i_orig_hold_code
       ,i_prov_type
       ,iRecordSID
       ,i_Affilitaion_GID
       ,i_orig_code_list
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Hold_Code
       ,i_code_list_id
       ,i_code_list_desc
       ,i_diag_list_id
       ,i_diag_list_desc
       ,i_diag_option
       ,i_rec_name1
       ,i_rec_name2
       ,i_location_id
       ,i_location_name
       ,i_address_1
       ,i_address_2
       ,i_zip_code
       ,i_city
       ,i_state
       ,i_county
       ,i_country
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #ProvidersHolds

   OPEN ProvidersHolds_Cursor
  FETCH NEXT FROM ProvidersHolds_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_provider_gid
       ,@i_location_gid
       ,@i_business_gid
       ,@i_orig_eff_date
       ,@i_orig_term_date
       ,@i_orig_hold_code
       ,@i_prov_type
       ,@iRecordSID
       ,@i_Affilitaion_GID
       ,@i_orig_code_list
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Hold_Code
       ,@i_code_list_id
       ,@i_code_list_desc
       ,@i_diag_list_id
       ,@i_diag_list_desc
       ,@i_diag_option
       ,@i_rec_name1
       ,@i_rec_name2
       ,@i_location_id
       ,@i_location_name
       ,@i_address_1
       ,@i_address_2
       ,@i_zip_code
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
			
			-- Get the Provider ID 
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			-- Find the provider's gid
			SELECT @i_provider_gid		= P.provider_gid
			  FROM Provider				P
			 WHERE P.record_status		= 'A'
			   AND P.provider_id		= @SearchID

			EXEC dbo.prProviderHolds_AddModify
             @i_entity_name
            ,@i_provider_gid
            ,@i_location_gid
            ,@i_business_gid
            ,@i_orig_eff_date
            ,@i_orig_term_date
            ,@i_orig_hold_code
            ,@i_prov_type
            ,@iRecordSID
            ,@i_Affilitaion_GID
            ,@i_orig_code_list
            ,@i_action
            ,@i_Date_Time_Modified
            ,@iUserID
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Hold_Code
            ,@i_code_list_id
            ,@i_code_list_desc
            ,@i_diag_list_id
            ,@i_diag_list_desc
            ,@i_diag_option
            ,@i_rec_name1
            ,@i_rec_name2
            ,@i_location_id
            ,@i_location_name
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
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Hold_Code, @i_Effective_Date, @status, @err_num, @err_msg

        FETCH NEXT FROM ProvidersHolds_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_provider_gid
             ,@i_location_gid
             ,@i_business_gid
             ,@i_orig_eff_date
             ,@i_orig_term_date
             ,@i_orig_hold_code
             ,@i_prov_type
             ,@iRecordSID
             ,@i_Affilitaion_GID
             ,@i_orig_code_list
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Hold_Code
             ,@i_code_list_id
             ,@i_code_list_desc
             ,@i_diag_list_id
             ,@i_diag_list_desc
             ,@i_diag_option
             ,@i_rec_name1
             ,@i_rec_name2
             ,@i_location_id
             ,@i_location_name
             ,@i_address_1
             ,@i_address_2
             ,@i_zip_code
             ,@i_city
             ,@i_state
             ,@i_county
             ,@i_country
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE ProvidersHolds_Cursor
DEALLOCATE ProvidersHolds_Cursor

END
GO