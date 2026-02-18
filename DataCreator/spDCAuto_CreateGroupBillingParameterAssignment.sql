IF OBJECT_ID('dbo.spDCAuto_CreateGroupBillingParameterAssignment') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateGroupBillingParameterAssignment AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateGroupBillingParameterAssignment
Purpose:    Create groupbillingparameterassignment data from CorderAutomation
Method:     GroupBillingParameterAssignment
Screen GID: 84
Procedure:  dbo.prBARBilling_Parms_Assign_Add

Date        User            Change
---------------------------------------------------------------------------------------------
12/13/2019	DK				Original procedure
01/21/2020	DK				Added second call to prBARBilling_Parms_Assign_LostFocus for
                            demographics information
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateGroupBillingParameterAssignment '100-Config%', 22, 'GroupBillingParameterAssignment'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateGroupBillingParameterAssignment
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
	   ,@contact_relation_gid		INT
	   ,@group_gid					INT
	   ,@SearchID					VARCHAR(200)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_entity_name                VARCHAR(50)
       ,@i_group_gid                  VARCHAR(50)
       ,@i_key2                       VARCHAR(20)
       ,@i_key3                       VARCHAR(20)
       ,@i_key4                       VARCHAR(50)
       ,@i_key5                       VARCHAR(10)
       ,@i_key6                       VARCHAR(10)
       ,@i_key7                       VARCHAR(20)
       ,@i_key8                       VARCHAR(50)
       ,@i_key9                       VARCHAR(50)
       ,@i_key10                      VARCHAR(50)
       ,@i_action                     VARCHAR(10)
       ,@l_modified_date              VARCHAR(20)
       ,@iUserID                      VARCHAR(25)
       ,@i_group_id                   VARCHAR(50)
       ,@i_group_desc                 VARCHAR(50)
       ,@i_Effective_Date             VARCHAR(50)
       ,@i_Termination_Date           VARCHAR(50)
       ,@i_Billing_Param_Id           VARCHAR(50)
       ,@i_Billing_Param_Desc         VARCHAR(50)
       ,@i_invoice_flag               VARCHAR(50)
       ,@i_invoice_type               VARCHAR(10)
       ,@iPaymentType                 VARCHAR(50)
       ,@i_invoice_timing             VARCHAR(50)
       ,@i_invoice_basis_date         VARCHAR(50)
       ,@i_num_days_prior_ach         VARCHAR(50)
       ,@i_COBRA_eligible             VARCHAR(50)
       ,@i_COBRA_flag                 VARCHAR(50)
       ,@i_Inv_Report_Media           VARCHAR(50)
       ,@i_Printed_Copies             INT
       ,@i_AutoCashApply              VARCHAR(20)
       ,@i_ActMinGrpPart              VARCHAR(50)
       ,@i_OIC                        VARCHAR(10)
       ,@i_OICDesc                    VARCHAR(50)
       ,@i_Contact_Type               VARCHAR(100)
       ,@i_HoldRefundDays             VARCHAR(30)
       ,@i_Contact_Id                 VARCHAR(30)
       ,@i_Contact_Prefix             VARCHAR(100)
       ,@i_Contact_fname              VARCHAR(200)
       ,@i_Contact_mname              VARCHAR(50)
       ,@i_Contact_lname              VARCHAR(60)
       ,@i_Contact_Suffix             VARCHAR(50)
       ,@i_Contact_Address1           VARCHAR(55)
       ,@i_Contact_Address2           VARCHAR(55)
       ,@i_Contact_Zip                VARCHAR(50)
       ,@i_Contact_City               VARCHAR(50)
       ,@i_Contact_State              VARCHAR(50)
       ,@i_Contact_County             VARCHAR(50)
       ,@i_Contact_Country            VARCHAR(50)
       ,@i_Contact_Phone              VARCHAR(50)
       ,@i_Contact_Fax                VARCHAR(50)
       ,@i_Contact_Email              VARCHAR(50)
       ,@i_invoice_message            VARCHAR(180)
       ,@i_invoice_message_start_date VARCHAR(50)
       ,@i_invoice_message_end_date   VARCHAR(50)
       ,@i_check_digit                INT
       ,@i_invoice_print_rules_id     VARCHAR(50)
       ,@i_invoice_print_rules_desc   VARCHAR(100)
       ,@o_status                     INT
       ,@o_message                    VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#GroupBillingParameterAssignment') IS NOT NULL
	DROP TABLE #GroupBillingParameterAssignment

