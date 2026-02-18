IF OBJECT_ID('dbo.spDCAuto_CreateSuperNetworkMatrix') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateSuperNetworkMatrix AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateSuperNetworkMatrix
Purpose:    Create supernetworkmatrix data from CorderAutomation

Screen:     11023
Method:     SuperNetworkMatrix
Procedure:  dbo.prSuperNetworkMatrixAddModify 
Entity:     SuperNetworkMatrix

Date        User            Change
---------------------------------------------------------------------------------------------
09/01/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateSuperNetworkMatrix '100-Config%', 22, 'SuperNetworkMatrix'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateSuperNetworkMatrix
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

DECLARE @iEntityName              VARCHAR(50)
       ,@iSuperNetworkMatrixGID   VARCHAR(75)
       ,@iSuperNetworkMatrixSID   VARCHAR(75)
       ,@iRecordKey3              VARCHAR(200)
       ,@iRecordKey4              VARCHAR(75)
       ,@iRecordKey5              VARCHAR(75)
       ,@iRecordKey6              VARCHAR(200)
       ,@iRecordKey7              VARCHAR(200)
       ,@iRecordKey8              VARCHAR(200)
       ,@iRecordKey9              VARCHAR(200)
       ,@iRecordKey10             VARCHAR(200)
       ,@iAction                  VARCHAR(10)
       ,@iDateTimeModified        VARCHAR(23)
       ,@iUserID                  VARCHAR(25)
       ,@iEffectiveDate           VARCHAR(50)
       ,@iTerminationDate         VARCHAR(50)
       ,@iSuperNetworkID          VARCHAR(50)
       ,@iSuperNetworkDescription VARCHAR(50)
       ,@iSuperNetworkSourceID    VARCHAR(50)
       ,@iSuperNetworkSourceValue VARCHAR(100)
       ,@oStatus                  INT
       ,@oMessage                 VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#SuperNetworkMatrix') IS NOT NULL
	DROP TABLE #SuperNetworkMatrix

CREATE TABLE #SuperNetworkMatrix
      (SearchID                 VARCHAR(200)
      ,iEntityName              VARCHAR(50)       DEFAULT('SuperNetworkMatrix')
      ,iSuperNetworkMatrixGID   VARCHAR(75)       DEFAULT('0')
      ,iSuperNetworkMatrixSID   VARCHAR(75)       DEFAULT('0')
      ,iRecordKey3              VARCHAR(200)      DEFAULT('0')
      ,iRecordKey4              VARCHAR(75)       DEFAULT('0')
      ,iRecordKey5              VARCHAR(75)       DEFAULT('0')
      ,iRecordKey6              VARCHAR(200)      DEFAULT('0')
      ,iRecordKey7              VARCHAR(200)      DEFAULT('0')
      ,iRecordKey8              VARCHAR(200)      DEFAULT('0')
      ,iRecordKey9              VARCHAR(200)      DEFAULT('0')
      ,iRecordKey10             VARCHAR(200)      DEFAULT('0')
      ,iAction                  VARCHAR(10)       DEFAULT('ADD')
      ,iDateTimeModified        VARCHAR(23)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,iEffectiveDate           VARCHAR(50)
      ,iTerminationDate         VARCHAR(50)
      ,iSuperNetworkID          VARCHAR(50)
      ,iSuperNetworkDescription VARCHAR(50)
      ,iSuperNetworkSourceID    VARCHAR(50)
      ,iSuperNetworkSourceValue VARCHAR(100)
      ,oStatus                  INT
      ,oMessage                 VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #SuperNetworkMatrix
          (SearchID
          ,iEffectiveDate
          ,iTerminationDate
          ,iSuperNetworkID
          ,iSuperNetworkSourceID
          ,iSuperNetworkSourceValue
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([*SuperNetworkID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SuperNetworkSourceID]), ' ')
          ,ISNULL([*SuperNetworkSourceValue], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_SuperNetworkMatrix
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #SuperNetworkMatrix
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
DECLARE SuperNetworkMatrix_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iSuperNetworkMatrixGID
       ,iSuperNetworkMatrixSID
       ,iRecordKey3
       ,iRecordKey4
       ,iRecordKey5
       ,iRecordKey6
       ,iRecordKey7
       ,iRecordKey8
       ,iRecordKey9
       ,iRecordKey10
       ,iAction
       ,iDateTimeModified
       ,iUserID
       ,iEffectiveDate
       ,iTerminationDate
       ,iSuperNetworkID
       ,iSuperNetworkDescription
       ,iSuperNetworkSourceID
       ,iSuperNetworkSourceValue
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #SuperNetworkMatrix

   OPEN SuperNetworkMatrix_Cursor
  FETCH NEXT FROM SuperNetworkMatrix_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iSuperNetworkMatrixGID
       ,@iSuperNetworkMatrixSID
       ,@iRecordKey3
       ,@iRecordKey4
       ,@iRecordKey5
       ,@iRecordKey6
       ,@iRecordKey7
       ,@iRecordKey8
       ,@iRecordKey9
       ,@iRecordKey10
       ,@iAction
       ,@iDateTimeModified
       ,@iUserID
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iSuperNetworkID
       ,@iSuperNetworkDescription
       ,@iSuperNetworkSourceID
       ,@iSuperNetworkSourceValue
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

			EXEC dbo.prSuperNetworkMatrixAddModify 
                 @iEntityName
                ,@iSuperNetworkMatrixGID
                ,@iSuperNetworkMatrixSID
                ,@iRecordKey3
                ,@iRecordKey4
                ,@iRecordKey5
                ,@iRecordKey6
                ,@iRecordKey7
                ,@iRecordKey8
                ,@iRecordKey9
                ,@iRecordKey10
                ,@iAction
                ,@iDateTimeModified
                ,@iUserID
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iSuperNetworkID
                ,@iSuperNetworkDescription
                ,@iSuperNetworkSourceID
                ,@iSuperNetworkSourceValue
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iSuperNetworkID, @iSuperNetworkSourceID, @iSuperNetworkSourceValue, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM SuperNetworkMatrix_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iSuperNetworkMatrixGID
             ,@iSuperNetworkMatrixSID
             ,@iRecordKey3
             ,@iRecordKey4
             ,@iRecordKey5
             ,@iRecordKey6
             ,@iRecordKey7
             ,@iRecordKey8
             ,@iRecordKey9
             ,@iRecordKey10
             ,@iAction
             ,@iDateTimeModified
             ,@iUserID
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iSuperNetworkID
             ,@iSuperNetworkDescription
             ,@iSuperNetworkSourceID
             ,@iSuperNetworkSourceValue
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE SuperNetworkMatrix_Cursor
DEALLOCATE SuperNetworkMatrix_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#SuperNetworkMatrix') IS NOT NULL
	DROP TABLE #SuperNetworkMatrix

END
GO

