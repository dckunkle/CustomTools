IF OBJECT_ID('dbo.fnAPIAuto_GetIntegrationGlobalValues') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAPIAuto_GetIntegrationGlobalValues() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnAPIAuto_GetIntegrationGlobalValues
Purpose:    Given a test case generate the necessary test cases

Date        User            Change
---------------------------------------------------------------------------------------------
06/24/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
SELECT dbo.fnAPIAuto_GetIntegrationGlobalValues()
***************************************************************************************************/
ALTER FUNCTION dbo.fnAPIAuto_GetIntegrationGlobalValues()

RETURNS VARCHAR(MAX)
AS
BEGIN

--*************************************************************************************************
-- Gather all of the settings for the Integration service
--*************************************************************************************************
DECLARE  @IntegrationLoggingEnabled					VARCHAR(10)  
        ,@CompanyName								VARCHAR(100)  
        ,@ServerInstance							VARCHAR(100)  
        ,@ExternalAuthorizationSecurityKey			VARCHAR(500)  
        ,@ExternalAuthorizationURL					VARCHAR(100)  
        ,@AdjudicationLoggingEnabled				VARCHAR(10)  
        ,@DefaultLOBType							VARCHAR(6)  
        ,@ProcessingState							VARCHAR(100)  
        ,@MaxClaimAge								VARCHAR(20)  
		,@MaxClaimAgeInt							INT
        ,@NPFUsed									VARCHAR(10)  
        ,@CarryPredeterminationRemarkCodesToClaim	VARCHAR(10)  
        ,@EnforceCOBEditsForPredetermination		VARCHAR(10)  
        ,@BenefitModeling							VARCHAR(100)  
        ,@AssignmentOverride						VARCHAR(10)  
        ,@AlderaWebServiceURL						VARCHAR(100)  
        ,@AlderaWebServiceURLOverride				VARCHAR(100)  
		,@ProviderMatchingServiceEnabled			VARCHAR(10)  
		,@ProviderMatchingServiceURL				VARCHAR(100)  
		,@ProviderMatchingAPIKey					VARCHAR(100)  
		,@RulesEngineEnabled						VARCHAR(100)  
		,@RulesEngineURL							VARCHAR(100)  
        ,@CountClaimsForAuthEnabled					VARCHAR(10)  
        ,@CountClaimsForAuthURL						VARCHAR(100)  
		,@PricingRejectOverride						VARCHAR(10)  
        ,@RuleSetName								VARCHAR(100)  

		,@IntegrationJson							VARCHAR(MAX)
		,@OutputJson								VARCHAR(MAX)

--*************************************************************************************************
-- Get global settings for the Integration Service
--*************************************************************************************************
SELECT @IntegrationLoggingEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'IntegrationLoggingEnabled'
   AND record_status = 'A'

SELECT @CompanyName = variable_value
  FROM Global_Values 
 WHERE variable_name = 'COMPANY_NAME'
   AND record_status = 'A'

SELECT @ServerInstance = variable_value
  FROM Global_Values 
 WHERE variable_name = 'SERVER_INSTANCE'
   AND record_status = 'A'

SELECT @ExternalAuthorizationURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'AUTH_WSL'
   AND record_status = 'A'

SELECT @ExternalAuthorizationSecurityKey = variable_value
  FROM Global_Values 
 WHERE variable_name = 'AUTH_WSL_SECKEY'
   AND record_status = 'A'

SELECT @AdjudicationLoggingEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'AdjudicationTraceLogEnabled'
   AND record_status = 'A'

SELECT @BenefitModeling = variable_value
  FROM Global_Values 
 WHERE variable_name = 'BENEFIT_MODELING'
   AND record_status = 'A'

SELECT @DefaultLOBType = variable_value
  FROM Global_Values 
 WHERE variable_name = 'DEFAULT_LOB'
   AND record_status = 'A'

SELECT @ProcessingState = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PROC_STATE'
   AND record_status = 'A'

SELECT @MaxClaimAge = variable_value
  FROM Global_Values 
 WHERE variable_name = 'MAX_CLAIM_AGE'
   AND record_status = 'A'

SELECT @NPFUsed = variable_value
  FROM Global_Values 
 WHERE variable_name = 'NPF_USED'
   AND record_status = 'A'

SELECT @EnforceCOBEditsForPredetermination = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PREDET_COB_EDITS'
   AND record_status = 'A'

