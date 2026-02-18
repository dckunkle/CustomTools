IF OBJECT_ID('dbo.spDCAuto_CreateRateTable') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRateTable AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRateTable
Purpose:    Create ratetable data from CorderAutomation
Method:     RateTable
Screen GID: 320
Procedure:  dbo.prRateTableAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/04/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRateTable '100-Config%', 22, 'RateTable'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRateTable
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_Entity_name               VARCHAR(20)
       ,@k_Rate_Table_GID            VARCHAR(100)
       ,@i_key_2_field               VARCHAR(50)
       ,@i_key_3_field               VARCHAR(50)
       ,@i_key_4_field               VARCHAR(20)
       ,@i_key_5_field               VARCHAR(50)
       ,@i_key_6_field               VARCHAR(10)
       ,@i_key_7_field               VARCHAR(50)
       ,@i_key_8_field               VARCHAR(20)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_key_10_field              VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_Date_Time_Modified        CHAR(30)
       ,@iUserID                     VARCHAR(25)
       ,@i_rate_table_id             VARCHAR(55)
       ,@i_rate_table_desc           VARCHAR(55)
       ,@i_rate_basis                VARCHAR(50)
       ,@i_financial_code            VARCHAR(50)
       ,@i_CoverageTiersID           VARCHAR(55)
       ,@i_CoverageTiersDesc         VARCHAR(2000)
       ,@i_gender_rating             VARCHAR(50)
       ,@i_age_rating                VARCHAR(50)
       ,@i_AgeBandID                 VARCHAR(55)
       ,@i_AgeBandDesc               VARCHAR(2000)
       ,@iACARating                  VARCHAR(50)
       ,@iNumDeps                    VARCHAR(50)
       ,@i_rate_xml                  VARCHAR(MAX)
       ,@i_SecDeposit_financial_code VARCHAR(50)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DCRateTable') IS NOT NULL
	DROP TABLE #DCRateTable

CREATE TABLE #DCRateTable
      (i_Entity_name               VARCHAR(20)       DEFAULT('Rate_Table')
      ,k_Rate_Table_GID            VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field               VARCHAR(20)       DEFAULT('0')
      ,i_key_5_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field               VARCHAR(10)       DEFAULT('0')
      ,i_key_7_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(20)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified        CHAR(30)          DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,i_rate_table_id             VARCHAR(55)
      ,i_rate_table_desc           VARCHAR(55)
      ,i_rate_basis                VARCHAR(50)
      ,i_financial_code            VARCHAR(50)
      ,i_CoverageTiersID           VARCHAR(55)
      ,i_CoverageTiersDesc         VARCHAR(2000)
      ,i_gender_rating             VARCHAR(50)
      ,i_age_rating                VARCHAR(50)
      ,i_AgeBandID                 VARCHAR(55)
      ,i_AgeBandDesc               VARCHAR(2000)
      ,iACARating                  VARCHAR(50)
      ,iNumDeps                    VARCHAR(50)
      ,i_rate_xml                  VARCHAR(MAX)
      ,i_SecDeposit_financial_code VARCHAR(50)
      ,o_status                    INT
      ,o_message                   VARCHAR(255)
      ,record_id                   INT
      ,static_gid                  INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #DCRateTable
      (i_rate_table_id
      ,i_rate_table_desc
      ,i_rate_basis
      ,i_financial_code
      ,i_CoverageTiersID
      ,i_gender_rating
      ,i_age_rating
      ,i_AgeBandID
      ,iACARating
      ,iNumDeps
      ,i_SecDeposit_financial_code
      ,record_id
      ,static_gid)
SELECT ISNULL([*RateTableID], '')
      ,ISNULL([*RateTableDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*RateAmountBasis]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*FinancialCode]), 'Missing')
      ,ISNULL([*CoverageTiersID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GenderRating]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AgeRating]), 'N')
      ,ISNULL([AgeBandID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PerMemberRating]), 'N')
      ,ISNULL([NumDepsUnder21], '3')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SecurityDepFinanceCode]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_RateTable
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #DCRateTable
   SET iUserID  = @user

