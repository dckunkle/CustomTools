IF OBJECT_ID('dbo.spDCAuto_CreateCodeRules') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeRules AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeRules
Purpose:    Create coderules data from CorderAutomation
Method:     CodeRules
Screen GID: 3010
Procedure:  dbo.prProdRulesAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeRules '100-Config%', 22, 'CodeRules'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeRules
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
       ,@i_Key_Rule_GID         VARCHAR(50)
       ,@i_key_2_field          VARCHAR(50)
       ,@i_key_3_field          VARCHAR(50)
       ,@i_key_4_field          VARCHAR(50)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(30)
       ,@iUserID                VARCHAR(25)
       ,@iRule_ID               VARCHAR(50)
       ,@iRule_Description      VARCHAR(50)
       ,@iEffective_Date        VARCHAR(50)
       ,@iTermination_Date      VARCHAR(50)
       ,@iDefault_Status        VARCHAR(50)
       ,@iOverride_Benefit      VARCHAR(50)
       ,@iMin_Age               VARCHAR(50)
       ,@iMin_Age_Option        VARCHAR(50)
       ,@iMax_Age               VARCHAR(50)
       ,@iMax_Age_Option        VARCHAR(50)
       ,@iGender_Covered        VARCHAR(50)
       ,@iValid_Relationship    VARCHAR(50)
       ,@iCoverage_Start_Days   VARCHAR(50)
       ,@iMax_Begin_Age         VARCHAR(50)
       ,@iProc_Policy1          VARCHAR(50)
       ,@iProc_Policy_Desc1     VARCHAR(100)
       ,@iProc_Policy2          VARCHAR(50)
       ,@iProc_Policy_Desc2     VARCHAR(100)
       ,@iDiagnosis_List        VARCHAR(50)
       ,@iDiagnosis_Name        VARCHAR(50)
       ,@iESPDT_service         VARCHAR(50)
       ,@iOrderable             VARCHAR(50)
       ,@iPCPRequired           VARCHAR(50)
       ,@iPrice_Strategy_ID     VARCHAR(50)
       ,@iPrice_Strategy_Name   VARCHAR(50)
       ,@iCopay_Strategy_ID     VARCHAR(50)
       ,@iCopay_Strategy_Name   VARCHAR(50)
       ,@iBenefit_Strategy_ID   VARCHAR(50)
       ,@iBenefit_Strategy_Name VARCHAR(50)
       ,@iExcludeDed            VARCHAR(50)
       ,@iExcludeOOP            VARCHAR(50)
       ,@iExcludeMax            VARCHAR(50)
       ,@iExcludeCOB            VARCHAR(50)
       ,@iMin_Dose              VARCHAR(50)
       ,@iMax_Dose              VARCHAR(50)
       ,@iMin_Qty               VARCHAR(50)
       ,@iMax_Qty               VARCHAR(50)
       ,@iMin_Days              VARCHAR(50)
       ,@iMax_Days              VARCHAR(50)
       ,@iMax_Qty_Over_Time     VARCHAR(50)
       ,@iMax_Days_Over_Time    VARCHAR(50)
       ,@iMax_Qty_OT_Option     VARCHAR(50)
       ,@iMax_Days_OT_Option    VARCHAR(50)
       ,@iMax_Qty_OT_Amount     VARCHAR(50)
       ,@iMax_Days_OT_Amount    VARCHAR(50)
       ,@iMax_Fills_Over_Time   VARCHAR(50)
       ,@iMax_Fills_OT_Option   VARCHAR(50)
       ,@iMax_Fills_OT_Amount   VARCHAR(50)
       ,@iMail_Order_Flag       VARCHAR(50)
       ,@iTooth_Type            VARCHAR(50)
       ,@iPrimary_Prov_Req      VARCHAR(50)
       ,@iClinical_Doc          VARCHAR(50)
       ,@iSpecialty_Req         VARCHAR(50)
       ,@iCredentialling_Req    VARCHAR(50)
       ,@iPOARuleID             VARCHAR(50)
       ,@iPOARuleDesc           VARCHAR(50)
       ,@iNDCReq                VARCHAR(50)
       ,@oStatus                INT
       ,@oMessage               VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeRules') IS NOT NULL
	DROP TABLE #CodeRules

