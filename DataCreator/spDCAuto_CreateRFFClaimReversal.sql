/**************************************************************************************************
Name:       spDCAuto_CreateRFFClaimReversal
Purpose:    Create rffclaimreversal data from CorderAutomation

Screen:     0
Method:     RFFClaimReversal
Procedure:  dbo.prOLTPReverseClaim
Entity:     

Date        User            Change
---------------------------------------------------------------------------------------------
09/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateRFFClaimReversal 'RFF-Int-Run1-Claim%', 22, 'RFF-Int-Run1-Claim','RFFClaimReversal', 'RFF-Int-Run1-Claim'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateRFFClaimReversal
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
	   ,@date_submitted				VARCHAR(20)

	   ,@return_code				INT					
	   ,@num_rejects				INT					
	   ,@reject_codes				CHAR(80)			
	   ,@num_msgs					INT					
	   ,@msgs						CHAR(400)			


SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_claim_number      VARCHAR(15)
       ,@i_source            VARCHAR(10)
       ,@i_user_id           VARCHAR(50)
       ,@o_return_code       INT
       ,@o_num_rejects       INT
       ,@o_reject_codes      CHAR(80)
       ,@o_num_msgs          INT
       ,@o_msgs              CHAR(400)
       ,@iDateSubmitted      DATETIME
       ,@iVoidIt             CHAR(1)
       ,@oNewSubmittedDate   DATETIME
       ,@iRemarkCodes        VARCHAR(100)
       ,@iComment            VARCHAR(500)
       ,@iAdjReasonCode      CHAR(2)
       ,@iSentToStaging      VARCHAR(50)
       ,@iVoidItPayerCompass BIT
       ,@iCorrectedClaim     VARCHAR(50)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#RFFClaimReversal') IS NOT NULL
	DROP TABLE #RFFClaimReversal

CREATE TABLE #RFFClaimReversal
      (SearchID            VARCHAR(200)
      ,i_claim_number      VARCHAR(15)
      ,i_source            VARCHAR(10)
      ,i_user_id           VARCHAR(50)
      ,o_return_code       INT 
      ,o_num_rejects       INT 
      ,o_reject_codes      CHAR(80) 
      ,o_num_msgs          INT     
      ,o_msgs              CHAR(400)
      ,iDateSubmitted      DATETIME 
      ,iVoidIt             CHAR(1) 
      ,oNewSubmittedDate   DATETIME  
      ,iRemarkCodes        VARCHAR(100)
      ,iComment            VARCHAR(500)
      ,iAdjReasonCode      CHAR(2)
      ,iSentToStaging      VARCHAR(50)
      ,iVoidItPayerCompass BIT
      ,iCorrectedClaim     VARCHAR(50)
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

    INSERT INTO #RFFClaimReversal
          (SearchID
          ,i_claim_number
          ,i_source
          ,i_user_id
          ,o_return_code
          ,o_num_rejects
          ,o_reject_codes
          ,o_num_msgs
          ,o_msgs
          ,iDateSubmitted
          ,iVoidIt
          ,oNewSubmittedDate
          ,iRemarkCodes
          ,iComment
          ,iAdjReasonCode
          ,iSentToStaging
          ,iVoidItPayerCompass
          ,iCorrectedClaim
		  ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([i_claim_number], '')
          ,ISNULL([i_source], '')
          ,ISNULL([i_user_id], '')
          ,ISNULL([o_return_code], '')
          ,ISNULL([o_num_rejects], '')
          ,ISNULL([o_reject_codes], '')
          ,ISNULL([o_num_msgs], '')
          ,ISNULL([o_msgs], '')
          ,ISNULL([iDateSubmitted], '')
          ,ISNULL([iVoidIt], '')
          ,ISNULL([oNewSubmittedDate], '')
          ,ISNULL([iRemarkCodes], '')
          ,ISNULL([iComment], '')
          ,ISNULL([iAdjReasonCode], '')
          ,ISNULL([iSentToStaging], '')
          ,ISNULL([iVoidItPayerCompass], '')
          ,ISNULL([iCorrectedClaim], '')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_RFFClaimReversal
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #RFFClaimReversal
       SET i_user_id  = @user


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
DECLARE RFFClaimReversal_Cursor CURSOR FOR
 SELECT SearchID
       ,i_claim_number
       ,i_source
       ,i_user_id
       ,o_return_code
       ,o_num_rejects
       ,o_reject_codes
       ,o_num_msgs
       ,o_msgs
       ,iDateSubmitted
       ,iVoidIt
       ,oNewSubmittedDate
       ,iRemarkCodes
       ,iComment
       ,iAdjReasonCode
       ,iSentToStaging
       ,iVoidItPayerCompass
       ,iCorrectedClaim
       ,record_id
       ,static_gid
   FROM #RFFClaimReversal

   OPEN RFFClaimReversal_Cursor
  FETCH NEXT FROM RFFClaimReversal_Cursor
   INTO @SearchID
       ,@i_claim_number
       ,@i_source
       ,@i_user_id
       ,@o_return_code
       ,@o_num_rejects
       ,@o_reject_codes
       ,@o_num_msgs
       ,@o_msgs
       ,@iDateSubmitted
       ,@iVoidIt
       ,@oNewSubmittedDate
       ,@iRemarkCodes
       ,@iComment
       ,@iAdjReasonCode
       ,@iSentToStaging
       ,@iVoidItPayerCompass
       ,@iCorrectedClaim
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Make sure to grab the Auth Match ID to search for
			TRUNCATE TABLE #Tokens
			INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
			SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

			--Lookup date_submitted for the claim being reversed
			SELECT @iDateSubmitted			= CL.date_submitted
			  FROM dbo.Claims_Log_V2		CL
			 WHERE CL.claim_number			= @i_claim_number

			IF ISNULL(@iDateSubmitted, '') = ''
				BEGIN

					SELECT @err_num = 4001
					      ,@err_msg = 'The date_submitted could not be found for claim number, ' + @i_claim_number + ', can not reverse claim.'
				END
			ELSE
				BEGIN
					EXEC dbo.prOLTPReverseClaim
						 @i_claim_number
						,@i_source				
						,@i_user_id				= @i_user_id
						,@o_return_code			= @return_code		OUTPUT
						,@o_num_rejects			= @num_rejects		OUTPUT
						,@o_reject_codes		= @reject_codes		OUTPUT
						,@o_num_msgs			= @num_msgs			OUTPUT
						,@o_msgs				= @msgs				OUTPUT
						,@iDateSubmitted		= @iDateSubmitted
						,@iVoidIt				= @iVoidIt
						,@oNewSubmittedDate		= @oNewSubmittedDate
						,@iRemarkCodes			= @iRemarkCodes
						,@iComment				= @iComment
						,@iAdjReasonCode		= @iAdjReasonCode
						,@iSentToStaging		= @iSentToStaging
						,@iVoidItPayerCompass	= @iVoidItPayerCompass
						,@iCorrectedClaim		= @iCorrectedClaim
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @date_submitted = CONVERT(VARCHAR(20), @iDateSubmitted, 120)
		SELECT @status = 'Add'
		      ,@err_num = 0
			  ,@err_msg = ''

		-- An error occured, document it
		IF @return_code <> 0
			BEGIN
				SELECT @status	= 'Error'
				      ,@err_num	= @return_code
				      ,@err_msg	= @msgs
			END

		IF @num_rejects <> 0
			BEGIN
				SELECT @status	= 'Error'
				      ,@err_num	= @num_rejects
				      ,@err_msg	= @num_rejects
			END

        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_claim_number, @date_submitted, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.200';

        FETCH NEXT FROM RFFClaimReversal_Cursor
         INTO @SearchID
             ,@i_claim_number
             ,@i_source
             ,@i_user_id
             ,@o_return_code
             ,@o_num_rejects
             ,@o_reject_codes
             ,@o_num_msgs
             ,@o_msgs
             ,@iDateSubmitted
             ,@iVoidIt
             ,@oNewSubmittedDate
             ,@iRemarkCodes
             ,@iComment
             ,@iAdjReasonCode
             ,@iSentToStaging
             ,@iVoidItPayerCompass
             ,@iCorrectedClaim
             ,@record_id
             ,@static_gid
	END

CLOSE RFFClaimReversal_Cursor
DEALLOCATE RFFClaimReversal_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#RFFClaimReversal') IS NOT NULL
	DROP TABLE #RFFClaimReversal

END
GO

