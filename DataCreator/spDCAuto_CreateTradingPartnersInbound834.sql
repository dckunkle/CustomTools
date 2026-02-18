IF OBJECT_ID('dbo.spDCAuto_CreateTradingPartnersInbound834') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTradingPartnersInbound834 AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTradingPartnersInbound834
Purpose:    Create tradingpartnersinbound834 data from CorderAutomation
Method:     TradingPartnersInbound834
Screen GID: 9992
Procedure:  dbo.prInbound_X12_834_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTradingPartnersInbound834 '100-Config%', 22, 'TradingPartnersInbound834'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTradingPartnersInbound834
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
       ,@i_Key_Transaction_type        VARCHAR(50)
       ,@i_Key_Direction               VARCHAR(50)
       ,@i_Trxn_SID                    VARCHAR(50)
       ,@i_Screen_Entity               VARCHAR(50)
       ,@i_Key_6                       VARCHAR(50)
       ,@i_key_7_field                 VARCHAR(50)
       ,@i_key_8_field                 VARCHAR(50)
       ,@i_key_9_field                 VARCHAR(50)
       ,@i_key_10_field                VARCHAR(50)
       ,@iAction                       VARCHAR(10)
       ,@i_date_time_modified          VARCHAR(20)
       ,@i_user_id                     VARCHAR(50)
       ,@i_Transaction_Type            VARCHAR(50)
       ,@i_Direction                   VARCHAR(50)
       ,@i_LOB_Pointer                 VARCHAR(50)
       ,@i_Default_Coverage_Code       VARCHAR(50)
       ,@i_Override_Group_ID           VARCHAR(50)
       ,@i_Override_Group_Desc         VARCHAR(50)
       ,@i_Default_Group_ID            VARCHAR(50)
       ,@i_Default_Group_Desc          VARCHAR(50)
       ,@iMemberMatchID                VARCHAR(50)
       ,@iMemberMatchDesc              VARCHAR(50)
       ,@i_Eligibility_Processing_ID   VARCHAR(50)
       ,@i_Eligibility_Processing_Desc VARCHAR(50)
       ,@iFullAction                   VARCHAR(50)
       ,@iTypeOfReports                VARCHAR(50)
       ,@i_Group_Pointer               VARCHAR(50)
       ,@i_Policy_Pointer              VARCHAR(50)
       ,@i_CarrierGroup_Pointer        VARCHAR(50)
       ,@i_Rating_Date_Pointer         VARCHAR(50)
       ,@i_plan_strategy_pointer       VARCHAR(50)
       ,@iProcessEffectuations         VARCHAR(50)
       ,@iTermReasonCode               VARCHAR(50)
       ,@iTermReasonCodeDesc           VARCHAR(50)
       ,@o_status                      INT
       ,@o_message                     VARCHAR(255)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TradingPartnersInbound834') IS NOT NULL
	DROP TABLE #TradingPartnersInbound834

