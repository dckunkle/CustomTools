/**************************************************************************************************
Name:       spDCAuto_CreateCPTPlaceOfServicePairsAdd
Purpose:    Create CPTplaceofservicepairsadd data from CorderAutomation

Screen:     802
Method:     CPT-PlaceOfServicePairsAdd
Procedure:  dbo.prCodePairCPTtoPOSAddModify
Entity:     CPTToPOS

Date        User            Change
---------------------------------------------------------------------------------------------
02/07/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCPTPlaceOfServicePairsAdd '100-Config%', 22, 'CPT-PlaceOfServicePairsAdd'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateCPTPlaceOfServicePairsAdd
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

DECLARE @iEntity            VARCHAR(50)
       ,@iKeyPairSID        INT
       ,@iKeyPairType       VARCHAR(50)
       ,@iKeyEffDate        VARCHAR(50)
       ,@iKeyTermDate       VARCHAR(50)
       ,@iKeyProcStart      VARCHAR(50)
       ,@iKeyProcEnd        VARCHAR(50)
       ,@iKeyProcList       VARCHAR(50)
       ,@iKeyPOS1           VARCHAR(50)
       ,@iKeyPOS2           VARCHAR(50)
       ,@iKey10             VARCHAR(50)
       ,@iAction            VARCHAR(10)
       ,@iDateModified      VARCHAR(50)
       ,@iUserID            VARCHAR(25)
       ,@iEffective_Date    VARCHAR(50)
       ,@iTermination_Date  VARCHAR(50)
       ,@iCode_Start        VARCHAR(50)
       ,@iCode_Description1 VARCHAR(300)
       ,@iCode_End          VARCHAR(50)
       ,@iCode_Description2 VARCHAR(300)
       ,@iCode_List_ID      VARCHAR(50)
       ,@iCode_List_Desc    VARCHAR(50)
       ,@iPOS_Start         VARCHAR(50)
       ,@iCode_Description3 VARCHAR(50)
       ,@iPOS_End           VARCHAR(50)
       ,@iCode_Description4 VARCHAR(50)
       ,@iPOSListID         VARCHAR(50)
       ,@iPOSListDesc       VARCHAR(100)
       ,@oStatus            INT
       ,@oMessage           VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CPTPlaceOfServicePairsAdd') IS NOT NULL
	DROP TABLE #CPTPlaceOfServicePairsAdd

CREATE TABLE #CPTPlaceOfServicePairsAdd
      (SearchID           VARCHAR(200)
      ,iEntity            VARCHAR(50)       DEFAULT('CPTToPOS')
      ,iKeyPairSID        INT				DEFAULT('0')
      ,iKeyPairType       VARCHAR(50)       DEFAULT('0')
      ,iKeyEffDate        VARCHAR(50)       DEFAULT('0')
      ,iKeyTermDate       VARCHAR(50)       DEFAULT('0')
      ,iKeyProcStart      VARCHAR(50)       DEFAULT('0')
      ,iKeyProcEnd        VARCHAR(50)       DEFAULT('0')
      ,iKeyProcList       VARCHAR(50)       DEFAULT('0')
      ,iKeyPOS1           VARCHAR(50)       DEFAULT('0')
      ,iKeyPOS2           VARCHAR(50)       DEFAULT('0')
      ,iKey10             VARCHAR(50)       DEFAULT('0')
      ,iAction            VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified      VARCHAR(50)       DEFAULT('')
      ,iUserID            VARCHAR(25)       DEFAULT('')
      ,iEffective_Date    VARCHAR(50)
      ,iTermination_Date  VARCHAR(50)
      ,iCode_Start        VARCHAR(50)
      ,iCode_Description1 VARCHAR(300)
      ,iCode_End          VARCHAR(50)
      ,iCode_Description2 VARCHAR(300)
      ,iCode_List_ID      VARCHAR(50)
      ,iCode_List_Desc    VARCHAR(50)
      ,iPOS_Start         VARCHAR(50)
      ,iCode_Description3 VARCHAR(50)
      ,iPOS_End           VARCHAR(50)
      ,iCode_Description4 VARCHAR(50)
      ,iPOSListID         VARCHAR(50)
      ,iPOSListDesc       VARCHAR(100)
      ,oStatus            INT
      ,oMessage           VARCHAR(250)
      ,record_id          INT
      ,static_gid         INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #CPTPlaceOfServicePairsAdd
          (SearchID
          ,iEffective_Date
          ,iTermination_Date
          ,iCode_Start
          ,iCode_End
          ,iCode_List_ID
          ,iPOS_Start
          ,iPOS_End
          ,iPOSListID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([CodeStart], '')
          ,ISNULL([CodeEnd], '')
          ,ISNULL([CodeListID], '')
          ,ISNULL([POSStart], '')
          ,ISNULL([POSEnd], '')
          ,ISNULL([POSList], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_CPTPlaceOfServicePairsCodeToPOSPairingAdd
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CPTPlaceOfServicePairsAdd
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
DECLARE CPTPlaceOfServicePairsAdd_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iKeyPairSID
       ,iKeyPairType
       ,iKeyEffDate
       ,iKeyTermDate
       ,iKeyProcStart
       ,iKeyProcEnd
       ,iKeyProcList
       ,iKeyPOS1
       ,iKeyPOS2
       ,iKey10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iEffective_Date
       ,iTermination_Date
       ,iCode_Start
       ,iCode_Description1
       ,iCode_End
       ,iCode_Description2
       ,iCode_List_ID
       ,iCode_List_Desc
       ,iPOS_Start
       ,iCode_Description3
       ,iPOS_End
       ,iCode_Description4
       ,iPOSListID
       ,iPOSListDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #CPTPlaceOfServicePairsAdd

   OPEN CPTPlaceOfServicePairsAdd_Cursor
  FETCH NEXT FROM CPTPlaceOfServicePairsAdd_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iKeyPairSID
       ,@iKeyPairType
       ,@iKeyEffDate
       ,@iKeyTermDate
       ,@iKeyProcStart
       ,@iKeyProcEnd
       ,@iKeyProcList
       ,@iKeyPOS1
       ,@iKeyPOS2
       ,@iKey10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iEffective_Date
       ,@iTermination_Date
       ,@iCode_Start
       ,@iCode_Description1
       ,@iCode_End
       ,@iCode_Description2
       ,@iCode_List_ID
       ,@iCode_List_Desc
       ,@iPOS_Start
       ,@iCode_Description3
       ,@iPOS_End
       ,@iCode_Description4
       ,@iPOSListID
       ,@iPOSListDesc
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

			SELECT @iKeyPairSID			= ISNULL(EN.entity_gid, 0)
			  FROM Entity_Names			EN
			 WHERE EN.entity_identifier	= 'Code_Pairs'
			   AND EN.record_status		= 'A'
			   AND EN.entity_user_id	= @SearchID

			IF @iKeyPairSID <> 0
				BEGIN
					EXEC dbo.prCodePairCPTtoPOSAddModify
						 @iEntity
						,@iKeyPairSID
						,@iKeyPairType
						,@iKeyEffDate
						,@iKeyTermDate
						,@iKeyProcStart
						,@iKeyProcEnd
						,@iKeyProcList
						,@iKeyPOS1
						,@iKeyPOS2
						,@iKey10
						,@iAction
						,@iDateModified
						,@iUserID
						,@iEffective_Date
						,@iTermination_Date
						,@iCode_Start
						,@iCode_Description1
						,@iCode_End
						,@iCode_Description2
						,@iCode_List_ID
						,@iCode_List_Desc
						,@iPOS_Start
						,@iCode_Description3
						,@iPOS_End
						,@iCode_Description4
						,@iPOSListID
						,@iPOSListDesc
						,@oStatus     = @err_num OUTPUT
						,@oMessage    = @err_msg OUTPUT

				END
			ELSE
				BEGIN
					SELECT @err_num = 1016
					      ,@err_msg = 'Code Pairs,' + @SearchID + ', could not be found.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iEffective_Date, @iTermination_Date, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CPTPlaceOfServicePairsAdd_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iKeyPairSID
             ,@iKeyPairType
             ,@iKeyEffDate
             ,@iKeyTermDate
             ,@iKeyProcStart
             ,@iKeyProcEnd
             ,@iKeyProcList
             ,@iKeyPOS1
             ,@iKeyPOS2
             ,@iKey10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iEffective_Date
             ,@iTermination_Date
             ,@iCode_Start
             ,@iCode_Description1
             ,@iCode_End
             ,@iCode_Description2
             ,@iCode_List_ID
             ,@iCode_List_Desc
             ,@iPOS_Start
             ,@iCode_Description3
             ,@iPOS_End
             ,@iCode_Description4
             ,@iPOSListID
             ,@iPOSListDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE CPTPlaceOfServicePairsAdd_Cursor
DEALLOCATE CPTPlaceOfServicePairsAdd_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CPTPlaceOfServicePairsAdd') IS NOT NULL
	DROP TABLE #CPTPlaceOfServicePairsAdd

END
GO

