IF OBJECT_ID('dbo.spDCAuto_CreateProductOffering') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateProductOffering AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateProductOffering
Purpose:    Create productoffering data from CorderAutomation

Screen:     7777
Method:     ProductOffering
Procedure:  dbo.prProductOffering_AddModify
Entity:     PRODUCT_OFFERING

Date        User            Change
---------------------------------------------------------------------------------------------
03/24/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateProductOffering '100-Config%', 22, 'ProductOffering'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateProductOffering
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
       ,@i_ProdOfferingGid    VARCHAR(50)
       ,@i_key_SysLOB         VARCHAR(20)
       ,@i_key_3_field        VARCHAR(20)
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
       ,@i_ProdOfferingID     VARCHAR(50)
       ,@i_ProdOfferingDesc   VARCHAR(50)
       ,@i_Effective_Date     VARCHAR(50)
       ,@i_Termination_Date   VARCHAR(50)
       ,@i_System_LOB         VARCHAR(50)
       ,@i_Census_Category    VARCHAR(50)
       ,@i_NPP_Parm_ID        VARCHAR(50)
       ,@i_NPP_Parm_Desc      VARCHAR(100)
       ,@o_status             INT
       ,@o_message            VARCHAR(100)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ProductOffering') IS NOT NULL
	DROP TABLE #ProductOffering

CREATE TABLE #ProductOffering
      (SearchID             VARCHAR(200)
      ,i_entity_name        VARCHAR(50)       DEFAULT('PRODUCT_OFFERING')
      ,i_ProdOfferingGid    VARCHAR(50)       DEFAULT('0')
      ,i_key_SysLOB         VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field        VARCHAR(20)       DEFAULT('0')
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
      ,i_ProdOfferingID     VARCHAR(50)
      ,i_ProdOfferingDesc   VARCHAR(50)
      ,i_Effective_Date     VARCHAR(50)
      ,i_Termination_Date   VARCHAR(50)
      ,i_System_LOB         VARCHAR(50)
      ,i_Census_Category    VARCHAR(50)
      ,i_NPP_Parm_ID        VARCHAR(50)
      ,i_NPP_Parm_Desc      VARCHAR(100)
      ,o_status             INT
      ,o_message            VARCHAR(100)
      ,record_id            INT
      ,static_gid           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #ProductOffering
          (SearchID
          ,i_ProdOfferingID
          ,i_ProdOfferingDesc
          ,i_Effective_Date
          ,i_Termination_Date
          ,i_System_LOB
          ,i_Census_Category
          ,i_NPP_Parm_ID
          ,record_id
          ,static_gid)
    SELECT SearchID
		  ,ISNULL([*ProductOfferingID], '')
          ,ISNULL([*ProductOfferingDesc], '')
          ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*SystemLOB]), '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([CensusCategory]), '******')
          ,ISNULL([NPPParameterID], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL(gid, 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_ProductOffering
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #ProductOffering
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
DECLARE ProductOffering_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_ProdOfferingGid
       ,i_key_SysLOB
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
       ,i_ProdOfferingID
       ,i_ProdOfferingDesc
       ,i_Effective_Date
       ,i_Termination_Date
       ,i_System_LOB
       ,i_Census_Category
       ,i_NPP_Parm_ID
       ,i_NPP_Parm_Desc
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #ProductOffering

   OPEN ProductOffering_Cursor
  FETCH NEXT FROM ProductOffering_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_ProdOfferingGid
       ,@i_key_SysLOB
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
       ,@i_ProdOfferingID
       ,@i_ProdOfferingDesc
       ,@i_Effective_Date
       ,@i_Termination_Date
       ,@i_System_LOB
       ,@i_Census_Category
       ,@i_NPP_Parm_ID
       ,@i_NPP_Parm_Desc
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

			EXEC dbo.prProductOffering_AddModify
                 @i_entity_name
                ,@i_ProdOfferingGid
                ,@i_key_SysLOB
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
                ,@i_ProdOfferingID
                ,@i_ProdOfferingDesc
                ,@i_Effective_Date
                ,@i_Termination_Date
                ,@i_System_LOB
                ,@i_Census_Category
                ,@i_NPP_Parm_ID
                ,@i_NPP_Parm_Desc
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE Product_Offering 
				   SET product_offering_gid		= @static_gid 
				 WHERE record_status			= 'A'
				   AND product_offering_id		= @i_ProdOfferingID

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_ProdOfferingID, @i_ProdOfferingDesc, '', @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM ProductOffering_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_ProdOfferingGid
             ,@i_key_SysLOB
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
             ,@i_ProdOfferingID
             ,@i_ProdOfferingDesc
             ,@i_Effective_Date
             ,@i_Termination_Date
             ,@i_System_LOB
             ,@i_Census_Category
             ,@i_NPP_Parm_ID
             ,@i_NPP_Parm_Desc
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE ProductOffering_Cursor
DEALLOCATE ProductOffering_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#ProductOffering') IS NOT NULL
	DROP TABLE #ProductOffering

END
GO

