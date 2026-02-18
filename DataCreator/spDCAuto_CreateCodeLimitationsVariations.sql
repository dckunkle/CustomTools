IF OBJECT_ID('dbo.spDCAuto_CreateCodeLimitationsVariations') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCodeLimitationsVariations AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCodeLimitationsVariations
Purpose:    Create codelimitationsvariations data from CorderAutomation
Method:     CodeLimitationsVariations
Screen GID: 51
Procedure:  dbo.prCovVariationsAdd

Date        User            Change
---------------------------------------------------------------------------------------------
11/13/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCodeLimitationsVariations '100-Config%', 22, 'CodeLimitationsVariations'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCodeLimitationsVariations
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

DECLARE @i_entity_name             VARCHAR(100)
       ,@i_Coverage_Strategy_gid   VARCHAR(100)
       ,@i_old_effective_date      VARCHAR(100)
       ,@i_old_termination_date    VARCHAR(100)
       ,@i_old_network_variation   VARCHAR(100)
       ,@i_key_5_field             VARCHAR(50)
       ,@i_key_6_field             VARCHAR(100)
       ,@i_key_7_field             VARCHAR(50)
       ,@i_key_8_field             VARCHAR(100)
       ,@i_key_9_field             VARCHAR(50)
       ,@i_Cov_Strategy_sid        VARCHAR(100)
       ,@i_action                  VARCHAR(10)
       ,@i_date_time_modified      VARCHAR(100)
       ,@iUserID                   VARCHAR(25)
       ,@i_effective_date          VARCHAR(100)
       ,@i_termination_date        VARCHAR(50)
       ,@i_Network_Variation       VARCHAR(100)
       ,@i_Disp_Type               VARCHAR(50)
       ,@iTaxonomyListID           VARCHAR(100)
       ,@iTaxonomyListDesc         VARCHAR(50)
       ,@i_Proc_Rule_Id            VARCHAR(100)
       ,@i_Proc_Rule_Desc          VARCHAR(50)
       ,@i_Proc_Step_Ther_Id       VARCHAR(50)
       ,@i_Proc_Step_Ther_Desc     VARCHAR(50)
       ,@i_Proc_Class_Rel_Id       VARCHAR(50)
       ,@i_Proc_Class_Rel_Desc     VARCHAR(50)
       ,@i_Proc_Payment_Id         VARCHAR(50)
       ,@i_Proc_Payment_Desc       VARCHAR(50)
       ,@i_Proc_XCheck_Id          VARCHAR(50)
       ,@i_Proc_XCheck_Desc        VARCHAR(50)
       ,@i_Proc_Bundling_Id        VARCHAR(50)
       ,@i_Proc_Bundling_Desc      VARCHAR(50)
       ,@i_Rev_Code_Id             VARCHAR(50)
       ,@i_Rev_Code_Desc           VARCHAR(50)
       ,@iGroupPricingBundlingID   VARCHAR(50)
       ,@iGroupPricingBundlingDesc VARCHAR(50)
       ,@i_Domain_Rule_Id          VARCHAR(50)
       ,@i_Domain_Rule_Desc        VARCHAR(50)
       ,@i_Domain_Rule_Priority    VARCHAR(50)
       ,@o_status                  INT
       ,@o_message                 VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CodeLimitationsVariations') IS NOT NULL
	DROP TABLE #CodeLimitationsVariations

