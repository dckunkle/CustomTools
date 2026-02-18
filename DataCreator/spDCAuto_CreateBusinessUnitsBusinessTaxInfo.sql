/**************************************************************************************************
Name:       spDCAuto_CreateBusinessUnitsBusinessTaxInfo
Purpose:    Create businessunitsbusinesstaxinfo data from CorderAutomation

Screen:     130
Method:     BusinessUnitsBusinessTaxInfo
Procedure:  dbo.prPMAddModify_BusTaxInfo
Entity:     Business_Tax_Info

Date        User            Change
---------------------------------------------------------------------------------------------
09/25/2023	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBusinessUnitsBusinessTaxInfo 'RFF-Run1-Core-2100-001%', 22, 'RFF-Run1-Core-2100-001', 'BusinessUnitsBusinessTaxInfo', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreateBusinessUnitsBusinessTaxInfo
     (@i_pattern				VARCHAR(200)
	 ,@i_log_id					INT
	 ,@i_test_case_name			VARCHAR(200)
	 ,@i_method					VARCHAR(200)
	 ,@i_user					VARCHAR(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @pattern				 VARCHAR(200)
	   ,@log_id					 INT
	   ,@test_case_name			 VARCHAR(200)
	   ,@method					 VARCHAR(200)
	   ,@user					 VARCHAR(200)

	   ,@record_id				 INT
	   ,@gid					 INT
	   ,@err_msg				 VARCHAR(4000)
       ,@err_num				 INT
	   ,@status					 VARCHAR(25)

	   ,@current_gid			 INT
	   ,@static_gid				 INT
	   ,@SearchID				 VARCHAR(200)

	   ,@i_location_gid_1099	 INT
	   ,@i_rel_eff_date			 VARCHAR(20)
	   ,@i_rel_end_date			 VARCHAR(20)

SELECT @pattern					 = @i_pattern
	  ,@log_id					 = @i_log_id
	  ,@method					 = @i_method
	  ,@test_case_name			 = @i_test_case_name
	  ,@user					 = @i_user

DECLARE @i_entity_name            VARCHAR(50)
       ,@i_Business_gid           VARCHAR(50)
       ,@i_Business_tax_gid       VARCHAR(20)
       ,@i_Payment_location_gid   VARCHAR(20)
       ,@i_Old_Tin_effective_date VARCHAR(20)
       ,@i_Old_Tin_end_date       VARCHAR(20)
       ,@i_Old_Tax_id_number      VARCHAR(20)
       ,@i_Old_Tax_id_type        VARCHAR(20)
       ,@i_blank1                 VARCHAR(50)
       ,@i_blank2                 VARCHAR(50)
       ,@i_blank3                 VARCHAR(100)
       ,@i_action                 VARCHAR(100)
       ,@i_date_time_modified     VARCHAR(50)
       ,@iUserID                  VARCHAR(20)
       ,@i_Tax_id_number          VARCHAR(50)
       ,@i_Tax_id_type            VARCHAR(50)
       ,@i_Tin_effective_date     VARCHAR(50)
       ,@i_Tin_end_date           VARCHAR(50)
       ,@i_w9_onfile              VARCHAR(50)
       ,@i_w9_completed           VARCHAR(50)
       ,@i_w9_Requested           VARCHAR(50)
       ,@i_w9_rec_date            VARCHAR(50)
       ,@i_W9_business_type       VARCHAR(50)
       ,@i_name_1099              VARCHAR(80)
       ,@i_name_1099_2            VARCHAR(50)
       ,@i_B_waiver               VARCHAR(50)
       ,@i_B_waiver_percent       VARCHAR(50)
       ,@i_1099_loc_id            VARCHAR(50)
       ,@i_1099_loc_name          VARCHAR(100)
       ,@i_1099_addy1             VARCHAR(55)
       ,@i_1099_addy2             VARCHAR(55)
       ,@i_1099_zip               VARCHAR(50)
       ,@i_1099_city              VARCHAR(50)
       ,@i_1099_state             VARCHAR(50)
       ,@i_1099_county            VARCHAR(50)
       ,@i_1099_country           VARCHAR(50)
       ,@iAutoRecoupID            VARCHAR(50)
       ,@iAutoRecoupDesc          VARCHAR(100)
       ,@iPrimaryBU               VARCHAR(50)
       ,@o_status                 INT
       ,@o_message                VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BusinessUnitsBusinessTaxInfo') IS NOT NULL
	DROP TABLE #BusinessUnitsBusinessTaxInfo

CREATE TABLE #BusinessUnitsBusinessTaxInfo
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(50)       DEFAULT('Business_Tax_Info')
      ,i_Business_gid           VARCHAR(50)       DEFAULT('0')
      ,i_Business_tax_gid       VARCHAR(20)       DEFAULT('0')
      ,i_Payment_location_gid   VARCHAR(20)       DEFAULT('0')
      ,i_Old_Tin_effective_date VARCHAR(20)       DEFAULT('0')
      ,i_Old_Tin_end_date       VARCHAR(20)       DEFAULT('0')
      ,i_Old_Tax_id_number      VARCHAR(20)       DEFAULT('0')
      ,i_Old_Tax_id_type        VARCHAR(20)       DEFAULT('0')
      ,i_blank1                 VARCHAR(50)       DEFAULT('0')
      ,i_blank2                 VARCHAR(50)       DEFAULT('0')
      ,i_blank3                 VARCHAR(100)      DEFAULT('0')
      ,i_action                 VARCHAR(100)      DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(20)       DEFAULT('')
      ,iUserID                  VARCHAR(20)       DEFAULT('')
      ,i_Tax_id_number          VARCHAR(50)
      ,i_Tax_id_type            VARCHAR(50)
      ,i_Tin_effective_date     VARCHAR(50)
      ,i_Tin_end_date           VARCHAR(50)
      ,i_w9_onfile              VARCHAR(50)
      ,i_w9_completed           VARCHAR(50)
      ,i_w9_Requested           VARCHAR(50)
      ,i_w9_rec_date            VARCHAR(50)
      ,i_W9_business_type       VARCHAR(50)
      ,i_name_1099              VARCHAR(80)
      ,i_name_1099_2            VARCHAR(50)
      ,i_B_waiver               VARCHAR(50)
      ,i_B_waiver_percent       VARCHAR(50)
      ,i_1099_loc_id            VARCHAR(50)
      ,i_1099_loc_name          VARCHAR(100)
      ,i_1099_addy1             VARCHAR(55)
      ,i_1099_addy2             VARCHAR(55)
      ,i_1099_zip               VARCHAR(50)
      ,i_1099_city              VARCHAR(50)
      ,i_1099_state             VARCHAR(50)
      ,i_1099_county            VARCHAR(50)
      ,i_1099_country           VARCHAR(50)
      ,iAutoRecoupID            VARCHAR(50)
      ,iAutoRecoupDesc          VARCHAR(100)
      ,iPrimaryBU               VARCHAR(50)
      ,o_status                 INT
      ,o_message                VARCHAR(255)
      ,record_id                INT
      ,static_gid               INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

IF Object_ID('tempdb.dbo.#BusinessTaxInfo_Populate') IS NOT NULL
	DROP TABLE #BusinessTaxInfo_Populate

CREATE TABLE #BusinessTaxInfo_Populate
      (tax_id_number				VARCHAR(50)
      ,tax_id_type					VARCHAR(50)
      ,tin_effective_date			VARCHAR(50)
      ,tin_end_date					VARCHAR(50)
      ,w9_onfile					VARCHAR(50)
      ,w9_completed					VARCHAR(50)
      ,w9_date_requested			VARCHAR(50)
      ,w9_date_received				VARCHAR(50)
      ,w9_business_type				VARCHAR(50)
	  ,space_1						VARCHAR(20)
      ,name_1099					VARCHAR(80)
      ,name_1099_2					VARCHAR(50)
      ,retention_waiver				VARCHAR(50)
      ,waiver_percent				VARCHAR(50)
      ,tax_location_id				VARCHAR(50)
	  ,tax_location_name			VARCHAR(200)
	  ,tax_location_address			VARCHAR(200)
	  ,tax_location_address2		VARCHAR(200)
	  ,tax_location_zip				VARCHAR(200)
	  ,tax_location_city			VARCHAR(200)
	  ,tax_location_state			VARCHAR(200)
	  ,tax_location_county			VARCHAR(200)
	  ,tax_location_country			VARCHAR(200)
	  ,space_2						VARCHAR(20)
      ,auto_recoup_rule_id			VARCHAR(50)
	  ,auto_recoup_rule_description	VARCHAR(200)
      ,primary_business_unit		VARCHAR(50)
	  ,date_time_created			VARCHAR(50)
      ,user_id_created				VARCHAR(50)
	  ,date_time_modified			VARCHAR(50)
      ,user_id						VARCHAR(50)
	  ,form_id						VARCHAR(50))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #BusinessUnitsBusinessTaxInfo
          (SearchID
          ,i_Tax_id_number
          ,i_Tax_id_type
          ,i_Tin_effective_date
          ,i_Tin_end_date
          ,i_w9_onfile
          ,i_w9_completed
          ,i_w9_Requested
          ,i_w9_rec_date
          ,i_W9_business_type
          ,i_name_1099
          ,i_name_1099_2
          ,i_B_waiver
          ,i_B_waiver_percent
          ,i_1099_loc_id
          ,iAutoRecoupID
          ,iPrimaryBU
		  ,i_action
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL([*TaxID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*TaxIDType]), '1')
          ,ISNULL([*TINEffDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TINEndDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9OnFile]), 'Y')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9Completed]), 'N')
          ,ISNULL([W9DateRequested], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([W9DateReceived], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([W9BusType]), 'O')
          ,ISNULL([1099PayeeName1], '')
          ,ISNULL([1099PayeeName2], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([RetentionWaiver]), 'N')
          ,ISNULL([WaiverPercentage], '0.00')
          ,ISNULL([*TaxLocationID], '')
          ,ISNULL([AutoRecoupRuleID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PrimaryBusinessUnit]), '')
		  ,CASE WHEN ISNULL([ACTION], '') = '' THEN 'ADD' WHEN [ACTION] = 'ADD_EXIT' THEN 'ADD' WHEN [ACTION] = 'MODIFY_EXIT' THEN 'MODIFY' ELSE 'ADD' END
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_BusinessUnitTaxInfoModify
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #BusinessUnitsBusinessTaxInfo
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
DECLARE BusinessUnitsBusinessTaxInfo_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Business_gid
       ,i_Business_tax_gid
       ,i_Payment_location_gid
       ,i_Old_Tin_effective_date
       ,i_Old_Tin_end_date
       ,i_Old_Tax_id_number
       ,i_Old_Tax_id_type
       ,i_blank1
       ,i_blank2
       ,i_blank3
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_Tax_id_number
       ,i_Tax_id_type
       ,i_Tin_effective_date
       ,i_Tin_end_date
       ,i_w9_onfile
       ,i_w9_completed
       ,i_w9_Requested
       ,i_w9_rec_date
       ,i_W9_business_type
       ,i_name_1099
       ,i_name_1099_2
       ,i_B_waiver
       ,i_B_waiver_percent
       ,i_1099_loc_id
       ,i_1099_loc_name
       ,i_1099_addy1
       ,i_1099_addy2
       ,i_1099_zip
       ,i_1099_city
       ,i_1099_state
       ,i_1099_county
       ,i_1099_country
       ,iAutoRecoupID
       ,iAutoRecoupDesc
       ,iPrimaryBU
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BusinessUnitsBusinessTaxInfo

   OPEN BusinessUnitsBusinessTaxInfo_Cursor
  FETCH NEXT FROM BusinessUnitsBusinessTaxInfo_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Business_gid
       ,@i_Business_tax_gid
       ,@i_Payment_location_gid
       ,@i_Old_Tin_effective_date
       ,@i_Old_Tin_end_date
       ,@i_Old_Tax_id_number
       ,@i_Old_Tax_id_type
       ,@i_blank1
       ,@i_blank2
       ,@i_blank3
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_Tax_id_number
       ,@i_Tax_id_type
       ,@i_Tin_effective_date
       ,@i_Tin_end_date
       ,@i_w9_onfile
       ,@i_w9_completed
       ,@i_w9_Requested
       ,@i_w9_rec_date
       ,@i_W9_business_type
       ,@i_name_1099
       ,@i_name_1099_2
       ,@i_B_waiver
       ,@i_B_waiver_percent
       ,@i_1099_loc_id
       ,@i_1099_loc_name
       ,@i_1099_addy1
       ,@i_1099_addy2
       ,@i_1099_zip
       ,@i_1099_city
       ,@i_1099_state
       ,@i_1099_county
       ,@i_1099_country
       ,@iAutoRecoupID
       ,@iAutoRecoupDesc
       ,@iPrimaryBU
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			IF @i_action = 'MODIFY'
				BEGIN

					-- Make sure to grab the Auth Match ID to search for
					TRUNCATE TABLE #Tokens
					INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')
					SELECT @SearchID = token FROM #Tokens WHERE token_order = 1

					SELECT @i_Business_gid				= BU.business_gid
						  ,@i_Business_tax_gid			= BTR.business_tax_gid
						  ,@i_Payment_location_gid		= BU.payment_location_gid
						  ,@i_Tin_effective_date		= CONVERT(VARCHAR(20), BTR.effective_date, 101)
						  ,@i_Tin_end_date				= CONVERT(VARCHAR(20), BTR.termination_date, 101)
						  ,@i_Tax_id_type				= BTI.tax_id_type
						  ,@i_Tax_id_number				= BTI.tax_id_number
						  ,@i_date_time_modified		= CONVERT(VARCHAR(50), BTI.date_time_modified, 121)
					  FROM dbo.Business_Units			BU
					  JOIN dbo.Business_Tax_Relation	BTR
						ON BU.business_gid				= BTR.business_gid
					  JOIN dbo.Business_Tax_Info		BTI
						ON BTR.business_tax_gid			= BTI.business_tax_gid
					 WHERE BU.record_status				= 'A'
					   AND BTR.record_status			= 'A'
					   AND BTI.record_status			= 'A'
					   AND BTI.tax_id_number			= @SearchID

					--Get the existing values
					TRUNCATE TABLE #BusinessTaxInfo_Populate

					SELECT @i_location_gid_1099 = @i_Payment_location_gid
						  ,@i_rel_eff_date		= CONVERT(VARCHAR(20),@i_Tin_effective_date, 101)
						  ,@i_rel_end_date		= CONVERT(VARCHAR(20), @i_Tin_end_date, 101)

					INSERT INTO #BusinessTaxInfo_Populate
						  (tax_id_number
                          ,tax_id_type
                          ,tin_effective_date
                          ,tin_end_date
                          ,w9_onfile
                          ,w9_completed
                          ,w9_date_requested
                          ,w9_date_received
                          ,w9_business_type
	                      ,space_1
                          ,name_1099
                          ,name_1099_2
                          ,retention_waiver
                          ,waiver_percent
                          ,tax_location_id
	                      ,tax_location_name
	                      ,tax_location_address
	                      ,tax_location_address2
	                      ,tax_location_zip
	                      ,tax_location_city
	                      ,tax_location_state
	                      ,tax_location_county
	                      ,tax_location_country
	                      ,space_2
                          ,auto_recoup_rule_id
	                      ,auto_recoup_rule_description
                          ,primary_business_unit
	                      ,date_time_created
                          ,user_id_created
	                      ,date_time_modified
                          ,user_id
	                      ,form_id)
					--*************************************************************************************************
					-- DO NOT CHANGE, Copied directly from prPMPopulate_BusTaxInfo
					--*************************************************************************************************
					SELECT bti.Tax_id_number  
                          ,bti.Tax_id_type  
                          ,CONVERT(varchar(10),btr.effective_date,101)  
                          ,CONVERT(varchar(10),btr.termination_date,101)  
                          ,ISNULL(bti.w9_onfile,'N')  
                          ,ISNULL(bti.w9_completed,'N')  
                          ,CONVERT(varchar(10),bti.w9_request_date,101)  
                          ,CONVERT(varchar(10),bti.w9_rec_date,101)  
                          ,bti.W9_business_type  
                          ,''  
                          ,ISNULL(bti.name_1099,'')  
                          ,ISNULL(bti.name2_1099,'')  
                          ,SUBSTRING(bti.support_codes,2,1)  
                          ,CONVERT(varchar,ISNULL(waiver_percent,0.00))  
                          ,ISNULL(l.location_id, '')  
                          ,ISNULL(l.location_desc, '')  
                          ,ISNULL(l.address_1, '')  
                          ,ISNULL(l.address_2,'')  
                          ,ISNULL(l.zip_code,'')  
                          ,ISNULL(l.city,'')  
                          ,ISNULL(l.state,'')  
                          ,ISNULL(l.county,'')  
                          ,ISNULL(l.country,'')  
                          ,''  
                          ,ISNULL(AC.AutoRecoupRuleID, '')  
                          ,ISNULL(AC.AutoRecoupRuleDesc, '')  
                          ,ISNULL(BU.business_unit_id, '')  
                          ,CONVERT(varchar(30),bti.date_time_created,121)  
                          ,bti.user_id_created  
                          ,CONVERT(varchar(30),bti.date_time_modified,121)  
                          ,bti.user_id  
                          ,bti.form_id  
                      FROM business_tax_info		bti WITH (NOLOCK)  
                      JOIN locations				l   WITH (NOLOCK)  
                        ON bti.Business_tax_gid		= CONVERT(int,@i_Business_tax_gid)  
                       AND l.Location_gid           = CONVERT(int,@i_location_gid_1099)  
                       AND bti.tax_id_number        = @i_Tax_id_number  
                       AND bti.tax_id_type          = @i_Tax_id_type  
                       AND bti.record_status		= 'A'  
                       AND l.record_status          = 'A'   
                      JOIN business_tax_relation	btr WITH (NOLOCK)  
                        ON bti.Business_tax_gid     = btr.Business_tax_gid  
                       AND btr.business_gid         = CONVERT(int,@i_Business_gid)   
                       AND CONVERT(varchar,btr.effective_date,101)      = CONVERT(varchar,@i_rel_eff_date,101)  
                       AND CONVERT(varchar,btr.termination_date,101)    = CONVERT(varchar,@i_rel_end_date,101)  
                       AND btr.record_status		= 'A'  
                 LEFT JOIN dbo.AutoRecoupRule		AC WITH (NOLOCK)  
                        ON bti.autoRecoupGid		= AC.AutoRecoupRuleGid  
                       AND AC.record_status			= 'A'  
                 LEFT JOIN dbo.Business_Units		BU WITH (NOLOCK)  
                        ON BU.business_gid			= bti.PrimaryBusinessGid  
                       AND BU.record_status			= 'A'  

					SELECT @i_Old_Tin_effective_date	= @i_Tin_effective_date
                          ,@i_Old_Tin_end_date			= @i_Tin_end_date
                          ,@i_Old_Tax_id_number			= @i_Tax_id_number
                          ,@i_Old_Tax_id_type			= @i_Tax_id_type

					SELECT TOP 1              
						   @i_Tax_id_number			= CASE WHEN ISNULL(@i_Tax_id_number, '') = ''		THEN BTI.tax_id_number				ELSE @i_Tax_id_number END
						  ,@i_Tax_id_type			= CASE WHEN ISNULL(@i_Tax_id_type, '') = ''			THEN BTI.tax_id_type				ELSE @i_Tax_id_type END
						  ,@i_Tin_effective_date	= CASE WHEN ISNULL(@i_Tin_effective_date, '') = ''	THEN BTI.tin_effective_date			ELSE @i_Tin_effective_date END
						  ,@i_Tin_end_date			= CASE WHEN ISNULL(@i_Tin_end_date, '') = ''		THEN BTI.tin_end_date				ELSE @i_Tin_end_date END
						  ,@i_w9_onfile				= CASE WHEN ISNULL(@i_w9_onfile, '') = ''			THEN BTI.w9_onfile					ELSE @i_w9_onfile END
						  ,@i_w9_completed			= CASE WHEN ISNULL(@i_w9_completed, '') = ''		THEN BTI.w9_completed				ELSE @i_w9_completed END
						  ,@i_w9_Requested			= CASE WHEN ISNULL(@i_w9_Requested, '') = ''		THEN BTI.w9_date_requested			ELSE @i_w9_Requested END
						  ,@i_w9_rec_date			= CASE WHEN ISNULL(@i_w9_rec_date, '') = ''			THEN BTI.w9_date_received			ELSE @i_w9_rec_date END
						  ,@i_W9_business_type		= CASE WHEN ISNULL(@i_W9_business_type, '') = ''	THEN BTI.w9_business_type			ELSE @i_W9_business_type END
						  ,@i_name_1099				= CASE WHEN ISNULL(@i_name_1099, '') = ''			THEN BTI.name_1099					ELSE @i_name_1099 END
						  ,@i_name_1099_2			= CASE WHEN ISNULL(@i_name_1099_2, '') = ''			THEN BTI.name_1099_2				ELSE @i_name_1099_2 END
						  ,@i_B_waiver				= CASE WHEN ISNULL(@i_B_waiver, '') = ''			THEN BTI.retention_waiver			ELSE @i_B_waiver END
						  ,@i_B_waiver_percent		= CASE WHEN ISNULL(@i_B_waiver_percent, '') = ''	THEN BTI.waiver_percent				ELSE @i_B_waiver_percent END
						  ,@i_1099_loc_id			= CASE WHEN ISNULL(@i_1099_loc_id, '') = ''			THEN BTI.tax_location_id			ELSE @i_1099_loc_id END
						  ,@iAutoRecoupID			= CASE WHEN ISNULL(@iAutoRecoupID, '') = ''			THEN BTI.auto_recoup_rule_id		ELSE @iAutoRecoupID END
						  ,@iPrimaryBU				= CASE WHEN ISNULL(@iPrimaryBU, '') = ''			THEN BTI.primary_business_unit		ELSE @iPrimaryBU END
					  FROM #BusinessTaxInfo_Populate BTI

				END

			EXEC dbo.prPMAddModify_BusTaxInfo
                 @i_entity_name
                ,@i_Business_gid
                ,@i_Business_tax_gid
                ,@i_Payment_location_gid
                ,@i_Old_Tin_effective_date
                ,@i_Old_Tin_end_date
                ,@i_Old_Tax_id_number
                ,@i_Old_Tax_id_type
                ,@i_blank1
                ,@i_blank2
                ,@i_blank3
                ,@i_action
                ,@i_date_time_modified
                ,@iUserID
                ,@i_Tax_id_number
                ,@i_Tax_id_type
                ,@i_Tin_effective_date
                ,@i_Tin_end_date
                ,@i_w9_onfile
                ,@i_w9_completed
                ,@i_w9_Requested
                ,@i_w9_rec_date
                ,@i_W9_business_type
                ,@i_name_1099
                ,@i_name_1099_2
                ,@i_B_waiver
                ,@i_B_waiver_percent
                ,@i_1099_loc_id
                ,@i_1099_loc_name
                ,@i_1099_addy1
                ,@i_1099_addy2
                ,@i_1099_zip
                ,@i_1099_city
                ,@i_1099_state
                ,@i_1099_county
                ,@i_1099_country
                ,@iAutoRecoupID
                ,@iAutoRecoupDesc
                ,@iPrimaryBU
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

			PRINT @err_msg

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Tax_id_number, @i_Tax_id_type, @i_Tin_effective_date, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM BusinessUnitsBusinessTaxInfo_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Business_gid
             ,@i_Business_tax_gid
             ,@i_Payment_location_gid
             ,@i_Old_Tin_effective_date
             ,@i_Old_Tin_end_date
             ,@i_Old_Tax_id_number
             ,@i_Old_Tax_id_type
             ,@i_blank1
             ,@i_blank2
             ,@i_blank3
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_Tax_id_number
             ,@i_Tax_id_type
             ,@i_Tin_effective_date
             ,@i_Tin_end_date
             ,@i_w9_onfile
             ,@i_w9_completed
             ,@i_w9_Requested
             ,@i_w9_rec_date
             ,@i_W9_business_type
             ,@i_name_1099
             ,@i_name_1099_2
             ,@i_B_waiver
             ,@i_B_waiver_percent
             ,@i_1099_loc_id
             ,@i_1099_loc_name
             ,@i_1099_addy1
             ,@i_1099_addy2
             ,@i_1099_zip
             ,@i_1099_city
             ,@i_1099_state
             ,@i_1099_county
             ,@i_1099_country
             ,@iAutoRecoupID
             ,@iAutoRecoupDesc
             ,@iPrimaryBU
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BusinessUnitsBusinessTaxInfo_Cursor
DEALLOCATE BusinessUnitsBusinessTaxInfo_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#BusinessUnitsBusinessTaxInfo') IS NOT NULL
	DROP TABLE #BusinessUnitsBusinessTaxInfo

END
GO

