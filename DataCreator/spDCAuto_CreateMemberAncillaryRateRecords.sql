IF OBJECT_ID('dbo.spDCAuto_CreateMemberAncillaryRateRecords') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberAncillaryRateRecords AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberAncillaryRateRecords
Purpose:    Create memberancillaryraterecords data from CorderAutomation

Screen:     4102
Method:     MemberAncillaryRateRecords
Procedure:  dbo.prEligRateAncillary 
Entity:     EligRate_Ancillary

Date        User            Change
---------------------------------------------------------------------------------------------
01/08/2020	DK				Original procedure
01/15/2020	DK				Suppress warning about census records not being created before the cutoff
04/11/2022	DK				Rewrite using new format
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberAncillaryRateRecords 'Census-Config-20%', 22, 'Census-Config',  'MemberAncillaryRateRecords', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberAncillaryRateRecords
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
	   ,@member_id					VARCHAR(20)
	   ,@ssn						VARCHAR(50)
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_ChildGID           VARCHAR(50)
       ,@i_key_2_field        VARCHAR(50)
       ,@i_ParentGID          VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_RateEffectiveDate  VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_GroupGID           VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_LOB                VARCHAR(50)
       ,@i_ECAncillarySID     VARCHAR(50)
       ,@i_action             VARCHAR(50)
       ,@i_Date_Time_Modified VARCHAR(30)
       ,@iUserID              VARCHAR(50)
       ,@i_DefaultLOB         VARCHAR(50)
       ,@i_RateAmt            VARCHAR(50)
       ,@i_RateEffDate        VARCHAR(50)
       ,@i_RateTermDate       VARCHAR(50)
       ,@i_RateArea           VARCHAR(50)
       ,@i_RateAreaEff        VARCHAR(50)
       ,@i_TierCode           VARCHAR(50)
       ,@i_RateBlockEff       VARCHAR(50)
       ,@i_RateTableEff       VARCHAR(50)
       ,@i_RateGuartEff       VARCHAR(50)
       ,@i_RateGuartTerm      VARCHAR(50)
       ,@i_AgeRated           VARCHAR(50)
       ,@i_MaintCode          VARCHAR(50)
       ,@i_AgeCode            VARCHAR(50)
       ,@iEmployerAmnt        VARCHAR(50)
       ,@iEmployeeAmnt        VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(255)
       ,@i_DisplayResults     VARCHAR(50)
       ,@return_xml           XML
       ,@iProcessMassFull     BIT

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberAncillaryRateRecords') IS NOT NULL
	DROP TABLE #MemberAncillaryRateRecords

