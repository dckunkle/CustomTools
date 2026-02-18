IF OBJECT_ID('dbo.spDCAuto_CreateCodeAlternatesCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeAlternatesCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeAlternatesCodes
Purpose:    Create codealternatescodes data from CorderAutomation

Screen:     42
Method:     CodeAlternatesCodes
Procedure:  dbo.prProcPaymentAdd 
Entity:     Proc_Payment

Date        User            Change
---------------------------------------------------------------------------------------------
02/02/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeAlternatesCodes 'Ragnarok-Config%', 22, 'Ragnarok-Config', 'CodeAlternatesCodes', 'dkunkle'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeAlternatesCodes
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

DECLARE @i_entity_name                  VARCHAR(75)
       ,@i_payment_gid                  VARCHAR(75)
       ,@i_Old_procedure_id             VARCHAR(50)
       ,@i_Old_effective_date           VARCHAR(50)
       ,@i_Old_termination_date         VARCHAR(50)
       ,@i_Old_Age_Option               VARCHAR(50)
       ,@i_key_6_field                  VARCHAR(50)
       ,@i_key_7_field                  VARCHAR(50)
       ,@i_key_8_field                  VARCHAR(50)
       ,@i_key_9_field                  VARCHAR(50)
       ,@i_Payment_sid                  VARCHAR(50)
       ,@i_action                       VARCHAR(10)
       ,@i_date_time_modified           VARCHAR(30)
       ,@iUserID                        VARCHAR(25)
       ,@i_Proc_Id                      VARCHAR(50)
       ,@i_Proc_name                    VARCHAR(300)
       ,@i_effective_date               VARCHAR(50)
       ,@i_termination_date             VARCHAR(50)
       ,@i_Adjudicated_proc_Id          VARCHAR(50)
       ,@i_Adjudicated_Proc_name        VARCHAR(300)
       ,@i_Payment_proc_Id              VARCHAR(50)
       ,@i_Payment_proc_name            VARCHAR(300)
       ,@i_Procedure_Payment            VARCHAR(50)
       ,@i_Procedure_Desc               VARCHAR(100)
       ,@i_Age_option                   VARCHAR(50)
       ,@i_Age_Limit                    INT
       ,@i_Tooth_Type                   VARCHAR(50)
       ,@i_App_Fee_Basis                VARCHAR(50)
       ,@i_Processing_Policy            VARCHAR(50)
       ,@i_Processing_Policy_Desc       VARCHAR(600)
       ,@i_Delta_Processing_Policy      VARCHAR(50)
       ,@i_Delta_Processing_Policy_Desc VARCHAR(600)
       ,@o_status                       INT
       ,@o_message                      VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeAlternatesCodes') IS NOT NULL
	DROP TABLE #CodeAlternatesCodes

CREATE TABLE #CodeAlternatesCodes
      (SearchID                       VARCHAR(200)
      ,i_entity_name                  VARCHAR(75)       DEFAULT('Proc_Payment')
      ,i_payment_gid                  VARCHAR(75)       DEFAULT('0')
      ,i_Old_procedure_id             VARCHAR(50)       DEFAULT('0')
      ,i_Old_effective_date           VARCHAR(50)       DEFAULT('0')
      ,i_Old_termination_date         VARCHAR(50)       DEFAULT('0')
      ,i_Old_Age_Option               VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                  VARCHAR(50)       DEFAULT('0')
      ,i_Payment_sid                  VARCHAR(50)       DEFAULT('0')
      ,i_action                       VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified           VARCHAR(30)       DEFAULT('')
      ,iUserID                        VARCHAR(25)       DEFAULT('')
      ,i_Proc_Id                      VARCHAR(50)
      ,i_Proc_name                    VARCHAR(300)
      ,i_effective_date               VARCHAR(50)
      ,i_termination_date             VARCHAR(50)
      ,i_Adjudicated_proc_Id          VARCHAR(50)
      ,i_Adjudicated_Proc_name        VARCHAR(300)
      ,i_Payment_proc_Id              VARCHAR(50)
      ,i_Payment_proc_name            VARCHAR(300)
      ,i_Procedure_Payment            VARCHAR(50)
      ,i_Procedure_Desc               VARCHAR(100)
      ,i_Age_option                   VARCHAR(50)
      ,i_Age_Limit                    INT
      ,i_Tooth_Type                   VARCHAR(50)
      ,i_App_Fee_Basis                VARCHAR(50)
      ,i_Processing_Policy            VARCHAR(50)
      ,i_Processing_Policy_Desc       VARCHAR(600)       DEFAULT('Blank')
      ,i_Delta_Processing_Policy      VARCHAR(50)
      ,i_Delta_Processing_Policy_Desc VARCHAR(600)       DEFAULT('Blank')
      ,o_status                       INT
      ,o_message                      VARCHAR(100)
      ,record_id                      INT
      ,static_gid                     INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #CodeAlternatesCodes
          (SearchID
          ,i_Proc_Id
          ,i_Proc_name
          ,i_effective_date
          ,i_termination_date
          ,i_Adjudicated_proc_Id
          ,i_Adjudicated_Proc_name
          ,i_Payment_proc_Id
          ,i_Payment_proc_name
          ,i_Procedure_Payment
          ,i_Procedure_Desc
          ,i_Age_option
          ,i_Age_Limit
          ,i_Tooth_Type
          ,i_App_Fee_Basis
          ,i_Processing_Policy
          ,i_Delta_Processing_Policy
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*CodeId], '')
		  ,ISNULL([CodeDesc], 'Blank')
          ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([AdjudCodeID], '')
          ,ISNULL([AdjudCodeDesc], 'Blank')
          ,ISNULL([PayAsCode], '')
          ,ISNULL([PayAsCodeDesc], 'Blank')
          ,ISNULL([Speciality], '999')
          ,ISNULL([SpecialityDesc], 'Blank')
          ,ISNULL([AgeOption], '')
          ,ISNULL([AgeLimit], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ToothType]), 'DF')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApprovedFeeBasis]), 'S')
          ,ISNULL([RemarkCodeID], '')
          ,ISNULL([RemarkCodeID2], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_CodeAlternatesCodes
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CodeAlternatesCodes
       SET iUserID  = @user
	   SELECT * FROM #CodeAlternatesCodes

END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeAlternatesCodes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_payment_gid
       ,i_Old_procedure_id
       ,i_Old_effective_date
       ,i_Old_termination_date
       ,i_Old_Age_Option
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Payment_sid
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Proc_Id
       ,i_Proc_name
       ,i_effective_date
       ,i_termination_date
       ,i_Adjudicated_proc_Id
       ,i_Adjudicated_Proc_name
       ,i_Payment_proc_Id
       ,i_Payment_proc_name
       ,i_Procedure_Payment
       ,i_Procedure_Desc
       ,i_Age_option
       ,i_Age_Limit
       ,i_Tooth_Type
       ,i_App_Fee_Basis
       ,i_Processing_Policy
       ,i_Processing_Policy_Desc
       ,i_Delta_Processing_Policy
       ,i_Delta_Processing_Policy_Desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeAlternatesCodes

   OPEN CodeAlternatesCodes_Cursor
  FETCH NEXT FROM CodeAlternatesCodes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_payment_gid
       ,@i_Old_procedure_id
       ,@i_Old_effective_date
       ,@i_Old_termination_date
       ,@i_Old_Age_Option
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Payment_sid
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Proc_Id
       ,@i_Proc_name
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Adjudicated_proc_Id
       ,@i_Adjudicated_Proc_name
       ,@i_Payment_proc_Id
       ,@i_Payment_proc_name
       ,@i_Procedure_Payment
       ,@i_Procedure_Desc
       ,@i_Age_option
       ,@i_Age_Limit
       ,@i_Tooth_Type
       ,@i_App_Fee_Basis
       ,@i_Processing_Policy
       ,@i_Processing_Policy_Desc
       ,@i_Delta_Processing_Policy
       ,@i_Delta_Processing_Policy_Desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Get the gid for the Benefit Rules
			SELECT @i_payment_gid			= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_user_id			= @SearchID
			   AND entity_identifier		= 'PROCEDURE_PAYMENT'

			PRINT @i_Proc_name
			PRINT @i_Adjudicated_Proc_name

			EXEC dbo.prProcPaymentAdd 
                 @i_entity_name
                ,@i_payment_gid
                ,@i_Old_procedure_id
                ,@i_Old_effective_date
                ,@i_Old_termination_date
                ,@i_Old_Age_Option
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_Payment_sid
                ,@i_action
                ,@i_date_time_modified
                ,@iUserID
                ,@i_Proc_Id
                ,@i_Proc_name
                ,@i_effective_date
                ,@i_termination_date
                ,@i_Adjudicated_proc_Id
                ,@i_Adjudicated_Proc_name
                ,@i_Payment_proc_Id
                ,@i_Payment_proc_name
                ,@i_Procedure_Payment
                ,@i_Procedure_Desc
                ,@i_Age_option
                ,@i_Age_Limit
                ,@i_Tooth_Type
                ,@i_App_Fee_Basis
                ,@i_Processing_Policy
                ,@i_Processing_Policy_Desc
                ,@i_Delta_Processing_Policy
                ,@i_Delta_Processing_Policy_Desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Proc_Id, @i_Proc_name, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CodeAlternatesCodes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_payment_gid
             ,@i_Old_procedure_id
             ,@i_Old_effective_date
             ,@i_Old_termination_date
             ,@i_Old_Age_Option
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Payment_sid
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Proc_Id
             ,@i_Proc_name
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Adjudicated_proc_Id
             ,@i_Adjudicated_Proc_name
             ,@i_Payment_proc_Id
             ,@i_Payment_proc_name
             ,@i_Procedure_Payment
             ,@i_Procedure_Desc
             ,@i_Age_option
             ,@i_Age_Limit
             ,@i_Tooth_Type
             ,@i_App_Fee_Basis
             ,@i_Processing_Policy
             ,@i_Processing_Policy_Desc
             ,@i_Delta_Processing_Policy
             ,@i_Delta_Processing_Policy_Desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeAlternatesCodes_Cursor
DEALLOCATE CodeAlternatesCodes_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CodeAlternatesCodes') IS NOT NULL
	DROP TABLE #CodeAlternatesCodes

END
GO