SELECT @CarryPredeterminationRemarkCodesToClaim = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PREDET_CARRY_RC'
   AND record_status = 'A'

SELECT @AssignmentOverride = variable_value
  FROM Global_Values 
 WHERE variable_name = 'Base_Assignment'
   AND record_status = 'A'
  
SELECT @AlderaWebServiceURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'AlderaWebServiceURL'
   AND record_status = 'A'

SELECT @AlderaWebServiceURLOverride = variable_value
  FROM Global_Values 
 WHERE variable_name = 'AlderaWebServiceURLOverride'
   AND record_status = 'A'

SELECT @ProviderMatchingServiceEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'ProviderMatchingServiceEnabled'
   AND record_status = 'A'

SELECT @ProviderMatchingServiceURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'ProviderMatchingServiceURL'
   AND record_status = 'A'

SELECT @ProviderMatchingAPIKey = variable_value
  FROM Global_Values 
 WHERE variable_name = 'ProviderMatchingAPIKey'
   AND record_status = 'A'

SELECT @RulesEngineEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'RulesEngineEnabled'
   AND record_status = 'A'

SELECT @RulesEngineURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'RulesEngineURL'
   AND record_status = 'A'

SELECT @ProviderMatchingAPIKey = variable_value
  FROM Global_Values 
 WHERE variable_name = 'ProviderMatchingAPIKey'
   AND record_status = 'A'

SELECT @CountClaimsForAuthEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'CountClaimsForAuthEnabled'
   AND record_status = 'A'

SELECT @CountClaimsForAuthURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'CountClaimsForAuthURL'
   AND record_status = 'A'
 
SELECT @PricingRejectOverride = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PricingRejectOverride'
   AND record_status = 'A'

SELECT @RuleSetName = variable_value
  FROM Global_Values 
 WHERE variable_name = 'RuleSetName'
   AND record_status = 'A'
  
--*************************************************************************************************
-- Update some of the values
--*************************************************************************************************
SELECT @IntegrationLoggingEnabled				= ISNULL(@IntegrationLoggingEnabled, '')  
	  ,@CompanyName								= dbo.fnFormatForXML(@CompanyName) 				
	  ,@ServerInstance							= ISNULL(@ServerInstance, '')					
	  ,@ExternalAuthorizationSecurityKey		= ISNULL(@ExternalAuthorizationSecurityKey, '')		
	  ,@ExternalAuthorizationURL				= ISNULL(@ExternalAuthorizationURL, '')
	  ,@AdjudicationLoggingEnabled				= ISNULL(@AdjudicationLoggingEnabled, '')				
	  ,@DefaultLOBType							= ISNULL(@DefaultLOBType, '')
	  ,@ProcessingState							= ISNULL(@ProcessingState, '')
	  ,@MaxClaimAge								= ISNULL(@MaxClaimAge, '0')
	  ,@MaxClaimAgeInt							= ISNULL(@MaxClaimAgeInt, 0)
	  ,@NPFUsed									= ISNULL(@NPFUsed, '')
	  ,@CarryPredeterminationRemarkCodesToClaim	= ISNULL(@CarryPredeterminationRemarkCodesToClaim, '')
	  ,@EnforceCOBEditsForPredetermination		= ISNULL(@EnforceCOBEditsForPredetermination, '')
	  ,@BenefitModeling							= ISNULL(@BenefitModeling, 'N')
	  ,@AssignmentOverride						= ISNULL(@AssignmentOverride, 'D')
	  ,@AlderaWebServiceURL						= ISNULL(@AlderaWebServiceURL, '')
	  ,@AlderaWebServiceURLOverride				= ISNULL(@AlderaWebServiceURLOverride, '')
	  ,@ProviderMatchingServiceEnabled			= ISNULL(@ProviderMatchingServiceEnabled, '')
	  ,@ProviderMatchingServiceURL				= ISNULL(@ProviderMatchingServiceURL, '')
	  ,@ProviderMatchingAPIKey					= ISNULL(@ProviderMatchingAPIKey, '')
	  ,@RulesEngineEnabled						= ISNULL(@RulesEngineEnabled, '')
	  ,@RulesEngineURL							= ISNULL(@RulesEngineURL, '')
	  ,@CountClaimsForAuthEnabled				= ISNULL(@CountClaimsForAuthEnabled, '')	
	  ,@CountClaimsForAuthURL					= ISNULL(@CountClaimsForAuthURL, '')	
	  ,@PricingRejectOverride					= ISNULL(@PricingRejectOverride, '')	
	  ,@RuleSetName								= ISNULL(@RuleSetName, '')

