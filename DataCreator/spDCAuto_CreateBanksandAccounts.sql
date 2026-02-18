IF OBJECT_ID('dbo.spDCAuto_CreateBanksandAccounts') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateBanksandAccounts AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateBanksandAccounts
Purpose:    Create banksandaccounts data from CorderAutomation
Method:     BanksandAccounts
Screen GID: 87
Procedure:  dbo.prBank_Table_Add_Modify

Date        User            Change
---------------------------------------------------------------------------------------------
10/28/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateBanksandAccounts '100-Config%', 22, 'BanksandAccounts'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateBanksandAccounts
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

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @i_Entity_name          VARCHAR(20)
       ,@i_Bank_Gid             VARCHAR(100)
       ,@i_contact_relation_gid VARCHAR(20)
       ,@i_key_3_field          VARCHAR(50)
       ,@i_key_4_field          VARCHAR(50)
       ,@i_key_5_field          VARCHAR(50)
       ,@i_key_6_field          VARCHAR(50)
       ,@i_key_7_field          VARCHAR(50)
       ,@i_key_8_field          VARCHAR(50)
       ,@i_key_9_field          VARCHAR(50)
       ,@i_key_10_field         VARCHAR(50)
       ,@i_action               VARCHAR(50)
       ,@l_modified_date        VARCHAR(100)
       ,@iUserID                VARCHAR(50)
       ,@l_ABA_Number           VARCHAR(20)
       ,@l_Bank_Desc            VARCHAR(80)
       ,@l_Bank_Number          VARCHAR(50)
       ,@i_ImmDest              VARCHAR(10)
       ,@i_ImmDestName          VARCHAR(100)
       ,@i_ImmOrig              VARCHAR(50)
       ,@i_ImmOrigName          VARCHAR(50)
       ,@i_FileHeader           VARCHAR(200)
       ,@i_FileName             VARCHAR(20)
       ,@i_serverAddy           VARCHAR(20)
       ,@i_serverType           VARCHAR(6)
       ,@i_serverUser           VARCHAR(50)
       ,@i_serverGPG            VARCHAR(1)
       ,@i_serverPass1          VARCHAR(50)
       ,@i_serverPass2          VARCHAR(50)
       ,@o_status               INT
       ,@o_message              VARCHAR(255)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#BanksandAccounts') IS NOT NULL
	DROP TABLE #BanksandAccounts

CREATE TABLE #BanksandAccounts
      (i_Entity_name          VARCHAR(20)       DEFAULT('Bank_Table')
      ,i_Bank_Gid             VARCHAR(100)      DEFAULT('0')
      ,i_contact_relation_gid VARCHAR(20)       DEFAULT('0')
      ,i_key_3_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_4_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_5_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_6_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_7_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_8_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_9_field          VARCHAR(50)       DEFAULT('0')
      ,i_key_10_field         VARCHAR(50)       DEFAULT('0')
      ,i_action               VARCHAR(50)       DEFAULT('ADD')
      ,l_modified_date        VARCHAR(100)      DEFAULT('')
      ,iUserID                VARCHAR(50)       DEFAULT('')
      ,l_ABA_Number           VARCHAR(20)
      ,l_Bank_Desc            VARCHAR(80)
      ,l_Bank_Number          VARCHAR(50)
      ,i_ImmDest              VARCHAR(10)
      ,i_ImmDestName          VARCHAR(100)
      ,i_ImmOrig              VARCHAR(50)
      ,i_ImmOrigName          VARCHAR(50)
      ,i_FileHeader           VARCHAR(200)
      ,i_FileName             VARCHAR(20)
      ,i_serverAddy           VARCHAR(20)
      ,i_serverType           VARCHAR(50)
      ,i_serverUser           VARCHAR(50)
      ,i_serverGPG            VARCHAR(50)
      ,i_serverPass1          VARCHAR(50)
      ,i_serverPass2          VARCHAR(50)
      ,o_status               INT
      ,o_message              VARCHAR(255)
      ,record_id              INT
      ,static_gid             INT)

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #BanksandAccounts
      (l_ABA_Number
      ,l_Bank_Desc
      ,l_Bank_Number
	  ,i_ImmDest
      ,i_ImmDestName
      ,i_ImmOrig
      ,i_ImmOrigName
      ,i_FileHeader
      ,i_FileName
      ,i_serverAddy
	  ,i_serverType
      ,i_serverUser
      ,i_serverGPG
      ,i_serverPass1
      ,i_serverPass2
      ,record_id
      ,static_gid)
