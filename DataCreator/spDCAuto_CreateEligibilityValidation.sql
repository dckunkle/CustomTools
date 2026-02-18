IF OBJECT_ID('dbo.spDCAuto_CreateEligibilityValidation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateEligibilityValidation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateEligibilityValidation
Purpose:    Create eligibilityvalidation data from CorderAutomation
Method:     EligibilityValidation
Screen GID: 57
Procedure:  dbo.prDetailRuleNameAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/06/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateEligibilityValidation '100-Config%', 22, 'EligibilityValidation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateEligibilityValidation
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_Rule_gid           VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_Date_Time_Modified CHAR(200)
       ,@iUserID              VARCHAR(25)
       ,@i_Rule_id            VARCHAR(100)
       ,@i_Rule_name          VARCHAR(500)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#EligibilityValidation') IS NOT NULL
	DROP TABLE #EligibilityValidation

CREATE TABLE #EligibilityValidation
      (i_entity_name        VARCHAR(50)       DEFAULT('EligValidation_Root')
      ,i_Rule_gid           VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified CHAR(200)         DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Rule_id            VARCHAR(100)
      ,i_Rule_name          VARCHAR(500)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #EligibilityValidation
      (i_Rule_id
      ,i_Rule_name
      ,record_id
      ,static_gid)
SELECT ISNULL([*ID], '')
      ,ISNULL([*Description], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_EligibilityValidation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #EligibilityValidation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE EligibilityValidation_Cursor CURSOR FOR
 SELECT i_entity_name
       ,i_Rule_gid
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
       ,i_Rule_id
       ,i_Rule_name
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #EligibilityValidation

   OPEN EligibilityValidation_Cursor
  FETCH NEXT FROM EligibilityValidation_Cursor
   INTO @i_entity_name
       ,@i_Rule_gid
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
       ,@i_Rule_id
       ,@i_Rule_name
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prDetailRuleNameAdd
             @i_entity_name
            ,@i_Rule_gid
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
            ,@i_Rule_id
            ,@i_Rule_name
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				SELECT @current_gid				= entity_gid
				  FROM dbo.Entity_Names			EN
				 WHERE  record_status			= 'A'
				   AND entity_identifier		= 'Eligibility_Validation'
				   AND entity_user_id			= @i_Rule_id

				-- Update to the static gid
				UPDATE dbo.Entity_Names 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND entity_identifier		= 'Eligibility_Validation'
				   AND entity_user_id			= @i_Rule_id

				UPDATE Eligibility_Validation
				   SET elig_validation_gid		= @static_gid
				 WHERE record_status			= 'A'
				   AND elig_validation_gid		= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Rule_id, @i_Rule_name, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM EligibilityValidation_Cursor
         INTO @i_entity_name
             ,@i_Rule_gid
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
             ,@i_Rule_id
             ,@i_Rule_name
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE EligibilityValidation_Cursor
DEALLOCATE EligibilityValidation_Cursor

END
GO