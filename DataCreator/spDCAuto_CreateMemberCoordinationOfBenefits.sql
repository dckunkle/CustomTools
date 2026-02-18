IF OBJECT_ID('dbo.spDCAuto_CreateMemberCoordinationOfBenefits') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMemberCoordinationOfBenefits AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMemberCoordinationOfBenefits
Purpose:    Create membercordinationofbenefits data from CorderAutomation
Method:     MemberCordinationOfBenefits
Screen GID: 701
Procedure:  dbo.prMemCOBAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
01/15/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberCoordinationOfBenefits '100-Config%', 22, 'MemberCordinationOfBenefits'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMemberCoordinationOfBenefits
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
	   ,@default_LOB				VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntity           VARCHAR(100)
       ,@iContactGID       VARCHAR(100)
       ,@iChildType        VARCHAR(100)
       ,@iParentGID        VARCHAR(100)
       ,@iParentType       VARCHAR(100)
       ,@iKeyEffDate       VARCHAR(100)
       ,@iKeyTermDate      VARCHAR(100)
       ,@iKeyCovFlag       VARCHAR(50)
       ,@iKeyField8        VARCHAR(100)
       ,@iKeySysLOB        VARCHAR(50)
       ,@iMemberID         VARCHAR(100)
       ,@iAction           VARCHAR(10)
       ,@iDateTimeModified VARCHAR(100)
       ,@iUserID           VARCHAR(100)
       ,@iEffDate          VARCHAR(100)
       ,@iTermDate         VARCHAR(50)
       ,@iSystemLOB        VARCHAR(50)
       ,@iUserLOB          VARCHAR(50)
       ,@iCovFlag          VARCHAR(50)
       ,@iDualFlag         VARCHAR(50)
       ,@iOtherCarrierID   VARCHAR(50)
       ,@iOtherCarrierName VARCHAR(50)
       ,@iOtherGroupID     VARCHAR(50)
       ,@iOtherGroupName   VARCHAR(50)
       ,@iOtherMemberID    VARCHAR(50)
       ,@iOtherFirstName   VARCHAR(50)
       ,@iOtherLastName    VARCHAR(60)
       ,@iOtherBirthDate   VARCHAR(50)
       ,@iChangeFamily     VARCHAR(50)
       ,@o_status          INT
       ,@o_message         VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberCordinationOfBenefits') IS NOT NULL
	DROP TABLE #MemberCordinationOfBenefits

CREATE TABLE #MemberCordinationOfBenefits
      (SearchID          VARCHAR(200)
      ,iEntity           VARCHAR(100)       DEFAULT('Member_COB_Sub')
      ,iContactGID       VARCHAR(100)       DEFAULT('0')
      ,iChildType        VARCHAR(100)       DEFAULT('0')
      ,iParentGID        VARCHAR(100)       DEFAULT('0')
      ,iParentType       VARCHAR(100)       DEFAULT('0')
      ,iKeyEffDate       VARCHAR(100)       DEFAULT('')
      ,iKeyTermDate      VARCHAR(100)       DEFAULT('')
      ,iKeyCovFlag       VARCHAR(50)        DEFAULT('0')
      ,iKeyField8        VARCHAR(100)       DEFAULT('0')
      ,iKeySysLOB        VARCHAR(50)        DEFAULT('0')
      ,iMemberID         VARCHAR(100)       DEFAULT('0')
      ,iAction           VARCHAR(10)        DEFAULT('ADD')
      ,iDateTimeModified VARCHAR(100)       DEFAULT('')
      ,iUserID           VARCHAR(100)       DEFAULT('')
      ,iEffDate          VARCHAR(100)
      ,iTermDate         VARCHAR(50)
      ,iSystemLOB        VARCHAR(50)
      ,iUserLOB          VARCHAR(50)
      ,iCovFlag          VARCHAR(50)
      ,iDualFlag         VARCHAR(50)
      ,iOtherCarrierID   VARCHAR(50)
      ,iOtherCarrierName VARCHAR(50)
      ,iOtherGroupID     VARCHAR(50)
      ,iOtherGroupName   VARCHAR(50)
      ,iOtherMemberID    VARCHAR(50)
      ,iOtherFirstName   VARCHAR(50)
      ,iOtherLastName    VARCHAR(60)
      ,iOtherBirthDate   VARCHAR(50)
      ,iChangeFamily     VARCHAR(50)
      ,o_status          INT
      ,o_message         VARCHAR(100)
      ,record_id         INT
      ,static_gid        INT)

IF OBJECT_ID('tempdb.dbo.#LOBs') IS NOT NULL
	DROP TABLE #LOBs

CREATE TABLE #LOBs
      (FieldNumber		VARCHAR(200)  
      ,Reference_Type 	VARCHAR(200)
      ,Short_Desc		VARCHAR(200)
      ,Description   	VARCHAR(200)
      ,Seq_Num			VARCHAR(200))  

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #MemberCordinationOfBenefits
      (SearchID
      ,iEffDate
      ,iTermDate
      ,iSystemLOB
      ,iUserLOB
      ,iCovFlag
      ,iDualFlag
      ,iOtherCarrierID
      ,iOtherGroupID
      ,iOtherMemberID
      ,iOtherFirstName
      ,iOtherLastName
      ,iOtherBirthDate
      ,iChangeFamily
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SystemLOB]), 'D')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*LOB]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*CoverageLayer]), '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*DualCoverage]), 'N')
      ,ISNULL([*OtherCarrierID], '')
      ,ISNULL([OtherGroupID], '')
      ,ISNULL([OtherMemberID], '')
      ,ISNULL([OtherMemberFirstName], '')
      ,ISNULL([OtherMemberLastName], '')
      ,ISNULL([OtherMemberBirthDate], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApplyCOBtoAllFamiMem]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_MemberCoordinationofBenefits
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #MemberCordinationOfBenefits
   SET iUserID  = @user

