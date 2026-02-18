IF OBJECT_ID('dbo.spDCAuto_CreateRFFParameter') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRFFParameter AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRFFParameter
Purpose:    Create rffparameter data from CorderAutomation
Method:     RFFParameter
Screen GID: 3114
Procedure:  dbo.prRFFParam_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRFFParameter '100-Config%', 22, 'RFFParameter'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRFFParameter
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

DECLARE @i_Entity_name        VARCHAR(50)
       ,@i_param_gid          VARCHAR(50)
       ,@i_variable_name      VARCHAR(50)
       ,@i_variable_value     VARCHAR(50)
       ,@i_rff_param_sid      VARCHAR(50)
       ,@i_modify_from_entity VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@iAction              VARCHAR(10)
       ,@iModifiedDate        VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@iParamName           VARCHAR(50)
       ,@iParamValue          VARCHAR(200)
       ,@oStatus              INT
       ,@oMessage             VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RFFParameter') IS NOT NULL
	DROP TABLE #RFFParameter

CREATE TABLE #RFFParameter
      (SearchID             VARCHAR(200)
      ,i_Entity_name        VARCHAR(50)       DEFAULT('RFF_PARAM')
      ,i_param_gid          VARCHAR(50)       DEFAULT('0')
      ,i_variable_name      VARCHAR(50)       DEFAULT('0')
      ,i_variable_value     VARCHAR(50)       DEFAULT('0')
      ,i_rff_param_sid      VARCHAR(50)       DEFAULT('0')
      ,i_modify_from_entity VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,iAction              VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate        VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iParamName           VARCHAR(50)
      ,iParamValue          VARCHAR(200)
      ,oStatus              INT
      ,oMessage             VARCHAR(100)
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
INSERT INTO #RFFParameter
      (SearchID
      ,iParamName
      ,iParamValue
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([VariableType]), 'AFFIL')
      ,ISNULL([VariableValue], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_RffParameter
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #RFFParameter
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE RFFParameter_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_param_gid
       ,i_variable_name
       ,i_variable_value
       ,i_rff_param_sid
       ,i_modify_from_entity
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iParamName
       ,iParamValue
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #RFFParameter

   OPEN RFFParameter_Cursor
  FETCH NEXT FROM RFFParameter_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_param_gid
       ,@i_variable_name
       ,@i_variable_value
       ,@i_rff_param_sid
       ,@i_modify_from_entity
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iParamName
       ,@iParamValue
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

			--Get the gid for the Auth Match
			SELECT @i_param_gid				= rff_param_gid
			  FROM RFF_Parameter_Definition
			 WHERE record_status			= 'A'
			   AND parameter_id				= @SearchID

			EXEC dbo.prRFFParam_AddModify
             @i_Entity_name
            ,@i_param_gid
            ,@i_variable_name
            ,@i_variable_value
            ,@i_rff_param_sid
            ,@i_modify_from_entity
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@iAction
            ,@iModifiedDate
            ,@iUserID
            ,@iParamName
            ,@iParamValue
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iParamName, @iParamValue, @status, @err_num, @err_msg

        FETCH NEXT FROM RFFParameter_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_param_gid
             ,@i_variable_name
             ,@i_variable_value
             ,@i_rff_param_sid
             ,@i_modify_from_entity
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iParamName
             ,@iParamValue
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE RFFParameter_Cursor
DEALLOCATE RFFParameter_Cursor

END
GO