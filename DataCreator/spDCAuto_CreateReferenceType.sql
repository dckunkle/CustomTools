IF OBJECT_ID('dbo.spDCAuto_CreateReferenceType') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateReferenceType AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateReferenceType
Purpose:    Create referencetype data from CorderAutomation
Method:     ReferenceType
Screen GID: 3207
Procedure:  dbo.prReferenceValue_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
02/13/2020	DK				Increased field sizes to avoid string truncation errors
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateReferenceType '100-Config%', 22, 'ReferenceType'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateReferenceType
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

DECLARE @i_Entity_name  VARCHAR(20)
       ,@i_key_1_field  VARCHAR(50)
       ,@i_key_2_field  VARCHAR(50)
       ,@i_key_3_field  VARCHAR(100)
       ,@i_key_4_field  VARCHAR(10)
       ,@i_key_5_field  VARCHAR(50)
       ,@i_key_6_field  VARCHAR(50)
       ,@i_key_7_field  VARCHAR(50)
       ,@i_key_8_field  VARCHAR(50)
       ,@i_key_9_field  VARCHAR(50)
       ,@i_key_10_field VARCHAR(50)
       ,@iAction        VARCHAR(10)
       ,@iModifiedDate  VARCHAR(30)
       ,@iUserID        VARCHAR(25)
       ,@iReferenceType VARCHAR(6)
       ,@iShortDesc     VARCHAR(6)
       ,@iDescription   VARCHAR(100)
       ,@iSequenceNum   INT
       ,@oStatus        INT
       ,@oMessage       VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ReferenceType') IS NOT NULL
	DROP TABLE #ReferenceType

CREATE TABLE #ReferenceType
      (i_Entity_name  VARCHAR(50)       DEFAULT('Reference_Value')
      ,i_key_1_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field  VARCHAR(100)      DEFAULT('0')
      ,i_key_4_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field  VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field VARCHAR(50)       DEFAULT('0')
      ,iAction        VARCHAR(50)       DEFAULT('ADD')
      ,iModifiedDate  VARCHAR(30)       DEFAULT('')
      ,iUserID        VARCHAR(25)       DEFAULT('')
      ,iReferenceType VARCHAR(50)
      ,iShortDesc     VARCHAR(50)
      ,iDescription   VARCHAR(100)
      ,iSequenceNum   INT
      ,oStatus        INT
      ,oMessage       VARCHAR(100)
      ,record_id      INT
      ,static_gid     INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY
	INSERT INTO #ReferenceType
		  (i_key_1_field  
		  ,i_key_2_field  
		  ,i_key_3_field 
		  ,iReferenceType
		  ,iShortDesc
		  ,iDescription
		  ,iSequenceNum
		  ,record_id
		  ,static_gid)
	SELECT ISNULL([ReferenceType], '')
		  ,ISNULL([*SequenceNumber], '')
		  ,ISNULL([*ShortDesc], '')
		  ,ISNULL([ReferenceType], '')
		  ,ISNULL([*ShortDesc], '')
		  ,ISNULL([*Description], '')
		  ,ISNULL([*SequenceNumber], '')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
	  FROM COREAUTO.CoreAutomation.dbo.TD_ReferenceTypeValues
	 WHERE TCID				LIKE @pattern
	   AND ActiveTestCase	= 'A'

	--*************************************************************************************************
	-- Update the user
	--*************************************************************************************************
	UPDATE #ReferenceType
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
DECLARE ReferenceType_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_key_1_field
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
       ,iReferenceType
       ,iShortDesc
       ,iDescription
       ,iSequenceNum
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #ReferenceType

   OPEN ReferenceType_Cursor
  FETCH NEXT FROM ReferenceType_Cursor
   INTO @i_Entity_name
       ,@i_key_1_field
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
       ,@iReferenceType
       ,@iShortDesc
       ,@iDescription
       ,@iSequenceNum
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY
		EXEC dbo.prReferenceValue_AddModify
             @i_Entity_name
            ,@i_key_1_field
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
            ,@iReferenceType
            ,@iShortDesc
            ,@iDescription
            ,@iSequenceNum
            ,@oStatus				= @err_num	OUTPUT
            ,@oMessage				= @err_msg	OUTPUT

		END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iReferenceType, @iShortDesc, @iSequenceNum, @status, @err_num, @err_msg

        FETCH NEXT FROM ReferenceType_Cursor
         INTO @i_Entity_name
             ,@i_key_1_field
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
             ,@iReferenceType
             ,@iShortDesc
             ,@iDescription
             ,@iSequenceNum
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE ReferenceType_Cursor
DEALLOCATE ReferenceType_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#ReferenceType') IS NOT NULL
	DROP TABLE #ReferenceType

END
GO