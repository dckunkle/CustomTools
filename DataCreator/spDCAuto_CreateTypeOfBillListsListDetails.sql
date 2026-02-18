IF OBJECT_ID('dbo.spDCAuto_CreateTypeOfBillListsListDetails') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTypeOfBillListsListDetails AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTypeOfBillListsListDetails
Purpose:    Create typeofbilllistsvariations data from CorderAutomation
Method:     TypeOfBillListsVariations
Screen GID: 3090
Procedure:  dbo.prTOBList_Add

Date        User            Change
---------------------------------------------------------------------------------------------
01/30/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTypeOfBillListsListDetails '100-Config%', 22, 'TypeOfBillListsVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTypeOfBillListsListDetails
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
       ,@iTOBCode1       VARCHAR(50)
       ,@iTOBDesc1       VARCHAR(100)
       ,@iEffDate1       VARCHAR(50)
       ,@iTermDate1      VARCHAR(50)
       ,@iTOBCode2       VARCHAR(50)
       ,@iTOBDesc2       VARCHAR(100)
       ,@iEffDate2       VARCHAR(50)
       ,@iTermDate2      VARCHAR(50)
       ,@iTOBCode3       VARCHAR(50)
       ,@iTOBDesc3       VARCHAR(100)
       ,@iEffDate3       VARCHAR(50)
       ,@iTermDate3      VARCHAR(50)
       ,@iTOBCode4       VARCHAR(50)
       ,@iTOBDesc4       VARCHAR(100)
       ,@iEffDate4       VARCHAR(50)
       ,@iTermDate4      VARCHAR(50)
       ,@iTOBCode5       VARCHAR(50)
       ,@iTOBDesc5       VARCHAR(100)
       ,@iEffDate5       VARCHAR(50)
       ,@iTermDate5      VARCHAR(50)
       ,@o_status        INT
       ,@o_message       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TypeOfBillListsListDetails') IS NOT NULL
	DROP TABLE #TypeOfBillListsListDetails

CREATE TABLE #TypeOfBillListsListDetails
      (SearchID        VARCHAR(200)
      ,i_Entity_name   VARCHAR(50)       DEFAULT('TOB_LIST_VARIATION')
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
      ,iTOBCode1       VARCHAR(50)
      ,iTOBDesc1       VARCHAR(100)
      ,iEffDate1       VARCHAR(50)
      ,iTermDate1      VARCHAR(50)
      ,iTOBCode2       VARCHAR(50)
      ,iTOBDesc2       VARCHAR(100)
      ,iEffDate2       VARCHAR(50)
      ,iTermDate2      VARCHAR(50)
      ,iTOBCode3       VARCHAR(50)
      ,iTOBDesc3       VARCHAR(100)
      ,iEffDate3       VARCHAR(50)
      ,iTermDate3      VARCHAR(50)
      ,iTOBCode4       VARCHAR(50)
      ,iTOBDesc4       VARCHAR(100)
      ,iEffDate4       VARCHAR(50)
      ,iTermDate4      VARCHAR(50)
      ,iTOBCode5       VARCHAR(50)
      ,iTOBDesc5       VARCHAR(100)
      ,iEffDate5       VARCHAR(50)
      ,iTermDate5      VARCHAR(50)
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
INSERT INTO #TypeOfBillListsListDetails
      (SearchID
      ,iTOBCode1
      ,iEffDate1
      ,iTermDate1
      ,iTOBCode2
      ,iEffDate2
      ,iTermDate2
      ,iTOBCode3
      ,iEffDate3
      ,iTermDate3
      ,iTOBCode4
      ,iEffDate4
      ,iTermDate4
      ,iTOBCode5
      ,iEffDate5
      ,iTermDate5
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([TypeOfBillCode_1], '')
      ,ISNULL([EffectivDate_1], '01/01/1900')
      ,ISNULL([TerminationDate_1], '12/31/9999')
      ,ISNULL([TypeOfBillCode_2], '')
      ,ISNULL([EffectivDate_2], '01/01/1900')
      ,ISNULL([TerminationDate_2], '12/31/9999')
      ,ISNULL([TypeOfBillCode_3], '')
      ,ISNULL([EffectivDate_3], '01/01/1900')
      ,ISNULL([TerminationDate_3], '12/31/9999')
      ,ISNULL([TypeOfBillCode_4], '')
      ,ISNULL([EffectivDate_4], '01/01/1900')
      ,ISNULL([TerminationDate_4], '12/31/9999')
      ,ISNULL([TypeOfBillCode_5], '')
      ,ISNULL([EffectivDate_5], '01/01/1900')
      ,ISNULL([TerminationDate_5], '12/31/9999')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_TypeOfBillListsListDetails
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TypeOfBillListsListDetails
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TypeOfBillListsListDetails_Cursor CURSOR FOR
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
       ,iTOBCode1
       ,iTOBDesc1
       ,iEffDate1
       ,iTermDate1
       ,iTOBCode2
       ,iTOBDesc2
       ,iEffDate2
       ,iTermDate2
       ,iTOBCode3
       ,iTOBDesc3
       ,iEffDate3
       ,iTermDate3
       ,iTOBCode4
       ,iTOBDesc4
       ,iEffDate4
       ,iTermDate4
       ,iTOBCode5
       ,iTOBDesc5
       ,iEffDate5
       ,iTermDate5
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TypeOfBillListsListDetails

   OPEN TypeOfBillListsListDetails_Cursor
  FETCH NEXT FROM TypeOfBillListsListDetails_Cursor
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
       ,@iTOBCode1
       ,@iTOBDesc1
       ,@iEffDate1
       ,@iTermDate1
       ,@iTOBCode2
       ,@iTOBDesc2
       ,@iEffDate2
       ,@iTermDate2
       ,@iTOBCode3
       ,@iTOBDesc3
       ,@iEffDate3
       ,@iTermDate3
       ,@iTOBCode4
       ,@iTOBDesc4
       ,@iEffDate4
       ,@iTermDate4
       ,@iTOBCode5
       ,@iTOBDesc5
       ,@iEffDate5
       ,@iTermDate5
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
			   AND entity_identifier		= 'TOB_LIST'

			EXEC dbo.prTOBList_Add
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
				,@iTOBCode1
				,@iTOBDesc1
				,@iEffDate1
				,@iTermDate1
				,@iTOBCode2
				,@iTOBDesc2
				,@iEffDate2
				,@iTermDate2
				,@iTOBCode3
				,@iTOBDesc3
				,@iEffDate3
				,@iTermDate3
				,@iTOBCode4
				,@iTOBDesc4
				,@iEffDate4
				,@iTermDate4
				,@iTOBCode5
				,@iTOBDesc5
				,@iEffDate5
				,@iTermDate5
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iTOBCode1, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TypeOfBillListsListDetails_Cursor
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
             ,@iTOBCode1
             ,@iTOBDesc1
             ,@iEffDate1
             ,@iTermDate1
             ,@iTOBCode2
             ,@iTOBDesc2
             ,@iEffDate2
             ,@iTermDate2
             ,@iTOBCode3
             ,@iTOBDesc3
             ,@iEffDate3
             ,@iTermDate3
             ,@iTOBCode4
             ,@iTOBDesc4
             ,@iEffDate4
             ,@iTermDate4
             ,@iTOBCode5
             ,@iTOBDesc5
             ,@iEffDate5
             ,@iTermDate5
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TypeOfBillListsListDetails_Cursor
DEALLOCATE TypeOfBillListsListDetails_Cursor

END
GO