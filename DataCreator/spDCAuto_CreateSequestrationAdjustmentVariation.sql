IF OBJECT_ID('dbo.spDCAuto_CreateSequestrationAdjustmentVariation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateSequestrationAdjustmentVariation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateSequestrationAdjustmentVariation
Purpose:    Create sequestrationadjustmentvariation data from CorderAutomation
Method:     SequestrationAdjustmentVariation
Screen GID: 4901
Procedure:  dbo.prSequestrationVarAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
03/09/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateSequestrationAdjustmentVariation '100-Config%', 22, 'SequestrationAdjustmentVariation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateSequestrationAdjustmentVariation
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

DECLARE @iEntityName           VARCHAR(50)
       ,@iRuleGid              VARCHAR(50)
       ,@iKey_2_field          VARCHAR(10)
       ,@iKey_3_field          VARCHAR(10)
       ,@iKey_4_field          VARCHAR(10)
       ,@iKey_5_field          VARCHAR(50)
       ,@iKey_6_field          VARCHAR(20)
       ,@iKey_7_field          VARCHAR(50)
       ,@iKey_8_field          VARCHAR(50)
       ,@iKey_9_field          VARCHAR(50)
       ,@iRuleSid              VARCHAR(50)
       ,@iAction               VARCHAR(10)
       ,@iDate_Time_Modified   VARCHAR(50)
       ,@iUserID               VARCHAR(25)
       ,@iRuleID               VARCHAR(50)
       ,@iRuleDesc             VARCHAR(100)
       ,@iEffectiveDate        DATETIME
       ,@iTerminationDate      DATETIME
       ,@iPercentage           DECIMAL(5)
       ,@iBusinessUnitListID   VARCHAR(50)
       ,@iBusinessUnitListDesc VARCHAR(500)
       ,@o_status              INT
       ,@o_message             VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#SequestrationAdjustmentVariation') IS NOT NULL
	DROP TABLE #SequestrationAdjustmentVariation

CREATE TABLE #SequestrationAdjustmentVariation
      (SearchID              VARCHAR(200)
      ,iEntityName           VARCHAR(50)       DEFAULT('Sequestration_Var')
      ,iRuleGid              VARCHAR(50)       DEFAULT('0')
      ,iKey_2_field          VARCHAR(10)       DEFAULT('0')
      ,iKey_3_field          VARCHAR(10)       DEFAULT('0')
      ,iKey_4_field          VARCHAR(10)       DEFAULT('0')
      ,iKey_5_field          VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field          VARCHAR(20)       DEFAULT('0')
      ,iKey_7_field          VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field          VARCHAR(50)       DEFAULT('0')
      ,iKey_9_field          VARCHAR(50)       DEFAULT('0')
      ,iRuleSid              VARCHAR(50)       DEFAULT('0')
      ,iAction               VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified   VARCHAR(50)       DEFAULT('')
      ,iUserID               VARCHAR(25)       DEFAULT('')
      ,iRuleID               VARCHAR(50)
      ,iRuleDesc             VARCHAR(100)
      ,iEffectiveDate        DATETIME
      ,iTerminationDate      DATETIME
      ,iPercentage           DECIMAL(5)
      ,iBusinessUnitListID   VARCHAR(50)
      ,iBusinessUnitListDesc VARCHAR(500)
      ,o_status              INT
      ,o_message             VARCHAR(255)
      ,record_id             INT
      ,static_gid            INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #SequestrationAdjustmentVariation
      (SearchID
      ,iEffectiveDate
      ,iTerminationDate
      ,iPercentage
      ,iBusinessUnitListID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], '01/01/1900')
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([*Percentage], '0.00')
      ,ISNULL([BusinessUnitListID], '')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_SequestrationAdjustmentVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #SequestrationAdjustmentVariation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE SequestrationAdjustmentVariation_Cursor CURSOR FOR
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
       ,iEffectiveDate
       ,iTerminationDate
       ,iPercentage
       ,iBusinessUnitListID
       ,iBusinessUnitListDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #SequestrationAdjustmentVariation

   OPEN SequestrationAdjustmentVariation_Cursor
  FETCH NEXT FROM SequestrationAdjustmentVariation_Cursor
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
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iPercentage
       ,@iBusinessUnitListID
       ,@iBusinessUnitListDesc
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

			-- Lookup the Copay Levels gid
			SELECT @iRuleGid				= entity_gid
			  FROM Entity_Names
			 WHERE entity_identifier		= 'Sequestration'
			   AND entity_user_id			= @SearchID

			EXEC dbo.prSequestrationVarAddModify
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
				,@iEffectiveDate
				,@iTerminationDate
				,@iPercentage
				,@iBusinessUnitListID
				,@iBusinessUnitListDesc
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRuleID, @iPercentage, @iBusinessUnitListID, @status, @err_num, @err_msg

        FETCH NEXT FROM SequestrationAdjustmentVariation_Cursor
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
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iPercentage
             ,@iBusinessUnitListID
             ,@iBusinessUnitListDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE SequestrationAdjustmentVariation_Cursor
DEALLOCATE SequestrationAdjustmentVariation_Cursor

END
GO