SELECT @MaxClaimAgeInt							= CONVERT(INT, @MaxClaimAge)

SELECT @IntegrationLoggingEnabled				= CASE @IntegrationLoggingEnabled				WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @AdjudicationLoggingEnabled				= CASE @AdjudicationLoggingEnabled				WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @EnforceCOBEditsForPredetermination		= CASE @EnforceCOBEditsForPredetermination		WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @CarryPredeterminationRemarkCodesToClaim	= CASE @CarryPredeterminationRemarkCodesToClaim	WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @ProviderMatchingServiceEnabled			= CASE @ProviderMatchingServiceEnabled			WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @RulesEngineEnabled						= CASE @RulesEngineEnabled						WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @CountClaimsForAuthEnabled				= CASE @CountClaimsForAuthEnabled				WHEN 'Y' THEN 'true' ELSE 'false' END
SELECT @PricingRejectOverride					= CASE @PricingRejectOverride					WHEN 'Y' THEN 'true' ELSE 'false' END

--*************************************************************************************************
-- Build the Integration portion of the JSON (manually building JSON to avoid escape characters)
--*************************************************************************************************
SELECT @IntegrationJson = '{'
      ,@IntegrationJson = @IntegrationJson + '"IntegrationLoggingEnabled": ' +					@IntegrationLoggingEnabled					+ ','
      ,@IntegrationJson = @IntegrationJson + '"ServerInstance": "' +							@ServerInstance								+ '",'
      ,@IntegrationJson = @IntegrationJson + '"CompanyName": "' +								@CompanyName								+ '",'  
      ,@IntegrationJson = @IntegrationJson + '"ExternalAuthorizationURL": "' +					@ExternalAuthorizationURL					+ '",'
      ,@IntegrationJson = @IntegrationJson + '"ExternalAuthorizationSecurityKey": "' +			@ExternalAuthorizationSecurityKey			+ '",'
      ,@IntegrationJson = @IntegrationJson + '"AdjudicationLoggingEnabled": ' +					@AdjudicationLoggingEnabled					+ ','
      ,@IntegrationJson = @IntegrationJson + '"BenefitModeling": "' +							@BenefitModeling							+ '",'
      ,@IntegrationJson = @IntegrationJson + '"CarryPredeterminationRemarkCodesToClaim": ' +	@CarryPredeterminationRemarkCodesToClaim	+ ','
      ,@IntegrationJson = @IntegrationJson + '"EnforceCOBEditsForPredetermination": ' +			@EnforceCOBEditsForPredetermination			+ ','
      ,@IntegrationJson = @IntegrationJson + '"ProcessingState": "' +							@ProcessingState							+ '",'
      ,@IntegrationJson = @IntegrationJson + '"MaxClaimAge": "' +								CONVERT(VARCHAR(10), @MaxClaimAge)			+ '",'
	  ,@IntegrationJson = @IntegrationJson + '"MaxClaimAgeInt": ' +								CONVERT(VARCHAR(10), @MaxClaimAgeInt)		+ ','
      ,@IntegrationJson = @IntegrationJson + '"NPFUsed": "' +									@NPFUsed									+ '",'
      ,@IntegrationJson = @IntegrationJson + '"DefaultLOBType": "' +							@DefaultLOBType								+ '",'
      ,@IntegrationJson = @IntegrationJson + '"AssignmentOverride": "' +						@AssignmentOverride							+ '",'
      ,@IntegrationJson = @IntegrationJson + '"AlderaWebServiceURL": "' +						@AlderaWebServiceURL						+ '",'
      ,@IntegrationJson = @IntegrationJson + '"AlderaWebServiceURLOverride": "' +				@AlderaWebServiceURLOverride				+ '",'
      ,@IntegrationJson = @IntegrationJson + '"ProviderMatchingServiceEnabled": ' +				@ProviderMatchingServiceEnabled				+ ','
      ,@IntegrationJson = @IntegrationJson + '"ProviderMatchingServiceURL": "' +				@ProviderMatchingServiceURL					+ '",'
      ,@IntegrationJson = @IntegrationJson + '"ProviderMatchingAPIKey": "' +					@ProviderMatchingAPIKey						+ '",'
      ,@IntegrationJson = @IntegrationJson + '"RulesEngineEnabled": ' +							@RulesEngineEnabled							+ ','
      ,@IntegrationJson = @IntegrationJson + '"RulesEngineURL": "' +							@RulesEngineURL								+ '",'
      ,@IntegrationJson = @IntegrationJson + '"CountClaimsForAuthEnabled": ' +					@CountClaimsForAuthEnabled					+ ','
      ,@IntegrationJson = @IntegrationJson + '"CountClaimsForAuthURL": "' +						@CountClaimsForAuthURL						+ '",'
      ,@IntegrationJson = @IntegrationJson + '"PricingRejectOverride": ' +						@PricingRejectOverride						+ ','
      ,@IntegrationJson = @IntegrationJson + '"RuleSetName": "' +								@RuleSetName								+ '",'

