IF OBJECT_ID('dbo.spDCAuto_CreateNonPaymentParametersMemberAPTC') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateNonPaymentParametersMemberAPTC AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateNonPaymentParametersMemberAPTC
Purpose:    Create NonPaymentparametersgroup data from CorderAutomation
Method:     NonPaymentParametersMember
Screen GID: 6097
Procedure:  dbo.prNPP_Param_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
03/17/2020	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateNonPaymentParametersMemberAPTC '100-Config%', 22, 'NonPaymentParametersMember'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateNonPaymentParametersMemberAPTC
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

DECLARE @i_Entity_name                    VARCHAR(50)
       ,@i_NPP_Parameter_Gid              VARCHAR(50)
       ,@i_NPP_Parameter_sid              VARCHAR(50)
       ,@i_old_seq_order                  VARCHAR(100)
       ,@i_old_entityType                 VARCHAR(75)
       ,@i_key_5_invoice_freq             VARCHAR(75)
       ,@i_key_6_field                    VARCHAR(20)
       ,@i_key_7_field                    VARCHAR(50)
       ,@i_key_8_field                    VARCHAR(50)
       ,@i_key_9_field                    VARCHAR(20)
       ,@i_key_10_field                   VARCHAR(20)
       ,@i_action                         VARCHAR(10)
       ,@l_modified_date                  VARCHAR(100)
       ,@iUserID                          VARCHAR(25)
       ,@i_NPP_parameter_id               VARCHAR(100)
       ,@i_NPP_parameter_description      VARCHAR(50)
       ,@i_entityType                     VARCHAR(100)
       ,@i_invoiceFrequency               VARCHAR(50)
       ,@i_delinquencyType                VARCHAR(75)
       ,@i_NPP_category                   VARCHAR(50)
       ,@i_Seq_Order                      VARCHAR(20)
       ,@i_Period_Type                    VARCHAR(20)
       ,@i_Days_After_PastDue             VARCHAR(20)
       ,@i_Days_After_Creation            VARCHAR(20)
       ,@i_AdminFee_ID                    VARCHAR(50)
       ,@i_AdminFee_Desc                  VARCHAR(50)
       ,@i_LapseHold_ID                   VARCHAR(20)
       ,@i_LapseHold_Desc                 VARCHAR(20)
       ,@i_Lapse_Hold_Effective_Date      VARCHAR(50)
       ,@i_Terminate_All_Group_LOB        VARCHAR(50)
       ,@i_Termination_ID                 VARCHAR(50)
       ,@i_Termination_Desc               VARCHAR(50)
       ,@i_Term_In_Lapse                  VARCHAR(50)
       ,@i_Auto_Finalize                  VARCHAR(50)
       ,@i_AutoReinstatement              VARCHAR(20)
       ,@i_InvoiceReprint                 VARCHAR(50)
       ,@i_Correspondence_ID              VARCHAR(50)
       ,@i_Correspondence_Desc            VARCHAR(50)
       ,@i_write_Off_Amount               VARCHAR(50)
       ,@i_write_Off_Percent              VARCHAR(50)
       ,@i_Misc_Trans_Code                VARCHAR(50)
       ,@i_Misc_Trans_Code_desc           VARCHAR(100)
       ,@i_Member_Initial_Gap_In_Coverage VARCHAR(50)
       ,@i_Group_Term_Reason              VARCHAR(50)
       ,@i_apply_security_deposit         VARCHAR(50)
       ,@iPostAPTCGraceDays               INT
       ,@iPostAPTCCorrespondenceID        VARCHAR(50)
       ,@iPostAPTCCorrespondenceDesc      VARCHAR(50)
       ,@iAPTCGraceClaimCorrespID         VARCHAR(50)
       ,@iAPTCGraceClaimCorrespDesc       VARCHAR(50)
       ,@o_status                         INT
       ,@o_message                        VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#NonPaymentParametersMemberAPTC') IS NOT NULL
	DROP TABLE #NonPaymentParametersMemberAPTC

