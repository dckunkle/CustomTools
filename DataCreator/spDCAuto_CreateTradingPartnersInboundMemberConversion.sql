IF OBJECT_ID('dbo.spDCAuto_CreateTradingPartnersInboundMemberConversion') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTradingPartnersInboundMemberConversion AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTradingPartnersInboundMemberConversion
Purpose:    Create tradingpartnersinboundmemberconversion data from CorderAutomation
Method:     TradingPartnersInboundMemberConversion
Screen GID: 6001
Procedure:  dbo.prInbound_Member_Conversion_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTradingPartnersInboundMemberConversion '100-Config%', 22, 'TradingPartnersInboundMemberConversion'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTradingPartnersInboundMemberConversion
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

DECLARE @i_entity_name                 VARCHAR(50)
       ,@i_Trading_partner_gid         VARCHAR(50)
       ,@i_Key_Transaction_type        VARCHAR(100)
       ,@i_Key_Direction               VARCHAR(50)
       ,@i_Trxn_SID                    VARCHAR(100)
       ,@i_Screen_Entity               VARCHAR(50)
       ,@i_Key_6                       VARCHAR(100)
       ,@i_key_7_field                 VARCHAR(50)
       ,@i_key_8_field                 VARCHAR(100)
       ,@i_key_9_field                 VARCHAR(50)
       ,@i_key_10_field                VARCHAR(100)
       ,@iAction                       VARCHAR(10)
       ,@i_date_time_modified          VARCHAR(100)
       ,@i_user_id                     VARCHAR(20)
       ,@i_Transaction_Type            VARCHAR(50)
       ,@i_Direction                   VARCHAR(50)
       ,@i_Default_Coverage_Code       VARCHAR(50)
       ,@i_Override_Group_ID           VARCHAR(50)
       ,@i_Override_Group_Desc         VARCHAR(50)
       ,@i_Default_Group_ID            VARCHAR(50)
       ,@i_Default_Group_Desc          VARCHAR(50)
       ,@iMemberMatchID                VARCHAR(50)
       ,@iMemberMatchDesc              VARCHAR(50)
       ,@i_Eligibility_Processing_ID   VARCHAR(50)
       ,@i_Eligibility_Processing_Desc VARCHAR(50)
       ,@i_Rating_Date_Pointer         VARCHAR(50)
       ,@o_status                      INT
       ,@o_message                     VARCHAR(255)
       ,@i_use_transaction             INT

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TradingPartnersInboundMemberConversion') IS NOT NULL
	DROP TABLE #TradingPartnersInboundMemberConversion

