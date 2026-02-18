IF OBJECT_ID('dbo.spDCAuto_CreateAffiliationDefinition') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAffiliationDefinition AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAffiliationDefinition
Purpose:    Create affiliationdefinition data from CorderAutomation
Method:     AffiliationDefinition
Screen GID: 450
Procedure:  dbo.prAffiliationDef_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/30/2019	DK				Original procedure
07/18/2022	DK				Stored procedure name change for SP51
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAffiliationDefinition '400-Config%', 22, '400-Configuration', 'AffiliationDefinition', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAffiliationDefinition
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntity        VARCHAR(50)
       ,@iKeyField1     VARCHAR(200)
       ,@iKeyField2     VARCHAR(50)
       ,@iKeyField3     VARCHAR(50)
       ,@iKeyField4     VARCHAR(50)
       ,@iKeyField5     VARCHAR(30)
       ,@iKeyField6     VARCHAR(30)
       ,@iKeyField7     VARCHAR(10)
       ,@iKeyField8     VARCHAR(50)
       ,@iKeyField9     VARCHAR(50)
       ,@iKeyField10    VARCHAR(50)
       ,@iAction        VARCHAR(10)
       ,@iDateModified  VARCHAR(30)
       ,@iUserID        VARCHAR(25)
       ,@iAff_ID        VARCHAR(50)
       ,@iAff_Desc      VARCHAR(50)
       ,@iProdType      VARCHAR(50)
       ,@iPcplevel      VARCHAR(100)
       ,@iPayType       VARCHAR(50)
       ,@iRosterMethod  VARCHAR(50)
       ,@iRosterDest    VARCHAR(50)
       ,@iNumCopies     INT
       ,@iCapId         VARCHAR(25)
       ,@iCapDesc       VARCHAR(100)
       ,@iSchedule_Id   VARCHAR(25)
       ,@iSchedule_Desc VARCHAR(100)
       ,@iAffGrouper    VARCHAR(50)
       ,@iRank          INT
       ,@oStatus        INT
       ,@oMessage       VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AffiliationDefinition') IS NOT NULL
	DROP TABLE #AffiliationDefinition

CREATE TABLE #AffiliationDefinition
      (iEntity        VARCHAR(50)       DEFAULT('AFFILIATION_DEF')
      ,iKeyField1     VARCHAR(200)      DEFAULT('0')
      ,iKeyField2     VARCHAR(50)       DEFAULT('0')
      ,iKeyField3     VARCHAR(50)       DEFAULT('0')
      ,iKeyField4     VARCHAR(50)       DEFAULT('0')
      ,iKeyField5     VARCHAR(30)       DEFAULT('0')
      ,iKeyField6     VARCHAR(30)       DEFAULT('0')
      ,iKeyField7     VARCHAR(10)       DEFAULT('0')
      ,iKeyField8     VARCHAR(50)       DEFAULT('0')
      ,iKeyField9     VARCHAR(50)       DEFAULT('0')
      ,iKeyField10    VARCHAR(50)       DEFAULT('0')
      ,iAction        VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified  VARCHAR(30)       DEFAULT('')
      ,iUserID        VARCHAR(25)       DEFAULT('')
      ,iAff_ID        VARCHAR(50)
      ,iAff_Desc      VARCHAR(50)
      ,iProdType      VARCHAR(50)
      ,iPcplevel      VARCHAR(100)
      ,iPayType       VARCHAR(50)
      ,iRosterMethod  VARCHAR(50)
      ,iRosterDest    VARCHAR(50)
      ,iNumCopies     INT
      ,iCapId         VARCHAR(25)
      ,iCapDesc       VARCHAR(100)
      ,iSchedule_Id   VARCHAR(25)
      ,iSchedule_Desc VARCHAR(100)
      ,iAffGrouper    VARCHAR(50)
      ,iRank          INT
      ,oStatus        INT
      ,oMessage       VARCHAR(250)
      ,record_id      INT
      ,static_gid     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AffiliationDefinition
      (iAff_ID
      ,iAff_Desc
      ,iProdType
      ,iPcplevel
      ,iPayType
      ,iRosterMethod
      ,iRosterDest
      ,iNumCopies
      ,iCapId
      ,iSchedule_Id
      ,iAffGrouper
      ,iRank
      ,record_id
      ,static_gid)
SELECT ISNULL([*AffiliationID], '')
      ,ISNULL([*AffiliationDesc], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ProductType]), 'F')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PCPAssignLevel]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CapitationPaymType]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RosterMethod]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RosterDestination]), 'U')
      ,ISNULL([NumberOfCopies], '0')
      ,ISNULL([DefaultCAPRateID], '')
      ,ISNULL([EncounterSchedID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AffiliationGrouper]), '')
      ,ISNULL([Rank], '999')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AffiliationDefinition
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AffiliationDefinition
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AffiliationDefinition_Cursor CURSOR FOR
 SELECT iEntity
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
       ,iDateModified
       ,iUserID
       ,iAff_ID
       ,iAff_Desc
       ,iProdType
       ,iPcplevel
       ,iPayType
       ,iRosterMethod
       ,iRosterDest
       ,iNumCopies
       ,iCapId
       ,iCapDesc
       ,iSchedule_Id
       ,iSchedule_Desc
       ,iAffGrouper
       ,iRank
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #AffiliationDefinition

   OPEN AffiliationDefinition_Cursor
  FETCH NEXT FROM AffiliationDefinition_Cursor
   INTO @iEntity
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
       ,@iDateModified
       ,@iUserID
       ,@iAff_ID
       ,@iAff_Desc
       ,@iProdType
       ,@iPcplevel
       ,@iPayType
       ,@iRosterMethod
       ,@iRosterDest
       ,@iNumCopies
       ,@iCapId
       ,@iCapDesc
       ,@iSchedule_Id
       ,@iSchedule_Desc
       ,@iAffGrouper
       ,@iRank
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prAffiliationDef_Add --SP51 prAffiliationDef_AddModify
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
            ,@iDateModified
            ,@iUserID
            ,@iAff_ID
            ,@iAff_Desc
            ,@iProdType
            ,@iPcplevel
            ,@iPayType
            ,@iRosterMethod
            ,@iRosterDest
            ,@iNumCopies
            ,@iCapId
            ,@iCapDesc
            ,@iSchedule_Id
            ,@iSchedule_Desc
            ,@iAffGrouper
            ,@iRank
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iAff_ID, @iAff_Desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM AffiliationDefinition_Cursor
         INTO @iEntity
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
             ,@iDateModified
             ,@iUserID
             ,@iAff_ID
             ,@iAff_Desc
             ,@iProdType
             ,@iPcplevel
             ,@iPayType
             ,@iRosterMethod
             ,@iRosterDest
             ,@iNumCopies
             ,@iCapId
             ,@iCapDesc
             ,@iSchedule_Id
             ,@iSchedule_Desc
             ,@iAffGrouper
             ,@iRank
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE AffiliationDefinition_Cursor
DEALLOCATE AffiliationDefinition_Cursor

END
GO