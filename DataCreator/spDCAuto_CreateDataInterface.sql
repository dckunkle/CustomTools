IF OBJECT_ID('dbo.spDCAuto_CreateDataInterface') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateDataInterface AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateDataInterface
Purpose:    Create datainterface data from CorderAutomation
Method:     DataInterface
Screen GID: 49
Procedure:  dbo.prDataInterfaceAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateDataInterface '100-Config%', 22, 'DataInterface'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateDataInterface
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
       ,@i_key_RuleGid          VARCHAR(20)
       ,@i_key_effective_date   VARCHAR(100)
       ,@i_key_termination_date VARCHAR(10)
       ,@i_key_priority         VARCHAR(100)
       ,@i_key_sid              VARCHAR(50)
       ,@i_key_6_field          VARCHAR(100)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(50)
       ,@iUserID                VARCHAR(25)
       ,@i_Effective_Date       VARCHAR(50)
       ,@i_Termination_Date     VARCHAR(50)
       ,@i_Interface_type       VARCHAR(50)
       ,@i_Priority             VARCHAR(50)
       ,@i_Group_List_ID        VARCHAR(50)
       ,@i_Group_List_Desc      VARCHAR(100)
       ,@i_Member_Match_ID      VARCHAR(50)
       ,@i_Member_Match_Desc    VARCHAR(100)
       ,@o_status               INT
       ,@o_message              VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DataInterface') IS NOT NULL
	DROP TABLE #DataInterface

CREATE TABLE #DataInterface
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(20)       DEFAULT('Data_Interface')
      ,i_key_RuleGid          VARCHAR(20)       DEFAULT('0')
      ,i_key_effective_date   VARCHAR(100)      DEFAULT('0')
      ,i_key_termination_date VARCHAR(10)       DEFAULT('0')
      ,i_key_priority         VARCHAR(100)      DEFAULT('0')
      ,i_key_sid              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(50)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,i_Effective_Date       VARCHAR(50)
      ,i_Termination_Date     VARCHAR(50)
      ,i_Interface_type       VARCHAR(50)
      ,i_Priority             VARCHAR(50)
      ,i_Group_List_ID        VARCHAR(50)
      ,i_Group_List_Desc      VARCHAR(100)
      ,i_Member_Match_ID      VARCHAR(50)
      ,i_Member_Match_Desc    VARCHAR(100)
      ,o_status               INT
      ,o_message              VARCHAR(100)
      ,record_id              INT
      ,static_gid             INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #DataInterface
      (SearchID
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Interface_type
      ,i_Priority
      ,i_Group_List_ID
      ,i_Member_Match_ID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Type]), '')
      ,ISNULL([*Priority], '-1')
      ,ISNULL([GroupListID], '')
      ,ISNULL([*MemberMatchID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_DataInterface
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #DataInterface
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE DataInterface_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_RuleGid
       ,i_key_effective_date
       ,i_key_termination_date
       ,i_key_priority
       ,i_key_sid
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Interface_type
       ,i_Priority
       ,i_Group_List_ID
       ,i_Group_List_Desc
       ,i_Member_Match_ID
       ,i_Member_Match_Desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #DataInterface

   OPEN DataInterface_Cursor
  FETCH NEXT FROM DataInterface_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_RuleGid
       ,@i_key_effective_date
       ,@i_key_termination_date
       ,@i_key_priority
       ,@i_key_sid
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Interface_type
       ,@i_Priority
       ,@i_Group_List_ID
       ,@i_Group_List_Desc
       ,@i_Member_Match_ID
       ,@i_Member_Match_Desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prDataInterfaceAddModify
             @i_entity_name
            ,@i_key_RuleGid
            ,@i_key_effective_date
            ,@i_key_termination_date
            ,@i_key_priority
            ,@i_key_sid
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Interface_type
            ,@i_Priority
            ,@i_Group_List_ID
            ,@i_Group_List_Desc
            ,@i_Member_Match_ID
            ,@i_Member_Match_Desc
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
				UPDATE dbo.Data_Interface_Rules 
				   SET Rule_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND interface_type			= @i_Interface_type
				   AND priority					= @i_Priority

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Interface_type, @i_Effective_Date, @i_Member_Match_ID, @status, @err_num, @err_msg

        FETCH NEXT FROM DataInterface_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_RuleGid
             ,@i_key_effective_date
             ,@i_key_termination_date
             ,@i_key_priority
             ,@i_key_sid
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Interface_type
             ,@i_Priority
             ,@i_Group_List_ID
             ,@i_Group_List_Desc
             ,@i_Member_Match_ID
             ,@i_Member_Match_Desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE DataInterface_Cursor
DEALLOCATE DataInterface_Cursor

END
GO