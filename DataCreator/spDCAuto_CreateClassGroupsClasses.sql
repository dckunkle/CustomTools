IF OBJECT_ID('dbo.spDCAuto_CreateClassGroupsClasses') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateClassGroupsClasses AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateClassGroupsClasses
Purpose:    Create classgroupsclasses data from CorderAutomation
Method:     ClassGroupsClasses
Screen GID: 136
Procedure:  dbo.prBenefitEntityClassVarAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
08/17/2021  DK				Changes for SP47
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateClassGroupsClasses '100-Config%', 22, 'ClassGroupsClasses'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateClassGroupsClasses
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

DECLARE @i_entity_name          VARCHAR(100)
       ,@i_Class_Gid            VARCHAR(20)
       ,@i_key_2_field          VARCHAR(20)
       ,@i_key_3_field          VARCHAR(50)
       ,@i_old_effective_date   VARCHAR(20)
       ,@i_old_termination_date VARCHAR(20)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_Reference_Sid        VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(30)
       ,@iUserID                VARCHAR(25)
	   ,@i_Class_Group_id       VARCHAR(50)
       ,@i_Class_Group_Desc     VARCHAR(100)
       ,@i_Class_id             VARCHAR(50)
       ,@i_Class_id_Desc        VARCHAR(50)
       ,@i_Effective_date       VARCHAR(50)
       ,@i_Termination_date     VARCHAR(50)
       ,@o_status               INT
       ,@o_message              VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ClassGroupsClasses') IS NOT NULL
	DROP TABLE #ClassGroupsClasses

CREATE TABLE #ClassGroupsClasses
      (i_entity_name          VARCHAR(100)      DEFAULT('Class_Groups_Var')
      ,i_Class_Gid            VARCHAR(20)       DEFAULT('0')
      ,i_key_2_field          VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(50)       DEFAULT('0')
      ,i_old_effective_date   VARCHAR(20)       DEFAULT('0')
      ,i_old_termination_date VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_Reference_Sid        VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,i_Class_Group_id       VARCHAR(50)       DEFAULT('')
      ,i_Class_Group_Desc     VARCHAR(100)      DEFAULT('')
      ,i_Class_id             VARCHAR(50)
      ,i_Class_id_Desc        VARCHAR(50)       DEFAULT('')
      ,i_Effective_date       VARCHAR(50)
      ,i_Termination_date     VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(100)
      ,record_id              INT
      ,static_gid             INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ClassGroupsClasses
      (i_key_2_field
	  ,i_Class_id
      ,i_Effective_date
      ,i_Termination_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ClassID]), '0')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(),101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ClassGroupsClasses
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ClassGroupsClasses
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ClassGroupsClasses_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_Class_Gid
       ,i_key_2_field
       ,i_key_3_field
       ,i_old_effective_date
       ,i_old_termination_date
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Reference_Sid
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Class_Group_id
       ,i_Class_Group_Desc
       ,i_Class_id
       ,i_Class_id_Desc
       ,i_Effective_date
       ,i_Termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #ClassGroupsClasses

   OPEN ClassGroupsClasses_Cursor
  FETCH NEXT FROM ClassGroupsClasses_Cursor
   INTO @i_entity_name
       ,@i_Class_Gid
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_old_effective_date
       ,@i_old_termination_date
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Reference_Sid
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Class_Group_id
       ,@i_Class_Group_Desc
       ,@i_Class_id
       ,@i_Class_id_Desc
       ,@i_Effective_date
       ,@i_Termination_date
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Need to lookup the current gid to pass into the stored procedure call
		SELECT @i_Class_Gid			= EN.entity_gid
		  FROM Entity_Names			EN
		 WHERE EN.record_status		= 'A'
		   AND EN.entity_identifier	= 'Class Groups'
		   AND EN.entity_user_id	= @i_key_2_field

		EXEC dbo.prBenefitEntityClassVarAddModify
             @i_entity_name
            ,@i_Class_Gid
            ,@i_key_2_field
            ,@i_key_3_field
            ,@i_old_effective_date
            ,@i_old_termination_date
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_Reference_Sid
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Class_Group_id
            ,@i_Class_Group_Desc
            ,@i_Class_id
            ,@i_Class_id_Desc
            ,@i_Effective_date
            ,@i_Termination_date
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Class_id, '', '', @status, @err_num, @err_msg

        FETCH NEXT FROM ClassGroupsClasses_Cursor
         INTO @i_entity_name
             ,@i_Class_Gid
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_old_effective_date
             ,@i_old_termination_date
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Reference_Sid
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Class_Group_id
             ,@i_Class_Group_Desc
             ,@i_Class_id
             ,@i_Class_id_Desc
             ,@i_Effective_date
             ,@i_Termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE ClassGroupsClasses_Cursor
DEALLOCATE ClassGroupsClasses_Cursor

END
GO