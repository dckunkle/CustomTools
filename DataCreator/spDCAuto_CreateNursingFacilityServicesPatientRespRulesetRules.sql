IF OBJECT_ID('dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRulesetRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRulesetRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateNursingFacilityServicesPatientRespRulesetRules
Purpose:    Create nursingfacilityservicespatientresprulesetrules data from CorderAutomation

Screen:     11017
Method:     NursingFacilityServicesPatientRespRulesetRules
Procedure:  dbo.prNursingFacServicesPatRespRuleAddModify
Entity:     NFS_PatRespRules

Date        User            Change
---------------------------------------------------------------------------------------------
09/14/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateNursingFacilityServicesPatientRespRulesetRules '100-Config%', 22, 'NursingFacilityServicesPatientRespRulesetRules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateNursingFacilityServicesPatientRespRulesetRules
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

DECLARE @iEntity                     VARCHAR(50)
       ,@iKeyField1                  VARCHAR(75)
       ,@iKeyField2                  VARCHAR(75)
       ,@iKeyField3                  VARCHAR(50)
       ,@iKeyField4                  VARCHAR(75)
       ,@iKeyField5                  VARCHAR(50)
       ,@iKeyField6                  VARCHAR(75)
       ,@iKeyField7                  VARCHAR(50)
       ,@iKeyField8                  VARCHAR(75)
       ,@iKeyField9                  VARCHAR(50)
       ,@iKeyField10                 VARCHAR(75)
       ,@iAction                     VARCHAR(50)
       ,@iDateTimeModified           VARCHAR(75)
       ,@iUserID                     VARCHAR(25)
       ,@iEffectiveDate              VARCHAR(75)
       ,@iTerminationDate            VARCHAR(50)
       ,@iRevCodeStart               VARCHAR(50)
       ,@iRevCodeStartDescription    VARCHAR(50)
       ,@iRevCodeEnd                 VARCHAR(50)
       ,@iRevCodeEndDescription      VARCHAR(50)
       ,@iRevCodeListID              VARCHAR(50)
       ,@iRevCodeListDescription     VARCHAR(500)
       ,@iTypeOfBillStart            VARCHAR(50)
       ,@iTypeOfBillStartDescription VARCHAR(125)
       ,@iTypeOfBillEnd              VARCHAR(50)
       ,@iTypeOfBillEndDescription   VARCHAR(125)
       ,@iTypeOfBillListID           VARCHAR(50)
       ,@iTypeOfBillListDescription  VARCHAR(500)
       ,@iRemarkCode                 VARCHAR(50)
       ,@iRemarkCodeDescription      VARCHAR(1000)
       ,@oStatus                     INT
       ,@oMessage                    VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#NursingFacilityServicesPatientRespRulesetRules') IS NOT NULL
	DROP TABLE #NursingFacilityServicesPatientRespRulesetRules

CREATE TABLE #NursingFacilityServicesPatientRespRulesetRules
      (SearchID                    VARCHAR(200)
      ,iEntity                     VARCHAR(50)       DEFAULT('NFS_PatRespRules')
      ,iKeyField1                  VARCHAR(75)       DEFAULT('0')
      ,iKeyField2                  VARCHAR(75)       DEFAULT('0')
      ,iKeyField3                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField4                  VARCHAR(75)       DEFAULT('0')
      ,iKeyField5                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField6                  VARCHAR(75)       DEFAULT('0')
      ,iKeyField7                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField8                  VARCHAR(75)       DEFAULT('0')
      ,iKeyField9                  VARCHAR(50)       DEFAULT('0')
      ,iKeyField10                 VARCHAR(75)       DEFAULT('0')
      ,iAction                     VARCHAR(50)       DEFAULT('ADD')
      ,iDateTimeModified           VARCHAR(75)       DEFAULT('')
      ,iUserID                     VARCHAR(25)       DEFAULT('')
      ,iEffectiveDate              VARCHAR(75)
      ,iTerminationDate            VARCHAR(50)
      ,iRevCodeStart               VARCHAR(50)
      ,iRevCodeStartDescription    VARCHAR(50)
      ,iRevCodeEnd                 VARCHAR(50)
      ,iRevCodeEndDescription      VARCHAR(50)
      ,iRevCodeListID              VARCHAR(50)
      ,iRevCodeListDescription     VARCHAR(500)
      ,iTypeOfBillStart            VARCHAR(50)
      ,iTypeOfBillStartDescription VARCHAR(125)
      ,iTypeOfBillEnd              VARCHAR(50)
      ,iTypeOfBillEndDescription   VARCHAR(125)
      ,iTypeOfBillListID           VARCHAR(50)
      ,iTypeOfBillListDescription  VARCHAR(500)
      ,iRemarkCode                 VARCHAR(50)
      ,iRemarkCodeDescription      VARCHAR(1000)
      ,oStatus                     INT
      ,oMessage                    VARCHAR(250)
      ,record_id                   INT
      ,static_gid                  INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #NursingFacilityServicesPatientRespRulesetRules
          (SearchID
          ,iEffectiveDate
          ,iTerminationDate
          ,iRevCodeStart
          ,iRevCodeEnd
          ,iRevCodeListID
          ,iTypeOfBillStart
          ,iTypeOfBillEnd
          ,iTypeOfBillListID
          ,iRemarkCode
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([REVCodeStart], '')
          ,ISNULL([REVCodeEnd], '')
          ,ISNULL([REVCodeListID], '')
          ,ISNULL([TypeOfBillStart], '')
          ,ISNULL([TypeOfBillEnd], '')
          ,ISNULL([TypeOfBillListID], '')
          ,ISNULL([RemarkCodeID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_NursFacServPatRespRulesetRules
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #NursingFacilityServicesPatientRespRulesetRules
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
DECLARE NursingFacilityServicesPatientRespRulesetRules_Cursor CURSOR FOR
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
       ,iEffectiveDate
       ,iTerminationDate
       ,iRevCodeStart
       ,iRevCodeStartDescription
       ,iRevCodeEnd
       ,iRevCodeEndDescription
       ,iRevCodeListID
       ,iRevCodeListDescription
       ,iTypeOfBillStart
       ,iTypeOfBillStartDescription
       ,iTypeOfBillEnd
       ,iTypeOfBillEndDescription
       ,iTypeOfBillListID
       ,iTypeOfBillListDescription
       ,iRemarkCode
       ,iRemarkCodeDescription
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #NursingFacilityServicesPatientRespRulesetRules

   OPEN NursingFacilityServicesPatientRespRulesetRules_Cursor
  FETCH NEXT FROM NursingFacilityServicesPatientRespRulesetRules_Cursor
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
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iRevCodeStart
       ,@iRevCodeStartDescription
       ,@iRevCodeEnd
       ,@iRevCodeEndDescription
       ,@iRevCodeListID
       ,@iRevCodeListDescription
       ,@iTypeOfBillStart
       ,@iTypeOfBillStartDescription
       ,@iTypeOfBillEnd
       ,@iTypeOfBillEndDescription
       ,@iTypeOfBillListID
       ,@iTypeOfBillListDescription
       ,@iRemarkCode
       ,@iRemarkCodeDescription
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

			SELECT @iKeyField1							= NF.NursingFacServicesPatRespRuleset_GID
			  FROM dbo.NursingFacServicesPatRespRuleset NF
			 WHERE NF.NursingFacServicesPatRespRulesetID = @SearchID
			   AND NF.record_status = 'A'

			EXEC dbo.prNursingFacServicesPatRespRuleAddModify
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
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iRevCodeStart
                ,@iRevCodeStartDescription
                ,@iRevCodeEnd
                ,@iRevCodeEndDescription
                ,@iRevCodeListID
                ,@iRevCodeListDescription
                ,@iTypeOfBillStart
                ,@iTypeOfBillStartDescription
                ,@iTypeOfBillEnd
                ,@iTypeOfBillEndDescription
                ,@iTypeOfBillListID
                ,@iTypeOfBillListDescription
                ,@iRemarkCode
                ,@iRemarkCodeDescription
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT


        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRevCodeListID, @iTypeOfBillListID, @iRemarkCode, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM NursingFacilityServicesPatientRespRulesetRules_Cursor
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
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iRevCodeStart
             ,@iRevCodeStartDescription
             ,@iRevCodeEnd
             ,@iRevCodeEndDescription
             ,@iRevCodeListID
             ,@iRevCodeListDescription
             ,@iTypeOfBillStart
             ,@iTypeOfBillStartDescription
             ,@iTypeOfBillEnd
             ,@iTypeOfBillEndDescription
             ,@iTypeOfBillListID
             ,@iTypeOfBillListDescription
             ,@iRemarkCode
             ,@iRemarkCodeDescription
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE NursingFacilityServicesPatientRespRulesetRules_Cursor
DEALLOCATE NursingFacilityServicesPatientRespRulesetRules_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#NursingFacilityServicesPatientRespRulesetRules') IS NOT NULL
	DROP TABLE #NursingFacilityServicesPatientRespRulesetRules

END
GO

