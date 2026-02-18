IF OBJECT_ID('dbo.spDCAuto_CreatePCPAssignmentLimitationMatrix') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreatePCPAssignmentLimitationMatrix AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreatePCPAssignmentLimitationMatrix
Purpose:    Create pcpassignmentlimitationmatrix data from CorderAutomation

Screen:     8877
Method:     PCPAssignmentLimitationMatrix
Procedure:  dbo.prPCP_AssignmentLimitationMatrix_AddModify
Entity:     PCP_Assignment_Limitation_Matrix

Date        User            Change
---------------------------------------------------------------------------------------------
07/15/2020	DK				Original procedure
09/14/2020  DK				Added UI changes for SP42
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePCPAssignmentLimitationMatrix '100-Config%', 22, 'PCPAssignmentLimitationMatrix'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreatePCPAssignmentLimitationMatrix
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

	   ,@record_id					INT
	   ,@gid						INT
	   ,@err_msg					VARCHAR(4000)
       ,@err_num					INT
	   ,@status						VARCHAR(25)

	   ,@current_gid				INT
	   ,@static_gid					INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntityName                       VARCHAR(50)
       ,@iPcpAssignmentLimitationMatrixGID VARCHAR(50)
       ,@iKey2Field                        VARCHAR(20)
       ,@iKey3Field                        VARCHAR(50)
       ,@iKey4Field                        VARCHAR(50)
       ,@iKey5Field                        VARCHAR(50)
       ,@iKey6Field                        VARCHAR(50)
       ,@iKey7Field                        VARCHAR(50)
       ,@iKey8Field                        VARCHAR(50)
       ,@iKey9Field                        VARCHAR(50)
       ,@iPcpAssignmentLimitationMatrixSID VARCHAR(50)
       ,@iAction                           VARCHAR(50)
       ,@iDateTimeModified                 VARCHAR(50)
       ,@iUserId                           VARCHAR(50)
       ,@iPCPLimitID                       VARCHAR(50)
       ,@iPCPLimitDesc                     VARCHAR(150)
       ,@iEffectiveDate                    DATE
       ,@iTerminationDate                  DATE
       ,@iMaxPanelCount                    INT
	   ,@iTaxID                            VARCHAR(50)  
	   ,@iDistributeBy                     INT  
       ,@iProviderID                       VARCHAR(60)
       ,@iProviderName                     VARCHAR(160)
       ,@iBusinessUnitID                   VARCHAR(50)
       ,@iBusinessName                     VARCHAR(160)
       ,@iLocationID                       VARCHAR(50)
       ,@iLocationName                     VARCHAR(100)
       ,@iGroupListID                      VARCHAR(50)
       ,@iGroupListDesc                    VARCHAR(100)
       ,@iLOBGrouperID                     VARCHAR(50)
       ,@iLOBGrouperDesc                   VARCHAR(100)
       ,@oStatus                           INT
       ,@oMessage                          VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PCPAssignmentLimitationMatrix') IS NOT NULL
	DROP TABLE #PCPAssignmentLimitationMatrix