UPDATE #DCRateTable
   SET i_rate_xml = dbo.fnDCAuto_GetRateTableXML(i_rate_table_id, i_CoverageTiersID)

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE RateTable_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,k_Rate_Table_GID
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
       ,i_Date_Time_Modified
       ,iUserID
       ,i_rate_table_id
       ,i_rate_table_desc
       ,i_rate_basis
       ,i_financial_code
       ,i_CoverageTiersID
       ,i_CoverageTiersDesc
       ,i_gender_rating
       ,i_age_rating
       ,i_AgeBandID
       ,i_AgeBandDesc
       ,iACARating
       ,iNumDeps
       ,i_rate_xml
       ,i_SecDeposit_financial_code
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #DCRateTable

   OPEN RateTable_Cursor
  FETCH NEXT FROM RateTable_Cursor
   INTO @i_Entity_name
       ,@k_Rate_Table_GID
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
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_rate_table_id
       ,@i_rate_table_desc
       ,@i_rate_basis
       ,@i_financial_code
       ,@i_CoverageTiersID
       ,@i_CoverageTiersDesc
       ,@i_gender_rating
       ,@i_age_rating
       ,@i_AgeBandID
       ,@i_AgeBandDesc
       ,@iACARating
       ,@iNumDeps
       ,@i_rate_xml
       ,@i_SecDeposit_financial_code
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Check to see if the rate table is trying to use gender or age banding (currently not supported)
		IF @i_AgeBandID != '' OR  @i_gender_rating != 'N'
			BEGIN

				SELECT @status		= 'Error'
				      ,@err_num		= 16
					  ,@err_msg		= 'The Data Creator doesn''t currently support rate tables that use gender or age bands.'

				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Unsupported option.', '', '', @status, @err_num, @err_msg

			END

		ELSE

			BEGIN
				--SELECT @i_rate_xml = dbo.fnDCAuto_GetRateTableXML(@i_rate_table_id, @i_CoverageTiersID)

				EXEC dbo.prRateTableAddModify
					 @i_Entity_name
					,@k_Rate_Table_GID
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
					,@i_Date_Time_Modified
					,@iUserID
					,@i_rate_table_id
					,@i_rate_table_desc
					,@i_rate_basis
					,@i_financial_code
					,@i_CoverageTiersID
					,@i_CoverageTiersDesc
					,@i_gender_rating
					,@i_age_rating
					,@i_AgeBandID
					,@i_AgeBandDesc
					,@iACARating
					,@iNumDeps
					,@i_rate_xml
					,@i_SecDeposit_financial_code
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT

				   -- Update the GIDs
					IF ISNULL(@static_gid, 0) > 0
						BEGIN

							SELECT @current_gid				= rate_table_gid
							  FROM Rate_Table_Definition	RTD
							 WHERE RTD.record_status		= 'A'
							   AND RTD.rate_table_id		= @i_rate_table_id

							-- Update to the static gid
							UPDATE dbo.Rate_Table_Definition 
							   SET rate_table_gid			= @static_gid 
							 WHERE record_status			= 'A'
							   AND rate_table_gid			= @current_gid

							UPDATE dbo.Rate_Table_Details	
							   SET rate_table_gid			= @static_gid 
							 WHERE record_status			= 'A'
							   AND rate_table_gid			= @current_gid

						END

				SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_rate_table_id, @i_rate_table_desc, '', @status, @err_num, @err_msg

			END

        FETCH NEXT FROM RateTable_Cursor
         INTO @i_Entity_name
             ,@k_Rate_Table_GID
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
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_rate_table_id
             ,@i_rate_table_desc
             ,@i_rate_basis
             ,@i_financial_code
             ,@i_CoverageTiersID
             ,@i_CoverageTiersDesc
             ,@i_gender_rating
             ,@i_age_rating
             ,@i_AgeBandID
             ,@i_AgeBandDesc
             ,@iACARating
             ,@iNumDeps
             ,@i_rate_xml
             ,@i_SecDeposit_financial_code
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE RateTable_Cursor
DEALLOCATE RateTable_Cursor

END
GO