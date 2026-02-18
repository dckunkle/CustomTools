IF OBJECT_ID('dbo.spDCAuto_CreateWitholdsDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateWitholdsDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateWitholdsDetails
Purpose:    Create witholdsdetails data from CorderAutomation
Method:     WitholdsDetails
Screen GID: 7000
Procedure:  dbo.prWithholdVariation_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateWitholdsDetails '100-Config%', 22, 'WitholdsDetails'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateWitholdsDetails
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

DECLARE @i_Entity_name       VARCHAR(100)
       ,@i_withhold_gid      VARCHAR(100)
       ,@i_withhold_sid      VARCHAR(100)
       ,@i_key_3_field       VARCHAR(50)
       ,@i_key_4_field       VARCHAR(100)
       ,@i_key_5_field       VARCHAR(100)
       ,@i_key_6_field       VARCHAR(100)
       ,@i_key_7_field       VARCHAR(50)
       ,@i_key_8_field       VARCHAR(100)
       ,@i_key_9_field       VARCHAR(100)
       ,@i_key_10_field      VARCHAR(100)
       ,@i_action            VARCHAR(100)
       ,@l_modified_date     VARCHAR(30)
       ,@iUserID             VARCHAR(25)
       ,@i_system_lob        VARCHAR(50)
       ,@i_custom_lob        VARCHAR(50)
       ,@i_grouper_id        VARCHAR(50)
       ,@i_grouper_desc      VARCHAR(50)
       ,@i_Network_Status    VARCHAR(50)
       ,@iX12835PLBCode      VARCHAR(50)
       ,@i_code_list_id      VARCHAR(50)
       ,@i_code_list_desc    VARCHAR(50)
       ,@i_retention_type    VARCHAR(50)
       ,@i_retention_percent VARCHAR(50)
       ,@i_max_exempt        VARCHAR(50)
       ,@i_calculation_date  VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(300)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#WitholdsDetails') IS NOT NULL
	DROP TABLE #WitholdsDetails

CREATE TABLE #WitholdsDetails
      (SearchID            VARCHAR(200)
      ,i_Entity_name       VARCHAR(100)      DEFAULT('Withhold_Variations')
      ,i_withhold_gid      VARCHAR(100)      DEFAULT('0')
      ,i_withhold_sid      VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field       VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field       VARCHAR(100)      DEFAULT('0')
      ,i_key_6_field       VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field       VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field       VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field       VARCHAR(100)      DEFAULT('0')
      ,i_key_10_field      VARCHAR(100)      DEFAULT('0')
      ,i_action            VARCHAR(100)      DEFAULT('ADD')
      ,l_modified_date     VARCHAR(30)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,i_system_lob        VARCHAR(50)
      ,i_custom_lob        VARCHAR(50)
      ,i_grouper_id        VARCHAR(50)
      ,i_grouper_desc      VARCHAR(50)
      ,i_Network_Status    VARCHAR(50)
      ,iX12835PLBCode      VARCHAR(50)
      ,i_code_list_id      VARCHAR(50)
      ,i_code_list_desc    VARCHAR(50)
      ,i_retention_type    VARCHAR(50)
      ,i_retention_percent VARCHAR(50)
      ,i_max_exempt        VARCHAR(50)
      ,i_calculation_date  VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(300)
      ,record_id           INT
      ,static_gid          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #WitholdsDetails
      (SearchID
      ,i_system_lob
      ,i_custom_lob
      ,i_grouper_id
      ,i_Network_Status
      ,iX12835PLBCode
      ,i_code_list_id
      ,i_retention_type
      ,i_retention_percent
      ,i_max_exempt
      ,i_calculation_date
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '******')
      ,ISNULL([LOBGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Network]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([835ProviderAdjmtReasonCode]), 'IR')
      ,ISNULL([CodeListID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RetentionType]), 'P')
      ,ISNULL([RetentionAmount], '0.00')
      ,ISNULL([MaxExemptAmount], '0.00')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CalculationDate]), 'P')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_WitholdsDetails
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #WitholdsDetails
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE WitholdsDetails_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_withhold_gid
       ,i_withhold_sid
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
       ,i_system_lob
       ,i_custom_lob
       ,i_grouper_id
       ,i_grouper_desc
       ,i_Network_Status
       ,iX12835PLBCode
       ,i_code_list_id
       ,i_code_list_desc
       ,i_retention_type
       ,i_retention_percent
       ,i_max_exempt
       ,i_calculation_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #WitholdsDetails

   OPEN WitholdsDetails_Cursor
  FETCH NEXT FROM WitholdsDetails_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_withhold_gid
       ,@i_withhold_sid
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
       ,@i_system_lob
       ,@i_custom_lob
       ,@i_grouper_id
       ,@i_grouper_desc
       ,@i_Network_Status
       ,@iX12835PLBCode
       ,@i_code_list_id
       ,@i_code_list_desc
       ,@i_retention_type
       ,@i_retention_percent
       ,@i_max_exempt
       ,@i_calculation_date
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

			--Get the gid for the Auth Match
			SELECT @i_withhold_gid			= EN.entity_gid
			  FROM Entity_Names				EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_identifier		IN ('withholds','aff_witholds')
			   AND EN.entity_user_id		= @SearchID

			EXEC dbo.prWithholdVariation_AddModify
             @i_Entity_name
            ,@i_withhold_gid
            ,@i_withhold_sid
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
            ,@i_system_lob
            ,@i_custom_lob
            ,@i_grouper_id
            ,@i_grouper_desc
            ,@i_Network_Status
            ,@iX12835PLBCode
            ,@i_code_list_id
            ,@i_code_list_desc
            ,@i_retention_type
            ,@i_retention_percent
            ,@i_max_exempt
            ,@i_calculation_date
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_system_lob, @i_custom_lob, @status, @err_num, @err_msg

        FETCH NEXT FROM WitholdsDetails_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_withhold_gid
             ,@i_withhold_sid
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
             ,@i_system_lob
             ,@i_custom_lob
             ,@i_grouper_id
             ,@i_grouper_desc
             ,@i_Network_Status
             ,@iX12835PLBCode
             ,@i_code_list_id
             ,@i_code_list_desc
             ,@i_retention_type
             ,@i_retention_percent
             ,@i_max_exempt
             ,@i_calculation_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE WitholdsDetails_Cursor
DEALLOCATE WitholdsDetails_Cursor

END
GO