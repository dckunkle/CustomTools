IF OBJECT_ID('dbo.spDCAuto_CreateGroupContracts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupContracts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupContracts
Purpose:    Create groupcontracts data from CorderAutomation
Method:     GroupContracts
Screen GID: 30
Procedure:  dbo.prContractRelationAdd

Date        User            Change
---------------------------------------------------------------------------------------------
12/13/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupContracts '100-Config%', 22, 'GroupContracts'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupContracts
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
       ,@i_group_gid          VARCHAR(50)
       ,@i_entity_type        VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(75)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(20)
       ,@iUserID              VARCHAR(20)
       ,@iGroupID             VARCHAR(50)
       ,@iGroupName           VARCHAR(50)
       ,@i_effective_date     VARCHAR(50)
       ,@i_termination_date   VARCHAR(50)
       ,@i_user_lob           VARCHAR(50)
       ,@iExternalID          VARCHAR(50)
       ,@i_oic_id             VARCHAR(50)
       ,@i_oic_desc           VARCHAR(20)
       ,@i_contract_id        VARCHAR(50)
       ,@i_contract_desc      VARCHAR(180)
       ,@i_regionCode         VARCHAR(50)
       ,@i_regionZipCode      VARCHAR(50)
       ,@i_planYear           VARCHAR(50)
       ,@i_size               VARCHAR(50)
       ,@i_lastRenewalDate    VARCHAR(50)
       ,@i_NextRenewalDate    VARCHAR(50)
       ,@GroupPolicy          VARCHAR(50)
       ,@iContributionID      VARCHAR(50)
       ,@iContributionDesc    VARCHAR(50)
       ,@iCommissionStartDate VARCHAR(50)
       ,@iCommissionAttribute VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupContracts') IS NOT NULL
	DROP TABLE #GroupContracts

CREATE TABLE #GroupContracts
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Contract_Relation')
      ,i_group_gid          VARCHAR(50)       DEFAULT('0')
      ,i_entity_type        VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(75)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(20)       DEFAULT('')
      ,iUserID              VARCHAR(20)       DEFAULT('')
      ,iGroupID             VARCHAR(50)
      ,iGroupName           VARCHAR(50)
      ,i_effective_date     VARCHAR(50)
      ,i_termination_date   VARCHAR(50)
      ,i_user_lob           VARCHAR(50)
      ,iExternalID          VARCHAR(50)
      ,i_oic_id             VARCHAR(50)
      ,i_oic_desc           VARCHAR(20)
      ,i_contract_id        VARCHAR(50)
      ,i_contract_desc      VARCHAR(180)
      ,i_regionCode         VARCHAR(50)
      ,i_regionZipCode      VARCHAR(50)
      ,i_planYear           VARCHAR(50)
      ,i_size               VARCHAR(50)
      ,i_lastRenewalDate    VARCHAR(50)
      ,i_NextRenewalDate    VARCHAR(50)
      ,GroupPolicy          VARCHAR(50)
      ,iContributionID      VARCHAR(50)
      ,iContributionDesc    VARCHAR(50)
      ,iCommissionStartDate VARCHAR(50)
      ,iCommissionAttribute VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(200)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#GroupLOBs') IS NOT NULL
	DROP TABLE #GroupLOBs

CREATE TABLE #GroupLOBs
      (field_number			INT
	  ,reference_type		VARCHAR(200)
	  ,short_description	VARCHAR(200)
	  ,description			VARCHAR(200)
	  ,sequence_num			INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupContracts
      (SearchID
      ,iGroupID
      ,i_effective_date
      ,i_termination_date
      ,i_user_lob
      ,iExternalID
      ,i_oic_id
      ,i_contract_id
      ,i_regionCode
      ,i_regionZipCode
      ,i_planYear
      ,i_size
      ,i_lastRenewalDate
      ,i_NextRenewalDate
      ,GroupPolicy
      ,iContributionID
      ,iCommissionStartDate
      ,iCommissionAttribute
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*GroupID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TermDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOB]), '')
      ,ISNULL([ExternalID], '')
      ,ISNULL([OICID], '')
      ,ISNULL([*ContractID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RegionCode]), '')
      ,ISNULL([RegionZipCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PlanYear]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Size]), '')
      ,ISNULL([LastRenewalDate], '01/01/1900')
      ,ISNULL([NextRenewalDate], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SubmitGroupPolIntoCardProd]), 'N')
      ,ISNULL([ContributionID], '')
      ,ISNULL([CommissionStartDt], '01/01/1900')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CommissionAttribute]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupContractAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupContracts
   SET iUserID  = @user

