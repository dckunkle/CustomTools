/**************************************************************************************************
Name:       spDCAuto_CreateTimelyFilingMatrix
Purpose:    Create timelyfilingmatrix data from CorderAutomation

Screen:     7021
Method:     TimelyFilingMatrix
Procedure:  dbo.prTimelyFilingMatrix_AddModify
Entity:     Timely_Filing

Date        User            Change
---------------------------------------------------------------------------------------------
02/10/2021	DK				Original procedure
09/21/2022	DK				Provider TIN added SP52
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTimelyFilingMatrix 'RFF-Config-2%', 99999, 'RFF-Config-2001','TimelyFilingMatrix','RFFConfig2001'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateTimelyFilingMatrix
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

DECLARE @i_Entity_name      VARCHAR(50)
       ,@i_key_1_field      VARCHAR(50)
       ,@i_key_2_field      VARCHAR(100)
       ,@i_key_3_field      VARCHAR(100)
       ,@i_key_4_field      VARCHAR(100)
       ,@i_key_5_field      VARCHAR(100)
       ,@i_key_6_field      VARCHAR(100)
       ,@i_key_7_field      VARCHAR(100)
       ,@i_key_8_field      VARCHAR(100)
       ,@i_key_9_field      VARCHAR(100)
       ,@i_key_10_field     VARCHAR(100)
       ,@iAction            VARCHAR(100)
       ,@iModifiedDate      VARCHAR(100)
       ,@iUserID            VARCHAR(100)
       ,@iEffectiveDate     VARCHAR(100)
       ,@iTerminationDate   VARCHAR(100)
       ,@iGroupID           VARCHAR(50)
       ,@iGroupName         VARCHAR(100)
       ,@iSystemLOB         VARCHAR(100)
       ,@iCustomLOB         VARCHAR(100)
       ,@iContractState     VARCHAR(100)
       ,@iClassCode         VARCHAR(100)
       ,@iProviderState     VARCHAR(100)
       ,@iAffiliationID     VARCHAR(100)
       ,@iNetworkID         VARCHAR(100)
       ,@iNetworkDesc       VARCHAR(100)
       ,@iBusinessID        VARCHAR(100)
       ,@iBusinessName      VARCHAR(100)
       ,@iLocationID        VARCHAR(50)
       ,@iLocationInfo      VARCHAR(100)
       ,@iProviderTin       VARCHAR(50)
       ,@iProviderTaxStatus VARCHAR(50)
       ,@iNetworkVariation  VARCHAR(50)
       ,@iFormType          VARCHAR(50)
       ,@iAssignmentCode    VARCHAR(50)
       ,@iCleanClaimSubDays VARCHAR(50)
       ,@iTimeBasis         VARCHAR(50)
       ,@iTimeUnits         VARCHAR(50)
       ,@iCalcBasis         VARCHAR(50)
       ,@iSvcOption         VARCHAR(50)
       ,@iRemarkCode        VARCHAR(50)
       ,@iRemarkDesc        VARCHAR(1000)
       ,@oStatus            INT
       ,@oMessage           VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TimelyFilingMatrix') IS NOT NULL
	DROP TABLE #TimelyFilingMatrix

CREATE TABLE #TimelyFilingMatrix
      (SearchID           VARCHAR(200)
      ,i_Entity_name      VARCHAR(50)       DEFAULT('Timely_Filing')
      ,i_key_1_field      VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_3_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_4_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_5_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_6_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_7_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_8_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_9_field      VARCHAR(100)       DEFAULT('0')
      ,i_key_10_field     VARCHAR(100)       DEFAULT('0')
      ,iAction            VARCHAR(100)       DEFAULT('ADD')
      ,iModifiedDate      VARCHAR(100)       DEFAULT('')
      ,iUserID            VARCHAR(100)       DEFAULT('')
      ,iEffectiveDate     VARCHAR(100)
      ,iTerminationDate   VARCHAR(100)
      ,iGroupID           VARCHAR(50)
      ,iGroupName         VARCHAR(100)
      ,iSystemLOB         VARCHAR(100)
      ,iCustomLOB         VARCHAR(100)
      ,iContractState     VARCHAR(100)
      ,iClassCode         VARCHAR(100)
      ,iProviderState     VARCHAR(100)
      ,iAffiliationID     VARCHAR(100)
      ,iNetworkID         VARCHAR(100)
      ,iNetworkDesc       VARCHAR(100)
      ,iBusinessID        VARCHAR(100)
      ,iBusinessName      VARCHAR(100)
      ,iLocationID        VARCHAR(50)
      ,iLocationInfo      VARCHAR(100)
      ,iProviderTin       VARCHAR(50)
      ,iProviderTaxStatus VARCHAR(50)
      ,iNetworkVariation  VARCHAR(50)
      ,iFormType          VARCHAR(50)
      ,iAssignmentCode    VARCHAR(50)
      ,iCleanClaimSubDays VARCHAR(50)
      ,iTimeBasis         VARCHAR(50)
      ,iTimeUnits         VARCHAR(50)
      ,iCalcBasis         VARCHAR(50)
      ,iSvcOption         VARCHAR(50)
      ,iRemarkCode        VARCHAR(50)
      ,iRemarkDesc        VARCHAR(1000)
      ,oStatus            INT
      ,oMessage           VARCHAR(100)
      ,record_id          INT
      ,static_gid         INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #TimelyFilingMatrix
          (SearchID
          ,iEffectiveDate
          ,iTerminationDate
          ,iGroupID
          ,iSystemLOB
          ,iCustomLOB
          ,iContractState
          ,iClassCode
          ,iProviderState
          ,iAffiliationID
          ,iNetworkID
          ,iBusinessID
          ,iLocationID
          ,iProviderTin
          ,iNetworkVariation
          ,iFormType
          ,iAssignmentCode
          ,iCleanClaimSubDays
          ,iTimeBasis
          ,iTimeUnits
          ,iCalcBasis
          ,iSvcOption
          ,iRemarkCode
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], '01/01/2001')
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([GroupID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SystemLOB]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '******')
          ,ISNULL([ContractState], '**')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContractClassCode]), '*')
          ,ISNULL([ProviderState], '**')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Affiliation]), '******')
          ,ISNULL([NetworkSearchID], '')
          ,ISNULL([BusinessUnitID], '')
          ,ISNULL([LocationID], '')
		  ,ISNULL([ProviderTaxID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClaimFormType]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AssignmentCode]), '*')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CleanClaimSubmissionDays]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ClaimSubmissionTimeBasis]), 'D')
          ,ISNULL([*NumberOfTimeUnits], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ClaimSubmissionCalcBasis]), 'D')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ServiceDateBasis]), 'F')
          ,ISNULL([RemarkCodeID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(static_gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_TimelyFilingMatrix
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #TimelyFilingMatrix
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
DECLARE TimelyFilingMatrix_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_key_1_field
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iEffectiveDate
       ,iTerminationDate
       ,iGroupID
       ,iGroupName
       ,iSystemLOB
       ,iCustomLOB
       ,iContractState
       ,iClassCode
       ,iProviderState
       ,iAffiliationID
       ,iNetworkID
       ,iNetworkDesc
       ,iBusinessID
       ,iBusinessName
       ,iLocationID
       ,iLocationInfo
       ,iProviderTin
       ,iProviderTaxStatus
       ,iNetworkVariation
       ,iFormType
       ,iAssignmentCode
       ,iCleanClaimSubDays
       ,iTimeBasis
       ,iTimeUnits
       ,iCalcBasis
       ,iSvcOption
       ,iRemarkCode
       ,iRemarkDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #TimelyFilingMatrix

   OPEN TimelyFilingMatrix_Cursor
  FETCH NEXT FROM TimelyFilingMatrix_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_key_1_field
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iGroupID
       ,@iGroupName
       ,@iSystemLOB
       ,@iCustomLOB
       ,@iContractState
       ,@iClassCode
       ,@iProviderState
       ,@iAffiliationID
       ,@iNetworkID
       ,@iNetworkDesc
       ,@iBusinessID
       ,@iBusinessName
       ,@iLocationID
       ,@iLocationInfo
       ,@iProviderTin
       ,@iProviderTaxStatus
       ,@iNetworkVariation
       ,@iFormType
       ,@iAssignmentCode
       ,@iCleanClaimSubDays
       ,@iTimeBasis
       ,@iTimeUnits
       ,@iCalcBasis
       ,@iSvcOption
       ,@iRemarkCode
       ,@iRemarkDesc
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

			EXEC dbo.prTimelyFilingMatrix_AddModify
                 @i_Entity_name
                ,@i_key_1_field
                ,@i_key_2_field
                ,@i_key_3_field
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@iAction
                ,@iModifiedDate
                ,@iUserID
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iGroupID
                ,@iGroupName
                ,@iSystemLOB
                ,@iCustomLOB
                ,@iContractState
                ,@iClassCode
                ,@iProviderState
                ,@iAffiliationID
                ,@iNetworkID
                ,@iNetworkDesc
                ,@iBusinessID
                ,@iBusinessName
                ,@iLocationID
                ,@iLocationInfo
                ,@iProviderTin			-- SP52
                ,@iProviderTaxStatus	-- SP52
                ,@iNetworkVariation
                ,@iFormType
                ,@iAssignmentCode
                ,@iCleanClaimSubDays
                ,@iTimeBasis
                ,@iTimeUnits
                ,@iCalcBasis
                ,@iSvcOption
                ,@iRemarkCode
                ,@iRemarkDesc
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iGroupID, @iEffectiveDate, @iTimeUnits, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM TimelyFilingMatrix_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_key_1_field
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iGroupID
             ,@iGroupName
             ,@iSystemLOB
             ,@iCustomLOB
             ,@iContractState
             ,@iClassCode
             ,@iProviderState
             ,@iAffiliationID
             ,@iNetworkID
             ,@iNetworkDesc
             ,@iBusinessID
             ,@iBusinessName
             ,@iLocationID
             ,@iLocationInfo
             ,@iProviderTin
             ,@iProviderTaxStatus
             ,@iNetworkVariation
             ,@iFormType
             ,@iAssignmentCode
             ,@iCleanClaimSubDays
             ,@iTimeBasis
             ,@iTimeUnits
             ,@iCalcBasis
             ,@iSvcOption
             ,@iRemarkCode
             ,@iRemarkDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE TimelyFilingMatrix_Cursor
DEALLOCATE TimelyFilingMatrix_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#TimelyFilingMatrix') IS NOT NULL
	DROP TABLE #TimelyFilingMatrix

END
GO

