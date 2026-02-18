IF OBJECT_ID('dbo.spDCAuto_CreateAuthorizationTypeServicesOffered') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateAuthorizationTypeServicesOffered AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateAuthorizationTypeServicesOffered
Purpose:    Create authorizationtypeservicesoffered data from CorderAutomation
Method:     AuthorizationTypeServicesOffered
Screen GID: 903
Procedure:  dbo.prAuthTypeXServiceAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/29/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateAuthorizationTypeServicesOffered '100-Config%', 22, 'AuthorizationTypeServicesOffered'
***************************************************************************************************/
ALTER PROCEDURE [dbo].[spDCAuto_CreateAuthorizationTypeServicesOffered]
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

DECLARE @iEntity              VARCHAR(100)
       ,@iAuthTypeGID         VARCHAR(50)
       ,@iAuthTypeXServiceSID VARCHAR(50)
       ,@iOldBenefitClass     VARCHAR(50)
       ,@iKeyField4           VARCHAR(50)
       ,@iKeyField5           VARCHAR(50)
       ,@iKeyField6           VARCHAR(50)
       ,@iKeyField7           VARCHAR(50)
       ,@iKeyField8           VARCHAR(50)
       ,@iKeyField9           VARCHAR(50)
       ,@iKeyField10          VARCHAR(50)
       ,@iAction              VARCHAR(10)
       ,@iDateModified        VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@iService_Offered     VARCHAR(25)
       ,@oStatus              INT
       ,@oMessage             VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#AuthorizationTypeServicesOffered') IS NOT NULL
	DROP TABLE #AuthorizationTypeServicesOffered

CREATE TABLE #AuthorizationTypeServicesOffered
      (iEntity              VARCHAR(100)      DEFAULT('Auth_Type_XRef_Srv')
      ,iAuthTypeGID         VARCHAR(50)       DEFAULT('0')
      ,iAuthTypeXServiceSID VARCHAR(50)       DEFAULT('0')
      ,iOldBenefitClass     VARCHAR(50)       DEFAULT('0')
      ,iKeyField4           VARCHAR(50)       DEFAULT('0')
      ,iKeyField5           VARCHAR(50)       DEFAULT('0')
      ,iKeyField6           VARCHAR(50)       DEFAULT('0')
      ,iKeyField7           VARCHAR(50)       DEFAULT('0')
      ,iKeyField8           VARCHAR(50)       DEFAULT('0')
      ,iKeyField9           VARCHAR(50)       DEFAULT('0')
      ,iKeyField10          VARCHAR(50)       DEFAULT('0')
      ,iAction              VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified        VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iService_Offered     VARCHAR(25)
      ,oStatus              INT
      ,oMessage             VARCHAR(250)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #AuthorizationTypeServicesOffered
      (iKeyField4
	  ,iService_Offered
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*ValidServicesOffered]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_AuthTypeServicesOffered
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #AuthorizationTypeServicesOffered
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE AuthorizationTypeServicesOffered_Cursor CURSOR FOR
 SELECT iEntity
       ,iAuthTypeGID
       ,iAuthTypeXServiceSID
       ,iOldBenefitClass
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
       ,iService_Offered
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #AuthorizationTypeServicesOffered

   OPEN AuthorizationTypeServicesOffered_Cursor
  FETCH NEXT FROM AuthorizationTypeServicesOffered_Cursor
   INTO @iEntity
       ,@iAuthTypeGID
       ,@iAuthTypeXServiceSID
       ,@iOldBenefitClass
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
       ,@iService_Offered
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
		   AND A.auth_type			= @iKeyField4

		EXEC dbo.prAuthTypeXServiceAddModify
             @iEntity
            ,@iAuthTypeGID
            ,@iAuthTypeXServiceSID
            ,@iOldBenefitClass
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
            ,@iService_Offered
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iKeyField4, @iService_Offered, '', @status, @err_num, @err_msg

        FETCH NEXT FROM AuthorizationTypeServicesOffered_Cursor
         INTO @iEntity
             ,@iAuthTypeGID
             ,@iAuthTypeXServiceSID
             ,@iOldBenefitClass
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
             ,@iService_Offered
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE AuthorizationTypeServicesOffered_Cursor
DEALLOCATE AuthorizationTypeServicesOffered_Cursor

END
GO

