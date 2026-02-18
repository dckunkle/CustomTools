/**************************************************************************************************
Name:       spDCAuto_CreateFeeScheduleDetailsFacility
Purpose:    Create feescheduledetailsfacility data from CorderAutomation

Screen:     9367
Method:     FeeScheduleDetailsFacility
Procedure:  dbo.prFeeScheduleInstDetails_AddModify
Entity:     Fee_Schedule_Inst

Date        User            Change
---------------------------------------------------------------------------------------------
08/10/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateFeeScheduleDetailsFacility 'Kraken-CONFIG-1001%', 22, 'FeeScheduleDetailsFacility', 'FeeScheduleDetailsFacility', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateFeeScheduleDetailsFacility
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
       ,@iParentGid                  VARCHAR(50)
       ,@iDetailGid                  VARCHAR(50)
       ,@i_key_3_field               VARCHAR(50)
       ,@i_key_4_field               VARCHAR(50)
       ,@i_key_5_field               VARCHAR(50)
       ,@i_key_6_field               VARCHAR(50)
       ,@i_key_7_field               VARCHAR(50)
       ,@i_key_8_field               VARCHAR(50)
       ,@i_key_9_field               VARCHAR(50)
       ,@i_key_10_field              VARCHAR(50)
       ,@i_action                    VARCHAR(10)
       ,@i_date_time_modified        VARCHAR(50)
       ,@i_UserID                    VARCHAR(25)
       ,@iEffectiveDate              VARCHAR(50)
       ,@iTerminationDate            VARCHAR(50)
       ,@iFromDay                    VARCHAR(50)
       ,@iToDay                      VARCHAR(50)
       ,@iCodeQualifier              VARCHAR(50)
       ,@iSeverity                   VARCHAR(50)
       ,@iCodeID                     VARCHAR(50)
       ,@iCodeDesc                   VARCHAR(300)
       ,@iTypeofBill                 VARCHAR(50)
       ,@iTypeofBillDesc             VARCHAR(125)
       ,@iTOBListID                  VARCHAR(50)
       ,@iTOBListDesc                VARCHAR(50)
       ,@iAlsoContainsCodeFromListID VARCHAR(50)
       ,@iCodeListDescription        VARCHAR(50)
       ,@iModifierListID             VARCHAR(50)
       ,@iModifierListDesc           VARCHAR(100)
       ,@iModifier1                  VARCHAR(50)
       ,@iModifier2                  VARCHAR(50)
       ,@iModifier3                  VARCHAR(50)
       ,@iModifier4                  VARCHAR(50)
       ,@iModifierLogic              VARCHAR(50)
       ,@iRank                       VARCHAR(50)
       ,@iDiagLogic                  VARCHAR(50)
       ,@iDiagListId                 VARCHAR(50)
       ,@iDiagListDesc               VARCHAR(100)
       ,@iHospContractBasis          VARCHAR(50)
       ,@iCarveOut                   VARCHAR(50)
       ,@iDollarAmount               VARCHAR(50)
       ,@iMarkUp                     VARCHAR(50)
       ,@iTieredStepPricingID        VARCHAR(50)
       ,@iTieredStepPricingDesc      VARCHAR(100)
       ,@iExceptionListID            VARCHAR(50)
       ,@iExceptionListDesc          VARCHAR(50)
       ,@iMatchDateIndicator         VARCHAR(50)
       ,@iDiscDateIncludedinDayTotal VARCHAR(50)
       ,@iAllowGreater               VARCHAR(50)
       ,@iUnitRounding               VARCHAR(50)
       ,@iRemarkCode1                VARCHAR(50)
       ,@iRemarkDesc1                VARCHAR(490)
       ,@iRemarkCode2                VARCHAR(50)
       ,@iRemarkDesc2                VARCHAR(490)
       ,@iAltPricing                 VARCHAR(50)
       ,@iAltDollarAmount            VARCHAR(50)
       ,@iAltMarkUp                  VARCHAR(50)
       ,@o_status                    INT
       ,@o_message                   VARCHAR(110)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#FeeScheduleDetailsFacility') IS NOT NULL
	DROP TABLE #FeeScheduleDetailsFacility

CREATE TABLE #FeeScheduleDetailsFacility
      (SearchID                    VARCHAR(200)
      ,i_entity_name               VARCHAR(50)       DEFAULT('Fee_Schedule_Inst')
      ,iParentGid                  VARCHAR(50)       DEFAULT('0')
      ,iDetailGid                  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field               VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field              VARCHAR(50)       DEFAULT('0')
      ,i_action                    VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified        VARCHAR(50)       DEFAULT('')
      ,i_UserID                    VARCHAR(25)       DEFAULT('')
      ,iEffectiveDate              VARCHAR(50)
      ,iTerminationDate            VARCHAR(50)
      ,iFromDay                    VARCHAR(50)
      ,iToDay                      VARCHAR(50)
      ,iCodeQualifier              VARCHAR(50)
      ,iSeverity                   VARCHAR(50)
      ,iCodeID                     VARCHAR(50)
      ,iCodeDesc                   VARCHAR(300)
      ,iTypeofBill                 VARCHAR(50)
      ,iTypeofBillDesc             VARCHAR(125)
      ,iTOBListID                  VARCHAR(50)
      ,iTOBListDesc                VARCHAR(50)
      ,iAlsoContainsCodeFromListID VARCHAR(50)
      ,iCodeListDescription        VARCHAR(50)
      ,iModifierListID             VARCHAR(50)
      ,iModifierListDesc           VARCHAR(100)
      ,iModifier1                  VARCHAR(50)
      ,iModifier2                  VARCHAR(50)
      ,iModifier3                  VARCHAR(50)
      ,iModifier4                  VARCHAR(50)
      ,iModifierLogic              VARCHAR(50)
      ,iRank                       VARCHAR(50)
      ,iDiagLogic                  VARCHAR(50)
      ,iDiagListId                 VARCHAR(50)
      ,iDiagListDesc               VARCHAR(100)
      ,iHospContractBasis          VARCHAR(50)
      ,iCarveOut                   VARCHAR(50)
      ,iDollarAmount               VARCHAR(50)
      ,iMarkUp                     VARCHAR(50)
      ,iTieredStepPricingID        VARCHAR(50)
      ,iTieredStepPricingDesc      VARCHAR(100)
      ,iExceptionListID            VARCHAR(50)
      ,iExceptionListDesc          VARCHAR(50)
      ,iMatchDateIndicator         VARCHAR(50)	  DEFAULT('SD')
      ,iDiscDateIncludedinDayTotal VARCHAR(50)
      ,iAllowGreater               VARCHAR(50)
      ,iUnitRounding               VARCHAR(50)
      ,iRemarkCode1                VARCHAR(50)
      ,iRemarkDesc1                VARCHAR(490)
      ,iRemarkCode2                VARCHAR(50)
      ,iRemarkDesc2                VARCHAR(490)
      ,iAltPricing                 VARCHAR(50)
      ,iAltDollarAmount            VARCHAR(50)
      ,iAltMarkUp                  VARCHAR(50)
      ,o_status                    INT
      ,o_message                   VARCHAR(110)
      ,record_id                   INT
      ,static_gid                  INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #FeeScheduleDetailsFacility
          (SearchID
          ,iEffectiveDate
          ,iTerminationDate
          ,iFromDay
          ,iToDay
          ,iCodeQualifier
          ,iSeverity
          ,iCodeID
          ,iTypeofBill
          ,iTOBListID
          ,iAlsoContainsCodeFromListID
          ,iModifierListID
          ,iModifier1
          ,iModifier2
          ,iModifier3
          ,iModifier4
          ,iModifierLogic
          ,iRank
          ,iDiagLogic
          ,iDiagListId
          ,iHospContractBasis
          ,iCarveOut
          ,iDollarAmount
          ,iMarkUp
          ,iTieredStepPricingID
          ,iExceptionListID
		  ,iDiscDateIncludedinDayTotal
          ,iAllowGreater
          ,iUnitRounding
          ,iRemarkCode1
          ,iRemarkCode2
		  ,iAltPricing
		  ,iAltDollarAmount
          ,iAltMarkUp
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(),101))
          ,ISNULL([*Common_TerminationDate], '12/31/9999')
          ,ISNULL([*Common_FromUnit], '')
          ,ISNULL([*Common_ToUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CodeQualifier]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_SeverityOfIllness]), '0')
          ,ISNULL([Common_CodeID], '')
          ,ISNULL([Common_TypeOfBill], '')
          ,ISNULL([Common_TOBListID], '')
          ,ISNULL([Common_ClaimAlsoContainsCodeFromListID], '')
          ,ISNULL([Common_ModifierListID], '')
          ,ISNULL([Common_Modifier1], '')
          ,ISNULL([Common_Modifier2], '')
          ,ISNULL([Common_Modifier3], '')
          ,ISNULL([Common_Modifier4], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_ModifierLogic]), '1')
          ,ISNULL([Common_Rank], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DiaValidationLogic]), '')
          ,ISNULL([Common_DiaValidationID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PriCal_HospContractBasis]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriCal_CarveOut]), 'N')
          ,ISNULL([PriCal_DollarAmt], '')
          ,ISNULL([PriCal_MarkUp%], '')
          ,ISNULL([PriCal_TieredStpePricingID], '')
          ,ISNULL([PriCal_ExceptionListID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriCal_DiscDateIncludedInDayTotal]), 'Y')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriCal_AllowGreaterThanBilled]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriCal_ReimbsUnitRounding]), 'N')
          ,ISNULL([PriCal_RemarkCode1], '')
          ,ISNULL([PriCal_RemarkCode2], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PriCal_AltAlgorithm]), '')
          ,ISNULL([PriCal_AltDollarAmount], '')
          ,ISNULL([PriCal_AltMarkUp%], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_FeeScheduleFacilityFeeScheduleDetails
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #FeeScheduleDetailsFacility
       SET i_UserID  = @user


END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE FeeScheduleDetailsFacility_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,iParentGid
       ,iDetailGid
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
       ,iEffectiveDate
       ,iTerminationDate
       ,iFromDay
       ,iToDay
       ,iCodeQualifier
       ,iSeverity
       ,iCodeID
       ,iCodeDesc
       ,iTypeofBill
       ,iTypeofBillDesc
       ,iTOBListID
       ,iTOBListDesc
       ,iAlsoContainsCodeFromListID
       ,iCodeListDescription
       ,iModifierListID
       ,iModifierListDesc
       ,iModifier1
       ,iModifier2
       ,iModifier3
       ,iModifier4
       ,iModifierLogic
       ,iRank
       ,iDiagLogic
       ,iDiagListId
       ,iDiagListDesc
       ,iHospContractBasis
       ,iCarveOut
       ,iDollarAmount
       ,iMarkUp
       ,iTieredStepPricingID
       ,iTieredStepPricingDesc
       ,iExceptionListID
       ,iExceptionListDesc
       ,iMatchDateIndicator
       ,iDiscDateIncludedinDayTotal
       ,iAllowGreater
       ,iUnitRounding
       ,iRemarkCode1
       ,iRemarkDesc1
       ,iRemarkCode2
       ,iRemarkDesc2
       ,iAltPricing
       ,iAltDollarAmount
       ,iAltMarkUp
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #FeeScheduleDetailsFacility

   OPEN FeeScheduleDetailsFacility_Cursor
  FETCH NEXT FROM FeeScheduleDetailsFacility_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@iParentGid
       ,@iDetailGid
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
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iFromDay
       ,@iToDay
       ,@iCodeQualifier
       ,@iSeverity
       ,@iCodeID
       ,@iCodeDesc
       ,@iTypeofBill
       ,@iTypeofBillDesc
       ,@iTOBListID
       ,@iTOBListDesc
       ,@iAlsoContainsCodeFromListID
       ,@iCodeListDescription
       ,@iModifierListID
       ,@iModifierListDesc
       ,@iModifier1
       ,@iModifier2
       ,@iModifier3
       ,@iModifier4
       ,@iModifierLogic
       ,@iRank
       ,@iDiagLogic
       ,@iDiagListId
       ,@iDiagListDesc
       ,@iHospContractBasis
       ,@iCarveOut
       ,@iDollarAmount
       ,@iMarkUp
       ,@iTieredStepPricingID
       ,@iTieredStepPricingDesc
       ,@iExceptionListID
       ,@iExceptionListDesc
       ,@iMatchDateIndicator
       ,@iDiscDateIncludedinDayTotal
       ,@iAllowGreater
       ,@iUnitRounding
       ,@iRemarkCode1
       ,@iRemarkDesc1
       ,@iRemarkCode2
       ,@iRemarkDesc2
       ,@iAltPricing
       ,@iAltDollarAmount
       ,@iAltMarkUp
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			SELECT @err_num = 0
				  ,@err_msg	= ''

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			SELECT @iParentGid			= FS.fee_schedule_gid
              FROM dbo.Fee_Schedule		FS
			 WHERE FS.fee_schedule_id	= @SearchID
			   AND FS.record_status		= 'A'

			EXEC dbo.prFeeScheduleInstDetails_AddModify
                 @i_entity_name
                ,@iParentGid
                ,@iDetailGid
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
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iFromDay
                ,@iToDay
                ,@iCodeQualifier
                ,@iSeverity
                ,@iCodeID
                ,@iCodeDesc
                ,@iTypeofBill
                ,@iTypeofBillDesc
                ,@iTOBListID
                ,@iTOBListDesc
                ,@iAlsoContainsCodeFromListID
                ,@iCodeListDescription
                ,@iModifierListID
                ,@iModifierListDesc
                ,@iModifier1
                ,@iModifier2
                ,@iModifier3
                ,@iModifier4
                ,@iModifierLogic
                ,@iRank
                ,@iDiagLogic
                ,@iDiagListId
                ,@iDiagListDesc
                ,@iHospContractBasis
                ,@iCarveOut
                ,@iDollarAmount
                ,@iMarkUp
                ,@iTieredStepPricingID
                ,@iTieredStepPricingDesc
                ,@iExceptionListID
                ,@iExceptionListDesc
                ,@iMatchDateIndicator
                ,@iDiscDateIncludedinDayTotal
                ,@iAllowGreater
                ,@iUnitRounding
                ,@iRemarkCode1
                ,@iRemarkDesc1
                ,@iRemarkCode2
                ,@iRemarkDesc2
                ,@iAltPricing
                ,@iAltDollarAmount
                ,@iAltMarkUp
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iEffectiveDate, @iFromDay, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM FeeScheduleDetailsFacility_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@iParentGid
             ,@iDetailGid
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
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iFromDay
             ,@iToDay
             ,@iCodeQualifier
             ,@iSeverity
             ,@iCodeID
             ,@iCodeDesc
             ,@iTypeofBill
             ,@iTypeofBillDesc
             ,@iTOBListID
             ,@iTOBListDesc
             ,@iAlsoContainsCodeFromListID
             ,@iCodeListDescription
             ,@iModifierListID
             ,@iModifierListDesc
             ,@iModifier1
             ,@iModifier2
             ,@iModifier3
             ,@iModifier4
             ,@iModifierLogic
             ,@iRank
             ,@iDiagLogic
             ,@iDiagListId
             ,@iDiagListDesc
             ,@iHospContractBasis
             ,@iCarveOut
             ,@iDollarAmount
             ,@iMarkUp
             ,@iTieredStepPricingID
             ,@iTieredStepPricingDesc
             ,@iExceptionListID
             ,@iExceptionListDesc
             ,@iMatchDateIndicator
             ,@iDiscDateIncludedinDayTotal
             ,@iAllowGreater
             ,@iUnitRounding
             ,@iRemarkCode1
             ,@iRemarkDesc1
             ,@iRemarkCode2
             ,@iRemarkDesc2
             ,@iAltPricing
             ,@iAltDollarAmount
             ,@iAltMarkUp
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE FeeScheduleDetailsFacility_Cursor
DEALLOCATE FeeScheduleDetailsFacility_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#FeeScheduleDetailsFacility') IS NOT NULL
	DROP TABLE #FeeScheduleDetailsFacility

END
GO

