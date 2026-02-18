IF OBJECT_ID('dbo.spDCAuto_CreateNetworkGroupsNetworks') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateNetworkGroupsNetworks AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateNetworkGroupsNetworks
Purpose:    Create networkgroupsnetworks data from CorderAutomation

Screen:     138
Method:     NetworkGroupsNetworks
Procedure:  dbo.prBenefitEntityNetworkVarAddModify
Entity:     Network_groups_var

Date        User            Change
---------------------------------------------------------------------------------------------
09/20/2021	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateNetworkGroupsNetworks '100-Config%', 22, 'NetworkGroupsNetworks'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateNetworkGroupsNetworks
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

DECLARE @i_entity_name          VARCHAR(50)
       ,@i_network_Gid          VARCHAR(75)
       ,@i_network_ID           VARCHAR(75)
       ,@i_network_Desc         VARCHAR(25)
       ,@i_old_effective_date   VARCHAR(20)
       ,@i_old_termination_date VARCHAR(20)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_Reference_Sid        VARCHAR(50)
       ,@i_action               VARCHAR(10)
       ,@i_date_time_modified   VARCHAR(30)
       ,@iUserid                VARCHAR(25)
       ,@i_new_id               VARCHAR(50)
       ,@i_Effective_date       VARCHAR(50)
       ,@i_Termination_date     VARCHAR(50)
       ,@o_status               INT
       ,@o_message              VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#NetworkGroupsNetworks') IS NOT NULL
	DROP TABLE #NetworkGroupsNetworks

CREATE TABLE #NetworkGroupsNetworks
      (SearchID               VARCHAR(200)
      ,i_entity_name          VARCHAR(50)       DEFAULT('Network_groups_var')
      ,i_network_Gid          VARCHAR(75)       DEFAULT('0')
      ,i_network_ID           VARCHAR(75)       DEFAULT('0')
      ,i_network_Desc         VARCHAR(25)       DEFAULT('0')
      ,i_old_effective_date   VARCHAR(20)       DEFAULT('0')
      ,i_old_termination_date VARCHAR(20)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_Reference_Sid        VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(10)       DEFAULT('ADD')
      ,i_date_time_modified   VARCHAR(30)       DEFAULT('')
      ,iUserid                VARCHAR(25)       DEFAULT('')
      ,i_new_id               VARCHAR(50)
      ,i_Effective_date       VARCHAR(50)
      ,i_Termination_date     VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #NetworkGroupsNetworks
          (SearchID
          ,i_new_id
          ,i_Effective_date
          ,i_Termination_date
          ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*NetworkVariation]), 'I')
          ,ISNULL([*EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*TerminationDate], '12/31/9999')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_NetworkGroupsNetworks
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #NetworkGroupsNetworks
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
DECLARE NetworkGroupsNetworks_Cursor CURSOR FOR
 SELECT SearchID
       ,i_entity_name
       ,i_network_Gid
       ,i_network_ID
       ,i_network_Desc
       ,i_old_effective_date
       ,i_old_termination_date
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_Reference_Sid
       ,i_action
       ,i_date_time_modified
       ,iUserid
       ,i_new_id
       ,i_Effective_date
       ,i_Termination_date
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #NetworkGroupsNetworks

   OPEN NetworkGroupsNetworks_Cursor
  FETCH NEXT FROM NetworkGroupsNetworks_Cursor
   INTO @SearchID
       ,@i_entity_name
       ,@i_network_Gid
       ,@i_network_ID
       ,@i_network_Desc
       ,@i_old_effective_date
       ,@i_old_termination_date
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_Reference_Sid
       ,@i_action
       ,@i_date_time_modified
       ,@iUserid
       ,@i_new_id
       ,@i_Effective_date
       ,@i_Termination_date
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

			SELECT @i_network_Gid			= entity_gid
			  FROM Entity_Names
			 WHERE record_status			= 'A'
			   AND entity_identifier		= 'Network Groups'
			   AND entity_user_id			= @SearchID

			EXEC dbo.prBenefitEntityNetworkVarAddModify
                 @i_entity_name
                ,@i_network_Gid
                ,@i_network_ID
                ,@i_network_Desc
                ,@i_old_effective_date
                ,@i_old_termination_date
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_Reference_Sid
                ,@i_action
                ,@i_date_time_modified
                ,@iUserid
                ,@i_new_id
                ,@i_Effective_date
                ,@i_Termination_date
                ,@o_status     = @err_num OUTPUT
                ,@o_message    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @SearchID, @i_new_id, @i_Effective_date, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM NetworkGroupsNetworks_Cursor
         INTO @SearchID
             ,@i_entity_name
             ,@i_network_Gid
             ,@i_network_ID
             ,@i_network_Desc
             ,@i_old_effective_date
             ,@i_old_termination_date
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_Reference_Sid
             ,@i_action
             ,@i_date_time_modified
             ,@iUserid
             ,@i_new_id
             ,@i_Effective_date
             ,@i_Termination_date
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE NetworkGroupsNetworks_Cursor
DEALLOCATE NetworkGroupsNetworks_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#NetworkGroupsNetworks') IS NOT NULL
	DROP TABLE #NetworkGroupsNetworks

END
GO

