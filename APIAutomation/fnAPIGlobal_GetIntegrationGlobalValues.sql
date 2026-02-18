IF OBJECT_ID('dbo.spAPIGlobal_GetIntegrationGlobalValues') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spAPIGlobal_GetIntegrationGlobalValues AS SELECT 1')
GO
/**************************************************************************************************
Name:       spAPIGlobal_GetIntegrationGlobalValues
Purpose:    Given a test case generate the necessary test cases

Comments:	I have tried a number of approaches for this code. xp_cmdshell only returns 255 characters
            therefore I could not put the function on the target system to return the JSON.
			I tried OPENROWSET and OPENQUERY and neither worked without distributed transaction
			setup.

Date        User            Change
---------------------------------------------------------------------------------------------
06/24/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @OutputJson VARCHAR(MAX)
EXEC dbo.spAPIGlobal_GetIntegrationGlobalValues 'alddevdb03\corec06','COREC06APP',@OutputJson OUTPUT
SELECT @OutputJson
***************************************************************************************************/
ALTER PROCEDURE dbo.spAPIGlobal_GetIntegrationGlobalValues
     (@server_name		VARCHAR(200)
	 ,@database_name	VARCHAR(200)
	 ,@OutputJson		VARCHAR(MAX) OUTPUT)

AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Gather all of the settings for the Integration service
--*************************************************************************************************
DECLARE @IntegrationLoggingEnabled					VARCHAR(10)  
       ,@CompanyName								VARCHAR(100)  
       ,@ServerInstance								VARCHAR(100)  
       ,@ExternalAuthorizationSecurityKey			VARCHAR(500)  
       ,@ExternalAuthorizationURL					VARCHAR(100)  
       ,@AdjudicationLoggingEnabled					VARCHAR(10)  
       ,@DefaultLOBType								VARCHAR(6)  
       ,@ProcessingState							VARCHAR(100)  
       ,@MaxClaimAge								VARCHAR(20)  
	   ,@MaxClaimAgeInt								INT
       ,@NPFUsed									VARCHAR(10)  
       ,@CarryPredeterminationRemarkCodesToClaim	VARCHAR(10)  
       ,@EnforceCOBEditsForPredetermination			VARCHAR(10)  
       ,@BenefitModeling							VARCHAR(100)  
       ,@AssignmentOverride							VARCHAR(10)  
       ,@AlderaWebServiceURL						VARCHAR(100)  
       ,@AlderaWebServiceURLOverride				VARCHAR(100)  
	   ,@ProviderMatchingServiceEnabled				VARCHAR(10)  
	   ,@ProviderMatchingServiceURL					VARCHAR(100)  
	   ,@ProviderMatchingAPIKey						VARCHAR(100)  
	   ,@RulesEngineEnabled							VARCHAR(100)  
	   ,@RulesEngineURL								VARCHAR(100)  
       ,@CountClaimsForAuthEnabled					VARCHAR(10)  
       ,@CountClaimsForAuthURL						VARCHAR(100)  
	   ,@PricingRejectOverride						VARCHAR(10)  
       ,@RuleSetName								VARCHAR(100)  

	   ,@IntegrationJson							VARCHAR(MAX)

	   ,@PayerCompassURL							VARCHAR(200)
	   ,@UserID										VARCHAR(100)
	   ,@Password									VARCHAR(100)
	   ,@PayerID									VARCHAR(100)
	   ,@IsTestClaim								VARCHAR(10)
	   ,@IsLoggingEnabled							VARCHAR(10)
	   
	   ,@PayerCompassJson							VARCHAR(MAX)

	   ,@variable_name								VARCHAR(200)

	   ,@err_num									INT
	   ,@err_msg									VARCHAR(8000)
	   ,@cmd										VARCHAR(8000)
	   ,@sql										VARCHAR(8000)

--*************************************************************************************************
-- Create a table to gather the global parameters and their values
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#parameter_values') IS NOT NULL
	DROP TABLE #parameter_values

CREATE TABLE #parameter_values
      (variable_name		VARCHAR(200)
	  ,variable_value		VARCHAR(2000))

