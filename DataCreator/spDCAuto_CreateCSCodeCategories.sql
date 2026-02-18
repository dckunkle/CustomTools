IF OBJECT_ID('dbo.spDCAuto_CreateCSCodeCategories') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCSCodeCategories AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCSCodeCategories
Purpose:    Create cscodecategories data from CorderAutomation
Method:     CSCodeCategories
Screen GID: 225
Procedure:  dbo.prCSCodeAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/27/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCSCodeCategories '100-Config%', 22, 'CSCodeCategories'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCSCodeCategories
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

DECLARE @iEntity           VARCHAR(50)
       ,@iKeyCS_Code_ID    VARCHAR(100)
       ,@iKeyField2        VARCHAR(100)
       ,@iKeyField3        VARCHAR(100)
       ,@iKeyField4        VARCHAR(100)
       ,@iKeyField5        VARCHAR(50)
       ,@iKeyField6        VARCHAR(50)
       ,@iKeyField7        VARCHAR(50)
       ,@iKeyField8        VARCHAR(100)
       ,@iKeyField9        VARCHAR(100)
       ,@iKeyField10       VARCHAR(50)
       ,@iAction           VARCHAR(10)
       ,@iDateModified     VARCHAR(50)
       ,@iUserID           VARCHAR(25)
       ,@iCS_Code_ID       VARCHAR(50)
       ,@iCode_Description VARCHAR(150)
       ,@iCategory_Label   VARCHAR(50)
       ,@iDisplay_Order    VARCHAR(50)
       ,@iApplyToAll       VARCHAR(50)
       ,@iInquiry_Reason   VARCHAR(50)
       ,@iInquiry_Desc     VARCHAR(50)
       ,@iReqComment       VARCHAR(50)
       ,@iActive           VARCHAR(50)
       ,@oStatus           INT
       ,@oMessage          VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CSCodeCategories') IS NOT NULL
	DROP TABLE #CSCodeCategories

CREATE TABLE #CSCodeCategories
      (SearchID          VARCHAR(200)
      ,iEntity           VARCHAR(50)      DEFAULT('CS_Categories')
      ,iKeyCS_Code_ID    VARCHAR(100)     DEFAULT('0')
      ,iKeyField2        VARCHAR(100)     DEFAULT('0')
      ,iKeyField3        VARCHAR(100)     DEFAULT('0')
      ,iKeyField4        VARCHAR(100)     DEFAULT('0')
      ,iKeyField5        VARCHAR(50)      DEFAULT('0')
      ,iKeyField6        VARCHAR(50)      DEFAULT('0')
      ,iKeyField7        VARCHAR(50)      DEFAULT('0')
      ,iKeyField8        VARCHAR(100)     DEFAULT('0')
      ,iKeyField9        VARCHAR(100)     DEFAULT('0')
      ,iKeyField10       VARCHAR(50)      DEFAULT('0')
      ,iAction           VARCHAR(10)      DEFAULT('ADD')
      ,iDateModified     VARCHAR(50)      DEFAULT('')
      ,iUserID           VARCHAR(25)      DEFAULT('')
      ,iCS_Code_ID       VARCHAR(50)
      ,iCode_Description VARCHAR(150)
      ,iCategory_Label   VARCHAR(50)
      ,iDisplay_Order    VARCHAR(50)
      ,iApplyToAll       VARCHAR(50)
      ,iInquiry_Reason   VARCHAR(50)
      ,iInquiry_Desc     VARCHAR(50)
      ,iReqComment       VARCHAR(50)
      ,iActive           VARCHAR(50)
      ,oStatus           INT
      ,oMessage          VARCHAR(250)
      ,record_id         INT
      ,static_gid        INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CSCodeCategories
      (SearchID
      ,iCS_Code_ID
      ,iCode_Description
      ,iCategory_Label
      ,iDisplay_Order
      ,iApplyToAll
      ,iInquiry_Reason
      ,iReqComment
      ,iActive
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*CSCodeID], '')
      ,ISNULL([*CodeDescription], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CategoryColumn]), 'CSRS2')
      ,ISNULL([*DisplayOrder], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*AssigntoAllInquiryReasons]), 'Y')
      ,ISNULL([InquiryReasonID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*RequiresComment]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Active]), 'Y')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CsCodeCategories
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CSCodeCategories
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CSCodeCategories_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iKeyCS_Code_ID
       ,iKeyField2
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
       ,iCS_Code_ID
       ,iCode_Description
       ,iCategory_Label
       ,iDisplay_Order
       ,iApplyToAll
       ,iInquiry_Reason
       ,iInquiry_Desc
       ,iReqComment
       ,iActive
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #CSCodeCategories

   OPEN CSCodeCategories_Cursor
  FETCH NEXT FROM CSCodeCategories_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iKeyCS_Code_ID
       ,@iKeyField2
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
       ,@iCS_Code_ID
       ,@iCode_Description
       ,@iCategory_Label
       ,@iDisplay_Order
       ,@iApplyToAll
       ,@iInquiry_Reason
       ,@iInquiry_Desc
       ,@iReqComment
       ,@iActive
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prCSCodeAddModify
             @iEntity
            ,@iKeyCS_Code_ID
            ,@iKeyField2
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
            ,@iCS_Code_ID
            ,@iCode_Description
            ,@iCategory_Label
            ,@iDisplay_Order
            ,@iApplyToAll
            ,@iInquiry_Reason
            ,@iInquiry_Desc
            ,@iReqComment
            ,@iActive
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iCS_Code_ID, @iCode_Description, '', @status, @err_num, @err_msg

        FETCH NEXT FROM CSCodeCategories_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iKeyCS_Code_ID
             ,@iKeyField2
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
             ,@iCS_Code_ID
             ,@iCode_Description
             ,@iCategory_Label
             ,@iDisplay_Order
             ,@iApplyToAll
             ,@iInquiry_Reason
             ,@iInquiry_Desc
             ,@iReqComment
             ,@iActive
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE CSCodeCategories_Cursor
DEALLOCATE CSCodeCategories_Cursor

END
GO