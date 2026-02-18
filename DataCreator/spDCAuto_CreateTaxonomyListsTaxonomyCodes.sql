IF OBJECT_ID('dbo.spDCAuto_CreateTaxonomyListsTaxonomyCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTaxonomyListsTaxonomyCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTaxonomyListsTaxonomyCodes
Purpose:    Create taxonomyliststaxonomycodes data from CorderAutomation

Screen:     1067
Method:     TaxonomyListsTaxonomyCodes
Procedure:  dbo.prCommonList_AddModify_Taxwrapper
Entity:     TAXONOMY_LIST_VARIATION

Date        User            Change
---------------------------------------------------------------------------------------------
03/29/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTaxonomyListsTaxonomyCodes '100-Config%', 22, 'TaxonomyListsTaxonomyCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTaxonomyListsTaxonomyCodes
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

DECLARE @iEntity         VARCHAR(50)
       ,@iEntityGid      VARCHAR(50)
       ,@iOrigListValue  VARCHAR(50)
       ,@iKeyField3      VARCHAR(50)
       ,@iKeyField4      VARCHAR(50)
       ,@iKeyField5      VARCHAR(50)
       ,@iKeyField6      VARCHAR(50)
       ,@iKeyField7      VARCHAR(50)
       ,@iKeyField8      VARCHAR(50)
       ,@iKeyField9      VARCHAR(50)
       ,@iKeyField10     VARCHAR(50)
       ,@iAction         VARCHAR(10)
       ,@iDateModified   VARCHAR(50)
       ,@iUserID         VARCHAR(25)
       ,@iListValue1     VARCHAR(50)
       ,@iListValueDesc1 VARCHAR(50)
       ,@iListValue2     VARCHAR(50)
       ,@iListValueDesc2 VARCHAR(50)
       ,@iListValue3     VARCHAR(50)
       ,@iListValueDesc3 VARCHAR(50)
       ,@iListValue4     VARCHAR(50)
       ,@iListValueDesc4 VARCHAR(50)
       ,@iListValue5     VARCHAR(50)
       ,@iListValueDesc5 VARCHAR(50)
       ,@oStatus         INT
       ,@oMessage        VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TaxonomyListsTaxonomyCodes') IS NOT NULL
	DROP TABLE #TaxonomyListsTaxonomyCodes

CREATE TABLE #TaxonomyListsTaxonomyCodes
      (SearchID        VARCHAR(200)
      ,iEntity         VARCHAR(50)       DEFAULT('TAXONOMY_LIST_VARIATION')
      ,iEntityGid      VARCHAR(50)       DEFAULT('0')
      ,iOrigListValue  VARCHAR(50)       DEFAULT('0')
      ,iKeyField3      VARCHAR(50)       DEFAULT('0')
      ,iKeyField4      VARCHAR(50)       DEFAULT('0')
      ,iKeyField5      VARCHAR(50)       DEFAULT('0')
      ,iKeyField6      VARCHAR(50)       DEFAULT('0')
      ,iKeyField7      VARCHAR(50)       DEFAULT('0')
      ,iKeyField8      VARCHAR(50)       DEFAULT('0')
      ,iKeyField9      VARCHAR(50)       DEFAULT('0')
      ,iKeyField10     VARCHAR(50)       DEFAULT('0')
      ,iAction         VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified   VARCHAR(50)       DEFAULT('')
      ,iUserID         VARCHAR(25)       DEFAULT('')
      ,iListValue1     VARCHAR(50)
      ,iListValueDesc1 VARCHAR(50)
      ,iListValue2     VARCHAR(50)
      ,iListValueDesc2 VARCHAR(50)
      ,iListValue3     VARCHAR(50)
      ,iListValueDesc3 VARCHAR(50)
      ,iListValue4     VARCHAR(50)
      ,iListValueDesc4 VARCHAR(50)
      ,iListValue5     VARCHAR(50)
      ,iListValueDesc5 VARCHAR(50)
      ,oStatus         INT
      ,oMessage        VARCHAR(250)
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
BEGIN TRY

    INSERT INTO #TaxonomyListsTaxonomyCodes
          (SearchID
          ,iListValue1
          ,iListValue2
          ,iListValue3
          ,iListValue4
          ,iListValue5
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([TaxonomyID_1], '')
          ,ISNULL([TaxonomyID_2], '')
          ,ISNULL([TaxonomyID_3], '')
          ,ISNULL([TaxonomyID_4], '')
          ,ISNULL([TaxonomyID_5], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_TaxonomyListsTaxonomyCodes
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #TaxonomyListsTaxonomyCodes
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
DECLARE TaxonomyListsTaxonomyCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iEntityGid
       ,iOrigListValue
       ,iKeyField3
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iListValue1
       ,iListValueDesc1
       ,iListValue2
       ,iListValueDesc2
       ,iListValue3
       ,iListValueDesc3
       ,iListValue4
       ,iListValueDesc4
       ,iListValue5
       ,iListValueDesc5
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #TaxonomyListsTaxonomyCodes

   OPEN TaxonomyListsTaxonomyCodes_Cursor
  FETCH NEXT FROM TaxonomyListsTaxonomyCodes_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iEntityGid
       ,@iOrigListValue
       ,@iKeyField3
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iListValue1
       ,@iListValueDesc1
       ,@iListValue2
       ,@iListValueDesc2
       ,@iListValue3
       ,@iListValueDesc3
       ,@iListValue4
       ,@iListValueDesc4
       ,@iListValue5
       ,@iListValueDesc5
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

			SELECT @iEntityGid			= EN.entity_gid
			  FROM Entity_Names			EN
			 WHERE EN.record_status		= 'A'
			   AND EN.entity_identifier	= 'TAXONOMY_LIST'
			   AND EN.entity_user_id	= @SearchID

			EXEC dbo.prCommonList_AddModify_Taxwrapper
                 @iEntity
                ,@iEntityGid
                ,@iOrigListValue
                ,@iKeyField3
                ,@iKeyField4
                ,@iKeyField5
                ,@iKeyField6
                ,@iKeyField7
                ,@iKeyField8
                ,@iKeyField9
                ,@iKeyField10
                ,@iAction
                ,@iDateModified
                ,@iUserID
                ,@iListValue1
                ,@iListValueDesc1
                ,@iListValue2
                ,@iListValueDesc2
                ,@iListValue3
                ,@iListValueDesc3
                ,@iListValue4
                ,@iListValueDesc4
                ,@iListValue5
                ,@iListValueDesc5
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iListValue1, @iListValueDesc1, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM TaxonomyListsTaxonomyCodes_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iEntityGid
             ,@iOrigListValue
             ,@iKeyField3
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iListValue1
             ,@iListValueDesc1
             ,@iListValue2
             ,@iListValueDesc2
             ,@iListValue3
             ,@iListValueDesc3
             ,@iListValue4
             ,@iListValueDesc4
             ,@iListValue5
             ,@iListValueDesc5
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE TaxonomyListsTaxonomyCodes_Cursor
DEALLOCATE TaxonomyListsTaxonomyCodes_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#TaxonomyListsTaxonomyCodes') IS NOT NULL
	DROP TABLE #TaxonomyListsTaxonomyCodes

END
GO

