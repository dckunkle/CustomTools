IF OBJECT_ID('dbo.spDCAuto_LoadDataTables') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_LoadDataTables AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_LoadDataTables
Purpose:    POC to see if data from Core can easily be loaded into CoreAutomation tables

Date        User            Change
---------------------------------------------------------------------------------------------
11/08/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_LoadDataTables 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_LoadDataTables
     (@suppress_defaults	BIT		= 1)
AS
BEGIN

DECLARE @screen_gid			INT
       ,@entity_name		VARCHAR(200)
	   ,@td_table_name		VARCHAR(200)
	   ,@core_table_name	VARCHAR(200)
	   ,@key_field_1		VARCHAR(200)
	   ,@key_field_2		VARCHAR(200)
	   ,@key_field_3		VARCHAR(200)

--*************************************************************************************************
-- Create table of values to be loaded
--*************************************************************************************************
SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#TablesToLoad') IS NOT NULL
	DROP TABLE #TableToLoad

CREATE TABLE #TablesToLoad
      (screen_gid		INT
	  ,entity_name		VARCHAR(200)
	  ,td_table_name	VARCHAR(200)
	  ,core_table_name	VARCHAR(200)
	  ,key_field_1		VARCHAR(200)
	  ,key_field_2		VARCHAR(200)
	  ,key_field_3		VARCHAR(200))

INSERT INTO #TablesToLoad (screen_gid, entity_name,        td_table_name,       core_table_name,   key_field_1,     key_field_2, key_field_3)
                   VALUES (3002,       'Benefit_Classes', 'TD_BenefitClasses', 'Benefit_Classes', 'benefit_class', 'class_gid',''),
				          (3030,       'Custom_LOB',      'TD_CustomLob',      'LOB_Options',     'group_id',      'user_lob',''),
						  (3021,       'Coverage_Codes',  'TD_CoverageCodes',  'Coverage_Codes',  'coverage_code', '',''),
						  (77,         'Calendar',        'TD_Calendar',       'Calendar',        'calendar_gid','',''),
						  (813,        'Financial_Codes', 'TD_FinancialCodes', 'Financial_Codes', 'Code_ID','',''),
						  (156,        'Processing_Policies', 'TD_RemarkCodes', 'Processing_Policy_Master', 'Policy_Number','effective_date', 'termination_date'),
						  (514,        'Security_Role',    'TD_SecurityRoleAdmin','Security_Roles','Role_ID','Role_GID','')
						  --(3104,       'Product_nName_List','TD_CodeLists', 'Entity_Names','

--*************************************************************************************************
-- Start loading data into the tables
--*************************************************************************************************
DECLARE Tables_Cursor CURSOR FOR
 SELECT screen_gid
       ,entity_name
	   ,td_table_name
	   ,core_table_name
	   ,key_field_1
	   ,key_field_2
	   ,key_field_3
   FROM #TablesToLoad

   OPEN Tables_Cursor
  FETCH NEXT FROM Tables_Cursor
   INTO @screen_gid
       ,@entity_name
       ,@td_table_name
	   ,@core_table_name
	   ,@key_field_1
	   ,@key_field_2
	   ,@key_field_3

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC spDCAuto_LoadData @screen_gid, @entity_name, @td_table_name, @core_table_name, @key_field_1, @key_field_2, @key_field_3, @suppress_defaults

		FETCH NEXT FROM Tables_Cursor
		 INTO @screen_gid
		     ,@entity_name
			 ,@td_table_name
			 ,@core_table_name
			 ,@key_field_1
			 ,@key_field_2
			 ,@key_field_3

	END

CLOSE Tables_Cursor
DEALLOCATE Tables_Cursor
END
GO