IF OBJECT_ID('dbo.spDCAuto_CreatePriceStrategy') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePriceStrategy AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePriceStrategy
Purpose:    Create pricestrategy data from CorderAutomation
Method:     PriceStrategy
Screen GID: 197
Procedure:  dbo.prEntityStrategyAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/12/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePriceStrategy '100-Config%', 22, 'PriceStrategy'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePriceStrategy
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

DECLARE @iEntityName         VARCHAR(50)
       ,@iKey_1_field        VARCHAR(200)
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
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PriceStrategy') IS NOT NULL
	DROP TABLE #PriceStrategy

CREATE TABLE #PriceStrategy
      (iEntityName         VARCHAR(50)       DEFAULT('Price_Strategy')
      ,iKey_1_field        VARCHAR(200)      DEFAULT('0')
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
      ,o_status            INT
      ,o_message           VARCHAR(255)
      ,record_id           INT
      ,static_gid          INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #PriceStrategy
      (iNewStrategyID
      ,iNewStrategyDesc
      ,iCopyStrategyID
      ,record_id
      ,static_gid)
SELECT ISNULL([*NewPriceStrategyID], '')
      ,ISNULL([*NewPriceStrategyDesc], '')
      ,ISNULL([CopyFromPriceStrategyID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PriceStrategy
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #PriceStrategy
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE PriceStrategy_Cursor CURSOR FOR
 SELECT iEntityName
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
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PriceStrategy

   OPEN PriceStrategy_Cursor
  FETCH NEXT FROM PriceStrategy_Cursor
   INTO @iEntityName
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
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prEntityStrategyAdd
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
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		-- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'PRICE_STRATEGY'
				   AND entity_user_id			= @iNewStrategyID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iNewStrategyID, @iNewStrategyDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM PriceStrategy_Cursor
         INTO @iEntityName
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
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PriceStrategy_Cursor
DEALLOCATE PriceStrategy_Cursor

END
GO