/**************************************************************************************************
Name:       spQAAuto_DeleteTestDataPortal
Purpose:    Delete portal automation test data given the user_id
            Calls spQAAuto_DeletePortalUser to delete the portal user

Date        User            Change
---------------------------------------------------------------------------------------------
02/28/2018	DK				Original procedure
---------------------------------------------------------------------------------------------

EXEC spPortal_RemoveDeletedRecords 1292
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spPortal_RemoveDeletedRecords
      (@days INT)
AS
BEGIN
SET NOCOUNT ON

DECLARE @sql				VARCHAR(8000)
	   ,@table_name			VARCHAR(256)
	   ,@join_table			VARCHAR(256)
	   ,@join_field_src		VARCHAR(256)
	   ,@join_field_dst		VARCHAR(256)
	   ,@table_level		INT
	   ,@cutoff_date		DATE
	   
--*************************************************************************************************
-- Calculate the cutoff date
--*************************************************************************************************
SELECT @cutoff_date = DATEADD(day, -@days, GETDATE())
SELECT @cutoff_date

--*************************************************************************************************
-- Create Provider tables
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#provider_ids') IS NOT NULL
	BEGIN DROP TABLE #provider_ids END

CREATE TABLE #provider_ids
      (PROVIDER_ID					NUMERIC(18,0))

IF OBJECT_ID('tempdb.dbo.#provider_scorecard_ids') IS NOT NULL
	BEGIN DROP TABLE #provider_scorecard_ids END

CREATE TABLE #provider_scorecard_ids
      (PROVIDER_SCORECARD_ID		NUMERIC(18,0))

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

CREATE TABLE #table_deletes
      (table_name					VARCHAR(256)
	  ,join_table					VARCHAR(256)	DEFAULT('')
	  ,join_field_src				VARCHAR(256)	DEFAULT('')
	  ,join_field_dst				VARCHAR(256)	DEFAULT(''))

--*************************************************************************************************
-- Populate Provider tables
--*************************************************************************************************
INSERT INTO #provider_ids
      (PROVIDER_ID)
SELECT P.PROVIDER_ID
  FROM PROVIDER			P
 WHERE P.DELETED		= 'Y'
   AND P.ENTRY_DATE		< @cutoff_date

INSERT INTO #provider_scorecard_ids
      (PROVIDER_SCORECARD_ID)
SELECT PS.PROVIDER_SCORECARD_ID
  FROM PROVIDER_SCORECARD	PS
  JOIN PROVIDER				P
    ON PS.PROVIDER_ID		= P.PROVIDER_ID

--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER'					, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_ROLE'					, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_ACCEPTING_PATIENT'	, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_ACCREDITATION'	, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_EDUCATION'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_ID'				, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_LANGUAGE'			, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_LICENSE_INFO'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_SCORECARD'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_SPECIALTY'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_REG_ENTRY'			, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_EMPLOYEE'				, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('REMITTANCE_ADVICE'			, '#provider_ids', 'PAYEE_ID'   , 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_AFFILIATION'			, '#provider_ids', 'CHILD_AFFILIATION_ID', 'PROVIDER_ID')
INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_SCORECARD_DETAIL'	, '#provider_scorecard_ids', 'PROVIDER_SCORECARD_ID', 'PROVIDER_SCORECARD_ID')

--*************************************************************************************************
-- Create Provider tables
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#claim_ids') IS NOT NULL
	BEGIN DROP TABLE #claim_ids END

CREATE TABLE #claim_ids
      (CLAIM_ID					NUMERIC(18,0))

--*************************************************************************************************
-- Populate Claims tables
--*************************************************************************************************
INSERT INTO #claim_ids
      (CLAIM_ID)
SELECT C.CLAIM_ID
  FROM CLAIM			C
 WHERE C.DELETED		= 'Y'
   AND C.ENTRY_DATE		< @cutoff_date

--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('CLAIM'						, '#claim_ids', 'CLAIM_ID', 'CLAIM_ID')
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('CLAIM_ADJUSTMENT'			, '#claim_ids', 'CLAIM_ID', 'CLAIM_ID')

--INSERT INTO #table_names (table_name) VALUES ('CLAIM_HISTORY')
--INSERT INTO #table_names (table_name) VALUES ('CLAIM_PAYMENT')
--INSERT INTO #table_names (table_name) VALUES ('CLAIM_PAYMENT_ADJUSTMENT')
--INSERT INTO #table_names (table_name) VALUES ('CLAIM_PMT_SUPPL_AMOUNT')
--INSERT INTO #table_names (table_name) VALUES ('CLAIM_PROV_ACCESS')
--INSERT INTO #table_names (table_name) VALUES ('CLAIM_RELATED_CLAIM')
--*************************************************************************************************
-- Insert the tables that will be maintained by this process
--*************************************************************************************************
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_PAYMENT'				, '#claim_ids', 'PROVIDER_ID', 'PROVIDER_ID')
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_ADJUSTMENT'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROV_AFFILIATION'			, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
--INSERT INTO #table_deletes (table_name, join_table, join_field_src, join_field_dst) VALUES ('PROVIDER_SUMMARY_INFO'		, '#provider_ids', 'PROVIDER_ID', 'PROVIDER_ID')
--INSERT INTO #table_names (table_name) VALUES ('ACCOUNT_SUMMARY')
--INSERT INTO #table_names (table_name) VALUES ('ACCUMULATOR')
--INSERT INTO #table_names (table_name) VALUES ('ADDPROVIDERUSERTABLE')
--INSERT INTO #table_names (table_name) VALUES ('ADDRESS')
--INSERT INTO #table_names (table_name) VALUES ('AFFILIATION_SPECIALTY')
--INSERT INTO #table_names (table_name) VALUES ('AUTH')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_AUTO_APPROVE')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_DIAGNOSIS')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_PROV_ACCESS')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_REQUEST')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_REQUESTER_ID')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_SERVICE')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_SERVICE_PROV')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_SERVICE_PROV_ID')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_TOOTH_INFO')
--INSERT INTO #table_names (table_name) VALUES ('AUTH_TYPE_XREF')
--INSERT INTO #table_names (table_name) VALUES ('BENEFIT_LIMIT')
--INSERT INTO #table_names (table_name) VALUES ('BENEFIT_PLAN')
--INSERT INTO #table_names (table_name) VALUES ('BENEFIT_PLAN_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('BENEFIT_PLAN_DOC')
--INSERT INTO #table_names (table_name) VALUES ('BENEFIT_PRICING')
--INSERT INTO #table_names (table_name) VALUES ('BROKER')
--INSERT INTO #table_names (table_name) VALUES ('BROKER_EMPLOYEE')

--INSERT INTO #table_names (table_name) VALUES ('COMM_CONTACT')
--INSERT INTO #table_names (table_name) VALUES ('COMMISSION')
--INSERT INTO #table_names (table_name) VALUES ('COMMISSION_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('CONTACT')
--INSERT INTO #table_names (table_name) VALUES ('DIAGNOSIS_LIST')
--INSERT INTO #table_names (table_name) VALUES ('DOCUMENT')
--INSERT INTO #table_names (table_name) VALUES ('DOCUMENT_NOTIFICATION_VIEWER')
--INSERT INTO #table_names (table_name) VALUES ('ELIGIBILITY')
--INSERT INTO #table_names (table_name) VALUES ('ELIGIBILITY_BENEFIT')
--INSERT INTO #table_names (table_name) VALUES ('ELIGIBILITY_COMMENT')
--INSERT INTO #table_names (table_name) VALUES ('ELIGIBILITY_PROVIDER')
--INSERT INTO #table_names (table_name) VALUES ('ELIGIBILITY_RESTRICTION')
--INSERT INTO #table_names (table_name) VALUES ('EMPLOYEE')
--INSERT INTO #table_names (table_name) VALUES ('EMPLOYER')
--INSERT INTO #table_names (table_name) VALUES ('EMPLOYER_BROKER')
--INSERT INTO #table_names (table_name) VALUES ('ENTITY_HOLDS')
--INSERT INTO #table_names (table_name) VALUES ('EOP_PROV_ACCESS')
--INSERT INTO #table_names (table_name) VALUES ('FILE_ACCESS')
--INSERT INTO #table_names (table_name) VALUES ('FILE_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('FILE_DETAIL_ASSOCIATION')
--INSERT INTO #table_names (table_name) VALUES ('GRACE_PERIOD')
INSERT INTO #table_deletes (table_name) VALUES ('HCARE_SERVICES_DELIVERY')
--INSERT INTO #table_names (table_name) VALUES ('HCARE_SVC_DELIVERY_REQ')
--INSERT INTO #table_names (table_name) VALUES ('HCARE_SVC_DELIVERY_USED')
--INSERT INTO #table_names (table_name) VALUES ('HEALTH_CARE_CODE_INFO')
--INSERT INTO #table_names (table_name) VALUES ('HEALTH_CARE_REMARK_CODES')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_BEN_PLAN_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_BENEFIT_LIMIT')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_BENEFIT_PKG')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_BENEFIT_PLAN')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_COST_SHARE_VARIANCE')
--INSERT INTO #table_names (table_name) VALUES ('HIOS_SBC_SCENARIO')
--INSERT INTO #table_names (table_name) VALUES ('ID_CARD_LIMIT')
--INSERT INTO #table_names (table_name) VALUES ('INVOICE')
--INSERT INTO #table_names (table_name) VALUES ('INVOICE_ADJUSTMENT')
--INSERT INTO #table_names (table_name) VALUES ('INVOICE_PAYMENT')
--INSERT INTO #table_names (table_name) VALUES ('L_ADDRESS_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_ADMISSION_TYPE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_AUTH_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_BENEFIT_LIMIT_LEVEL')
--INSERT INTO #table_names (table_name) VALUES ('L_BENEFIT_LIMIT_NETWORK')
--INSERT INTO #table_names (table_name) VALUES ('L_BENEFIT_LIMIT_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_CERTIFICATION_STATUS')
--INSERT INTO #table_names (table_name) VALUES ('L_CLAIM_ADJ_RSN_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_CLAIM_RELATIONSHIP_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_CLAIM_STATUS_CAT_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_CLAIM_STATUS_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_CLAIM_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_CONTRACT_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_COUNTRY_SUBDIVISION')
--INSERT INTO #table_names (table_name) VALUES ('L_COVERAGE_LEVEL_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_DELAY_REASON_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_DIAGNOSIS_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_DRG_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_ELIGIBILITY_CHANGE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_EMPLOYMENT_CLASS_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_EMPLOYMENT_STATUS_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_EPSDT_REFERRAL_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_ETHNICITY_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_FACILITY_TYPE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_FILE_DETAIL_CATEGORY')
--INSERT INTO #table_names (table_name) VALUES ('L_HOLD_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_IDENTIFIED_ETHNICITY_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_IDENTIFIED_RACE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_INSURANCE_LINE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_INTERVENTION_ACTION')
--INSERT INTO #table_names (table_name) VALUES ('L_LANGUAGE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_LEVEL_OF_CARE')
--INSERT INTO #table_names (table_name) VALUES ('L_LOCATION_SERVICE')
--INSERT INTO #table_names (table_name) VALUES ('L_MAINTENANCE_REASON_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_MARITAL_STATUS_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_MEDICARE_ELIG_RSN_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_MEMBER_INTERVENTION')
--INSERT INTO #table_names (table_name) VALUES ('L_NEWS_CATEGORY')
--INSERT INTO #table_names (table_name) VALUES ('L_PROCEDURE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_PROCEDURE_MODIFIER')
--INSERT INTO #table_names (table_name) VALUES ('L_PROV_ACCEPTING_PATIENT')
--INSERT INTO #table_names (table_name) VALUES ('L_PROVIDER_LICENSE_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_PROVIDER_TAXONOMY')
--INSERT INTO #table_names (table_name) VALUES ('L_PROVIDER_TYPE')
--INSERT INTO #table_names (table_name) VALUES ('L_RACE_ETHNICITY_COLLECTION_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_REJECT_REASON_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_RELATIONSHIP_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_REMITTANCE_REMARK_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_REVENUE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_SERVICE_CLASS')
--INSERT INTO #table_names (table_name) VALUES ('L_SERVICE_TYPE_CODE')
--INSERT INTO #table_names (table_name) VALUES ('L_TYPE_OF_SERVICE')
--INSERT INTO #table_names (table_name) VALUES ('L_UNIT_OF_MEASUREMENT_CODE')
--INSERT INTO #table_names (table_name) VALUES ('LINE_OF_BUSINESS')
--INSERT INTO #table_names (table_name) VALUES ('LOB_NETWORK')
--INSERT INTO #table_names (table_name) VALUES ('LOCATION')
--INSERT INTO #table_names (table_name) VALUES ('LOCATION_HOURS')
--INSERT INTO #table_names (table_name) VALUES ('LOCATION_SERVICES')
--INSERT INTO #table_names (table_name) VALUES ('MEDICAL_PROCEDURE')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_BROKER')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_COB')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_CONTACT')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_DIAGNOSIS')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_EMPLOYMENT_CLASS')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_ID')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_INTERVENTION')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_INTERVENTION_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_LANGUAGE')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_LIST_DETAILS')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_LISTS')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_PREMIUM')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_PROVIDER')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_SERVICE_HISTORY')
--INSERT INTO #table_names (table_name) VALUES ('MEMBER_SHARE_PREFERENCES')
--INSERT INTO #table_names (table_name) VALUES ('NDC_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('NETWORK')
--INSERT INTO #table_names (table_name) VALUES ('NETWORK_AFFILIATION')
--INSERT INTO #table_names (table_name) VALUES ('NEWS')
--INSERT INTO #table_names (table_name) VALUES ('NEWS_ASSOCIATION')
--INSERT INTO #table_names (table_name) VALUES ('NOTIFICATION_TO_SEND')
--INSERT INTO #table_names (table_name) VALUES ('OTHER_CARRIER')
--INSERT INTO #table_names (table_name) VALUES ('PAYER')
--INSERT INTO #table_names (table_name) VALUES ('PB_GROUP')
--INSERT INTO #table_names (table_name) VALUES ('POLICY')
--INSERT INTO #table_names (table_name) VALUES ('POLICY_BENEFIT')
--INSERT INTO #table_names (table_name) VALUES ('POLICY_BENEFIT_NETWORK')
--INSERT INTO #table_names (table_name) VALUES ('POLICY_BENEFIT_PB_GROUP')
--INSERT INTO #table_names (table_name) VALUES ('PRICING_TIER')
--INSERT INTO #table_names (table_name) VALUES ('PROCEDURE_RULE')
--INSERT INTO #table_names (table_name) VALUES ('PROV_BILL')
--INSERT INTO #table_names (table_name) VALUES ('PROV_BILL_ASSOC')
--INSERT INTO #table_names (table_name) VALUES ('PROV_BILL_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('PROV_NETWORK_AFFILIATION')
--INSERT INTO #table_names (table_name) VALUES ('PROV_NETWORK_SPECIALTY')
--INSERT INTO #table_names (table_name) VALUES ('QUOTATION')
--INSERT INTO #table_names (table_name) VALUES ('QUOTATION_ITEM')
--INSERT INTO #table_names (table_name) VALUES ('QUOTATION_PLAN')
--INSERT INTO #table_names (table_name) VALUES ('RAR_CLAIM')
--INSERT INTO #table_names (table_name) VALUES ('REMITTANCE_ADVICE')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_LINE')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_LINE_ICN')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_LINE_PROCESSING_POLICY')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_PAYMENT')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_PAYMENT_ADJ')
--INSERT INTO #table_names (table_name) VALUES ('SERVICE_PMT_SUPPL_AMOUNT')
--INSERT INTO #table_names (table_name) VALUES ('SVC_LINE_ADJUDICATION')
--INSERT INTO #table_names (table_name) VALUES ('THIRD_PARTY_FILE_ACCESS')
--INSERT INTO #table_names (table_name) VALUES ('THIRD_PARTY_FILE_DETAIL')
--INSERT INTO #table_names (table_name) VALUES ('TOOTH_INFO')
--INSERT INTO #table_names (table_name) VALUES ('VIEW_PROVIDER_DIRECTORY')
--INSERT INTO #table_names (table_name) VALUES ('X12_ENTITY')
--INSERT INTO #table_names (table_name) VALUES ('X12_ENTITY_ID')

--*************************************************************************************************
-- Delete data using the proper delete order and for the right IDs
--*************************************************************************************************
BEGIN TRY
		
	DECLARE table_count_cursor CURSOR FOR
	SELECT TC.table_name
		  ,TC.join_table
		  ,TC.join_field_src
		  ,TC.join_field_dst
		  ,DO.table_level
    FROM #table_deletes			TC
	JOIN DeleteOrder			DO
		ON TC.table_name		= DO.table_name
	ORDER BY DO.table_level DESC
		    ,DO.table_name  DESC

	OPEN table_count_cursor
    FETCH NEXT FROM table_count_cursor INTO @table_name, @join_table, @join_field_src, @join_field_dst, @table_level

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF @join_table <> ''
				BEGIN

					SELECT @sql = 'DELETE SRC' 
								+ '  FROM ' + @table_name + ' SRC'
								+ '  JOIN ' + @join_table + ' DST'
								+ '    ON SRC.' + @join_field_src + ' = DST.' + @join_field_dst
					PRINT @sql
					EXEC (@sql)
					SELECT @table_name, @@ROWCOUNT
				END
			ELSE
				BEGIN
					SELECT @sql = 'DELETE ' + @table_name
					            + ' WHERE ENTRY_DATE < ' + CONVERT(VARCHAR(20), @cutoff_date)
								+ '   AND DELETED = ''Y'''
					PRINT @sql
					EXEC (@sql)
					SELECT @table_name, @@ROWCOUNT
				END

			FETCH NEXT FROM table_count_cursor INTO @table_name, @join_table, @join_field_src, @join_field_dst, @table_level
		END

	CLOSE table_count_cursor
	DEALLOCATE table_count_cursor
END TRY
BEGIN CATCH

	PRINT ERROR_MESSAGE()
	CLOSE table_count_cursor
	DEALLOCATE table_count_cursor

END CATCH

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CONFIG_ERROR:

IF OBJECT_ID('temp.dbo.#provider_ids') IS NOT NULL
	BEGIN DROP TABLE #provider_ids END

IF OBJECT_ID('tempdb.dbo.#provider_scorecard_ids') IS NOT NULL
	BEGIN DROP TABLE #provider_scorecard_ids END

IF OBJECT_ID('tempdb.dbo.#table_deletes') IS NOT NULL
	BEGIN DROP TABLE #table_deletes END

END
GO