SELECT ISNULL([*ABANumber], '')
      ,ISNULL([*FinancialInstitution], '')
      ,ISNULL([BankNumber], '')
      ,ISNULL([ImmediateDestNumber], '')
      ,ISNULL([ImmediateDestName], '')
      ,ISNULL([ImmediateOriginNumber], '')
      ,ISNULL([ImmediateOriginName], '')
      ,ISNULL([FileHeader], '')
      ,ISNULL([FileName], '')
      ,ISNULL([ServerLocation], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServerType]), '')
      ,ISNULL([ServerUser], '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ServerPGP]), 'N')
      ,ISNULL([Password], '')
      ,ISNULL([ConfirmPassword], '')
      ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_BankAndAccounts
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #BanksandAccounts
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE BanksandAccounts_Cursor CURSOR FOR
 SELECT i_Entity_name
       ,i_Bank_Gid
       ,i_contact_relation_gid
       ,i_key_3_field
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,l_modified_date
       ,iUserID
       ,l_ABA_Number
       ,l_Bank_Desc
       ,l_Bank_Number
       ,i_ImmDest
       ,i_ImmDestName
       ,i_ImmOrig
       ,i_ImmOrigName
       ,i_FileHeader
       ,i_FileName
       ,i_serverAddy
       ,i_serverType
       ,i_serverUser
       ,i_serverGPG
       ,i_serverPass1
       ,i_serverPass2
       ,o_status
       ,o_message
       ,record_id
       ,static_gid
   FROM #BanksandAccounts

   OPEN BanksandAccounts_Cursor
  FETCH NEXT FROM BanksandAccounts_Cursor
   INTO @i_Entity_name
       ,@i_Bank_Gid
       ,@i_contact_relation_gid
       ,@i_key_3_field
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@l_modified_date
       ,@iUserID
       ,@l_ABA_Number
       ,@l_Bank_Desc
       ,@l_Bank_Number
       ,@i_ImmDest
       ,@i_ImmDestName
       ,@i_ImmOrig
       ,@i_ImmOrigName
       ,@i_FileHeader
       ,@i_FileName
       ,@i_serverAddy
       ,@i_serverType
       ,@i_serverUser
       ,@i_serverGPG
       ,@i_serverPass1
       ,@i_serverPass2
       ,@o_status
       ,@o_message
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		EXEC dbo.prBank_Table_Add_Modify
             @i_Entity_name
            ,@i_Bank_Gid
            ,@i_contact_relation_gid
            ,@i_key_3_field
            ,@i_key_4_field
            ,@i_key_5_field
            ,@i_key_6_field
            ,@i_key_7_field
            ,@i_key_8_field
            ,@i_key_9_field
            ,@i_key_10_field
            ,@i_action
            ,@l_modified_date
            ,@iUserID
            ,@l_ABA_Number
            ,@l_Bank_Desc
            ,@l_Bank_Number
            ,@i_ImmDest
            ,@i_ImmDestName
            ,@i_ImmOrig
            ,@i_ImmOrigName
            ,@i_FileHeader
            ,@i_FileName
            ,@i_serverAddy
            ,@i_serverType
            ,@i_serverUser
            ,@i_serverGPG
            ,@i_serverPass1
            ,@i_serverPass2
            ,@o_status     = @err_num OUTPUT
            ,@o_message    = @err_msg OUTPUT

       -- Update the GIDs
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Update to the static gid
				UPDATE dbo.Banks 
				   SET bank_gid				= @static_gid 
				 WHERE record_status		= 'A'
				   AND aba_number			= @l_ABA_Number

			END

		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @l_ABA_Number, @l_Bank_Desc, @l_Bank_Number, @status, @err_num, @err_msg

        FETCH NEXT FROM BanksandAccounts_Cursor
         INTO @i_Entity_name
             ,@i_Bank_Gid
             ,@i_contact_relation_gid
             ,@i_key_3_field
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@l_modified_date
             ,@iUserID
             ,@l_ABA_Number
             ,@l_Bank_Desc
             ,@l_Bank_Number
             ,@i_ImmDest
             ,@i_ImmDestName
             ,@i_ImmOrig
             ,@i_ImmOrigName
             ,@i_FileHeader
             ,@i_FileName
             ,@i_serverAddy
             ,@i_serverType
             ,@i_serverUser
             ,@i_serverGPG
             ,@i_serverPass1
             ,@i_serverPass2
             ,@o_status
             ,@o_message
             ,@record_id
             ,@static_gid
	END

CLOSE BanksandAccounts_Cursor
DEALLOCATE BanksandAccounts_Cursor

END
GO