IF OBJECT_ID('dbo.spDCAuto_ModifyGlobalParams') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_ModifyGlobalParams AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_ModifyGlobalParams
Purpose:    Create codelistscodes data from CorderAutomation
Method:     CodeListsCodes
Screen GID: 3104
Procedure:  dbo.prProdListAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
12/16/2019  DK				Add ACH Enabled on Import/Export tab
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_ModifyGlobalParams '100-Config%', 22, 'CodeListsCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_ModifyGlobalParams
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE	 @pattern					VARCHAR(200)
		,@log_id					INT
		,@test_case_name			VARCHAR(200)
		,@method					VARCHAR(200)
		,@user						VARCHAR(200)

		,@record_id					INT
		,@gid						INT
		,@err_msg					VARCHAR(4000)	= ''
		,@err_num					INT				= 0
		,@status					VARCHAR(25)

		,@current_gid				INT
		,@static_gid				INT

		,@l_screen_gid				INT					= 169
		,@l_entity_name				VARCHAR(200)		= 'Global_Values'
		,@l_td_table_name			VARCHAR(200)		= 'TD_Global_Values'	
	   
		,@sql						VARCHAR(8000)
		,@crlf						VARCHAR(20)			= CHAR(13) + CHAR(10)
		,@stored_procedure_name		VARCHAR(200)
		,@error_message				VARCHAR(4000)
		,@num_screen_fields			INT
		,@max_screen_fields			INT
		,@field_counter				INT
		,@key_1						VARCHAR(200)
		,@key_2						VARCHAR(200)
		,@key_3						VARCHAR(200)
		,@field_name				VARCHAR(200)		

 SELECT  @pattern					= @i_pattern
 	    ,@log_id					= @i_log_id
 	    ,@method					= @i_method
		,@test_case_name			= @i_test_case_name
	    ,@user						= @i_user

--*************************************************************************************************
-- Create the table that will be used to store the TD Table data
--*************************************************************************************************
IF Object_ID('tempdb.dbo.#ScreenDetails') IS NOT NULL
	DROP TABLE #ScreenDetails

CREATE TABLE #ScreenDetails
      (FieldOrder		INT
	  ,Label			VARCHAR(200)
	  ,ComboType		VARCHAR(20)
	  ,DataType			VARCHAR(20)
	  ,DefaultValue		VARCHAR(200)
	  ,isRequired		INT
	  ,isLocked			INT)

INSERT INTO #ScreenDetails
      (FieldOrder
	  ,Label
	  ,ComboType
	  ,DataType
	  ,DefaultValue
	  ,isRequired
	  ,isLocked)
SELECT FieldOrder
      ,Label
	  ,ComboType	
	  ,DataType
	  ,DefaultValue
	  ,isRequired
	  ,isLocked
  FROM ScreenDetails
 WHERE ScreenGid		= @l_screen_gid

SELECT @num_screen_fields	= COUNT(*)
  FROM ScreenDetails
 WHERE ScreenGid = @l_screen_gid

SELECT @max_screen_fields = MAX(FieldOrder) 
  FROM ScreenDetails 
 WHERE ScreenGid = @l_screen_gid

IF Object_ID('tempdb.dbo.#Global_Populate') IS NOT NULL
	DROP TABLE #Global_Populate

