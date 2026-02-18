IF OBJECT_ID('dbo.spDCAuto_CreateAffiliationNetworks') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAffiliationNetworks AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAffiliationNetworks
Purpose:    Create affiliationnetworks data from CorderAutomation
Method:     AffiliationNetworks
Screen GID: 116
Procedure:  dbo.prNet_AttribNetName_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/14/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAffiliationNetworks '100-Config%', 22, 'AffiliationNetworks'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAffiliationNetworks
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

DECLARE @i_entity_name            VARCHAR(50)
       ,@i_Network_gid            VARCHAR(200)
       ,@i_Old_Network_Id         VARCHAR(50)
       ,@i_Old_Network_Name       VARCHAR(50)
       ,@i_key_4_field            VARCHAR(50)
       ,@i_key_5_field            VARCHAR(50)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(50)
       ,@i_key_8_field            VARCHAR(50)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(50)
       ,@i_action                 VARCHAR(10)
       ,@i_date_time_modified     VARCHAR(50)
       ,@iUserID                  VARCHAR(25)
       ,@i_Network_Id             VARCHAR(50)
       ,@i_Network_Name           VARCHAR(50)
       ,@i_Price_Strategy_Id      VARCHAR(50)
       ,@i_Price_Strategy_Desc    VARCHAR(50)
       ,@i_Copay_Strategy_Id      VARCHAR(50)
       ,@i_Copay_Strategy_Desc    VARCHAR(50)
       ,@i_Coverage_Strategy_Id   VARCHAR(50)
       ,@i_Coverage_Strategy_Desc VARCHAR(50)
       ,@iCodePairingID           VARCHAR(50)
       ,@iCodePairingDesc         VARCHAR(50)
       ,@iBenefitStrategyID       VARCHAR(50)
       ,@iBenefitStrategyDesc     VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AffiliationNetworks') IS NOT NULL
	DROP TABLE #AffiliationNetworks

CREATE TABLE #AffiliationNetworks
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(50)       DEFAULT('Attribute_Networks')
      ,i_Network_gid            VARCHAR(200)      DEFAULT('0')
      ,i_Old_Network_Id         VARCHAR(50)       DEFAULT('0')
      ,i_Old_Network_Name       VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(50)       DEFAULT('0')
      ,i_action                 VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(50)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,i_Network_Id             VARCHAR(50)
      ,i_Network_Name           VARCHAR(50)
      ,i_Price_Strategy_Id      VARCHAR(50)
      ,i_Price_Strategy_Desc    VARCHAR(50)
      ,i_Copay_Strategy_Id      VARCHAR(50)
      ,i_Copay_Strategy_Desc    VARCHAR(50)
      ,i_Coverage_Strategy_Id   VARCHAR(50)
      ,i_Coverage_Strategy_Desc VARCHAR(50)
      ,iCodePairingID           VARCHAR(50)
      ,iCodePairingDesc         VARCHAR(50)
      ,iBenefitStrategyID       VARCHAR(50)
      ,iBenefitStrategyDesc     VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(255)
      ,record_id                INT
      ,static_gid               INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AffiliationNetworks
      (SearchID
      ,i_Network_Id
      ,i_Network_Name
      ,i_Price_Strategy_Id
      ,i_Copay_Strategy_Id
      ,i_Coverage_Strategy_Id
      ,iCodePairingID
      ,iBenefitStrategyID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*AffiliationNetID], '')
      ,ISNULL([*AffiliationNetDesc], '')
      ,ISNULL([PriceStrategyID], '')
      ,ISNULL([CopayLevelsID], '')
      ,ISNULL([CodeLimitationsID], '')
      ,ISNULL([CodePairingID], '')
      ,ISNULL([BenefitStrategyID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AffiliationNetworks
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AffiliationNetworks
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AffiliationNetworks_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Network_gid
       ,i_Old_Network_Id
       ,i_Old_Network_Name
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Network_Id
       ,i_Network_Name
       ,i_Price_Strategy_Id
       ,i_Price_Strategy_Desc
       ,i_Copay_Strategy_Id
       ,i_Copay_Strategy_Desc
       ,i_Coverage_Strategy_Id
       ,i_Coverage_Strategy_Desc
       ,iCodePairingID
       ,iCodePairingDesc
       ,iBenefitStrategyID
       ,iBenefitStrategyDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #AffiliationNetworks

   OPEN AffiliationNetworks_Cursor
  FETCH NEXT FROM AffiliationNetworks_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Network_gid
       ,@i_Old_Network_Id
       ,@i_Old_Network_Name
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Network_Id
       ,@i_Network_Name
       ,@i_Price_Strategy_Id
       ,@i_Price_Strategy_Desc
       ,@i_Copay_Strategy_Id
       ,@i_Copay_Strategy_Desc
       ,@i_Coverage_Strategy_Id
       ,@i_Coverage_Strategy_Desc
       ,@iCodePairingID
       ,@iCodePairingDesc
       ,@iBenefitStrategyID
       ,@iBenefitStrategyDesc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prNet_AttribNetName_AddModify
             @i_entity_name
            ,@i_Network_gid
            ,@i_Old_Network_Id
            ,@i_Old_Network_Name
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_Network_Id
            ,@i_Network_Name
            ,@i_Price_Strategy_Id
            ,@i_Price_Strategy_Desc
            ,@i_Copay_Strategy_Id
            ,@i_Copay_Strategy_Desc
            ,@i_Coverage_Strategy_Id
            ,@i_Coverage_Strategy_Desc
            ,@iCodePairingID
            ,@iCodePairingDesc
            ,@iBenefitStrategyID
            ,@iBenefitStrategyDesc
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
				UPDATE dbo.Attribute_Network_Names 
				   SET network_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND network_id				= @i_Network_Id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Network_Id, @i_Network_Name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM AffiliationNetworks_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Network_gid
             ,@i_Old_Network_Id
             ,@i_Old_Network_Name
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Network_Id
             ,@i_Network_Name
             ,@i_Price_Strategy_Id
             ,@i_Price_Strategy_Desc
             ,@i_Copay_Strategy_Id
             ,@i_Copay_Strategy_Desc
             ,@i_Coverage_Strategy_Id
             ,@i_Coverage_Strategy_Desc
             ,@iCodePairingID
             ,@iCodePairingDesc
             ,@iBenefitStrategyID
             ,@iBenefitStrategyDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE AffiliationNetworks_Cursor
DEALLOCATE AffiliationNetworks_Cursor

END
GO