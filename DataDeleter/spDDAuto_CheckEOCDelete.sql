IF OBJECT_ID('dbo.spDDAuto_CheckEOCDelete') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDDAuto_CheckEOCDelete AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDDAuto_CheckEOCDelete
Purpose:    Delete data for a file loaded through the 837 Parse and Load process

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
01/19/2021	DK				Added @internal_delete for deleting at the time the file is being created
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDDAuto_CheckEOCDelete '837P_EOB_INDONCH_1_1_01_HPSQA11809_20200527_1.edi'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDDAuto_CheckEOCDelete
     (@filename			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Create temporary tables to be used to gather data
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Claim') IS NOT NULL
	DROP TABLE #Claim

CREATE TABLE #Claim
      (claim_number		VARCHAR(50)
	  ,line_number		INT
	  ,date_submitted	DATETIME)

IF OBJECT_ID('tempdb.dbo.#Claim_Sid') IS NOT NULL
	DROP TABLE #Claim_Sid

CREATE TABLE #Claim_Sid
      (claim_sid		INT)

IF OBJECT_ID('tempdb.dbo.#eoc') IS NOT NULL
	DROP TABLE #eoc

CREATE TABLE #eoc (
    eoc_gid     int
)

IF OBJECT_ID('tempdb.dbo.#Claim_Count') IS NOT NULL
	DROP TABLE #Claim_Count

CREATE TABLE #Claim_Count
      (table_name	VARCHAR(255)
	  ,records		INT)

--*************************************************************************************************
-- Populate tables that will be used to determine if there are any EOC records
--*************************************************************************************************
INSERT INTO #Claim  
      (claim_number
	  ,line_number
	  ,date_submitted)
SELECT CD.claim_number
      ,CD.line_number
	  ,CD.date_submitted
  FROM dbo.Claims_Detail_V2		CD
 WHERE CD.file_sid IN (SELECT FRL.file_sid
                         FROM File_Receive_Log	FRL
						WHERE FRL.file_name		= @filename)

INSERT INTO #Claim_Sid
      (claim_sid)
SELECT CL.claim_sid
  FROM #Claim				C
  JOIN dbo.Claims_Log_V2	CL
    ON C.claim_number		= CL.claim_number

INSERT INTO #eoc 
      (eoc_gid)
SELECT DISTINCT 
       CLX.eoc_gid
  FROM dbo.EOC_To_Claim_Line_Xref	CLX 
  JOIN #Claim_Sid					CS
    ON CLX.claim_sid				= CS.claim_sid

INSERT INTO #Claim_Count
      (table_name
	  ,records)
SELECT 'EOC_Table'
      ,COUNT(*)
  FROM dbo.EOC_Table	ET
  JOIN #eoc				E
    ON ET.eoc_gid		= E.eoc_gid

--*************************************************************************************************
-- Check to see if there are EOC records and EOC Delete Data is chosen
--*************************************************************************************************
IF (SELECT records FROM #Claim_Count WHERE table_name = 'EOC_Table') > 0
	BEGIN
		SELECT 'Yes' AS EOC_Records
	END
ELSE
	BEGIN
		SELECT 'No' AS EOC_Records
	END

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Claim') IS NOT NULL
	DROP TABLE #Claim

IF OBJECT_ID('tempdb.dbo.#Claim_Sid') IS NOT NULL
	DROP TABLE #Claim_Sid

IF OBJECT_ID('Tempdb.dbo.#eoc') IS NOT NULL
	DROP TABLE #eoc

IF OBJECT_ID('tempdb.dbo.#Claim_Count') IS NOT NULL
	DROP TABLE #Claim_Count

END
GO