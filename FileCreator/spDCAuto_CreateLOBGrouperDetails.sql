IF OBJECT_ID('dbo.spDCAuto_CreateLOBGrouperDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateLOBGrouperDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateLOBGrouperDetails
Purpose:    Create lobgrouperdetails data from CorderAutomation

Screen:     2500
Method:     LOBGrouperDetails
Procedure:  dbo.prLOBGrouper_Add
Entity:     LOB_Grouper_Details

Date        User            Change
---------------------------------------------------------------------------------------------
10/05/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateLOBGrouperDetails 'Accums-Config-1001%', 222222, 'Accums-Config-1001', 'LOBGrouperDetails', 'AccumsConfig1001'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateLOBGrouperDetails
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

DECLARE @i_entity_name   VARCHAR(50)
       ,@i_lob_group_gid VARCHAR(50)
       ,@i_key_2_field   VARCHAR(50)
       ,@i_key_3_field   VARCHAR(50)
       ,@i_key_4_field   VARCHAR(50)
       ,@i_key_5_field   VARCHAR(50)
       ,@i_key_6_field   VARCHAR(50)
       ,@i_key_7_field   VARCHAR(50)
       ,@i_key_8_field   VARCHAR(50)
       ,@i_key_9_field   VARCHAR(50)
       ,@i_key_10_field  VARCHAR(50)
       ,@i_action        VARCHAR(10)
       ,@i_dummy         VARCHAR(10)
       ,@i_User_ID       VARCHAR(25)
       ,@i_Grouper_Name  VARCHAR(50)
       ,@i_Grouper_Desc  VARCHAR(100)
       ,@i_system1       VARCHAR(50)
       ,@i_custom1       VARCHAR(50)
       ,@i_system2       VARCHAR(50)
       ,@i_custom2       VARCHAR(50)
       ,@i_system3       VARCHAR(50)
       ,@i_custom3       VARCHAR(50)
       ,@i_system4       VARCHAR(50)
       ,@i_custom4       VARCHAR(50)
       ,@i_system5       VARCHAR(50)
       ,@i_custom5       VARCHAR(50)
       ,@o_status        INT
       ,@o_message       VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#LOBGrouperDetails') IS NOT NULL
	DROP TABLE #LOBGrouperDetails

CREATE TABLE #LOBGrouperDetails
      (SearchID        VARCHAR(200)
      ,i_entity_name   VARCHAR(50)       DEFAULT('LOB_Grouper_Details')
      ,i_lob_group_gid VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field  VARCHAR(50)       DEFAULT('0')
      ,i_action        VARCHAR(10)       DEFAULT('ADD')
      ,i_dummy         VARCHAR(10)       DEFAULT('')
      ,i_User_ID       VARCHAR(25)       DEFAULT('')
      ,i_Grouper_Name  VARCHAR(50)
      ,i_Grouper_Desc  VARCHAR(100)
      ,i_system1       VARCHAR(50)
      ,i_custom1       VARCHAR(50)
      ,i_system2       VARCHAR(50)
      ,i_custom2       VARCHAR(50)
      ,i_system3       VARCHAR(50)
      ,i_custom3       VARCHAR(50)
      ,i_system4       VARCHAR(50)
      ,i_custom4       VARCHAR(50)
      ,i_system5       VARCHAR(50)
      ,i_custom5       VARCHAR(50)
      ,o_status        INT
      ,o_message       VARCHAR(255)
      ,record_id       INT
      ,static_gid      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #LOBGrouperDetails
          (SearchID
          ,i_system1
          ,i_custom1
          ,i_system2
          ,i_custom2
          ,i_system3
          ,i_custom3
          ,i_system4
          ,i_custom4
          ,i_system5
          ,i_custom5
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB_1]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB_1]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB_2]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB_2]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB_3]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB_3]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB_4]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB_4]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB_5]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB_5]), '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_LOBGrouperDetails
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #LOBGrouperDetails
       SET i_User_ID  = @user

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
DECLARE LOBGrouperDetails_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_lob_group_gid
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
       ,i_dummy
       ,i_User_ID
       ,i_Grouper_Name
       ,i_Grouper_Desc
       ,i_system1
       ,i_custom1
       ,i_system2
       ,i_custom2
       ,i_system3
       ,i_custom3
       ,i_system4
       ,i_custom4
       ,i_system5
       ,i_custom5
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #LOBGrouperDetails

   OPEN LOBGrouperDetails_Cursor
  FETCH NEXT FROM LOBGrouperDetails_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_lob_group_gid
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
       ,@i_dummy
       ,@i_User_ID
       ,@i_Grouper_Name
       ,@i_Grouper_Desc
       ,@i_system1
       ,@i_custom1
       ,@i_system2
       ,@i_custom2
       ,@i_system3
       ,@i_custom3
       ,@i_system4
       ,@i_custom4
       ,@i_system5
       ,@i_custom5
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

			SELECT @i_lob_group_gid		= EN.entity_gid
			      ,@i_Grouper_Name		= @SearchID
				  ,@i_Grouper_Desc		= EN.entity_user_name
			  FROM Entity_Names			EN
			 WHERE EN.record_status		= 'A'
			   AND EN.entity_user_id	= @SearchID

			SELECT @i_entity_name
                ,@i_lob_group_gid	gid
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
                ,@i_dummy
                ,@i_User_ID			user_id
                ,@i_Grouper_Name	grouper_name
                ,@i_Grouper_Desc	grouper_desc
                ,@i_system1
                ,@i_custom1
                ,@i_system2
                ,@i_custom2
                ,@i_system3
                ,@i_custom3
                ,@i_system4
                ,@i_custom4
                ,@i_system5
                ,@i_custom5

			EXEC dbo.prLOBGrouper_Add
                 @i_entity_name
                ,@i_lob_group_gid
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
                ,@i_dummy
                ,@i_User_ID
                ,@i_Grouper_Name
                ,@i_Grouper_Desc
                ,@i_system1
                ,@i_custom1
                ,@i_system2
                ,@i_custom2
                ,@i_system3
                ,@i_custom3
                ,@i_system4
                ,@i_custom4
                ,@i_system5
                ,@i_custom5
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Grouper_Name, @i_system1, @i_custom1, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM LOBGrouperDetails_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_lob_group_gid
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
             ,@i_dummy
             ,@i_User_ID
             ,@i_Grouper_Name
             ,@i_Grouper_Desc
             ,@i_system1
             ,@i_custom1
             ,@i_system2
             ,@i_custom2
             ,@i_system3
             ,@i_custom3
             ,@i_system4
             ,@i_custom4
             ,@i_system5
             ,@i_custom5
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE LOBGrouperDetails_Cursor
DEALLOCATE LOBGrouperDetails_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#LOBGrouperDetails') IS NOT NULL
	DROP TABLE #LOBGrouperDetails

END
GO

