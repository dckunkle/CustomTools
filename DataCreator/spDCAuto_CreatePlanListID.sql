/**************************************************************************************************
Name:       spDCAuto_CreatePlanListID
Purpose:    Create planlistid data from CorderAutomation

Screen:     10002
Method:     PlanListID
Procedure:  dbo.prPlanListAddModify
Entity:     Plan_List

Date        User            Change
---------------------------------------------------------------------------------------------
09/02/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePlanListID '100-Config%', 22, 'PlanListID'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreatePlanListID
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
       ,@i_planlist_gid       VARCHAR(50)
       ,@i_key_2_field        VARCHAR(20)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified VARCHAR(10)
       ,@iUserID              VARCHAR(25)
       ,@iPlanListid          VARCHAR(50)
       ,@iPlanListDesc        VARCHAR(150)
       ,@iExclude             VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PlanListID') IS NOT NULL
	DROP TABLE #PlanListID

CREATE TABLE #PlanListID
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Plan_List')
      ,i_planlist_gid       VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(10)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iPlanListid          VARCHAR(50)
      ,iPlanListDesc        VARCHAR(150)
      ,iExclude             VARCHAR(50)
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
BEGIN TRY

    INSERT INTO #PlanListID
          (SearchID
          ,iPlanListid
          ,iPlanListDesc
          ,iExclude
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*PlanListID], '')
          ,ISNULL([*PlanListDescription], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Exclude]), 'N')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_PlanListID
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #PlanListID
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
DECLARE PlanListID_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_planlist_gid
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
       ,iPlanListid
       ,iPlanListDesc
       ,iExclude
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #PlanListID

   OPEN PlanListID_Cursor
  FETCH NEXT FROM PlanListID_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_planlist_gid
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
       ,@iPlanListid
       ,@iPlanListDesc
       ,@iExclude
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

			EXEC dbo.prPlanListAddModify
                 @i_entity_name
                ,@i_planlist_gid
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
                ,@iPlanListid
                ,@iPlanListDesc
                ,@iExclude
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Plan_List'
				   AND entity_user_id			= @iPlanListid

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iPlanListid, @iPlanListDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM PlanListID_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_planlist_gid
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
             ,@iPlanListid
             ,@iPlanListDesc
             ,@iExclude
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE PlanListID_Cursor
DEALLOCATE PlanListID_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#PlanListID') IS NOT NULL
	DROP TABLE #PlanListID

END
GO

