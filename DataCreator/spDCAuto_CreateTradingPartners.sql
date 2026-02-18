IF OBJECT_ID('dbo.spDCAuto_CreateTradingPartners') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTradingPartners AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTradingPartners
Purpose:    Create tradingpartners data from CorderAutomation
Method:     TradingPartners
Screen GID: 9989
Procedure:  dbo.prTrading_Partners_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTradingPartners '100-Config%', 22, 'TradingPartners'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTradingPartners
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

DECLARE @i_entity_name                VARCHAR(50)
       ,@i_key_1_Trading_partner_gid  VARCHAR(50)
       ,@i_key_2_entity_type          VARCHAR(50)
       ,@i_key_3_Entity_gid           VARCHAR(50)
       ,@i_key_4_Entity_id            VARCHAR(200)
       ,@i_key_5_Entity_Name          VARCHAR(50)
       ,@i_key_6_Interchange_type_id  VARCHAR(50)
       ,@i_key_7_Interchange_id       VARCHAR(50)
       ,@i_key_8_field                VARCHAR(50)
       ,@i_key_9_Status               VARCHAR(50)
       ,@i_key_10_Trading_Partner_sid VARCHAR(50)
       ,@iAction                      VARCHAR(10)
       ,@i_date_time_modified         VARCHAR(20)
       ,@i_user_id                    VARCHAR(20)
       ,@i_entity_type                VARCHAR(50)
       ,@i_Entity_ID                  VARCHAR(50)
       ,@i_entity_type_desc           VARCHAR(50)
       ,@i_Interchange_ID_Type        VARCHAR(50)
       ,@i_Interchange_ID             VARCHAR(50)
       ,@i_Trading_Partners_Status    VARCHAR(50)
       ,@iCMSFunctionCode             VARCHAR(50)
       ,@o_status                     INT
       ,@o_message                    VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TradingPartners') IS NOT NULL
	DROP TABLE #TradingPartners

CREATE TABLE #TradingPartners
      (SearchID                     VARCHAR(200)
      ,i_entity_name                VARCHAR(50)       DEFAULT('Trading_Partners')
      ,i_key_1_Trading_partner_gid  VARCHAR(50)       DEFAULT('0')
      ,i_key_2_entity_type          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_Entity_gid           VARCHAR(50)       DEFAULT('0')
      ,i_key_4_Entity_id            VARCHAR(200)      DEFAULT('0')
      ,i_key_5_Entity_Name          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_Interchange_type_id  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_Interchange_id       VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                VARCHAR(50)       DEFAULT('0')
      ,i_key_9_Status               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_Trading_Partner_sid VARCHAR(50)       DEFAULT('0')
      ,iAction                      VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified         VARCHAR(20)       DEFAULT('')
      ,i_user_id                    VARCHAR(20)       DEFAULT('')
      ,i_entity_type                VARCHAR(50)
      ,i_Entity_ID                  VARCHAR(50)
      ,i_entity_type_desc           VARCHAR(50)
      ,i_Interchange_ID_Type        VARCHAR(50)
      ,i_Interchange_ID             VARCHAR(50)
      ,i_Trading_Partners_Status    VARCHAR(50)
      ,iCMSFunctionCode             VARCHAR(50)
      ,o_status                     INT
      ,o_message                    VARCHAR(255)
      ,record_id                    INT
      ,static_gid                   INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TradingPartners
      (SearchID
      ,i_entity_type
      ,i_Entity_ID
      ,i_entity_type_desc
      ,i_Interchange_ID_Type
      ,i_Interchange_ID
      ,i_Trading_Partners_Status
      ,iCMSFunctionCode
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*EntityType]), '')
      ,ISNULL([*EntityID], '')
      ,ISNULL([*EntityDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InterchangeIDType]), '')
      ,ISNULL([*InterchangeID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Status]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CMSFunctionCode]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TradingPartners
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TradingPartners
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TradingPartners_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_key_1_Trading_partner_gid
       ,i_key_2_entity_type
       ,i_key_3_Entity_gid
       ,i_key_4_Entity_id
       ,i_key_5_Entity_Name
       ,i_key_6_Interchange_type_id
       ,i_key_7_Interchange_id
       ,i_key_8_field
       ,i_key_9_Status
       ,i_key_10_Trading_Partner_sid
       ,iAction
       ,i_date_time_modified
       ,i_user_id
       ,i_entity_type
       ,i_Entity_ID
       ,i_entity_type_desc
       ,i_Interchange_ID_Type
       ,i_Interchange_ID
       ,i_Trading_Partners_Status
       ,iCMSFunctionCode
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TradingPartners

   OPEN TradingPartners_Cursor
  FETCH NEXT FROM TradingPartners_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_key_1_Trading_partner_gid
       ,@i_key_2_entity_type
       ,@i_key_3_Entity_gid
       ,@i_key_4_Entity_id
       ,@i_key_5_Entity_Name
       ,@i_key_6_Interchange_type_id
       ,@i_key_7_Interchange_id
       ,@i_key_8_field
       ,@i_key_9_Status
       ,@i_key_10_Trading_Partner_sid
       ,@iAction
       ,@i_date_time_modified
       ,@i_user_id
       ,@i_entity_type
       ,@i_Entity_ID
       ,@i_entity_type_desc
       ,@i_Interchange_ID_Type
       ,@i_Interchange_ID
       ,@i_Trading_Partners_Status
       ,@iCMSFunctionCode
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prTrading_Partners_AddModify
             @i_entity_name
            ,@i_key_1_Trading_partner_gid
            ,@i_key_2_entity_type
            ,@i_key_3_Entity_gid
            ,@i_key_4_Entity_id
            ,@i_key_5_Entity_Name
            ,@i_key_6_Interchange_type_id
            ,@i_key_7_Interchange_id
            ,@i_key_8_field
            ,@i_key_9_Status
            ,@i_key_10_Trading_Partner_sid
            ,@iAction
            ,@i_date_time_modified
            ,@i_user_id
            ,@i_entity_type
            ,@i_Entity_ID
            ,@i_entity_type_desc
            ,@i_Interchange_ID_Type
            ,@i_Interchange_ID
            ,@i_Trading_Partners_Status
            ,@iCMSFunctionCode
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

				-- Update to the static gid
				UPDATE dbo.Trading_Partner 
				   SET Trading_Partner_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND Entity_id				= @i_Entity_ID
				   AND Entity_Type				= @i_entity_type
				   AND Entity_Name				= @i_entity_type_desc

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Entity_ID, @i_entity_type_desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TradingPartners_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_key_1_Trading_partner_gid
             ,@i_key_2_entity_type
             ,@i_key_3_Entity_gid
             ,@i_key_4_Entity_id
             ,@i_key_5_Entity_Name
             ,@i_key_6_Interchange_type_id
             ,@i_key_7_Interchange_id
             ,@i_key_8_field
             ,@i_key_9_Status
             ,@i_key_10_Trading_Partner_sid
             ,@iAction
             ,@i_date_time_modified
             ,@i_user_id
             ,@i_entity_type
             ,@i_Entity_ID
             ,@i_entity_type_desc
             ,@i_Interchange_ID_Type
             ,@i_Interchange_ID
             ,@i_Trading_Partners_Status
             ,@iCMSFunctionCode
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TradingPartners_Cursor
DEALLOCATE TradingPartners_Cursor

END
GO