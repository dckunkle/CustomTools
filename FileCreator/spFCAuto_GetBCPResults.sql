IF OBJECT_ID('dbo.spFCAuto_GetBCPResults') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_GetBCPResults AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_GetBCPResults
Purpose:    Used to export a file

Date        User            Change
---------------------------------------------------------------------------------------------
01/07/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_GetBCPResults 'Member-VFC%', 'ExportMemberFIles', 'MemberDateBasedAttributes', 'aldqrdb02', '12'
EXEC spFCAuto_GetBCPResults '100-Config%', 'ExportMemberFIles', 'SomeOtherFile', 'aldqrdb02', '22'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_GetBCPResults
     (@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(8000)	OUTPUT
	 ,@records			INT				OUTPUT)
AS
BEGIN
	
DECLARE @copied_records TABLE (records_copied	INT)
DECLARE @err_count		INT
       ,@copy_failed	BIT

SELECT @err_num			= 0
      ,@err_msg			= 'File created successfully.'
	  ,@records			= 0
	  ,@err_count		= 0
	  ,@copy_failed		= 0

--*************************************************************************************************
-- Determine if the copy was successful or not, ignore warnings
--*************************************************************************************************
SELECT @err_count = COUNT(*)
  FROM #cmd_results
 WHERE (results LIKE 'Error%'
   AND results NOT LIKE '%Warning%')

IF EXISTS(SELECT TOP 1 results FROM #cmd_results WHERE results = 'BCP copy out failed') 
	BEGIN SELECT @copy_failed = 1 END

IF (@err_count > 0) OR (@copy_failed = 1)
	BEGIN

		--Try to determine the error number and error message to report back
		SELECT @err_num = 100
		      ,@err_msg = (SELECT TOP 1 results FROM #cmd_results WHERE results LIKE 'Error%' ORDER BY result_id)
	END
ELSE
	BEGIN

		INSERT INTO @copied_records
			  (records_copied)
		SELECT CONVERT(INT, REPLACE(results, ' rows copied.',''))
		  FROM #cmd_results
		 WHERE results		LIKE '% rows copied.'
      
		SELECT @records = SUM(records_copied) 
		  FROM @copied_records

	END	
END
GO