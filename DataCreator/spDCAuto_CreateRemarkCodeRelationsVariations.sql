IF OBJECT_ID('dbo.spDCAuto_CreateRemarkCodeRelationsVariations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateRemarkCodeRelationsVariations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateRemarkCodeRelationsVariations
Purpose:    Create remarkcoderelationsvariations data from CorderAutomation
Method:     RemarkCodeRelationsVariations
Screen GID: 89
Procedure:  dbo.prPPRAdd_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
01/09/2020	DK				Original procedure
12/23/2021	DK				Changes fro SP48
02/08/2022  DK				Stored procedure name changed from prPPRAdd_Modify to prPPRAdd
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRemarkCodeRelationsVariations '100-Config%', 22, 'RemarkCodeRelationsVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateRemarkCodeRelationsVariations
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

DECLARE @i_entity_name                  VARCHAR(100)
       ,@i_PP_Relation_gid              VARCHAR(100)
       ,@i_old_effective_date           VARCHAR(100)
       ,@i_old_termination_date         VARCHAR(50)
       ,@i_old_Reject_Code              VARCHAR(100)
       ,@i_key_5_field                  VARCHAR(50)
       ,@i_key_6_field                  VARCHAR(100)
       ,@i_old_suppress_message         VARCHAR(50)
       ,@i_key_8_field                  VARCHAR(100)
       ,@i_key_9_field                  VARCHAR(50)
       ,@i_key_10_field                 VARCHAR(50)
       ,@i_action                       VARCHAR(10)
       ,@i_date_time_modified           VARCHAR(50)
       ,@iUserID                        VARCHAR(25)
	   ,@Relation_ID                    VARCHAR(50)		-- SP48
       ,@Relation_Desc                  VARCHAR(100)	-- SP48
       ,@i_effective_date               VARCHAR(50)
       ,@i_termination_date             VARCHAR(50)
       ,@i_Reject_Code                  VARCHAR(50)
       ,@i_Processing_Policy            VARCHAR(50)
       ,@i_Processing_Policy_Desc       VARCHAR(600)
       ,@i_Delta_Processing_Policy      VARCHAR(50)
       ,@i_Delta_Processing_Policy_Desc VARCHAR(600)
       ,@i_Penalty_exempt_code          VARCHAR(50)
       ,@i_Suppress_Message             VARCHAR(50)
       ,@o_status                       INT
       ,@o_message                      VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RemarkCodeRelationsVariations') IS NOT NULL
	DROP TABLE #RemarkCodeRelationsVariations

CREATE TABLE #RemarkCodeRelationsVariations
      (SearchID                       VARCHAR(200)
      ,i_entity_name                  VARCHAR(100)      DEFAULT('PPR_Variations')
      ,i_PP_Relation_gid              VARCHAR(100)      DEFAULT('0')
      ,i_old_effective_date           VARCHAR(100)      DEFAULT('0')
      ,i_old_termination_date         VARCHAR(50)       DEFAULT('0')
      ,i_old_Reject_Code              VARCHAR(100)      DEFAULT('0')
      ,i_key_5_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                  VARCHAR(100)      DEFAULT('0')
      ,i_old_suppress_message         VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                  VARCHAR(100)      DEFAULT('0')
      ,i_key_9_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field                 VARCHAR(50)       DEFAULT('0')
      ,i_action                       VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified           VARCHAR(50)       DEFAULT('')
      ,iUserID                        VARCHAR(25)       DEFAULT('')
      ,Relation_ID                    VARCHAR(50)	-- SP48
      ,Relation_Desc                  VARCHAR(100)	-- SP48
      ,i_effective_date               VARCHAR(50)
      ,i_termination_date             VARCHAR(50)
      ,i_Reject_Code                  VARCHAR(50)
      ,i_Processing_Policy            VARCHAR(50)
      ,i_Processing_Policy_Desc       VARCHAR(600)
      ,i_Delta_Processing_Policy      VARCHAR(50)
      ,i_Delta_Processing_Policy_Desc VARCHAR(600)
      ,i_Penalty_exempt_code          VARCHAR(50)
      ,i_Suppress_Message             VARCHAR(50)		DEFAULT('N')
      ,o_status                       INT
      ,o_message                      VARCHAR(100)
      ,record_id                      INT
      ,static_gid                     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #RemarkCodeRelationsVariations
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_Reject_Code
      ,i_Processing_Policy
      ,i_Delta_Processing_Policy
      ,i_Penalty_exempt_code
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RejectCode]), '')
      ,ISNULL([RemarkCodeID], '')
      ,ISNULL([RemarkCodeID2], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PenaltyExemptCode]), '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_RemarkCodeRelationsVariation
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #RemarkCodeRelationsVariations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE RemarkCodeRelationsVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_PP_Relation_gid
       ,i_old_effective_date
       ,i_old_termination_date
       ,i_old_Reject_Code
       ,i_key_5_field
       ,i_key_6_field
       ,i_old_suppress_message
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,Relation_ID				-- SP48
       ,Relation_Desc			-- SP48
       ,i_effective_date
       ,i_termination_date
       ,i_Reject_Code
       ,i_Processing_Policy
       ,i_Processing_Policy_Desc
       ,i_Delta_Processing_Policy
       ,i_Delta_Processing_Policy_Desc
       ,i_Penalty_exempt_code
       ,i_Suppress_Message
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #RemarkCodeRelationsVariations

   OPEN RemarkCodeRelationsVariations_Cursor
  FETCH NEXT FROM RemarkCodeRelationsVariations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_PP_Relation_gid
       ,@i_old_effective_date
       ,@i_old_termination_date
       ,@i_old_Reject_Code
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_old_suppress_message
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@Relation_ID			-- SP48
       ,@Relation_Desc			-- SP48
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Reject_Code
       ,@i_Processing_Policy
       ,@i_Processing_Policy_Desc
       ,@i_Delta_Processing_Policy
       ,@i_Delta_Processing_Policy_Desc
       ,@i_Penalty_exempt_code
       ,@i_Suppress_Message
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			--Get the GIDs 
			SELECT @i_PP_Relation_gid		= EN.entity_gid
			  FROM Entity_Names				EN
			 WHERE EN.record_status			= 'A'
			   AND EN.entity_identifier		= 'PROCESSING_POLICY_RELATION'
			   AND EN.entity_user_id		= @SearchID

			EXEC dbo.prPPRAdd
				 @i_entity_name
				,@i_PP_Relation_gid
				,@i_old_effective_date
				,@i_old_termination_date
				,@i_old_Reject_Code
				,@i_key_5_field
				,@i_key_6_field
				,@i_old_suppress_message
				,@i_key_8_field
				,@i_key_9_field
				,@i_key_10_field
				,@i_action
				,@i_date_time_modified
				,@iUserID
                ,@Relation_ID				-- SP48
                ,@Relation_Desc				-- SP48
				,@i_effective_date
				,@i_termination_date
				,@i_Reject_Code
				,@i_Processing_Policy
				,@i_Processing_Policy_Desc
				,@i_Delta_Processing_Policy
				,@i_Delta_Processing_Policy_Desc
				,@i_Penalty_exempt_code
				,@i_Suppress_Message
				,@o_status					= @err_num OUTPUT
				,@o_message					= @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Reject_Code, @i_Processing_Policy, @status, @err_num, @err_msg

        FETCH NEXT FROM RemarkCodeRelationsVariations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_PP_Relation_gid
             ,@i_old_effective_date
             ,@i_old_termination_date
             ,@i_old_Reject_Code
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_old_suppress_message
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@Relation_ID				-- SP48
             ,@Relation_Desc			-- SP48
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Reject_Code
             ,@i_Processing_Policy
             ,@i_Processing_Policy_Desc
             ,@i_Delta_Processing_Policy
             ,@i_Delta_Processing_Policy_Desc
             ,@i_Penalty_exempt_code
             ,@i_Suppress_Message
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE RemarkCodeRelationsVariations_Cursor
DEALLOCATE RemarkCodeRelationsVariations_Cursor

END
GO