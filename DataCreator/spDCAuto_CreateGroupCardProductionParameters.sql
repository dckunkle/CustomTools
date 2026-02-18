IF OBJECT_ID('dbo.spDCAuto_CreateGroupCardProductionParameters') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupCardProductionParameters AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupCardProductionParameters
Purpose:    Create groupcardproductionparameters data from CorderAutomation
Method:     GroupCardProductionParameters
Screen GID: 132
Procedure:  dbo.prCardProdGroupLOBAdd

Date        User            Change
---------------------------------------------------------------------------------------------
12/12/2019	DK				Original procedure
01/28/2021	DK				Change System_LOB default from ALL to *, * needs to be saved in 
                            the table for this to work. Currently saving 'A' as system_lob
04/07/2021	DK				Add support for Filter Plan List ID (SP45)
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupCardProductionParameters '100-Config%', 22, 'GroupCardProductionParameters'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupCardProductionParameters
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

DECLARE @i_entity_name               VARCHAR(50)
       ,@i_entity_type               VARCHAR(50)
       ,@i_card_parm_gid             VARCHAR(10)
       ,@i_group_gid                 VARCHAR(10)
       ,@i_orig_system_lob           VARCHAR(10)
       ,@i_orig_custom_lob           VARCHAR(20)
       ,@i_orig_card_parm_id         VARCHAR(50)
       ,@i_orig_card_parm_desc       VARCHAR(50)
       ,@i_orig_effective_date       VARCHAR(50)
       ,@i_orig_termination_date     VARCHAR(5)
       ,@i_card_parm_sid             VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_dummy                     VARCHAR(10)
       ,@i_user_id                   VARCHAR(25)
       ,@i_group_id                  VARCHAR(50)
       ,@i_group_name                VARCHAR(180)
       ,@i_effective_date            VARCHAR(50)
       ,@i_termination_date          VARCHAR(50)
       ,@i_system_lob                VARCHAR(50)
       ,@i_custom_lob                VARCHAR(50)
       ,@i_card_parm_id              VARCHAR(50)
       ,@i_card_parm_desc            VARCHAR(100)
       ,@i_initial_card_invoice_paid VARCHAR(50)
       ,@i_initial_card_hold_days    INT
	   ,@i_plan_list_id              VARCHAR(25)	--SP45     
	   ,@i_plan_list_desc			 VARCHAR(150)	--SP45
       ,@o_status                    INT
       ,@o_message                   VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupCardProductionParameters') IS NOT NULL
	DROP TABLE #GroupCardProductionParameters

CREATE TABLE #GroupCardProductionParameters
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Card_Production_Assignment')
      ,i_entity_type               VARCHAR(50)       DEFAULT('GROUP')
      ,i_card_parm_gid             VARCHAR(10)       DEFAULT('0')
      ,i_group_gid                 VARCHAR(10)       DEFAULT('0')
      ,i_orig_system_lob           VARCHAR(10)       DEFAULT('0')
      ,i_orig_custom_lob           VARCHAR(20)       DEFAULT('0')
      ,i_orig_card_parm_id         VARCHAR(50)       DEFAULT('0')
      ,i_orig_card_parm_desc       VARCHAR(50)       DEFAULT('0')
      ,i_orig_effective_date       VARCHAR(50)       DEFAULT('0')
      ,i_orig_termination_date     VARCHAR(5)        DEFAULT('0')
      ,i_card_parm_sid             VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_dummy                     VARCHAR(10)       DEFAULT('')
      ,i_user_id                   VARCHAR(25)       DEFAULT('')
      ,i_group_id                  VARCHAR(50)
      ,i_group_name                VARCHAR(180)
      ,i_effective_date            VARCHAR(50)
      ,i_termination_date          VARCHAR(50)
      ,i_system_lob                VARCHAR(50)
      ,i_custom_lob                VARCHAR(50)
      ,i_card_parm_id              VARCHAR(50)
      ,i_card_parm_desc            VARCHAR(100)
      ,i_initial_card_invoice_paid VARCHAR(50)
      ,i_initial_card_hold_days    INT
	  ,i_plan_list_id			   VARCHAR(25)
      ,o_status                    INT
      ,o_message                   VARCHAR(255)
      ,record_id                   INT
      ,static_gid                  INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupCardProductionParameters
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_system_lob
      ,i_custom_lob
      ,i_card_parm_id
      ,i_initial_card_invoice_paid
      ,i_initial_card_hold_days
	  ,i_plan_list_id
      ,record_id
      ,static_gid)
