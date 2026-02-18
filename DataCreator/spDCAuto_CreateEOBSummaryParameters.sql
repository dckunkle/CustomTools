IF OBJECT_ID('dbo.spDCAuto_CreateEOBSummaryParameters') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateEOBSummaryParameters AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateEOBSummaryParameters
Purpose:    Create eobsummaryparameters data from CorderAutomation
Method:     EOBSummaryParameters
Screen GID: 350
Procedure:  dbo.prEOBParamAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
04/02/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateEOBSummaryParameters '100-Config%', 22, 'EOBSummaryParameters'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateEOBSummaryParameters
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

DECLARE @iEntityName         VARCHAR(50)
       ,@iParamGid           VARCHAR(300)
       ,@iKey_2_field        VARCHAR(100)
       ,@iKey_3_field        VARCHAR(200)
       ,@iKey_4_field        VARCHAR(300)
       ,@iKey_5_field        VARCHAR(50)
       ,@iKey_6_field        VARCHAR(200)
       ,@iKey_7_field        VARCHAR(50)
       ,@iKey_8_field        VARCHAR(100)
       ,@iKey_9_field        VARCHAR(50)
       ,@iParamSid           VARCHAR(100)
       ,@iAction             VARCHAR(10)
       ,@iDate_Time_Modified VARCHAR(100)
       ,@iUserID             VARCHAR(25)
       ,@iParamID            VARCHAR(200)
       ,@iParamDesc          VARCHAR(100)
       ,@iEffectiveDate      VARCHAR(100)
       ,@iTerminationDate    DATETIME
       ,@iGroupID            VARCHAR(50)
       ,@iGroupName          VARCHAR(100)
       ,@iGroupListID        VARCHAR(50)
       ,@iGroupListDesc      VARCHAR(100)
       ,@iPlanID             VARCHAR(50)
       ,@iPlanDesc           VARCHAR(100)
       ,@iPlanlistID         VARCHAR(50)
       ,@iPlanlistDesc       VARCHAR(100)
       ,@iCalendarID         VARCHAR(50)
       ,@iCalendarDesc       VARCHAR(100)
       ,@iEOBType            VARCHAR(50)
       ,@iLastRunDate        DATETIME
       ,@iNumofDays          INT
       ,@iExtractDate        DATETIME
       ,@iRunMode            VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#EOBSummaryParameters') IS NOT NULL
	DROP TABLE #EOBSummaryParameters

