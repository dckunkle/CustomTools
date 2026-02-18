IF OBJECT_ID('dbo.spDCAuto_CreateProviderComments') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProviderComments AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProviderComments
Purpose:    Create providercomments data from CorderAutomation

Screen:     25
Method:     ProviderComments
Procedure:  dbo.prAppendAdd
Entity:     Prov_Inc2

Date        User            Change
---------------------------------------------------------------------------------------------
10/06/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProviderComments '100-Config%', 22, 'ProviderComments'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProviderComments
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

DECLARE @i_TABLE_name         VARCHAR(50)
       ,@i_key_1_field        VARCHAR(50)
       ,@i_key_2_field        VARCHAR(75)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(75)
       ,@i_key_5_field        VARCHAR(75)
       ,@i_key_6_field        VARCHAR(75)
       ,@i_key_7_field        VARCHAR(75)
       ,@i_key_8_field        VARCHAR(75)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_reference_type     VARCHAR(50)
       ,@i_entity_name        VARCHAR(50)
       ,@i_security_level     VARCHAR(50)
       ,@i_append_date        VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_sensitive_flag     VARCHAR(50)
       ,@i_append_text        VARCHAR(50)
       ,@i_display_related    VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)
       ,@DisplayResults       VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProviderComments') IS NOT NULL
	DROP TABLE #ProviderComments

CREATE TABLE #ProviderComments
      (SearchID             VARCHAR(200)
      ,i_TABLE_name         VARCHAR(50)       DEFAULT('Prov_Inc2')
      ,i_key_1_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('COMMENTS')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('N')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_reference_type     VARCHAR(50)	
      ,i_entity_name        VARCHAR(50)		  DEFAULT('Prov_Inc2')
      ,i_security_level     VARCHAR(50)
      ,i_append_date        VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_sensitive_flag     VARCHAR(50)
      ,i_append_text        VARCHAR(50)
      ,i_display_related    VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,DisplayResults       VARCHAR(50)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #ProviderComments
          (SearchID
          ,i_reference_type
          ,i_security_level
          ,i_append_date
          ,i_termination_date
          ,i_sensitive_flag
          ,i_append_text
          ,i_display_related
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CommentType]), '01')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SecurityLevel]), 'L')
          ,ISNULL([*CommentDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([HighVisibility]), 'N')
          ,ISNULL([*Comment], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DisplayOnRelatedEntities]), 'N')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_ProviderComments
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #ProviderComments
       SET iUserID  = @user


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
DECLARE ProviderComments_Cursor CURSOR FOR
 SELECT SearchID
       ,i_TABLE_name
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
       ,i_date_time_modified
       ,iUserID
       ,i_reference_type
       ,i_entity_name
       ,i_security_level
       ,i_append_date
       ,i_termination_date
       ,i_sensitive_flag
       ,i_append_text
       ,i_display_related
       ,o_status
       ,o_message
       ,DisplayResults
       ,record_id
       ,static_gid
   FROM #ProviderComments

   OPEN ProviderComments_Cursor
  FETCH NEXT FROM ProviderComments_Cursor
   INTO @SearchID
       ,@i_TABLE_name
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
       ,@i_date_time_modified
       ,@iUserID
       ,@i_reference_type
       ,@i_entity_name
       ,@i_security_level
       ,@i_append_date
       ,@i_termination_date
       ,@i_sensitive_flag
       ,@i_append_text
       ,@i_display_related
       ,@o_status
       ,@o_message
       ,@DisplayResults
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @i_key_1_field	= P.provider_gid
			  FROM dbo.Provider	P
			 WHERE P.record_status	= 'A'
			   AND P.provider_id	= @SearchID

			EXEC dbo.prAppendAdd
                 @i_TABLE_name
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
                ,@i_date_time_modified
                ,@iUserID
                ,@i_reference_type
                ,@i_entity_name
                ,@i_security_level
                ,@i_append_date
                ,@i_termination_date
                ,@i_sensitive_flag
                ,@i_append_text
                ,@i_display_related
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT
                --,@DisplayResults

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		--Only log the first part of the comment
		SELECT @i_append_text = LEFT(@i_append_text, 20)

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_reference_type, @i_append_text, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM ProviderComments_Cursor
         INTO @SearchID
             ,@i_TABLE_name
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
             ,@i_date_time_modified
             ,@iUserID
             ,@i_reference_type
             ,@i_entity_name
             ,@i_security_level
             ,@i_append_date
             ,@i_termination_date
             ,@i_sensitive_flag
             ,@i_append_text
             ,@i_display_related
             ,@o_status
             ,@o_message
             ,@DisplayResults
             ,@record_id
             ,@static_gid
	END

CLOSE ProviderComments_Cursor
DEALLOCATE ProviderComments_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#ProviderComments') IS NOT NULL
	DROP TABLE #ProviderComments

END
GO

