IF OBJECT_ID('dbo.spDCAuto_CreateBusinessUnitListID') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBusinessUnitListID AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnitListID
Purpose:    Create businessunitlistid data from CorderAutomation
Method:     BusinessUnitListID
Screen GID: 4902
Procedure:  dbo.prBusinessUnitListAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
03/10/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnitListID '100-Config%', 22, 'BusinessUnitListID'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnitListID
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

DECLARE @i_entity_name         VARCHAR(20)
       ,@i_tx_gid              VARCHAR(50)
       ,@i_key_2_field         VARCHAR(50)
       ,@i_key_3_field         VARCHAR(50)
       ,@i_key_4_field         VARCHAR(50)
       ,@i_key_5_field         VARCHAR(50)
       ,@i_key_6_field         VARCHAR(50)
       ,@i_key_7_field         VARCHAR(50)
       ,@i_key_8_field         VARCHAR(50)
       ,@i_key_9_field         VARCHAR(50)
       ,@i_key_10_field        VARCHAR(50)
       ,@i_action              VARCHAR(10)
       ,@i_Date_Time_Modified  VARCHAR(30)
       ,@iUserID               VARCHAR(25)
       ,@iBusinessUnitListId   VARCHAR(50)
       ,@iBusinessUnitListDesc VARCHAR(50)
       ,@o_status              INT
       ,@o_message             VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnitListID') IS NOT NULL
	DROP TABLE #BusinessUnitListID

CREATE TABLE #BusinessUnitListID
      (SearchID              VARCHAR(200)
      ,i_entity_name         VARCHAR(20)       DEFAULT('BusinessUnit_List')
      ,i_tx_gid              VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified  VARCHAR(30)       DEFAULT('')
      ,iUserID               VARCHAR(25)       DEFAULT('')
      ,iBusinessUnitListId   VARCHAR(50)
      ,iBusinessUnitListDesc VARCHAR(50)
      ,o_status              INT
      ,o_message             VARCHAR(100)
      ,record_id             INT
      ,static_gid            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BusinessUnitListID
      (SearchID
      ,iBusinessUnitListId
      ,iBusinessUnitListDesc
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*BusinessUnitListID], '')
      ,ISNULL([*BusinessUnitListDesc], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnitListId
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BusinessUnitListID
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BusinessUnitListID_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_tx_gid
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
       ,iBusinessUnitListId
       ,iBusinessUnitListDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BusinessUnitListID

   OPEN BusinessUnitListID_Cursor
  FETCH NEXT FROM BusinessUnitListID_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_tx_gid
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
       ,@iBusinessUnitListId
       ,@iBusinessUnitListDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prBusinessUnitListAddModify
             @i_entity_name
            ,@i_tx_gid
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
            ,@iBusinessUnitListId
            ,@iBusinessUnitListDesc
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
				   AND entity_identifier		= 'BusinessUnit_List'
				   AND entity_user_id			= @iBusinessUnitListId

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iBusinessUnitListId, @iBusinessUnitListDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM BusinessUnitListID_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_tx_gid
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
             ,@iBusinessUnitListId
             ,@iBusinessUnitListDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnitListID_Cursor
DEALLOCATE BusinessUnitListID_Cursor

END
GO