IF OBJECT_ID('dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRuleset') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRuleset AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateNursingFacilityServicesPatientRespRuleset
Purpose:    Create nursingfacilityservicespatientrespruleset data from CorderAutomation

Screen:     11018
Method:     NursingFacilityServicesPatientRespRuleset
Procedure:  dbo.prNursingFacServicesPatRespRulesetAddModify
Entity:     NFS_PatRespRuleset

Date        User            Change
---------------------------------------------------------------------------------------------
09/14/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateNursingFacilityServicesPatientRespRuleset '100-Config%', 22, 'NursingFacilityServicesPatientRespRuleset'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRuleset
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

DECLARE @iEntity                                      VARCHAR(50)
       ,@iKeyField1                                   VARCHAR(50)
       ,@iKeyField2                                   VARCHAR(50)
       ,@iKeyField3                                   VARCHAR(50)
       ,@iKeyField4                                   VARCHAR(50)
       ,@iKeyField5                                   VARCHAR(50)
       ,@iKeyField6                                   VARCHAR(50)
       ,@iKeyField7                                   VARCHAR(50)
       ,@iKeyField8                                   VARCHAR(50)
       ,@iKeyField9                                   VARCHAR(50)
       ,@iKeyField10                                  VARCHAR(50)
       ,@iAction                                      VARCHAR(50)
       ,@iDateTimeModified                            VARCHAR(50)
       ,@iUserID                                      VARCHAR(25)
       ,@iNursingFacServicesPatRespRulesetID          VARCHAR(50)
       ,@iNursingFacServicesPatRespRulesetDescription VARCHAR(500)
       ,@oStatus                                      INT
       ,@oMessage                                     VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#NursingFacilityServicesPatientRespRuleset') IS NOT NULL
	DROP TABLE #NursingFacilityServicesPatientRespRuleset

CREATE TABLE #NursingFacilityServicesPatientRespRuleset
      (SearchID                                     VARCHAR(200)
      ,iEntity                                      VARCHAR(50)       DEFAULT('NFS_PatRespRuleset')
      ,iKeyField1                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField2                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField3                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField4                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField5                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField6                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField7                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField8                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField9                                   VARCHAR(50)       DEFAULT('0')
      ,iKeyField10                                  VARCHAR(50)       DEFAULT('0')
      ,iAction                                      VARCHAR(50)       DEFAULT('ADD')
      ,iDateTimeModified                            VARCHAR(50)       DEFAULT('')
      ,iUserID                                      VARCHAR(25)       DEFAULT('')
      ,iNursingFacServicesPatRespRulesetID          VARCHAR(50)
      ,iNursingFacServicesPatRespRulesetDescription VARCHAR(500)
      ,oStatus                                      INT
      ,oMessage                                     VARCHAR(250)
      ,record_id                                    INT
      ,static_gid                                   INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #NursingFacilityServicesPatientRespRuleset
          (SearchID
          ,iNursingFacServicesPatRespRulesetID
          ,iNursingFacServicesPatRespRulesetDescription
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*RulesetID], '')
          ,ISNULL([*RulesetDesc], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_NursFacServPatRespRuleset
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #NursingFacilityServicesPatientRespRuleset
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
DECLARE NursingFacilityServicesPatientRespRuleset_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iKeyField1
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
       ,iDateTimeModified
       ,iUserID
       ,iNursingFacServicesPatRespRulesetID
       ,iNursingFacServicesPatRespRulesetDescription
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #NursingFacilityServicesPatientRespRuleset

   OPEN NursingFacilityServicesPatientRespRuleset_Cursor
  FETCH NEXT FROM NursingFacilityServicesPatientRespRuleset_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iKeyField1
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
       ,@iDateTimeModified
       ,@iUserID
       ,@iNursingFacServicesPatRespRulesetID
       ,@iNursingFacServicesPatRespRulesetDescription
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

			EXEC dbo.prNursingFacServicesPatRespRulesetAddModify
                 @iEntity
                ,@iKeyField1
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
                ,@iDateTimeModified
                ,@iUserID
                ,@iNursingFacServicesPatRespRulesetID
                ,@iNursingFacServicesPatRespRulesetDescription
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.NursingFacServicesPatRespRuleset 
				   SET NursingFacServicesPatRespRuleset_GID	= @static_gid 
				 WHERE record_status						= 'A'
				   AND NursingFacServicesPatRespRulesetID	= @iNursingFacServicesPatRespRulesetID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iNursingFacServicesPatRespRulesetID, @iNursingFacServicesPatRespRulesetDescription, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM NursingFacilityServicesPatientRespRuleset_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iKeyField1
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
             ,@iDateTimeModified
             ,@iUserID
             ,@iNursingFacServicesPatRespRulesetID
             ,@iNursingFacServicesPatRespRulesetDescription
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE NursingFacilityServicesPatientRespRuleset_Cursor
DEALLOCATE NursingFacilityServicesPatientRespRuleset_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#NursingFacilityServicesPatientRespRuleset') IS NOT NULL
	DROP TABLE #NursingFacilityServicesPatientRespRuleset

END
GO