CREATE TABLE #Global_Populate
      (CompanyName							VARCHAR(100)  
      ,CompanyAddress1						VARCHAR(100)  
      ,CompanyAddress2						VARCHAR(100)  
      ,CompanyCity							VARCHAR(100)  
      ,CompanyState							VARCHAR(100)  
      ,CompanyZipCode						VARCHAR(100)  
      ,CompanyPhone							VARCHAR(100)  
      ,CompanyFax							VARCHAR(100)  
      ,CompanyTaxID							VARCHAR(100)  
      ,CompanyTCC							VARCHAR(100)  
      ,CompanyABA							VARCHAR(100)  
      ,Dummy_Field1							VARCHAR(10)
      ,CompanyBankAcctType					VARCHAR(100)  
      ,CompanyBankAcctNum					VARCHAR(100)  
      ,CompanyContactName					VARCHAR(100)  
      ,CompanyContactPhone					VARCHAR(100)  
      ,CompanyContactExt					VARCHAR(100)  
      ,CompanyContactEmail					VARCHAR(100)  
      ,CompanyBillingContact				VARCHAR(100)  
      ,CompanyTollFreePhone					VARCHAR(100)  
      ,CompanySenderQualifier				VARCHAR(2)  
      ,CompanySenderID						VARCHAR(15)  
      ,CompanyDefaultInsuranceCarrier		VARCHAR(25)  
      ,DefaultInsCarrierDesc				VARCHAR(100)  
      ,ProcessingStates						VARCHAR(100)  
      ,CompanyDefaultLOB					VARCHAR(10)  
      ,PasswordRuleID						VARCHAR(10)  
      ,PasswordRuleDesc						VARCHAR(100)  
      ,SessionTimeout						VARCHAR(10)  
      ,TimeoutWarning						VARCHAR(10)  
      ,Dummy_Field2							VARCHAR(10)
      ,Dummy_Field3							VARCHAR(10)
      ,DuplicateMemberCheck					VARCHAR(10)  
      ,MaxClaimAge							VARCHAR(15)  
      ,MedicaidInsuranceCarrier				VARCHAR(25)  
      ,MedicaidCarrierName					VARCHAR(50)  
      ,ADAShow								CHAR(1)  
      ,DentalEncounterShow					CHAR(1)  
      ,PharmacyShow							CHAR(1)  
      ,HCFAShow								CHAR(1)  
      ,HCFAEncounterShow					CHAR(1)  
      ,UBShow								CHAR(1)  
      ,PredetYears							INT  
      ,ProvW9								CHAR(1)  
      ,ResubFlag							CHAR(1)  
      ,ClaimType							CHAR(1)  
      ,AuthTimeSpan							INT  
      ,InitialAssignmentCode				VARCHAR(50)  
      ,ClaimNumberIncomingInd				VARCHAR(50)  
      ,ClaimNumberManualInd					VARCHAR(50)  
      ,DefRateID							VARCHAR(55)  
      ,DefRateDesc							VARCHAR(55)  
      ,ToothNumberingSystem					CHAR(2)  
      ,DOITermReason						VARCHAR(20)  
      ,AutoGenMemID							CHAR(1)  
      ,ForceClear							CHAR(1)  
      ,ForceClearCC							CHAR(1)  
      ,PCPMaint								VARCHAR(10)  
      ,CCAuthCodeStore						CHAR(1)  
      ,CascadePlanToDependents				CHAR(1) 
      ,CascadeGroup							CHAR(1)  
      ,CascadeMember						CHAR(1)  
      ,SupCovMessage						CHAR(1)  
      ,GenManualTermLtr						CHAR(1)  
      ,NcpdpDefaultRejectCode				VARCHAR(2)  
      ,Dummy_Field4							VARCHAR(10)
      ,RemarkCode							VARCHAR(4)  
      ,Dummy_Field5							VARCHAR(10)
      ,PreDetCOBProcess						CHAR(1)  
      ,PreDetCarryRules						CHAR(1)  
      ,ReinstatePrompt						CHAR(1)  
      ,ConcurrentBilling					CHAR(1)  
      ,EligProcID							VARCHAR(25)  
      ,EligProcDesc							VARCHAR(55)  
      ,AlginEffectiveDate					CHAR(1)  
      ,AutoReverseMemberPTD					CHAR(1)  
      ,WarningPromptForGroupBilling			CHAR(1)  
      ,CarrierRequired						CHAR(1)  
      ,LanguageCodeFormat					CHAR(1) 
      ,AdjustProvTaxWithholding				CHAR(1)  
      ,CommonCodeLimitHistoryDisplay		CHAR(1)   
      ,EligLoadAutoFinalize					CHAR(1) 
      ,BypassPTD							CHAR(1)  
      ,Dummy_Field6							VARCHAR(10)
      ,Dummy_Field7							VARCHAR(10)
      ,Dummy_Field8							VARCHAR(10)
      ,ProvDispType							CHAR(1)  
      ,ProvDirSortOrder						VARCHAR(5)  
      ,ACHEnabled							CHAR(1)  
      ,ACHFileFormat						VARCHAR(25)  
      ,CSArchiveMonths						VARCHAR(5)  
      ,EligLoadReport						CHAR(1)  
      ,ImageExtension						VARCHAR(20)  
      ,RunCapitation						CHAR(1)  
      ,Produce277							CHAR(1)  
      ,PosPayFileFormat						CHAR(1)  
      ,CCFileFormat							CHAR(1)  
      ,GroupTrans							CHAR(1)  
      ,EmailHours							INT  
      ,EmailList							VARCHAR(200)  
      ,X12_835Version						VARCHAR(20)  
      ,X12_835GE02							VARCHAR(20)  
      ,X12_835ISA08							VARCHAR(20)  
      ,X12_835GS02							VARCHAR(20)  
      ,X12_835GS03							VARCHAR(20)  
      ,X12_835GS06							VARCHAR(20)  
      ,X12_835TRN03							VARCHAR(20)  
      ,X12_835ExtractADA					CHAR(1)  
      ,GlobalOutputType						VARCHAR(20)  
      ,X12_834CapturePremium				CHAR(1)  
      ,X12_834Version						VARCHAR(20)  
      ,EthnicityCodeSet						VARCHAR(10) 
      ,X12_837Version						VARCHAR(20)  
      ,LastExtract							CHAR(1)  
      ,PaymentIntegrityClientID				VARCHAR(25)  
      ,AcknowledgmentEmailList				VARCHAR(200)  
      ,CheckReconSetsExternalCheckNumber	CHAR(1)   
      ,FFMBaselineTradingPartnerID			VARCHAR(100) 
      ,FFMBaselineMemberIDPointer			VARCHAR(100) 
      ,Dummy_Field9							VARCHAR(10)
      ,AdditionalEOPRecordValuesID			VARCHAR(20)  
      ,AdditionalEOPRecordValuesDesc		VARCHAR(100)  
      ,Dummy_Field10						VARCHAR(10)
      ,Dummy_Field11						VARCHAR(10)
      ,DualSided							CHAR(1)  
      ,NegInvProcess						CHAR(1)  
      ,DefCensusMonths						VARCHAR(5)  
      ,DisbEarnedOnly						CHAR(1)  
      ,RetroAddCutoff						VARCHAR(5)  
      ,RollingBalancePTD					CHAR(1)  
      ,SuspenseGroupID						VARCHAR(50)  
      ,SuspenseGroupName					VARCHAR(50)  
      ,ACHAggregation						CHAR(1)   
      ,AllowRefundInterest					CHAR(1)  
      ,SeparateACHProcess					CHAR(1)  
      ,PreNoteProcess						CHAR(1)  
      ,NPPMonths							VARCHAR(3)  
      ,Dummy_Field12						VARCHAR(10)
      ,Dummy_Field13						VARCHAR(10)
      ,Dummy_Field14						VARCHAR(10)
      ,InstaMedLockBoxBN					VARCHAR(50)   
      ,Dummy_Field15						VARCHAR(10)
      ,InstaMedLockBoxBA					VARCHAR(50) 
      ,InstaMedLockBoxBD					VARCHAR(50) 
      ,InvCollection						CHAR(1)   
      ,Dummy_Field16						VARCHAR(10)
      ,FlushSusGrp2Cancel					CHAR(1)  
      ,Dummy_Field17						VARCHAR(10)
      ,MAXDollarID							VARCHAR(20)  
      ,MAXDollarDesc						VARCHAR(100)  
      ,RFFLimitId							VARCHAR(20)  
      ,RFFLimitDesc							VARCHAR(100)  
      ,MaxEOCLines							VARCHAR(10)  
      ,Dummy_Field18						VARCHAR(10)
      ,Dummy_Field19						VARCHAR(10)
      ,Dummy_Field20						VARCHAR(10)
      ,SSOEnable							CHAR(1)  
      ,SSOPath								VARCHAR(50) 
      ,SSORedirectUrl						VARCHAR(50) 
      ,MemberIDMask							VARCHAR(100) 
      ,FirstBillingRun						VARCHAR(10)  
      ,APTCBalancingStartDate				DATETIME  
      ,MultiplePortalInsurers				CHAR(1)  
      ,DisplayInactive						CHAR(1)  
      ,Dummy_Field21						VARCHAR(10)
      ,Dummy_Field22						VARCHAR(10)
      ,BL_SHL_Enabled						VARCHAR(100) 
      ,BL_SHL_LoadProvEnabled				VARCHAR(100)  
      ,BL_SHL_URL							VARCHAR(100) 
      ,BL_SHL_ClientID						VARCHAR(100)   
      ,BL_SHL_UserID						VARCHAR(100) 
      ,Dummy_Field23						VARCHAR(10)
      ,Dummy_Field24						VARCHAR(10)
      ,Dummy_Field25						VARCHAR(10)
      ,InstaMedAutoPay						CHAR(1)  
      ,InstaMedClientID						VARCHAR(100)   
      ,Dummy_Field26						VARCHAR(10)
      ,Dummy_Field27						VARCHAR(10)
      ,Dummy_Field28						VARCHAR(10)
      ,Dummy_Field29						VARCHAR(10)
      ,ProvExtractVersion					CHAR(4)  
      ,ClaimExtractVersion					CHAR(4)  
      ,ClaimsExtractVersion					CHAR(1) 
      ,Dummy_Field30						VARCHAR(10)
      ,Dummy_Field31						VARCHAR(10)
      ,Dummy_Field32						VARCHAR(10)
      ,FinanceLetterVersion					CHAR(1)  
      ,Dummy_Field33						VARCHAR(10)
      ,InvoiceExtractShortVersion			CHAR(1)  
      ,Dummy_Field34						VARCHAR(10)
      ,Dummy_Field35						VARCHAR(10)
      ,Dummy_Field36						VARCHAR(10)
      ,MemberExtractVersion					CHAR(1)    
      ,SuppressSSN							CHAR(1)    
      ,Dummy_Field37						VARCHAR(10)
      ,Dummy_Field38						VARCHAR(10)
      ,EOBVersion							CHAR(1)  
      ,date_time_created					VARCHAR(50)  
      ,user_id_created						VARCHAR(50)  
      ,date_time_modified					VARCHAR(50)  
      ,[user_id]							VARCHAR(50)  
      ,form_id								VARCHAR(50))