SELECT ISNULL([*GroupID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '******')
      ,ISNULL([*CardprodParmID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InitialCardInvoicePaid]), 'N')
      ,ISNULL([InitialCardHoldDays], '0')
	  ,ISNULL([FilterPlanListID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupCardParameterAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupCardProductionParameters
   SET i_user_id  = @user

UPDATE GC
   SET i_group_gid						= G.group_gid
   	  ,i_group_id						= G.group_id
	  ,i_group_name						= G.group_name
	  ,i_system_lob						= CASE WHEN i_system_lob = 'ALL' THEN '*'
	                                           ELSE i_system_lob
										   END
  FROM Groups							G
  JOIN #GroupCardProductionParameters	GC
    ON G.group_id						= GC.SearchID
 WHERE G.record_status					= 'A'

UPDATE GC
   SET i_card_parm_desc					= EN.entity_user_name
  FROM Entity_Names						EN
  JOIN Card_Production_Parms			CPP
    ON EN.entity_gid					= CPP.card_parm_gid
  JOIN #GroupCardProductionParameters	GC
    ON EN.entity_user_id				= GC.i_card_parm_id
 WHERE EN.entity_identifier				= 'Card_Production_Parms'
   AND CPP.record_status				= 'A'
   AND EN.record_status					= 'A'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupCardProductionParameters_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_entity_type
       ,i_card_parm_gid
       ,i_group_gid
       ,i_orig_system_lob
       ,i_orig_custom_lob
       ,i_orig_card_parm_id
       ,i_orig_card_parm_desc
       ,i_orig_effective_date
       ,i_orig_termination_date
       ,i_card_parm_sid
       ,i_action
       ,i_dummy
       ,i_user_id
       ,i_group_id
       ,i_group_name
       ,i_effective_date
       ,i_termination_date
       ,i_system_lob
       ,i_custom_lob
       ,i_card_parm_id
       ,i_card_parm_desc
       ,i_initial_card_invoice_paid
       ,i_initial_card_hold_days
	   ,i_plan_list_id
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupCardProductionParameters

   OPEN GroupCardProductionParameters_Cursor
  FETCH NEXT FROM GroupCardProductionParameters_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_entity_type
       ,@i_card_parm_gid
       ,@i_group_gid
       ,@i_orig_system_lob
       ,@i_orig_custom_lob
       ,@i_orig_card_parm_id
       ,@i_orig_card_parm_desc
       ,@i_orig_effective_date
       ,@i_orig_termination_date
       ,@i_card_parm_sid
       ,@i_action
       ,@i_dummy
       ,@i_user_id
       ,@i_group_id
       ,@i_group_name
       ,@i_effective_date
       ,@i_termination_date
       ,@i_system_lob
       ,@i_custom_lob
       ,@i_card_parm_id
       ,@i_card_parm_desc
       ,@i_initial_card_invoice_paid
       ,@i_initial_card_hold_days
	   ,@i_plan_list_id
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prCardProdGroupLOBAdd
             @i_entity_name
            ,@i_entity_type
            ,@i_card_parm_gid
            ,@i_group_gid
            ,@i_orig_system_lob
            ,@i_orig_custom_lob
            ,@i_orig_card_parm_id
            ,@i_orig_card_parm_desc
            ,@i_orig_effective_date
            ,@i_orig_termination_date
            ,@i_card_parm_sid
            ,@i_action
            ,@i_dummy
            ,@i_user_id
            ,@i_group_id
            ,@i_group_name
            ,@i_effective_date
            ,@i_termination_date
            ,@i_system_lob
            ,@i_custom_lob
            ,@i_card_parm_id
            ,@i_card_parm_desc
            ,@i_initial_card_invoice_paid
            ,@i_initial_card_hold_days
			,@i_plan_list_id
			,@i_plan_list_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_card_parm_id, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupCardProductionParameters_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_entity_type
             ,@i_card_parm_gid
             ,@i_group_gid
             ,@i_orig_system_lob
             ,@i_orig_custom_lob
             ,@i_orig_card_parm_id
             ,@i_orig_card_parm_desc
             ,@i_orig_effective_date
             ,@i_orig_termination_date
             ,@i_card_parm_sid
             ,@i_action
             ,@i_dummy
             ,@i_user_id
             ,@i_group_id
             ,@i_group_name
             ,@i_effective_date
             ,@i_termination_date
             ,@i_system_lob
             ,@i_custom_lob
             ,@i_card_parm_id
             ,@i_card_parm_desc
             ,@i_initial_card_invoice_paid
             ,@i_initial_card_hold_days
			 ,@i_plan_list_id
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupCardProductionParameters_Cursor
DEALLOCATE GroupCardProductionParameters_Cursor

END
GO