CREATE TABLE #TradingPartnersInboundMemberConversion
      (SearchID                      VARCHAR(200)
      ,i_entity_name                 VARCHAR(50)       DEFAULT('Member_Conv_In')
      ,i_Trading_partner_gid         VARCHAR(50)       DEFAULT('0')
      ,i_Key_Transaction_type        VARCHAR(100)      DEFAULT('MC')
      ,i_Key_Direction               VARCHAR(50)       DEFAULT('I')
      ,i_Trxn_SID                    VARCHAR(100)      DEFAULT('0')
      ,i_Screen_Entity               VARCHAR(50)       DEFAULT('Member_Conv_In')
      ,i_Key_6                       VARCHAR(100)      DEFAULT('0')
      ,i_key_7_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                 VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                VARCHAR(100)      DEFAULT('0')
      ,iAction                       VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified          VARCHAR(100)      DEFAULT('')
      ,i_user_id                     VARCHAR(20)       DEFAULT('')
      ,i_Transaction_Type            VARCHAR(50)	   DEFAULT('MC')
      ,i_Direction                   VARCHAR(50)       DEFAULT('I')
      ,i_Default_Coverage_Code       VARCHAR(50)
      ,i_Override_Group_ID           VARCHAR(50)
      ,i_Override_Group_Desc         VARCHAR(50)
      ,i_Default_Group_ID            VARCHAR(50)
      ,i_Default_Group_Desc          VARCHAR(50)
      ,iMemberMatchID                VARCHAR(50)
      ,iMemberMatchDesc              VARCHAR(50)
      ,i_Eligibility_Processing_ID   VARCHAR(50)
      ,i_Eligibility_Processing_Desc VARCHAR(50)
      ,i_Rating_Date_Pointer         VARCHAR(50)
      ,o_status                      INT
      ,o_message                     VARCHAR(255)
      ,i_use_transaction             INT
      ,record_id                     INT
      ,static_gid                    INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TradingPartnersInboundMemberConversion
      (SearchID
      ,i_Default_Coverage_Code
      ,i_Override_Group_ID
      ,i_Default_Group_ID
      ,iMemberMatchID
      ,i_Eligibility_Processing_ID
      ,i_Rating_Date_Pointer
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DefaultCoverageCode]), '')
      ,ISNULL([OverrideGroupID], '')
      ,ISNULL([DefaultGroupID], '')
      ,ISNULL([MemberMatchID], '')
      ,ISNULL([EligibilityProcessingID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RatingDatePointer]), 'B')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TradingPartnersInboundMemberConversion
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TradingPartnersInboundMemberConversion
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TradingPartnersInboundMemberConversion_Cursor CURSOR FOR
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
       ,i_Default_Coverage_Code
       ,i_Override_Group_ID
       ,i_Override_Group_Desc
       ,i_Default_Group_ID
       ,i_Default_Group_Desc
       ,iMemberMatchID
       ,iMemberMatchDesc
       ,i_Eligibility_Processing_ID
       ,i_Eligibility_Processing_Desc
       ,i_Rating_Date_Pointer
       ,o_status
       ,o_message
       ,i_use_transaction
       ,record_id
       ,static_gid
   FROM #TradingPartnersInboundMemberConversion

   OPEN TradingPartnersInboundMemberConversion_Cursor
  FETCH NEXT FROM TradingPartnersInboundMemberConversion_Cursor
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
       ,@i_Default_Coverage_Code
       ,@i_Override_Group_ID
       ,@i_Override_Group_Desc
       ,@i_Default_Group_ID
       ,@i_Default_Group_Desc
       ,@iMemberMatchID
       ,@iMemberMatchDesc
       ,@i_Eligibility_Processing_ID
       ,@i_Eligibility_Processing_Desc
       ,@i_Rating_Date_Pointer
       ,@o_status
       ,@o_message
       ,@i_use_transaction
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the second search criteria only
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 2

			--Get the gid for the trading partner
			SELECT @i_Trading_partner_gid	= Trading_Partner_gid
			  FROM Trading_Partner
			 WHERE record_status			= 'A'
			   AND Entity_id				= @SearchID

			EXEC dbo.prInbound_Member_Conversion_AddModify
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
            ,@i_Default_Coverage_Code
            ,@i_Override_Group_ID
            ,@i_Override_Group_Desc
            ,@i_Default_Group_ID
            ,@i_Default_Group_Desc
            ,@iMemberMatchID
            ,@iMemberMatchDesc
            ,@i_Eligibility_Processing_ID
            ,@i_Eligibility_Processing_Desc
            ,@i_Rating_Date_Pointer
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Default_Coverage_Code, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TradingPartnersInboundMemberConversion_Cursor
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
             ,@i_Default_Coverage_Code
             ,@i_Override_Group_ID
             ,@i_Override_Group_Desc
             ,@i_Default_Group_ID
             ,@i_Default_Group_Desc
             ,@iMemberMatchID
             ,@iMemberMatchDesc
             ,@i_Eligibility_Processing_ID
             ,@i_Eligibility_Processing_Desc
             ,@i_Rating_Date_Pointer
             ,@o_status
             ,@o_message
             ,@i_use_transaction
             ,@record_id
             ,@static_gid
	END

CLOSE TradingPartnersInboundMemberConversion_Cursor
DEALLOCATE TradingPartnersInboundMemberConversion_Cursor

END
GO