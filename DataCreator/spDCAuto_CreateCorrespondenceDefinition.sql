IF OBJECT_ID('dbo.spDCAuto_CreateCorrespondenceDefinition') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCorrespondenceDefinition AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCorrespondenceDefinition
Purpose:    Create correspondencedefinition data from CorderAutomation
Method:     CorrespondenceDefinition
Screen GID: 168
Procedure:  dbo.prCorrespondence_Definition_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
03/31/2020	DK				Original procedure
07/21/2020	DK				Add pause to avoid PK Violation
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCorrespondenceDefinition '100-Config%', 22, 'CorrespondenceDefinition'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCorrespondenceDefinition
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
       ,@i_correspondence_gid  VARCHAR(50)
       ,@i_key_2_corrid        VARCHAR(100)
       ,@i_key_3_desc          VARCHAR(50)
       ,@i_key_4_datagid       VARCHAR(100)
       ,@i_key_5_field         VARCHAR(50)
       ,@i_key_6_field         VARCHAR(50)
       ,@i_key_7_field         VARCHAR(100)
       ,@i_key_8_field         VARCHAR(100)
       ,@i_key_9_field         VARCHAR(100)
       ,@i_key_10_field        VARCHAR(50)
       ,@i_action              VARCHAR(10)
       ,@i_date_time_modified  VARCHAR(100)
       ,@i_UserID              VARCHAR(100)
       ,@i_correspondence_id   VARCHAR(100)
       ,@i_correspondence_desc VARCHAR(50)
       ,@i_dataset_gid         VARCHAR(50)
       ,@i_dataset_desc        VARCHAR(100)
       ,@i_calendar_id         VARCHAR(50)
       ,@i_calendar_desc       VARCHAR(100)
       ,@i_delivery_method     VARCHAR(50)
       ,@i_paper_stock         VARCHAR(50)
       ,@i_document_id         VARCHAR(50)
       ,@i_document_file       VARCHAR(50)
       ,@iContactPurpose       VARCHAR(50)
       ,@iOutputDep            VARCHAR(50)
       ,@iCOBRAOptions         VARCHAR(50)
       ,@oStatus               INT
       ,@oMessage              VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CorrespondenceDefinition') IS NOT NULL
	DROP TABLE #CorrespondenceDefinition

CREATE TABLE #CorrespondenceDefinition
      (SearchID              VARCHAR(200)
      ,i_entity_name         VARCHAR(100)      DEFAULT('Correspondence_Definition')
      ,i_correspondence_gid  VARCHAR(50)       DEFAULT('0')
      ,i_key_2_corrid        VARCHAR(100)      DEFAULT('0')
      ,i_key_3_desc          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_datagid       VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field         VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_8_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field         VARCHAR(100)      DEFAULT('0')
      ,i_key_10_field        VARCHAR(50)       DEFAULT('0')
      ,i_action              VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified  VARCHAR(100)      DEFAULT('')
      ,i_UserID              VARCHAR(100)      DEFAULT('')
      ,i_correspondence_id   VARCHAR(100)
      ,i_correspondence_desc VARCHAR(50)
      ,i_dataset_gid         VARCHAR(50)
      ,i_dataset_desc        VARCHAR(100)
      ,i_calendar_id         VARCHAR(50)
      ,i_calendar_desc       VARCHAR(100)
      ,i_delivery_method     VARCHAR(50)	   DEFAULT('M')
      ,i_paper_stock         VARCHAR(50)
      ,i_document_id         VARCHAR(50)
      ,i_document_file       VARCHAR(50)
      ,iContactPurpose       VARCHAR(50)
      ,iOutputDep            VARCHAR(50)
      ,iCOBRAOptions         VARCHAR(50)
      ,oStatus               INT
      ,oMessage              VARCHAR(100)
      ,record_id             INT
      ,static_gid            INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CorrespondenceDefinition
      (SearchID
      ,i_correspondence_id
      ,i_correspondence_desc
      ,i_dataset_gid
      ,i_calendar_id
      ,i_paper_stock
      ,i_document_id
      ,i_document_file
	  ,iContactPurpose
      ,iOutputDep
      ,iCOBRAOptions
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*CorrespondenceID], '')
      ,ISNULL([*CorrespondenceDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*DataSet]), 'Claim')
      ,ISNULL([CalendarID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PaperStock]), 'D')
      ,ISNULL([DocumentID], '')
      ,ISNULL([DocumentFile], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactPurpose]), 'X115')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OutputDependents]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IncludeCOBRARateOptions]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CorrespondenceDef
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CorrespondenceDefinition
   SET i_UserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CorrespondenceDefinition_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_correspondence_gid
       ,i_key_2_corrid
       ,i_key_3_desc
       ,i_key_4_datagid
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,i_UserID
       ,i_correspondence_id
       ,i_correspondence_desc
       ,i_dataset_gid
       ,i_dataset_desc
       ,i_calendar_id
       ,i_calendar_desc
       ,i_delivery_method
       ,i_paper_stock
       ,i_document_id
       ,i_document_file
       ,iContactPurpose
       ,iOutputDep
       ,iCOBRAOptions
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #CorrespondenceDefinition

   OPEN CorrespondenceDefinition_Cursor
  FETCH NEXT FROM CorrespondenceDefinition_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_correspondence_gid
       ,@i_key_2_corrid
       ,@i_key_3_desc
       ,@i_key_4_datagid
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@i_UserID
       ,@i_correspondence_id
       ,@i_correspondence_desc
       ,@i_dataset_gid
       ,@i_dataset_desc
       ,@i_calendar_id
       ,@i_calendar_desc
       ,@i_delivery_method
       ,@i_paper_stock
       ,@i_document_id
       ,@i_document_file
       ,@iContactPurpose
       ,@iOutputDep
       ,@iCOBRAOptions
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prCorrespondence_Definition_Add_Modify
             @i_entity_name
            ,@i_correspondence_gid
            ,@i_key_2_corrid
            ,@i_key_3_desc
            ,@i_key_4_datagid
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@i_UserID
            ,@i_correspondence_id
            ,@i_correspondence_desc
            ,@i_dataset_gid
            ,@i_dataset_desc
            ,@i_calendar_id
            ,@i_calendar_desc
            ,@i_delivery_method
            ,@i_paper_stock
            ,@i_document_id
            ,@i_document_file
            ,@iContactPurpose
            ,@iOutputDep
            ,@iCOBRAOptions
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Correspondence_Definition 
				   SET correspondence_gid				= @static_gid 
				 WHERE record_status					= 'A'
				   AND correspondence_id				= @i_correspondence_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_correspondence_id, @i_correspondence_desc, '', @status, @err_num, @err_msg
		
		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CorrespondenceDefinition_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_correspondence_gid
             ,@i_key_2_corrid
             ,@i_key_3_desc
             ,@i_key_4_datagid
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@i_UserID
             ,@i_correspondence_id
             ,@i_correspondence_desc
             ,@i_dataset_gid
             ,@i_dataset_desc
             ,@i_calendar_id
             ,@i_calendar_desc
             ,@i_delivery_method
             ,@i_paper_stock
             ,@i_document_id
             ,@i_document_file
             ,@iContactPurpose
             ,@iOutputDep
             ,@iCOBRAOptions
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE CorrespondenceDefinition_Cursor
DEALLOCATE CorrespondenceDefinition_Cursor

END
GO