/**************************************************************************************************
Name:       spDCAuto_CreateMemberPaperlessCorrespondence
Purpose:    Create memberpaperlesscorrespondence data from CorderAutomation

Screen:     5001
Method:     MemberPaperlessCorrespondence
Procedure:  dbo.prContactCorrespondencePreferenceSave
Entity:     Paperless

Date        User            Change
---------------------------------------------------------------------------------------------
01/25/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMemberPaperlessCorrespondence '500-TestCase-250-040', 22, '500-TestCase-250-040', 'MemberPaperlessCorrespondence', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateMemberPaperlessCorrespondence
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
	   ,@rows						VARCHAR(8000)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iChildGID            VARCHAR(200)
       ,@iParentGID           VARCHAR(200)
       ,@iUserID              VARCHAR(50)
       ,@iFormID              VARCHAR(25)
       ,@iPreferenceSelection XML
	   ,@iSelectionType1	  VARCHAR(75)
	   ,@iCorrespondenceType1 VARCHAR(75)
	   ,@iSelectionType2	  VARCHAR(75)
	   ,@iCorrespondenceType2 VARCHAR(75)
	   ,@iSelectionType3	  VARCHAR(75)
	   ,@iCorrespondenceType3 VARCHAR(75)
       ,@oStatus              INT
       ,@oMessage             VARCHAR(500)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MemberPaperlessCorrespondence') IS NOT NULL
	DROP TABLE #MemberPaperlessCorrespondence

CREATE TABLE #MemberPaperlessCorrespondence
      (SearchID             VARCHAR(200)
      ,iChildGID            VARCHAR(200)       DEFAULT('0')
      ,iParentGID           VARCHAR(200)       DEFAULT('0')
      ,iUserID              VARCHAR(50)        
      ,iFormID              VARCHAR(25)        DEFAULT('PAPERLESS')
      ,iPreferenceSelection XML		
	  ,iSelectionType1		VARCHAR(75)
	  ,iCorrespndenceType1	VARCHAR(75)
	  ,iSelectionType2		VARCHAR(75)
	  ,iCorrespndenceType2	VARCHAR(75)
	  ,iSelectionType3		VARCHAR(75)
	  ,iCorrespndenceType3	VARCHAR(75)
      ,oStatus              INT                
      ,oMessage             VARCHAR(500)       
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
BEGIN TRY

    INSERT INTO #MemberPaperlessCorrespondence
          (SearchID
		  ,iSelectionType1
		  ,iCorrespndenceType1
		  ,iSelectionType2
		  ,iCorrespndenceType2
		  ,iSelectionType3
		  ,iCorrespndenceType3
		  ,record_id
          ,static_gid)
    SELECT SearchID
          ,dbo.fnDCAuto_GetPaperlessSelection(ISNULL([SelectionType_1], ''))
          ,dbo.fnDCAuto_GetPaperlessCorrespondence(ISNULL([CorrespondenceType_1], ''))
          ,dbo.fnDCAuto_GetPaperlessSelection(ISNULL([SelectionType_2], ''))
          ,dbo.fnDCAuto_GetPaperlessCorrespondence(ISNULL([CorrespondenceType_2], ''))
          ,dbo.fnDCAuto_GetPaperlessSelection(ISNULL([SelectionType_3], ''))
		  ,dbo.fnDCAuto_GetPaperlessCorrespondence(ISNULL([CorrespondenceType_3], ''))
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_MemberPaperlessCorrespondence
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #MemberPaperlessCorrespondence
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
DECLARE MemberPaperlessCorrespondence_Cursor CURSOR FOR
 SELECT SearchID
       ,iChildGID
       ,iParentGID
       ,iUserID
       ,iFormID
       ,iPreferenceSelection
	   ,iSelectionType1	  
	   ,iCorrespndenceType1
	   ,iSelectionType2
	   ,iCorrespndenceType2
	   ,iSelectionType3
	   ,iCorrespndenceType3
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #MemberPaperlessCorrespondence

   OPEN MemberPaperlessCorrespondence_Cursor
  FETCH NEXT FROM MemberPaperlessCorrespondence_Cursor
   INTO @SearchID
       ,@iChildGID
       ,@iParentGID
       ,@iUserID
       ,@iFormID
       ,@iPreferenceSelection
	   ,@iSelectionType1	  
	   ,@iCorrespondenceType1
	   ,@iSelectionType2
	   ,@iCorrespondenceType2
	   ,@iSelectionType3
	   ,@iCorrespondenceType3
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

			SELECT @iChildGID				= EC.child_gid
			      ,@iParentGID				= EC.parent_gid
			  FROM Eligibility_Coverage		EC
			 WHERE member_id				= @SearchID
			   AND EC.record_status			= 'A'
			   AND EC.child_gid				= EC.parent_gid

			PRINT @iCorrespondenceType1

			-- Build the appropriate XML for the selections
			SELECT @rows = '<rows>' +
			               CASE WHEN @iCorrespondenceType1 <> '' THEN '<row CorrespondenceType="' + @iCorrespondenceType1 + '" SelectionType="' + @iSelectionType1 + '"/>' ELSE '' END +
						   CASE WHEN @iCorrespondenceType2 <> '' THEN '<row CorrespondenceType="' + @iCorrespondenceType2 + '" SelectionType="' + @iSelectionType2 + '"/>' ELSE '' END +
						   CASE WHEN @iCorrespondenceType3 <> '' THEN '<row CorrespondenceType="' + @iCorrespondenceType3 + '" SelectionType="' + @iSelectionType3 + '"/>' ELSE '' END +
						   '</rows>'

			SELECT @iPreferenceSelection = @rows

			-- If the member was found then execute the stored procedure
			IF @iChildGID <> 0
				BEGIN

					EXEC dbo.prContactCorrespondencePreferenceSave
						 @iChildGID
						,@iParentGID
						,@iUserID
						,@iFormID
						,@iPreferenceSelection
						,@oStatus     = @err_num OUTPUT
						,@oMessage    = @err_msg OUTPUT
				END
			ELSE
				BEGIN
					SELECT @err_num = 1016
					      ,@err_msg = 'Member,' + @SearchID + ', could not be found.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, '', '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM MemberPaperlessCorrespondence_Cursor
         INTO @SearchID
             ,@iChildGID
             ,@iParentGID
             ,@iUserID
             ,@iFormID
             ,@iPreferenceSelection
			 ,@iSelectionType1	  
		     ,@iCorrespondenceType1
		     ,@iSelectionType2
		     ,@iCorrespondenceType2
		     ,@iSelectionType3
		     ,@iCorrespondenceType3
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE MemberPaperlessCorrespondence_Cursor
DEALLOCATE MemberPaperlessCorrespondence_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#MemberPaperlessCorrespondence') IS NOT NULL
	DROP TABLE #MemberPaperlessCorrespondence

END
GO

