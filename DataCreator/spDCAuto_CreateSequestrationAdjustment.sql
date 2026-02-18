IF OBJECT_ID('dbo.spDCAuto_CreateSequestrationAdjustment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateSequestrationAdjustment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateSequestrationAdjustment
Purpose:    Create sequestrationadjustment data from CorderAutomation
Method:     SequestrationAdjustment
Screen GID: 4900
Procedure:  dbo.prSequestrationAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
03/09/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateSequestrationAdjustment '100-Config%', 22, 'SequestrationAdjustment'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateSequestrationAdjustment
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

DECLARE @iEntityName         VARCHAR(20)
       ,@iRuleGid            VARCHAR(20)
       ,@iKey_2_field        VARCHAR(50)
       ,@iKey_3_field        VARCHAR(50)
       ,@iKey_4_field        VARCHAR(50)
       ,@iKey_5_field        VARCHAR(50)
       ,@iKey_6_field        VARCHAR(50)
       ,@iKey_7_field        VARCHAR(50)
       ,@iKey_8_field        VARCHAR(50)
       ,@iKey_9_field        VARCHAR(50)
       ,@iRuleSid            VARCHAR(50)
       ,@iAction             VARCHAR(10)
       ,@iDate_Time_Modified VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iRuleID             VARCHAR(50)
       ,@iRuleDesc           VARCHAR(100)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#SequestrationAdjustment') IS NOT NULL
	DROP TABLE #SequestrationAdjustment

CREATE TABLE #SequestrationAdjustment
      (SearchID            VARCHAR(200)
      ,iEntityName         VARCHAR(20)       DEFAULT('Sequestration')
      ,iRuleGid            VARCHAR(20)       DEFAULT('0')
      ,iKey_2_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_3_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_4_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_5_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_7_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_9_field        VARCHAR(50)       DEFAULT('0')
      ,iRuleSid            VARCHAR(50)       DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iRuleID             VARCHAR(50)
      ,iRuleDesc           VARCHAR(100)
      ,o_status            INT
      ,o_message           VARCHAR(255)
      ,record_id           INT
      ,static_gid          INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #SequestrationAdjustment
      (SearchID
      ,iRuleID
      ,iRuleDesc
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*SequestrationAdjustmentID], '')
      ,ISNULL([*SequestrationAdjustmentDesc], '')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_SequestrationAdjustment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #SequestrationAdjustment
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE SequestrationAdjustment_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iRuleGid
       ,iKey_2_field
       ,iKey_3_field
       ,iKey_4_field
       ,iKey_5_field
       ,iKey_6_field
       ,iKey_7_field
       ,iKey_8_field
       ,iKey_9_field
       ,iRuleSid
       ,iAction
       ,iDate_Time_Modified
       ,iUserID
       ,iRuleID
       ,iRuleDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #SequestrationAdjustment

   OPEN SequestrationAdjustment_Cursor
  FETCH NEXT FROM SequestrationAdjustment_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iRuleGid
       ,@iKey_2_field
       ,@iKey_3_field
       ,@iKey_4_field
       ,@iKey_5_field
       ,@iKey_6_field
       ,@iKey_7_field
       ,@iKey_8_field
       ,@iKey_9_field
       ,@iRuleSid
       ,@iAction
       ,@iDate_Time_Modified
       ,@iUserID
       ,@iRuleID
       ,@iRuleDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prSequestrationAddModify
				 @iEntityName
				,@iRuleGid
				,@iKey_2_field
				,@iKey_3_field
				,@iKey_4_field
				,@iKey_5_field
				,@iKey_6_field
				,@iKey_7_field
				,@iKey_8_field
				,@iKey_9_field
				,@iRuleSid
				,@iAction
				,@iDate_Time_Modified
				,@iUserID
				,@iRuleID
				,@iRuleDesc
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Sequestration'
				   AND entity_user_id			= @iRuleID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRuleID, @iRuleDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM SequestrationAdjustment_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iRuleGid
             ,@iKey_2_field
             ,@iKey_3_field
             ,@iKey_4_field
             ,@iKey_5_field
             ,@iKey_6_field
             ,@iKey_7_field
             ,@iKey_8_field
             ,@iKey_9_field
             ,@iRuleSid
             ,@iAction
             ,@iDate_Time_Modified
             ,@iUserID
             ,@iRuleID
             ,@iRuleDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE SequestrationAdjustment_Cursor
DEALLOCATE SequestrationAdjustment_Cursor

END
GO