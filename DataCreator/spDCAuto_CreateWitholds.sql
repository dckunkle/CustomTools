IF OBJECT_ID('dbo.spDCAuto_CreateWitholds') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateWitholds AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateWitholds
Purpose:    Create witholds data from CorderAutomation
Method:     Witholds
Screen GID: 7025
Procedure:  dbo.prWithholdDefinition_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWitholds '100-Config%', 22, 'Witholds'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateWitholds
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

DECLARE @i_Entity_name   VARCHAR(100)
       ,@i_key_1_field   VARCHAR(100)
       ,@i_key_2_field   VARCHAR(100)
       ,@i_key_3_field   VARCHAR(50)
       ,@i_key_4_field   VARCHAR(50)
       ,@i_key_5_field   VARCHAR(50)
       ,@i_key_6_field   VARCHAR(50)
       ,@i_key_7_field   VARCHAR(50)
       ,@i_key_8_field   VARCHAR(50)
       ,@i_key_9_field   VARCHAR(50)
       ,@i_key_10_field  VARCHAR(50)
       ,@i_action        VARCHAR(10)
       ,@l_modified_date VARCHAR(30)
       ,@iUserID         VARCHAR(25)
       ,@i_withhold_id   VARCHAR(50)
       ,@i_withhold_desc VARCHAR(100)
       ,@i_withhold_type VARCHAR(50)
       ,@o_status        INT
       ,@o_message       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Witholds') IS NOT NULL
	DROP TABLE #Witholds

CREATE TABLE #Witholds
      (SearchID        VARCHAR(200)
      ,i_Entity_name   VARCHAR(100)      DEFAULT('Withholds')
      ,i_key_1_field   VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field   VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field  VARCHAR(50)       DEFAULT('0')
      ,i_action        VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date VARCHAR(30)       DEFAULT('')
      ,iUserID         VARCHAR(25)       DEFAULT('')
      ,i_withhold_id   VARCHAR(50)
      ,i_withhold_desc VARCHAR(100)
      ,i_withhold_type VARCHAR(50)
      ,o_status        INT
      ,o_message       VARCHAR(100)
      ,record_id       INT
      ,static_gid      INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Witholds
      (SearchID
      ,i_withhold_id
      ,i_withhold_desc
      ,i_withhold_type
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*WithholdID], '')
      ,ISNULL([*WithholdDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Type]), 'S')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Witholds
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Witholds
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Witholds_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_key_1_field
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
       ,l_modified_date
       ,iUserID
       ,i_withhold_id
       ,i_withhold_desc
       ,i_withhold_type
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Witholds

   OPEN Witholds_Cursor
  FETCH NEXT FROM Witholds_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_key_1_field
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
       ,@l_modified_date
       ,@iUserID
       ,@i_withhold_id
       ,@i_withhold_desc
       ,@i_withhold_type
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prWithholdDefinition_AddModify
             @i_Entity_name
            ,@i_key_1_field
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
            ,@l_modified_date
            ,@iUserID
            ,@i_withhold_id
            ,@i_withhold_desc
            ,@i_withhold_type
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
				   AND 1 = CASE WHEN @i_withhold_type = 'S'  AND entity_identifier = 'withholds' THEN 1
				                WHEN @i_withhold_type != 'S' AND entity_identifier = 'aff_witholds' THEN 1
						        ELSE 0
							 END
				   AND entity_user_id			= @i_withhold_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_withhold_id, @i_withhold_desc, @i_withhold_type, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Witholds_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_key_1_field
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
             ,@l_modified_date
             ,@iUserID
             ,@i_withhold_id
             ,@i_withhold_desc
             ,@i_withhold_type
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Witholds_Cursor
DEALLOCATE Witholds_Cursor

END
GO