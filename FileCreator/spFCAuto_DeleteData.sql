IF OBJECT_ID('dbo.spFCAuto_DeleteData') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spFCAuto_DeleteData AS SELECT 1')
GO
/**************************************************************************************************
Name:       spFCAuto_DeleteData
Purpose:    Determine if any data needs to be deleted prior to creating the file(s) through
            the File Creator

Date        User            Change
---------------------------------------------------------------------------------------------
07/30/2020	DK				Original procedure
11/11/2020	DK				Added custom delete for Member Adjustment Amount
02/05/2021	DK				Added safeguard for Core environments
04/03/2023  DK				Added custom delete for Scondary Demographics
05/30/2023	DK				Added custom delete for Risk Scores
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spFCAuto_DeleteData 'aldqrdb09','EB-IMM-Member-SearchMemberUpdateDetails%', 'Yes', 'dkunkle@evolent.com','999','Junk'
***************************************************************************************************/
ALTER PROCEDURE dbo.spFCAuto_DeleteData
     (@i_server_name	VARCHAR(200)
	 ,@i_test_case		VARCHAR(200)
	 ,@delete_data		VARCHAR(10)
	 ,@email_address	VARCHAR(200)	= ''
	 ,@build_id		    INT				= 0
	 ,@job_name			VARCHAR(200)	= '')
AS
BEGIN

SET NOCOUNT ON

DECLARE @err_num				INT
       ,@err_msg				VARCHAR(8000)
	   ,@data_deleted			BIT				= 0
	   ,@delete_type			VARCHAR(200)
	   ,@delete_name			VARCHAR(200)
	   ,@custom_delete_found	BIT				= 0
	   ,@skip_delete			BIT
	   ,@log_id					INT
	   ,@type_id				INT
	   ,@today					DATETIME		= GETDATE()

SELECT @skip_delete		= CASE WHEN LEFT(@i_server_name, 6) = 'alddev' THEN 1 ELSE 0 END
      ,@i_server_name	= RTRIM(@i_server_name)
	  ,@i_test_case		= RTRIM(@i_test_case)
	  ,@delete_data		= RTRIM(@delete_data)

--*************************************************************************************************
-- Begin logging data
--*************************************************************************************************
INSERT INTO FDLog
      (user_id
	  ,server_name
	  ,test_case
	  ,start_time
	  ,email_address
	  ,build_id
	  ,job_name)
SELECT SUSER_NAME()
	  ,@i_server_name
      ,@i_test_case
      ,GETDATE()
	  ,@email_address
	  ,@build_id
	  ,@job_name

SET @log_id = @@IDENTITY

--*******************************************************************************************************
-- Start Jenkins log ouptut for the deleter
--*******************************************************************************************************
PRINT ''
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ' DATA DELETER'
PRINT '------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT ''

IF (@delete_data = 'No') GOTO SKIP_DELETE

--*************************************************************************************************
-- Create a table to determine which test cases will be run
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Deletes') IS NOT NULL
	DROP TABLE #Deletes

CREATE TABLE #Deletes
      (delete_type		VARCHAR(200)
	  ,delete_name		VARCHAR(200))

--*************************************************************************************************
-- Create a table of all the deletes that need to happen for the test cases that will be run
--*************************************************************************************************
INSERT INTO #Deletes
      (delete_type
	  ,delete_name)
SELECT C.delete_type
	  ,C.delete_name
  FROM COREAUTO.CoreFileCreator.fw.TestCase			TC
  JOIN COREAUTO.CoreFileCreator.fw.TestCaseMethod	TCM
    ON TC.TestCaseName								= TCM.TestCaseName
  JOIN COREAUTO.CoreFileCreator.fw.Catalog			C
    ON TCM.Method_Name								= C.Method_Name
 WHERE TC.TestCaseName								LIKE @i_test_case
   AND ISNULL(C.delete_type, '')					<> ''
   AND TC.Status									= 'A'
   AND TCM.Status									= 'A'
 GROUP BY C.delete_type, C.delete_name

