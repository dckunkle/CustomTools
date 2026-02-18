IF OBJECT_ID('dbo.spDCAuto_CreateDiagnosisCode') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateDiagnosisCode AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateDiagnosisCode
Purpose:    Create diagnosiscode data from CorderAutomation
Method:     DiagnosisCode
Screen GID: 13
Procedure:  dbo.prDiagnosisAdd

Date        User            Change
---------------------------------------------------------------------------------------------
01/30/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateDiagnosisCode '100-Config%', 22, 'DiagnosisCode'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateDiagnosisCode
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

DECLARE @i_entity_name           VARCHAR(50)
       ,@i_mod_diagnosis_code    VARCHAR(50)
       ,@i_mod_type              VARCHAR(50)
       ,@i_diagnosis_sid         VARCHAR(50)
       ,@i_key_eff_date          VARCHAR(50)
       ,@i_key_5_field           VARCHAR(50)
       ,@i_key_6_field           VARCHAR(50)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(10)
       ,@i_date_time_modified    VARCHAR(30)
       ,@iUserID                 VARCHAR(25)
       ,@i_diagnosis_code        VARCHAR(50)
       ,@i_diagnosis_description VARCHAR(50)
       ,@iEff_Date               VARCHAR(50)
       ,@iTerm_Date              VARCHAR(50)
       ,@i_diagnosis_type        VARCHAR(50)
       ,@i_diagnosis_grouper     VARCHAR(50)
       ,@o_status                INT
       ,@o_message               VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DiagnosisCode') IS NOT NULL
	DROP TABLE #DiagnosisCode

CREATE TABLE #DiagnosisCode
      (SearchID                VARCHAR(200)
      ,i_entity_name           VARCHAR(50)       DEFAULT('Diagnosis_Codes')
      ,i_mod_diagnosis_code    VARCHAR(50)       DEFAULT('0')
      ,i_mod_type              VARCHAR(50)       DEFAULT('0')
      ,i_diagnosis_sid         VARCHAR(50)       DEFAULT('0')
      ,i_key_eff_date          VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified    VARCHAR(30)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,i_diagnosis_code        VARCHAR(50)
      ,i_diagnosis_description VARCHAR(50)
      ,iEff_Date               VARCHAR(50)
      ,iTerm_Date              VARCHAR(50)
      ,i_diagnosis_type        VARCHAR(50)
      ,i_diagnosis_grouper     VARCHAR(50)
      ,o_status                INT
      ,o_message               VARCHAR(100)
      ,record_id               INT
      ,static_gid              INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #DiagnosisCode
      (SearchID
      ,i_diagnosis_code
      ,i_diagnosis_description
      ,iEff_Date
      ,iTerm_Date
      ,i_diagnosis_type
      ,i_diagnosis_grouper
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Diagnosis_Code], '')
      ,ISNULL([*Diagnosis_Description], '')
      ,ISNULL([Effective_Date], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([Termination_Date], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Diagnosis_Type]), '9')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Diagnosis_Relation]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_DiagnosisCode
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #DiagnosisCode
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE DiagnosisCode_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_mod_diagnosis_code
       ,i_mod_type
       ,i_diagnosis_sid
       ,i_key_eff_date
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_diagnosis_code
       ,i_diagnosis_description
       ,iEff_Date
       ,iTerm_Date
       ,i_diagnosis_type
       ,i_diagnosis_grouper
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #DiagnosisCode

   OPEN DiagnosisCode_Cursor
  FETCH NEXT FROM DiagnosisCode_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_mod_diagnosis_code
       ,@i_mod_type
       ,@i_diagnosis_sid
       ,@i_key_eff_date
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_diagnosis_code
       ,@i_diagnosis_description
       ,@iEff_Date
       ,@iTerm_Date
       ,@i_diagnosis_type
       ,@i_diagnosis_grouper
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prDiagnosisAdd
				 @i_entity_name
				,@i_mod_diagnosis_code
				,@i_mod_type
				,@i_diagnosis_sid
				,@i_key_eff_date
				,@i_key_5_field
				,@i_key_6_field
				,@i_key_7_field
				,@i_key_8_field
				,@i_key_9_field
				,@i_key_10_field
				,@i_action
				,@i_date_time_modified
				,@iUserID
				,@i_diagnosis_code
				,@i_diagnosis_description
				,@iEff_Date
				,@iTerm_Date
				,@i_diagnosis_type
				,@i_diagnosis_grouper
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_diagnosis_code, @i_diagnosis_description, '', @status, @err_num, @err_msg

        FETCH NEXT FROM DiagnosisCode_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_mod_diagnosis_code
             ,@i_mod_type
             ,@i_diagnosis_sid
             ,@i_key_eff_date
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_diagnosis_code
             ,@i_diagnosis_description
             ,@iEff_Date
             ,@iTerm_Date
             ,@i_diagnosis_type
             ,@i_diagnosis_grouper
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE DiagnosisCode_Cursor
DEALLOCATE DiagnosisCode_Cursor

END
GO