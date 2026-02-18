IF OBJECT_ID('dbo.fnAuto_SplitTokens') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAuto_SplitTokens() RETURNS TABLE RETURN SELECT Item=1')
GO
/**************************************************************************************************
Name:       fnAuto_SplitTokens
Purpose:    Separate a comma-delimited list of items 

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original function
---------------------------------------------------------------------------------------------

Ex.  SELECT token FROM dbo.fnAuto_SplitTokens('Dan,Fred,Jeff')
     SELECT Username FROM dbo.fnAuto_SplitTokens('Dan,')
***************************************************************************************************/
ALTER FUNCTION dbo.fnAuto_SplitTokens
(
   @List		NVARCHAR(MAX)
  ,@delimiter	CHAR(1)			= ','
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E42(N)       AS (SELECT 1 FROM E4 a, E2 b),
       cteTally(N)  AS (SELECT 0 UNION ALL SELECT TOP (DATALENGTH(ISNULL(@List,1))) 
                         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E42),
       cteStart(N1) AS (SELECT t.N+1 FROM cteTally t
                         WHERE (SUBSTRING(@List,t.N,1) = @delimiter OR t.N = 0))
  SELECT token = SUBSTRING(@List, s.N1, ISNULL(NULLIF(CHARINDEX(@delimiter,@List,s.N1),0)-s.N1,8000))
    FROM cteStart s;

GO