CREATE TABLE #EOBSummaryParameters
      (SearchID            VARCHAR(200)
      ,iEntityName         VARCHAR(50)       DEFAULT('EOB_Parm')
      ,iParamGid           VARCHAR(300)      DEFAULT('0')
      ,iKey_2_field        VARCHAR(100)      DEFAULT('0')
      ,iKey_3_field        VARCHAR(200)      DEFAULT('0')
      ,iKey_4_field        VARCHAR(300)      DEFAULT('0')
      ,iKey_5_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field        VARCHAR(200)      DEFAULT('0')
      ,iKey_7_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field        VARCHAR(100)      DEFAULT('0')
      ,iKey_9_field        VARCHAR(50)       DEFAULT('0')
      ,iParamSid           VARCHAR(100)      DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified VARCHAR(100)      DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iParamID            VARCHAR(200)
      ,iParamDesc          VARCHAR(100)
      ,iEffectiveDate      VARCHAR(100)
      ,iTerminationDate    DATETIME
      ,iGroupID            VARCHAR(50)
      ,iGroupName          VARCHAR(100)
      ,iGroupListID        VARCHAR(50)
      ,iGroupListDesc      VARCHAR(100)
      ,iPlanID             VARCHAR(50)
      ,iPlanDesc           VARCHAR(100)
      ,iPlanlistID         VARCHAR(50)
      ,iPlanlistDesc       VARCHAR(100)
      ,iCalendarID         VARCHAR(50)
      ,iCalendarDesc       VARCHAR(100)
      ,iEOBType            VARCHAR(50)
      ,iLastRunDate        DATETIME
      ,iNumofDays          INT
      ,iExtractDate        DATETIME
      ,iRunMode            VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(255)
      ,record_id           INT
      ,static_gid          INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #EOBSummaryParameters
      (SearchID
      ,iParamID
      ,iParamDesc
      ,iEffectiveDate
      ,iTerminationDate
      ,iGroupID
      ,iGroupListID
      ,iPlanID
      ,iPlanlistID
      ,iCalendarID
      ,iEOBType
      ,iNumofDays
      ,iRunMode
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EOBParameterID], '')
      ,ISNULL([*ParameterDescription], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([GroupID], '')
      ,ISNULL([GroupListID], '')
      ,ISNULL([PlanStrategyID], '')
      ,ISNULL([PlanListID], '')
      ,ISNULL([CalendarID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([EOBType]), 'MM')
      ,ISNULL([*NumofDaysAfterPeriodEndDate], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RunMode]), 'V')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_EobSummaryParameters
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #EOBSummaryParameters
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE EOBSummaryParameters_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iParamGid
       ,iKey_2_field
       ,iKey_3_field
       ,iKey_4_field
       ,iKey_5_field
       ,iKey_6_field
       ,iKey_7_field
       ,iKey_8_field
       ,iKey_9_field
       ,iParamSid
       ,iAction
       ,iDate_Time_Modified
       ,iUserID
       ,iParamID
       ,iParamDesc
       ,iEffectiveDate
       ,iTerminationDate
       ,iGroupID
       ,iGroupName
       ,iGroupListID
       ,iGroupListDesc
       ,iPlanID
       ,iPlanDesc
       ,iPlanlistID
       ,iPlanlistDesc
       ,iCalendarID
       ,iCalendarDesc
       ,iEOBType
       ,iLastRunDate
       ,iNumofDays
       ,iExtractDate
       ,iRunMode
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #EOBSummaryParameters

   OPEN EOBSummaryParameters_Cursor
  FETCH NEXT FROM EOBSummaryParameters_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iParamGid
       ,@iKey_2_field
       ,@iKey_3_field
       ,@iKey_4_field
       ,@iKey_5_field
       ,@iKey_6_field
       ,@iKey_7_field
       ,@iKey_8_field
       ,@iKey_9_field
       ,@iParamSid
       ,@iAction
       ,@iDate_Time_Modified
       ,@iUserID
       ,@iParamID
       ,@iParamDesc
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iGroupID
       ,@iGroupName
       ,@iGroupListID
       ,@iGroupListDesc
       ,@iPlanID
       ,@iPlanDesc
       ,@iPlanlistID
       ,@iPlanlistDesc
       ,@iCalendarID
       ,@iCalendarDesc
       ,@iEOBType
       ,@iLastRunDate
       ,@iNumofDays
       ,@iExtractDate
       ,@iRunMode
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prEOBParamAddModify
             @iEntityName
            ,@iParamGid
            ,@iKey_2_field
            ,@iKey_3_field
            ,@iKey_4_field
            ,@iKey_5_field
            ,@iKey_6_field
            ,@iKey_7_field
            ,@iKey_8_field
            ,@iKey_9_field
            ,@iParamSid
            ,@iAction
            ,@iDate_Time_Modified
            ,@iUserID
            ,@iParamID
            ,@iParamDesc
            ,@iEffectiveDate
            ,@iTerminationDate
            ,@iGroupID
            ,@iGroupName
            ,@iGroupListID
            ,@iGroupListDesc
            ,@iPlanID
            ,@iPlanDesc
            ,@iPlanlistID
            ,@iPlanlistDesc
            ,@iCalendarID
            ,@iCalendarDesc
            ,@iEOBType
            ,@iLastRunDate
            ,@iNumofDays
            ,@iExtractDate
            ,@iRunMode
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.EOBSummaryParameter 
				   SET parameter_gid			= @static_gid 
				 WHERE record_status			= 'A'
				   AND EOB_ParameterID			= @iParamID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iParamID, @iParamDesc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM EOBSummaryParameters_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iParamGid
             ,@iKey_2_field
             ,@iKey_3_field
             ,@iKey_4_field
             ,@iKey_5_field
             ,@iKey_6_field
             ,@iKey_7_field
             ,@iKey_8_field
             ,@iKey_9_field
             ,@iParamSid
             ,@iAction
             ,@iDate_Time_Modified
             ,@iUserID
             ,@iParamID
             ,@iParamDesc
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iGroupID
             ,@iGroupName
             ,@iGroupListID
             ,@iGroupListDesc
             ,@iPlanID
             ,@iPlanDesc
             ,@iPlanlistID
             ,@iPlanlistDesc
             ,@iCalendarID
             ,@iCalendarDesc
             ,@iEOBType
             ,@iLastRunDate
             ,@iNumofDays
             ,@iExtractDate
             ,@iRunMode
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE EOBSummaryParameters_Cursor
DEALLOCATE EOBSummaryParameters_Cursor

END
GO