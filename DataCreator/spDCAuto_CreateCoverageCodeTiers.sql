IF OBJECT_ID('dbo.spDCAuto_CreateCoverageCodeTiers') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateCoverageCodeTiers AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateCoverageCodeTiers
Purpose:    Create coverage code tiers from CorderAutomation

Date        User            Change
---------------------------------------------------------------------------------------------
10/18/2019	DK				Original procedure
01/15/2020	DK				Add delay to avoid Primary Key issues in Entity_Names

---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateCoverageCodeTiers 
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateCoverageCodeTiers
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

	   ,@tier_gid					INT

DECLARE	@iFunction					VARCHAR(10)
       ,@iEntityGID					VARCHAR(50)
       ,@iEntityID					VARCHAR(50)
       ,@iAction					VARCHAR(10)
       ,@i_date_time_modified		VARCHAR(50)
       ,@iUserID					VARCHAR(25)
       ,@date_time_modified			VARCHAR(50)
       ,@i_entity_user_id			VARCHAR(25)
       ,@i_entity_user_name			VARCHAR(150)
       ,@iDataXML					VARCHAR(MAX)


SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#CoverageCodeTiers') IS NOT NULL
	DROP TABLE #CoverageCodeTiers

CREATE TABLE #CoverageCodeTiers
      (iFunction				VARCHAR(10)		DEFAULT('COV')
      ,iEntityGID				VARCHAR(50)		DEFAULT('')
      ,iEntityID				VARCHAR(50)		DEFAULT('')
      ,iAction					VARCHAR(10)		DEFAULT('ADD')
      ,i_date_time_modified		VARCHAR(50)		DEFAULT('')
      ,iUserID					VARCHAR(25)		DEFAULT('')
      ,date_time_modified		VARCHAR(50)		DEFAULT('')
      ,i_entity_user_id			VARCHAR(25)
      ,i_entity_user_name		VARCHAR(150)
      ,iDataXML					VARCHAR(MAX)
	  ,record_id				INT
	  ,gid						INT)

--*************************************************************************************************
-- Populate the table with data to be created
--*************************************************************************************************
INSERT INTO #CoverageCodeTiers
      (i_entity_user_id			
      ,i_entity_user_name		
      ,iDataXML	
	  ,record_id
	  ,gid)
SELECT ISNULL([*ID], '')
	  ,ISNULL([*Description], '')
	  ,dbo.fnDCAuto_GetCoverageCodeXML(CCToInclude)
	  ,RecordID
	  ,gid
  FROM COREAUTO.CoreAutomation.dbo.TD_CoverageCodesTiers
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #CoverageCodeTiers
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Coverage_Code_Tiers_Cursor CURSOR FOR
 SELECT iFunction				
       ,iEntityGID				
       ,iEntityID				
       ,iAction					
       ,i_date_time_modified		
       ,iUserID					
       ,date_time_modified		
       ,i_entity_user_id			
       ,i_entity_user_name		
       ,iDataXML					
	   ,record_id
	   ,gid
   FROM #CoverageCodeTiers


   OPEN Coverage_Code_Tiers_Cursor
  FETCH NEXT FROM Coverage_Code_Tiers_Cursor
   INTO @iFunction				
       ,@iEntityGID				
       ,@iEntityID				
       ,@iAction				
       ,@i_date_time_modified	
       ,@iUserID				
       ,@date_time_modified		
       ,@i_entity_user_id		
       ,@i_entity_user_name		
       ,@iDataXML				
	   ,@record_id
	   ,@gid

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF LEFT(@iDataXML,6) <> '<DATA>'
			BEGIN
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @i_method, @record_id, @i_entity_user_id, @i_entity_user_name, '', 'Error', 100, @iDataXML
			END
		ELSE
			BEGIN

				EXEC prGridScreenAddModify  
					 @iFunction				
					,@iEntityGID				
					,@iEntityID				
					,@iAction				
					,@i_date_time_modified	
					,@iUserID				
					,@date_time_modified		
					,@i_entity_user_id		
					,@i_entity_user_name		
					,@iDataXML	
					,@o_status = 0				--= @err_num	OUTPUT
					,@o_message = ''				--= @err_msg	OUTPUT

				-- Update the GIDs
				IF @gid IS NOT NULL
					BEGIN

						SELECT @tier_gid			= ISNULL(entity_gid, 0)
						  FROM Entity_Names
						 WHERE entity_identifier	= 'COVERAGE_CODE_TIERS'
						   AND entity_user_id		= @i_entity_user_id
						   AND record_status		= 'A'

						UPDATE Entity_Names SET entity_gid = @gid 
						 WHERE entity_identifier = 'COVERAGE_CODE_TIERS'
						   AND entity_user_id		= @i_entity_user_id
						   AND record_status		= 'A'

						UPDATE Coverage_Tiers
						   SET Coverage_Tiers_gid	= @gid
						 WHERE Coverage_Tiers_gid	= @tier_gid
						   AND record_status		= 'A'

					END
				
				-- Log the details
				SELECT @status = CASE WHEN @err_num <> 0 THEN 'Error' ELSE 'Add' END
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @i_method, @record_id, @i_entity_user_id, @i_entity_user_name, '', @status, 0, 'Record Added Successfully.'

				WAITFOR DELAY '00:00:00.100';

			END

		FETCH NEXT FROM Coverage_Code_Tiers_Cursor
		    INTO @iFunction				
			    ,@iEntityGID				
			    ,@iEntityID				
			    ,@iAction				
			    ,@i_date_time_modified	
			    ,@iUserID				
			    ,@date_time_modified		
			    ,@i_entity_user_id		
			    ,@i_entity_user_name		
			    ,@iDataXML				
			    ,@record_id
				,@gid
	END

CLOSE Coverage_Code_Tiers_Cursor
DEALLOCATE Coverage_Code_Tiers_Cursor

END
GO