IF OBJECT_ID('dbo.fnDCAuto_GetCoverageCodeXML') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetCoverageCodeXML() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetCoverageCodeXML
Purpose:    Extract the dropdown value from the dropdown description/value
            Ex. Medical(M) need to extract the M

Date        User            Change
---------------------------------------------------------------------------------------------
10/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetCoverageCodeXML
     (@i_coverage_codes	VARCHAR(200))

RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @coverageXML	VARCHAR(MAX) = ''
	       ,@missing_codes	INT
		   ,@code			VARCHAR(20)
		   ,@included		CHAR(1)

--*************************************************************************************************
-- Separate the delimited list of coverage codes into a table
--*************************************************************************************************
	DECLARE @coverage_codes			 TABLE (code VARCHAR(30))
	DECLARE @existing_coverage_codes TABLE (code VARCHAR(30),included CHAR(1) DEFAULT('N'))

	INSERT INTO @coverage_codes 
		  (code)
	SELECT token
	  FROM dbo.fnAuto_SplitTokens(@i_coverage_codes, ',')

--*************************************************************************************************
-- Build the XML necessary
--*************************************************************************************************
	INSERT INTO @existing_coverage_codes
	      (code)
	SELECT coverage_code
	  FROM Coverage_Codes
	 WHERE record_status	= 'A'

	--Verify that all the codes are actual Coverage Codes
	SELECT @missing_codes = COUNT(*)
	  FROM @coverage_codes					CC
	  LEFT JOIN @existing_coverage_codes	EC
	    ON CC.code							= EC.code
	 WHERE EC.code IS NULL
	 
	UPDATE EC
	   SET included					= 'Y'
	  FROM @coverage_codes			CC
	  JOIN @existing_coverage_codes	EC
	    ON CC.code					= EC.code

	 IF @missing_codes = 0
		BEGIN
			
			SET @coverageXML = '<DATA>'

			DECLARE Coverage_Code_Cursor CURSOR FOR
			SELECT code, included
			  FROM @existing_coverage_codes

			OPEN Coverage_Code_Cursor
			FETCH NEXT FROM Coverage_Code_Cursor
			 INTO @code, @included

			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @coverageXML = @coverageXML + '<Record CovCode="' + @code + '" Selected="' + @included + '" />'
					
					FETCH NEXT FROM Coverage_Code_Cursor
					 INTO @code, @included
				END

			CLOSE Coverage_Code_Cursor
			DEALLOCATE Coverage_Code_Cursor

			SET @coverageXML = @coverageXML + '</DATA>'

		END
	 ELSE
		BEGIN
			SET @coverageXML = 'One or more coverage codes have not been configured.'
		END

	RETURN @coverageXML
	
END
GO