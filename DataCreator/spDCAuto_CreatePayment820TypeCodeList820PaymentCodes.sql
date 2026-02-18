/**************************************************************************************************
Name:       spDCAuto_CreatePayment820TypeCodeList820PaymentCodes
Purpose:    Create payment820typecodelistadd data from CorderAutomation

Screen:     11027
Method:     Payment820TypeCodeListAdd
Procedure:  dbo.pr820PaymentCodeDetailsAdd
Entity:     820PaymentCodes

Date        User            Change
---------------------------------------------------------------------------------------------
08/23/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePayment820TypeCodeList820PaymentCodes '100-Config%', 22, 'Payment820TypeCodeListAdd'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreatePayment820TypeCodeList820PaymentCodes
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
       ,@iListGid            VARCHAR(50)
       ,@iKey_2_field        VARCHAR(50)
       ,@iKey_3_field        VARCHAR(50)
       ,@iKey_4_field        VARCHAR(50)
       ,@iKey_5_field        VARCHAR(50)
       ,@iKey_6_field        VARCHAR(50)
       ,@iKey_7_field        VARCHAR(50)
       ,@iKey_8_field        VARCHAR(50)
       ,@iKey_9_field        VARCHAR(50)
       ,@iListSid            VARCHAR(50)
       ,@iAction             VARCHAR(10)
       ,@iDate_Time_Modified VARCHAR(50)
       ,@iUserID             VARCHAR(25)
       ,@iListID             VARCHAR(50)
       ,@iListDesc           VARCHAR(150)
       ,@iCodeID             VARCHAR(50)
       ,@iCodeDesc           VARCHAR(150)
       ,@iExclude            VARCHAR(50)
       ,@o_status            INT
       ,@o_message           VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Payment820TypeCodeListAdd') IS NOT NULL
	DROP TABLE #Payment820TypeCodeListAdd

CREATE TABLE #Payment820TypeCodeListAdd
      (SearchID            VARCHAR(200)
      ,iEntityName         VARCHAR(50)       DEFAULT('820PaymentCodes')
      ,iListGid            VARCHAR(50)       DEFAULT('0')
      ,iKey_2_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_3_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_4_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_5_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_6_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_7_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_8_field        VARCHAR(50)       DEFAULT('0')
      ,iKey_9_field        VARCHAR(50)       DEFAULT('0')
      ,iListSid            VARCHAR(50)       DEFAULT('0')
      ,iAction             VARCHAR(10)       DEFAULT('ADD')
      ,iDate_Time_Modified VARCHAR(50)       DEFAULT('')
      ,iUserID             VARCHAR(25)       DEFAULT('')
      ,iListID             VARCHAR(50)
      ,iListDesc           VARCHAR(150)
      ,iCodeID             VARCHAR(50)
      ,iCodeDesc           VARCHAR(150)
      ,iExclude            VARCHAR(50)
      ,o_status            INT
      ,o_message           VARCHAR(255)
      ,record_id           INT
      ,static_gid          INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #Payment820TypeCodeListAdd
          (SearchID
          ,iCodeID
          ,record_id
          ,static_gid)
	SELECT ISNULL(SearchID, '')
	      ,ISNULL([820PaymentTypeCode], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_Payment820TypeCodeListPayment820Codes
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #Payment820TypeCodeListAdd
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
DECLARE Payment820TypeCodeListAdd_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iListGid
       ,iKey_2_field
       ,iKey_3_field
       ,iKey_4_field
       ,iKey_5_field
       ,iKey_6_field
       ,iKey_7_field
       ,iKey_8_field
       ,iKey_9_field
       ,iListSid
       ,iAction
       ,iDate_Time_Modified
       ,iUserID
       ,iListID
       ,iListDesc
       ,iCodeID
       ,iCodeDesc
       ,iExclude
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #Payment820TypeCodeListAdd

   OPEN Payment820TypeCodeListAdd_Cursor
  FETCH NEXT FROM Payment820TypeCodeListAdd_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iListGid
       ,@iKey_2_field
       ,@iKey_3_field
       ,@iKey_4_field
       ,@iKey_5_field
       ,@iKey_6_field
       ,@iKey_7_field
       ,@iKey_8_field
       ,@iKey_9_field
       ,@iListSid
       ,@iAction
       ,@iDate_Time_Modified
       ,@iUserID
       ,@iListID
       ,@iListDesc
       ,@iCodeID
       ,@iCodeDesc
       ,@iExclude
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

			SELECT @iListID	= @SearchID

			EXEC dbo.pr820PaymentCodeDetailsAdd
                 @iEntityName
                ,@iListGid
                ,@iKey_2_field
                ,@iKey_3_field
                ,@iKey_4_field
                ,@iKey_5_field
                ,@iKey_6_field
                ,@iKey_7_field
                ,@iKey_8_field
                ,@iKey_9_field
                ,@iListSid
                ,@iAction
                ,@iDate_Time_Modified
                ,@iUserID
                ,@iListID
                ,@iListDesc
                ,@iCodeID
                ,@iCodeDesc
                ,@iExclude
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iListID, @iCodeID, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Payment820TypeCodeListAdd_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iListGid
             ,@iKey_2_field
             ,@iKey_3_field
             ,@iKey_4_field
             ,@iKey_5_field
             ,@iKey_6_field
             ,@iKey_7_field
             ,@iKey_8_field
             ,@iKey_9_field
             ,@iListSid
             ,@iAction
             ,@iDate_Time_Modified
             ,@iUserID
             ,@iListID
             ,@iListDesc
             ,@iCodeID
             ,@iCodeDesc
             ,@iExclude
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE Payment820TypeCodeListAdd_Cursor
DEALLOCATE Payment820TypeCodeListAdd_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#Payment820TypeCodeListAdd') IS NOT NULL
	DROP TABLE #Payment820TypeCodeListAdd

END
GO

