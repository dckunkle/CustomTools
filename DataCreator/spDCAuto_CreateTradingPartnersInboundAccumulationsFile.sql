IF OBJECT_ID('dbo.spDCAuto_CreateTradingPartnersInboundAccumulationsFile') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTradingPartnersInboundAccumulationsFile AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTradingPartnersInboundAccumulationsFile
Purpose:    Create tradingpartnersinboundaccumulationsfile data from CorderAutomation
Method:     TradingPartnersInboundAccumulationsFile
Screen GID: 9998
Procedure:  dbo.prInbound_Accumulation_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
12/27/2019	DK				Original procedure
06/18/2020	DK				SP41 - Add Dupe Records Field
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTradingPartnersInboundAccumulationsFile '100-Config%', 22, 'TradingPartnersInboundAccumulationsFile'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTradingPartnersInboundAccumulationsFile
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

DECLARE @i_entity_name          VARCHAR(100)
       ,@i_Trading_partner_gid  VARCHAR(100)
       ,@i_Key_Transaction_type VARCHAR(50)
       ,@i_Key_Direction        VARCHAR(50)
       ,@i_Trxn_SID             VARCHAR(50)
       ,@i_Screen_Entity        VARCHAR(50)
       ,@i_Key_6                VARCHAR(100)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@iAction                VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(20)
       ,@i_user_id              VARCHAR(20)
       ,@i_Transaction_Type     VARCHAR(50)
       ,@i_Direction            VARCHAR(50)
       ,@i_Member_Match_ID      VARCHAR(50)
       ,@i_Member_Match_Desc    VARCHAR(100)
       ,@i_LOB_Grouper_ID       VARCHAR(50)
       ,@i_LOB_Grouper_Desc     VARCHAR(100)
       ,@i_Benefit_Class        VARCHAR(50)
	   ,@i_AllowDups            VARCHAR(20)       
	   ,@o_status               INT
       ,@o_message              VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TradingPartnersInboundAccumulationsFile') IS NOT NULL
	DROP TABLE #TradingPartnersInboundAccumulationsFile

CREATE TABLE #TradingPartnersInboundAccumulationsFile
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(100)      DEFAULT('In_Accumulation')
      ,i_Trading_partner_gid  VARCHAR(100)      DEFAULT('0')
      ,i_Key_Transaction_type VARCHAR(50)       DEFAULT('ACC')
      ,i_Key_Direction        VARCHAR(50)       DEFAULT('I')
      ,i_Trxn_SID             VARCHAR(50)       DEFAULT('0')
      ,i_Screen_Entity        VARCHAR(50)       DEFAULT('In_Accumulation')
      ,i_Key_6                VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,iAction                VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(20)       DEFAULT('')
      ,i_user_id              VARCHAR(20)       DEFAULT('')
      ,i_Transaction_Type     VARCHAR(50)		DEFAULT('ACC')
      ,i_Direction            VARCHAR(50)		DEFAULT('I')
      ,i_Member_Match_ID      VARCHAR(50)
      ,i_Member_Match_Desc    VARCHAR(100)
      ,i_LOB_Grouper_ID       VARCHAR(50)
      ,i_LOB_Grouper_Desc     VARCHAR(100)
      ,i_Benefit_Class        VARCHAR(50)
	  ,i_AllowDups			  VARCHAR(20)
      ,o_status               INT
      ,o_message              VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TradingPartnersInboundAccumulationsFile
      (SearchID
      ,i_Member_Match_ID
      ,i_LOB_Grouper_ID
      ,i_Benefit_Class
	  ,i_AllowDups
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*MemberMatchID], '')
      ,ISNULL([LOBGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*DefaultBenefitClass]), '0')
	  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AllowDupRecordsInImportDoc]), '0')
      ,ISNULL([RecordID], '')
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_TradingPartnersInboundAccumulation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TradingPartnersInboundAccumulationsFile
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TradingPartnersInboundAccumulationsFile_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Trading_partner_gid
       ,i_Key_Transaction_type
       ,i_Key_Direction
       ,i_Trxn_SID
       ,i_Screen_Entity
       ,i_Key_6
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,i_date_time_modified
       ,i_user_id
       ,i_Transaction_Type
       ,i_Direction
       ,i_Member_Match_ID
       ,i_Member_Match_Desc
       ,i_LOB_Grouper_ID
       ,i_LOB_Grouper_Desc
       ,i_Benefit_Class
	   ,i_AllowDups
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TradingPartnersInboundAccumulationsFile

   OPEN TradingPartnersInboundAccumulationsFile_Cursor
  FETCH NEXT FROM TradingPartnersInboundAccumulationsFile_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Trading_partner_gid
       ,@i_Key_Transaction_type
       ,@i_Key_Direction
       ,@i_Trxn_SID
       ,@i_Screen_Entity
       ,@i_Key_6
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@i_date_time_modified
       ,@i_user_id
       ,@i_Transaction_Type
       ,@i_Direction
       ,@i_Member_Match_ID
       ,@i_Member_Match_Desc
       ,@i_LOB_Grouper_ID
       ,@i_LOB_Grouper_Desc
       ,@i_Benefit_Class
	   ,@i_AllowDups
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
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 2

			--Get the gid for the Auth Match
			SELECT @i_Trading_partner_gid	= TP.Trading_Partner_gid
			  FROM Trading_Partner			TP
			 WHERE TP.record_status			= 'A'
			   AND TP.Entity_id				= @SearchID
			
			EXEC dbo.prInbound_Accumulation_AddModify
             @i_entity_name
            ,@i_Trading_partner_gid
            ,@i_Key_Transaction_type
            ,@i_Key_Direction
            ,@i_Trxn_SID
            ,@i_Screen_Entity
            ,@i_Key_6
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@iAction
            ,@i_date_time_modified
            ,@i_user_id
            ,@i_Transaction_Type
            ,@i_Direction
            ,@i_Member_Match_ID
            ,@i_Member_Match_Desc
            ,@i_LOB_Grouper_ID
            ,@i_LOB_Grouper_Desc
            ,@i_Benefit_Class
			,@i_AllowDups
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Member_Match_ID, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TradingPartnersInboundAccumulationsFile_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Trading_partner_gid
             ,@i_Key_Transaction_type
             ,@i_Key_Direction
             ,@i_Trxn_SID
             ,@i_Screen_Entity
             ,@i_Key_6
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@i_date_time_modified
             ,@i_user_id
             ,@i_Transaction_Type
             ,@i_Direction
             ,@i_Member_Match_ID
             ,@i_Member_Match_Desc
             ,@i_LOB_Grouper_ID
             ,@i_LOB_Grouper_Desc
             ,@i_Benefit_Class
			 ,@i_AllowDups
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TradingPartnersInboundAccumulationsFile_Cursor
DEALLOCATE TradingPartnersInboundAccumulationsFile_Cursor

END
GO