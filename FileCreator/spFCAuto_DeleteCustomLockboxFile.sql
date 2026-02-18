IF OBJECT_ID('dbo.spFCAuto_DeleteCustomLockboxFile') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteCustomLockboxFile AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteCustomLockboxFile
Purpose:    Delete data that was loaded via a lockbox file

Date        User            Change
---------------------------------------------------------------------------------------------
03/05/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteCustomLockboxFile 'FC_Lockbox_LBX_TC1_20210309_141337.txt'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteCustomLockboxFile
     (@filename		VARCHAR(200)	
	 ,@err_num		INT				= 0		OUTPUT
	 ,@err_msg		VARCHAR(8000)	= ''	OUTPUT
	 ,@type_id		INT				= 999)
AS
BEGIN

SET NOCOUNT ON

DECLARE @table_name			VARCHAR(255)
	   ,@record_count		INT
	   ,@sql				VARCHAR(4000)
	   ,@file_sid			INT
	   ,@batch_gid			INT
	   ,@deposit_number		INT

--*************************************************************************************************
-- Get the file_sids that will need to be deleted
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#file_sids') IS NOT NULL
	DROP TABLE #file_sids

CREATE TABLE #file_sids
      (file_sid		INT)

INSERT INTO #file_sids
      (file_sid)
SELECT FRL.file_sid
  FROM File_Receive_Log	FRL
 WHERE FRL.file_name	= @filename
   AND FRL.file_type	= 'ELB'

--*************************************************************************************************
-- Get the corresponding parent batch ids
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#parent_batch_gids') IS NOT NULL
	DROP TABLE #parent_batch_gids

CREATE TABLE #parent_batch_gids
      (parent_batch_gid		INT
	  ,batch_number			VARCHAR(50)
	  ,parent_sid			INT)

INSERT INTO #parent_batch_gids 
      (parent_batch_gid
	  ,batch_number
	  ,parent_sid)
SELECT H.batch_gid
      ,H.batch_number
	  ,H.CR_Batch_Header_sid
  FROM #file_sids		F
      ,CR_Batch_Header	H
 WHERE H.batch_number	LIKE '%-' + CONVERT(VARCHAR(20), F.file_sid)

INSERT INTO #parent_batch_gids
      (parent_batch_gid
	  ,batch_number
	  ,parent_sid)
SELECT 0
      ,''
	  ,H.CR_Batch_Header_sid
  FROM #parent_batch_gids	P
  JOIN CR_Batch_Header		H
    ON P.parent_batch_gid	= H.parent_batch_gid

--*************************************************************************************************
-- Get the sub batch ids
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#sub_batch_gids') IS NOT NULL
	DROP TABLE #sub_batch_gids

CREATE TABLE #sub_batch_gids
      (batch_detail_gid		INT
	  ,sub_batch_gid		INT
	  ,parent_batch_gid		INT)

INSERT INTO #sub_batch_gids
      (batch_detail_gid
	  ,sub_batch_gid
	  ,parent_batch_gid)
SELECT D.batch_detail_gid
      ,H.batch_gid
      ,P.parent_batch_gid
  FROM CR_Batch_Header		H
  JOIN #parent_batch_gids	P
    ON H.parent_batch_gid	= P.parent_batch_gid
  JOIN CR_Batch_Detail		D
    ON D.batch_gid			= H.batch_gid

--*************************************************************************************************
-- Delete any Misc_Transaction records that were created
--*************************************************************************************************
-- TODO: Add code to delete MT records

--*************************************************************************************************
-- Delete any Workflow records that were created
--*************************************************************************************************
-- TODO: Add code to delete WF records

--*************************************************************************************************
-- Delete any Cash Receipt records that were created
--*************************************************************************************************
DELETE CRT
  FROM Cash_Receipt_Transaction		CRT
  JOIN #sub_batch_gids				SB
    ON CRT.batch_detail_gid			= SB.batch_detail_gid
 WHERE CRT.user_id_created			= 'Lockbox'

SET @record_count = @@ROWCOUNT

SET @table_name = 'Cash_Receipt_Transaction'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

--*************************************************************************************************
-- Delete the CR_Batch_Items records
--*************************************************************************************************
DELETE I
  FROM CR_Batch_Items		I
  JOIN #sub_batch_gids		S
    ON I.batch_detail_gid	= S.batch_detail_gid
 
SET @record_count = @@ROWCOUNT

SET @table_name = 'CR_Batch_Items'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

--*************************************************************************************************
-- Delete the CR_Batch_Detail records
--*************************************************************************************************
DELETE D
  FROM CR_Batch_Detail		D
  JOIN #sub_batch_gids		S
    ON D.batch_detail_gid	= S.batch_detail_gid

SET @record_count = @@ROWCOUNT

SET @table_name = 'CR_Batch_Detail'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

--*************************************************************************************************
-- Delete the CR_Batch_Header records
--*************************************************************************************************
DELETE H
  FROM CR_Batch_Header			H
  JOIN #parent_batch_gids		S
    ON H.CR_Batch_Header_sid	= S.parent_sid

SET @record_count = @@ROWCOUNT

SET @table_name = 'CR_Batch_Header'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

--*************************************************************************************************
-- Delete the File_Receive_Log_Details records
--*************************************************************************************************
DELETE FD
  FROM File_Receive_Log_Details	FD
  JOIN #file_sids				F
    ON FD.file_sid				= F.file_sid

SET @record_count = @@ROWCOUNT

SET @table_name = 'File_Receive_Log_Details'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts 'File_Receive_Log_Details', @record_count

--*************************************************************************************************
-- Delete the File_Receive_Log records
--*************************************************************************************************
DELETE FRL
  FROM File_Receive_Log		FRL
  JOIN #file_sids			F    
    ON FRL.file_sid			= F.file_sid

SET @record_count = @@ROWCOUNT

SET @table_name = 'File_Receive_Log'
EXEC spFDAuto_LogTypeEvent @type_id, @table_name, @record_count, 'Deleted', 0, ''
EXEC spFCAuto_DeleteDisplayCounts @table_name, @record_count

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

IF OBJECT_ID('tempdb.dbo.#file_sids') IS NOT NULL
	DROP TABLE #file_sids

IF OBJECT_ID('tempdb.dbo.#parent_batch_gids') IS NOT NULL
	DROP TABLE #parent_batch_gids

IF OBJECT_ID('tempdb.dbo.#sub_batch_gids') IS NOT NULL
	DROP TABLE #sub_batch_gids

END
GO