CREATE TABLE #MemberAncillaryRateRecords
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('EligRate_Ancillary')
      ,i_ChildGID           VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field        VARCHAR(50)       DEFAULT('0')
      ,i_ParentGID          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_RateEffectiveDate  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_GroupGID           VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_LOB                VARCHAR(50)       DEFAULT('0')
      ,i_ECAncillarySID     VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(50)       DEFAULT('ADD')
      ,i_Date_Time_Modified VARCHAR(30)       DEFAULT('')
      ,iUserID              VARCHAR(50)       DEFAULT('')
      ,i_DefaultLOB         VARCHAR(50)
      ,i_RateAmt            VARCHAR(50)
      ,i_RateEffDate        VARCHAR(50)
      ,i_RateTermDate       VARCHAR(50)
      ,i_RateArea           VARCHAR(50)
      ,i_RateAreaEff        VARCHAR(50)
      ,i_TierCode           VARCHAR(50)
      ,i_RateBlockEff       VARCHAR(50)
      ,i_RateTableEff       VARCHAR(50)
      ,i_RateGuartEff       VARCHAR(50)
      ,i_RateGuartTerm      VARCHAR(50)
      ,i_AgeRated           VARCHAR(50)
      ,i_MaintCode          VARCHAR(50)
      ,i_AgeCode            VARCHAR(50)
      ,iEmployerAmnt        VARCHAR(50)
      ,iEmployeeAmnt        VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(255)
      ,i_DisplayResults     VARCHAR(50)
      ,return_xml           XML
      ,iProcessMassFull     BIT
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #MemberAncillaryRateRecords
          (SearchID
          ,i_DefaultLOB
          ,i_RateAmt
          ,i_RateEffDate
          ,i_RateTermDate
          ,i_RateArea
          ,i_RateAreaEff
          ,i_TierCode
          ,i_RateBlockEff
          ,i_RateTableEff
          ,i_RateGuartEff
          ,i_RateGuartTerm
          ,i_AgeRated
          ,i_MaintCode
          ,i_AgeCode
          ,iEmployerAmnt
          ,iEmployeeAmnt
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LOB]), '')
		  ,ISNULL([RateAmt], '0.00')
		  ,ISNULL([EffDate], '')
		  ,ISNULL([TermDate], '12/31/9999')
		  ,ISNULL([RateArea], '')
		  ,ISNULL([RateAreaEffDate], '')
		  ,ISNULL([TierCode], '')
		  ,ISNULL([RateBlockEffDate], '')
		  ,ISNULL([RateTableEffDate], '')
		  ,ISNULL([RateGuaranteeEffDt], '')
		  ,ISNULL([RateGuaranteePerEndDt], '')
		  ,ISNULL([AgeRatedAt], '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MaintReasonCode]), '')
		  ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AgeCode]), '')
		  ,ISNULL([EmployerContrAmt], '0.00')
		  ,ISNULL([EmployeeContrAmt], '0.00')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_MemberAncillaryRates
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #MemberAncillaryRateRecords
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
DECLARE MemberAncillaryRateRecords_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_ChildGID
       ,i_key_2_field
       ,i_ParentGID
       ,i_key_4_field
       ,i_RateEffectiveDate
       ,i_key_6_field
       ,i_GroupGID
       ,i_key_8_field
       ,i_LOB
       ,i_ECAncillarySID
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,i_DefaultLOB
       ,i_RateAmt
       ,i_RateEffDate
       ,i_RateTermDate
       ,i_RateArea
       ,i_RateAreaEff
       ,i_TierCode
       ,i_RateBlockEff
       ,i_RateTableEff
       ,i_RateGuartEff
       ,i_RateGuartTerm
       ,i_AgeRated
       ,i_MaintCode
       ,i_AgeCode
       ,iEmployerAmnt
       ,iEmployeeAmnt
       ,o_status
       ,o_message
       ,i_DisplayResults
       ,return_xml
       ,iProcessMassFull
       ,record_id
       ,static_gid
   FROM #MemberAncillaryRateRecords

   OPEN MemberAncillaryRateRecords_Cursor
  FETCH NEXT FROM MemberAncillaryRateRecords_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_ChildGID
       ,@i_key_2_field
       ,@i_ParentGID
       ,@i_key_4_field
       ,@i_RateEffectiveDate
       ,@i_key_6_field
       ,@i_GroupGID
       ,@i_key_8_field
       ,@i_LOB
       ,@i_ECAncillarySID
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@i_DefaultLOB
       ,@i_RateAmt
       ,@i_RateEffDate
       ,@i_RateTermDate
       ,@i_RateArea
       ,@i_RateAreaEff
       ,@i_TierCode
       ,@i_RateBlockEff
       ,@i_RateTableEff
       ,@i_RateGuartEff
       ,@i_RateGuartTerm
       ,@i_AgeRated
       ,@i_MaintCode
       ,@i_AgeCode
       ,@iEmployerAmnt
       ,@iEmployeeAmnt
       ,@o_status
       ,@o_message
       ,@i_DisplayResults
       ,@return_xml
       ,@iProcessMassFull
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the child and parent gids for the member
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @member_id = token FROM #Tokens WHERE token_order = 1
			SELECT @ssn = token		  FROM #Tokens WHERE token_order = 2

			SELECT @i_ChildGID				= EC.child_gid
			      ,@i_ParentGID				= EC.parent_gid
				  ,@i_GroupGID				= EC.group_gid
			  FROM Eligibility_Coverage		EC
			  JOIN Contacts					C
			    ON EC.child_gid				= C.contact_gid
			 WHERE EC.record_status			= 'A'
			   AND C.record_status			= 'A'
			   AND EC.member_id				= @member_id
			   AND EC.child_identifier		= 'M'
			   AND EC.parent_identifier		= 'M'
			   AND C.actual_ssn				= @ssn
			   AND EC.default_lob			= @i_DefaultLOB

			IF @i_ChildGID > 0
				BEGIN

			EXEC dbo.prEligRateAncillary 
                 @i_entity_name
                ,@i_ChildGID
                ,@i_key_2_field
                ,@i_ParentGID
                ,@i_key_4_field
                ,@i_RateEffectiveDate
                ,@i_key_6_field
                ,@i_GroupGID
                ,@i_key_8_field
                ,@i_LOB
                ,@i_ECAncillarySID
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@i_DefaultLOB
                ,@i_RateAmt
                ,@i_RateEffDate
                ,@i_RateTermDate
                ,@i_RateArea
                ,@i_RateAreaEff
                ,@i_TierCode
                ,@i_RateBlockEff
                ,@i_RateTableEff
                ,@i_RateGuartEff
                ,@i_RateGuartTerm
                ,@i_AgeRated
                ,@i_MaintCode
                ,@i_AgeCode
                ,@iEmployerAmnt
                ,@iEmployeeAmnt
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT
				END
			ELSE
				BEGIN
					SELECT @err_num = 116
						  ,@err_msg	= 'The SearchID criteria did not match an existing member.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @member_id, @ssn, @i_RateAmt, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberAncillaryRateRecords_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_ChildGID
             ,@i_key_2_field
             ,@i_ParentGID
             ,@i_key_4_field
             ,@i_RateEffectiveDate
             ,@i_key_6_field
             ,@i_GroupGID
             ,@i_key_8_field
             ,@i_LOB
             ,@i_ECAncillarySID
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@i_DefaultLOB
             ,@i_RateAmt
             ,@i_RateEffDate
             ,@i_RateTermDate
             ,@i_RateArea
             ,@i_RateAreaEff
             ,@i_TierCode
             ,@i_RateBlockEff
             ,@i_RateTableEff
             ,@i_RateGuartEff
             ,@i_RateGuartTerm
             ,@i_AgeRated
             ,@i_MaintCode
             ,@i_AgeCode
             ,@iEmployerAmnt
             ,@iEmployeeAmnt
             ,@o_status
             ,@o_message
             ,@i_DisplayResults
             ,@return_xml
             ,@iProcessMassFull
             ,@record_id
             ,@static_gid
	END

CLOSE MemberAncillaryRateRecords_Cursor
DEALLOCATE MemberAncillaryRateRecords_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#MemberAncillaryRateRecords') IS NOT NULL
	DROP TABLE #MemberAncillaryRateRecords

END
GO

