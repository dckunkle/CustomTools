IF OBJECT_ID('dbo.spDCAuto_CreateRateMatrixAssignment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRateMatrixAssignment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRateMatrixAssignment
Purpose:    Create ratematrixassignment data from CorderAutomation

Screen:     9016
Method:     RateMatrixAssignment
Procedure:  dbo.prRateMatrixAddModify
Entity:     Rate_Matrix

Date        User            Change
---------------------------------------------------------------------------------------------
03/24/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRateMatrixAssignment '100-Config%', 22, 'RateMatrixAssignment'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRateMatrixAssignment
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

DECLARE @i_entity_name          VARCHAR(20)
       ,@i_key_1_field          VARCHAR(20)
       ,@i_key_2_field          VARCHAR(50)
       ,@i_key_3_field          VARCHAR(100)
       ,@i_key_4_field          VARCHAR(50)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(100)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(100)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(100)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(100)
       ,@iUserID                VARCHAR(25)
       ,@i_effective_date       VARCHAR(20)
       ,@i_termination_date     VARCHAR(50)
       ,@i_size                 VARCHAR(100)
       ,@i_calcOption           VARCHAR(50)
       ,@i_regionCode           VARCHAR(50)
       ,@iSmoking               VARCHAR(50)
       ,@iRegionDefID           VARCHAR(50)
       ,@iRegionDefDesc         VARCHAR(50)
       ,@i_productOffering_id   VARCHAR(50)
       ,@i_productOffering_desc VARCHAR(100)
       ,@i_planStrategy_id      VARCHAR(50)
       ,@i_planStrategy_desc    VARCHAR(150)
       ,@i_rateTable_id         VARCHAR(55)
       ,@i_rateTable_desc       VARCHAR(100)
       ,@i_last_renewal_date    VARCHAR(50)
       ,@i_group_id             VARCHAR(50)
       ,@i_group_desc           VARCHAR(100)
       ,@o_status               INT
       ,@o_message              VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RateMatrixAssignment') IS NOT NULL
	DROP TABLE #RateMatrixAssignment

CREATE TABLE #RateMatrixAssignment
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(20)       DEFAULT('Rate_Matrix')
      ,i_key_1_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(100)      DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(100)      DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,i_effective_date       VARCHAR(20)
      ,i_termination_date     VARCHAR(50)
      ,i_size                 VARCHAR(100)
      ,i_calcOption           VARCHAR(50)
      ,i_regionCode           VARCHAR(50)
      ,iSmoking               VARCHAR(50)
      ,iRegionDefID           VARCHAR(50)
      ,iRegionDefDesc         VARCHAR(50)
      ,i_productOffering_id   VARCHAR(50)
      ,i_productOffering_desc VARCHAR(100)
      ,i_planStrategy_id      VARCHAR(50)
      ,i_planStrategy_desc    VARCHAR(150)
      ,i_rateTable_id         VARCHAR(55)
      ,i_rateTable_desc       VARCHAR(100)
      ,i_last_renewal_date    VARCHAR(50)
      ,i_group_id             VARCHAR(50)
      ,i_group_desc           VARCHAR(100)
      ,o_status               INT
      ,o_message              VARCHAR(200)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #RateMatrixAssignment
          (SearchID
          ,i_effective_date
          ,i_termination_date
          ,i_size
          ,i_calcOption
          ,i_regionCode
          ,iSmoking
          ,iRegionDefID
          ,i_productOffering_id
          ,i_planStrategy_id
          ,i_rateTable_id
          ,i_last_renewal_date
          ,i_group_id
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*EffectiveDate], '01/01/1900')
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Size]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CalculationOption]), '1')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RegionCode]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SmokingIndicator]), 'U')
          ,ISNULL([RegionDefinitionID], '')
          ,ISNULL([ProductOfferingID], '')
          ,ISNULL([*PlanStrategyID], '')
          ,ISNULL([*RateTableID], '')
          ,ISNULL([*LastRenewalDate], '01/01/1900')
          ,ISNULL([GroupID], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_RateMatrixAssignment
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #RateMatrixAssignment
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
DECLARE RateMatrixAssignment_Cursor CURSOR FOR
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
       ,i_effective_date
       ,i_termination_date
       ,i_size
       ,i_calcOption
       ,i_regionCode
       ,iSmoking
       ,iRegionDefID
       ,iRegionDefDesc
       ,i_productOffering_id
       ,i_productOffering_desc
       ,i_planStrategy_id
       ,i_planStrategy_desc
       ,i_rateTable_id
       ,i_rateTable_desc
       ,i_last_renewal_date
       ,i_group_id
       ,i_group_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #RateMatrixAssignment

   OPEN RateMatrixAssignment_Cursor
  FETCH NEXT FROM RateMatrixAssignment_Cursor
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
       ,@i_effective_date
       ,@i_termination_date
       ,@i_size
       ,@i_calcOption
       ,@i_regionCode
       ,@iSmoking
       ,@iRegionDefID
       ,@iRegionDefDesc
       ,@i_productOffering_id
       ,@i_productOffering_desc
       ,@i_planStrategy_id
       ,@i_planStrategy_desc
       ,@i_rateTable_id
       ,@i_rateTable_desc
       ,@i_last_renewal_date
       ,@i_group_id
       ,@i_group_desc
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

			EXEC dbo.prRateMatrixAddModify
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
                ,@i_effective_date
                ,@i_termination_date
                ,@i_size
                ,@i_calcOption
                ,@i_regionCode
                ,@iSmoking
                ,@iRegionDefID
                ,@iRegionDefDesc
                ,@i_productOffering_id
                ,@i_productOffering_desc
                ,@i_planStrategy_id
                ,@i_planStrategy_desc
                ,@i_rateTable_id
                ,@i_rateTable_desc
                ,@i_last_renewal_date
                ,@i_group_id
                ,@i_group_desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Missing', '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM RateMatrixAssignment_Cursor
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
             ,@i_effective_date
             ,@i_termination_date
             ,@i_size
             ,@i_calcOption
             ,@i_regionCode
             ,@iSmoking
             ,@iRegionDefID
             ,@iRegionDefDesc
             ,@i_productOffering_id
             ,@i_productOffering_desc
             ,@i_planStrategy_id
             ,@i_planStrategy_desc
             ,@i_rateTable_id
             ,@i_rateTable_desc
             ,@i_last_renewal_date
             ,@i_group_id
             ,@i_group_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE RateMatrixAssignment_Cursor
DEALLOCATE RateMatrixAssignment_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#RateMatrixAssignment') IS NOT NULL
	DROP TABLE #RateMatrixAssignment

END
GO

