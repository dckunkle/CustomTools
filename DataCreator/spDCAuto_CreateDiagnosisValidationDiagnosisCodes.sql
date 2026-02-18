IF OBJECT_ID('dbo.spDCAuto_CreateDiagnosisValidationDiagnosisCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateDiagnosisValidationDiagnosisCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateDiagnosisValidationDiagnosisCodes
Purpose:    Create diagnosisvalidationdiagnosiscodes data from CorderAutomation
Method:     DiagnosisValidationDiagnosisCodes
Screen GID: 73
Procedure:  dbo.prDiagnosisValidationAdd

Date        User            Change
---------------------------------------------------------------------------------------------
01/30/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateDiagnosisValidationDiagnosisCodes '100-Config%', 22, 'DiagnosisValidationDiagnosisCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateDiagnosisValidationDiagnosisCodes
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
       ,@i_Diagnosis_Validation_gid VARCHAR(50)
       ,@i_Diagnosis_Validation_sid VARCHAR(20)
       ,@i_key_3_field              VARCHAR(20)
       ,@i_key_4_field              VARCHAR(50)
       ,@i_key_5_field              VARCHAR(50)
       ,@i_key_6_field              VARCHAR(50)
       ,@i_key_7_field              VARCHAR(50)
       ,@i_key_8_field              VARCHAR(50)
       ,@i_key_9_field              VARCHAR(20)
       ,@i_key_10_field             VARCHAR(50)
       ,@i_action                   VARCHAR(10)
       ,@i_date_time_modified       VARCHAR(30)
       ,@iUserID                    VARCHAR(25)
       ,@iDiagValID                 VARCHAR(50)
       ,@iDiagValDesc               VARCHAR(50)
       ,@i_effective_date           VARCHAR(50)
       ,@i_termination_date         VARCHAR(50)
       ,@i_Type                     VARCHAR(50)
       ,@i_Diagnosis_Code           VARCHAR(50)
       ,@i_Diagnosis_Code_desc      VARCHAR(50)
       ,@i_New_procedure_class      VARCHAR(50)
       ,@i_Deny_Flag                VARCHAR(50)
       ,@oStatus                    INT
       ,@oMessage                   VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DiagnosisValidationDiagnosisCodes') IS NOT NULL
	DROP TABLE #DiagnosisValidationDiagnosisCodes

CREATE TABLE #DiagnosisValidationDiagnosisCodes
      (SearchID                   VARCHAR(200)
      ,i_entity_name              VARCHAR(50)       DEFAULT('Diagnosis_Validation')
      ,i_Diagnosis_Validation_gid VARCHAR(50)       DEFAULT('0')
      ,i_Diagnosis_Validation_sid VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field              VARCHAR(20)       DEFAULT('0')
      ,i_key_4_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field              VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field              VARCHAR(20)       DEFAULT('0')
      ,i_key_10_field             VARCHAR(50)       DEFAULT('0')
      ,i_action                   VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified       VARCHAR(30)       DEFAULT('')
      ,iUserID                    VARCHAR(25)       DEFAULT('')
      ,iDiagValID                 VARCHAR(50)
      ,iDiagValDesc               VARCHAR(50)
      ,i_effective_date           VARCHAR(50)
      ,i_termination_date         VARCHAR(50)
      ,i_Type                     VARCHAR(50)
      ,i_Diagnosis_Code           VARCHAR(50)
      ,i_Diagnosis_Code_desc      VARCHAR(50)
      ,i_New_procedure_class      VARCHAR(50)
      ,i_Deny_Flag                VARCHAR(50)
      ,oStatus                    INT
      ,oMessage                   VARCHAR(255)
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
INSERT INTO #DiagnosisValidationDiagnosisCodes
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_Type
      ,i_Diagnosis_Code
      ,i_New_procedure_class
      ,i_Deny_Flag
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], '01/01/1900')
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DiagnosisType]), '9')
      ,ISNULL([*DiagnosisCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NewCodeClassException]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Denied]), 'N')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_DiagnosisValidationDiagnosisCodes
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #DiagnosisValidationDiagnosisCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE DiagnosisValidationDiagnosisCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Diagnosis_Validation_gid
       ,i_Diagnosis_Validation_sid
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,iDiagValID
       ,iDiagValDesc
       ,i_effective_date
       ,i_termination_date
       ,i_Type
       ,i_Diagnosis_Code
       ,i_Diagnosis_Code_desc
       ,i_New_procedure_class
       ,i_Deny_Flag
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #DiagnosisValidationDiagnosisCodes

   OPEN DiagnosisValidationDiagnosisCodes_Cursor
  FETCH NEXT FROM DiagnosisValidationDiagnosisCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Diagnosis_Validation_gid
       ,@i_Diagnosis_Validation_sid
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@iDiagValID
       ,@iDiagValDesc
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Type
       ,@i_Diagnosis_Code
       ,@i_Diagnosis_Code_desc
       ,@i_New_procedure_class
       ,@i_Deny_Flag
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the Auth Match
			SELECT @i_Diagnosis_Validation_gid	= entity_gid
			  FROM Entity_Names
			 WHERE record_status				= 'A'
			   AND entity_user_id				= @SearchID
			   AND entity_identifier			= 'Diagnosis_Validation'

			EXEC dbo.prDiagnosisValidationAdd
             @i_entity_name
            ,@i_Diagnosis_Validation_gid
            ,@i_Diagnosis_Validation_sid
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@iDiagValID
            ,@iDiagValDesc
            ,@i_effective_date
            ,@i_termination_date
            ,@i_Type
            ,@i_Diagnosis_Code
            ,@i_Diagnosis_Code_desc
            ,@i_New_procedure_class
            ,@i_Deny_Flag
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Diagnosis_Code, '', @status, @err_num, @err_msg

        FETCH NEXT FROM DiagnosisValidationDiagnosisCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Diagnosis_Validation_gid
             ,@i_Diagnosis_Validation_sid
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@iDiagValID
             ,@iDiagValDesc
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Type
             ,@i_Diagnosis_Code
             ,@i_Diagnosis_Code_desc
             ,@i_New_procedure_class
             ,@i_Deny_Flag
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE DiagnosisValidationDiagnosisCodes_Cursor
DEALLOCATE DiagnosisValidationDiagnosisCodes_Cursor

END
GO