--*************************************************************************************************
-- Create the table that will hold the data from Core
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##Core_Data') IS NOT NULL
	DROP TABLE ##Core_Data

SET @field_counter = 1
SET @sql = 'CREATE TABLE ##Core_Data' + @crlf

WHILE @field_counter <= @max_screen_fields
	BEGIN

		SET @sql = @sql + CASE WHEN @field_counter = 1 THEN '(' ELSE ',' END + 'Field' + CONVERT(VARCHAR(10), @field_counter) + CASE WHEN @field_counter < 10 THEN '      '
																																	 WHEN @field_counter <100 THEN '     '
																																	 ELSE '    '
																																 END + 'VARCHAR(4000)' + @crlf
		SET @field_counter = @field_counter + 1
	END

SET @sql = @sql + ',date_time_created	VARCHAR(200)' + @crlf
                + ',user_id_created		VARCHAR(200)' + @crlf
				+ ',date_time_modified	VARCHAR(200)' + @crlf
				+ ',user_id				VARCHAR(200)' + @crlf
				+ ',form_id				VARCHAR(200))'
EXEC (@sql)

--*************************************************************************************************
-- Start populating the Core data 
--*************************************************************************************************
SELECT @stored_procedure_name	= populate_stored_proc
  FROM Entity_Screen_Action
 WHERE screen_gid				= @l_screen_gid
   AND action					= 'MODIFY'