CREATE TABLE #CodeLimitationsVariations
      (SearchID                  VARCHAR(200)
      ,i_entity_name             VARCHAR(100)       DEFAULT('Coverage_Variations')
      ,i_Coverage_Strategy_gid   VARCHAR(100)       DEFAULT('0')
      ,i_old_effective_date      VARCHAR(100)       DEFAULT('0')
      ,i_old_termination_date    VARCHAR(100)       DEFAULT('0')
      ,i_old_network_variation   VARCHAR(100)       DEFAULT('0')
      ,i_key_5_field             VARCHAR(50)        DEFAULT('0')
      ,i_key_6_field             VARCHAR(100)       DEFAULT('0')
      ,i_key_7_field             VARCHAR(50)        DEFAULT('0')
      ,i_key_8_field             VARCHAR(100)       DEFAULT('0')
      ,i_key_9_field             VARCHAR(50)        DEFAULT('0')
      ,i_Cov_Strategy_sid        VARCHAR(100)       DEFAULT('0')
      ,i_action                  VARCHAR(10)        DEFAULT('ADD')
      ,i_date_time_modified      VARCHAR(100)       DEFAULT('')
      ,iUserID                   VARCHAR(25)        DEFAULT('')
      ,i_effective_date          VARCHAR(100)
      ,i_termination_date        VARCHAR(50)
      ,i_Network_Variation       VARCHAR(100)
      ,i_Disp_Type               VARCHAR(50)
      ,iTaxonomyListID           VARCHAR(100)
      ,iTaxonomyListDesc         VARCHAR(50)
      ,i_Proc_Rule_Id            VARCHAR(100)
      ,i_Proc_Rule_Desc          VARCHAR(50)
      ,i_Proc_Step_Ther_Id       VARCHAR(50)
      ,i_Proc_Step_Ther_Desc     VARCHAR(50)
      ,i_Proc_Class_Rel_Id       VARCHAR(50)
      ,i_Proc_Class_Rel_Desc     VARCHAR(50)
      ,i_Proc_Payment_Id         VARCHAR(50)
      ,i_Proc_Payment_Desc       VARCHAR(50)
      ,i_Proc_XCheck_Id          VARCHAR(50)
      ,i_Proc_XCheck_Desc        VARCHAR(50)
      ,i_Proc_Bundling_Id        VARCHAR(50)
      ,i_Proc_Bundling_Desc      VARCHAR(50)
      ,i_Rev_Code_Id             VARCHAR(50)
      ,i_Rev_Code_Desc           VARCHAR(50)
      ,iGroupPricingBundlingID   VARCHAR(50)
      ,iGroupPricingBundlingDesc VARCHAR(50)
      ,i_Domain_Rule_Id          VARCHAR(50)
      ,i_Domain_Rule_Desc        VARCHAR(50)
      ,i_Domain_Rule_Priority    VARCHAR(50)
      ,o_status                  INT
      ,o_message                 VARCHAR(255)
      ,record_id                 INT
      ,static_gid                INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #CodeLimitationsVariations
      (SearchID
      ,i_effective_date
      ,i_termination_date
      ,i_Network_Variation
      ,i_Disp_Type
      ,iTaxonomyListID
      ,i_Proc_Rule_Id
      ,i_Proc_Step_Ther_Id
      ,i_Proc_Class_Rel_Id
      ,i_Proc_Payment_Id
      ,i_Proc_XCheck_Id
      ,i_Proc_Bundling_Id
      ,i_Rev_Code_Id
      ,iGroupPricingBundlingID
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
      ,ISNULL([*TerminationDate], '12/31/9999')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([NetworkVariation]), 'I')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([DispenserType]), '**')
      ,ISNULL([TaxonomyListID], '')
      ,ISNULL([CodeCoverage], '')
      ,ISNULL([CodeStepTherapyID], '')
      ,ISNULL([CodeClassExceptionID], '')
      ,ISNULL([CodeAlternateID], '')
      ,ISNULL([CodeFrequencyID], '')
      ,ISNULL([CodeBundlingID], '')
      ,ISNULL([RevenueCodeValidationID], '')
      ,ISNULL([CodeBundlingForGroupPricingID], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_CodeLimitationsVariations
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CodeLimitationsVariations
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE CodeLimitationsVariations_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Coverage_Strategy_gid
       ,i_old_effective_date
       ,i_old_termination_date
       ,i_old_network_variation
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Cov_Strategy_sid
       ,i_action
       ,i_date_time_modified
       ,iUserID
       ,i_effective_date
       ,i_termination_date
       ,i_Network_Variation
       ,i_Disp_Type
       ,iTaxonomyListID
       ,iTaxonomyListDesc
       ,i_Proc_Rule_Id
       ,i_Proc_Rule_Desc
       ,i_Proc_Step_Ther_Id
       ,i_Proc_Step_Ther_Desc
       ,i_Proc_Class_Rel_Id
       ,i_Proc_Class_Rel_Desc
       ,i_Proc_Payment_Id
       ,i_Proc_Payment_Desc
       ,i_Proc_XCheck_Id
       ,i_Proc_XCheck_Desc
       ,i_Proc_Bundling_Id
       ,i_Proc_Bundling_Desc
       ,i_Rev_Code_Id
       ,i_Rev_Code_Desc
       ,iGroupPricingBundlingID
       ,iGroupPricingBundlingDesc
       ,i_Domain_Rule_Id
       ,i_Domain_Rule_Desc
       ,i_Domain_Rule_Priority
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #CodeLimitationsVariations

   OPEN CodeLimitationsVariations_Cursor
  FETCH NEXT FROM CodeLimitationsVariations_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Coverage_Strategy_gid
       ,@i_old_effective_date
       ,@i_old_termination_date
       ,@i_old_network_variation
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Cov_Strategy_sid
       ,@i_action
       ,@i_date_time_modified
       ,@iUserID
       ,@i_effective_date
       ,@i_termination_date
       ,@i_Network_Variation
       ,@i_Disp_Type
       ,@iTaxonomyListID
       ,@iTaxonomyListDesc
       ,@i_Proc_Rule_Id
       ,@i_Proc_Rule_Desc
       ,@i_Proc_Step_Ther_Id
       ,@i_Proc_Step_Ther_Desc
       ,@i_Proc_Class_Rel_Id
       ,@i_Proc_Class_Rel_Desc
       ,@i_Proc_Payment_Id
       ,@i_Proc_Payment_Desc
       ,@i_Proc_XCheck_Id
       ,@i_Proc_XCheck_Desc
       ,@i_Proc_Bundling_Id
       ,@i_Proc_Bundling_Desc
       ,@i_Rev_Code_Id
       ,@i_Rev_Code_Desc
       ,@iGroupPricingBundlingID
       ,@iGroupPricingBundlingDesc
       ,@i_Domain_Rule_Id
       ,@i_Domain_Rule_Desc
       ,@i_Domain_Rule_Priority
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the Code Limitation gid
			SELECT @i_Coverage_Strategy_gid		= entity_gid
			  FROM Entity_Names
			 WHERE entity_identifier			= 'Coverage_Strategy'
			   AND entity_user_id				= @Searchid

			EXEC dbo.prCovVariationsAdd
             @i_entity_name
            ,@i_Coverage_Strategy_gid
            ,@i_old_effective_date
            ,@i_old_termination_date
            ,@i_old_network_variation
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_Cov_Strategy_sid
            ,@i_action
            ,@i_date_time_modified
            ,@iUserID
            ,@i_effective_date
            ,@i_termination_date
            ,@i_Network_Variation
            ,@i_Disp_Type
            ,@iTaxonomyListID
            ,@iTaxonomyListDesc
            ,@i_Proc_Rule_Id
            ,@i_Proc_Rule_Desc
            ,@i_Proc_Step_Ther_Id
            ,@i_Proc_Step_Ther_Desc
            ,@i_Proc_Class_Rel_Id
            ,@i_Proc_Class_Rel_Desc
            ,@i_Proc_Payment_Id
            ,@i_Proc_Payment_Desc
            ,@i_Proc_XCheck_Id
            ,@i_Proc_XCheck_Desc
            ,@i_Proc_Bundling_Id
            ,@i_Proc_Bundling_Desc
            ,@i_Rev_Code_Id
            ,@i_Rev_Code_Desc
            ,@iGroupPricingBundlingID
            ,@iGroupPricingBundlingDesc
            ,@i_Domain_Rule_Id
            ,@i_Domain_Rule_Desc
            ,@i_Domain_Rule_Priority
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_Proc_Step_Ther_Id, @i_Proc_XCheck_Id, @status, @err_num, @err_msg

        FETCH NEXT FROM CodeLimitationsVariations_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Coverage_Strategy_gid
             ,@i_old_effective_date
             ,@i_old_termination_date
             ,@i_old_network_variation
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Cov_Strategy_sid
             ,@i_action
             ,@i_date_time_modified
             ,@iUserID
             ,@i_effective_date
             ,@i_termination_date
             ,@i_Network_Variation
             ,@i_Disp_Type
             ,@iTaxonomyListID
             ,@iTaxonomyListDesc
             ,@i_Proc_Rule_Id
             ,@i_Proc_Rule_Desc
             ,@i_Proc_Step_Ther_Id
             ,@i_Proc_Step_Ther_Desc
             ,@i_Proc_Class_Rel_Id
             ,@i_Proc_Class_Rel_Desc
             ,@i_Proc_Payment_Id
             ,@i_Proc_Payment_Desc
             ,@i_Proc_XCheck_Id
             ,@i_Proc_XCheck_Desc
             ,@i_Proc_Bundling_Id
             ,@i_Proc_Bundling_Desc
             ,@i_Rev_Code_Id
             ,@i_Rev_Code_Desc
             ,@iGroupPricingBundlingID
             ,@iGroupPricingBundlingDesc
             ,@i_Domain_Rule_Id
             ,@i_Domain_Rule_Desc
             ,@i_Domain_Rule_Priority
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE CodeLimitationsVariations_Cursor
DEALLOCATE CodeLimitationsVariations_Cursor

END
GO