UPDATE #MemberCordinationOfBenefits
   SET iUserLOB = CASE WHEN iUserLOB = '<Key> TAB' THEN '' ELSE iUserLOB END

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE MemberCordinationOfBenefits_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iContactGID
       ,iChildType
       ,iParentGID
       ,iParentType
       ,iKeyEffDate
       ,iKeyTermDate
       ,iKeyCovFlag
       ,iKeyField8
       ,iKeySysLOB
       ,iMemberID
       ,iAction
       ,iDateTimeModified
       ,iUserID
       ,iEffDate
       ,iTermDate
       ,iSystemLOB
       ,iUserLOB
       ,iCovFlag
       ,iDualFlag
       ,iOtherCarrierID
       ,iOtherCarrierName
       ,iOtherGroupID
       ,iOtherGroupName
       ,iOtherMemberID
       ,iOtherFirstName
       ,iOtherLastName
       ,iOtherBirthDate
       ,iChangeFamily
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #MemberCordinationOfBenefits

   OPEN MemberCordinationOfBenefits_Cursor
  FETCH NEXT FROM MemberCordinationOfBenefits_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iContactGID
       ,@iChildType
       ,@iParentGID
       ,@iParentType
       ,@iKeyEffDate
       ,@iKeyTermDate
       ,@iKeyCovFlag
       ,@iKeyField8
       ,@iKeySysLOB
       ,@iMemberID
       ,@iAction
       ,@iDateTimeModified
       ,@iUserID
       ,@iEffDate
       ,@iTermDate
       ,@iSystemLOB
       ,@iUserLOB
       ,@iCovFlag
       ,@iDualFlag
       ,@iOtherCarrierID
       ,@iOtherCarrierName
       ,@iOtherGroupID
       ,@iOtherGroupName
       ,@iOtherMemberID
       ,@iOtherFirstName
       ,@iOtherLastName
       ,@iOtherBirthDate
       ,@iChangeFamily
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the member's GIDs
			SELECT @iContactGID				= EC.child_gid
			      ,@iChildType				= EC.child_identifier
				  ,@iParentGID				= EC.parent_gid
				  ,@iParentType				= EC.parent_identifier
				  ,@iMemberID				= EC.member_id
				  ,@default_LOB				= EC.default_lob
			  FROM Eligibility_Coverage		EC
			 WHERE EC.record_status			= 'A'
			   AND EC.member_id				= @SearchID
			   AND EC.child_gid				= EC.parent_gid

			-- Get the LOB as if the user pressed TAB on the screen
			TRUNCATE TABLE #LOBs
			  INSERT INTO #LOBs
			    EXEC prGroupVaryLOBCombo 'Member_COB_Sub', @iContactGID, @iChildType, @iParentGID, @iParentType, '', '', '', '', '', @iMemberID, 'ADD', '', '', 'COBLOB', '4',@default_LOB

			SELECT TOP 1
			       @iUserLOB	= L.Short_Desc
			  FROM #LOBs		L
			 ORDER BY Seq_Num

			-- Lookup the Other Carrier Name
			SELECT @iOtherCarrierName		= ISNULL(CI.other_carrier_name, '')
			  FROM Carrier_Information		CI
			 WHERE CI.other_carrier_code	= @iOtherCarrierID
			   AND CI.record_status			= 'A'

			EXEC dbo.prMemCOBAddModify
             @iEntity
            ,@iContactGID
            ,@iChildType
            ,@iParentGID
            ,@iParentType
            ,@iKeyEffDate
            ,@iKeyTermDate
            ,@iKeyCovFlag
            ,@iKeyField8
            ,@iKeySysLOB
            ,@iMemberID
            ,@iAction
            ,@iDateTimeModified
            ,@iUserID
            ,@iEffDate
            ,@iTermDate
            ,@iSystemLOB
            ,@iUserLOB
            ,@iCovFlag
            ,@iDualFlag
            ,@iOtherCarrierID
            ,@iOtherCarrierName
            ,@iOtherGroupID
            ,@iOtherGroupName
            ,@iOtherMemberID
            ,@iOtherFirstName
            ,@iOtherLastName
            ,@iOtherBirthDate
            ,@iChangeFamily
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iSystemLOB, @iUserLOB, @status, @err_num, @err_msg

        FETCH NEXT FROM MemberCordinationOfBenefits_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iContactGID
             ,@iChildType
             ,@iParentGID
             ,@iParentType
             ,@iKeyEffDate
             ,@iKeyTermDate
             ,@iKeyCovFlag
             ,@iKeyField8
             ,@iKeySysLOB
             ,@iMemberID
             ,@iAction
             ,@iDateTimeModified
             ,@iUserID
             ,@iEffDate
             ,@iTermDate
             ,@iSystemLOB
             ,@iUserLOB
             ,@iCovFlag
             ,@iDualFlag
             ,@iOtherCarrierID
             ,@iOtherCarrierName
             ,@iOtherGroupID
             ,@iOtherGroupName
             ,@iOtherMemberID
             ,@iOtherFirstName
             ,@iOtherLastName
             ,@iOtherBirthDate
             ,@iChangeFamily
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE MemberCordinationOfBenefits_Cursor
DEALLOCATE MemberCordinationOfBenefits_Cursor

END
GO