SET @sql = 'INSERT INTO ##Core_Data EXEC ' + @stored_procedure_name + '''' + @l_entity_name + ''',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''ADD'',''0'','''''
EXEC(@sql)

--*************************************************************************************************
-- Make the changes to the values (assumes only one record per test case)
--*************************************************************************************************
DECLARE @CompanyTollFreeNumber		VARCHAR(200)	-- Field20
       ,@DefaultRateTableID			VARCHAR(200)	-- Field51
	   ,@ImportExportACHEnabled		VARCHAR(200)	-- Field89
	   ,@DualSidedAccounting		VARCHAR(200)	-- Field125
	   ,@DisbursementEarned			VARCHAR(200)	-- Field128
	   ,@MemberExtractVersion		VARCHAR(200)	-- Field199  -- 193
	   ,@SuppressSSN				VARCHAR(200)	-- Field200  -- 194


SELECT TOP 1
       @CompanyTollFreeNumber	= ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_CompanyTollFreeNumber]),		'Skip')
      ,@DefaultRateTableID		= ISNULL(dbo.fnDCAuto_GetDropdownValue([Processing_DefaultRateTableID]),	'Skip')		
	  ,@ImportExportACHEnabled	= ISNULL(dbo.fnDCAuto_GetDropdownValue([ImportExport_ACHEnabled]),			'Skip')
	  ,@DualSidedAccounting		= ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_DualSidedAccounting]),		'Skip')
	  ,@DisbursementEarned		= ISNULL(dbo.fnDCAuto_GetDropdownValue([Finance_DisbursementEarned]),		'Skip')
	  ,@MemberExtractVersion	= ISNULL(dbo.fnDCAuto_GetDropdownValue([*Extracts_MemberExtractVersion]),	'Skip')
	  ,@SuppressSSN				= ISNULL(dbo.fnDCAuto_GetDropdownValue([Extracts_SuppressSSN]),				'Skip')
	  ,@record_id				= RecordID
  FROM COREAUTO.CoreAutomation.dbo.TD_GlobalValues
 WHERE TCID LIKE @pattern

-- Make sure the fields have not moved on the screen, otherwise abort with an error
SET @err_num = 0
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Company Toll Free Phone:'	AND FieldOrder = 20)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Default Rate Table ID:'		AND FieldOrder = 51)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'ACH Enabled:'				AND FieldOrder = 89)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Dual Sided Accounting:'		AND FieldOrder = 125)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Disbursement Earned'			AND FieldOrder = 128)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Member Extract Version:'		AND FieldOrder = 199)	SET @err_num = 16
IF NOT EXISTS(SELECT TOP 1 * FROM ScreenDetails WHERE ScreenGID = 169 AND label = 'Suppress SSN:'				AND FieldOrder = 200)	SET @err_num = 16

IF @err_num <> 0 SET @err_msg = 'The Global Values screen appears to have changed. Aborting update.'
IF @err_num <> 0 GOTO ERROR_EXIT

IF @CompanyTollFreeNumber	<> 'Skip' BEGIN UPDATE ##Core_Data SET Field20	= @CompanyTollFreeNumber	END
IF @DefaultRateTableID		<> 'Skip' BEGIN UPDATE ##Core_Data SET Field51	= @DefaultRateTableID		END
IF @ImportExportACHEnabled	<> 'Skip' BEGIN UPDATE ##Core_Data SET Field89  = @ImportExportACHEnabled	END
IF @DualSidedAccounting		<> 'Skip' BEGIN UPDATE ##Core_Data SET Field125 = @DualSidedAccounting		END
IF @DisbursementEarned		<> 'Skip' BEGIN UPDATE ##Core_Data SET Field128 = @DisbursementEarned		END
IF @MemberExtractVersion	<> 'Skip' BEGIN UPDATE ##Core_Data SET Field199 = @MemberExtractVersion		END
IF @SuppressSSN				<> 'Skip' BEGIN UPDATE ##Core_Data SET Field200 = @SuppressSSN				END

--*************************************************************************************************
-- Build the SQL that will be used to do the update
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##Field_Value') IS NOT NULL
	DROP TABLE ##Field_Value

CREATE TABLE ##Field_Value
      (field_value	VARCHAR(4000) DEFAULT (''))

DECLARE @label			VARCHAR(200)
       ,@is_locked		BIT
	   ,@data_type		VARCHAR(200)
	   ,@field_value	VARCHAR(4000)
	   ,@sql_field		VARCHAR(4000)

-- Need to add a blank row to this table for this to work
SET @sql_field = 'INSERT INTO ##Field_Value(field_value) VALUES ('''')'
EXEC(@sql_field)

