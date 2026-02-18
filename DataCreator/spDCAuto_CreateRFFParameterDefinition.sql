IF OBJECT_ID('dbo.spDCAuto_CreateRFFParameterDefinition') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRFFParameterDefinition AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRFFParameterDefinition
Purpose:    Create rffparameterdefinition data from CorderAutomation
Method:     RFFParameterDefinition
Screen GID: 3113
Procedure:  dbo.prRFFParamDefinition_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/20/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRFFParameterDefinition '100-Config%', 22, 'RFFParameterDefinition'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRFFParameterDefinition
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

DECLARE @i_Entity_name  VARCHAR(50)
       ,@i_param_gid    VARCHAR(50)
       ,@i_key_2_field  VARCHAR(50)
       ,@i_key_3_field  VARCHAR(50)
       ,@i_key_4_field  VARCHAR(50)
       ,@i_key_5_field  VARCHAR(50)
       ,@i_key_6_field  VARCHAR(50)
       ,@i_key_7_field  VARCHAR(50)
       ,@i_key_8_field  VARCHAR(50)
       ,@i_key_9_field  VARCHAR(50)
       ,@i_key_10_field VARCHAR(50)
       ,@iAction        VARCHAR(10)
       ,@iModifiedDate  VARCHAR(50)
       ,@iUserID        VARCHAR(25)
       ,@iParamId       VARCHAR(50)
       ,@iParamDesc     VARCHAR(50)
       ,@iDateUsed      VARCHAR(50)
       ,@iTermDate      VARCHAR(50)
       ,@oStatus        INT
       ,@oMessage       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RFFParameterDefinition') IS NOT NULL
	DROP TABLE #RFFParameterDefinition

CREATE TABLE #RFFParameterDefinition
      (SearchID       VARCHAR(200)
      ,i_Entity_name  VARCHAR(50)       DEFAULT('RFF_PARAM_DEF')
      ,i_param_gid    VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field VARCHAR(50)       DEFAULT('0')
      ,iAction        VARCHAR(10)       DEFAULT('ADD')
      ,iModifiedDate  VARCHAR(50)       DEFAULT('')
      ,iUserID        VARCHAR(25)       DEFAULT('')
      ,iParamId       VARCHAR(50)
      ,iParamDesc     VARCHAR(50)
      ,iDateUsed      VARCHAR(50)
      ,iTermDate      VARCHAR(50)
      ,oStatus        INT
      ,oMessage       VARCHAR(100)
      ,record_id      INT
      ,static_gid     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #RFFParameterDefinition
      (SearchID
      ,iParamId
      ,iParamDesc
      ,iTermDate
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([RFFParamID], '')
      ,ISNULL([Description], '')
      ,ISNULL([TermDate], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_RffParameterDefinition
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #RFFParameterDefinition
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE RFFParameterDefinition_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_param_gid
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,iAction
       ,iModifiedDate
       ,iUserID
       ,iParamId
       ,iParamDesc
       ,iDateUsed
       ,iTermDate
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #RFFParameterDefinition

   OPEN RFFParameterDefinition_Cursor
  FETCH NEXT FROM RFFParameterDefinition_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_param_gid
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@iAction
       ,@iModifiedDate
       ,@iUserID
       ,@iParamId
       ,@iParamDesc
       ,@iDateUsed
       ,@iTermDate
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prRFFParamDefinition_AddModify
             @i_Entity_name
            ,@i_param_gid
            ,@i_key_2_field
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@iAction
            ,@iModifiedDate
            ,@iUserID
            ,@iParamId
            ,@iParamDesc
            ,@iDateUsed
            ,@iTermDate
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.RFF_Parameter_Definition 
				   SET rff_param_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND parameter_id				= @iParamId

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iParamId, @iParamDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM RFFParameterDefinition_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_param_gid
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@iAction
             ,@iModifiedDate
             ,@iUserID
             ,@iParamId
             ,@iParamDesc
             ,@iDateUsed
             ,@iTermDate
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE RFFParameterDefinition_Cursor
DEALLOCATE RFFParameterDefinition_Cursor

END
GO