-- Integration Service Global Values
INSERT INTO #parameter_values(variable_name) VALUES ('IntegrationLoggingEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('COMPANY_NAME')
INSERT INTO #parameter_values(variable_name) VALUES ('SERVER_INSTANCE')
INSERT INTO #parameter_values(variable_name) VALUES ('AUTH_WSL')
INSERT INTO #parameter_values(variable_name) VALUES ('AUTH_WSL_SECKEY')
INSERT INTO #parameter_values(variable_name) VALUES ('AdjudicationTraceLogEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('BENEFIT_MODELING')
INSERT INTO #parameter_values(variable_name) VALUES ('DEFAULT_LOB')
INSERT INTO #parameter_values(variable_name) VALUES ('PROC_STATE')
INSERT INTO #parameter_values(variable_name) VALUES ('MAX_CLAIM_AGE')
INSERT INTO #parameter_values(variable_name) VALUES ('NPF_USED')
INSERT INTO #parameter_values(variable_name) VALUES ('PREDET_COB_EDITS')
INSERT INTO #parameter_values(variable_name) VALUES ('PREDET_CARRY_RC')
INSERT INTO #parameter_values(variable_name) VALUES ('Base_Assignment')
INSERT INTO #parameter_values(variable_name) VALUES ('AlderaWebServiceURL')
INSERT INTO #parameter_values(variable_name) VALUES ('AlderaWebServiceURLOverride')
INSERT INTO #parameter_values(variable_name) VALUES ('ProviderMatchingServiceEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('ProviderMatchingServiceURL')
INSERT INTO #parameter_values(variable_name) VALUES ('ProviderMatchingAPIKey')
INSERT INTO #parameter_values(variable_name) VALUES ('RulesEngineEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('RulesEngineURL')
INSERT INTO #parameter_values(variable_name) VALUES ('CountClaimsForAuthEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('CountClaimsForAuthURL')
INSERT INTO #parameter_values(variable_name) VALUES ('PricingRejectOverride')
INSERT INTO #parameter_values(variable_name) VALUES ('RuleSetName')

-- Payer Compass Global Values
INSERT INTO #parameter_values(variable_name) VALUES ('PayerID')
INSERT INTO #parameter_values(variable_name) VALUES ('PayerCompassURL')
INSERT INTO #parameter_values(variable_name) VALUES ('PayerCompassUserID')
INSERT INTO #parameter_values(variable_name) VALUES ('PayerCompassPassword')
INSERT INTO #parameter_values(variable_name) VALUES ('PayerCompassLoggingEnabled')
INSERT INTO #parameter_values(variable_name) VALUES ('PayerCompassIsTestClaim')

--*************************************************************************************************
-- Loop through each of the global parameters and get the value from the target system
--*************************************************************************************************
DECLARE Global_Parameters_Cursor CURSOR FOR
 SELECT P.variable_name
   FROM #parameter_values P

   OPEN Global_Parameters_Cursor
  FETCH NEXT FROM Global_Parameters_Cursor
   INTO @variable_name
  
WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Create a table to collect the results of the query
			IF OBJECT_ID('tempdb.dbo.#cmd_results') IS NOT NULL
			DROP TABLE #cmd_results

			CREATE TABLE #cmd_results
				  (results		VARCHAR(MAX)
				  ,result_id	INT				IDENTITY(1,1))

			SET @sql = 'SELECT variable_value FROM Global_Values WHERE record_status = ''A'' AND variable_name = ''' + @variable_name + ''''
			SET @sql = 'USE ' + @database_name + ' ' + @sql
			SET @cmd = 'SQLCMD -S ' + @server_name + ' -Q "' + @sql + '"'

			INSERT INTO #cmd_results
			EXEC master.sys.xp_cmdshell @cmd
			--SELECT * FROM #cmd_results

			SELECT @sql = 'UPDATE P
			                  SET variable_value = (SELECT RTRIM(LTRIM(CR.results))
							                          FROM #cmd_results		CR
							                         WHERE CR.result_id		= 4)
							 FROM #parameter_values P
							WHERE variable_name = ''' + @variable_name + ''''
			EXEC(@sql)

		END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()


		END CATCH

		
			PRINT 'Error: ' + @err_msg

		FETCH NEXT FROM Global_Parameters_Cursor
         INTO @variable_name

	END

CLOSE Global_Parameters_Cursor
DEALLOCATE Global_Parameters_Cursor

--*************************************************************************************************
-- Update some of the values
--*************************************************************************************************
SELECT @IntegrationLoggingEnabled				= variable_value FROM #parameter_values WHERE variable_name = 'IntegrationLoggingEnabled'
SELECT @CompanyName								= variable_value FROM #parameter_values WHERE variable_name = 'COMPANY_NAME'			
SELECT @ServerInstance							= variable_value FROM #parameter_values WHERE variable_name = 'SERVER_INSTANCE'				
SELECT @ExternalAuthorizationSecurityKey		= variable_value FROM #parameter_values WHERE variable_name = 'AUTH_WSL_SECKEY'	
SELECT @ExternalAuthorizationURL				= variable_value FROM #parameter_values WHERE variable_name = 'AUTH_WSL'
SELECT @AdjudicationLoggingEnabled				= variable_value FROM #parameter_values WHERE variable_name = 'AdjudicationTraceLogEnabled'		
SELECT @BenefitModeling							= variable_value FROM #parameter_values WHERE variable_name = 'BENEFIT_MODELING'		
SELECT @DefaultLOBType							= variable_value FROM #parameter_values WHERE variable_name = 'DEFAULT_LOB'
SELECT @ProcessingState							= variable_value FROM #parameter_values WHERE variable_name = 'PROC_STATE'
SELECT @MaxClaimAge								= variable_value FROM #parameter_values WHERE variable_name = 'MAX_CLAIM_AGE'
SELECT @NPFUsed									= variable_value FROM #parameter_values WHERE variable_name = 'NPF_USED'
SELECT @CarryPredeterminationRemarkCodesToClaim	= variable_value FROM #parameter_values WHERE variable_name = 'PREDET_COB_EDITS'
SELECT @EnforceCOBEditsForPredetermination		= variable_value FROM #parameter_values WHERE variable_name = 'PREDET_CARRY_RC'
SELECT @AssignmentOverride						= variable_value FROM #parameter_values WHERE variable_name = 'Base_Assignment'
SELECT @AlderaWebServiceURL						= variable_value FROM #parameter_values WHERE variable_name = 'AlderaWebServiceURL'
SELECT @AlderaWebServiceURLOverride				= variable_value FROM #parameter_values WHERE variable_name = 'AlderaWebServiceURLOverride'
SELECT @ProviderMatchingServiceEnabled			= variable_value FROM #parameter_values WHERE variable_name = 'ProviderMatchingServiceEnabled'
SELECT @ProviderMatchingServiceURL				= variable_value FROM #parameter_values WHERE variable_name = 'ProviderMatchingServiceURL'
SELECT @ProviderMatchingAPIKey					= variable_value FROM #parameter_values WHERE variable_name = 'ProviderMatchingAPIKey'
SELECT @RulesEngineEnabled						= variable_value FROM #parameter_values WHERE variable_name = 'RulesEngineEnabled'
SELECT @RulesEngineURL							= variable_value FROM #parameter_values WHERE variable_name = 'RulesEngineURL'
SELECT @CountClaimsForAuthEnabled				= variable_value FROM #parameter_values WHERE variable_name = 'CountClaimsForAuthEnabled'	
SELECT @CountClaimsForAuthURL					= variable_value FROM #parameter_values WHERE variable_name = 'CountClaimsForAuthURL'
SELECT @PricingRejectOverride					= variable_value FROM #parameter_values WHERE variable_name = 'PricingRejectOverride'
SELECT @RuleSetName								= variable_value FROM #parameter_values WHERE variable_name = 'RuleSetName'

SELECT @PayerCompassURL							= variable_value FROM #parameter_values WHERE variable_name = 'PayerCompassURL'
SELECT @UserID									= variable_value FROM #parameter_values WHERE variable_name = 'PayerCompassUserID'
SELECT @Password								= variable_value FROM #parameter_values WHERE variable_name = 'PayerCompassPassword'
SELECT @PayerID									= variable_value FROM #parameter_values WHERE variable_name = 'PayerID'
SELECT @IsTestClaim								= variable_value FROM #parameter_values WHERE variable_name = 'PayerCompassIsTestClaim'
SELECT @IsLoggingEnabled						= variable_value FROM #parameter_values WHERE variable_name = 'PayerCompassLoggingEnabled'

--*************************************************************************************************
-- Update some of the values
--*************************************************************************************************
SELECT @IntegrationLoggingEnabled				= ISNULL(@IntegrationLoggingEnabled, '')  
	  ,@CompanyName								= ISNULL(@CompanyName, '') 				
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

END 
GO