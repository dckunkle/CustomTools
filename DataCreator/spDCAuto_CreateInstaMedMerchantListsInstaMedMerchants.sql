IF OBJECT_ID('dbo.spDCAuto_CreateInstaMedMerchantListsInstaMedMerchants') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateInstaMedMerchantListsInstaMedMerchants AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateInstaMedMerchantListsInstaMedMerchants
Purpose:    Create instamedmerchantlistsinstamedmerchants data from CorderAutomation

Screen:     11009
Method:     InstaMedMerchantListsInstaMedMerchants
Procedure:  dbo.prInstaMedMerchantAssign
Entity:     InstaMed_Merchant_Assign

Date        User            Change
---------------------------------------------------------------------------------------------
06/10/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateInstaMedMerchantListsInstaMedMerchants '100-Config%', 22, 'InstaMedMerchantListsInstaMedMerchants'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateInstaMedMerchantListsInstaMedMerchants
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_key_1_field        VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_Entity_List_Sid    VARCHAR(50)
       ,@i_action             VARCHAR(50)
       ,@i_date_time_modified VARCHAR(50)
       ,@i_UserID             VARCHAR(50)
       ,@i_Merchant_ID        VARCHAR(50)
       ,@i_Merchant_Desc      VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#InstaMedMerchantListsInstaMedMerchants') IS NOT NULL
	DROP TABLE #InstaMedMerchantListsInstaMedMerchants

CREATE TABLE #InstaMedMerchantListsInstaMedMerchants
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('InstaMed_Merchant_Assign')
      ,i_key_1_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('-1')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_Entity_List_Sid    VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(50)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,i_UserID             VARCHAR(50)       DEFAULT('')
      ,i_Merchant_ID        VARCHAR(50)
      ,i_Merchant_Desc      VARCHAR(50)
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
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

    INSERT INTO #InstaMedMerchantListsInstaMedMerchants
          (SearchID
          ,i_Merchant_ID
          ,record_id
          ,static_gid)
    SELECT ISNULL(SearchID, '')
	      ,ISNULL(InstaMedMerchantID, '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_InstaMedMerchantListsInstaMedMerchants
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #InstaMedMerchantListsInstaMedMerchants
       SET i_UserID  = @user

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
DECLARE InstaMedMerchantListsInstaMedMerchants_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_field
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Entity_List_Sid
       ,i_action
       ,i_date_time_modified
       ,i_UserID
       ,i_Merchant_ID
       ,i_Merchant_Desc
       ,i_effective_date
       ,i_termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #InstaMedMerchantListsInstaMedMerchants

   OPEN InstaMedMerchantListsInstaMedMerchants_Cursor
  FETCH NEXT FROM InstaMedMerchantListsInstaMedMerchants_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_field
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Entity_List_Sid
       ,@i_action
       ,@i_date_time_modified
       ,@i_UserID
       ,@i_Merchant_ID
       ,@i_Merchant_Desc
       ,@i_effective_date
       ,@i_termination_date
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

			SELECT @i_key_1_field			= InstaMedMerchantList_gid
			  FROM InstaMedMerchantLists
			 WHERE MerchantListID			= @SearchID
			   AND record_status			= 'A'

			EXEC dbo.prInstaMedMerchantAssign
                 @i_entity_name
                ,@i_key_1_field
                ,@i_key_2_field
                ,@i_key_3_field
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_Entity_List_Sid
                ,@i_action
                ,@i_date_time_modified
                ,@i_UserID
                ,@i_Merchant_ID
                ,@i_Merchant_Desc
                ,@i_effective_date
                ,@i_termination_date
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Merchant_ID, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM InstaMedMerchantListsInstaMedMerchants_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_field
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Entity_List_Sid
             ,@i_action
             ,@i_date_time_modified
             ,@i_UserID
             ,@i_Merchant_ID
             ,@i_Merchant_Desc
             ,@i_effective_date
             ,@i_termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE InstaMedMerchantListsInstaMedMerchants_Cursor
DEALLOCATE InstaMedMerchantListsInstaMedMerchants_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#InstaMedMerchantListsInstaMedMerchants') IS NOT NULL
	DROP TABLE #InstaMedMerchantListsInstaMedMerchants

END
GO