SET @sql = 'EXEC prGlobalParamModify ''Global_Values'', ''0'', ''0'', ''0'', ''0'', ''0'', ''0'', ''0'', ''0'', ''0'', ''0'', ''ADD'','''',''' + @user + '''' 

SET @field_counter = 1

WHILE @field_counter <= @max_screen_fields
	BEGIN

		SELECT @label			= ISNULL(Label, '')
		      ,@data_type		= DataType
		      ,@is_locked		= isLocked
		  FROM #ScreenDetails
		 WHERE FieldOrder		= @field_counter

		SET @sql_field = 'UPDATE ##Field_Value SET field_value = ISNULL(Field' + CONVERT(VARCHAR(20), @field_counter) + ', '''') FROM ##Core_Data'
		EXEC(@sql_field)

		SELECT @field_value = field_value FROM ##Field_Value

		IF @label <> '' AND @data_type <> 'EXPAND' AND @data_type <> 'DUMMY' AND @data_type <> 'SPACE'
			BEGIN

				SET @sql = @sql + ',''' + @field_value + ''''
			END

		SET @field_counter = @field_counter + 1
		
	END

SET @sql = @sql + ',0,'''''

BEGIN TRY

	PRINT @sql
	EXEC (@sql)

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

END CATCH
--*************************************************************************************************
-- Log the results
--*************************************************************************************************
ERROR_EXIT:
SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Global_Values', 'Modify', @record_id, @status, @err_num, @err_msg

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.##Core_Data') IS NOT NULL
	DROP TABLE ##Core_Data

IF Object_ID('tempdb.dbo.#ScreenDetails') IS NOT NULL
	DROP TABLE #ScreenDetails

IF OBJECT_ID('tempdb.dbo.##Field_Value') IS NOT NULL
	DROP TABLE ##Field_Value

END
GO