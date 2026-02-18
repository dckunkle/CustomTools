IF OBJECT_ID('dbo.spDCAuto_CreateCommissions') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCommissions AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCommissions
Purpose:    Create commissions data from CorderAutomation
Method:     Commissions
Screen GID: 250
Procedure:  dbo.prCommissionAdd_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
11/22/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCommissions '100-Config%', 22, 'Commissions'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCommissions
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

DECLARE @i_entity_name        VARCHAR(30)
       ,@i_commission_gid     VARCHAR(100)
       ,@i_old_lob            VARCHAR(100)
       ,@i_key_3_field        VARCHAR(30)
       ,@i_key_4_field        VARCHAR(30)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(30)
       ,@i_key_7_field        VARCHAR(30)
       ,@i_key_8_field        VARCHAR(100)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_commission_id      VARCHAR(50)
       ,@i_commission_desc    VARCHAR(100)
       ,@i_calc_base          VARCHAR(50)
       ,@i_calc_type          VARCHAR(50)
       ,@i_lob_grouper_id     VARCHAR(50)
       ,@i_lob_grouper_desc   VARCHAR(100)
       ,@i_system_lob         VARCHAR(50)
       ,@i_commission         VARCHAR(50)
       ,@i_tier_id            VARCHAR(55)
       ,@i_tier_desc          VARCHAR(55)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Commissions') IS NOT NULL
	DROP TABLE #Commissions

CREATE TABLE #Commissions
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(30)       DEFAULT('Commissions')
      ,i_commission_gid     VARCHAR(100)      DEFAULT('0')
      ,i_old_lob            VARCHAR(100)      DEFAULT('0')
      ,i_key_3_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(30)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_commission_id      VARCHAR(50)
      ,i_commission_desc    VARCHAR(100)
      ,i_calc_base          VARCHAR(50)
      ,i_calc_type          VARCHAR(50)
      ,i_lob_grouper_id     VARCHAR(50)
      ,i_lob_grouper_desc   VARCHAR(100)
      ,i_system_lob         VARCHAR(50)
      ,i_commission         VARCHAR(50)
      ,i_tier_id            VARCHAR(55)
      ,i_tier_desc          VARCHAR(55)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Commissions
      (SearchID
      ,i_commission_id
      ,i_commission_desc
      ,i_calc_base
      ,i_calc_type
      ,i_lob_grouper_id
      ,i_system_lob
      ,i_commission
      ,i_tier_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*CommissionID], '')
      ,ISNULL([*CommissionDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CalcBaseType]), 'PRMUM')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CalcType]), 'P')
      ,ISNULL([LobGrouperID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB]), '*')
      ,ISNULL([CommissionValue], '0.00')
      ,ISNULL([TierRateID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Commissions
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Commissions
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Commissions_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_commission_gid
       ,i_old_lob
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
       ,iUserID
       ,i_commission_id
       ,i_commission_desc
       ,i_calc_base
       ,i_calc_type
       ,i_lob_grouper_id
       ,i_lob_grouper_desc
       ,i_system_lob
       ,i_commission
       ,i_tier_id
       ,i_tier_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Commissions

   OPEN Commissions_Cursor
  FETCH NEXT FROM Commissions_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_commission_gid
       ,@i_old_lob
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
       ,@iUserID
       ,@i_commission_id
       ,@i_commission_desc
       ,@i_calc_base
       ,@i_calc_type
       ,@i_lob_grouper_id
       ,@i_lob_grouper_desc
       ,@i_system_lob
       ,@i_commission
       ,@i_tier_id
       ,@i_tier_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prCommissionAdd_Modify
             @i_entity_name
            ,@i_commission_gid
            ,@i_old_lob
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
            ,@iUserID
            ,@i_commission_id
            ,@i_commission_desc
            ,@i_calc_base
            ,@i_calc_type
            ,@i_lob_grouper_id
            ,@i_lob_grouper_desc
            ,@i_system_lob
            ,@i_commission
            ,@i_tier_id
            ,@i_tier_desc
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
				UPDATE dbo.Commission_Definition 
				   SET Commission_GID			= @static_gid 
				 WHERE record_status			= 'A'
				   AND Commission_ID			= @i_commission_id

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_commission_id, @i_commission_desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM Commissions_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_commission_gid
             ,@i_old_lob
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
             ,@iUserID
             ,@i_commission_id
             ,@i_commission_desc
             ,@i_calc_base
             ,@i_calc_type
             ,@i_lob_grouper_id
             ,@i_lob_grouper_desc
             ,@i_system_lob
             ,@i_commission
             ,@i_tier_id
             ,@i_tier_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Commissions_Cursor
DEALLOCATE Commissions_Cursor

END
GO