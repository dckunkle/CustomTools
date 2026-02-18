IF OBJECT_ID('dbo.spDCAuto_CreateAuthorizationType') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAuthorizationType AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAuthorizationType
Purpose:    Create authorizationtype data from CorderAutomation
Method:     AuthorizationType
Screen GID: 901
Procedure:  dbo.prAuthTypeAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAuthorizationType '100-Config%', 22, 'AuthorizationType'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateAuthorizationType
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

DECLARE @iEntity       VARCHAR(50)
       ,@iAuthTypeGID  VARCHAR(50)
       ,@iKeyField2    VARCHAR(100)
       ,@iKeyField3    VARCHAR(50)
       ,@iKeyField4    VARCHAR(20)
       ,@iKeyField5    VARCHAR(50)
       ,@iKeyField6    VARCHAR(50)
       ,@iKeyField7    VARCHAR(50)
       ,@iKeyField8    VARCHAR(50)
       ,@iKeyField9    VARCHAR(50)
       ,@iKeyField10   VARCHAR(50)
       ,@iAction       VARCHAR(10)
       ,@iDateModified VARCHAR(50)
       ,@iUserID       VARCHAR(25)
       ,@iSystemLOB    VARCHAR(25)
       ,@iAuthType     VARCHAR(25)
       ,@iAuthTypeDesc VARCHAR(25)
       ,@iIVRKeyNum    VARCHAR(3)
       ,@oStatus       INT
       ,@oMessage      VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AuthorizationType') IS NOT NULL
	DROP TABLE #AuthorizationType

CREATE TABLE #AuthorizationType
      (iEntity       VARCHAR(50)       DEFAULT('AUTH_TYPE')
      ,iAuthTypeGID  VARCHAR(50)       DEFAULT('0')
      ,iKeyField2    VARCHAR(100)      DEFAULT('0')
      ,iKeyField3    VARCHAR(50)       DEFAULT('0')
      ,iKeyField4    VARCHAR(20)       DEFAULT('0')
      ,iKeyField5    VARCHAR(50)       DEFAULT('0')
      ,iKeyField6    VARCHAR(50)       DEFAULT('0')
      ,iKeyField7    VARCHAR(50)       DEFAULT('0')
      ,iKeyField8    VARCHAR(50)       DEFAULT('0')
      ,iKeyField9    VARCHAR(50)       DEFAULT('0')
      ,iKeyField10   VARCHAR(50)       DEFAULT('0')
      ,iAction       VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified VARCHAR(50)       DEFAULT('')
      ,iUserID       VARCHAR(25)       DEFAULT('')
      ,iSystemLOB    VARCHAR(25)
      ,iAuthType     VARCHAR(25)
      ,iAuthTypeDesc VARCHAR(25)
      ,iIVRKeyNum    VARCHAR(3)
      ,oStatus       INT
      ,oMessage      VARCHAR(250)
      ,record_id     INT
      ,static_gid    INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AuthorizationType
      (iSystemLOB
      ,iAuthType
      ,iAuthTypeDesc
      ,iIVRKeyNum
      ,record_id
      ,static_gid)
SELECT ISNULL(dbo.fnDCAuto_GetDropdownValue([*SystemLOB]), 'M')
      ,ISNULL([*AuthType], '')
      ,ISNULL([*AuthTypeDesc], '')
      ,ISNULL([IVRKeyNumber], '-1')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AuthType
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AuthorizationType
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AuthorizationType_Cursor CURSOR FOR
 SELECT iEntity
       ,iAuthTypeGID
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
       ,iSystemLOB
       ,iAuthType
       ,iAuthTypeDesc
       ,iIVRKeyNum
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #AuthorizationType

   OPEN AuthorizationType_Cursor
  FETCH NEXT FROM AuthorizationType_Cursor
   INTO @iEntity
       ,@iAuthTypeGID
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
       ,@iSystemLOB
       ,@iAuthType
       ,@iAuthTypeDesc
       ,@iIVRKeyNum
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prAuthTypeAddModify
             @iEntity
            ,@iAuthTypeGID
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
            ,@iSystemLOB
            ,@iAuthType
            ,@iAuthTypeDesc
            ,@iIVRKeyNum
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Auth_Type 
				   SET auth_type_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND auth_type				= @iAuthType

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iAuthType, @iAuthTypeDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM AuthorizationType_Cursor
         INTO @iEntity
             ,@iAuthTypeGID
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
             ,@iSystemLOB
             ,@iAuthType
             ,@iAuthTypeDesc
             ,@iIVRKeyNum
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE AuthorizationType_Cursor
DEALLOCATE AuthorizationType_Cursor

END
GO