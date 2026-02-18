/**************************************************************************************************
Name:       spDCAuto_CreateCodePairingRulesAdd
Purpose:    Create codepairingrulesadd data from CorderAutomation

Screen:     803
Method:     CodePairingRulesAdd
Procedure:  dbo.prCodePairRuleAddModify
Entity:     Pairing_Rules

Date        User            Change
---------------------------------------------------------------------------------------------
02/03/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodePairingRulesAdd '100-Config%', 22, 'CodePairingRulesAdd'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateCodePairingRulesAdd
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
       ,@iPairRuleSID       INT
       ,@iKeyField2         VARCHAR(50)
       ,@iKeyField3         VARCHAR(50)
       ,@iKeyField4         VARCHAR(50)
       ,@iKeyField5         VARCHAR(50)
       ,@iKeyField6         VARCHAR(50)
       ,@iKeyField7         VARCHAR(50)
       ,@iKeyField8         VARCHAR(50)
       ,@iKeyField9         VARCHAR(50)
       ,@iKeyField10        VARCHAR(50)
       ,@iAction            VARCHAR(50)
       ,@iDateModified      VARCHAR(50)
       ,@iUserID            VARCHAR(50)
       ,@iEffective_Date    VARCHAR(50)
       ,@iTermination_Date  VARCHAR(50)
       ,@iPriority          VARCHAR(50)
       ,@iCode_Diagnosis    VARCHAR(50)
       ,@iDescription1      VARCHAR(50)
       ,@iCode_TOS          VARCHAR(50)
       ,@iDescription2      VARCHAR(50)
       ,@iCode_POS          VARCHAR(50)
       ,@iDescription3      VARCHAR(50)
       ,@iModifier_1        VARCHAR(50)
       ,@iModifier_2        VARCHAR(50)
       ,@iTypeOfBill        VARCHAR(50)
       ,@iNew_Benefit_Class VARCHAR(50)
       ,@iPOSListID         VARCHAR(100)
       ,@iPOSListDesc       VARCHAR(200)
       ,@iTOBListID         VARCHAR(100)
       ,@iTOBListDesc       VARCHAR(200)
       ,@oStatus            INT
       ,@oMessage           VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodePairingRulesAdd') IS NOT NULL
	DROP TABLE #CodePairingRulesAdd

CREATE TABLE #CodePairingRulesAdd
      (SearchID           VARCHAR(200)
      ,iEntity            VARCHAR(50)       DEFAULT('Pairing_Rules')
      ,iPairRuleSID       INT				DEFAULT('0')
      ,iKeyField2         VARCHAR(50)       DEFAULT('0')
      ,iKeyField3         VARCHAR(50)       DEFAULT('0')
      ,iKeyField4         VARCHAR(50)       DEFAULT('0')
      ,iKeyField5         VARCHAR(50)       DEFAULT('0')
      ,iKeyField6         VARCHAR(50)       DEFAULT('0')
      ,iKeyField7         VARCHAR(50)       DEFAULT('0')
      ,iKeyField8         VARCHAR(50)       DEFAULT('0')
      ,iKeyField9         VARCHAR(50)       DEFAULT('0')
      ,iKeyField10        VARCHAR(50)       DEFAULT('0')
      ,iAction            VARCHAR(50)       DEFAULT('ADD')
      ,iDateModified      VARCHAR(50)       DEFAULT('')
      ,iUserID            VARCHAR(50)       DEFAULT('')
      ,iEffective_Date    VARCHAR(50)
      ,iTermination_Date  VARCHAR(50)
      ,iPriority          VARCHAR(50)
      ,iCode_Diagnosis    VARCHAR(50)
      ,iDescription1      VARCHAR(50)
      ,iCode_TOS          VARCHAR(50)
      ,iDescription2      VARCHAR(50)
      ,iCode_POS          VARCHAR(50)
      ,iDescription3      VARCHAR(50)
      ,iModifier_1        VARCHAR(50)
      ,iModifier_2        VARCHAR(50)
      ,iTypeOfBill        VARCHAR(50)
      ,iNew_Benefit_Class VARCHAR(50)
      ,iPOSListID         VARCHAR(100)
      ,iPOSListDesc       VARCHAR(200)
      ,iTOBListID         VARCHAR(100)
      ,iTOBListDesc       VARCHAR(200)
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

    INSERT INTO #CodePairingRulesAdd
          (SearchID
          ,iEffective_Date
          ,iTermination_Date
          ,iPriority
          ,iCode_Diagnosis
          ,iCode_TOS
          ,iCode_POS
          ,iModifier_1
          ,iModifier_2
          ,iTypeOfBill
          ,iNew_Benefit_Class
          ,iPOSListID
          ,iTOBListID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([*Priority], '-1')
          ,ISNULL([CodeDiagnosis], '')
          ,ISNULL([CodeTOS], '')
          ,ISNULL([CodePOS], '')
          ,ISNULL([Modifier1], '')
          ,ISNULL([Modifier2], '')
          ,ISNULL([TypeOfBill], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NewBenefitClass]), '0')
          ,ISNULL([POSListID], '')
          ,ISNULL([TOBListID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_CodePairingRulesCodePairs
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #CodePairingRulesAdd
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
DECLARE CodePairingRulesAdd_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,iPairRuleSID
       ,iKeyField2
       ,iKeyField3
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iEffective_Date
       ,iTermination_Date
       ,iPriority
       ,iCode_Diagnosis
       ,iDescription1
       ,iCode_TOS
       ,iDescription2
       ,iCode_POS
       ,iDescription3
       ,iModifier_1
       ,iModifier_2
       ,iTypeOfBill
       ,iNew_Benefit_Class
       ,iPOSListID
       ,iPOSListDesc
       ,iTOBListID
       ,iTOBListDesc
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #CodePairingRulesAdd

   OPEN CodePairingRulesAdd_Cursor
  FETCH NEXT FROM CodePairingRulesAdd_Cursor
   INTO @SearchID
       ,@iEntity
       ,@iPairRuleSID
       ,@iKeyField2
       ,@iKeyField3
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iEffective_Date
       ,@iTermination_Date
       ,@iPriority
       ,@iCode_Diagnosis
       ,@iDescription1
       ,@iCode_TOS
       ,@iDescription2
       ,@iCode_POS
       ,@iDescription3
       ,@iModifier_1
       ,@iModifier_2
       ,@iTypeOfBill
       ,@iNew_Benefit_Class
       ,@iPOSListID
       ,@iPOSListDesc
       ,@iTOBListID
       ,@iTOBListDesc
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

			SELECT @iPairRuleSID		= ISNULL(EN.entity_gid, 0)
			  FROM Entity_Names			EN
			 WHERE EN.entity_identifier	= 'Code_Pair_Rules'
			   AND EN.record_status		= 'A'
			   AND EN.entity_user_id	= @SearchID

			IF @iPairRuleSID <> 0
				BEGIN
					EXEC dbo.prCodePairRuleAddModify
						 @iEntity
						,@iPairRuleSID
						,@iKeyField2
						,@iKeyField3
						,@iKeyField4
						,@iKeyField5
						,@iKeyField6
						,@iKeyField7
						,@iKeyField8
						,@iKeyField9
						,@iKeyField10
						,@iAction
						,@iDateModified
						,@iUserID
						,@iEffective_Date
						,@iTermination_Date
						,@iPriority
						,@iCode_Diagnosis
						,@iDescription1
						,@iCode_TOS
						,@iDescription2
						,@iCode_POS
						,@iDescription3
						,@iModifier_1
						,@iModifier_2
						,@iTypeOfBill
						,@iNew_Benefit_Class
						,@iPOSListID
						,@iPOSListDesc
						,@iTOBListID
						,@iTOBListDesc
						,@oStatus     = @err_num OUTPUT
						,@oMessage    = @err_msg OUTPUT
				END
			ELSE
				BEGIN
					SELECT @err_num = 1016
					      ,@err_msg = 'Code Pairing, ' + @SearchID + ', could not be found.'
				END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @iEffective_Date, @iPriority, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM CodePairingRulesAdd_Cursor
         INTO @SearchID
             ,@iEntity
             ,@iPairRuleSID
             ,@iKeyField2
             ,@iKeyField3
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iEffective_Date
             ,@iTermination_Date
             ,@iPriority
             ,@iCode_Diagnosis
             ,@iDescription1
             ,@iCode_TOS
             ,@iDescription2
             ,@iCode_POS
             ,@iDescription3
             ,@iModifier_1
             ,@iModifier_2
             ,@iTypeOfBill
             ,@iNew_Benefit_Class
             ,@iPOSListID
             ,@iPOSListDesc
             ,@iTOBListID
             ,@iTOBListDesc
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE CodePairingRulesAdd_Cursor
DEALLOCATE CodePairingRulesAdd_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#CodePairingRulesAdd') IS NOT NULL
	DROP TABLE #CodePairingRulesAdd

END
GO

