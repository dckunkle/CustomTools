IF OBJECT_ID('dbo.spDCAuto_CreateTypeofBill') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateTypeofBill AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateTypeofBill
Purpose:    Create typeofbill data from CorderAutomation
Method:     TypeofBill
Screen GID: 230
Procedure:  dbo.prTypeOfBillAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/01/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateTypeofBill '100-Config%', 22, 'TypeofBill'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateTypeofBill
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

DECLARE @iEntity           VARCHAR(50)
       ,@iTypeOfBillKey    VARCHAR(50)
       ,@iKeyField2        VARCHAR(20)
       ,@iKeyField3        VARCHAR(20)
       ,@iKeyField4        VARCHAR(20)
       ,@iKeyField5        VARCHAR(50)
       ,@iKeyField6        VARCHAR(50)
       ,@iKeyField7        VARCHAR(50)
       ,@iKeyField8        VARCHAR(50)
       ,@iKeyField9        VARCHAR(50)
       ,@iKeyField10       VARCHAR(50)
       ,@iAction           VARCHAR(10)
       ,@iDateModified     VARCHAR(50)
       ,@iUserID           VARCHAR(25)
       ,@iTypeOfBillCode   VARCHAR(20)
       ,@iTypeOfBillDesc   VARCHAR(125)
       ,@iInpatient        CHAR(1)
       ,@iRequireAttending CHAR(1)
       ,@iPOSCodeXRef      VARCHAR(2)
       ,@iPOSCodeDesc      VARCHAR(50)
       ,@oStatus           INT
       ,@oMessage          VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#TypeofBill') IS NOT NULL
	DROP TABLE #TypeofBill

CREATE TABLE #TypeofBill
      (iEntity           VARCHAR(50)       DEFAULT('Type_Of_Bill')
      ,iTypeOfBillKey    VARCHAR(50)       DEFAULT('0')
      ,iKeyField2        VARCHAR(20)       DEFAULT('0')
      ,iKeyField3        VARCHAR(20)       DEFAULT('0')
      ,iKeyField4        VARCHAR(20)       DEFAULT('0')
      ,iKeyField5        VARCHAR(50)       DEFAULT('0')
      ,iKeyField6        VARCHAR(50)       DEFAULT('0')
      ,iKeyField7        VARCHAR(50)       DEFAULT('0')
      ,iKeyField8        VARCHAR(50)       DEFAULT('0')
      ,iKeyField9        VARCHAR(50)       DEFAULT('0')
      ,iKeyField10       VARCHAR(50)       DEFAULT('0')
      ,iAction           VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified     VARCHAR(50)       DEFAULT('')
      ,iUserID           VARCHAR(25)       DEFAULT('')
      ,iTypeOfBillCode   VARCHAR(20)
      ,iTypeOfBillDesc   VARCHAR(125)
      ,iInpatient        VARCHAR(50)
      ,iRequireAttending VARCHAR(50)
      ,iPOSCodeXRef      VARCHAR(2)
      ,iPOSCodeDesc      VARCHAR(50)
      ,oStatus           INT
      ,oMessage          VARCHAR(250)
      ,record_id         INT
      ,static_gid        INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #TypeofBill
      (iTypeOfBillCode
      ,iTypeOfBillDesc
      ,iInpatient
      ,iRequireAttending
      ,iPOSCodeXRef
      ,record_id
      ,static_gid)
SELECT ISNULL([*Code], '')
      ,ISNULL([Description], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*IsInpatient]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*RequiresAttendingPhysician]), 'N')
      ,ISNULL([POSCodeXref], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_TypeOfBill
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #TypeofBill
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE TypeofBill_Cursor CURSOR FOR
 SELECT iEntity
       ,iTypeOfBillKey
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
       ,iTypeOfBillCode
       ,iTypeOfBillDesc
       ,iInpatient
       ,iRequireAttending
       ,iPOSCodeXRef
       ,iPOSCodeDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #TypeofBill

   OPEN TypeofBill_Cursor
  FETCH NEXT FROM TypeofBill_Cursor
   INTO @iEntity
       ,@iTypeOfBillKey
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
       ,@iTypeOfBillCode
       ,@iTypeOfBillDesc
       ,@iInpatient
       ,@iRequireAttending
       ,@iPOSCodeXRef
       ,@iPOSCodeDesc
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prTypeOfBillAddModify
             @iEntity
            ,@iTypeOfBillKey
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
            ,@iTypeOfBillCode
            ,@iTypeOfBillDesc
            ,@iInpatient
            ,@iRequireAttending
            ,@iPOSCodeXRef
            ,@iPOSCodeDesc
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iTypeOfBillCode, @iTypeOfBillDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM TypeofBill_Cursor
         INTO @iEntity
             ,@iTypeOfBillKey
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
             ,@iTypeOfBillCode
             ,@iTypeOfBillDesc
             ,@iInpatient
             ,@iRequireAttending
             ,@iPOSCodeXRef
             ,@iPOSCodeDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE TypeofBill_Cursor
DEALLOCATE TypeofBill_Cursor

END
GO