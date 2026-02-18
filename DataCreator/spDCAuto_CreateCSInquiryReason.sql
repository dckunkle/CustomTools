IF OBJECT_ID('dbo.spDCAuto_CreateCSInquiryReason') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCSInquiryReason AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCSInquiryReason
Purpose:    Create csinquiryreason data from CorderAutomation
Method:     CSInquiryReason
Screen GID: 4500
Procedure:  dbo.prInquiryReasonsAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/27/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCSInquiryReason '100-Config%', 22, 'CSInquiryReason'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCSInquiryReason
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

DECLARE @i_entity_name         VARCHAR(100)
       ,@iKeyInquiryReason     VARCHAR(100)
       ,@i_key_2_field         VARCHAR(100)
       ,@i_key_3_field         VARCHAR(100)
       ,@i_key_4_field         VARCHAR(50)
       ,@i_key_5_field         VARCHAR(50)
       ,@i_key_6_field         VARCHAR(50)
       ,@i_key_7_field         VARCHAR(50)
       ,@i_key_8_field         VARCHAR(50)
       ,@i_key_9_field         VARCHAR(50)
       ,@i_key_10_field        VARCHAR(50)
       ,@i_action              VARCHAR(10)
       ,@iDateModified         VARCHAR(50)
       ,@iUserID               VARCHAR(25)
       ,@i_Inquiry_Reason      VARCHAR(50)
       ,@i_Inquiry_Reason_Desc VARCHAR(50)
       ,@i_Inquiry_Type        VARCHAR(50)
       ,@i_Routing_Screen      VARCHAR(50)
       ,@i_NCQA_required       VARCHAR(50)
       ,@o_status              INT
       ,@o_message             VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CSInquiryReason') IS NOT NULL
	DROP TABLE #CSInquiryReason

CREATE TABLE #CSInquiryReason
      (SearchID              VARCHAR(200)
      ,i_entity_name         VARCHAR(100)      DEFAULT('CS_Inquiry_Reasons')
      ,iKeyInquiryReason     VARCHAR(100)      DEFAULT('0')
      ,i_key_2_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified         VARCHAR(50)       DEFAULT('')
      ,iUserID               VARCHAR(25)       DEFAULT('')
      ,i_Inquiry_Reason      VARCHAR(50)
      ,i_Inquiry_Reason_Desc VARCHAR(50)
      ,i_Inquiry_Type        VARCHAR(50)
      ,i_Routing_Screen      VARCHAR(50)
      ,i_NCQA_required       VARCHAR(50)
      ,o_status              INT
      ,o_message             VARCHAR(100)
      ,record_id             INT
      ,static_gid            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CSInquiryReason
      (SearchID
      ,i_Inquiry_Reason
      ,i_Inquiry_Reason_Desc
      ,i_Inquiry_Type
      ,i_Routing_Screen
      ,i_NCQA_required
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*InquiryReason], '')
      ,ISNULL([*InquiryDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InquiryType]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*RoutingScreen]), 'MP')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*NCQAInquiryReasonRequired]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CsInquiryReason
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CSInquiryReason
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CSInquiryReason_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,iKeyInquiryReason
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
       ,iDateModified
       ,iUserID
       ,i_Inquiry_Reason
       ,i_Inquiry_Reason_Desc
       ,i_Inquiry_Type
       ,i_Routing_Screen
       ,i_NCQA_required
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CSInquiryReason

   OPEN CSInquiryReason_Cursor
  FETCH NEXT FROM CSInquiryReason_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@iKeyInquiryReason
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
       ,@iDateModified
       ,@iUserID
       ,@i_Inquiry_Reason
       ,@i_Inquiry_Reason_Desc
       ,@i_Inquiry_Type
       ,@i_Routing_Screen
       ,@i_NCQA_required
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prInquiryReasonsAddModify
             @i_entity_name
            ,@iKeyInquiryReason
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
            ,@iDateModified
            ,@iUserID
            ,@i_Inquiry_Reason
            ,@i_Inquiry_Reason_Desc
            ,@i_Inquiry_Type
            ,@i_Routing_Screen
            ,@i_NCQA_required
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Inquiry_Reason, @i_Inquiry_Reason_Desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM CSInquiryReason_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@iKeyInquiryReason
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
             ,@iDateModified
             ,@iUserID
             ,@i_Inquiry_Reason
             ,@i_Inquiry_Reason_Desc
             ,@i_Inquiry_Type
             ,@i_Routing_Screen
             ,@i_NCQA_required
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CSInquiryReason_Cursor
DEALLOCATE CSInquiryReason_Cursor

END
GO