CREATE TABLE #TradingPartnersInbound834
      (SearchID                      VARCHAR(200)
      ,i_entity_name                 VARCHAR(50)       DEFAULT('In_834')
      ,i_Trading_partner_gid         VARCHAR(50)       DEFAULT('0')
      ,i_Key_Transaction_type        VARCHAR(50)       DEFAULT('834')
      ,i_Key_Direction               VARCHAR(50)       DEFAULT('I')
      ,i_Trxn_SID                    VARCHAR(50)       DEFAULT('0')
      ,i_Screen_Entity               VARCHAR(50)       DEFAULT('In_834')
      ,i_Key_6                       VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                 VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                VARCHAR(50)       DEFAULT('0')
      ,iAction                       VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified          VARCHAR(20)       DEFAULT('')
      ,i_user_id                     VARCHAR(50)       DEFAULT('')
      ,i_Transaction_Type            VARCHAR(50)	   DEFAULT('834')
      ,i_Direction                   VARCHAR(50)	   DEFAULT('I')
      ,i_LOB_Pointer                 VARCHAR(50)
      ,i_Default_Coverage_Code       VARCHAR(50)
      ,i_Override_Group_ID           VARCHAR(50)
      ,i_Override_Group_Desc         VARCHAR(50)
      ,i_Default_Group_ID            VARCHAR(50)
      ,i_Default_Group_Desc          VARCHAR(50)
      ,iMemberMatchID                VARCHAR(50)
      ,iMemberMatchDesc              VARCHAR(50)
      ,i_Eligibility_Processing_ID   VARCHAR(50)
      ,i_Eligibility_Processing_Desc VARCHAR(50)
      ,iFullAction                   VARCHAR(50)
      ,iTypeOfReports                VARCHAR(50)
      ,i_Group_Pointer               VARCHAR(50)
      ,i_Policy_Pointer              VARCHAR(50)
      ,i_CarrierGroup_Pointer        VARCHAR(50)
      ,i_Rating_Date_Pointer         VARCHAR(50)
      ,i_plan_strategy_pointer       VARCHAR(50)
      ,iProcessEffectuations         VARCHAR(50)
      ,iTermReasonCode               VARCHAR(50)
      ,iTermReasonCodeDesc           VARCHAR(50)
      ,o_status                      INT
      ,o_message                     VARCHAR(255)
      ,record_id                     INT
      ,static_gid                    INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TradingPartnersInbound834
      (SearchID
      ,i_LOB_Pointer
      ,i_Default_Coverage_Code
      ,i_Override_Group_ID
      ,i_Default_Group_ID
      ,iMemberMatchID
      ,i_Eligibility_Processing_ID
      ,iFullAction
      ,iTypeOfReports
      ,i_Group_Pointer
      ,i_Policy_Pointer
      ,i_CarrierGroup_Pointer
      ,i_Rating_Date_Pointer
      ,i_plan_strategy_pointer
      ,iProcessEffectuations
      ,iTermReasonCode
      ,record_id
      ,static_gid)
SELECT [SrchEntityID]
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOBPointer]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DefaultCovCode]), '')
      ,ISNULL([OverrideGroupID], '')
      ,ISNULL([DefaultGroupID], '')
      ,ISNULL([MemberMatchID], '')
      ,ISNULL([EligProcID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EligLoadActionOnFull]), 'F')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportsGenerated]), 'S')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GroupPointer]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PolicyPointer]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CarrierGroupPointer]), '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RatingDatePointer]), '2')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PlanStrategyPointer]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ProcessEffectuations]), 'Y')
      ,ISNULL([TBATermReasonCode], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TradingPartnersInbound834
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TradingPartnersInbound834
   SET i_user_id  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TradingPartnersInbound834_Cursor CURSOR FOR
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
       ,i_LOB_Pointer
       ,i_Default_Coverage_Code
       ,i_Override_Group_ID
       ,i_Override_Group_Desc
       ,i_Default_Group_ID
       ,i_Default_Group_Desc
       ,iMemberMatchID
       ,iMemberMatchDesc
       ,i_Eligibility_Processing_ID
       ,i_Eligibility_Processing_Desc
       ,iFullAction
       ,iTypeOfReports
       ,i_Group_Pointer
       ,i_Policy_Pointer
       ,i_CarrierGroup_Pointer
       ,i_Rating_Date_Pointer
       ,i_plan_strategy_pointer
       ,iProcessEffectuations
       ,iTermReasonCode
       ,iTermReasonCodeDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #TradingPartnersInbound834

   OPEN TradingPartnersInbound834_Cursor
  FETCH NEXT FROM TradingPartnersInbound834_Cursor
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
       ,@i_LOB_Pointer
       ,@i_Default_Coverage_Code
       ,@i_Override_Group_ID
       ,@i_Override_Group_Desc
       ,@i_Default_Group_ID
       ,@i_Default_Group_Desc
       ,@iMemberMatchID
       ,@iMemberMatchDesc
       ,@i_Eligibility_Processing_ID
       ,@i_Eligibility_Processing_Desc
       ,@iFullAction
       ,@iTypeOfReports
       ,@i_Group_Pointer
       ,@i_Policy_Pointer
       ,@i_CarrierGroup_Pointer
       ,@i_Rating_Date_Pointer
       ,@i_plan_strategy_pointer
       ,@iProcessEffectuations
       ,@iTermReasonCode
       ,@iTermReasonCodeDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the second search criteria only
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the trading partner
			SELECT @i_Trading_partner_gid	= Trading_Partner_gid
			  FROM Trading_Partner
			 WHERE record_status			= 'A'
			   AND Entity_id				= @SearchID

			EXEC dbo.prInbound_X12_834_AddModify
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
            ,@i_LOB_Pointer
            ,@i_Default_Coverage_Code
            ,@i_Override_Group_ID
            ,@i_Override_Group_Desc
            ,@i_Default_Group_ID
            ,@i_Default_Group_Desc
            ,@iMemberMatchID
            ,@iMemberMatchDesc
            ,@i_Eligibility_Processing_ID
            ,@i_Eligibility_Processing_Desc
            ,@iFullAction
            ,@iTypeOfReports
            ,@i_Group_Pointer
            ,@i_Policy_Pointer
            ,@i_CarrierGroup_Pointer
            ,@i_Rating_Date_Pointer
            ,@i_plan_strategy_pointer
            ,@iProcessEffectuations
            ,@iTermReasonCode
            ,@iTermReasonCodeDesc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_LOB_Pointer, @iTermReasonCode, @status, @err_num, @err_msg

        FETCH NEXT FROM TradingPartnersInbound834_Cursor
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
             ,@i_LOB_Pointer
             ,@i_Default_Coverage_Code
             ,@i_Override_Group_ID
             ,@i_Override_Group_Desc
             ,@i_Default_Group_ID
             ,@i_Default_Group_Desc
             ,@iMemberMatchID
             ,@iMemberMatchDesc
             ,@i_Eligibility_Processing_ID
             ,@i_Eligibility_Processing_Desc
             ,@iFullAction
             ,@iTypeOfReports
             ,@i_Group_Pointer
             ,@i_Policy_Pointer
             ,@i_CarrierGroup_Pointer
             ,@i_Rating_Date_Pointer
             ,@i_plan_strategy_pointer
             ,@iProcessEffectuations
             ,@iTermReasonCode
             ,@iTermReasonCodeDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE TradingPartnersInbound834_Cursor
DEALLOCATE TradingPartnersInbound834_Cursor

END
GO