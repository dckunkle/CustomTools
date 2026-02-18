IF OBJECT_ID('dbo.spDCAuto_CreateDataImportJobs') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateDataImportJobs AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateDataImportJobs
Purpose:    Create dataimportjobs data from CorderAutomation

Screen:     0
Method:     DataImportJobs
Procedure:  dbo.prOnDemandJob
Entity:     

Date        User            Change
---------------------------------------------------------------------------------------------
03/01/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateDataImportJobs '100-Config%', 22, 'DataImportJobs'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateDataImportJobs
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern			VARCHAR(200)
	   ,@log_id				INT
	   ,@test_case_name		VARCHAR(200)
	   ,@method				VARCHAR(200)
	   ,@user				VARCHAR(200)

	   ,@record_id			INT
	   ,@gid				INT
	   ,@err_msg			VARCHAR(4000)
       ,@err_num			INT
	   ,@status				VARCHAR(25)

	   ,@current_gid		INT
	   ,@static_gid			INT
	   ,@SearchID			VARCHAR(200)

	   ,@seconds			VARCHAR(20)
	   ,@minutes			VARCHAR(20)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iJobName			VARCHAR(50)
       ,@iJobGID			INT
       ,@iInput1			VARCHAR(250)
       ,@iInput2			VARCHAR(250)
       ,@iInput3			VARCHAR(250)
       ,@iInput4			VARCHAR(250)
       ,@iInput5			VARCHAR(250)
       ,@iInput6			VARCHAR(250)
       ,@iInput7			VARCHAR(250)
       ,@iInput8			VARCHAR(250)
       ,@iInput9			VARCHAR(250)
       ,@iInput10			VARCHAR(250)
       ,@iInput11			VARCHAR(250)
       ,@iInput12			VARCHAR(250)
       ,@iInput13			VARCHAR(250)
       ,@iInput14			VARCHAR(250)
       ,@iInput15			VARCHAR(250)
       ,@iInput16			VARCHAR(250)
       ,@iInput17			VARCHAR(250)
       ,@iInput18			VARCHAR(250)
       ,@iInput19			VARCHAR(250)
       ,@iInput20			VARCHAR(250)
       ,@iNotificationAdd	VARCHAR(250)
       ,@iUserID			VARCHAR(50)
	   ,@iPause				VARCHAR(100)
       ,@o_status			INT
       ,@o_message			VARCHAR(255)
       ,@iDebug				VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#DataImportJobs') IS NOT NULL
	DROP TABLE #DataImportJobs

