/**************************************************************************************************
Name:       spDCAuto_CreateCodeClassExceptionsExceptions
Purpose:    Create codeclassexceptionsadd data from CorderAutomation

Screen:     44
Method:     CodeClassExceptionsAdd
Procedure:  dbo.prProcClassRelAdd
Entity:     Proc_Class_Rel

Date        User            Change
---------------------------------------------------------------------------------------------
04/17/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeClassExceptionsExceptions '100-Config%', 22, 'CodeClassExceptionsExceptions'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateCodeClassExceptionsExceptions
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

DECLARE @i_entity_name          VARCHAR(50)
       ,@i_Relation_gid         VARCHAR(50)
       ,@i_Old_effective_date   VARCHAR(100)
       ,@i_Old_termination_date VARCHAR(50)
       ,@i_Old_class_id         VARCHAR(100)
       ,@i_Old_procedure_id     VARCHAR(50)
       ,@i_RelationSID          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(30)
       ,@iUserID                VARCHAR(25)
       ,@i_effective_date       VARCHAR(50)
       ,@i_termination_date     VARCHAR(50)
       ,@i_Class_Id             VARCHAR(50)
       ,@i_Procedure_Id         VARCHAR(50)
       ,@i_Procedure_name       VARCHAR(300)
       ,@o_status               INT
       ,@o_message              VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeClassExceptionsAdd') IS NOT NULL
	DROP TABLE #CodeClassExceptionsAdd

CREATE TABLE #CodeClassExceptionsAdd
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(50)       DEFAULT('Proc_Class_Rel')
      ,i_Relation_gid         VARCHAR(50)       DEFAULT('0')
      ,i_Old_effective_date   VARCHAR(100)      DEFAULT('0')
      ,i_Old_termination_date VARCHAR(50)       DEFAULT('0')
      ,i_Old_class_id         VARCHAR(100)      DEFAULT('0')
      ,i_Old_procedure_id     VARCHAR(50)       DEFAULT('0')
      ,i_RelationSID          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,i_effective_date       VARCHAR(50)
      ,i_termination_date     VARCHAR(50)
      ,i_Class_Id             VARCHAR(50)
      ,i_Procedure_Id         VARCHAR(50)
      ,i_Procedure_name       VARCHAR(300)
      ,o_status               INT
      ,o_message              VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #CodeClassExceptionsAdd
          (SearchID
          ,i_effective_date
          ,i_termination_date
          ,i_Class_Id
          ,i_Procedure_Id
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ClassVariationID]), '100')
          ,ISNULL([*CodeID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid],0)
      FROM COREAUTO.CoreAutomation.dbo.TD_CodeClassExceptionsExceptions
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CodeClassExceptionsAdd
       SET iUserID  = @user


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
DECLARE CodeClassExceptionsAdd_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Relation_gid
       ,i_Old_effective_date
       ,i_Old_termination_date
       ,i_Old_class_id
       ,i_Old_procedure_id
       ,i_RelationSID
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_effective_date
       ,i_termination_date
       ,i_Class_Id
       ,i_Procedure_Id
       ,i_Procedure_name
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeClassExceptionsAdd

   OPEN CodeClassExceptionsAdd_Cursor
  FETCH NEXT FROM CodeClassExceptionsAdd_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Relation_gid
       ,@i_Old_effective_date
       ,@i_Old_termination_date
       ,@i_Old_class_id
       ,@i_Old_procedure_id
       ,@i_RelationSID
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Class_Id
       ,@i_Procedure_Id
       ,@i_Procedure_name
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

			SELECT @i_Relation_gid			= EN.entity_gid
			  FROM dbo.Entity_Names			EN
			 WHERE record_status			= 'A'
			   AND entity_identifier		= 'PROCEDURE_CLASS_RELATION'
			   AND entity_user_id			= @SearchID

			EXEC dbo.prProcClassRelAdd
                 @i_entity_name
                ,@i_Relation_gid
                ,@i_Old_effective_date
                ,@i_Old_termination_date
                ,@i_Old_class_id
                ,@i_Old_procedure_id
                ,@i_RelationSID
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@i_date_time_modified
                ,@iUserID
                ,@i_effective_date
                ,@i_termination_date
                ,@i_Class_Id
                ,@i_Procedure_Id
                ,@i_Procedure_name
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_effective_date, @i_Procedure_Id, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CodeClassExceptionsAdd_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Relation_gid
             ,@i_Old_effective_date
             ,@i_Old_termination_date
             ,@i_Old_class_id
             ,@i_Old_procedure_id
             ,@i_RelationSID
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Class_Id
             ,@i_Procedure_Id
             ,@i_Procedure_name
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeClassExceptionsAdd_Cursor
DEALLOCATE CodeClassExceptionsAdd_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CodeClassExceptionsAdd') IS NOT NULL
	DROP TABLE #CodeClassExceptionsAdd

END
GO

