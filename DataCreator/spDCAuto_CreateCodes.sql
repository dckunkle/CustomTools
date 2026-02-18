IF OBJECT_ID('dbo.spDCAuto_CreateCodes') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodes AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodes
Purpose:    Create codes data from CorderAutomation

Screen:     3000
Method:     Codes
Procedure:  dbo.prProductTableAdd_Modify 
Entity:     Products

Date        User            Change
---------------------------------------------------------------------------------------------
06/28/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodes '100-Config%', 22, 'Codes'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodes
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

DECLARE @i_entity_name            VARCHAR(50)
       ,@i_Product_Gid            VARCHAR(50)
       ,@i_key_2_field            VARCHAR(50)
       ,@i_key_3_field            VARCHAR(50)
       ,@i_key_4_field            VARCHAR(50)
       ,@i_key_5_field            VARCHAR(50)
       ,@i_key_6_field            VARCHAR(50)
       ,@i_key_7_field            VARCHAR(50)
       ,@i_key_8_field            VARCHAR(50)
       ,@i_key_9_field            VARCHAR(50)
       ,@i_key_10_field           VARCHAR(50)
       ,@i_action                 VARCHAR(10)
       ,@i_date_time_modified     VARCHAR(30)
       ,@iUserID                  VARCHAR(25)
       ,@i_Product_qualifier      VARCHAR(50)
       ,@i_Product_id             VARCHAR(50)
       ,@i_Product_name           VARCHAR(300)
       ,@i_effective_date         VARCHAR(50)
       ,@i_termination_date       VARCHAR(50)
       ,@i_default_class          VARCHAR(50)
       ,@i_incentive_flag         VARCHAR(50)
       ,@i_generic_product_id     VARCHAR(50)
       ,@i_generic_name           VARCHAR(60)
       ,@i_manufacturer_id        VARCHAR(50)
       ,@i_manufacturer_name      VARCHAR(50)
       ,@i_generic_code           VARCHAR(50)
       ,@i_DEA_class_code         VARCHAR(50)
       ,@i_Therapeutic_class_code VARCHAR(50)
       ,@i_Therapeutic_equiv_code VARCHAR(50)
       ,@i_RX_OTC_indicator       VARCHAR(50)
       ,@i_third_party_rest_code  VARCHAR(50)
       ,@i_GPPC_code              VARCHAR(50)
       ,@i_metric_strength        VARCHAR(50)
       ,@i_strength_UOM           VARCHAR(50)
       ,@i_dosage_form            VARCHAR(50)
       ,@i_package_size           VARCHAR(50)
       ,@i_package_UOM            VARCHAR(50)
       ,@i_package_QTY            VARCHAR(50)
       ,@i_total_package_QTY      VARCHAR(50)
       ,@i_legend_Change_Date     VARCHAR(50)
       ,@i_DESI_code              VARCHAR(50)
       ,@i_maintenance_drug_code  VARCHAR(50)
       ,@i_dispensing_unit_code   VARCHAR(50)
       ,@i_unit_dose_code         VARCHAR(50)
       ,@i_route_admin_code       VARCHAR(50)
       ,@i_form_type_code         VARCHAR(50)
       ,@i_dollar_rank_code       VARCHAR(50)
       ,@i_RX_rank_code           VARCHAR(50)
       ,@i_single_comb_code       VARCHAR(50)
       ,@i_repackager_IND         VARCHAR(50)
       ,@i_superceded_NDC         VARCHAR(50)
       ,@i_superceded_name        VARCHAR(100)
       ,@i_preceded_NDC           VARCHAR(50)
       ,@i_preceded_name          VARCHAR(100)
       ,@i_last_change_date       VARCHAR(50)
       ,@i_drug_status            VARCHAR(50)
       ,@i_INT_EXT_Code           VARCHAR(50)
       ,@i_pkg_description        VARCHAR(50)
       ,@i_OTC_EQUIV_IND          VARCHAR(50)
       ,@i_stc_code               VARCHAR(50)
       ,@i_gcn_code               VARCHAR(50)
       ,@i_HICL_SeqNo             VARCHAR(50)
       ,@i_GTC_Code               VARCHAR(50)
       ,@i_HIC3_Code              VARCHAR(50)
       ,@i_Quadrant_Req           VARCHAR(50)
       ,@i_Tooth_Req              VARCHAR(50)
       ,@i_Surface_Req            VARCHAR(50)
       ,@i_Tooth_Type             VARCHAR(50)
       ,@i_Auto_Adj               VARCHAR(50)
       ,@i_Clinical_Doc           VARCHAR(50)
       ,@i_Credentialling         VARCHAR(50)
       ,@i_Color_Code             VARCHAR(50)
       ,@i_hist_multiplier        VARCHAR(50)
       ,@i_min_num_surfaces       VARCHAR(50)
       ,@i_max_num_surfaces       VARCHAR(50)
       ,@iTime_Units              VARCHAR(50)
       ,@i_asc_grouper            VARCHAR(50)
       ,@i_apc_classification     VARCHAR(50)
       ,@i_base_units             VARCHAR(50)
       ,@iUnitBasis               VARCHAR(50)
       ,@iRBCharge                VARCHAR(50)
       ,@oStatus                  INT
       ,@oMessage                 VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Codes') IS NOT NULL
	DROP TABLE #Codes

