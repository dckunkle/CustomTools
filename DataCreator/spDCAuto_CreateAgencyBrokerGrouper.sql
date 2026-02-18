IF OBJECT_ID('dbo.spDCAuto_CreateAgencyBrokerGrouper') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAgencyBrokerGrouper AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAgencyBrokerGrouper
Purpose:    Create agencybrokergrouper data from CorderAutomation
Method:     AgencyBrokerGrouper
Screen GID: 9988
Procedure:  dbo.prAgencyBrokerGrouper_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAgencyBrokerGrouper '100-Config%', 22, 'AgencyBrokerGrouper'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAgencyBrokerGrouper
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
       ,@iGrouperGid          VARCHAR(80)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@i_UserID             VARCHAR(25)
       ,@iGrouperID           VARCHAR(50)
       ,@iGrouperDesc         VARCHAR(100)
       ,@iAgencyID1           VARCHAR(50)
       ,@iAgencyName1         VARCHAR(100)
       ,@iBrokerID1           VARCHAR(50)
       ,@iBrokerName1         VARCHAR(100)
       ,@iPercentage1         VARCHAR(50)
       ,@iAgencyID2           VARCHAR(50)
       ,@iAgencyName2         VARCHAR(100)
       ,@iBrokerID2           VARCHAR(50)
       ,@iBrokerName2         VARCHAR(100)
       ,@iPercentage2         VARCHAR(50)
       ,@iAgencyID3           VARCHAR(50)
       ,@iAgencyName3         VARCHAR(100)
       ,@iBrokerID3           VARCHAR(50)
       ,@iBrokerName3         VARCHAR(100)
       ,@iPercentage3         VARCHAR(50)
       ,@iAgencyID4           VARCHAR(50)
       ,@iAgencyName4         VARCHAR(100)
       ,@iBrokerID4           VARCHAR(50)
       ,@iBrokerName4         VARCHAR(100)
       ,@iPercentage4         VARCHAR(50)
       ,@iAgencyID5           VARCHAR(50)
       ,@iAgencyName5         VARCHAR(100)
       ,@iBrokerID5           VARCHAR(50)
       ,@iBrokerName5         VARCHAR(100)
       ,@iPercentage5         VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AgencyBrokerGrouper') IS NOT NULL
	DROP TABLE #AgencyBrokerGrouper