CREATE TABLE #NonPaymentParametersMemberAPTC
      (SearchID                         VARCHAR(200)
      ,i_Entity_name                    VARCHAR(50)       DEFAULT('NPP_Param')
      ,i_NPP_Parameter_Gid              VARCHAR(50)       DEFAULT('0')
      ,i_NPP_Parameter_sid              VARCHAR(50)       DEFAULT('0')
      ,i_old_seq_order                  VARCHAR(100)      DEFAULT('0')
      ,i_old_entityType                 VARCHAR(75)       DEFAULT('0')
      ,i_key_5_invoice_freq             VARCHAR(75)       DEFAULT('0')
      ,i_key_6_field                    VARCHAR(20)       DEFAULT('0')
      ,i_key_7_field                    VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field                    VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field                    VARCHAR(20)       DEFAULT('0')
      ,i_key_10_field                   VARCHAR(20)       DEFAULT('0')
      ,i_action                         VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date                  VARCHAR(100)      DEFAULT('')
      ,iUserID                          VARCHAR(25)       DEFAULT('')
      ,i_NPP_parameter_id               VARCHAR(100)
      ,i_NPP_parameter_description      VARCHAR(50)
      ,i_entityType                     VARCHAR(100)	  DEFAULT('A')
      ,i_invoiceFrequency               VARCHAR(50)
      ,i_delinquencyType                VARCHAR(75)
      ,i_NPP_category                   VARCHAR(50)
      ,i_Seq_Order                      VARCHAR(20)
      ,i_Period_Type                    VARCHAR(20)
      ,i_Days_After_PastDue             VARCHAR(20)
      ,i_Days_After_Creation            VARCHAR(20)
      ,i_AdminFee_ID                    VARCHAR(50)
      ,i_AdminFee_Desc                  VARCHAR(50)
      ,i_LapseHold_ID                   VARCHAR(20)
      ,i_LapseHold_Desc                 VARCHAR(20)
      ,i_Lapse_Hold_Effective_Date      VARCHAR(50)
      ,i_Terminate_All_Group_LOB        VARCHAR(50)
      ,i_Termination_ID                 VARCHAR(50)
      ,i_Termination_Desc               VARCHAR(50)
      ,i_Term_In_Lapse                  VARCHAR(50)
      ,i_Auto_Finalize                  VARCHAR(50)
      ,i_AutoReinstatement              VARCHAR(20)
      ,i_InvoiceReprint                 VARCHAR(50)
      ,i_Correspondence_ID              VARCHAR(50)
      ,i_Correspondence_Desc            VARCHAR(50)
      ,i_write_Off_Amount               VARCHAR(50)
      ,i_write_Off_Percent              VARCHAR(50)
      ,i_Misc_Trans_Code                VARCHAR(50)
      ,i_Misc_Trans_Code_desc           VARCHAR(100)
      ,i_Member_Initial_Gap_In_Coverage VARCHAR(50)
      ,i_Group_Term_Reason              VARCHAR(50)
      ,i_apply_security_deposit         VARCHAR(50)
      ,iPostAPTCGraceDays               INT
      ,iPostAPTCCorrespondenceID        VARCHAR(50)
      ,iPostAPTCCorrespondenceDesc      VARCHAR(50)
      ,iAPTCGraceClaimCorrespID         VARCHAR(50)
      ,iAPTCGraceClaimCorrespDesc       VARCHAR(50)
      ,o_status                         INT
      ,o_message                        VARCHAR(200)
      ,record_id                        INT
      ,static_gid                       INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #NonPaymentParametersMemberAPTC
      (SearchID
      ,i_invoiceFrequency
      ,i_delinquencyType
      ,i_NPP_category
      ,i_Seq_Order
      ,i_Period_Type
      ,i_Days_After_PastDue
      ,i_Days_After_Creation
      ,i_AdminFee_ID
      ,i_LapseHold_ID
      ,i_Lapse_Hold_Effective_Date
      ,i_Terminate_All_Group_LOB
      ,i_Termination_ID
      ,i_Term_In_Lapse
      ,i_Auto_Finalize
      ,i_AutoReinstatement
      ,i_InvoiceReprint
      ,i_Correspondence_ID
      ,i_write_Off_Amount
      ,i_write_Off_Percent
      ,i_Misc_Trans_Code
      ,i_Member_Initial_Gap_In_Coverage
      ,i_Group_Term_Reason
      ,i_apply_security_deposit
      ,iPostAPTCGraceDays
      ,iPostAPTCCorrespondenceID
      ,iAPTCGraceClaimCorrespID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InvoiceFrequency]), 'M')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*DelinquencyType]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Category]), '')
      ,ISNULL([*SequenceOrder], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PeriodType]), 'D')
      ,ISNULL([*NumOfPeriodsAfterInvoiceStartDate], '0')
      ,ISNULL([*NumOfDaysAfterInvoiceCreationDate], '0')
      ,ISNULL([AdminFeeID], '')
      ,ISNULL([LapseHoldID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([LapseHoldEffectiveDate]), 'B')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([TerminateAllGroupLOB]), 'N')
      ,ISNULL([MemberTerminationReasonCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([OnlyTermInLapseHold]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AutoTermination]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([AutoReinstatement]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvoiceReprint]), 'N')
      ,ISNULL([CorrespondenceID], '')
      ,ISNULL([*WriteOffAmount], '0.00')
      ,ISNULL([*WriteOffPercent], '0')
      ,ISNULL([WriteOffMiscTransCode], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([IncludeGapsInCoverage_MemInitialOnly]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([GroupTerminationReason]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ApplySecurityDepositPriorTerm_MemOnly]), 'N')
      ,ISNULL([DaysAfterAPTCChangeGracePeriodStartDate], '0')
      ,ISNULL([CorrespondenceIDForAPTCChanges], '')
      ,ISNULL([CorresIDForAPTCGrace1Month], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_NonPaymentParametersMemberAPTC
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #NonPaymentParametersMemberAPTC
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE NonPaymentParametersMemberAPTC_Cursor CURSOR FOR
 SELECT SearchID
       ,i_Entity_name
       ,i_NPP_Parameter_Gid
       ,i_NPP_Parameter_sid
       ,i_old_seq_order
       ,i_old_entityType
       ,i_key_5_invoice_freq
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_NPP_parameter_id
       ,i_NPP_parameter_description
       ,i_entityType
       ,i_invoiceFrequency
       ,i_delinquencyType
       ,i_NPP_category
       ,i_Seq_Order
       ,i_Period_Type
       ,i_Days_After_PastDue
       ,i_Days_After_Creation
       ,i_AdminFee_ID
       ,i_AdminFee_Desc
       ,i_LapseHold_ID
       ,i_LapseHold_Desc
       ,i_Lapse_Hold_Effective_Date
       ,i_Terminate_All_Group_LOB
       ,i_Termination_ID
       ,i_Termination_Desc
       ,i_Term_In_Lapse
       ,i_Auto_Finalize
       ,i_AutoReinstatement
       ,i_InvoiceReprint
       ,i_Correspondence_ID
       ,i_Correspondence_Desc
       ,i_write_Off_Amount
       ,i_write_Off_Percent
       ,i_Misc_Trans_Code
       ,i_Misc_Trans_Code_desc
       ,i_Member_Initial_Gap_In_Coverage
       ,i_Group_Term_Reason
       ,i_apply_security_deposit
       ,iPostAPTCGraceDays
       ,iPostAPTCCorrespondenceID
       ,iPostAPTCCorrespondenceDesc
       ,iAPTCGraceClaimCorrespID
       ,iAPTCGraceClaimCorrespDesc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #NonPaymentParametersMemberAPTC

   OPEN NonPaymentParametersMemberAPTC_Cursor
  FETCH NEXT FROM NonPaymentParametersMemberAPTC_Cursor
   INTO @SearchID
       ,@i_Entity_name
       ,@i_NPP_Parameter_Gid
       ,@i_NPP_Parameter_sid
       ,@i_old_seq_order
       ,@i_old_entityType
       ,@i_key_5_invoice_freq
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_NPP_parameter_id
       ,@i_NPP_parameter_description
       ,@i_entityType
       ,@i_invoiceFrequency
       ,@i_delinquencyType
       ,@i_NPP_category
       ,@i_Seq_Order
       ,@i_Period_Type
       ,@i_Days_After_PastDue
       ,@i_Days_After_Creation
       ,@i_AdminFee_ID
       ,@i_AdminFee_Desc
       ,@i_LapseHold_ID
       ,@i_LapseHold_Desc
       ,@i_Lapse_Hold_Effective_Date
       ,@i_Terminate_All_Group_LOB
       ,@i_Termination_ID
       ,@i_Termination_Desc
       ,@i_Term_In_Lapse
       ,@i_Auto_Finalize
       ,@i_AutoReinstatement
       ,@i_InvoiceReprint
       ,@i_Correspondence_ID
       ,@i_Correspondence_Desc
       ,@i_write_Off_Amount
       ,@i_write_Off_Percent
       ,@i_Misc_Trans_Code
       ,@i_Misc_Trans_Code_desc
       ,@i_Member_Initial_Gap_In_Coverage
       ,@i_Group_Term_Reason
       ,@i_apply_security_deposit
       ,@iPostAPTCGraceDays
       ,@iPostAPTCCorrespondenceID
       ,@iPostAPTCCorrespondenceDesc
       ,@iAPTCGraceClaimCorrespID
       ,@iAPTCGraceClaimCorrespDesc
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

			-- Lookup the Copay Levels gid
			SELECT @i_NPP_Parameter_Gid			= entity_gid
			      ,@i_NPP_parameter_id			= entity_user_id
				  ,@i_NPP_parameter_description	= entity_user_name
			  FROM Entity_Names
			 WHERE entity_identifier			= 'NPP_PARAM_DEF'
			   AND entity_user_id				= @SearchID

			EXEC dbo.prNPP_Param_Add_Modify
				 @i_Entity_name
				,@i_NPP_Parameter_Gid
				,@i_NPP_Parameter_sid
				,@i_old_seq_order
				,@i_old_entityType
				,@i_key_5_invoice_freq
				,@i_key_6_field
				,@i_key_7_field
				,@i_key_8_field
				,@i_key_9_field
				,@i_key_10_field
				,@i_action
				,@l_modified_date
				,@iUserID
				,@i_NPP_parameter_id
				,@i_NPP_parameter_description
				,@i_entityType
				,@i_invoiceFrequency
				,@i_delinquencyType
				,@i_NPP_category
				,@i_Seq_Order
				,@i_Period_Type
				,@i_Days_After_PastDue
				,@i_Days_After_Creation
				,@i_AdminFee_ID
				,@i_AdminFee_Desc
				,@i_LapseHold_ID
				,@i_LapseHold_Desc
				,@i_Lapse_Hold_Effective_Date
				,@i_Terminate_All_Group_LOB
				,@i_Termination_ID
				,@i_Termination_Desc
				,@i_Term_In_Lapse
				,@i_Auto_Finalize
				,@i_AutoReinstatement
				,@i_InvoiceReprint
				,@i_Correspondence_ID
				,@i_Correspondence_Desc
				,@i_write_Off_Amount
				,@i_write_Off_Percent
				,@i_Misc_Trans_Code
				,@i_Misc_Trans_Code_desc
				,@i_Member_Initial_Gap_In_Coverage
				,@i_Group_Term_Reason
				,@i_apply_security_deposit
				,@iPostAPTCGraceDays
				,@iPostAPTCCorrespondenceID
				,@iPostAPTCCorrespondenceDesc
				,@iAPTCGraceClaimCorrespID
				,@iAPTCGraceClaimCorrespDesc
				,@o_status     = @err_num OUTPUT
				,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_delinquencyType, @i_NPP_category, @status, @err_num, @err_msg

        FETCH NEXT FROM NonPaymentParametersMemberAPTC_Cursor
         INTO @SearchID
             ,@i_Entity_name
             ,@i_NPP_Parameter_Gid
             ,@i_NPP_Parameter_sid
             ,@i_old_seq_order
             ,@i_old_entityType
             ,@i_key_5_invoice_freq
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_NPP_parameter_id
             ,@i_NPP_parameter_description
             ,@i_entityType
             ,@i_invoiceFrequency
             ,@i_delinquencyType
             ,@i_NPP_category
             ,@i_Seq_Order
             ,@i_Period_Type
             ,@i_Days_After_PastDue
             ,@i_Days_After_Creation
             ,@i_AdminFee_ID
             ,@i_AdminFee_Desc
             ,@i_LapseHold_ID
             ,@i_LapseHold_Desc
             ,@i_Lapse_Hold_Effective_Date
             ,@i_Terminate_All_Group_LOB
             ,@i_Termination_ID
             ,@i_Termination_Desc
             ,@i_Term_In_Lapse
             ,@i_Auto_Finalize
             ,@i_AutoReinstatement
             ,@i_InvoiceReprint
             ,@i_Correspondence_ID
             ,@i_Correspondence_Desc
             ,@i_write_Off_Amount
             ,@i_write_Off_Percent
             ,@i_Misc_Trans_Code
             ,@i_Misc_Trans_Code_desc
             ,@i_Member_Initial_Gap_In_Coverage
             ,@i_Group_Term_Reason
             ,@i_apply_security_deposit
             ,@iPostAPTCGraceDays
             ,@iPostAPTCCorrespondenceID
             ,@iPostAPTCCorrespondenceDesc
             ,@iAPTCGraceClaimCorrespID
             ,@iAPTCGraceClaimCorrespDesc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE NonPaymentParametersMemberAPTC_Cursor
DEALLOCATE NonPaymentParametersMemberAPTC_Cursor

END
GO