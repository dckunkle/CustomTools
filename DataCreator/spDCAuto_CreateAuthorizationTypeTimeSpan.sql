IF OBJECT_ID('dbo.spDCAuto_CreateAuthorizationTypeTimeSpan') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAuthorizationTypeTimeSpan AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAuthorizationTypeTimeSpan
Purpose:    Create authorizationtypetimespan data from CorderAutomation
Method:     AuthorizationTypeTimeSpan
Screen GID: 901
Procedure:  dbo.prAuthTypeTimeAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAuthorizationTypeTimeSpan '100-Config%', 22, 'AuthorizationTypeTimeSpan'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAuthorizationTypeTimeSpan
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

DECLARE @iEntity          VARCHAR(50)
       ,@iAuthTypeGID     VARCHAR(50)
       ,@iAuthTypeTimeSID VARCHAR(50)
       ,@iKeyField3       VARCHAR(50)
       ,@iKeyField4       VARCHAR(50)
       ,@iKeyField5       VARCHAR(50)
       ,@iKeyField6       VARCHAR(50)
       ,@iKeyField7       VARCHAR(50)
       ,@iKeyField8       VARCHAR(50)
       ,@iKeyField9       VARCHAR(50)
       ,@iKeyField10      VARCHAR(50)
       ,@iAction          VARCHAR(10)
       ,@iDateModified    VARCHAR(50)
       ,@iUserID          VARCHAR(25)
       ,@iCust_LOB        VARCHAR(10)
       ,@iTime_Span       VARCHAR(10)
       ,@oStatus          INT
       ,@oMessage         VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AuthorizationTypeTimeSpan') IS NOT NULL
	DROP TABLE #AuthorizationTypeTimeSpan

CREATE TABLE #AuthorizationTypeTimeSpan
      (iEntity          VARCHAR(50)       DEFAULT('Auth_Type_XRef_TIME')
      ,iAuthTypeGID     VARCHAR(50)       DEFAULT('0')
      ,iAuthTypeTimeSID VARCHAR(50)       DEFAULT('0')
      ,iKeyField3       VARCHAR(50)       DEFAULT('0')
      ,iKeyField4       VARCHAR(50)       DEFAULT('0')
      ,iKeyField5       VARCHAR(50)       DEFAULT('0')
      ,iKeyField6       VARCHAR(50)       DEFAULT('0')
      ,iKeyField7       VARCHAR(50)       DEFAULT('0')
      ,iKeyField8       VARCHAR(50)       DEFAULT('0')
      ,iKeyField9       VARCHAR(50)       DEFAULT('0')
      ,iKeyField10      VARCHAR(50)       DEFAULT('0')
      ,iAction          VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified    VARCHAR(50)       DEFAULT('')
      ,iUserID          VARCHAR(25)       DEFAULT('')
      ,iCust_LOB        VARCHAR(10)
      ,iTime_Span       VARCHAR(10)
      ,oStatus          INT
      ,oMessage         VARCHAR(250)
      ,record_id        INT
      ,static_gid       INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AuthorizationTypeTimeSpan
      (iKeyField3
	  ,iCust_LOB
      ,iTime_Span
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*LOB], '')
      ,ISNULL([*AuthTimeSpan], '0')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AuthTypeAuthTimeSpan
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AuthorizationTypeTimeSpan
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AuthorizationTypeTimeSpan_Cursor CURSOR FOR
 SELECT iEntity
       ,iAuthTypeGID
       ,iAuthTypeTimeSID
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
       ,iCust_LOB
       ,iTime_Span
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #AuthorizationTypeTimeSpan

   OPEN AuthorizationTypeTimeSpan_Cursor
  FETCH NEXT FROM AuthorizationTypeTimeSpan_Cursor
   INTO @iEntity
       ,@iAuthTypeGID
       ,@iAuthTypeTimeSID
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
       ,@iCust_LOB
       ,@iTime_Span
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Need to lookup the current gid to pass into the stored procedure call
		SELECT @iAuthTypeGID		= A.auth_type_gid
		  FROM Auth_Type			A
		 WHERE A.record_status		= 'A'
		   AND A.auth_type			= @iKeyField3

		EXEC dbo.prAuthTypeTimeAddModify
             @iEntity
            ,@iAuthTypeGID
            ,@iAuthTypeTimeSID
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
            ,@iCust_LOB
            ,@iTime_Span
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iKeyField3, @iCust_LOB, @iTime_Span, @status, @err_num, @err_msg

        FETCH NEXT FROM AuthorizationTypeTimeSpan_Cursor
         INTO @iEntity
             ,@iAuthTypeGID
             ,@iAuthTypeTimeSID
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
             ,@iCust_LOB
             ,@iTime_Span
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE AuthorizationTypeTimeSpan_Cursor
DEALLOCATE AuthorizationTypeTimeSpan_Cursor

END
GO