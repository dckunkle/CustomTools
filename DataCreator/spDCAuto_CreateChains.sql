IF OBJECT_ID('dbo.spDCAuto_CreateChains') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateChains AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateChains
Purpose:    Create chains data from CorderAutomation
Method:     Chains
Screen GID: 3303
Procedure:  dbo.prChainsAddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/14/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateChains '100-Config%', 22, 'Chains'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateChains
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

DECLARE @iEntity              VARCHAR(50)
       ,@i_chain_gid          VARCHAR(50)
       ,@i_location_gid       VARCHAR(50)
       ,@i_orig_chain_code    VARCHAR(50)
       ,@iKeyField4           VARCHAR(50)
       ,@iKeyField5           VARCHAR(50)
       ,@iKeyField6           VARCHAR(50)
       ,@iKeyField7           VARCHAR(50)
       ,@iKeyField8           VARCHAR(50)
       ,@iKeyField9           VARCHAR(50)
       ,@iKeyField10          VARCHAR(50)
       ,@iAction              VARCHAR(10)
       ,@iDateModified        VARCHAR(50)
       ,@iUserID              VARCHAR(25)
       ,@iChain_Code          VARCHAR(50)
       ,@iChain_Name          VARCHAR(255)
       ,@i_CH_Location_ID     VARCHAR(50)
       ,@i_CH_Location_name   VARCHAR(100)
       ,@i_CH_Address1        VARCHAR(55)
       ,@i_CH_Address2        VARCHAR(55)
       ,@i_CH_Zip             VARCHAR(50)
       ,@i_CH_City            VARCHAR(50)
       ,@i_CH_State           VARCHAR(50)
       ,@i_CH_County          VARCHAR(50)
       ,@i_CH_Country         VARCHAR(50)
       ,@i_CHMA_location_ID   VARCHAR(50)
       ,@i_CHMA_Location_name VARCHAR(100)
       ,@i_CHMA_Address_1     VARCHAR(55)
       ,@i_CHMA_Address_2     VARCHAR(55)
       ,@i_CHMA_Zip           VARCHAR(50)
       ,@i_CHMA_City          VARCHAR(50)
       ,@i_CHMA_State         VARCHAR(50)
       ,@i_CHMA_County        VARCHAR(50)
       ,@i_CHMA_Country       VARCHAR(50)
       ,@iContact_Title       VARCHAR(50)
       ,@iEmail               VARCHAR(50)
       ,@iPhone               VARCHAR(50)
       ,@iFax                 VARCHAR(50)
       ,@oStatus              INT
       ,@oMessage             VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#Chains') IS NOT NULL
	DROP TABLE #Chains

