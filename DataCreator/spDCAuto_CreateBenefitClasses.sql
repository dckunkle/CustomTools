IF OBJECT_ID('dbo.spDCAuto_CreateBenefitClasses') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBenefitClasses AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBenefitClasses
Purpose:    Create benefitclasses data from CorderAutomation
Method:     BenefitClasses
Screen GID: 3002
Procedure:  dbo.prBenefitClassAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/18/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBenefitClasses '100-Config%', 22, 'BenefitClasses'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBenefitClasses
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

DECLARE @i_entity_name        VARCHAR(50)
       ,@i_Key_Benefit_Class  VARCHAR(100)
       ,@i_class_gid          VARCHAR(50)
       ,@i_key_3_field        VARCHAR(50)
       ,@i_key_4_field        VARCHAR(50)
       ,@i_key_5_field        VARCHAR(50)
       ,@i_key_6_field        VARCHAR(50)
       ,@i_key_7_field        VARCHAR(50)
       ,@i_key_8_field        VARCHAR(50)
       ,@i_key_9_field        VARCHAR(50)
       ,@i_key_10_field       VARCHAR(50)
       ,@i_action             VARCHAR(10)
       ,@i_date_time_modified VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@i_Benefit_Class      VARCHAR(50)
       ,@i_Benefit_Class_Desc VARCHAR(50)
       ,@i_service_type_id    VARCHAR(50)
       ,@i_service_type_desc  VARCHAR(50)
       ,@i_report_class       VARCHAR(50)
       ,@iColorCode           VARCHAR(50)
       ,@i_product_id         VARCHAR(50)
       ,@i_product_name       VARCHAR(300)
       ,@i_default_lob        VARCHAR(50)
       ,@i_copay_per          VARCHAR(50)
       ,@iDiscretionary       VARCHAR(50)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BenefitClasses') IS NOT NULL
	DROP TABLE #BenefitClasses

CREATE TABLE #BenefitClasses
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('Benefit_Classes')
      ,i_Key_Benefit_Class  VARCHAR(100)      DEFAULT('0')
      ,i_class_gid          VARCHAR(50)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field        VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field       VARCHAR(50)       DEFAULT('0')
      ,i_action             VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,i_Benefit_Class      VARCHAR(50)
      ,i_Benefit_Class_Desc VARCHAR(50)
      ,i_service_type_id    VARCHAR(50)
      ,i_service_type_desc  VARCHAR(50)
      ,i_report_class       VARCHAR(50)
      ,iColorCode           VARCHAR(50)
      ,i_product_id         VARCHAR(50)
      ,i_product_name       VARCHAR(300)
      ,i_default_lob        VARCHAR(50)
      ,i_copay_per          VARCHAR(50)
      ,iDiscretionary       VARCHAR(50)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BenefitClasses
      (SearchID
      ,i_Benefit_Class
      ,i_Benefit_Class_Desc
      ,i_service_type_id
      ,i_report_class
      ,iColorCode
      ,i_product_id
      ,i_default_lob
      ,i_copay_per
      ,iDiscretionary
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*Benefit_Class], '0')
      ,ISNULL([*Description], '')
      ,ISNULL([Service_Type_ID], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Reporting_Class]), '100')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Color_Code]), 'Clear')
      ,ISNULL([Representative_Code], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([System_LOB]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Copay_Per_Indicator]), 'L')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([270_Discretionary_Service]), 'N')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BenefitClasses
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BenefitClasses
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BenefitClasses_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_Key_Benefit_Class
       ,i_class_gid
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
       ,i_Benefit_Class
       ,i_Benefit_Class_Desc
       ,i_service_type_id
       ,i_service_type_desc
       ,i_report_class
       ,iColorCode
       ,i_product_id
       ,i_product_name
       ,i_default_lob
       ,i_copay_per
       ,iDiscretionary
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BenefitClasses

   OPEN BenefitClasses_Cursor
  FETCH NEXT FROM BenefitClasses_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_Key_Benefit_Class
       ,@i_class_gid
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
       ,@i_Benefit_Class
       ,@i_Benefit_Class_Desc
       ,@i_service_type_id
       ,@i_service_type_desc
       ,@i_report_class
       ,@iColorCode
       ,@i_product_id
       ,@i_product_name
       ,@i_default_lob
       ,@i_copay_per
       ,@iDiscretionary
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prBenefitClassAddModify
             @i_entity_name
            ,@i_Key_Benefit_Class
            ,@i_class_gid
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
            ,@i_Benefit_Class
            ,@i_Benefit_Class_Desc
            ,@i_service_type_id
            ,@i_service_type_desc
            ,@i_report_class
            ,@iColorCode
            ,@i_product_id
            ,@i_product_name
            ,@i_default_lob
            ,@i_copay_per
            ,@iDiscretionary
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Benefit_Class, @i_Benefit_Class_Desc, '', @status, @err_num, @err_msg

        FETCH NEXT FROM BenefitClasses_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_Key_Benefit_Class
             ,@i_class_gid
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
             ,@i_Benefit_Class
             ,@i_Benefit_Class_Desc
             ,@i_service_type_id
             ,@i_service_type_desc
             ,@i_report_class
             ,@iColorCode
             ,@i_product_id
             ,@i_product_name
             ,@i_default_lob
             ,@i_copay_per
             ,@iDiscretionary
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BenefitClasses_Cursor
DEALLOCATE BenefitClasses_Cursor

END
GO