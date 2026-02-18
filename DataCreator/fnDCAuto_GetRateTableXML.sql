IF OBJECT_ID('dbo.fnDCAuto_GetRateTableXML') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetRateTableXML() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetRateTableXML
Purpose:    Extract the dropdown value from the dropdown description/value
            Ex. Medical(M) need to extract the M

Date        User            Change
---------------------------------------------------------------------------------------------
10/17/2019	DK				Original script
12/09/2019	DK				Added spaces and formatting to match exactly Aldera
---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetRateTableXML
     (@i_rate_table_id		VARCHAR(200)
	 ,@i_coverage_tier_id	VARCHAR(200))

RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @rate_tableXML			VARCHAR(MAX)	= ''
		   ,@l_coverage_tier_id		VARCHAR(200)	= ''
		   ,@l_rate_table_id		VARCHAR(200)	= ''
		   ,@max_code				INT				= 0
		   ,@code_counter			INT				= 1
		   ,@code_rates				VARCHAR(300)	= ''
		   ,@rate					VARCHAR(200)	= ''

--*************************************************************************************************
-- Gather the data to build the XML for the rates
--*************************************************************************************************
	DECLARE @coverage_codes	TABLE
	       (code		VARCHAR(30)
		   ,code_order	INT				IDENTITY(1,1)
		   ,rate		VARCHAR(20))

	SELECT  @l_coverage_tier_id		= @i_coverage_tier_id
	       ,@l_rate_table_id		= @i_rate_table_id

	INSERT INTO @coverage_codes 
		  (code)
	SELECT CC.coverage_code
      FROM Entity_Names				EN
	  JOIN Coverage_Tiers			CT
	    ON EN.entity_gid			= CT.Coverage_Tiers_gid
      JOIN Coverage_Codes			CC
        ON CT.coverage_code			= CC.coverage_code
     WHERE CT.record_status			= 'A'  
       AND CC.record_status			= 'A'  
	   AND EN.record_status			= 'A'
	   AND EN.entity_identifier		LIKE 'COVERAGE_CODE_TIERS'
       AND entity_user_id			= @l_coverage_tier_id
     ORDER BY CC.num_of_subscribers  
             ,CC.min_dependents  
             ,CC.max_dependents  
             ,CC.coverage_code

	UPDATE CC
	   SET rate					= CONVERT(VARCHAR(20),CONVERT(DECIMAL(10,4),RTW.Rate))
	  FROM @coverage_codes		CC
	  JOIN COREAUTO.CoreAutomation.dbo.TD_RateTableWizard RTW
	    ON CC.code				= RTW.CoverageCode
	 WHERE RTW.RateTableID		= @l_rate_table_id

	SELECT @max_code		= MAX(CC.code_order)
	  FROM @coverage_codes	CC

	WHILE @code_counter <= @max_code
		BEGIN

			SELECT @rate = rate FROM @coverage_codes WHERE code_order = @code_counter
			SELECT @code_rates	 = @code_rates + ' V' + CONVERT(VARCHAR(20), @code_counter) + '=''' + @rate + ''' '
			SELECT @code_counter = @code_counter + 1
			
		END

	SELECT @rate_tableXML = '<Data Type=''RATE WIZARD''  C=''' + @l_coverage_tier_id + ''' A='''' G=''N''' + @code_rates + ' />'

--*************************************************************************************************
-- Build the XML necessary
--*************************************************************************************************


	RETURN @rate_tableXML
	
END
GO