UPDATE GC
   SET GC.i_group_gid	= G.group_gid
  FROM Groups			G
  JOIN #GroupContracts	GC
    ON G.group_id		= GC.iGroupID
 WHERE G.record_status	= 'A'

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupContracts_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_group_gid
       ,i_entity_type
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
       ,iGroupID
       ,iGroupName
       ,i_effective_date
       ,i_termination_date
       ,i_user_lob
       ,iExternalID
       ,i_oic_id
       ,i_oic_desc
       ,i_contract_id
       ,i_contract_desc
       ,i_regionCode
       ,i_regionZipCode
       ,i_planYear
       ,i_size
       ,i_lastRenewalDate
       ,i_NextRenewalDate
       ,GroupPolicy
       ,iContributionID
       ,iContributionDesc
       ,iCommissionStartDate
       ,iCommissionAttribute
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupContracts

   OPEN GroupContracts_Cursor
  FETCH NEXT FROM GroupContracts_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_group_gid
       ,@i_entity_type
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
       ,@iGroupID
       ,@iGroupName
       ,@i_effective_date
       ,@i_termination_date
       ,@i_user_lob
       ,@iExternalID
       ,@i_oic_id
       ,@i_oic_desc
       ,@i_contract_id
       ,@i_contract_desc
       ,@i_regionCode
       ,@i_regionZipCode
       ,@i_planYear
       ,@i_size
       ,@i_lastRenewalDate
       ,@i_NextRenewalDate
       ,@GroupPolicy
       ,@iContributionID
       ,@iContributionDesc
       ,@iCommissionStartDate
       ,@iCommissionAttribute
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Determine if the user specified an LOB and if not default it to the correct LOB
			TRUNCATE TABLE #GroupLOBs
			INSERT INTO #GroupLOBs
			EXEC prGroupVaryLOBCombo 'Contract_Relation', @i_group_gid, 'G', '', '', '', '0', '0', '0', '0', '', 'ADD', '', '', 'LOBEC', '5', @iGroupID

			SELECT TOP 1
			       @i_user_lob = CASE WHEN @i_user_lob = '' THEN G.short_description ELSE @i_user_lob END
			  FROM #GroupLOBs	G

			EXEC dbo.prContractRelationAdd
             @i_entity_name
            ,@i_group_gid
            ,@i_entity_type
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
            ,@iGroupID
            ,@iGroupName
            ,@i_effective_date
            ,@i_termination_date
            ,@i_user_lob
            ,@iExternalID
            ,@i_oic_id
            ,@i_oic_desc
            ,@i_contract_id
            ,@i_contract_desc
            ,@i_regionCode
            ,@i_regionZipCode
            ,@i_planYear
            ,@i_size
            ,@i_lastRenewalDate
            ,@i_NextRenewalDate
            ,@GroupPolicy
            ,@iContributionID
            ,@iContributionDesc
            ,@iCommissionStartDate
            ,@iCommissionAttribute
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iGroupID, @i_contract_id, '', @status, @err_num, @err_msg

        FETCH NEXT FROM GroupContracts_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_group_gid
             ,@i_entity_type
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
             ,@iGroupID
             ,@iGroupName
             ,@i_effective_date
             ,@i_termination_date
             ,@i_user_lob
             ,@iExternalID
             ,@i_oic_id
             ,@i_oic_desc
             ,@i_contract_id
             ,@i_contract_desc
             ,@i_regionCode
             ,@i_regionZipCode
             ,@i_planYear
             ,@i_size
             ,@i_lastRenewalDate
             ,@i_NextRenewalDate
             ,@GroupPolicy
             ,@iContributionID
             ,@iContributionDesc
             ,@iCommissionStartDate
             ,@iCommissionAttribute
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupContracts_Cursor
DEALLOCATE GroupContracts_Cursor

END
GO