CREATE TABLE #GroupBillingParameterAssignment
      (SearchID                     VARCHAR(200)
      ,i_entity_name                VARCHAR(50)       DEFAULT('Billing_Parameters_Assignment')
      ,i_group_gid                  VARCHAR(50)       DEFAULT('0')
      ,i_key2                       VARCHAR(20)       DEFAULT('0')
      ,i_key3                       VARCHAR(20)       DEFAULT('0')
      ,i_key4                       VARCHAR(50)       DEFAULT('0')
      ,i_key5                       VARCHAR(10)       DEFAULT('0')
      ,i_key6                       VARCHAR(10)       DEFAULT('0')
      ,i_key7                       VARCHAR(20)       DEFAULT('0')
      ,i_key8                       VARCHAR(50)       DEFAULT('0')
      ,i_key9                       VARCHAR(50)       DEFAULT('0')
      ,i_key10                      VARCHAR(50)       DEFAULT('0')
      ,i_action                     VARCHAR(10)       DEFAULT('ADD')
      ,l_modified_date              VARCHAR(20)       DEFAULT('')
      ,iUserID                      VARCHAR(25)       DEFAULT('')
      ,i_group_id                   VARCHAR(50)
      ,i_group_desc                 VARCHAR(50)
      ,i_Effective_Date             VARCHAR(50)
      ,i_Termination_Date           VARCHAR(50)
      ,i_Billing_Param_Id           VARCHAR(50)
      ,i_Billing_Param_Desc         VARCHAR(50)
      ,i_invoice_flag               VARCHAR(50)
      ,i_invoice_type               VARCHAR(10)
      ,iPaymentType                 VARCHAR(50)
      ,i_invoice_timing             VARCHAR(50)
      ,i_invoice_basis_date         VARCHAR(50)
      ,i_num_days_prior_ach         VARCHAR(50)
      ,i_COBRA_eligible             VARCHAR(50)
      ,i_COBRA_flag                 VARCHAR(50)
      ,i_Inv_Report_Media           VARCHAR(50)
      ,i_Printed_Copies             INT
      ,i_AutoCashApply              VARCHAR(20)
      ,i_ActMinGrpPart              VARCHAR(50)
      ,i_OIC                        VARCHAR(10)
      ,i_OICDesc                    VARCHAR(50)
      ,i_Contact_Type               VARCHAR(100)
      ,i_HoldRefundDays             VARCHAR(30)
      ,i_Contact_Id                 VARCHAR(30)
      ,i_Contact_Prefix             VARCHAR(100)
      ,i_Contact_fname              VARCHAR(200)
      ,i_Contact_mname              VARCHAR(50)
      ,i_Contact_lname              VARCHAR(60)
      ,i_Contact_Suffix             VARCHAR(50)
      ,i_Contact_Address1           VARCHAR(55)
      ,i_Contact_Address2           VARCHAR(55)
      ,i_Contact_Zip                VARCHAR(50)
      ,i_Contact_City               VARCHAR(50)
      ,i_Contact_State              VARCHAR(50)
      ,i_Contact_County             VARCHAR(50)
      ,i_Contact_Country            VARCHAR(50)
      ,i_Contact_Phone              VARCHAR(50)
      ,i_Contact_Fax                VARCHAR(50)
      ,i_Contact_Email              VARCHAR(50)
      ,i_invoice_message            VARCHAR(180)
      ,i_invoice_message_start_date VARCHAR(50)
      ,i_invoice_message_end_date   VARCHAR(50)
      ,i_check_digit                INT				DEFAULT('0')
      ,i_invoice_print_rules_id     VARCHAR(50)
      ,i_invoice_print_rules_desc   VARCHAR(100)
      ,o_status                     INT
      ,o_message                    VARCHAR(255)
      ,record_id                    INT
      ,static_gid                   INT)

