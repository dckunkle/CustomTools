IF OBJECT_ID('dbo.spDCAuto_CreateJobAdministrationAddProcess') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateJobAdministrationAddProcess AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateJobAdministrationAddProcess
Purpose:    Create jobadministrationaddprocess data from CorderAutomation
Method:     JobAdministrationAddProcess
Screen GID: 390
Procedure:  dbo.prProcessAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateJobAdministrationAddProcess '100-Config%', 22, 'JobAdministrationAddProcess'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateJobAdministrationAddProcess
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

DECLARE @i_entity_name     VARCHAR(50)
       ,@i_Job_GID         VARCHAR(50)
       ,@process_gid       VARCHAR(50)
       ,@i_key_3_field     VARCHAR(50)
       ,@i_related_gid     VARCHAR(50)
       ,@i_sequence_number VARCHAR(50)
       ,@i_key_6_field     VARCHAR(50)
       ,@i_key_7_field     VARCHAR(50)
       ,@i_key_8_field     VARCHAR(50)
       ,@i_key_9_field     VARCHAR(50)
       ,@i_key_10_field    VARCHAR(50)
       ,@i_action          VARCHAR(10)
       ,@i_blank           VARCHAR(50)
       ,@i_UserID          VARCHAR(50)
       ,@i_Job_ID          VARCHAR(50)
       ,@i_Job_Desc        VARCHAR(50)
       ,@i_Process_ID      VARCHAR(100)
       ,@i_New_Sequence    VARCHAR(10)
       ,@i_Cont_On_Error   CHAR(1)
       ,@i_File_Layout     VARCHAR(50)
       ,@i_Extract_Type    VARCHAR(50)
       ,@o_status          INT
       ,@o_message         VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#JobAdministrationAddProcess') IS NOT NULL
	DROP TABLE #JobAdministrationAddProcess

CREATE TABLE #JobAdministrationAddProcess
      (i_entity_name     VARCHAR(50)       DEFAULT('Job_Process')
      ,i_Job_GID         VARCHAR(50)       DEFAULT('0')
      ,process_gid       VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field     VARCHAR(50)       DEFAULT('0')
      ,i_related_gid     VARCHAR(50)       DEFAULT('0')
      ,i_sequence_number VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field     VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field    VARCHAR(50)       DEFAULT('0')
      ,i_action          VARCHAR(10)       DEFAULT('ADD')
      ,i_blank           VARCHAR(50)       DEFAULT('')
      ,i_UserID          VARCHAR(50)       DEFAULT('')
      ,i_Job_ID          VARCHAR(50)
      ,i_Job_Desc        VARCHAR(50)
      ,i_Process_ID      VARCHAR(100)
      ,i_New_Sequence    VARCHAR(10)
      ,i_Cont_On_Error   CHAR(1)
      ,i_File_Layout     VARCHAR(50)
      ,i_Extract_Type    VARCHAR(50)
      ,o_status          INT
      ,o_message         VARCHAR(255)
      ,record_id         INT
      ,static_gid        INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #JobAdministrationAddProcess
      (i_Job_ID
	  ,i_Process_ID
      ,i_New_Sequence
      ,i_Cont_On_Error
      ,i_File_Layout
      ,i_Extract_Type
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Process]), '1099EXT')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ProcessSequence]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContinueOnError]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([FileLayout]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ExtractType]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_JobAdministrationAddProcess
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #JobAdministrationAddProcess
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE JobAdministrationAddProcess_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_Job_GID
       ,process_gid
       ,i_key_3_field
       ,i_related_gid
       ,i_sequence_number
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_blank
       ,i_UserID
       ,i_Job_ID
       ,i_Job_Desc
       ,i_Process_ID
       ,i_New_Sequence
       ,i_Cont_On_Error
       ,i_File_Layout
       ,i_Extract_Type
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #JobAdministrationAddProcess

   OPEN JobAdministrationAddProcess_Cursor
  FETCH NEXT FROM JobAdministrationAddProcess_Cursor
   INTO @i_entity_name
       ,@i_Job_GID
       ,@process_gid
       ,@i_key_3_field
       ,@i_related_gid
       ,@i_sequence_number
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_blank
       ,@i_UserID
       ,@i_Job_ID
       ,@i_Job_Desc
       ,@i_Process_ID
       ,@i_New_Sequence
       ,@i_Cont_On_Error
       ,@i_File_Layout
       ,@i_Extract_Type
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Need to lookup the current gid to pass into the stored procedure call
		SELECT @current_gid			= BJD.job_gid
		      ,@i_Job_Desc			= BJD.job_desc
		  FROM Batch_Job_Definition	BJD
		 WHERE BJD.record_status	= 'A'
		   AND BJD.job_id			= @i_Job_ID

		EXEC dbo.prProcessAddModify
             @i_entity_name
            ,@current_gid
            ,@process_gid
            ,@i_key_3_field
            ,@i_related_gid
            ,@i_sequence_number
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_blank
            ,@i_UserID
            ,@i_Job_ID
            ,@i_Job_Desc
            ,@i_Process_ID
            ,@i_New_Sequence
            ,@i_Cont_On_Error
            ,@i_File_Layout
            ,@i_Extract_Type
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

			SET @err_num = ISNULL(@err_num, 0)

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Job_ID, @i_Process_ID, @i_New_Sequence, @status, @err_num, @err_msg

        FETCH NEXT FROM JobAdministrationAddProcess_Cursor
         INTO @i_entity_name
             ,@i_Job_GID
             ,@process_gid
             ,@i_key_3_field
             ,@i_related_gid
             ,@i_sequence_number
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_blank
             ,@i_UserID
             ,@i_Job_ID
             ,@i_Job_Desc
             ,@i_Process_ID
             ,@i_New_Sequence
             ,@i_Cont_On_Error
             ,@i_File_Layout
             ,@i_Extract_Type
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE JobAdministrationAddProcess_Cursor
DEALLOCATE JobAdministrationAddProcess_Cursor

END
GO