IF OBJECT_ID('dbo.spDCAuto_CreateMemberAdjustmentAmounts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberAdjustmentAmounts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberAdjustmentAmounts
Purpose:    Create memberadjustmentamounts data from CorderAutomation

Screen:     92
Method:     MemberAdjustmentAmounts
Procedure:  dbo.prMemberAdjAmntAdd 
Entity:     Member_Adjustment_Amounts

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberAdjustmentAmounts '100-Config%', 22, 'MemberAdjustmentAmounts'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberAdjustmentAmounts
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

DECLARE @i_entity_name              VARCHAR(50)
       ,@i_Contact_gid              VARCHAR(75)
       ,@i_Child_id                 VARCHAR(75)
       ,@i_Parent_gid               VARCHAR(75)
       ,@i_Parent_id                VARCHAR(75)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(75)
       ,@i_Group_gid                VARCHAR(75)
       ,@i_key_8_field              VARCHAR(75)
       ,@i_key_9_field              VARCHAR(75)
       ,@i_Member_ID                VARCHAR(75)
       ,@i_action                   VARCHAR(75)
       ,@i_Date_Time_Modified       VARCHAR(75)
       ,@iUserID                    VARCHAR(75)
       ,@i_Effective_Date           VARCHAR(50)
       ,@i_Termination_Date         VARCHAR(50)
       ,@i_Class_Variation          VARCHAR(50)
       ,@i_Network_Variation        VARCHAR(50)
       ,@i_Class_Grouping           VARCHAR(50)
       ,@i_Class_Grouping_Desc      VARCHAR(50)
       ,@i_Mbr_Adj_Deductible       VARCHAR(50)
       ,@i_Mbr_Adj_Out_of_Pocket    VARCHAR(50)
       ,@i_Mbr_Adj_Benefit          VARCHAR(50)
       ,@i_Family_Adj_Deductible    VARCHAR(50)
       ,@i_Family_Adj_Out_of_Pocket VARCHAR(50)
       ,@i_Family_Adj_Benefit       VARCHAR(50)
       ,@i_Wait_Unit                VARCHAR(50)
       ,@i_Wait_Amount              VARCHAR(50)
       ,@i_Apply_To_All             VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberAdjustmentAmounts') IS NOT NULL
	DROP TABLE #MemberAdjustmentAmounts

CREATE TABLE #MemberAdjustmentAmounts
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('Member_Adjustment_Amounts')
      ,i_Contact_gid              VARCHAR(75)       DEFAULT('0')
      ,i_Child_id                 VARCHAR(75)       DEFAULT('0')
      ,i_Parent_gid               VARCHAR(75)       DEFAULT('0')
      ,i_Parent_id                VARCHAR(75)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(75)       DEFAULT('0')
      ,i_Group_gid                VARCHAR(75)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(75)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(75)       DEFAULT('0')
      ,i_Member_ID                VARCHAR(75)       DEFAULT('0')
      ,i_action                   VARCHAR(75)       DEFAULT('ADD')
      ,i_Date_Time_Modified       VARCHAR(75)       DEFAULT('')
      ,iUserID                    VARCHAR(75)       DEFAULT('')
      ,i_Effective_Date           VARCHAR(50)
      ,i_Termination_Date         VARCHAR(50)
      ,i_Class_Variation          VARCHAR(50)
      ,i_Network_Variation        VARCHAR(50)
      ,i_Class_Grouping           VARCHAR(50)
      ,i_Class_Grouping_Desc      VARCHAR(50)
      ,i_Mbr_Adj_Deductible       VARCHAR(50)
      ,i_Mbr_Adj_Out_of_Pocket    VARCHAR(50)
      ,i_Mbr_Adj_Benefit          VARCHAR(50)
      ,i_Family_Adj_Deductible    VARCHAR(50)
      ,i_Family_Adj_Out_of_Pocket VARCHAR(50)
      ,i_Family_Adj_Benefit       VARCHAR(50)
      ,i_Wait_Unit                VARCHAR(50)
      ,i_Wait_Amount              VARCHAR(50)
      ,i_Apply_To_All             VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(255)
      ,record_id                  INT
      ,static_gid                 INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #MemberAdjustmentAmounts
          (SearchID
          ,i_Effective_Date
          ,i_Termination_Date
          ,i_Class_Variation
          ,i_Network_Variation
          ,i_Class_Grouping
          ,i_Mbr_Adj_Deductible
          ,i_Mbr_Adj_Out_of_Pocket
          ,i_Mbr_Adj_Benefit
          ,i_Family_Adj_Deductible
          ,i_Family_Adj_Out_of_Pocket
          ,i_Family_Adj_Benefit
          ,i_Wait_Unit
          ,i_Wait_Amount
          ,i_Apply_To_All
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClassVariation]), '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), '*')
          ,ISNULL([ClassGroupingID], '')
          ,ISNULL([*IndividualDeductible], '0.00')
          ,ISNULL([*IndividualOutOfPocket], '0.00')
          ,ISNULL([*IndividualMaximum], '0.00')
          ,ISNULL([*FamilyDeductible], '0.00')
          ,ISNULL([*FamilyOutOfPocket], '0.00')
          ,ISNULL([*FamilyMaximum], '0.00')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([WaitPeriodUnits]), 'M')
          ,ISNULL([*WaitPeriodAmount], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApplyWaitPeriodToAllFamilyMembers]), 'Y')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_MemberAdjustmentAmounts
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #MemberAdjustmentAmounts
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
DECLARE MemberAdjustmentAmounts_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Contact_gid
       ,i_Child_id
       ,i_Parent_gid
       ,i_Parent_id
       ,i_key_5_field
       ,i_key_6_field
       ,i_Group_gid
       ,i_key_8_field
       ,i_key_9_field
       ,i_Member_ID
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Class_Variation
       ,i_Network_Variation
       ,i_Class_Grouping
       ,i_Class_Grouping_Desc
       ,i_Mbr_Adj_Deductible
       ,i_Mbr_Adj_Out_of_Pocket
       ,i_Mbr_Adj_Benefit
       ,i_Family_Adj_Deductible
       ,i_Family_Adj_Out_of_Pocket
       ,i_Family_Adj_Benefit
       ,i_Wait_Unit
       ,i_Wait_Amount
       ,i_Apply_To_All
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberAdjustmentAmounts

   OPEN MemberAdjustmentAmounts_Cursor
  FETCH NEXT FROM MemberAdjustmentAmounts_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Contact_gid
       ,@i_Child_id
       ,@i_Parent_gid
       ,@i_Parent_id
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_Group_gid
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Member_ID
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Class_Variation
       ,@i_Network_Variation
       ,@i_Class_Grouping
       ,@i_Class_Grouping_Desc
       ,@i_Mbr_Adj_Deductible
       ,@i_Mbr_Adj_Out_of_Pocket
       ,@i_Mbr_Adj_Benefit
       ,@i_Family_Adj_Deductible
       ,@i_Family_Adj_Out_of_Pocket
       ,@i_Family_Adj_Benefit
       ,@i_Wait_Unit
       ,@i_Wait_Amount
       ,@i_Apply_To_All
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

			-- Get the GIDS for the member and group
			SELECT @i_Contact_gid			= EC.child_gid
				  ,@i_Child_id				= EC.child_identifier
			      ,@i_Parent_gid			= EC.parent_gid
				  ,@i_Parent_id				= EC.parent_identifier
				  ,@i_Group_gid				= EC.group_gid
				  ,@i_Member_ID				= EC.member_id
			  FROM Eligibility_Coverage		EC
			 WHERE EC.record_status			= 'A'
			   AND EC.child_gid				= EC.parent_gid
			   AND EC.member_id				= @SearchID

			EXEC dbo.prMemberAdjAmntAdd 
                 @i_entity_name
                ,@i_Contact_gid
                ,@i_Child_id
                ,@i_Parent_gid
                ,@i_Parent_id
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_Group_gid
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_Member_ID
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@i_Effective_Date
                ,@i_Termination_Date
                ,@i_Class_Variation
                ,@i_Network_Variation
                ,@i_Class_Grouping
                ,@i_Class_Grouping_Desc
                ,@i_Mbr_Adj_Deductible
                ,@i_Mbr_Adj_Out_of_Pocket
                ,@i_Mbr_Adj_Benefit
                ,@i_Family_Adj_Deductible
                ,@i_Family_Adj_Out_of_Pocket
                ,@i_Family_Adj_Benefit
                ,@i_Wait_Unit
                ,@i_Wait_Amount
                ,@i_Apply_To_All
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		IF @i_Contact_gid = 0
			BEGIN
				SELECT @err_num = 200
				      ,@err_msg = 'Member not found.'
			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Member_ID, @i_Class_Variation, @i_Network_Variation, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberAdjustmentAmounts_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Contact_gid
             ,@i_Child_id
             ,@i_Parent_gid
             ,@i_Parent_id
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_Group_gid
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Member_ID
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Class_Variation
             ,@i_Network_Variation
             ,@i_Class_Grouping
             ,@i_Class_Grouping_Desc
             ,@i_Mbr_Adj_Deductible
             ,@i_Mbr_Adj_Out_of_Pocket
             ,@i_Mbr_Adj_Benefit
             ,@i_Family_Adj_Deductible
             ,@i_Family_Adj_Out_of_Pocket
             ,@i_Family_Adj_Benefit
             ,@i_Wait_Unit
             ,@i_Wait_Amount
             ,@i_Apply_To_All
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberAdjustmentAmounts_Cursor
DEALLOCATE MemberAdjustmentAmounts_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#MemberAdjustmentAmounts') IS NOT NULL
	DROP TABLE #MemberAdjustmentAmounts

END
GO