CREATE TABLE #DataImportJobs
      (SearchID         VARCHAR(200)
      ,iJobName         VARCHAR(50)			DEFAULT('')
      ,iJobGID          INT					DEFAULT('0')
      ,iInput1          VARCHAR(250)		DEFAULT('')
      ,iInput2          VARCHAR(250)		DEFAULT('')
      ,iInput3          VARCHAR(250)		DEFAULT('')
      ,iInput4          VARCHAR(250)		DEFAULT('')
      ,iInput5          VARCHAR(250)		DEFAULT('')
      ,iInput6          VARCHAR(250)		DEFAULT('')
      ,iInput7          VARCHAR(250)		DEFAULT('')
      ,iInput8          VARCHAR(250)		DEFAULT('')
      ,iInput9          VARCHAR(250)		DEFAULT('')
      ,iInput10         VARCHAR(250)		DEFAULT('')
      ,iInput11         VARCHAR(250)		DEFAULT('')
      ,iInput12         VARCHAR(250)		DEFAULT('')
      ,iInput13         VARCHAR(250)		DEFAULT('')
      ,iInput14         VARCHAR(250)		DEFAULT('')
      ,iInput15         VARCHAR(250)		DEFAULT('')
      ,iInput16         VARCHAR(250)		DEFAULT('')
      ,iInput17         VARCHAR(250)		DEFAULT('')
      ,iInput18         VARCHAR(250)		DEFAULT('')
      ,iInput19         VARCHAR(250)		DEFAULT('')
      ,iInput20         VARCHAR(250)		DEFAULT('')
      ,iNotificationAdd VARCHAR(250)		DEFAULT('')
	  ,iPause			VARCHAR(100)		DEFAULT('')
      ,iUserID          VARCHAR(50)			DEFAULT('')
      ,o_status         INT
      ,o_message        VARCHAR(255)
      ,iDebug           VARCHAR(50)
      ,record_id        INT
      ,static_gid       INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

IF OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL
	DROP TABLE #Results

CREATE TABLE #Results
	  (err_num		VARCHAR(200)
	  ,err_msg		VARCHAR(4000))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #DataImportJobs
          (SearchID
		  ,iJobName
		  ,iJobGID
          ,iNotificationAdd
		  ,iPause
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,X.process_id
		  ,X.process_gid
          ,ISNULL([NotificationEmail], '')
		  ,ISNULL([Pause], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_DataImportJobs DI
	 CROSS APPLY (SELECT BPM.process_id
	                    ,BPM.process_gid
	                FROM dbo.Batch_Process_Master	BPM
				   WHERE BPM.record_status			= 'A'
				     AND BPM.process_user_id		=  DI.JobType) X

     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #DataImportJobs
       SET iUserID  = @user


END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

PRINT ' '
--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE DataImportJobs_Cursor CURSOR FOR
 SELECT SearchID
       ,iJobName
       ,iJobGID
       ,iInput1
       ,iInput2
       ,iInput3
       ,iInput4
       ,iInput5
       ,iInput6
       ,iInput7
       ,iInput8
       ,iInput9
       ,iInput10
       ,iInput11
       ,iInput12
       ,iInput13
       ,iInput14
       ,iInput15
       ,iInput16
       ,iInput17
       ,iInput18
       ,iInput19
       ,iInput20
       ,iNotificationAdd
       ,iUserID
	   ,iPause
       ,o_status
       ,o_message
       ,iDebug
       ,record_id
       ,static_gid
   FROM #DataImportJobs

   OPEN DataImportJobs_Cursor
  FETCH NEXT FROM DataImportJobs_Cursor
   INTO @SearchID
       ,@iJobName
       ,@iJobGID
       ,@iInput1
       ,@iInput2
       ,@iInput3
       ,@iInput4
       ,@iInput5
       ,@iInput6
       ,@iInput7
       ,@iInput8
       ,@iInput9
       ,@iInput10
       ,@iInput11
       ,@iInput12
       ,@iInput13
       ,@iInput14
       ,@iInput15
       ,@iInput16
       ,@iInput17
       ,@iInput18
       ,@iInput19
       ,@iInput20
       ,@iNotificationAdd
       ,@iUserID
	   ,@iPause
       ,@o_status
       ,@o_message
       ,@iDebug
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			INSERT INTO #Results 
				  (err_num
			      ,err_msg)
			EXEC dbo.prOnDemandJob
                 @iJobName
                ,@iJobGID
                ,@iInput1
                ,@iInput2
                ,@iInput3
                ,@iInput4
                ,@iInput5
                ,@iInput6
                ,@iInput7
                ,@iInput8
                ,@iInput9
                ,@iInput10
                ,@iInput11
                ,@iInput12
                ,@iInput13
                ,@iInput14
                ,@iInput15
                ,@iInput16
                ,@iInput17
                ,@iInput18
                ,@iInput19
                ,@iInput20
                ,@iNotificationAdd
                ,@iUserID
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iJobName, '', '', @status, @err_num, @err_msg

		SELECT @seconds	= CASE WHEN RIGHT(@iPause, 1) = 'S' THEN RIGHT('00' + LEFT(@iPause, LEN(@iPause) -1), 2)
		                       ELSE '00' 
						   END
		      ,@minutes = CASE WHEN RIGHT(@iPause, 1) = 'M' THEN RIGHT('00' + LEFT(@iPause, LEN(@iPause) -1), 2)
		                       ELSE '00' 
						   END

		IF NOT(@seconds = '00' AND @minutes = '00')
			BEGIN

				IF @minutes = '00' BEGIN PRINT 'Waiting ' + @seconds + ' seconds, for file to process...' END
				ELSE BEGIN PRINT 'Waiting ' + @minutes + ' minutes and ' + @seconds + ' seconds, for file to process...' END

			END

		PRINT ' '
		SELECT @seconds = '00:00:' + @seconds + '.000'
		      ,@minutes	= '00:' + @minutes + ':00.000'

		-- Wait the specified amount of time
		WAITFOR DELAY @seconds
		WAITFOR DELAY @minutes

        FETCH NEXT FROM DataImportJobs_Cursor
         INTO @SearchID
             ,@iJobName
             ,@iJobGID
             ,@iInput1
             ,@iInput2
             ,@iInput3
             ,@iInput4
             ,@iInput5
             ,@iInput6
             ,@iInput7
             ,@iInput8
             ,@iInput9
             ,@iInput10
             ,@iInput11
             ,@iInput12
             ,@iInput13
             ,@iInput14
             ,@iInput15
             ,@iInput16
             ,@iInput17
             ,@iInput18
             ,@iInput19
             ,@iInput20
             ,@iNotificationAdd
             ,@iUserID
			 ,@iPause
             ,@o_status
             ,@o_message
             ,@iDebug
             ,@record_id
             ,@static_gid
	END

CLOSE DataImportJobs_Cursor
DEALLOCATE DataImportJobs_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#DataImportJobs') IS NOT NULL
	DROP TABLE #DataImportJobs

IF OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL
	DROP TABLE #Results

END
GO