--*************************************************************************************************
-- Loop through all of the TD tables to find the test cases
--*************************************************************************************************
DECLARE DeleteFiles_Cursor CURSOR FOR
 SELECT delete_type
       ,delete_name
   FROM #Deletes

   OPEN DeleteFiles_Cursor
  FETCH NEXT FROM DeleteFiles_Cursor
   INTO @delete_type, @delete_name

	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spFDAuto_LogEvent @log_id, @delete_type, @delete_name, @delete_data, @type_id OUTPUT
			PRINT '        -Type-------Name----------------------Data---Table Name--------------------------------------------------Records------'
			PRINT '         ' + LEFT(@delete_type + SPACE(10), 10) + ' ' + LEFT(@delete_name + SPACE(25), 25) + ' ' + @delete_data

			IF @delete_type = 'Custom'
				BEGIN
							
					IF @delete_name = 'DeleteMemberImport'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustomMemberFiles @err_num OUTPUT, @err_msg OUTPUT, @type_id

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF @delete_name = 'Delete837Import'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustom837Files @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF @delete_name = 'Delete820Import'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustom820Files @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF (@delete_name = 'CONV_P1' AND @skip_delete <> 1)
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							IF @skip_delete = 0
								BEGIN
									EXEC spFCAuto_DeleteCustomCONV_P1 @err_num OUTPUT, @err_msg OUTPUT, @type_id
								END

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF @delete_name = 'DeleteLockbox'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustomLockboxFiles @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END
					
					IF @delete_name = 'DeleteInstamedLockbox'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustomInstamedLockboxFiles @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF @delete_name = 'DeleteVendorAccums'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC spFCAuto_DeleteCustomVendorAccums @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN PRINT '          Delete Error: ' + @err_msg END
						END

					IF @delete_name = 'DeleteSecondaryDemographics'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							EXEC COREAUTO.CoreFileCreator.dbo.spFCAuto_DeleteCustomSecondaryDemographics @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id, @i_server_name, @log_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN
									EXEC spFDAuto_LogTypeEvent @type_id, @today, '', 0, 'Error', @err_num, @err_msg 
								END
						END

					IF @delete_name = 'DeleteRiskScores'
						BEGIN
							SELECT @err_num = 0
							      ,@err_msg	= ''
								  ,@custom_delete_found = 1

							PRINT 'Risk'
							EXEC COREAUTO.CoreFileCreator.dbo.spFCAuto_DeleteCustomRiskScores @i_test_case, @err_num OUTPUT, @err_msg OUTPUT, @type_id, @i_server_name, @log_id
							SET @data_deleted = 1

							IF @err_num <> 0 
								BEGIN
									EXEC spFDAuto_LogTypeEvent @type_id, @today, '', 0, 'Error', @err_num, @err_msg 
								END
						END
					IF @custom_delete_found = 0 
						BEGIN
							PRINT 'Custom delete functionality has not been developed yet.'
						END
				END
			
			IF (@delete_type = 'User' AND @skip_delete <> 1)
				BEGIN

					-- Check to make sure the user is not a protected user and if the delete will happen on an approved server
					EXEC spFCAuto_DeleteDataValidate @delete_name, @err_num OUTPUT, @err_msg OUTPUT

					IF @err_num = 0 
						BEGIN

							EXEC spFCAuto_DeleteDataUser @delete_name, @data_deleted OUTPUT, @type_id

						END
					ELSE
						BEGIN PRINT '          Delete Error: ' + @err_msg END
					
				END

			-- If deleting has been disabled and this is not an 837 file show the following message
			IF (@skip_delete = 1 AND @custom_delete_found = 0)
				BEGIN
				    PRINT ' '
					PRINT '               Deleting file data has been disabled for this environment (alddev).'
					PRINT ' '
				END

			PRINT ''

			FETCH NEXT FROM DeleteFiles_Cursor
			 INTO @delete_type, @delete_name

		END

CLOSE DeleteFiles_Cursor
DEALLOCATE DeleteFiles_Cursor

--*******************************************************************************************************
-- If no data has been deleted then finish the Jenkins log
--*******************************************************************************************************
SKIP_DELETE:

IF @data_deleted = 0
	BEGIN

		IF @delete_data = 'No'
			BEGIN
				PRINT '        No data was deleted because the delete data flag was set to ''No'''
				PRINT ''
			END
		ELSE
			BEGIN
				PRINT '        No data was deleted'
				PRINT ''
			END

	END

PRINT '        ----------------------------------------------------------------------------------------------------------------------------------------'
PRINT ''

--*******************************************************************************************************
-- Complete the File Deleter log
--*******************************************************************************************************
UPDATE FDLog
   SET end_time		= GETDATE()
 WHERE log_id		= @log_id

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Deletes') IS NOT NULL
	DROP TABLE #Deletes
		
END
GO