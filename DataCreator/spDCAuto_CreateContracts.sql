/**************************************************************************************************
Name:       spDCAuto_CreateContracts
Purpose:    Create contracts/certificates data from CorderAutomation

Screen:     6
Method:     Contracts/Certificates
Procedure:  dbo.prContractAdd
Entity:     Contracts

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
08/25/2022	DK				Changes for MAX values (ContractDesc)
11/16/2022  DK				Rewrite
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateContracts 'Max-Config%', 22, 'Max-Config','Contracts/Certificates','dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateContracts
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
       ,@i_key_1_field            VARCHAR(50)
       ,@i_key_2_field            VARCHAR(50)
       ,@i_key_3_field            VARCHAR(50)
       ,@i_key_4_field            VARCHAR(30)
       ,@i_key_5_field            VARCHAR(50)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(50)
       ,@i_key_8_field            VARCHAR(50)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(50)
       ,@i_action                 VARCHAR(50)
       ,@i_date_time_modified     VARCHAR(50)
       ,@iUserID                  VARCHAR(50)
       ,@i_contract_id            VARCHAR(50)
       ,@i_contract_description   VARCHAR(200)
       ,@i_gl_schedule_id         VARCHAR(50)
       ,@i_gl_schedule_desc       VARCHAR(100)
       ,@i_contract_class_code    VARCHAR(50)
       ,@i_contract_state         VARCHAR(50)
       ,@i_other_carrier_code     VARCHAR(50)
       ,@i_insurance_carrier_desc VARCHAR(50)
       ,@i_funding_type           VARCHAR(50)
       ,@i_census_category        VARCHAR(50)
       ,@i_min_sub_enroll_code    VARCHAR(50)
       ,@i_min_dep_enroll_code    VARCHAR(50)
       ,@i_min_enrollee_count     VARCHAR(50)
       ,@i_max_enrollee_count     VARCHAR(50)
       ,@i_elig_cobra_code        VARCHAR(50)
       ,@i_elig_fmla_code         VARCHAR(50)
       ,@i_elig_self_pay_code     VARCHAR(50)
       ,@i_bene_book_oic          VARCHAR(50)
       ,@i_bene_book_oic_desc     VARCHAR(100)
       ,@i_bene_book_std_cover    VARCHAR(50)
       ,@i_bene_book_std_guts     VARCHAR(50)
       ,@i_bene_book_wds_print    VARCHAR(50)
       ,@oStatus                  INT
       ,@oMessage                 VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Contracts') IS NOT NULL
	DROP TABLE #Contracts

CREATE TABLE #Contracts
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(50)       DEFAULT('Contracts')
      ,i_key_1_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(50)       DEFAULT('0')
      ,i_action                 VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(50)       DEFAULT('')
      ,iUserID                  VARCHAR(50)       DEFAULT('')
      ,i_contract_id            VARCHAR(50)
      ,i_contract_description   VARCHAR(200)
      ,i_gl_schedule_id         VARCHAR(50)
      ,i_gl_schedule_desc       VARCHAR(100)
      ,i_contract_class_code    VARCHAR(50)
      ,i_contract_state         VARCHAR(50)
      ,i_other_carrier_code     VARCHAR(50)
      ,i_insurance_carrier_desc VARCHAR(50)
      ,i_funding_type           VARCHAR(50)
      ,i_census_category        VARCHAR(50)
      ,i_min_sub_enroll_code    VARCHAR(50)
      ,i_min_dep_enroll_code    VARCHAR(50)
      ,i_min_enrollee_count     VARCHAR(50)
      ,i_max_enrollee_count     VARCHAR(50)
      ,i_elig_cobra_code        VARCHAR(50)
      ,i_elig_fmla_code         VARCHAR(50)
      ,i_elig_self_pay_code     VARCHAR(50)
      ,i_bene_book_oic          VARCHAR(50)
      ,i_bene_book_oic_desc     VARCHAR(100)
      ,i_bene_book_std_cover    VARCHAR(50)
      ,i_bene_book_std_guts     VARCHAR(50)
      ,i_bene_book_wds_print    VARCHAR(50)
      ,oStatus                  INT
      ,oMessage                 VARCHAR(100)
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

    INSERT INTO #Contracts
          (SearchID
          ,i_contract_id
          ,i_contract_description
          ,i_gl_schedule_id
          ,i_contract_class_code
          ,i_contract_state
          ,i_other_carrier_code
          ,i_funding_type
          ,i_census_category
          ,i_min_sub_enroll_code
          ,i_min_dep_enroll_code
          ,i_min_enrollee_count
          ,i_max_enrollee_count
          ,i_elig_cobra_code
          ,i_elig_fmla_code
          ,i_elig_self_pay_code
          ,i_bene_book_oic
          ,i_bene_book_std_cover
          ,i_bene_book_std_guts
          ,i_bene_book_wds_print
          ,record_id
          ,static_gid)
	SELECT ISNULL([SearchID], '')
	      ,ISNULL([*ContractID], '')
		  ,ISNULL([*ContractDesc], '')
		  ,ISNULL([GeneralLedgerSchdID], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractClassCode]), 'F')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ContractState]), '')
		  ,ISNULL([CarrierID], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FundingType]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CensusCategory]), '******')
		  ,ISNULL([SubscriberEnrollPerc], '')
		  ,ISNULL([DependEnrollPerc], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MinEnrollCount]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MaxEnrollCount]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBRAVerbiage]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FMLAVerbiage]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SelfPayVerbiage]), '')
		  ,ISNULL([OICID], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([StandardCover]), 'Y')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([StandardGuts]), 'Y')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BookletPrint]), 'Y')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')      
	  FROM COREAUTO.CoreAutomation.dbo.TD_ContractsCert
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #Contracts
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
DECLARE Contracts_Cursor CURSOR FOR
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
       ,iUserID
       ,i_contract_id
       ,i_contract_description
       ,i_gl_schedule_id
       ,i_gl_schedule_desc
       ,i_contract_class_code
       ,i_contract_state
       ,i_other_carrier_code
       ,i_insurance_carrier_desc
       ,i_funding_type
       ,i_census_category
       ,i_min_sub_enroll_code
       ,i_min_dep_enroll_code
       ,i_min_enrollee_count
       ,i_max_enrollee_count
       ,i_elig_cobra_code
       ,i_elig_fmla_code
       ,i_elig_self_pay_code
       ,i_bene_book_oic
       ,i_bene_book_oic_desc
       ,i_bene_book_std_cover
       ,i_bene_book_std_guts
       ,i_bene_book_wds_print
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #Contracts

   OPEN Contracts_Cursor
  FETCH NEXT FROM Contracts_Cursor
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
       ,@iUserID
       ,@i_contract_id
       ,@i_contract_description
       ,@i_gl_schedule_id
       ,@i_gl_schedule_desc
       ,@i_contract_class_code
       ,@i_contract_state
       ,@i_other_carrier_code
       ,@i_insurance_carrier_desc
       ,@i_funding_type
       ,@i_census_category
       ,@i_min_sub_enroll_code
       ,@i_min_dep_enroll_code
       ,@i_min_enrollee_count
       ,@i_max_enrollee_count
       ,@i_elig_cobra_code
       ,@i_elig_fmla_code
       ,@i_elig_self_pay_code
       ,@i_bene_book_oic
       ,@i_bene_book_oic_desc
       ,@i_bene_book_std_cover
       ,@i_bene_book_std_guts
       ,@i_bene_book_wds_print
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			EXEC dbo.prContractAdd
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
                ,@iUserID
                ,@i_contract_id
                ,@i_contract_description
                ,@i_gl_schedule_id
                ,@i_gl_schedule_desc
                ,@i_contract_class_code
                ,@i_contract_state
                ,@i_other_carrier_code
                ,@i_insurance_carrier_desc
                ,@i_funding_type
                ,@i_census_category
                ,@i_min_sub_enroll_code
                ,@i_min_dep_enroll_code
                ,@i_min_enrollee_count
                ,@i_max_enrollee_count
                ,@i_elig_cobra_code
                ,@i_elig_fmla_code
                ,@i_elig_self_pay_code
                ,@i_bene_book_oic
                ,@i_bene_book_oic_desc
                ,@i_bene_book_std_cover
                ,@i_bene_book_std_guts
                ,@i_bene_book_wds_print
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Contracts 
				   SET contract_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND contract_id				= @i_contract_id

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_contract_id, @i_contract_description, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Contracts_Cursor
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
             ,@iUserID
             ,@i_contract_id
             ,@i_contract_description
             ,@i_gl_schedule_id
             ,@i_gl_schedule_desc
             ,@i_contract_class_code
             ,@i_contract_state
             ,@i_other_carrier_code
             ,@i_insurance_carrier_desc
             ,@i_funding_type
             ,@i_census_category
             ,@i_min_sub_enroll_code
             ,@i_min_dep_enroll_code
             ,@i_min_enrollee_count
             ,@i_max_enrollee_count
             ,@i_elig_cobra_code
             ,@i_elig_fmla_code
             ,@i_elig_self_pay_code
             ,@i_bene_book_oic
             ,@i_bene_book_oic_desc
             ,@i_bene_book_std_cover
             ,@i_bene_book_std_guts
             ,@i_bene_book_wds_print
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE Contracts_Cursor
DEALLOCATE Contracts_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#Contracts') IS NOT NULL
	DROP TABLE #Contracts

END
GO

