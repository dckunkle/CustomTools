/**************************************************************************************************
Name:       spDCAuto_CreateCommissionProcessing
Purpose:    Create commissionprocessing data from CorderAutomation

Screen:     0
Method:     CommissionProcessing
Procedure:  dbo.prSetUpCommissionRun
Entity:     Commission

Date        User            Change
---------------------------------------------------------------------------------------------
08/29/2023	DK				Original procedure
09/14/2023	DK				Added Pause functionality
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCommissionProcessing '400-TestCase-300-LB%', 999, 'CommissionProcessing', 'CommissionProcessing','dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateCommissionProcessing
     (@i_pattern		VARCHAR(200)
	 ,@i_log_id			INT
	 ,@i_test_case_name	VARCHAR(200)
	 ,@i_method			VARCHAR(200)
	 ,@i_user			VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern					VARCHAR(200)
	   ,@log_id						INT
	   ,@test_case_name				VARCHAR(200)
	   ,@method						VARCHAR(200)
	   ,@user						VARCHAR(200)
	   ,@user_gid					INT

	   ,@record_id					INT
	   ,@gid						INT
	   ,@err_msg					VARCHAR(4000)
       ,@err_num					INT
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT
	   ,@SearchID					VARCHAR(200)

	   ,@seconds			VARCHAR(20)
	   ,@minutes			VARCHAR(20)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntityType     CHAR(1)
       ,@iEntityId       VARCHAR(50)
       ,@iClassCode      VARCHAR(1)
       ,@iFromDate       VARCHAR(10)
       ,@iToDate         VARCHAR(10)
       ,@iRunType        CHAR(1)
       ,@iProduceOutput  CHAR(1)
       ,@iUserID         VARCHAR(25)
       ,@i_user_gid      INT
       ,@oRunGid         INT
       ,@o_status        INT
       ,@o_message       VARCHAR(200)
       ,@oDisplayResults INT
       ,@iSpecialRun     INT
       ,@iProcessType    VARCHAR(50)
       ,@iDebug          INT
	   ,@iPause			 VARCHAR(100) 

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CommissionProcessing') IS NOT NULL
	DROP TABLE #CommissionProcessing

CREATE TABLE #CommissionProcessing
      (SearchID        VARCHAR(200)
      ,iEntityType     VARCHAR(50)
      ,iEntityId       VARCHAR(50)
      ,iClassCode      VARCHAR(50)
      ,iFromDate       VARCHAR(50)
      ,iToDate         VARCHAR(50)
      ,iRunType        VARCHAR(50)
      ,iProduceOutput  VARCHAR(50)
      ,iUserID         VARCHAR(50)
      ,i_user_gid      INT
      ,oRunGid         INT
      ,o_status        INT
      ,o_message       VARCHAR(200)
      ,oDisplayResults INT
      ,iSpecialRun     INT
      ,iProcessType    VARCHAR(50)
      ,iDebug          INT
	  ,iPause		   VARCHAR(20)
      ,record_id       INT
      ,static_gid      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #CommissionProcessing
          (SearchID
          ,iEntityType     
          ,iEntityId      
          ,iClassCode    
          ,iFromDate     
          ,iToDate       
          ,iRunType       
          ,iProduceOutput 
		  ,iPause
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,CASE WHEN ISNULL([Comm_Creation_EntityType], '') = 'Group' THEN 'G' 
				WHEN ISNULL([Comm_Creation_EntityType], '') = 'Member' THEN 'M' 
				ELSE '' 
			END
          ,ISNULL([Comm_Creation_EntityID], '')
          ,CASE WHEN ISNULL([Comm_Creation_ClassCode], 'All') = 'All' THEN 'A'
		        WHEN ISNULL([Comm_Creation_ClassCode], 'All') = 'Self Funded' THEN 'S'
				WHEN ISNULL([Comm_Creation_ClassCode], 'All') = 'Non-Self Funded' THEN 'N'
			END
          ,ISNULL([Comm_Creation_DateFrom], '')
          ,ISNULL([Comm_Creation_DateTo], '')
          ,CASE WHEN ISNULL([Comm_Creation_RunType], 'Mock') = 'Mock' THEN 'M'
		        WHEN ISNULL([Comm_Creation_RunType], 'Mock') = 'Production' THEN 'P'
			END
          ,CASE WHEN ISNULL([Comm_Creation_ProduceOutput], 'No') = 'No' THEN 'N'
		        WHEN ISNULL([Comm_Creation_ProduceOutput], 'No') = 'Yes' THEN 'Y'
			END
		  ,ISNULL(Pause, '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_CommissionProcessing
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'
	   AND ACTION			= 'CREATE_COMMISSION'				-- Excludes SEARCH actions

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
	SELECT @user_gid			= SU.User_GID		
	  FROM Security_Users		SU
	 WHERE SU.System_User_ID	= @user 

    UPDATE #CommissionProcessing
       SET iUserID				= @user
	      ,i_user_gid			= @user_gid

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CommissionProcessing_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityType
       ,iEntityId
       ,iClassCode
       ,iFromDate
       ,iToDate
       ,iRunType
       ,iProduceOutput
       ,iUserID
       ,i_user_gid
       ,oRunGid
       ,o_status
       ,o_message
       ,oDisplayResults
       ,iSpecialRun
       ,iProcessType
       ,iDebug
	   ,iPause
       ,record_id
       ,static_gid
   FROM #CommissionProcessing

   OPEN CommissionProcessing_Cursor
  FETCH NEXT FROM CommissionProcessing_Cursor
   INTO @SearchID
       ,@iEntityType
       ,@iEntityId
       ,@iClassCode
       ,@iFromDate
       ,@iToDate
       ,@iRunType
       ,@iProduceOutput
       ,@iUserID
       ,@i_user_gid
       ,@oRunGid
       ,@o_status
       ,@o_message
       ,@oDisplayResults
       ,@iSpecialRun
       ,@iProcessType
       ,@iDebug
	   ,@iPause
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			EXEC dbo.prSetUpCommissionRun
                 @iEntityType
                ,@iEntityId
                ,@iClassCode
                ,@iFromDate
                ,@iToDate
                ,@iRunType
                ,@iProduceOutput
                ,@iUserID
                ,@i_user_gid
                ,@oRunGid
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iEntityType, @iEntityId, @iRunType, @status, @err_num, @err_msg

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

        FETCH NEXT FROM CommissionProcessing_Cursor
         INTO @SearchID
             ,@iEntityType
             ,@iEntityId
             ,@iClassCode
             ,@iFromDate
             ,@iToDate
             ,@iRunType
             ,@iProduceOutput
             ,@iUserID
             ,@i_user_gid
             ,@oRunGid
             ,@o_status
             ,@o_message
             ,@oDisplayResults
             ,@iSpecialRun
             ,@iProcessType
             ,@iDebug
			 ,@iPause
             ,@record_id
             ,@static_gid
	END

CLOSE CommissionProcessing_Cursor
DEALLOCATE CommissionProcessing_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CommissionProcessing') IS NOT NULL
	DROP TABLE #CommissionProcessing

END
GO

