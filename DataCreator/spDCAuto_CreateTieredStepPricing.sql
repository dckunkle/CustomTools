/**************************************************************************************************
Name:       spDCAuto_CreateTieredStepPricing
Purpose:    Create tieredsteppricing data from CorderAutomation

Screen:     9359
Method:     TieredStepPricing
Procedure:  dbo.prTieredStep_AddCopy
Entity:     Tiered_Step_Pricing

Date        User            Change
---------------------------------------------------------------------------------------------
07/24/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTieredStepPricing '100-Config%', 22, 'TieredStepPricing'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateTieredStepPricing
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

DECLARE @iEntityName         VARCHAR(50)
       ,@iKey_1_field        VARCHAR(100)
       ,@iKey_2_field        VARCHAR(50)
       ,@iKey_3_field        VARCHAR(50)
       ,@iKey_4_field        VARCHAR(50)
       ,@iKey_5_field        VARCHAR(50)
       ,@iKey_6_field        VARCHAR(50)
       ,@iKey_7_field        VARCHAR(50)
       ,@iKey_8_field        VARCHAR(50)
       ,@iKey_9_field        VARCHAR(50)
       ,@iKey_10_field       VARCHAR(50)
       ,@iAction             VARCHAR(10)
       ,@iDate_Time_Modified VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iNewStrategyID      VARCHAR(50)
       ,@iNewStrategyDesc    VARCHAR(100)
       ,@iCopyStrategyID     VARCHAR(50)
       ,@iCopytrategyDesc    VARCHAR(100)
       ,@i_tier_basis        VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TieredStepPricing') IS NOT NULL
	DROP TABLE #TieredStepPricing

CREATE TABLE #TieredStepPricing
      (SearchID            VARCHAR(200)
      ,iEntityName         VARCHAR(50)       DEFAULT('Tiered_Step_Pricing')
      ,iKey_1_field        VARCHAR(100)      DEFAULT('0')
      ,iKey_2_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_3_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_4_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_5_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_7_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_9_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_10_field       VARCHAR(50)       DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iNewStrategyID      VARCHAR(50)
      ,iNewStrategyDesc    VARCHAR(100)
      ,iCopyStrategyID     VARCHAR(50)
      ,iCopytrategyDesc    VARCHAR(100)
      ,i_tier_basis        VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(255)
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

    INSERT INTO #TieredStepPricing
          (SearchID
          ,iNewStrategyID
          ,iNewStrategyDesc
          ,iCopyStrategyID
          ,i_tier_basis
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*ID], '')
          ,ISNULL([*Desc], '')
          ,ISNULL([CopyFromID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*TierBasis]), 'U')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_TieredStepPricing
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #TieredStepPricing
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
DECLARE TieredStepPricing_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iKey_1_field
       ,iKey_2_field
       ,iKey_3_field
       ,iKey_4_field
       ,iKey_5_field
       ,iKey_6_field
       ,iKey_7_field
       ,iKey_8_field
       ,iKey_9_field
       ,iKey_10_field
       ,iAction
       ,iDate_Time_Modified
       ,iUserID
       ,iNewStrategyID
       ,iNewStrategyDesc
       ,iCopyStrategyID
       ,iCopytrategyDesc
       ,i_tier_basis
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TieredStepPricing

   OPEN TieredStepPricing_Cursor
  FETCH NEXT FROM TieredStepPricing_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iKey_1_field
       ,@iKey_2_field
       ,@iKey_3_field
       ,@iKey_4_field
       ,@iKey_5_field
       ,@iKey_6_field
       ,@iKey_7_field
       ,@iKey_8_field
       ,@iKey_9_field
       ,@iKey_10_field
       ,@iAction
       ,@iDate_Time_Modified
       ,@iUserID
       ,@iNewStrategyID
       ,@iNewStrategyDesc
       ,@iCopyStrategyID
       ,@iCopytrategyDesc
       ,@i_tier_basis
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

			EXEC dbo.prTieredStep_AddCopy
                 @iEntityName
                ,@iKey_1_field
                ,@iKey_2_field
                ,@iKey_3_field
                ,@iKey_4_field
                ,@iKey_5_field
                ,@iKey_6_field
                ,@iKey_7_field
                ,@iKey_8_field
                ,@iKey_9_field
                ,@iKey_10_field
                ,@iAction
                ,@iDate_Time_Modified
                ,@iUserID
                ,@iNewStrategyID
                ,@iNewStrategyDesc
                ,@iCopyStrategyID
                ,@iCopytrategyDesc
                ,@i_tier_basis
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Tiered_Step_Pricing'
				   AND entity_user_id			= @iNewStrategyID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iNewStrategyID, @iNewStrategyDesc, @i_tier_basis, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM TieredStepPricing_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iKey_1_field
             ,@iKey_2_field
             ,@iKey_3_field
             ,@iKey_4_field
             ,@iKey_5_field
             ,@iKey_6_field
             ,@iKey_7_field
             ,@iKey_8_field
             ,@iKey_9_field
             ,@iKey_10_field
             ,@iAction
             ,@iDate_Time_Modified
             ,@iUserID
             ,@iNewStrategyID
             ,@iNewStrategyDesc
             ,@iCopyStrategyID
             ,@iCopytrategyDesc
             ,@i_tier_basis
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TieredStepPricing_Cursor
DEALLOCATE TieredStepPricing_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#TieredStepPricing') IS NOT NULL
	DROP TABLE #TieredStepPricing

END
GO

