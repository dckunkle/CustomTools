IF OBJECT_ID('dbo.spDCAuto_CreateFeeScheduleLookupFeeSchedVariations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateFeeScheduleLookupFeeSchedVariations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateFeeScheduleLookupFeeSchedVariations
Purpose:    Create feeschedulelookupfeeschedvariations data from CorderAutomation
Method:     FeeScheduleLookupFeeSchedVariations
Screen GID: 166
Procedure:  dbo.prFeeScheduleLookup_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateFeeScheduleLookupFeeSchedVariations '100-Config%', 22, 'FeeScheduleLookupFeeSchedVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateFeeScheduleLookupFeeSchedVariations
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
       ,@i_fee_lookup_sid     VARCHAR(50)
       ,@i_fee_lookup_gid     VARCHAR(30)
       ,@i_key_3_field        VARCHAR(30)
       ,@i_key_4_field        VARCHAR(30)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(80)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(80)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(30)
       ,@i_UserID             VARCHAR(25)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_zipcode_from       VARCHAR(50)
       ,@i_zipcode_to         VARCHAR(50)
       ,@i_state              VARCHAR(50)
       ,@i_specialty_code     VARCHAR(50)
       ,@i_specialty_desc     VARCHAR(100)
       ,@i_age_option         VARCHAR(50)
       ,@i_thru_age           VARCHAR(50)
       ,@i_fee_schedule_id    VARCHAR(50)
       ,@i_fee_schedule_desc  VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#FeeScheduleLookupFeeSchedVariations') IS NOT NULL
	DROP TABLE #FeeScheduleLookupFeeSchedVariations

CREATE TABLE #FeeScheduleLookupFeeSchedVariations
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Fee_Schedule_Lookup')
      ,i_fee_lookup_sid     VARCHAR(50)       DEFAULT('0')
      ,i_fee_lookup_gid     VARCHAR(30)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(80)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(80)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(30)       DEFAULT('')
      ,i_UserID             VARCHAR(25)       DEFAULT('')
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_zipcode_from       VARCHAR(50)
      ,i_zipcode_to         VARCHAR(50)
      ,i_state              VARCHAR(50)
      ,i_specialty_code     VARCHAR(50)
      ,i_specialty_desc     VARCHAR(100)
      ,i_age_option         VARCHAR(50)
      ,i_thru_age           VARCHAR(50)
      ,i_fee_schedule_id    VARCHAR(50)
      ,i_fee_schedule_desc  VARCHAR(100)
      ,o_status             INT
      ,o_message            VARCHAR(100)
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
INSERT INTO #FeeScheduleLookupFeeSchedVariations
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_zipcode_from
      ,i_zipcode_to
      ,i_state
      ,i_specialty_code
      ,i_age_option
      ,i_thru_age
      ,i_fee_schedule_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL([*ZipCodeFrom], '00000')
      ,ISNULL([*ZipCodeTo], '99999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([State]), '**')
      ,ISNULL([*Specialty], '999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ThruAgeOption]), '1')
      ,ISNULL([ThruAge], '0')
      ,ISNULL([*FeeSchedID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_FeeScheduleLookupFeeSchedVariations
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #FeeScheduleLookupFeeSchedVariations
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE FeeScheduleLookupFeeSchedVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_fee_lookup_sid
       ,i_fee_lookup_gid
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
       ,i_UserID
       ,i_effective_date
       ,i_termination_date
       ,i_zipcode_from
       ,i_zipcode_to
       ,i_state
       ,i_specialty_code
       ,i_specialty_desc
       ,i_age_option
       ,i_thru_age
       ,i_fee_schedule_id
       ,i_fee_schedule_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #FeeScheduleLookupFeeSchedVariations

   OPEN FeeScheduleLookupFeeSchedVariations_Cursor
  FETCH NEXT FROM FeeScheduleLookupFeeSchedVariations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_fee_lookup_sid
       ,@i_fee_lookup_gid
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
       ,@i_UserID
       ,@i_effective_date
       ,@i_termination_date
       ,@i_zipcode_from
       ,@i_zipcode_to
       ,@i_state
       ,@i_specialty_code
       ,@i_specialty_desc
       ,@i_age_option
       ,@i_thru_age
       ,@i_fee_schedule_id
       ,@i_fee_schedule_desc
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

			--Get the gid for the Auth Match
			SELECT @i_fee_lookup_gid		= EN.entity_gid
			  FROM Entity_Names				EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_identifier		= 'Fee Schedule Lookup Name'
			   AND EN.entity_user_id		= @SearchID
			   PRINT @SearchID
			EXEC dbo.prFeeScheduleLookup_Add_Modify
             @i_entity_name
            ,@i_fee_lookup_sid
            ,@i_fee_lookup_gid
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
            ,@i_UserID
            ,@i_effective_date
            ,@i_termination_date
            ,@i_zipcode_from
            ,@i_zipcode_to
            ,@i_state
            ,@i_specialty_code
            ,@i_specialty_desc
            ,@i_age_option
            ,@i_thru_age
            ,@i_fee_schedule_id
            ,@i_fee_schedule_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_fee_schedule_id, @i_specialty_code, @status, @err_num, @err_msg

        FETCH NEXT FROM FeeScheduleLookupFeeSchedVariations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_fee_lookup_sid
             ,@i_fee_lookup_gid
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
             ,@i_UserID
             ,@i_effective_date
             ,@i_termination_date
             ,@i_zipcode_from
             ,@i_zipcode_to
             ,@i_state
             ,@i_specialty_code
             ,@i_specialty_desc
             ,@i_age_option
             ,@i_thru_age
             ,@i_fee_schedule_id
             ,@i_fee_schedule_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE FeeScheduleLookupFeeSchedVariations_Cursor
DEALLOCATE FeeScheduleLookupFeeSchedVariations_Cursor

END
GO