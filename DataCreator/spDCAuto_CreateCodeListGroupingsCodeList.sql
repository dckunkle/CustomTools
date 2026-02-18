IF OBJECT_ID('dbo.spDCAuto_CreateCodeListGroupingsCodeList') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeListGroupingsCodeList AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeListGroupingsCodeList
Purpose:    Create codelistgroupingscodelist data from CorderAutomation
Method:     CodeListGroupingsCodeList
Screen GID: 129
Procedure:  dbo.prProc_EntityListsAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeListGroupingsCodeList '100-Config%', 22, 'CodeListGroupingsCodeList'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeListGroupingsCodeList
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
       ,@i_Procedure_List_Group_gid VARCHAR(50)
       ,@i_Procedure_List_gid       VARCHAR(20)
       ,@i_Old_effective_date       VARCHAR(20)
       ,@i_Old_termination_date     VARCHAR(50)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(50)
       ,@i_Entity_List_Sid          VARCHAR(50)
       ,@i_action                   VARCHAR(50)
       ,@i_date_time_modified       VARCHAR(50)
       ,@iUserID                    VARCHAR(50)
       ,@i_Procedure_list_Id        VARCHAR(50)
       ,@i_Procedure_list_name      VARCHAR(50)
       ,@i_effective_date           VARCHAR(50)
       ,@i_termination_date         VARCHAR(50)
       ,@o_status                   INT
       ,@o_message                  VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeListGroupingsCodeList') IS NOT NULL
	DROP TABLE #CodeListGroupingsCodeList

CREATE TABLE #CodeListGroupingsCodeList
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('Procedure_Lists')
      ,i_Procedure_List_Group_gid VARCHAR(50)       DEFAULT('0')
      ,i_Procedure_List_gid       VARCHAR(20)       DEFAULT('0')
      ,i_Old_effective_date       VARCHAR(20)       DEFAULT('0')
      ,i_Old_termination_date     VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(50)       DEFAULT('0')
      ,i_Entity_List_Sid          VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified       VARCHAR(50)       DEFAULT('')
      ,iUserID                    VARCHAR(50)       DEFAULT('')
      ,i_Procedure_list_Id        VARCHAR(50)
      ,i_Procedure_list_name      VARCHAR(50)
      ,i_effective_date           VARCHAR(50)
      ,i_termination_date         VARCHAR(50)
      ,o_status                   INT
      ,o_message                  VARCHAR(100)
      ,record_id                  INT
      ,static_gid                 INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeListGroupingsCodeList
      (SearchID
      ,i_Procedure_list_Id
      ,i_effective_date
      ,i_termination_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([CodeListID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeListGroupingsCodeLists
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeListGroupingsCodeList
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeListGroupingsCodeList_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Procedure_List_Group_gid
       ,i_Procedure_List_gid
       ,i_Old_effective_date
       ,i_Old_termination_date
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Entity_List_Sid
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Procedure_list_Id
       ,i_Procedure_list_name
       ,i_effective_date
       ,i_termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeListGroupingsCodeList

   OPEN CodeListGroupingsCodeList_Cursor
  FETCH NEXT FROM CodeListGroupingsCodeList_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Procedure_List_Group_gid
       ,@i_Procedure_List_gid
       ,@i_Old_effective_date
       ,@i_Old_termination_date
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Entity_List_Sid
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Procedure_list_Id
       ,@i_Procedure_list_name
       ,@i_effective_date
       ,@i_termination_date
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the entity gid
			SELECT @i_Procedure_List_Group_gid	= entity_gid
			  FROM Entity_Names 
			 WHERE entity_identifier			= 'Entity_Lists'
			   AND entity_user_id				= @SearchID

			EXEC dbo.prProc_EntityListsAddModify
             @i_entity_name
            ,@i_Procedure_List_Group_gid
            ,@i_Procedure_List_gid
            ,@i_Old_effective_date
            ,@i_Old_termination_date
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_Entity_List_Sid
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Procedure_list_Id
            ,@i_Procedure_list_name
            ,@i_effective_date
            ,@i_termination_date
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Procedure_list_Id, @i_Procedure_list_name, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeListGroupingsCodeList_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Procedure_List_Group_gid
             ,@i_Procedure_List_gid
             ,@i_Old_effective_date
             ,@i_Old_termination_date
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Entity_List_Sid
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Procedure_list_Id
             ,@i_Procedure_list_name
             ,@i_effective_date
             ,@i_termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeListGroupingsCodeList_Cursor
DEALLOCATE CodeListGroupingsCodeList_Cursor

END
GO