CREATE TABLE #PCPAssignmentLimitationMatrix
      (SearchID                          VARCHAR(200)
      ,iEntityName                       VARCHAR(50)       DEFAULT('PCP_Assignment_Limitation_Matrix')
      ,iPcpAssignmentLimitationMatrixGID VARCHAR(50)       DEFAULT('0')
      ,iKey2Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey3Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey4Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey5Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey6Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey7Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey8Field                        VARCHAR(50)       DEFAULT('0')
      ,iKey9Field                        VARCHAR(50)       DEFAULT('0')
      ,iPcpAssignmentLimitationMatrixSID VARCHAR(50)       DEFAULT('0')
      ,iAction                           VARCHAR(50)       DEFAULT('ADD')
      ,iDateTimeModified                 VARCHAR(50)       DEFAULT('')
      ,iUserId                           VARCHAR(50)       DEFAULT('')
      ,iPCPLimitID                       VARCHAR(50)
      ,iPCPLimitDesc                     VARCHAR(150)
      ,iEffectiveDate                    DATE
      ,iTerminationDate                  DATE
      ,iMaxPanelCount                    INT
	  ,iTaxID                            VARCHAR(50)	-- SP42  
	  ,iDistributeBy                     INT			-- SP42
      ,iProviderID                       VARCHAR(60)
      ,iProviderName                     VARCHAR(160)
      ,iBusinessUnitID                   VARCHAR(50)
      ,iBusinessName                     VARCHAR(160)
      ,iLocationID                       VARCHAR(50)
      ,iLocationName                     VARCHAR(100)
      ,iGroupListID                      VARCHAR(50)
      ,iGroupListDesc                    VARCHAR(100)
      ,iLOBGrouperID                     VARCHAR(50)
      ,iLOBGrouperDesc                   VARCHAR(100)
      ,oStatus                           INT
      ,oMessage                          VARCHAR(255)
      ,record_id                         INT
      ,static_gid                        INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #PCPAssignmentLimitationMatrix
          (SearchID
          ,iPCPLimitID
          ,iPCPLimitDesc
          ,iEffectiveDate
          ,iTerminationDate
          ,iMaxPanelCount
		  ,iTaxID 
		  ,iDistributeBy
          ,iProviderID
          ,iBusinessUnitID
          ,iLocationID
          ,iGroupListID
          ,iLOBGrouperID
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*PCPLimitID], '')
          ,ISNULL([*PCPLimitDesc], '')
          ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([*MaxPanelCount], '0')
		  ,ISNULL([TaxID], '')
		  ,ISNULL([DistributeBy], '0')
          ,ISNULL([ProviderID], '')
          ,ISNULL([BusinessUnitID], '')
          ,ISNULL([LocationID], '')
          ,ISNULL([GroupListID], '')
          ,ISNULL([LOBGrouperID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_PcpAssignmentLimitationMatrix
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #PCPAssignmentLimitationMatrix
       SET iUserID  = @user


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
DECLARE PCPAssignmentLimitationMatrix_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iPcpAssignmentLimitationMatrixGID
       ,iKey2Field
       ,iKey3Field
       ,iKey4Field
       ,iKey5Field
       ,iKey6Field
       ,iKey7Field
       ,iKey8Field
       ,iKey9Field
       ,iPcpAssignmentLimitationMatrixSID
       ,iAction
       ,iDateTimeModified
       ,iUserId
       ,iPCPLimitID
       ,iPCPLimitDesc
       ,iEffectiveDate
       ,iTerminationDate
       ,iMaxPanelCount
	   ,iTaxID 
	   ,iDistributeBy
       ,iProviderID
       ,iProviderName
       ,iBusinessUnitID
       ,iBusinessName
       ,iLocationID
       ,iLocationName
       ,iGroupListID
       ,iGroupListDesc
       ,iLOBGrouperID
       ,iLOBGrouperDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #PCPAssignmentLimitationMatrix

   OPEN PCPAssignmentLimitationMatrix_Cursor
  FETCH NEXT FROM PCPAssignmentLimitationMatrix_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iPcpAssignmentLimitationMatrixGID
       ,@iKey2Field
       ,@iKey3Field
       ,@iKey4Field
       ,@iKey5Field
       ,@iKey6Field
       ,@iKey7Field
       ,@iKey8Field
       ,@iKey9Field
       ,@iPcpAssignmentLimitationMatrixSID
       ,@iAction
       ,@iDateTimeModified
       ,@iUserId
       ,@iPCPLimitID
       ,@iPCPLimitDesc
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iMaxPanelCount
	   ,@iTaxID 
	   ,@iDistributeBy
       ,@iProviderID
       ,@iProviderName
       ,@iBusinessUnitID
       ,@iBusinessName
       ,@iLocationID
       ,@iLocationName
       ,@iGroupListID
       ,@iGroupListDesc
       ,@iLOBGrouperID
       ,@iLOBGrouperDesc
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			EXEC dbo.prPCP_AssignmentLimitationMatrix_AddModify
                 @iEntityName
                ,@iPcpAssignmentLimitationMatrixGID
                ,@iKey2Field
                ,@iKey3Field
                ,@iKey4Field
                ,@iKey5Field
                ,@iKey6Field
                ,@iKey7Field
                ,@iKey8Field
                ,@iKey9Field
                ,@iPcpAssignmentLimitationMatrixSID
                ,@iAction
                ,@iDateTimeModified
                ,@iUserId
                ,@iPCPLimitID
                ,@iPCPLimitDesc
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iMaxPanelCount
				,@iTaxID 
				,@iDistributeBy
                ,@iProviderID
                ,@iProviderName
                ,@iBusinessUnitID
                ,@iBusinessName
                ,@iLocationID
                ,@iLocationName
                ,@iGroupListID
                ,@iGroupListDesc
                ,@iLOBGrouperID
                ,@iLOBGrouperDesc
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.SomeTable 
				   SET entity_gid				= @static_gid 
				 WHERE record_status			= 'A'

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Missing', '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM PCPAssignmentLimitationMatrix_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iPcpAssignmentLimitationMatrixGID
             ,@iKey2Field
             ,@iKey3Field
             ,@iKey4Field
             ,@iKey5Field
             ,@iKey6Field
             ,@iKey7Field
             ,@iKey8Field
             ,@iKey9Field
             ,@iPcpAssignmentLimitationMatrixSID
             ,@iAction
             ,@iDateTimeModified
             ,@iUserId
             ,@iPCPLimitID
             ,@iPCPLimitDesc
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iMaxPanelCount
			 ,@iTaxID 
			 ,@iDistributeBy
             ,@iProviderID
             ,@iProviderName
             ,@iBusinessUnitID
             ,@iBusinessName
             ,@iLocationID
             ,@iLocationName
             ,@iGroupListID
             ,@iGroupListDesc
             ,@iLOBGrouperID
             ,@iLOBGrouperDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE PCPAssignmentLimitationMatrix_Cursor
DEALLOCATE PCPAssignmentLimitationMatrix_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#PCPAssignmentLimitationMatrix') IS NOT NULL
	DROP TABLE #PCPAssignmentLimitationMatrix

END
GO

