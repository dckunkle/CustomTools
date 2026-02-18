IF OBJECT_ID('dbo.spDCAuto_CreateCoverageCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCoverageCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCoverageCodes
Purpose:    Create coverage codes from CorderAutomation

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCoverageCodes 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCoverageCodes
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

	   ,@user_id_created			VARCHAR(200)

DECLARE	@i_entity_name				VARCHAR(50)
       ,@i_key_coverage_code		VARCHAR(50)
       ,@i_key_2_field				VARCHAR(50)
       ,@i_key_3_field				VARCHAR(50)
       ,@i_key_4_field				VARCHAR(50)
       ,@i_key_5_field				VARCHAR(50)
       ,@i_key_6_field				VARCHAR(50)
       ,@i_key_7_field				VARCHAR(50)
       ,@i_key_8_field				VARCHAR(50)
       ,@i_key_9_field				VARCHAR(50)
       ,@i_key_10_field				VARCHAR(50)
       ,@i_action					VARCHAR(10)
       ,@i_date_time_modified		VARCHAR(50)
       ,@iUserID					VARCHAR(25)
       ,@i_coverage_code			VARCHAR(20)
       ,@i_coverage_code_desc		VARCHAR(100)
       ,@i_num_of_subscribers		INT
       ,@i_spouse_option			VARCHAR(50)
       ,@i_min_dependents			VARCHAR(10)
       ,@i_max_dependents			VARCHAR(10)
       ,@i_hippa_cov_code			VARCHAR(50)
       ,@i_Coverage_Code_Tier_ID	VARCHAR(55)
       ,@i_Coverage_Code_Tier_Desc	VARCHAR(2000)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CoverageCodes') IS NOT NULL
	DROP TABLE #CoverageCodes

CREATE TABLE #CoverageCodes
      (i_entity_name				VARCHAR(50)		DEFAULT('Coverage_Codes')
      ,i_key_coverage_code			VARCHAR(50)		DEFAULT('0')
      ,i_key_2_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_3_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_4_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_5_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_6_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_7_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_8_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_9_field				VARCHAR(50)		DEFAULT('0')
      ,i_key_10_field				VARCHAR(50)		DEFAULT('0')
      ,i_action						VARCHAR(10)		DEFAULT('ADD')
      ,i_Date_Time_Modified			VARCHAR(50)		DEFAULT('')
      ,iUserid						VARCHAR(25)		DEFAULT('')
      ,i_coverage_code				VARCHAR(20)
      ,i_coverage_code_desc			VARCHAR(100)
      ,i_num_of_subscribers			INT
      ,i_spouse_option				VARCHAR(50)
      ,i_min_dependents				VARCHAR(10)
      ,i_max_dependents				VARCHAR(10)
      ,i_hippa_cov_code				VARCHAR(50)
      ,i_Coverage_Code_Tier_ID		VARCHAR(55)
      ,i_Coverage_Code_Tier_Desc	VARCHAR(2000)
	  ,record_id					INT)

--*************************************************************************************************
-- Populate the table with data to be created
--*************************************************************************************************
INSERT INTO #CoverageCodes
      (i_coverage_code
	  ,i_coverage_code_desc
	  ,i_num_of_subscribers
	  ,i_spouse_option
	  ,i_min_dependents
	  ,i_max_dependents
	  ,i_hippa_cov_code
	  ,i_Coverage_Code_Tier_ID
	  ,i_Coverage_Code_Tier_Desc
	  ,record_id)
SELECT ISNULL([*CoverageCode], '')
	  ,ISNULL([*CoverageCodeDesc], '')
	  ,ISNULL([*NumOfSubscribers], '0')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SpouseOption]), 'N')
	  ,ISNULL([*MinNumDependents], '0')
	  ,ISNULL([*MaxNumDependents], '0')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*HIPAAEquivCovCode]), '')
	  ,ISNULL(COBRAOfferedCovTiers, '')
	  ,ISNULL(WizardRate, '')
	  ,RecordID
  FROM COREAUTO.CoreAutomation.dbo.TD_CoverageCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CoverageCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Coverage_Code_Cursor CURSOR FOR
 SELECT i_entity_name
	   ,i_key_coverage_code
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
	   ,i_coverage_code
	   ,i_coverage_code_desc
	   ,i_num_of_subscribers
	   ,i_spouse_option
	   ,i_min_dependents
	   ,i_max_dependents
	   ,i_hippa_cov_code
	   ,i_Coverage_Code_Tier_ID
	   ,i_Coverage_Code_Tier_Desc
	   ,record_id
   FROM #CoverageCodes


   OPEN Coverage_Code_Cursor
  FETCH NEXT FROM Coverage_Code_Cursor
   INTO @i_entity_name
	   ,@i_key_coverage_code
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
	   ,@i_coverage_code
	   ,@i_coverage_code_desc
	   ,@i_num_of_subscribers
	   ,@i_spouse_option
	   ,@i_min_dependents
	   ,@i_max_dependents
	   ,@i_hippa_cov_code
	   ,@i_Coverage_Code_Tier_ID
	   ,@i_Coverage_Code_Tier_Desc
	   ,@record_id

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @user_id_created = ''
		SELECT @user_id_created = ISNULL(user_id_created, '') FROM Coverage_Codes WHERE coverage_code = @i_coverage_code

		IF @user_id_created <> 'ScriptMod'
			BEGIN

				EXEC prCoverageCodeAddModify 
					 @i_entity_name
	 				,@i_key_coverage_code
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
					,@i_coverage_code
					,@i_coverage_code_desc
					,@i_num_of_subscribers
					,@i_spouse_option
					,@i_min_dependents
					,@i_max_dependents
					,@i_hippa_cov_code
					,@i_Coverage_Code_Tier_ID
					,@i_Coverage_Code_Tier_Desc
					,@o_status				= @err_num	OUTPUT
					,@o_message				= @err_msg	OUTPUT

				END
			ELSE
				BEGIN
					SET @err_num = -1
					SET @err_msg = 'Data created by ScriptMod, skipping...'
				END
						
		SELECT @status = CASE WHEN @err_num <> 0 THEN 'Skip' ELSE 'Add' END
		EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_coverage_code, @i_coverage_code_desc, '', @status, @err_num, @err_msg

		FETCH NEXT FROM Coverage_Code_Cursor
		 INTO @i_entity_name
			 ,@i_key_coverage_code
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
	   		 ,@i_coverage_code
	   		 ,@i_coverage_code_desc
	   		 ,@i_num_of_subscribers
	   		 ,@i_spouse_option
	   		 ,@i_min_dependents
	   		 ,@i_max_dependents
	   		 ,@i_hippa_cov_code
	   		 ,@i_Coverage_Code_Tier_ID
	   		 ,@i_Coverage_Code_Tier_Desc
	   		 ,@record_id
 
	END

CLOSE Coverage_Code_Cursor
DEALLOCATE Coverage_Code_Cursor

END
GO