CREATE TABLE #AgencyBrokerGrouper
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Agency_Broker_Grouper')
      ,iGrouperGid          VARCHAR(80)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,i_UserID             VARCHAR(25)       DEFAULT('')
      ,iGrouperID           VARCHAR(50)
      ,iGrouperDesc         VARCHAR(100)
      ,iAgencyID1           VARCHAR(50)
      ,iAgencyName1         VARCHAR(100)
      ,iBrokerID1           VARCHAR(50)
      ,iBrokerName1         VARCHAR(100)
      ,iPercentage1         VARCHAR(50)
      ,iAgencyID2           VARCHAR(50)
      ,iAgencyName2         VARCHAR(100)
      ,iBrokerID2           VARCHAR(50)
      ,iBrokerName2         VARCHAR(100)
      ,iPercentage2         VARCHAR(50)
      ,iAgencyID3           VARCHAR(50)
      ,iAgencyName3         VARCHAR(100)
      ,iBrokerID3           VARCHAR(50)
      ,iBrokerName3         VARCHAR(100)
      ,iPercentage3         VARCHAR(50)
      ,iAgencyID4           VARCHAR(50)
      ,iAgencyName4         VARCHAR(100)
      ,iBrokerID4           VARCHAR(50)
      ,iBrokerName4         VARCHAR(100)
      ,iPercentage4         VARCHAR(50)
      ,iAgencyID5           VARCHAR(50)
      ,iAgencyName5         VARCHAR(100)
      ,iBrokerID5           VARCHAR(50)
      ,iBrokerName5         VARCHAR(100)
      ,iPercentage5         VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AgencyBrokerGrouper
      (SearchID
      ,iGrouperID           
      ,iGrouperDesc         
      ,iAgencyID1           
      ,iBrokerID1           
      ,iPercentage1         
      ,iAgencyID2           
      ,iBrokerID2           
      ,iPercentage2         
      ,iAgencyID3           
      ,iBrokerID3           
      ,iPercentage3         
      ,iAgencyID4           
      ,iBrokerID4           
      ,iPercentage4         
      ,iAgencyID5           
      ,iBrokerID5           
      ,iPercentage5         
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*GrouperID], '')
      ,ISNULL([*GrouperDesc], '')
      ,ISNULL([AB1_AgencyID], '')
      ,ISNULL([AB1_BrokerID], '')
      ,ISNULL([AB1_Percentage], '')
      ,ISNULL([AB2_AgencyID], '')
      ,ISNULL([AB2_BrokerID], '')
      ,ISNULL([AB2_Percentage], '')
      ,ISNULL([AB3_AgencyID], '')
      ,ISNULL([AB3_BrokerID], '')
      ,ISNULL([AB3_Percentage], '')
      ,ISNULL([AB4_AgencyID], '')
      ,ISNULL([AB4_BrokerID], '')
      ,ISNULL([AB4_Percentage], '')
      ,ISNULL([AB5_AgencyID], '')
      ,ISNULL([AB5_BrokerID], '')
      ,ISNULL([AB5_Percentage], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AgencyBrokerGrouper
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AgencyBrokerGrouper
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AgencyBrokerGrouper_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,iGrouperGid
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
       ,i_UserID
       ,iGrouperID
       ,iGrouperDesc
       ,iAgencyID1
       ,iAgencyName1
       ,iBrokerID1
       ,iBrokerName1
       ,iPercentage1
       ,iAgencyID2
       ,iAgencyName2
       ,iBrokerID2
       ,iBrokerName2
       ,iPercentage2
       ,iAgencyID3
       ,iAgencyName3
       ,iBrokerID3
       ,iBrokerName3
       ,iPercentage3
       ,iAgencyID4
       ,iAgencyName4
       ,iBrokerID4
       ,iBrokerName4
       ,iPercentage4
       ,iAgencyID5
       ,iAgencyName5
       ,iBrokerID5
       ,iBrokerName5
       ,iPercentage5
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AgencyBrokerGrouper

   OPEN AgencyBrokerGrouper_Cursor
  FETCH NEXT FROM AgencyBrokerGrouper_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@iGrouperGid
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
       ,@i_UserID
       ,@iGrouperID
       ,@iGrouperDesc
       ,@iAgencyID1
       ,@iAgencyName1
       ,@iBrokerID1
       ,@iBrokerName1
       ,@iPercentage1
       ,@iAgencyID2
       ,@iAgencyName2
       ,@iBrokerID2
       ,@iBrokerName2
       ,@iPercentage2
       ,@iAgencyID3
       ,@iAgencyName3
       ,@iBrokerID3
       ,@iBrokerName3
       ,@iPercentage3
       ,@iAgencyID4
       ,@iAgencyName4
       ,@iBrokerID4
       ,@iBrokerName4
       ,@iPercentage4
       ,@iAgencyID5
       ,@iAgencyName5
       ,@iBrokerID5
       ,@iBrokerName5
       ,@iPercentage5
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prAgencyBrokerGrouper_AddModify
             @i_entity_name
            ,@iGrouperGid
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
            ,@i_UserID
            ,@iGrouperID
            ,@iGrouperDesc
            ,@iAgencyID1
            ,@iAgencyName1
            ,@iBrokerID1
            ,@iBrokerName1
            ,@iPercentage1
            ,@iAgencyID2
            ,@iAgencyName2
            ,@iBrokerID2
            ,@iBrokerName2
            ,@iPercentage2
            ,@iAgencyID3
            ,@iAgencyName3
            ,@iBrokerID3
            ,@iBrokerName3
            ,@iPercentage3
            ,@iAgencyID4
            ,@iAgencyName4
            ,@iBrokerID4
            ,@iBrokerName4
            ,@iPercentage4
            ,@iAgencyID5
            ,@iAgencyName5
            ,@iBrokerID5
            ,@iBrokerName5
            ,@iPercentage5
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Get the current gid
				SELECT @current_gid				= EN.entity_gid
				  FROM dbo.Entity_Names			EN
				 WHERE record_status			= 'A'
				   AND EN.entity_identifier		= 'Agency_Broker_Grouper'
				   AND EN.entity_user_id		= @iGrouperID

				-- Update to the static gid
				UPDATE dbo.Agency_Broker_Grouper_Details 
				   SET Agency_Broker_Grouper_Gid			= @static_gid 
				 WHERE record_status						= 'A'
				   AND Agency_Broker_Grouper_Gid			= @current_gid

				UPDATE Entity_Names
				   SET entity_gid							= @static_gid
				 WHERE entity_identifier					= 'Agency_Broker_Grouper'
				   AND entity_gid							= @current_gid

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iGrouperID, @iAgencyID1, @iAgencyID2, @status, @err_num, @err_msg

        FETCH NEXT FROM AgencyBrokerGrouper_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@iGrouperGid
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
             ,@i_UserID
             ,@iGrouperID
             ,@iGrouperDesc
             ,@iAgencyID1
             ,@iAgencyName1
             ,@iBrokerID1
             ,@iBrokerName1
             ,@iPercentage1
             ,@iAgencyID2
             ,@iAgencyName2
             ,@iBrokerID2
             ,@iBrokerName2
             ,@iPercentage2
             ,@iAgencyID3
             ,@iAgencyName3
             ,@iBrokerID3
             ,@iBrokerName3
             ,@iPercentage3
             ,@iAgencyID4
             ,@iAgencyName4
             ,@iBrokerID4
             ,@iBrokerName4
             ,@iPercentage4
             ,@iAgencyID5
             ,@iAgencyName5
             ,@iBrokerID5
             ,@iBrokerName5
             ,@iPercentage5
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AgencyBrokerGrouper_Cursor
DEALLOCATE AgencyBrokerGrouper_Cursor

END
GO