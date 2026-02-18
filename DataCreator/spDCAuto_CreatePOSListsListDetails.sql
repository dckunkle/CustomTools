IF OBJECT_ID('dbo.spDCAuto_CreatePOSListsListDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePOSListsListDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePOSListsListDetails
Purpose:    Create poslistslistdetails data from CorderAutomation
Method:     POSListsListDetails
Screen GID: 3080
Procedure:  dbo.prPOSList_Add

Date        User            Change
---------------------------------------------------------------------------------------------
01/30/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePOSListsListDetails '100-Config%', 22, 'POSListsListDetails'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePOSListsListDetails
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

DECLARE @i_Entity_name   VARCHAR(50)
       ,@i_key_1_field   VARCHAR(50)
       ,@i_key_2_field   VARCHAR(50)
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
       ,@iListID         VARCHAR(50)
       ,@iListDesc       VARCHAR(100)
       ,@iPosCode1       VARCHAR(50)
       ,@iPosDesc1       VARCHAR(100)
       ,@iPosCode2       VARCHAR(50)
       ,@iPosDesc2       VARCHAR(100)
       ,@iPosCode3       VARCHAR(50)
       ,@iPosDesc3       VARCHAR(100)
       ,@iPosCode4       VARCHAR(50)
       ,@iPosDesc4       VARCHAR(100)
       ,@iPosCode5       VARCHAR(50)
       ,@iPosDesc5       VARCHAR(100)
       ,@o_status        INT
       ,@o_message       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#POSListsListDetails') IS NOT NULL
	DROP TABLE #POSListsListDetails

CREATE TABLE #POSListsListDetails
      (SearchID        VARCHAR(200)
      ,i_Entity_name   VARCHAR(50)       DEFAULT('POS_LIST_VARIATION')
      ,i_key_1_field   VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field   VARCHAR(50)       DEFAULT('0')
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
      ,iListID         VARCHAR(50)
      ,iListDesc       VARCHAR(100)
      ,iPosCode1       VARCHAR(50)
      ,iPosDesc1       VARCHAR(100)
      ,iPosCode2       VARCHAR(50)
      ,iPosDesc2       VARCHAR(100)
      ,iPosCode3       VARCHAR(50)
      ,iPosDesc3       VARCHAR(100)
      ,iPosCode4       VARCHAR(50)
      ,iPosDesc4       VARCHAR(100)
      ,iPosCode5       VARCHAR(50)
      ,iPosDesc5       VARCHAR(100)
      ,o_status        INT
      ,o_message       VARCHAR(100)
      ,record_id       INT
      ,static_gid      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #POSListsListDetails
      (SearchID
      ,iPosCode1
      ,iPosCode2
      ,iPosCode3
      ,iPosCode4
      ,iPosCode5
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([POSCode_1], '')
      ,ISNULL([POSCode_2], '')
      ,ISNULL([POSCode_3], '')
      ,ISNULL([POSCode_4], '')
      ,ISNULL([POSCode_5], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_PosListsListDetails
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #POSListsListDetails
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE POSListsListDetails_Cursor CURSOR FOR
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
       ,iListID
       ,iListDesc
       ,iPosCode1
       ,iPosDesc1
       ,iPosCode2
       ,iPosDesc2
       ,iPosCode3
       ,iPosDesc3
       ,iPosCode4
       ,iPosDesc4
       ,iPosCode5
       ,iPosDesc5
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #POSListsListDetails

   OPEN POSListsListDetails_Cursor
  FETCH NEXT FROM POSListsListDetails_Cursor
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
       ,@iListID
       ,@iListDesc
       ,@iPosCode1
       ,@iPosDesc1
       ,@iPosCode2
       ,@iPosDesc2
       ,@iPosCode3
       ,@iPosDesc3
       ,@iPosCode4
       ,@iPosDesc4
       ,@iPosCode5
       ,@iPosDesc5
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
			SELECT @i_key_1_field			= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'POS_LIST'

			EXEC dbo.prPOSList_Add
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
				,@iListID
				,@iListDesc
				,@iPosCode1
				,@iPosDesc1
				,@iPosCode2
				,@iPosDesc2
				,@iPosCode3
				,@iPosDesc3
				,@iPosCode4
				,@iPosDesc4
				,@iPosCode5
				,@iPosDesc5
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iPosCode1, '', @status, @err_num, @err_msg

        FETCH NEXT FROM POSListsListDetails_Cursor
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
             ,@iListID
             ,@iListDesc
             ,@iPosCode1
             ,@iPosDesc1
             ,@iPosCode2
             ,@iPosDesc2
             ,@iPosCode3
             ,@iPosDesc3
             ,@iPosCode4
             ,@iPosDesc4
             ,@iPosCode5
             ,@iPosDesc5
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE POSListsListDetails_Cursor
DEALLOCATE POSListsListDetails_Cursor

END
GO