CREATE TABLE #Codes
      (SearchID                 VARCHAR(200)
      ,i_entity_name            VARCHAR(50)       DEFAULT('Products')
      ,i_Product_Gid            VARCHAR(50)       DEFAULT('0')
      ,i_key_2_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field            VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field           VARCHAR(50)       DEFAULT('0')
      ,i_action                 VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified     VARCHAR(30)       DEFAULT('')
      ,iUserID                  VARCHAR(25)       DEFAULT('')
      ,i_Product_qualifier      VARCHAR(50)
      ,i_Product_id             VARCHAR(50)
      ,i_Product_name           VARCHAR(300)
      ,i_effective_date         VARCHAR(50)
      ,i_termination_date       VARCHAR(50)
      ,i_default_class          VARCHAR(50)
      ,i_incentive_flag         VARCHAR(50)
      ,i_generic_product_id     VARCHAR(50)
      ,i_generic_name           VARCHAR(60)
      ,i_manufacturer_id        VARCHAR(50)
      ,i_manufacturer_name      VARCHAR(50)
      ,i_generic_code           VARCHAR(50)
      ,i_DEA_class_code         VARCHAR(50)
      ,i_Therapeutic_class_code VARCHAR(50)
      ,i_Therapeutic_equiv_code VARCHAR(50)
      ,i_RX_OTC_indicator       VARCHAR(50)
      ,i_third_party_rest_code  VARCHAR(50)
      ,i_GPPC_code              VARCHAR(50)
      ,i_metric_strength        VARCHAR(50)
      ,i_strength_UOM           VARCHAR(50)
      ,i_dosage_form            VARCHAR(50)
      ,i_package_size           VARCHAR(50)
      ,i_package_UOM            VARCHAR(50)
      ,i_package_QTY            VARCHAR(50)
      ,i_total_package_QTY      VARCHAR(50)
      ,i_legend_Change_Date     VARCHAR(50)
      ,i_DESI_code              VARCHAR(50)
      ,i_maintenance_drug_code  VARCHAR(50)
      ,i_dispensing_unit_code   VARCHAR(50)
      ,i_unit_dose_code         VARCHAR(50)
      ,i_route_admin_code       VARCHAR(50)
      ,i_form_type_code         VARCHAR(50)
      ,i_dollar_rank_code       VARCHAR(50)
      ,i_RX_rank_code           VARCHAR(50)
      ,i_single_comb_code       VARCHAR(50)
      ,i_repackager_IND         VARCHAR(50)
      ,i_superceded_NDC         VARCHAR(50)
      ,i_superceded_name        VARCHAR(100)
      ,i_preceded_NDC           VARCHAR(50)
      ,i_preceded_name          VARCHAR(100)
      ,i_last_change_date       VARCHAR(50)
      ,i_drug_status            VARCHAR(50)
      ,i_INT_EXT_Code           VARCHAR(50)
      ,i_pkg_description        VARCHAR(50)
      ,i_OTC_EQUIV_IND          VARCHAR(50)
      ,i_stc_code               VARCHAR(50)
      ,i_gcn_code               VARCHAR(50)
      ,i_HICL_SeqNo             VARCHAR(50)
      ,i_GTC_Code               VARCHAR(50)
      ,i_HIC3_Code              VARCHAR(50)
      ,i_Quadrant_Req           VARCHAR(50)
      ,i_Tooth_Req              VARCHAR(50)
      ,i_Surface_Req            VARCHAR(50)
      ,i_Tooth_Type             VARCHAR(50)
      ,i_Auto_Adj               VARCHAR(50)
      ,i_Clinical_Doc           VARCHAR(50)
      ,i_Credentialling         VARCHAR(50)
      ,i_Color_Code             VARCHAR(50)
      ,i_hist_multiplier        VARCHAR(50)
      ,i_min_num_surfaces       VARCHAR(50)
      ,i_max_num_surfaces       VARCHAR(50)
      ,iTime_Units              VARCHAR(50)
      ,i_asc_grouper            VARCHAR(50)
      ,i_apc_classification     VARCHAR(50)
      ,i_base_units             VARCHAR(50)
      ,iUnitBasis               VARCHAR(50)
      ,iRBCharge                VARCHAR(50)
      ,oStatus                  INT
      ,oMessage                 VARCHAR(100)
      ,record_id                INT
      ,static_gid               INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #Codes
          (SearchID
          ,i_Product_qualifier
          ,i_Product_id
          ,i_Product_name
          ,i_effective_date
          ,i_termination_date
          ,i_default_class
          ,i_incentive_flag
          ,i_generic_product_id
          ,i_generic_name
          ,i_manufacturer_id
          ,i_generic_code
          ,i_DEA_class_code
          ,i_Therapeutic_class_code
          ,i_Therapeutic_equiv_code
          ,i_RX_OTC_indicator
          ,i_third_party_rest_code
          ,i_GPPC_code
          ,i_metric_strength
          ,i_strength_UOM
          ,i_dosage_form
          ,i_package_size
          ,i_package_UOM
          ,i_package_QTY
          ,i_total_package_QTY
          ,i_legend_Change_Date
          ,i_DESI_code
          ,i_maintenance_drug_code
          ,i_dispensing_unit_code
          ,i_unit_dose_code
          ,i_route_admin_code
          ,i_form_type_code
          ,i_dollar_rank_code
          ,i_RX_rank_code
          ,i_single_comb_code
          ,i_repackager_IND
          ,i_superceded_NDC
          ,i_preceded_NDC
          ,i_last_change_date
          ,i_drug_status
          ,i_INT_EXT_Code
          ,i_pkg_description
          ,i_OTC_EQUIV_IND
          ,i_stc_code
          ,i_gcn_code
          ,i_HICL_SeqNo
          ,i_GTC_Code
          ,i_HIC3_Code
          ,i_Quadrant_Req
          ,i_Tooth_Req
          ,i_Surface_Req
          ,i_Tooth_Type
          ,i_Auto_Adj
          ,i_Clinical_Doc
          ,i_Credentialling
          ,i_Color_Code
          ,i_hist_multiplier
          ,i_min_num_surfaces
          ,i_max_num_surfaces
          ,iTime_Units
          ,i_asc_grouper
          ,i_apc_classification
          ,i_base_units
          ,iUnitBasis
          ,iRBCharge
          ,record_id
          ,static_gid)
    SELECT SearchID
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_CodeType]), 'NDC')
          ,ISNULL([*Common_CodeID], '')
          ,ISNULL([*Common_CodeDesc], '')
          ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*Common_TerminationDate],'12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_DefaultBenefitClass]), '100')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Common_IncentiveFlag]), 'U')
          ,ISNULL([DrugSetup_GPI], '')
          ,ISNULL([DrugSetup_GenericName], '')
          ,ISNULL([DrugSetup_MnftID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_GenericCode]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_DEAClass]), '1')
          ,ISNULL([DrugSetup_TherapyClass], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_TherapyEquiv]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_OTCIndicator]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_3rdPartyCode]), '')
          ,ISNULL([DrugSetup_GPPC], '')
          ,ISNULL([DrugSetup_MetricStrength], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_StrengthUOM]), 'EA')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_DosageForm]), 'AERO')
          ,ISNULL([DrugSetup_PackageSize], '0.00')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_PackageUOM]), 'EA')
          ,ISNULL([DrugSetup_PackageQuantity], '0.00')
          ,ISNULL([DrugSetup_TotPackageQty], '0.00')
          ,ISNULL([DrugSetup_ChangeDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_DESI]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_MaintIndicator]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_DispUnit]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_UnitDose]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_RouteAdmin]), 'BU')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_FormType]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_$Rank]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_RXRank]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_SingleComb]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_Repackaged]), 'N')
          ,ISNULL([DrugSetup_SupercededID], '')
          ,ISNULL([DrugSetup_PrecededID], '')
          ,ISNULL([DrugSetup_LastChange], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_CodeStatus]), 'A')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_IntExtCode]), 'E')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_PkgDescription]), 'AMP')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DrugSetup_OTCEquiv]), 'N')
          ,ISNULL([DrugSetup_STCCode], '')
          ,ISNULL([DrugSetup_GCNCode], '')
          ,ISNULL([DrugSetup_HICLSeqNo], '')
          ,ISNULL([DrugSetup_GTCCode], '')
          ,ISNULL([DrugSetup_HIC3Code], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_QuadrantReq]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_ToothReq]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_SurfaceReq]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_ValidTooth]), '00')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_AutoAdjudicate]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_ClinicalDoc]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_CredentialingReq]), 'N')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DentalSetup_ColorCode]), 'DF')
          ,ISNULL([DentalSetup_HistoryMultiplier], '1')
          ,ISNULL([DentalSetup_MinNumSurfaces], '0')
          ,ISNULL([DentalSetup_MaxNumSurfaces], '99')
          ,ISNULL([DentalSetup_TimeUnits], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MedicalSetup_ASCGrouperID]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MedicalSetup_APCClassification]), '')
          ,ISNULL([MedicalSetup_baseUnit], '0')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MedicalSetup_BasisOfUnits]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([MedicalSetup_RoomAndBoardCharge]), 'N')
          ,ISNULL([RecordID], '')
          ,ISNULL([gid], '')
      FROM COREAUTO.CoreAutomation.dbo.TD_Codes
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #Codes
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
DECLARE Codes_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Product_Gid
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
       ,i_Product_qualifier
       ,i_Product_id
       ,i_Product_name
       ,i_effective_date
       ,i_termination_date
       ,i_default_class
       ,i_incentive_flag
       ,i_generic_product_id
       ,i_generic_name
       ,i_manufacturer_id
       ,i_manufacturer_name
       ,i_generic_code
       ,i_DEA_class_code
       ,i_Therapeutic_class_code
       ,i_Therapeutic_equiv_code
       ,i_RX_OTC_indicator
       ,i_third_party_rest_code
       ,i_GPPC_code
       ,i_metric_strength
       ,i_strength_UOM
       ,i_dosage_form
       ,i_package_size
       ,i_package_UOM
       ,i_package_QTY
       ,i_total_package_QTY
       ,i_legend_Change_Date
       ,i_DESI_code
       ,i_maintenance_drug_code
       ,i_dispensing_unit_code
       ,i_unit_dose_code
       ,i_route_admin_code
       ,i_form_type_code
       ,i_dollar_rank_code
       ,i_RX_rank_code
       ,i_single_comb_code
       ,i_repackager_IND
       ,i_superceded_NDC
       ,i_superceded_name
       ,i_preceded_NDC
       ,i_preceded_name
       ,i_last_change_date
       ,i_drug_status
       ,i_INT_EXT_Code
       ,i_pkg_description
       ,i_OTC_EQUIV_IND
       ,i_stc_code
       ,i_gcn_code
       ,i_HICL_SeqNo
       ,i_GTC_Code
       ,i_HIC3_Code
       ,i_Quadrant_Req
       ,i_Tooth_Req
       ,i_Surface_Req
       ,i_Tooth_Type
       ,i_Auto_Adj
       ,i_Clinical_Doc
       ,i_Credentialling
       ,i_Color_Code
       ,i_hist_multiplier
       ,i_min_num_surfaces
       ,i_max_num_surfaces
       ,iTime_Units
       ,i_asc_grouper
       ,i_apc_classification
       ,i_base_units
       ,iUnitBasis
       ,iRBCharge
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #Codes

   OPEN Codes_Cursor
  FETCH NEXT FROM Codes_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Product_Gid
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
       ,@i_Product_qualifier
       ,@i_Product_id
       ,@i_Product_name
       ,@i_effective_date
       ,@i_termination_date
       ,@i_default_class
       ,@i_incentive_flag
       ,@i_generic_product_id
       ,@i_generic_name
       ,@i_manufacturer_id
       ,@i_manufacturer_name
       ,@i_generic_code
       ,@i_DEA_class_code
       ,@i_Therapeutic_class_code
       ,@i_Therapeutic_equiv_code
       ,@i_RX_OTC_indicator
       ,@i_third_party_rest_code
       ,@i_GPPC_code
       ,@i_metric_strength
       ,@i_strength_UOM
       ,@i_dosage_form
       ,@i_package_size
       ,@i_package_UOM
       ,@i_package_QTY
       ,@i_total_package_QTY
       ,@i_legend_Change_Date
       ,@i_DESI_code
       ,@i_maintenance_drug_code
       ,@i_dispensing_unit_code
       ,@i_unit_dose_code
       ,@i_route_admin_code
       ,@i_form_type_code
       ,@i_dollar_rank_code
       ,@i_RX_rank_code
       ,@i_single_comb_code
       ,@i_repackager_IND
       ,@i_superceded_NDC
       ,@i_superceded_name
       ,@i_preceded_NDC
       ,@i_preceded_name
       ,@i_last_change_date
       ,@i_drug_status
       ,@i_INT_EXT_Code
       ,@i_pkg_description
       ,@i_OTC_EQUIV_IND
       ,@i_stc_code
       ,@i_gcn_code
       ,@i_HICL_SeqNo
       ,@i_GTC_Code
       ,@i_HIC3_Code
       ,@i_Quadrant_Req
       ,@i_Tooth_Req
       ,@i_Surface_Req
       ,@i_Tooth_Type
       ,@i_Auto_Adj
       ,@i_Clinical_Doc
       ,@i_Credentialling
       ,@i_Color_Code
       ,@i_hist_multiplier
       ,@i_min_num_surfaces
       ,@i_max_num_surfaces
       ,@iTime_Units
       ,@i_asc_grouper
       ,@i_apc_classification
       ,@i_base_units
       ,@iUnitBasis
       ,@iRBCharge
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

			EXEC dbo.prProductTableAdd_Modify 
                 @i_entity_name
                ,@i_Product_Gid
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
                ,@i_Product_qualifier
                ,@i_Product_id
                ,@i_Product_name
                ,@i_effective_date
                ,@i_termination_date
                ,@i_default_class
                ,@i_incentive_flag
                ,@i_generic_product_id
                ,@i_generic_name
                ,@i_manufacturer_id
                ,@i_manufacturer_name
                ,@i_generic_code
                ,@i_DEA_class_code
                ,@i_Therapeutic_class_code
                ,@i_Therapeutic_equiv_code
                ,@i_RX_OTC_indicator
                ,@i_third_party_rest_code
                ,@i_GPPC_code
                ,@i_metric_strength
                ,@i_strength_UOM
                ,@i_dosage_form
                ,@i_package_size
                ,@i_package_UOM
                ,@i_package_QTY
                ,@i_total_package_QTY
                ,@i_legend_Change_Date
                ,@i_DESI_code
                ,@i_maintenance_drug_code
                ,@i_dispensing_unit_code
                ,@i_unit_dose_code
                ,@i_route_admin_code
                ,@i_form_type_code
                ,@i_dollar_rank_code
                ,@i_RX_rank_code
                ,@i_single_comb_code
                ,@i_repackager_IND
                ,@i_superceded_NDC
                ,@i_superceded_name
                ,@i_preceded_NDC
                ,@i_preceded_name
                ,@i_last_change_date
                ,@i_drug_status
                ,@i_INT_EXT_Code
                ,@i_pkg_description
                ,@i_OTC_EQUIV_IND
                ,@i_stc_code
                ,@i_gcn_code
                ,@i_HICL_SeqNo
                ,@i_GTC_Code
                ,@i_HIC3_Code
                ,@i_Quadrant_Req
                ,@i_Tooth_Req
                ,@i_Surface_Req
                ,@i_Tooth_Type
                ,@i_Auto_Adj
                ,@i_Clinical_Doc
                ,@i_Credentialling
                ,@i_Color_Code
                ,@i_hist_multiplier
                ,@i_min_num_surfaces
                ,@i_max_num_surfaces
                ,@iTime_Units
                ,@i_asc_grouper
                ,@i_apc_classification
                ,@i_base_units
                ,@iUnitBasis
                ,@iRBCharge
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT


        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Product_qualifier, @i_Product_id, @i_Product_name, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM Codes_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Product_Gid
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
             ,@i_Product_qualifier
             ,@i_Product_id
             ,@i_Product_name
             ,@i_effective_date
             ,@i_termination_date
             ,@i_default_class
             ,@i_incentive_flag
             ,@i_generic_product_id
             ,@i_generic_name
             ,@i_manufacturer_id
             ,@i_manufacturer_name
             ,@i_generic_code
             ,@i_DEA_class_code
             ,@i_Therapeutic_class_code
             ,@i_Therapeutic_equiv_code
             ,@i_RX_OTC_indicator
             ,@i_third_party_rest_code
             ,@i_GPPC_code
             ,@i_metric_strength
             ,@i_strength_UOM
             ,@i_dosage_form
             ,@i_package_size
             ,@i_package_UOM
             ,@i_package_QTY
             ,@i_total_package_QTY
             ,@i_legend_Change_Date
             ,@i_DESI_code
             ,@i_maintenance_drug_code
             ,@i_dispensing_unit_code
             ,@i_unit_dose_code
             ,@i_route_admin_code
             ,@i_form_type_code
             ,@i_dollar_rank_code
             ,@i_RX_rank_code
             ,@i_single_comb_code
             ,@i_repackager_IND
             ,@i_superceded_NDC
             ,@i_superceded_name
             ,@i_preceded_NDC
             ,@i_preceded_name
             ,@i_last_change_date
             ,@i_drug_status
             ,@i_INT_EXT_Code
             ,@i_pkg_description
             ,@i_OTC_EQUIV_IND
             ,@i_stc_code
             ,@i_gcn_code
             ,@i_HICL_SeqNo
             ,@i_GTC_Code
             ,@i_HIC3_Code
             ,@i_Quadrant_Req
             ,@i_Tooth_Req
             ,@i_Surface_Req
             ,@i_Tooth_Type
             ,@i_Auto_Adj
             ,@i_Clinical_Doc
             ,@i_Credentialling
             ,@i_Color_Code
             ,@i_hist_multiplier
             ,@i_min_num_surfaces
             ,@i_max_num_surfaces
             ,@iTime_Units
             ,@i_asc_grouper
             ,@i_apc_classification
             ,@i_base_units
             ,@iUnitBasis
             ,@iRBCharge
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE Codes_Cursor
DEALLOCATE Codes_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#Codes') IS NOT NULL
	DROP TABLE #Codes

END
GO

