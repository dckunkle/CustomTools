IF OBJECT_ID('dbo.spDCAuto_CreateMemberSuperNetworkAssignment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberSuperNetworkAssignment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberSuperNetworkAssignment
Purpose:    Create membersupernetworkassignment data from CorderAutomation

Screen:     2400
Method:     MemberSuperNetworkAssignment
Procedure:  dbo.prMemberSuperNetworkAssignmentAddModify
Entity:     MemberSuperNetworkAssign

Date        User            Change
---------------------------------------------------------------------------------------------
08/26/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberSuperNetworkAssignment '700-TestCase-221%', 22,'700-TestCase-221-025', 'MemberSuperNetworkAssignment', '700-221'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberSuperNetworkAssignment
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

	   ,@ssn						VARCHAR(50)
	   ,@lob						VARCHAR(50)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntityName                     VARCHAR(50)
       ,@iKeyChildGID                    VARCHAR(50)
       ,@iKeyParentGID                   VARCHAR(50)
       ,@iKeyGroupGID                    VARCHAR(75)
       ,@iKeyEffDate                     VARCHAR(75)
       ,@iKeyTermDate                    VARCHAR(75)
       ,@iKeyDefaultLOB                  VARCHAR(75)
       ,@iKeyMemberSuperNetworkAssignSID VARCHAR(50)
       ,@i_key_8_field                   VARCHAR(50)
       ,@i_key_9_field                   VARCHAR(50)
       ,@iKeyMemberID                    VARCHAR(50)
       ,@i_action                        VARCHAR(10)
       ,@i_Date_Time_Modified            VARCHAR(30)
       ,@iUserID                         VARCHAR(25)
       ,@iDefaultLOB                     VARCHAR(50)
       ,@iEffDate                        VARCHAR(50)
       ,@iTermDate                       VARCHAR(50)
       ,@iSuperNetworkSourceID           VARCHAR(50)
       ,@iSuperNetworkSourceValue        VARCHAR(100)
       ,@iSuperNetworkID                 VARCHAR(50)
       ,@iSuperNetworkDesc               VARCHAR(150)
       ,@oStatus                         INT
       ,@oMessage                        VARCHAR(150)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberSuperNetworkAssignment') IS NOT NULL
	DROP TABLE #MemberSuperNetworkAssignment

CREATE TABLE #MemberSuperNetworkAssignment
      (SearchID                        VARCHAR(200)
      ,iEntityName                     VARCHAR(50)       DEFAULT('MemberSuperNetworkAssign')
      ,iKeyChildGID                    VARCHAR(50)       DEFAULT('0')
      ,iKeyParentGID                   VARCHAR(50)       DEFAULT('0')
      ,iKeyGroupGID                    VARCHAR(75)       DEFAULT('0')
      ,iKeyEffDate                     VARCHAR(75)       DEFAULT('')
      ,iKeyTermDate                    VARCHAR(75)       DEFAULT('')
      ,iKeyDefaultLOB                  VARCHAR(75)       DEFAULT('0')
      ,iKeyMemberSuperNetworkAssignSID VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                   VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                   VARCHAR(50)       DEFAULT('0')
      ,iKeyMemberID                    VARCHAR(50)       DEFAULT('0')
      ,i_action                        VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified            VARCHAR(30)       DEFAULT('')
      ,iUserID                         VARCHAR(25)       DEFAULT('')
      ,iDefaultLOB                     VARCHAR(50)
      ,iEffDate                        VARCHAR(50)
      ,iTermDate                       VARCHAR(50)
      ,iSuperNetworkSourceID           VARCHAR(50)
      ,iSuperNetworkSourceValue        VARCHAR(100)
      ,iSuperNetworkID                 VARCHAR(50)
      ,iSuperNetworkDesc               VARCHAR(150)
      ,oStatus                         INT
      ,oMessage                        VARCHAR(150)
      ,record_id                       INT
      ,static_gid                      INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #MemberSuperNetworkAssignment
          (SearchID
          ,iEffDate
          ,iTermDate
          ,iSuperNetworkSourceID
          ,iSuperNetworkSourceValue
          ,iSuperNetworkID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([SuperNetworkSourceID]), '')
          ,ISNULL([SuperNetworkSourceValue], '')
          ,ISNULL([SuperNetworkID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_MemberSuperNetworkAssignment
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #MemberSuperNetworkAssignment
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
DECLARE MemberSuperNetworkAssignment_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iKeyChildGID
       ,iKeyParentGID
       ,iKeyGroupGID
       ,iKeyEffDate
       ,iKeyTermDate
       ,iKeyDefaultLOB
       ,iKeyMemberSuperNetworkAssignSID
       ,i_key_8_field
       ,i_key_9_field
       ,iKeyMemberID
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,iDefaultLOB
       ,iEffDate
       ,iTermDate
       ,iSuperNetworkSourceID
       ,iSuperNetworkSourceValue
       ,iSuperNetworkID
       ,iSuperNetworkDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #MemberSuperNetworkAssignment

   OPEN MemberSuperNetworkAssignment_Cursor
  FETCH NEXT FROM MemberSuperNetworkAssignment_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iKeyChildGID
       ,@iKeyParentGID
       ,@iKeyGroupGID
       ,@iKeyEffDate
       ,@iKeyTermDate
       ,@iKeyDefaultLOB
       ,@iKeyMemberSuperNetworkAssignSID
       ,@i_key_8_field
       ,@i_key_9_field
       ,@iKeyMemberID
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@iDefaultLOB
       ,@iEffDate
       ,@iTermDate
       ,@iSuperNetworkSourceID
       ,@iSuperNetworkSourceValue
       ,@iSuperNetworkID
       ,@iSuperNetworkDesc
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the child and parent gids for the member
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @lob		= token FROM #Tokens WHERE token_order = 2
			SELECT @ssn		= token	FROM #Tokens WHERE token_order = 1

			-- Assuming a new LOB is being added, strip off the literal LOB
			IF LEFT(@lob, 4) = 'LOB:' SET @lob = RTRIM(LTRIM(SUBSTRING(@lob,5,9999)))

			SELECT @iKeyChildGID			= EC.child_gid
			      ,@iKeyParentGID			= EC.parent_gid
				  ,@iKeyGroupGID			= EC.group_gid
				  ,@iKeyMemberID			= EC.member_id
				  ,@iDefaultLOB				= EC.default_lob
				  ,@iKeyDefaultLOB			= EC.default_lob
			  FROM Eligibility_Coverage		EC
			  JOIN Contacts					C
			    ON EC.child_gid				= C.contact_gid
			 WHERE EC.record_status			= 'A'
			   AND C.record_status			= 'A'
			   AND EC.child_identifier		= 'M'
			   AND EC.parent_identifier		= 'M'
			   AND C.actual_ssn				= @ssn
			   AND EC.default_lob			= @lob

			EXEC dbo.prMemberSuperNetworkAssignmentAddModify
                 @iEntityName
                ,@iKeyChildGID
                ,@iKeyParentGID
                ,@iKeyGroupGID
                ,@iKeyEffDate
                ,@iKeyTermDate
                ,@iKeyDefaultLOB
                ,@iKeyMemberSuperNetworkAssignSID
                ,@i_key_8_field
                ,@i_key_9_field
                ,@iKeyMemberID
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@iDefaultLOB
                ,@iEffDate
                ,@iTermDate
                ,@iSuperNetworkSourceID
                ,@iSuperNetworkSourceValue
                ,@iSuperNetworkID
                ,@iSuperNetworkDesc
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iKeyMemberID, @iSuperNetworkID, @iDefaultLOB, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberSuperNetworkAssignment_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iKeyChildGID
             ,@iKeyParentGID
             ,@iKeyGroupGID
             ,@iKeyEffDate
             ,@iKeyTermDate
             ,@iKeyDefaultLOB
             ,@iKeyMemberSuperNetworkAssignSID
             ,@i_key_8_field
             ,@i_key_9_field
             ,@iKeyMemberID
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@iDefaultLOB
             ,@iEffDate
             ,@iTermDate
             ,@iSuperNetworkSourceID
             ,@iSuperNetworkSourceValue
             ,@iSuperNetworkID
             ,@iSuperNetworkDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE MemberSuperNetworkAssignment_Cursor
DEALLOCATE MemberSuperNetworkAssignment_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#MemberSuperNetworkAssignment') IS NOT NULL
	DROP TABLE #MemberSuperNetworkAssignment

END
GO