CREATE TABLE #CodeRules
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(50)       DEFAULT('Product_Rules')
      ,i_Key_Rule_GID         VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserID                VARCHAR(25)       DEFAULT('')
      ,iRule_ID               VARCHAR(50)
      ,iRule_Description      VARCHAR(50)
      ,iEffective_Date        VARCHAR(50)
      ,iTermination_Date      VARCHAR(50)
      ,iDefault_Status        VARCHAR(50)
      ,iOverride_Benefit      VARCHAR(50)
      ,iMin_Age               VARCHAR(50)
      ,iMin_Age_Option        VARCHAR(50)
      ,iMax_Age               VARCHAR(50)
      ,iMax_Age_Option        VARCHAR(50)
      ,iGender_Covered        VARCHAR(50)
      ,iValid_Relationship    VARCHAR(50)
      ,iCoverage_Start_Days   VARCHAR(50)
      ,iMax_Begin_Age         VARCHAR(50)
      ,iProc_Policy1          VARCHAR(50)
      ,iProc_Policy_Desc1     VARCHAR(100)
      ,iProc_Policy2          VARCHAR(50)
      ,iProc_Policy_Desc2     VARCHAR(100)
      ,iDiagnosis_List        VARCHAR(50)
      ,iDiagnosis_Name        VARCHAR(50)
      ,iESPDT_service         VARCHAR(50)
      ,iOrderable             VARCHAR(50)
      ,iPCPRequired           VARCHAR(50)
      ,iPrice_Strategy_ID     VARCHAR(50)
      ,iPrice_Strategy_Name   VARCHAR(50)
      ,iCopay_Strategy_ID     VARCHAR(50)
      ,iCopay_Strategy_Name   VARCHAR(50)
      ,iBenefit_Strategy_ID   VARCHAR(50)
      ,iBenefit_Strategy_Name VARCHAR(50)
      ,iExcludeDed            VARCHAR(50)
      ,iExcludeOOP            VARCHAR(50)
      ,iExcludeMax            VARCHAR(50)
      ,iExcludeCOB            VARCHAR(50)
      ,iMin_Dose              VARCHAR(50)
      ,iMax_Dose              VARCHAR(50)
      ,iMin_Qty               VARCHAR(50)
      ,iMax_Qty               VARCHAR(50)
      ,iMin_Days              VARCHAR(50)
      ,iMax_Days              VARCHAR(50)
      ,iMax_Qty_Over_Time     VARCHAR(50)
      ,iMax_Days_Over_Time    VARCHAR(50)
      ,iMax_Qty_OT_Option     VARCHAR(50)
      ,iMax_Days_OT_Option    VARCHAR(50)
      ,iMax_Qty_OT_Amount     VARCHAR(50)
      ,iMax_Days_OT_Amount    VARCHAR(50)
      ,iMax_Fills_Over_Time   VARCHAR(50)
      ,iMax_Fills_OT_Option   VARCHAR(50)
      ,iMax_Fills_OT_Amount   VARCHAR(50)
      ,iMail_Order_Flag       VARCHAR(50)
      ,iTooth_Type            VARCHAR(50)
      ,iPrimary_Prov_Req      VARCHAR(50)
      ,iClinical_Doc          VARCHAR(50)
      ,iSpecialty_Req         VARCHAR(50)
      ,iCredentialling_Req    VARCHAR(50)
      ,iPOARuleID             VARCHAR(50)
      ,iPOARuleDesc           VARCHAR(50)
      ,iNDCReq                VARCHAR(50)
      ,oStatus                INT
      ,oMessage               VARCHAR(100)
      ,record_id              INT
      ,static_gid             INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeRules
      (SearchID
      ,iRule_ID
      ,iRule_Description
      ,iEffective_Date
      ,iTermination_Date
      ,iDefault_Status
      ,iOverride_Benefit
      ,iMin_Age
      ,iMin_Age_Option
      ,iMax_Age
      ,iMax_Age_Option
      ,iGender_Covered
      ,iValid_Relationship
      ,iCoverage_Start_Days
      ,iMax_Begin_Age
      ,iProc_Policy1
      ,iProc_Policy2
      ,iDiagnosis_List
      ,iESPDT_service
      ,iOrderable
      ,iPCPRequired
      ,iPrice_Strategy_ID
      ,iCopay_Strategy_ID
      ,iBenefit_Strategy_ID
      ,iExcludeDed
      ,iExcludeOOP
      ,iExcludeMax
      ,iExcludeCOB
      ,iMin_Dose
      ,iMax_Dose
      ,iMin_Qty
      ,iMax_Qty
      ,iMin_Days
      ,iMax_Days
      ,iMax_Qty_Over_Time
      ,iMax_Days_Over_Time
      ,iMax_Qty_OT_Option
      ,iMax_Days_OT_Option
      ,iMax_Qty_OT_Amount
      ,iMax_Days_OT_Amount
      ,iMax_Fills_Over_Time
      ,iMax_Fills_OT_Option
      ,iMax_Fills_OT_Amount
      ,iMail_Order_Flag
      ,iTooth_Type
      ,iPrimary_Prov_Req
	  ,iClinical_Doc
      ,iSpecialty_Req
      ,iCredentialling_Req
      ,iPOARuleID
      ,iNDCReq
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Common_RuleID], '')
      ,ISNULL([*Common_RuleDesc], '')
      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*Common_TerDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_DefaultStatus]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_OverrideBen]), '0')
      ,ISNULL([Common_MinAgeLimit], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MinAgeOption]), '')
      ,ISNULL([Common_MaxAgeLimit], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MaxAgeOption]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_GenCovered]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_ValidRelation]), '')
      ,ISNULL([Common_CoverStartDays], '0')
      ,ISNULL([Common_MaxBeginAge], '0')
      ,ISNULL([Common_RemarkCodeID], '')
      ,ISNULL([Common_RemarkCodeID2], '')
      ,ISNULL([Common_DiagnosisID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_MarkClaimEPSDTSer]), 'U')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_OrderableDME]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_PCPReqforAdj]), 'P')
      ,ISNULL([BenOverride_PriceStratID], '')
      ,ISNULL([BenOverride_SpecCopayLevelID], '')
      ,ISNULL([BenOverride_BenStratID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenOverride_ExcfromDeduct]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenOverride_ExcfromOutofPocket]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenOverride_ExcfromMax]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([BenOverride_ExcfromCOBVal]), 'N')
      ,ISNULL([DrugRules_MinDose], '0')
      ,ISNULL([DrugRules_MaxDose], '0')
      ,ISNULL([DrugRules_MinQuantity], '0.00')
      ,ISNULL([DrugRules_MaxQuantity], '0.00')
      ,ISNULL([DrugRules_MinDaysSupply], '0')
      ,ISNULL([DrugRules_MaxDaysSupply], '0')
      ,ISNULL([DrugRules_MaxQtyOverTime], '0.00')
      ,ISNULL([DrugRules_MaxDaysOverTime], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugRules_MaxQtyTimePeriod]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugRules_MaxDaysTimePeriod]), '')
      ,ISNULL([DrugRules_MaxQtyPeriodAmt], '0')
      ,ISNULL([DrugRules_MaxDaysPeriodAmt], '0')
      ,ISNULL([DrugRules_MaxFillsOverTime], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugRules_MaxFillsTimePeriod]), '')
      ,ISNULL([DrugRules_MaxFillsPeriodAmt], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugRules_MailOrderReq]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalRules_ToothType]), 'DF')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalRules_PrimProvReq]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalRules_ClinicalDoc]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalRules_SpecialtyReq]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalRules_CredenReq]), 'N')
      ,ISNULL([MedRules_POARuleID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MedRules_NDCReqonJCode]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeRules
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeRules
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeRules_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Key_Rule_GID
       ,i_key_2_field
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,iRule_ID
       ,iRule_Description
       ,iEffective_Date
       ,iTermination_Date
       ,iDefault_Status
       ,iOverride_Benefit
       ,iMin_Age
       ,iMin_Age_Option
       ,iMax_Age
       ,iMax_Age_Option
       ,iGender_Covered
       ,iValid_Relationship
       ,iCoverage_Start_Days
       ,iMax_Begin_Age
       ,iProc_Policy1
       ,iProc_Policy_Desc1
       ,iProc_Policy2
       ,iProc_Policy_Desc2
       ,iDiagnosis_List
       ,iDiagnosis_Name
       ,iESPDT_service
       ,iOrderable
       ,iPCPRequired
       ,iPrice_Strategy_ID
       ,iPrice_Strategy_Name
       ,iCopay_Strategy_ID
       ,iCopay_Strategy_Name
       ,iBenefit_Strategy_ID
       ,iBenefit_Strategy_Name
       ,iExcludeDed
       ,iExcludeOOP
       ,iExcludeMax
       ,iExcludeCOB
       ,iMin_Dose
       ,iMax_Dose
       ,iMin_Qty
       ,iMax_Qty
       ,iMin_Days
       ,iMax_Days
       ,iMax_Qty_Over_Time
       ,iMax_Days_Over_Time
       ,iMax_Qty_OT_Option
       ,iMax_Days_OT_Option
       ,iMax_Qty_OT_Amount
       ,iMax_Days_OT_Amount
       ,iMax_Fills_Over_Time
       ,iMax_Fills_OT_Option
       ,iMax_Fills_OT_Amount
       ,iMail_Order_Flag
       ,iTooth_Type
       ,iPrimary_Prov_Req
       ,iClinical_Doc
       ,iSpecialty_Req
       ,iCredentialling_Req
       ,iPOARuleID
       ,iPOARuleDesc
       ,iNDCReq
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #CodeRules

   OPEN CodeRules_Cursor
  FETCH NEXT FROM CodeRules_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Key_Rule_GID
       ,@i_key_2_field
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@iRule_ID
       ,@iRule_Description
       ,@iEffective_Date
       ,@iTermination_Date
       ,@iDefault_Status
       ,@iOverride_Benefit
       ,@iMin_Age
       ,@iMin_Age_Option
       ,@iMax_Age
       ,@iMax_Age_Option
       ,@iGender_Covered
       ,@iValid_Relationship
       ,@iCoverage_Start_Days
       ,@iMax_Begin_Age
       ,@iProc_Policy1
       ,@iProc_Policy_Desc1
       ,@iProc_Policy2
       ,@iProc_Policy_Desc2
       ,@iDiagnosis_List
       ,@iDiagnosis_Name
       ,@iESPDT_service
       ,@iOrderable
       ,@iPCPRequired
       ,@iPrice_Strategy_ID
       ,@iPrice_Strategy_Name
       ,@iCopay_Strategy_ID
       ,@iCopay_Strategy_Name
       ,@iBenefit_Strategy_ID
       ,@iBenefit_Strategy_Name
       ,@iExcludeDed
       ,@iExcludeOOP
       ,@iExcludeMax
       ,@iExcludeCOB
       ,@iMin_Dose
       ,@iMax_Dose
       ,@iMin_Qty
       ,@iMax_Qty
       ,@iMin_Days
       ,@iMax_Days
       ,@iMax_Qty_Over_Time
       ,@iMax_Days_Over_Time
       ,@iMax_Qty_OT_Option
       ,@iMax_Days_OT_Option
       ,@iMax_Qty_OT_Amount
       ,@iMax_Days_OT_Amount
       ,@iMax_Fills_Over_Time
       ,@iMax_Fills_OT_Option
       ,@iMax_Fills_OT_Amount
       ,@iMail_Order_Flag
       ,@iTooth_Type
       ,@iPrimary_Prov_Req
       ,@iClinical_Doc
       ,@iSpecialty_Req
       ,@iCredentialling_Req
       ,@iPOARuleID
       ,@iPOARuleDesc
       ,@iNDCReq
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prProdRulesAddModify
             @i_entity_name
            ,@i_Key_Rule_GID
            ,@i_key_2_field
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@iRule_ID
            ,@iRule_Description
            ,@iEffective_Date
            ,@iTermination_Date
            ,@iDefault_Status
            ,@iOverride_Benefit
            ,@iMin_Age
            ,@iMin_Age_Option
            ,@iMax_Age
            ,@iMax_Age_Option
            ,@iGender_Covered
            ,@iValid_Relationship
            ,@iCoverage_Start_Days
            ,@iMax_Begin_Age
            ,@iProc_Policy1
            ,@iProc_Policy_Desc1
            ,@iProc_Policy2
            ,@iProc_Policy_Desc2
            ,@iDiagnosis_List
            ,@iDiagnosis_Name
            ,@iESPDT_service
            ,@iOrderable
            ,@iPCPRequired
            ,@iPrice_Strategy_ID
            ,@iPrice_Strategy_Name
            ,@iCopay_Strategy_ID
            ,@iCopay_Strategy_Name
            ,@iBenefit_Strategy_ID
            ,@iBenefit_Strategy_Name
            ,@iExcludeDed
            ,@iExcludeOOP
            ,@iExcludeMax
            ,@iExcludeCOB
            ,@iMin_Dose
            ,@iMax_Dose
            ,@iMin_Qty
            ,@iMax_Qty
            ,@iMin_Days
            ,@iMax_Days
            ,@iMax_Qty_Over_Time
            ,@iMax_Days_Over_Time
            ,@iMax_Qty_OT_Option
            ,@iMax_Days_OT_Option
            ,@iMax_Qty_OT_Amount
            ,@iMax_Days_OT_Amount
            ,@iMax_Fills_Over_Time
            ,@iMax_Fills_OT_Option
            ,@iMax_Fills_OT_Amount
            ,@iMail_Order_Flag
            ,@iTooth_Type
            ,@iPrimary_Prov_Req
            ,@iClinical_Doc
            ,@iSpecialty_Req
            ,@iCredentialling_Req
            ,@iPOARuleID
            ,@iPOARuleDesc
            ,@iNDCReq
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Product_Rules 
				   SET Rule_GID					= @static_gid 
				 WHERE record_status			= 'A'
				   AND Rule_ID					= @iRule_ID

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iRule_ID, @iRule_Description, '', @status, @err_num, @err_msg

        FETCH NEXT FROM CodeRules_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Key_Rule_GID
             ,@i_key_2_field
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@iRule_ID
             ,@iRule_Description
             ,@iEffective_Date
             ,@iTermination_Date
             ,@iDefault_Status
             ,@iOverride_Benefit
             ,@iMin_Age
             ,@iMin_Age_Option
             ,@iMax_Age
             ,@iMax_Age_Option
             ,@iGender_Covered
             ,@iValid_Relationship
             ,@iCoverage_Start_Days
             ,@iMax_Begin_Age
             ,@iProc_Policy1
             ,@iProc_Policy_Desc1
             ,@iProc_Policy2
             ,@iProc_Policy_Desc2
             ,@iDiagnosis_List
             ,@iDiagnosis_Name
             ,@iESPDT_service
             ,@iOrderable
             ,@iPCPRequired
             ,@iPrice_Strategy_ID
             ,@iPrice_Strategy_Name
             ,@iCopay_Strategy_ID
             ,@iCopay_Strategy_Name
             ,@iBenefit_Strategy_ID
             ,@iBenefit_Strategy_Name
             ,@iExcludeDed
             ,@iExcludeOOP
             ,@iExcludeMax
             ,@iExcludeCOB
             ,@iMin_Dose
             ,@iMax_Dose
             ,@iMin_Qty
             ,@iMax_Qty
             ,@iMin_Days
             ,@iMax_Days
             ,@iMax_Qty_Over_Time
             ,@iMax_Days_Over_Time
             ,@iMax_Qty_OT_Option
             ,@iMax_Days_OT_Option
             ,@iMax_Qty_OT_Amount
             ,@iMax_Days_OT_Amount
             ,@iMax_Fills_Over_Time
             ,@iMax_Fills_OT_Option
             ,@iMax_Fills_OT_Amount
             ,@iMail_Order_Flag
             ,@iTooth_Type
             ,@iPrimary_Prov_Req
             ,@iClinical_Doc
             ,@iSpecialty_Req
             ,@iCredentialling_Req
             ,@iPOARuleID
             ,@iPOARuleDesc
             ,@iNDCReq
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE CodeRules_Cursor
DEALLOCATE CodeRules_Cursor

END
GO