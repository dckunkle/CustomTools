IF OBJECT_ID('dbo.spDCAuto_CreateRegionCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRegionCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRegionCodes
Purpose:    Create regioncodes data from CorderAutomation

Screen:     5052
Method:     RegionCodes
Procedure:  dbo.prRegionCodeDefinitionAddModify
Entity:     Region_Code_Definition

Date        User            Change
---------------------------------------------------------------------------------------------
03/19/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRegionCodes '100-Config%', 22, 'RegionCodes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRegionCodes
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

DECLARE @iEntity       VARCHAR(50)
       ,@iRegionGID    VARCHAR(100)
       ,@iKeyField2    VARCHAR(50)
       ,@iKeyField3    VARCHAR(50)
       ,@iKeyField4    VARCHAR(50)
       ,@iKeyField5    VARCHAR(50)
       ,@iKeyField6    VARCHAR(50)
       ,@iKeyField7    VARCHAR(50)
       ,@iKeyField8    VARCHAR(50)
       ,@iKeyField9    VARCHAR(50)
       ,@iKeyField10   VARCHAR(50)
       ,@iAction       VARCHAR(10)
       ,@iDateModified VARCHAR(50)
       ,@iUserID       VARCHAR(25)
       ,@iRegionCode   VARCHAR(50)
       ,@iRegionDesc   VARCHAR(50)
       ,@oStatus       INT
       ,@oMessage      VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RegionCodes') IS NOT NULL
	DROP TABLE #RegionCodes

CREATE TABLE #RegionCodes
      (SearchID      VARCHAR(200)
      ,iEntity       VARCHAR(50)       DEFAULT('Region_Code_Definition')
      ,iRegionGID    VARCHAR(100)       DEFAULT('0')
      ,iKeyField2    VARCHAR(50)       DEFAULT('0')
      ,iKeyField3    VARCHAR(50)       DEFAULT('0')
      ,iKeyField4    VARCHAR(50)       DEFAULT('0')
      ,iKeyField5    VARCHAR(50)       DEFAULT('0')
      ,iKeyField6    VARCHAR(50)       DEFAULT('0')
      ,iKeyField7    VARCHAR(50)       DEFAULT('0')
      ,iKeyField8    VARCHAR(50)       DEFAULT('0')
      ,iKeyField9    VARCHAR(50)       DEFAULT('0')
      ,iKeyField10   VARCHAR(50)       DEFAULT('0')
      ,iAction       VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified VARCHAR(50)       DEFAULT('')
      ,iUserID       VARCHAR(25)       DEFAULT('')
      ,iRegionCode   VARCHAR(50)
      ,iRegionDesc   VARCHAR(50)
      ,oStatus       INT
      ,oMessage      VARCHAR(250)
      ,record_id     INT
      ,static_gid    INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #RegionCodes
          (SearchID
          ,iRegionCode
          ,iRegionDesc
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*RegionCode], '')
          ,ISNULL([*RegionCodeDescription], '')
          ,ISNULL([RecordID], '')
		  ,gid
      FROM COREAUTO.CoreAutomation.dbo.TD_RegionCode
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #RegionCodes
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
DECLARE RegionCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iRegionGID
       ,iKeyField2
       ,iKeyField3
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iRegionCode
       ,iRegionDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #RegionCodes

   OPEN RegionCodes_Cursor
  FETCH NEXT FROM RegionCodes_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iRegionGID
       ,@iKeyField2
       ,@iKeyField3
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iRegionCode
       ,@iRegionDesc
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

			EXEC dbo.prRegionCodeDefinitionAddModify
                 @iEntity
                ,@iRegionGID
                ,@iKeyField2
                ,@iKeyField3
                ,@iKeyField4
                ,@iKeyField5
                ,@iKeyField6
                ,@iKeyField7
                ,@iKeyField8
                ,@iKeyField9
                ,@iKeyField10
                ,@iAction
                ,@iDateModified
                ,@iUserID
                ,@iRegionCode
                ,@iRegionDesc
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Region_Code_Definition 
				   SET region_gid			= @static_gid 
				 WHERE record_status		= 'A'
				   AND region_code			= @iRegionCode

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRegionCode, @iRegionDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM RegionCodes_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iRegionGID
             ,@iKeyField2
             ,@iKeyField3
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iRegionCode
             ,@iRegionDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE RegionCodes_Cursor
DEALLOCATE RegionCodes_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#RegionCodes') IS NOT NULL
	DROP TABLE #RegionCodes

END
GO