CREATE TABLE #ScreenChanges
      (group_id						VARCHAR(100)
      ,group_name  					VARCHAR(100)
      ,Effective_Date  				VARCHAR(100)
      ,Termination_Date  			VARCHAR(100)
      ,Billing_Parm_Id  			VARCHAR(100)
      ,Billing_Parm_Desc  			VARCHAR(100)
      ,invoice_flag 				VARCHAR(100) 
      ,invoice_type 				VARCHAR(100) 
      ,PaymentType					VARCHAR(100)  
      ,invoice_timing				VARCHAR(100)  
      ,invoice_basis_date 			VARCHAR(100) 
      ,num_days_prior_ach 			VARCHAR(100) 
      ,COBRA_elig 					VARCHAR(100) 
      ,COBRA_flag  					VARCHAR(100)
      ,report_Media 				VARCHAR(100) 
      ,Printed_Copies  				VARCHAR(100)
      ,AutoCashApply				VARCHAR(100)  
      ,ActMinGrpPart  				VARCHAR(100)
      ,OIC     						VARCHAR(100)          
      ,OICDesc   					VARCHAR(100)        
      ,Contact_Type    				VARCHAR(100)
      ,HoldRefundDays     			VARCHAR(100)
      ,Contact_ID     				VARCHAR(100)
      ,Name_Prefix    				VARCHAR(100) 
      ,First_Name   				VARCHAR(100)  
      ,Middle_Name    				VARCHAR(100) 
      ,Last_Name   					VARCHAR(100)  
      ,Name_Suffix  				VARCHAR(100) 
      ,Contact_Address1     		VARCHAR(100)
      ,Contact_Address2    			VARCHAR(100) 
      ,Contact_Zip   				VARCHAR(100) 
      ,Contact_City  				VARCHAR(100)  
      ,Contact_State   				VARCHAR(100) 
      ,Contact_County   			VARCHAR(100) 
      ,Contact_Country				VARCHAR(100)  
      ,Contact_Phone 				VARCHAR(100)  
      ,Contact_Fax 					VARCHAR(100)  
      ,Contact_Email  				VARCHAR(100) 
      ,invoice_message   			VARCHAR(100) 
      ,Dummy1     					VARCHAR(100)
      ,invoice_message_start_date   VARCHAR(100)  
      ,invoice_message_end_date    	VARCHAR(100) 
      ,check_digit    				VARCHAR(100) 
      ,Dummy2     					VARCHAR(100)
      ,InvoicePrintRulesID    		VARCHAR(100)          
      ,InvoicePrintRulesDesc    	VARCHAR(100)          
      ,o_status     				VARCHAR(100)
      ,o_message   					VARCHAR(100))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #GroupBillingParameterAssignment
      (SearchID
      ,i_group_id
      ,i_Effective_Date
      ,i_Termination_Date
      ,i_Billing_Param_Id
      ,i_invoice_flag
      ,i_invoice_type
      ,iPaymentType
      ,i_invoice_timing
      ,i_invoice_basis_date
      ,i_num_days_prior_ach
      ,i_COBRA_eligible
      ,i_COBRA_flag
      ,i_Inv_Report_Media
      ,i_Printed_Copies
      ,i_AutoCashApply
      ,i_ActMinGrpPart
      ,i_OIC
      ,i_Contact_Type
      ,i_HoldRefundDays
      ,i_Contact_Id
      ,i_Contact_Address1
      ,i_Contact_Address2
      ,i_Contact_Zip
      ,i_Contact_City
      ,i_Contact_State
      ,i_Contact_County
      ,i_Contact_Country
      ,i_Contact_Phone
      ,i_Contact_Fax
      ,i_Contact_Email
      ,i_invoice_message
      ,i_invoice_message_start_date
      ,i_invoice_message_end_date
      ,i_invoice_print_rules_id
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*GroupID], '')
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL([*BillingParamsID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InvoiceFlag]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InvoiceType]), 'G')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*PaymentType]), '*')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*InvoiceTiming]), 'P')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([InvoiceBasisDate]), 'C')
      ,ISNULL([NumberOfDaysPriorInv], '0')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*COBRAElig]), 'Y')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([COBRABillFlg]), 'N')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ReportInvMedia]), 'P')
      ,ISNULL([PrintedCopies], '1')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([UseAutoCash]), 'Y')
      ,ISNULL([ActiveMinGroupPar], '0')
      ,ISNULL([OICID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactType]), 'X115')
      ,ISNULL([HoldRefundDays], '0')
      ,ISNULL([ContactID], '')
      ,ISNULL([ContactAddr1], '')
      ,ISNULL([ContactAddr2], '')
      ,ISNULL([ContactZip], '')
      ,ISNULL([ContactCity], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactState]), 'UT')
      ,ISNULL([ContactCnty], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ContactCountry]), 'US')
      ,ISNULL([ContactPhone], '')
      ,ISNULL([ContactFax], '')
      ,ISNULL([ContactEmail], '')
      ,ISNULL([InvoiceMessage], '')
      ,ISNULL([InvMessStartDate], '')
      ,ISNULL([InvMessEndDate], '')
      ,ISNULL([InvPrintRulesID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_GroupBillingParameterAssignment
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #GroupBillingParameterAssignment
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE GroupBillingParameterAssignment_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_group_gid
       ,i_key2
       ,i_key3
       ,i_key4
       ,i_key5
       ,i_key6
       ,i_key7
       ,i_key8
       ,i_key9
       ,i_key10
       ,i_action
       ,l_modified_date
       ,iUserID
       ,i_group_id
       ,i_group_desc
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_Billing_Param_Id
       ,i_Billing_Param_Desc
       ,i_invoice_flag
       ,i_invoice_type
       ,iPaymentType
       ,i_invoice_timing
       ,i_invoice_basis_date
       ,i_num_days_prior_ach
       ,i_COBRA_eligible
       ,i_COBRA_flag
       ,i_Inv_Report_Media
       ,i_Printed_Copies
       ,i_AutoCashApply
       ,i_ActMinGrpPart
       ,i_OIC
       ,i_OICDesc
       ,i_Contact_Type
       ,i_HoldRefundDays
       ,i_Contact_Id
       ,i_Contact_Prefix
       ,i_Contact_fname
       ,i_Contact_mname
       ,i_Contact_lname
       ,i_Contact_Suffix
       ,i_Contact_Address1
       ,i_Contact_Address2
       ,i_Contact_Zip
       ,i_Contact_City
       ,i_Contact_State
       ,i_Contact_County
       ,i_Contact_Country
       ,i_Contact_Phone
       ,i_Contact_Fax
       ,i_Contact_Email
       ,i_invoice_message
       ,i_invoice_message_start_date
       ,i_invoice_message_end_date
       ,i_check_digit
       ,i_invoice_print_rules_id
       ,i_invoice_print_rules_desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #GroupBillingParameterAssignment

   OPEN GroupBillingParameterAssignment_Cursor
  FETCH NEXT FROM GroupBillingParameterAssignment_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_group_gid
       ,@i_key2
       ,@i_key3
       ,@i_key4
       ,@i_key5
       ,@i_key6
       ,@i_key7
       ,@i_key8
       ,@i_key9
       ,@i_key10
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@i_group_id
       ,@i_group_desc
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_Billing_Param_Id
       ,@i_Billing_Param_Desc
       ,@i_invoice_flag
       ,@i_invoice_type
       ,@iPaymentType
       ,@i_invoice_timing
       ,@i_invoice_basis_date
       ,@i_num_days_prior_ach
       ,@i_COBRA_eligible
       ,@i_COBRA_flag
       ,@i_Inv_Report_Media
       ,@i_Printed_Copies
       ,@i_AutoCashApply
       ,@i_ActMinGrpPart
       ,@i_OIC
       ,@i_OICDesc
       ,@i_Contact_Type
       ,@i_HoldRefundDays
       ,@i_Contact_Id
       ,@i_Contact_Prefix
       ,@i_Contact_fname
       ,@i_Contact_mname
       ,@i_Contact_lname
       ,@i_Contact_Suffix
       ,@i_Contact_Address1
       ,@i_Contact_Address2
       ,@i_Contact_Zip
       ,@i_Contact_City
       ,@i_Contact_State
       ,@i_Contact_County
       ,@i_Contact_Country
       ,@i_Contact_Phone
       ,@i_Contact_Fax
       ,@i_Contact_Email
       ,@i_invoice_message
       ,@i_invoice_message_start_date
       ,@i_invoice_message_end_date
       ,@i_check_digit
       ,@i_invoice_print_rules_id
       ,@i_invoice_print_rules_desc
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the proper contact information 
			TRUNCATE TABLE #ScreenChanges
			INSERT INTO #ScreenChanges
			EXEC prBARBilling_Parms_Assign_LostFocus '3'				-- Tab Off after billing parameters
			                                        ,@i_group_id
													,@i_group_desc
													,@i_Effective_Date
													,@i_Termination_Date
													,@i_Billing_Param_Id
													,@i_Billing_Param_Desc
												    ,@i_invoice_flag
												    ,@i_invoice_type
												    ,@iPaymentType
												    ,@i_invoice_timing
												    ,@i_invoice_basis_date
												    ,@i_num_days_prior_ach
												    ,@i_COBRA_eligible
												    ,@i_COBRA_flag
												    ,@i_Inv_Report_Media
												    ,@i_Printed_Copies
												    ,@i_AutoCashApply
												    ,@i_ActMinGrpPart
												    ,@i_OIC
												    ,@i_OICDesc
												    ,@i_Contact_Type
												    ,@i_HoldRefundDays
												    ,@i_Contact_Id
												    ,@i_Contact_Prefix
												    ,@i_Contact_fname
												    ,@i_Contact_mname
												    ,@i_Contact_lname
												    ,@i_Contact_Suffix
												    ,@i_Contact_Address1
												    ,@i_Contact_Address2
												    ,@i_Contact_Zip
												    ,@i_Contact_City
												    ,@i_Contact_State
												    ,@i_Contact_County
												    ,@i_Contact_Country
												    ,@i_Contact_Phone
												    ,@i_Contact_Fax
												    ,@i_Contact_Email
												    ,@i_invoice_message
												    ,@i_invoice_message_start_date
												    ,@i_invoice_message_end_date
												    ,@i_check_digit
												    ,@i_invoice_print_rules_id
												    ,@i_invoice_print_rules_desc
													,'ADD'
													,0
													,0
													,''

			-- Update the contact information before trying to create the billing assignment
			SELECT @i_Contact_Prefix		= SC.Name_Prefix
				  ,@i_Contact_fname			= SC.First_Name
				  ,@i_Contact_mname			= SC.Middle_Name
				  ,@i_Contact_lname			= SC.Last_Name
				  ,@i_Contact_Suffix		= SC.Name_Suffix
				  ,@i_Contact_Address1		= SC.Contact_Address1
				  ,@i_Contact_Address2		= SC.Contact_Address2
				  ,@i_Contact_Zip			= SC.Contact_Zip
				  ,@i_Contact_City			= SC.Contact_City
				  ,@i_Contact_State			= SC.Contact_State
				  ,@i_Contact_County		= SC.Contact_County
				  ,@i_Contact_Country		= SC.Contact_Country
				  ,@i_Contact_Phone			= SC.Contact_Phone
				  ,@i_Contact_Fax			= SC.Contact_Fax
				  ,@i_Contact_Email			= SC.Contact_Email
			  FROM #ScreenChanges			SC

			-- Get the proper contact information 
			TRUNCATE TABLE #ScreenChanges
			INSERT INTO #ScreenChanges
			EXEC prBARBilling_Parms_Assign_LostFocus '5'				-- Tab Off after billing parameters
			                                        ,@i_group_id
													,@i_group_desc
													,@i_Effective_Date
													,@i_Termination_Date
													,@i_Billing_Param_Id
													,@i_Billing_Param_Desc
												    ,@i_invoice_flag
												    ,@i_invoice_type
												    ,@iPaymentType
												    ,@i_invoice_timing
												    ,@i_invoice_basis_date
												    ,@i_num_days_prior_ach
												    ,@i_COBRA_eligible
												    ,@i_COBRA_flag
												    ,@i_Inv_Report_Media
												    ,@i_Printed_Copies
												    ,@i_AutoCashApply
												    ,@i_ActMinGrpPart
												    ,@i_OIC
												    ,@i_OICDesc
												    ,@i_Contact_Type
												    ,@i_HoldRefundDays
												    ,@i_Contact_Id
												    ,@i_Contact_Prefix
												    ,@i_Contact_fname
												    ,@i_Contact_mname
												    ,@i_Contact_lname
												    ,@i_Contact_Suffix
												    ,@i_Contact_Address1
												    ,@i_Contact_Address2
												    ,@i_Contact_Zip
												    ,@i_Contact_City
												    ,@i_Contact_State
												    ,@i_Contact_County
												    ,@i_Contact_Country
												    ,@i_Contact_Phone
												    ,@i_Contact_Fax
												    ,@i_Contact_Email
												    ,@i_invoice_message
												    ,@i_invoice_message_start_date
												    ,@i_invoice_message_end_date
												    ,@i_check_digit
												    ,@i_invoice_print_rules_id
												    ,@i_invoice_print_rules_desc
													,'ADD'
													,0
													,0
													,''
			-- Update the contact information before trying to create the billing assignment
			SELECT @i_Contact_Prefix		= SC.Name_Prefix
				  ,@i_Contact_fname			= SC.First_Name
				  ,@i_Contact_mname			= SC.Middle_Name
				  ,@i_Contact_lname			= SC.Last_Name
				  ,@i_Contact_Suffix		= SC.Name_Suffix
				  ,@i_Contact_Address1		= SC.Contact_Address1
				  ,@i_Contact_Address2		= SC.Contact_Address2
				  ,@i_Contact_Zip			= SC.Contact_Zip
				  ,@i_Contact_City			= SC.Contact_City
				  ,@i_Contact_State			= SC.Contact_State
				  ,@i_Contact_County		= SC.Contact_County
				  ,@i_Contact_Country		= SC.Contact_Country
				  ,@i_Contact_Phone			= SC.Contact_Phone
				  ,@i_Contact_Fax			= SC.Contact_Fax
				  ,@i_Contact_Email			= SC.Contact_Email
			  FROM #ScreenChanges			SC

			EXEC dbo.prBARBilling_Parms_Assign_Add
             @i_entity_name
            ,@i_group_gid
            ,@i_key2
            ,@i_key3
            ,@i_key4
            ,@i_key5
            ,@i_key6
            ,@i_key7
            ,@i_key8
            ,@i_key9
            ,@i_key10
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@i_group_id
            ,@i_group_desc
            ,@i_Effective_Date
            ,@i_Termination_Date
            ,@i_Billing_Param_Id
            ,@i_Billing_Param_Desc
            ,@i_invoice_flag
            ,@i_invoice_type
            ,@iPaymentType
            ,@i_invoice_timing
            ,@i_invoice_basis_date
            ,@i_num_days_prior_ach
            ,@i_COBRA_eligible
            ,@i_COBRA_flag
            ,@i_Inv_Report_Media
            ,@i_Printed_Copies
            ,@i_AutoCashApply
            ,@i_ActMinGrpPart
            ,@i_OIC
            ,@i_OICDesc
            ,@i_Contact_Type
            ,@i_HoldRefundDays
            ,@i_Contact_Id
            ,@i_Contact_Prefix
            ,@i_Contact_fname
            ,@i_Contact_mname
            ,@i_Contact_lname
            ,@i_Contact_Suffix
            ,@i_Contact_Address1
            ,@i_Contact_Address2
            ,@i_Contact_Zip
            ,@i_Contact_City
            ,@i_Contact_State
            ,@i_Contact_County
            ,@i_Contact_Country
            ,@i_Contact_Phone
            ,@i_Contact_Fax
            ,@i_Contact_Email
            ,@i_invoice_message
            ,@i_invoice_message_start_date
            ,@i_invoice_message_end_date
            ,@i_check_digit
            ,@i_invoice_print_rules_id
            ,@i_invoice_print_rules_desc
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_group_id, @i_Billing_Param_Id, '', @status, @err_num, @err_msg

		 -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				SELECT @group_gid		= G.group_gid
				  FROM Groups			G
				 WHERE G.record_status	= 'A'
				   AND G.group_id		= @i_group_id

				SELECT @current_gid							= BPA.billing_parameters_assignment_gid
				      ,@contact_relation_gid				= BPA.contact_relation_gid
				  FROM dbo.Billing_Parameters_Assignment	BPA
				  JOIN dbo.Entity_Names						EN
				    ON BPA.billing_type_gid					= EN.entity_gid
				   AND EN.entity_identifier					= 'Billing_PArameters'
				   AND EN.entity_user_id					= @i_Billing_Param_Id
				 WHERE BPA.record_status					= 'A'
				   AND BPA.entity_gid						= @group_gid
				   AND BPA.entity_type						= 'G'

				UPDATE dbo.Billing_Parameters_Assignment
				   SET billing_parameters_assignment_gid	= @static_gid
				      ,contact_relation_gid					= @static_gid
				 WHERE billing_parameters_assignment_gid	= @current_gid

				UPDATE dbo.Contact_Relation
				   SET contact_relation_gid					= @static_gid
				 WHERE contact_relation_gid					= @contact_relation_gid


			END

        FETCH NEXT FROM GroupBillingParameterAssignment_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_group_gid
             ,@i_key2
             ,@i_key3
             ,@i_key4
             ,@i_key5
             ,@i_key6
             ,@i_key7
             ,@i_key8
             ,@i_key9
             ,@i_key10
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@i_group_id
             ,@i_group_desc
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_Billing_Param_Id
             ,@i_Billing_Param_Desc
             ,@i_invoice_flag
             ,@i_invoice_type
             ,@iPaymentType
             ,@i_invoice_timing
             ,@i_invoice_basis_date
             ,@i_num_days_prior_ach
             ,@i_COBRA_eligible
             ,@i_COBRA_flag
             ,@i_Inv_Report_Media
             ,@i_Printed_Copies
             ,@i_AutoCashApply
             ,@i_ActMinGrpPart
             ,@i_OIC
             ,@i_OICDesc
             ,@i_Contact_Type
             ,@i_HoldRefundDays
             ,@i_Contact_Id
             ,@i_Contact_Prefix
             ,@i_Contact_fname
             ,@i_Contact_mname
             ,@i_Contact_lname
             ,@i_Contact_Suffix
             ,@i_Contact_Address1
             ,@i_Contact_Address2
             ,@i_Contact_Zip
             ,@i_Contact_City
             ,@i_Contact_State
             ,@i_Contact_County
             ,@i_Contact_Country
             ,@i_Contact_Phone
             ,@i_Contact_Fax
             ,@i_Contact_Email
             ,@i_invoice_message
             ,@i_invoice_message_start_date
             ,@i_invoice_message_end_date
             ,@i_check_digit
             ,@i_invoice_print_rules_id
             ,@i_invoice_print_rules_desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE GroupBillingParameterAssignment_Cursor
DEALLOCATE GroupBillingParameterAssignment_Cursor

END
GO