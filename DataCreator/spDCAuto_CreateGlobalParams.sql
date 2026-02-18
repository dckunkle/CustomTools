IF OBJECT_ID('dbo.spDCAuto_CreateGlobalParams') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGlobalParams AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGlobalParams
Purpose:    Update Global Parameter settings not available in Global Values screen
Method:     GlobalParams
Screen GID: N/A
Procedure:  dbo.prGetSetGlobalParams

Date        User            Change
---------------------------------------------------------------------------------------------
09/10/2021	DK				Original procedure
07/27/2022	SUS				Increased varciable length from 50 to 200
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGlobalParams 'DisablePC%', 22, 'DisablePayerCompass', 'GlobalParams','DisablePC'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGlobalParams
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

DECLARE @iAction		VARCHAR(50)
       ,@iVar_Name      VARCHAR(200)		-- SUS 07/27/2022
       ,@iVar_Value     VARCHAR(200)		-- SUS 07/27/2022
       ,@iUserID        VARCHAR(50)

       ,@o_status       INT
       ,@o_message      VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GlobalParams') IS NOT NULL
	DROP TABLE #GlobalParams

CREATE TABLE #GlobalParams
      (iAction			VARCHAR(50)       DEFAULT('Set')
      ,iVar_Name        VARCHAR(200)       
      ,iVar_Value       VARCHAR(200)      
      ,iUserID			VARCHAR(200)      
      ,record_id        INT
      ,static_gid       INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GlobalParams
      (iVar_Name
      ,iVar_Value
      ,record_id
      ,static_gid)
SELECT ISNULL([variable_name], '')
      ,ISNULL([variable_value], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GlobalParams
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GlobalParams
   SET iUserID  = @user

SELECT * FROM #GlobalParams
--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GlobalParams_Cursor CURSOR FOR
 SELECT iAction
       ,iVar_Name
       ,iVar_Value
       ,iUserID
       ,record_id
       ,static_gid
   FROM #GlobalParams

   OPEN GlobalParams_Cursor
  FETCH NEXT FROM GlobalParams_Cursor
   INTO @iAction
       ,@iVar_Name
       ,@iVar_Value
       ,@iUserID
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prGetSetGlobalValue
             @iAction
			,@iVar_Name
			,@iVar_Value
			,''
			,@iUserID


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iVar_Name, @iVar_Value, @iUserID, @status, @err_num, @err_msg

        FETCH NEXT FROM GlobalParams_Cursor
         INTO @iAction
		     ,@iVar_Name
		     ,@iVar_Value
		     ,@iUserID
		     ,@record_id
		     ,@static_gid
	END

CLOSE GlobalParams_Cursor
DEALLOCATE GlobalParams_Cursor

END
GO