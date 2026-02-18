IF OBJECT_ID('dbo.spDCAuto_CreateDiagnosisValidation') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateDiagnosisValidation AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateDiagnosisValidation
Purpose:    Create diagnosisvalidation data from CorderAutomation
Method:     DiagnosisValidation
Screen GID: 72
Procedure:  dbo.prDiagnosisValidationNameAdd

Date        User            Change
---------------------------------------------------------------------------------------------
01/30/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateDiagnosisValidation '100-Config%', 22, 'DiagnosisValidation'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateDiagnosisValidation
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

DECLARE @i_Entity_name           VARCHAR(200)
       ,@i_key_1_field           VARCHAR(300)
       ,@i_key_2_field           VARCHAR(50)
       ,@i_key_3_field           VARCHAR(50)
       ,@i_key_4_field           VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(50)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@iAction                 VARCHAR(10)
       ,@iModifiedDate           VARCHAR(30)
       ,@iUserID                 VARCHAR(25)
       ,@iDiagValidationID       VARCHAR(50)
       ,@iDiagValidationDesc     VARCHAR(50)
       ,@iCopyDiagValidationID   VARCHAR(50)
       ,@iCopyDiagValidationDesc VARCHAR(100)
       ,@iUsedForMemberCond      VARCHAR(50)
       ,@oStatus                 INT
       ,@oMessage                VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DiagnosisValidation') IS NOT NULL
	DROP TABLE #DiagnosisValidation

CREATE TABLE #DiagnosisValidation
      (SearchID                VARCHAR(200)
      ,i_Entity_name           VARCHAR(200)      DEFAULT('Diagnosis_Validation_Name')
      ,i_key_1_field           VARCHAR(300)      DEFAULT('0')
      ,i_key_2_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,iAction                 VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate           VARCHAR(30)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,iDiagValidationID       VARCHAR(50)
      ,iDiagValidationDesc     VARCHAR(50)
      ,iCopyDiagValidationID   VARCHAR(50)
      ,iCopyDiagValidationDesc VARCHAR(100)
      ,iUsedForMemberCond      VARCHAR(50)
      ,oStatus                 INT
      ,oMessage                VARCHAR(200)
      ,record_id               INT
      ,static_gid              INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #DiagnosisValidation
      (SearchID
      ,iDiagValidationID
      ,iDiagValidationDesc
      ,iCopyDiagValidationID
      ,iUsedForMemberCond
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*DiagValidationId], '')
      ,ISNULL([*DiagValidationDesc], '')
      ,ISNULL([CopyFrmDiagValId], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UsedForMemCond]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_DiagnosisValidation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #DiagnosisValidation
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE DiagnosisValidation_Cursor CURSOR FOR
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
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iDiagValidationID
       ,iDiagValidationDesc
       ,iCopyDiagValidationID
       ,iCopyDiagValidationDesc
       ,iUsedForMemberCond
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #DiagnosisValidation

   OPEN DiagnosisValidation_Cursor
  FETCH NEXT FROM DiagnosisValidation_Cursor
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
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iDiagValidationID
       ,@iDiagValidationDesc
       ,@iCopyDiagValidationID
       ,@iCopyDiagValidationDesc
       ,@iUsedForMemberCond
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prDiagnosisValidationNameAdd
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
				,@iAction
				,@iModifiedDate
				,@iUserID
				,@iDiagValidationID
				,@iDiagValidationDesc
				,@iCopyDiagValidationID
				,@iCopyDiagValidationDesc
				,@iUsedForMemberCond
				,@oStatus     = @err_num OUTPUT
				,@oMessage    = @err_msg OUTPUT

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
				   AND entity_identifier		= 'Diagnosis_Validation'
				   AND entity_user_id			= @iDiagValidationID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iDiagValidationID, @iDiagValidationDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM DiagnosisValidation_Cursor
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
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iDiagValidationID
             ,@iDiagValidationDesc
             ,@iCopyDiagValidationID
             ,@iCopyDiagValidationDesc
             ,@iUsedForMemberCond
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE DiagnosisValidation_Cursor
DEALLOCATE DiagnosisValidation_Cursor

END
GO