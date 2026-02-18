/**************************************************************************************************
Name:       spDCAuto_CreateOnDemandJobs
Purpose:    Create On Demand Jobs data from Core Automation

Screen:     1067
Method:     OnDemandJobs
Procedure:  dbo.prOnDemandJob
Entity:     N/A

Date        User            Change
---------------------------------------------------------------------------------------------
04/20/2021	DK				Original procedure
10/12/2022	DK				Add ID Cards to the list of supported jobs
12/06/2022  DK				Add ALL jobs 
03/21/2023	DK				Activate Provider Extract
08/24/2023	DK				Added JobType to #OnDemandJobs for proper comparison
08/25/2023	DK				Added call to API Submit for Billing job
10/18/2023  DK				Added X12.820 Import and InstaMed Invoice Collection Extract (HPSQA-19767) 
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateOnDemandJobs '400-TestCase-300-LB%', 99999, '400-TestCase-300-LB', 'OnDemandJobs', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateOnDemandJobs
     (@i_pattern			VARCHAR(200)
	 ,@i_log_id				INT
	 ,@i_test_case_name		VARCHAR(200)
	 ,@i_method				VARCHAR(200)
	 ,@i_user				VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern			VARCHAR(200)
	   ,@log_id				INT
	   ,@test_case_name		VARCHAR(200)
	   ,@method				VARCHAR(200)
	   ,@user				VARCHAR(200)

	   ,@record_id			INT
	   ,@gid				INT
	   ,@err_msg			VARCHAR(4000)
       ,@err_num			INT
	   ,@status				VARCHAR(25)

	   ,@current_gid		INT
	   ,@static_gid			INT
	   ,@SearchID			VARCHAR(200)

	   ,@seconds			VARCHAR(20)
	   ,@minutes			VARCHAR(20)

	   ,@enterprise_id		VARCHAR(40)
	   ,@system_name		VARCHAR(40)
	   ,@url				VARCHAR(2000)
	   ,@finance_url		VARCHAR(2000)
	   ,@finance_version	VARCHAR(20)
	   ,@parameters			VARCHAR(8000)

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iJobName			VARCHAR(50)
       ,@iJobGID			INT
       ,@iInput1			VARCHAR(250)
       ,@iInput2			VARCHAR(250)
       ,@iInput3			VARCHAR(250)
       ,@iInput4			VARCHAR(250)
       ,@iInput5			VARCHAR(250)
       ,@iInput6			VARCHAR(250)
       ,@iInput7			VARCHAR(250)
       ,@iInput8			VARCHAR(250)
       ,@iInput9			VARCHAR(250)
       ,@iInput10			VARCHAR(250)
       ,@iInput11			VARCHAR(250)
       ,@iInput12			VARCHAR(250)
       ,@iInput13			VARCHAR(250)
       ,@iInput14			VARCHAR(250)
       ,@iInput15			VARCHAR(250)
       ,@iInput16			VARCHAR(250)
       ,@iInput17			VARCHAR(250)
       ,@iInput18			VARCHAR(250)
       ,@iInput19			VARCHAR(250)
       ,@iInput20			VARCHAR(250)
       ,@iNotificationAdd	VARCHAR(250)
	   ,@iUserID			VARCHAR(50)
       ,@o_status			INT
       ,@o_message			VARCHAR(255)

	   ,@iJobType			VARCHAR(100) 
	   ,@iRunMode			VARCHAR(50) 
	   ,@iDate1				VARCHAR(50) 
	   ,@iDate2				VARCHAR(50) 
	   ,@iProviderID		VARCHAR(50) 
	   ,@iGroupID			VARCHAR(50) 
	   ,@iParentGroupID		VARCHAR(50) 
	   ,@iPlanStrategy		VARCHAR(50) 
	   ,@iPlanStrategyID	VARCHAR(50) 
	   ,@iProductOffering	VARCHAR(50) 
	   ,@iProductOfferingID	VARCHAR(50) 
	   ,@iCustomLOB			VARCHAR(50) 
	   ,@iLOBID				VARCHAR(50) 
	   ,@iMemberID			VARCHAR(50) 
	   ,@iInvoiceID			VARCHAR(50) 
	   ,@iType				VARCHAR(50) 
	   ,@iAffiliationDef	VARCHAR(50) 
	   ,@iEntityType		VARCHAR(50) 
	   ,@iEntityID			VARCHAR(50) 
	   ,@iNPPDefinitionID	VARCHAR(50) 
	   ,@iIncludeCredits	VARCHAR(50) 
	   ,@iNotificationEmail	VARCHAR(50) 
	   ,@iPause				VARCHAR(100) 
	   ,@iFilterPlanListID	VARCHAR(100) 
	   ,@iSupported			BIT

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#OnDemandJobs') IS NOT NULL
	DROP TABLE #OnDemandJobs

CREATE TABLE #OnDemandJobs
      (SearchID				VARCHAR(200)
	  ,JobType				VARCHAR(300)
      ,iJobName				VARCHAR(50)			DEFAULT('')
      ,iJobGID				INT					DEFAULT('')
      ,iInput1				VARCHAR(250)		DEFAULT('')
      ,iInput2				VARCHAR(250)		DEFAULT('')
      ,iInput3				VARCHAR(250)		DEFAULT('')
      ,iInput4				VARCHAR(250)		DEFAULT('')
      ,iInput5				VARCHAR(250)		DEFAULT('')
      ,iInput6				VARCHAR(250)		DEFAULT('')
      ,iInput7				VARCHAR(250)		DEFAULT('')
      ,iInput8				VARCHAR(250)		DEFAULT('')
      ,iInput9				VARCHAR(250)		DEFAULT('')
      ,iInput10				VARCHAR(250)		DEFAULT('')
      ,iInput11				VARCHAR(250)		DEFAULT('')
      ,iInput12				VARCHAR(250)		DEFAULT('')
      ,iInput13				VARCHAR(250)		DEFAULT('')
      ,iInput14				VARCHAR(250)		DEFAULT('')
      ,iInput15				VARCHAR(250)		DEFAULT('')
      ,iInput16				VARCHAR(250)		DEFAULT('')
      ,iInput17				VARCHAR(250)		DEFAULT('')
      ,iInput18				VARCHAR(250)		DEFAULT('')
      ,iInput19				VARCHAR(250)		DEFAULT('')
      ,iInput20				VARCHAR(250)		DEFAULT('')
	  ,iNotificationAdd		VARCHAR(250)		default('')
      ,iUserID				VARCHAR(50)			DEFAULT('')
      ,o_status				INT					DEFAULT(0)
      ,o_message			VARCHAR(255)		DEFAULT('')
	  ,iJobType				VARCHAR(100)		DEFAULT('') 
	  ,iRunMode				VARCHAR(50) 
	  ,iDate1				VARCHAR(50) 
	  ,iDate2				VARCHAR(50) 
	  ,iProviderID			VARCHAR(50) 
	  ,iGroupID				VARCHAR(50) 
	  ,iParentGroupID		VARCHAR(50) 
	  ,iPlanStrategy		VARCHAR(50) 
	  ,iPlanStrategyID		VARCHAR(50) 
	  ,iProductOffering		VARCHAR(50) 
	  ,iProductOfferingID	VARCHAR(50) 
	  ,iCustomLOB			VARCHAR(50) 
	  ,iLOBID				VARCHAR(50) 
	  ,iMemberID			VARCHAR(50) 
	  ,iInvoiceID			VARCHAR(50) 
	  ,iType				VARCHAR(50) 
	  ,iAffiliationDef		VARCHAR(50) 
	  ,iEntityType			VARCHAR(50) 
	  ,iEntityID			VARCHAR(50) 
	  ,iNPPDefinitionID		VARCHAR(50) 
	  ,iIncludeCredits		VARCHAR(50) 
	  ,iNotificationEmail	VARCHAR(50) 
	  ,iPause				VARCHAR(100) 
	  ,iFilterPlanListID	VARCHAR(100) 
	  ,iSupported			BIT
      ,record_id			INT
      ,static_gid			INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token				VARCHAR(200)
	  ,token_order			INT				IDENTITY(1,1))

IF OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL
	DROP TABLE #Results

CREATE TABLE #Results
	  (err_num				VARCHAR(200)
	  ,err_msg				VARCHAR(4000))

--*************************************************************************************************
-- Create a list of the supported functions
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Supported_JobTypes') IS NOT NULL
	DROP TABLE #Supported_JobTypes

CREATE TABLE #Supported_JobTypes
      (JobType				VARCHAR(200))

INSERT INTO #Supported_JobTypes VALUES ('1099 Extract')
--INSERT INTO #Supported_JobTypes VALUES ('834 Outbound')
--INSERT INTO #Supported_JobTypes VALUES ('837 Claim Reporting Outbound')
INSERT INTO #Supported_JobTypes VALUES ('837 Parse and Load')
--INSERT INTO #Supported_JobTypes VALUES ('837 Repricer Outbound')
--INSERT INTO #Supported_JobTypes VALUES ('999 Acknowledgment Inbound ')
--INSERT INTO #Supported_JobTypes VALUES ('ACH File Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Addendum Process')
--INSERT INTO #Supported_JobTypes VALUES ('Address Geocoding')
--INSERT INTO #Supported_JobTypes VALUES ('Age Reduction')
--INSERT INTO #Supported_JobTypes VALUES ('Agency/Broker Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Billing Census Audit')
INSERT INTO #Supported_JobTypes VALUES ('Billing Process')
--INSERT INTO #Supported_JobTypes VALUES ('Calculate and Post CSR Receivables')
--INSERT INTO #Supported_JobTypes VALUES ('Capitation Census Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Capitation Process')
--INSERT INTO #Supported_JobTypes VALUES ('Census Generation')
--INSERT INTO #Supported_JobTypes VALUES ('Claim Resubmitter')
--INSERT INTO #Supported_JobTypes VALUES ('Claims Extract (FULL)')
--INSERT INTO #Supported_JobTypes VALUES ('Claims Extract (FULL) - NO XML')
--INSERT INTO #Supported_JobTypes VALUES ('Claims Extract (INCREMENTAL - NO XML)')
--INSERT INTO #Supported_JobTypes VALUES ('Claims Extract (INCREMENTAL)')
--INSERT INTO #Supported_JobTypes VALUES ('Claims Payment')
--INSERT INTO #Supported_JobTypes VALUES ('Clear List Bill Group Accounts')
--INSERT INTO #Supported_JobTypes VALUES ('Clear Suspense Accounts')
--INSERT INTO #Supported_JobTypes VALUES ('CMS-Edge Server ESES Extract Outbound')
--INSERT INTO #Supported_JobTypes VALUES ('CMS-Edge Server ESMC Extract Outbound')
--INSERT INTO #Supported_JobTypes VALUES ('CMS-Edge Server Response Files Inbound')
--INSERT INTO #Supported_JobTypes VALUES ('COBRA Status Manager')
--INSERT INTO #Supported_JobTypes VALUES ('Contact Extract')
INSERT INTO #Supported_JobTypes VALUES ('Conversion Provider Production')
--INSERT INTO #Supported_JobTypes VALUES ('Conversion Provider Validation')
--INSERT INTO #Supported_JobTypes VALUES ('Create EOB Summary')
--INSERT INTO #Supported_JobTypes VALUES ('Credit Card Chase Bank File Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Credit Card PC Charge File Extract')
--INSERT INTO #Supported_JobTypes VALUES ('DMDS Agency')
--INSERT INTO #Supported_JobTypes VALUES ('EHB Category Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Electronic Payment Processing')
--INSERT INTO #Supported_JobTypes VALUES ('EOB EOP Reprint')
--INSERT INTO #Supported_JobTypes VALUES ('Event Finder And Correspondence')
--INSERT INTO #Supported_JobTypes VALUES ('Extract Magellan Claims')
--INSERT INTO #Supported_JobTypes VALUES ('FFE Shop Group Conversion')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Combined')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Combined (next year)')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Combined (previous year)')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Individual')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Individual (next year)')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - Individual (previous year)')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - SHOP')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - SHOP (next year)')
--INSERT INTO #Supported_JobTypes VALUES ('FFM Enrollment Data Baseline Extract - SHOP (previous year)')
--INSERT INTO #Supported_JobTypes VALUES ('Full Provider Directory Extract')
--INSERT INTO #Supported_JobTypes VALUES ('GenerateJson')
--INSERT INTO #Supported_JobTypes VALUES ('Group Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Group Payment Uplink Extract')
--INSERT INTO #Supported_JobTypes VALUES ('HRA Payment Uplink Extract')
INSERT INTO #Supported_JobTypes VALUES ('ID Card Abridged Extract')
INSERT INTO #Supported_JobTypes VALUES ('ID Cards/ID Book File Extracts')
--INSERT INTO #Supported_JobTypes VALUES ('Income Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Initial Payment File')
INSERT INTO #Supported_JobTypes VALUES ('InstaMed Invoice Collection Extract')
INSERT INTO #Supported_JobTypes VALUES ('Invoice Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Invoice Reprint')
--INSERT INTO #Supported_JobTypes VALUES ('Invoice Rollback in Mass')
--INSERT INTO #Supported_JobTypes VALUES ('IVR Data Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Machine Readable Plan Directory (JSON)')
--INSERT INTO #Supported_JobTypes VALUES ('Machine Readable Provider Directory (JSON)')
--INSERT INTO #Supported_JobTypes VALUES ('Manual Check Print Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Mappoint Step 1')
--INSERT INTO #Supported_JobTypes VALUES ('Mappoint Step 2')
--INSERT INTO #Supported_JobTypes VALUES ('Member Clinical History with Accumulators')
--INSERT INTO #Supported_JobTypes VALUES ('Member Extract File')
--INSERT INTO #Supported_JobTypes VALUES ('Member Payment Uplink Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Member SMF Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Month End Reconciliation Extracts')
--INSERT INTO #Supported_JobTypes VALUES ('Month End Subsidy Extracts')
--INSERT INTO #Supported_JobTypes VALUES ('Non-Payment Processing')
--INSERT INTO #Supported_JobTypes VALUES ('Off Cycle Billing')
--INSERT INTO #Supported_JobTypes VALUES ('Payment Integrity Post-Pay Claim Extract (FULL)')
--INSERT INTO #Supported_JobTypes VALUES ('Payment Integrity Post-Pay Claim Extract (INCR)')
--INSERT INTO #Supported_JobTypes VALUES ('Portal Back-Date Scheduler')
--INSERT INTO #Supported_JobTypes VALUES ('Positive Pay Extract')
--INSERT INTO #Supported_JobTypes VALUES ('Pre-Determination Extract (Dental)')
--INSERT INTO #Supported_JobTypes VALUES ('Pre-Determination Extract (Medical)')
--INSERT INTO #Supported_JobTypes VALUES ('Premium Agency Extract (INCREMENTAL)')
--INSERT INTO #Supported_JobTypes VALUES ('Premium Agency Extract Prelim')
--INSERT INTO #Supported_JobTypes VALUES ('Premium Verification')
--INSERT INTO #Supported_JobTypes VALUES ('Process Payments to Carriers')
--INSERT INTO #Supported_JobTypes VALUES ('Produce Invoice to Carriers')
--INSERT INTO #Supported_JobTypes VALUES ('Provider Directory')
INSERT INTO #Supported_JobTypes VALUES ('Provider Extract File')
--INSERT INTO #Supported_JobTypes VALUES ('Rate Increase')
--INSERT INTO #Supported_JobTypes VALUES ('Reprocess 820 Subsidy Records')
--INSERT INTO #Supported_JobTypes VALUES ('Retro Commission Events')
--INSERT INTO #Supported_JobTypes VALUES ('Security Deposit Funding')
--INSERT INTO #Supported_JobTypes VALUES ('Shop Group Conversion FOR KY')
--INSERT INTO #Supported_JobTypes VALUES ('Term Member Ancillary Records')
--INSERT INTO #Supported_JobTypes VALUES ('Trading Partner 834 Outbound')
INSERT INTO #Supported_JobTypes VALUES ('X12.820 Import')
--INSERT INTO #Supported_JobTypes VALUES ('X12.820 Premium Reporting')

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #OnDemandJobs
          (SearchID
		  ,JobType
		  ,iJobName
		  ,iJobGID
		  ,iJobType				 
	  	  ,iRunMode				
	  	  ,iDate1				
	  	  ,iDate2				
	 	  ,iProviderID			
	  	  ,iGroupID				
	  	  ,iParentGroupID		
	  	  ,iPlanStrategy		
	  	  ,iPlanStrategyID	
	  	  ,iProductOffering		
	  	  ,iProductOfferingID	
	  	  ,iCustomLOB			
	  	  ,iLOBID				 
	  	  ,iMemberID			
	  	  ,iInvoiceID			
	  	  ,iType				
	  	  ,iAffiliationDef		
	  	  ,iEntityType			
	  	  ,iEntityID			
	  	  ,iNPPDefinitionID		
	  	  ,iIncludeCredits		
	  	  ,iNotificationEmail	
	  	  ,iPause				
	  	  ,iFilterPlanListID
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,OD.JobType
	      ,X.process_id
		  ,X.process_gid
		  ,ISNULL([JobType], '')				 
	  	  ,ISNULL([RunMode], '')				
	  	  ,ISNULL([Date1], '')				
	  	  ,ISNULL([Date2], '')				
	 	  ,ISNULL([ProviderID], '')			
	  	  ,ISNULL([GroupID], '')				
	  	  ,ISNULL([ParentGroupID], '')		
	  	  ,ISNULL([PlanStrategy], '')		
	  	  ,ISNULL([PlanStrategyID], '')	
	  	  ,ISNULL([ProductOffering], '')		
	  	  ,ISNULL([ProductOfferingID], '')	
	  	  ,ISNULL([CustomLOB], '')			
	  	  ,ISNULL([LOBID], '')				 
	  	  ,ISNULL([MemberID], '')			
	  	  ,ISNULL([InvoiceID], '')			
	  	  ,ISNULL([Type], '')				
	  	  ,ISNULL([AffiliationDef], '')		
	  	  ,ISNULL([EntityType], '')			
	  	  ,ISNULL([EntityID], '')			
	  	  ,ISNULL([NPPDefinitionID], '')		
	  	  ,ISNULL([IncludeCredits], '')		
	  	  ,ISNULL([NotificationEmail], '')	
	  	  ,ISNULL([Pause], '')				
	  	  ,ISNULL([FilterPlanListID], '')	
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_OnDemandJobs OD
	 CROSS APPLY (SELECT BPM.process_id
	                    ,BPM.process_gid
	                FROM dbo.Batch_Process_Master	BPM
				   WHERE BPM.record_status			= 'A'
				     AND on_demand					= 'Y'
					 AND client						= 'ANY'
				     AND BPM.process_user_id		=  OD.JobType) X

     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #OnDemandJobs
       SET iUserID			= @user
	      ,iNotificationAdd	= ISNULL(iNotificationEmail, '')

	UPDATE #OnDemandJobs
	   SET iSupported			= 1
	  FROM #OnDemandJobs		OD
	  JOIN #Supported_JobTypes	SJT
	    ON OD.iJobType			= SJT.JobType

	--*************************************************************************************************
    -- Update job specific parameters
    --*************************************************************************************************
	UPDATE #OnDemandJobs SET iInput1 = iFilterPlanListID WHERE JobType = 'ID Cards/ID Book File Extracts'
	UPDATE #OnDemandJobs SET iInput1 = iFilterPlanListID WHERE JobType = 'ID Card Abridged Extract'
	UPDATE #OnDemandJobs SET iInput1 = iInvoiceID        WHERE JobType = 'Invoice Extract'

	UPDATE #OnDemandJobs SET iInput1 = iDate1,    iInput2 = iGroupID, iInput3 = iMemberID       WHERE JobType = 'Billing Process'
	UPDATE #OnDemandJobs SET iInput1 = iMemberID, iInput2 = iGroupID, iInput3 = iIncludeCredits WHERE JobType = 'InstaMed Invoice Collection Extract'

	--*************************************************************************************************
    -- Gather additional data if there are any billing jobs
    --*************************************************************************************************
	SELECT @finance_url			= ISNULL(variable_value, 'https://finance-qa-auto.core.valence.care/')
	  FROM dbo.Global_Values	GV
	 WHERE variable_name		= 'Finance_API_Url'
	   AND record_status		= 'A'
	 
    SELECT @finance_version		= ISNULL(variable_value, 'v1')
	  FROM dbo.Global_Values	GV
	 WHERE variable_name		= 'Finance_API_Version'
	   AND record_status		= 'A'

	SELECT @enterprise_id		= dbo.fnDCAuto_GetEnterpriseID()
	SELECT @system_name			= dbo.fnDCAuto_GetSystemName()
	SELECT @url					= @finance_url + @finance_version + '/Billing/ValidateBilling'
	
END TRY
BEGIN CATCH

	SELECT @err_num = ERROR_NUMBER()
		  ,@err_msg	= ERROR_MESSAGE()

	EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, 'Error populating data from CoreAutomation', '', '', 'Error', @err_num, @err_msg
	GOTO CLEANUP

END CATCH

PRINT ' '

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE OnDemandJobs_Cursor CURSOR FOR
 SELECT SearchID
       ,iJobName
       ,iJobGID
       ,iInput1
       ,iInput2
       ,iInput3
       ,iInput4
       ,iInput5
       ,iInput6
       ,iInput7
       ,iInput8
       ,iInput9
       ,iInput10
       ,iInput11
       ,iInput12
       ,iInput13
       ,iInput14
       ,iInput15
       ,iInput16
       ,iInput17
       ,iInput18
       ,iInput19
       ,iInput20
       ,iNotificationAdd
	   ,iPause
	   ,iJobType
	   ,iSupported
       ,iUserID
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #OnDemandJobs

   OPEN OnDemandJobs_Cursor
  FETCH NEXT FROM OnDemandJobs_Cursor
   INTO @SearchID
       ,@iJobName
       ,@iJobGID
       ,@iInput1
       ,@iInput2
       ,@iInput3
       ,@iInput4
       ,@iInput5
       ,@iInput6
       ,@iInput7
       ,@iInput8
       ,@iInput9
       ,@iInput10
       ,@iInput11
       ,@iInput12
       ,@iInput13
       ,@iInput14
       ,@iInput15
       ,@iInput16
       ,@iInput17
       ,@iInput18
       ,@iInput19
       ,@iInput20
       ,@iNotificationAdd
	   ,@iPause
	   ,@iJobType
	   ,@iSupported
       ,@iUserID
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @iSupported = 1
			BEGIN

				BEGIN TRY
					
					IF @iJobName = 'BILLING'
						BEGIN
							SELECT @err_num		= 0
							      ,@err_msg		= ''
							      ,@parameters	= '{"systemName": "'	 + ISNULL(@system_name, '')	+ '", 
								                    "billingRunDate": "' + ISNULL(@iInput1, '')		+ '", 
													"groupID": "'		 + ISNULL(@iInput2, '')		+ '", 
													"memberID": "'		 + ISNULL(@iInput3, '')		+ '", 
													"userID": "'		 + ISNULL(@iUserID, '')		+ '", 
													"isDocGen": "N"}'

							EXEC COREAUTO.CoreAutomation.dbo.spDCAuto_APISubmitRequest @url, @enterprise_id, @parameters, @err_num OUTPUT, @err_msg OUTPUT
							PRINT @err_msg
						END
					ELSE
						BEGIN

						  INSERT INTO #Results 
								(err_num
								,err_msg)
							EXEC dbo.prOnDemandJob
								 @iJobName
								,@iJobGID
								,@iInput1
								,@iInput2
								,@iInput3
								,@iInput4
								,@iInput5
								,@iInput6
								,@iInput7
								,@iInput8
								,@iInput9
								,@iInput10
								,@iInput11
								,@iInput12
								,@iInput13
								,@iInput14
								,@iInput15
								,@iInput16
								,@iInput17
								,@iInput18
								,@iInput19
								,@iInput20
								,@iNotificationAdd
								,@iUserID
								,@o_status     = @err_num OUTPUT
								,@o_message    = @err_msg OUTPUT
						END

				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH

				SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iJobName, @iInput1, @iInput2, @status, @err_num, @err_msg

				SELECT @seconds	= CASE WHEN RIGHT(@iPause, 1) = 'S' THEN RIGHT('00' + LEFT(@iPause, LEN(@iPause) -1), 2)
									   ELSE '00' 
								   END
					  ,@minutes = CASE WHEN RIGHT(@iPause, 1) = 'M' THEN RIGHT('00' + LEFT(@iPause, LEN(@iPause) -1), 2)
									   ELSE '00' 
								   END

				IF NOT(@seconds = '00' AND @minutes = '00')
					BEGIN

						IF @minutes = '00' BEGIN PRINT 'Waiting ' + @seconds + ' seconds, for file to process...' END
						ELSE BEGIN PRINT 'Waiting ' + @minutes + ' minutes and ' + @seconds + ' seconds, for file to process...' END

					END

				PRINT ' '
				SELECT @seconds = '00:00:' + @seconds + '.000'
					  ,@minutes	= '00:' + @minutes + ':00.000'

				-- Wait the specified amount of time
				WAITFOR DELAY @seconds
				WAITFOR DELAY @minutes
				
			END
		ELSE
			BEGIN
				SELECT @status		= 'Error'
				      ,@err_num		= 100
				      ,@err_msg		= 'The job type, ' + @iJobType + ', is not currently supported by the Data Creator.'

				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iJobName, @iInput1, @iInput2, @status, @err_num, @err_msg
			END


        FETCH NEXT FROM OnDemandJobs_Cursor
         INTO @SearchID
             ,@iJobName
             ,@iJobGID
             ,@iInput1
             ,@iInput2
             ,@iInput3
             ,@iInput4
             ,@iInput5
             ,@iInput6
             ,@iInput7
             ,@iInput8
             ,@iInput9
             ,@iInput10
             ,@iInput11
             ,@iInput12
             ,@iInput13
             ,@iInput14
             ,@iInput15
             ,@iInput16
             ,@iInput17
             ,@iInput18
             ,@iInput19
             ,@iInput20
             ,@iNotificationAdd
			 ,@iPause
			 ,@iJobType
			 ,@iSupported
             ,@iUserID
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE OnDemandJobs_Cursor
DEALLOCATE OnDemandJobs_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#OnDemandJobs') IS NOT NULL
	DROP TABLE #OnDemandJobs

IF OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL
	DROP TABLE #Results

IF OBJECT_ID('tempdb.dbo.#Supported_JobTypes') IS NOT NULL
	DROP TABLE #Supported_JobTypes

END
GO