--*************************************************************************************************
-- Build the Payer Compass portion of the JSON
--*************************************************************************************************
DECLARE @PayerCompassURL		VARCHAR(200)
	   ,@UserID					VARCHAR(100)
	   ,@Password				VARCHAR(100)
	   ,@PayerID				VARCHAR(100)
	   ,@IsTestClaim			VARCHAR(10)
	   ,@IsLoggingEnabled		VARCHAR(10)
	   
	   ,@PayerCompassJson		VARCHAR(MAX)

--*************************************************************************************************
-- Get global settings for the Integration Service
--*************************************************************************************************
SELECT @PayerID = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerID'
   AND record_status = 'A'

SELECT @PayerCompassURL = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerCompassURL'
   AND record_status = 'A'

SELECT @UserID = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerCompassUserID'
   AND record_status = 'A'

SELECT @Password = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerCompassPassword'
   AND record_status = 'A'

SELECT @IsLoggingEnabled = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerCompassLoggingEnabled'
   AND record_status = 'A'

SELECT @IsTestClaim = variable_value
  FROM Global_Values 
 WHERE variable_name = 'PayerCompassIsTestClaim'
   AND record_status = 'A'

--*************************************************************************************************
-- Update some of the values
--*************************************************************************************************
SELECT @PayerCompassURL			= ISNULL(@PayerCompassURL, '')
	  ,@UserID					= ISNULL(@UserID, '')
	  ,@Password				= ISNULL(@Password, '')
	  ,@PayerID					= ISNULL(@PayerID, '')
	  ,@IsTestClaim				= ISNULL(@IsTestClaim, '')
	  ,@IsLoggingEnabled		= ISNULL(@IsLoggingEnabled, '')

	  ,@IsTestClaim				= CASE WHEN @IsTestClaim = 'Y'		THEN 'true' ELSE 'false' END
	  ,@IsLoggingEnabled		= CASE WHEN @IsLoggingEnabled = 'Y'	THEN 'true' ELSE 'false' END


--*************************************************************************************************
-- Build the Payer Compass portion of the JSON (manually building JSON to avoid escape characters)
--*************************************************************************************************
SELECT @PayerCompassJson = '"PayerCompassGlobalParams": {'
      ,@PayerCompassJson = @PayerCompassJson + '"PayerCompassURL": "'	+ @PayerCompassURL	+ '",'
      ,@PayerCompassJson = @PayerCompassJson + '"UserID": "'			+ @UserID			+ '",'
	  ,@PayerCompassJson = @PayerCompassJson + '"Password": "'			+ @Password			+ '",'
	  ,@PayerCompassJson = @PayerCompassJson + '"PayerID": "'			+ @PayerID			+ '",'
	  ,@PayerCompassJson = @PayerCompassJson + '"IsTestClaim": '		+ @IsTestClaim		+ ','
	  ,@PayerCompassJson = @PayerCompassJson + '"IsLoggingEnabled": '	+ @IsLoggingEnabled	+ ''
	  ,@PayerCompassJson = @PayerCompassJson + '}'

--*************************************************************************************************
-- Create the final JSON and return it
--*************************************************************************************************
DECLARE @CompleteJson								VARCHAR(MAX)

SELECT @CompleteJson = @IntegrationJson + @PayerCompassJson + '}'

SELECT @OutputJson = (SELECT JSON_QUERY(@CompleteJson) AS IntegrationGlobalParams
                         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

SELECT @OutputJson = SUBSTRING(@OutputJson, 2, 999999)
SELECT @OutputJson = SUBSTRING(@OutputJson, 1, LEN(@OutputJson) - 1)

RETURN @OutputJson

END 
GO