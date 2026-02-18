IF OBJECT_ID('dbo.spDCAuto_CreateCodeListsCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeListsCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeListsCodes
Purpose:    Create codelistscodes data from CorderAutomation
Method:     CodeListsCodes
Screen GID: 3104
Procedure:  dbo.prProdListAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeListsCodes '100-Config%', 22, 'CodeListsCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeListsCodes
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

DECLARE @i_entity_name           VARCHAR(50)
       ,@i_Product_List_GID      VARCHAR(50)
       ,@i_Key_Effective_Date    VARCHAR(50)
       ,@i_Key_Termination_Date  VARCHAR(50)
       ,@i_Key_Product_Qualifier VARCHAR(50)
       ,@i_Key_Product_ID        VARCHAR(50)
       ,@i_key_6_field           VARCHAR(50)
       ,@i_key_7_field           VARCHAR(50)
       ,@i_key_8_field           VARCHAR(50)
       ,@i_key_9_field           VARCHAR(50)
       ,@i_key_10_field          VARCHAR(50)
       ,@i_action                VARCHAR(10)
       ,@i_date_time_modified    VARCHAR(30)
       ,@iUserID                 VARCHAR(25)
       ,@iImportListID           VARCHAR(50)
       ,@iImportListDesc         VARCHAR(50)
       ,@i_Effective_Date        VARCHAR(50)
       ,@i_Termination_Date      VARCHAR(50)
       ,@i_Product_Qualifier     VARCHAR(50)
       ,@i_Product_ID            VARCHAR(50)
       ,@i_Product_Desc          VARCHAR(300)
       ,@o_status                INT
       ,@o_message               VARCHAR(100)
	   ,@SearchID				 VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeListsCodes') IS NOT NULL
	DROP TABLE #CodeListsCodes

CREATE TABLE #CodeListsCodes
      (i_entity_name           VARCHAR(50)       DEFAULT('Product_List')
      ,i_Product_List_GID      VARCHAR(50)       DEFAULT('0')
      ,i_Key_Effective_Date    VARCHAR(50)       DEFAULT('0')
      ,i_Key_Termination_Date  VARCHAR(50)       DEFAULT('0')
      ,i_Key_Product_Qualifier VARCHAR(50)       DEFAULT('0')
      ,i_Key_Product_ID        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field           VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field          VARCHAR(50)       DEFAULT('0')
      ,i_action                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified    VARCHAR(30)       DEFAULT('')
      ,iUserID                 VARCHAR(25)       DEFAULT('')
      ,iImportListID           VARCHAR(50)
      ,iImportListDesc         VARCHAR(50)
      ,i_Effective_Date        VARCHAR(50)
      ,i_Termination_Date      VARCHAR(50)
      ,i_Product_Qualifier     VARCHAR(50)
      ,i_Product_ID            VARCHAR(50)
      ,i_Product_Desc          VARCHAR(300)
      ,o_status                INT
      ,o_message               VARCHAR(100)
      ,record_id               INT
      ,static_gid              INT
	  ,SearchID				   VARCHAR(200))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeListsCodes
      (SearchID
	  ,i_Effective_Date
      ,i_Termination_Date
      ,i_Product_Qualifier
      ,i_Product_ID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CodeListQualifier]), '')
      ,ISNULL([*CodeID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeListsCode
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeListsCodes
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeListsCodes_Cursor CURSOR FOR
 SELECT SearchID 
       ,i_entity_name
       ,i_Product_List_GID
       ,i_Key_Effective_Date
       ,i_Key_Termination_Date
       ,i_Key_Product_Qualifier
       ,i_Key_Product_ID
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,iImportListID
       ,iImportListDesc
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Product_Qualifier
       ,i_Product_ID
       ,i_Product_Desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeListsCodes

   OPEN CodeListsCodes_Cursor
  FETCH NEXT FROM CodeListsCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Product_List_GID
       ,@i_Key_Effective_Date
       ,@i_Key_Termination_Date
       ,@i_Key_Product_Qualifier
       ,@i_Key_Product_ID
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@iImportListID
       ,@iImportListDesc
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Product_Qualifier
       ,@i_Product_ID
       ,@i_Product_Desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			--Get the gid for the Code List
			SELECT @i_Product_List_GID	= entity_gid
			  FROM Entity_Names
			 WHERE entity_identifier	= 'Product_List_Name'
			   AND entity_user_id		= @SearchID

			EXEC dbo.prProdListAddModify
             @i_entity_name
            ,@i_Product_List_GID
            ,@i_Key_Effective_Date
            ,@i_Key_Termination_Date
            ,@i_Key_Product_Qualifier
            ,@i_Key_Product_ID
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@iImportListID
            ,@iImportListDesc
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Product_Qualifier
            ,@i_Product_ID
            ,@i_Product_Desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Product_Qualifier, @i_Product_ID, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeListsCodes_Cursor
         INTO @SearchID
		     ,@i_entity_name
             ,@i_Product_List_GID
             ,@i_Key_Effective_Date
             ,@i_Key_Termination_Date
             ,@i_Key_Product_Qualifier
             ,@i_Key_Product_ID
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@iImportListID
             ,@iImportListDesc
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Product_Qualifier
             ,@i_Product_ID
             ,@i_Product_Desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeListsCodes_Cursor
DEALLOCATE CodeListsCodes_Cursor

END
GO