CREATE TABLE #Chains
      (SearchID             VARCHAR(200)
      ,iEntity              VARCHAR(50)       DEFAULT('Chains')
      ,i_chain_gid          VARCHAR(50)       DEFAULT('0')
      ,i_location_gid       VARCHAR(50)       DEFAULT('0')
      ,i_orig_chain_code    VARCHAR(50)       DEFAULT('0')
      ,iKeyField4           VARCHAR(50)       DEFAULT('0')
      ,iKeyField5           VARCHAR(50)       DEFAULT('0')
      ,iKeyField6           VARCHAR(50)       DEFAULT('0')
      ,iKeyField7           VARCHAR(50)       DEFAULT('0')
      ,iKeyField8           VARCHAR(50)       DEFAULT('0')
      ,iKeyField9           VARCHAR(50)       DEFAULT('0')
      ,iKeyField10          VARCHAR(50)       DEFAULT('0')
      ,iAction              VARCHAR(10)       DEFAULT('ADD')
      ,iDateModified        VARCHAR(50)       DEFAULT('')
      ,iUserID              VARCHAR(25)       DEFAULT('')
      ,iChain_Code          VARCHAR(50)
      ,iChain_Name          VARCHAR(255)
      ,i_CH_Location_ID     VARCHAR(50)
      ,i_CH_Location_name   VARCHAR(100)
      ,i_CH_Address1        VARCHAR(55)
      ,i_CH_Address2        VARCHAR(55)
      ,i_CH_Zip             VARCHAR(50)
      ,i_CH_City            VARCHAR(50)
      ,i_CH_State           VARCHAR(50)
      ,i_CH_County          VARCHAR(50)
      ,i_CH_Country         VARCHAR(50)
      ,i_CHMA_location_ID   VARCHAR(50)
      ,i_CHMA_Location_name VARCHAR(100)
      ,i_CHMA_Address_1     VARCHAR(55)
      ,i_CHMA_Address_2     VARCHAR(55)
      ,i_CHMA_Zip           VARCHAR(50)
      ,i_CHMA_City          VARCHAR(50)
      ,i_CHMA_State         VARCHAR(50)
      ,i_CHMA_County        VARCHAR(50)
      ,i_CHMA_Country       VARCHAR(50)
      ,iContact_Title       VARCHAR(50)
      ,iEmail               VARCHAR(50)
      ,iPhone               VARCHAR(50)
      ,iFax                 VARCHAR(50)
      ,oStatus              INT
      ,oMessage             VARCHAR(250)
      ,record_id            INT
      ,static_gid           INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #Chains
      (SearchID
      ,iChain_Code
      ,iChain_Name
      ,i_CH_Location_ID
      ,i_CHMA_location_ID
      ,iContact_Title
      ,iEmail
      ,iPhone
      ,iFax
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL([*ChainCode], '')
      ,ISNULL([*ChainName], '')
      ,ISNULL([*LocationID], '')
      ,ISNULL([LocationID], '')
      ,ISNULL([ContactTitle], '')
      ,ISNULL([Email], '')
      ,ISNULL([Phone], '0000000000')
      ,ISNULL([Fax], '0000000000')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_Chains
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #Chains
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE Chains_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity
       ,i_chain_gid
       ,i_location_gid
       ,i_orig_chain_code
       ,iKeyField4
       ,iKeyField5
       ,iKeyField6
       ,iKeyField7
       ,iKeyField8
       ,iKeyField9
       ,iKeyField10
       ,iAction
       ,iDateModified
       ,iUserID
       ,iChain_Code
       ,iChain_Name
       ,i_CH_Location_ID
       ,i_CH_Location_name
       ,i_CH_Address1
       ,i_CH_Address2
       ,i_CH_Zip
       ,i_CH_City
       ,i_CH_State
       ,i_CH_County
       ,i_CH_Country
       ,i_CHMA_location_ID
       ,i_CHMA_Location_name
       ,i_CHMA_Address_1
       ,i_CHMA_Address_2
       ,i_CHMA_Zip
       ,i_CHMA_City
       ,i_CHMA_State
       ,i_CHMA_County
       ,i_CHMA_Country
       ,iContact_Title
       ,iEmail
       ,iPhone
       ,iFax
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #Chains

   OPEN Chains_Cursor
  FETCH NEXT FROM Chains_Cursor
   INTO @SearchID
       ,@iEntity
       ,@i_chain_gid
       ,@i_location_gid
       ,@i_orig_chain_code
       ,@iKeyField4
       ,@iKeyField5
       ,@iKeyField6
       ,@iKeyField7
       ,@iKeyField8
       ,@iKeyField9
       ,@iKeyField10
       ,@iAction
       ,@iDateModified
       ,@iUserID
       ,@iChain_Code
       ,@iChain_Name
       ,@i_CH_Location_ID
       ,@i_CH_Location_name
       ,@i_CH_Address1
       ,@i_CH_Address2
       ,@i_CH_Zip
       ,@i_CH_City
       ,@i_CH_State
       ,@i_CH_County
       ,@i_CH_Country
       ,@i_CHMA_location_ID
       ,@i_CHMA_Location_name
       ,@i_CHMA_Address_1
       ,@i_CHMA_Address_2
       ,@i_CHMA_Zip
       ,@i_CHMA_City
       ,@i_CHMA_State
       ,@i_CHMA_County
       ,@i_CHMA_Country
       ,@iContact_Title
       ,@iEmail
       ,@iPhone
       ,@iFax
       ,@oStatus
       ,@oMessage
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			EXEC dbo.prChainsAddModify
             @iEntity
            ,@i_chain_gid
            ,@i_location_gid
            ,@i_orig_chain_code
            ,@iKeyField4
            ,@iKeyField5
            ,@iKeyField6
            ,@iKeyField7
            ,@iKeyField8
            ,@iKeyField9
            ,@iKeyField10
            ,@iAction
            ,@iDateModified
            ,@iUserID
            ,@iChain_Code
            ,@iChain_Name
            ,@i_CH_Location_ID
            ,@i_CH_Location_name
            ,@i_CH_Address1
            ,@i_CH_Address2
            ,@i_CH_Zip
            ,@i_CH_City
            ,@i_CH_State
            ,@i_CH_County
            ,@i_CH_Country
            ,@i_CHMA_location_ID
            ,@i_CHMA_Location_name
            ,@i_CHMA_Address_1
            ,@i_CHMA_Address_2
            ,@i_CHMA_Zip
            ,@i_CHMA_City
            ,@i_CHMA_State
            ,@i_CHMA_County
            ,@i_CHMA_Country
            ,@iContact_Title
            ,@iEmail
            ,@iPhone
            ,@iFax
            ,@oStatus     = @err_num OUTPUT
            ,@oMessage    = @err_msg OUTPUT

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH

        -- Update the GIDs
		IF ISNULL(@static_gid, 0) != 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Chains 
				   SET chain_gid				= @static_gid 
				 WHERE record_status			= 'A'
				   AND chain_code				= @iChain_Code

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iChain_Code, @iChain_Name, '', @status, @err_num, @err_msg

        FETCH NEXT FROM Chains_Cursor
         INTO @SearchID
             ,@iEntity
             ,@i_chain_gid
             ,@i_location_gid
             ,@i_orig_chain_code
             ,@iKeyField4
             ,@iKeyField5
             ,@iKeyField6
             ,@iKeyField7
             ,@iKeyField8
             ,@iKeyField9
             ,@iKeyField10
             ,@iAction
             ,@iDateModified
             ,@iUserID
             ,@iChain_Code
             ,@iChain_Name
             ,@i_CH_Location_ID
             ,@i_CH_Location_name
             ,@i_CH_Address1
             ,@i_CH_Address2
             ,@i_CH_Zip
             ,@i_CH_City
             ,@i_CH_State
             ,@i_CH_County
             ,@i_CH_Country
             ,@i_CHMA_location_ID
             ,@i_CHMA_Location_name
             ,@i_CHMA_Address_1
             ,@i_CHMA_Address_2
             ,@i_CHMA_Zip
             ,@i_CHMA_City
             ,@i_CHMA_State
             ,@i_CHMA_County
             ,@i_CHMA_Country
             ,@iContact_Title
             ,@iEmail
             ,@iPhone
             ,@iFax
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE Chains_Cursor
DEALLOCATE Chains_Cursor

END
GO