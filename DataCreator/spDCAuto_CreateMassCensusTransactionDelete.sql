IF OBJECT_ID('dbo.spDCAuto_CreateMassCensusTransactionDelete') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateMassCensusTransactionDelete AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateMassCensusTransactionDelete
Purpose:    Create masscensustransactiondelete data from CorderAutomation
Method:     MassCensusTransactionDelete
Screen GID: 0
Procedure:  dbo.prMassCensusDelete

Date        User            Change
---------------------------------------------------------------------------------------------
01/08/2020	DK				Original procedure
01/14/2020  DK				Catch the error if no census records were found
08/18/2020	DK				Additional error trapping, also added Person_Code field to #CensusRecords
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateMassCensusTransactionDelete '100-Config%', 22, 'MassCensusTransactionDelete'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateMassCensusTransactionDelete
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
	   ,@user_gid					INT
	   ,@census_gid					INT
	   ,@SearchID					VARCHAR(200)

 SELECT @pattern					= @i_pattern
	   ,@log_id						= @i_log_id
	   ,@method						= @i_method
	   ,@test_case_name				= @i_test_case_name
	   ,@user						= @i_user

DECLARE @i_Member_ID				VARCHAR(18) 
       ,@i_MemberID_Starts			VARCHAR(100)
       ,@i_Group_ID					VARCHAR(50) 
	   ,@i_GroupID_Starts			VARCHAR(100)
       ,@i_DT_Range_Begin_Date		VARCHAR(11)  
       ,@i_DT_Range_End_Date		VARCHAR(11) 
       ,@i_Invoice_Number			VARCHAR(10) 
       ,@i_Show_Dep					VARCHAR(5)  
       ,@i_Census_Type				CHAR(1)     
       ,@i_user_gid					INT         
       ,@i_Report					CHAR(1)     
       ,@i_Batch					CHAR(1)     
       ,@o_status					INT
       ,@o_message					VARCHAR(250)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#MassCensusTransactionDelete') IS NOT NULL
	DROP TABLE #MassCensusTransactionDelete

CREATE TABLE #MassCensusTransactionDelete
      (SearchID					VARCHAR(200)
	  ,i_MemberID_Starts		VARCHAR(100)
	  ,i_Member_ID				VARCHAR(18)
	  ,i_GroupID_Starts			VARCHAR(100) 
      ,i_Group_ID				VARCHAR(50)   
      ,i_DT_Range_Begin_Date	VARCHAR(11)
      ,i_DT_Range_End_Date		VARCHAR(11)
      ,i_Invoice_Number			VARCHAR(10) 
      ,i_Show_Dep				VARCHAR(5)  
      ,i_Census_Type			CHAR(1)   
	  ,iUserID					VARCHAR(100)   
      ,i_user_gid				INT        
      ,i_Report					CHAR(1)    
      ,i_Batch					CHAR(1)    
      ,o_status					INT       
      ,o_message				VARCHAR(250)  
      ,record_id				INT
      ,static_gid				INT)

IF OBJECT_ID('tempdb.dbo.#CensusRecords') IS NOT NULL
	DROP TABLE #CensusRecords

CREATE TABLE #CensusRecords
      (Transaction_Count		INT
	  ,Member_Id				VARCHAR(1000)
	  ,Person_Code				VARCHAR(1000)
	  ,First_Name  				VARCHAR(1000)
	  ,Last_Name  				VARCHAR(1000)
	  ,Billing_Group_Name 		VARCHAR(1000)
	  ,Billing_Group_Id 		VARCHAR(1000) 
	  ,Elig_Group_Name 			VARCHAR(1000) 
	  ,Elig_Group_Id  			VARCHAR(1000)
	  ,Coverage_Start 			VARCHAR(1000) 
	  ,Coverage_End  			VARCHAR(1000)
	  ,Invoice_Nbr   			VARCHAR(1000)          
	  ,[Invoice Date Created] 	VARCHAR(1000)    
	  ,[Invoice Start]  		VARCHAR(1000)        
	  ,[Invoice Through] 		VARCHAR(1000)              
	  ,Custom_LOB  				VARCHAR(1000)
	  ,Plan_Strategy  			VARCHAR(1000)
	  ,Sum_Amount  				VARCHAR(1000)
	  ,Financial_Code  			VARCHAR(1000)
	  ,Census_Gid  				INT
	  ,Coverage_Code 			VARCHAR(1000))

IF OBJECT_ID('tempdb.dbo.#CensusError') IS NOT NULL
	DROP TABLE #CensusError

CREATE TABLE #CensusError
      (err_message VARCHAR(4000))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

	INSERT INTO #MassCensusTransactionDelete
		  (SearchID
		  ,i_MemberID_Starts
		  ,i_Member_ID	
		  ,i_GroupID_Starts			
		  ,i_Group_ID				 
		  ,i_DT_Range_BEGIN_Date	
		  ,i_DT_Range_END_Date			 
		  ,i_Show_Dep						   				   
		  ,record_id
		  ,static_gid)
	SELECT SearchID
		  ,ISNULL([MemberID_Starts], '')
		  ,ISNULL([MemberID_Text], '')
		  ,ISNULL([GroupID_Starts], '')
		  ,ISNULL([GroupID_Text], '')
		  ,ISNULL([CensusPeriodStartDt], '')
		  ,ISNULL([CensusPeriodEndDt], '')
		  ,ISNULL([ShowDependentInfo], '')
		  ,ISNULL([RecordID], '')
		  ,ISNULL([gid], '')
	  FROM COREAUTO.CoreAutomation.dbo.TD_MassCensusTransDelete
	 WHERE TCID				LIKE @pattern
	   AND ActiveTestCase	= 'A'

	--*************************************************************************************************
	-- Update the user
	--*************************************************************************************************
	UPDATE #MassCensusTransactionDelete
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
DECLARE MassCensusTransactionDelete_Cursor CURSOR FOR
 SELECT SearchID
       ,i_MemberID_Starts
       ,i_Member_ID
	   ,i_GroupID_Starts
	   ,i_Group_ID
	   ,i_DT_Range_BEGIN_Date
	   ,i_DT_Range_END_Date
	   ,i_Show_Dep
       ,record_id
       ,static_gid
   FROM #MassCensusTransactionDelete

   OPEN MassCensusTransactionDelete_Cursor
  FETCH NEXT FROM MassCensusTransactionDelete_Cursor
   INTO @SearchID
	   ,@i_MemberID_Starts
	   ,@i_Member_ID
	   ,@i_GroupID_Starts
	   ,@i_Group_ID
	   ,@i_DT_Range_BEGIN_Date
	   ,@i_DT_Range_END_Date
	   ,@i_Show_Dep
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY

			-- Get the census records that need to be deleted
			SELECT @i_Member_ID = CASE WHEN @i_MemberID_Starts	= 'Yes' THEN @i_Member_ID + '%' ELSE @i_Member_ID	END
			      ,@i_Group_ID  = CASE WHEN @i_GroupID_Starts	= 'Yes' THEN @i_Group_ID + '%'  ELSE @i_Group_ID	END
				  ,@i_Show_Dep  = CASE WHEN @i_Show_Dep			= 'Yes' THEN 'Y'				ELSE 'N'			END

			SELECT @user_gid = SU.User_GID FROM Security_Users SU WHERE SU.record_status = 'A' AND SU.user_id = @i_user

			-- Try calling the census stored procedure, if it fails call it a second time to get the error message
			BEGIN TRY

				TRUNCATE TABLE #CensusRecords
				  INSERT INTO #CensusRecords
				    EXEC prBAR04_CensusTransactionRpt @i_Member_ID,@i_Group_ID,@i_DT_Range_BEGIN_Date,@i_DT_Range_END_Date,-1,@i_Show_Dep,'A',1,'N'

			END TRY
			BEGIN CATCH
					
				-- Assume that the error is a SQL error and log it
				SELECT @err_num = ERROR_NUMBER()
					  ,@err_msg	= ERROR_MESSAGE()

				IF @err_num = 213 SET @err_msg = 'No census records to delete.'
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Member_ID, @i_Group_ID, @i_Show_Dep, @status, @err_num, @err_msg

			END CATCH
		

			-- Now loop through all of the census records and delete them
			DECLARE CensusDelete_Cursor CURSOR FOR
			 SELECT Census_GID
			   FROM #CensusRecords

			   OPEN CensusDelete_Cursor
			  FETCH NEXT FROM CensusDelete_Cursor
			   INTO @census_gid
				   
			WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC dbo.prBARCensus_Transaction_Delete   
						 @i_Entity_name              = ''  
						,@i_Census_Transaction_Gid   = @census_gid  
						,@i_Group_gid                = ''  
						,@i_Parent_Entity_Gid        = ''  
						,@i_Parent_Entity_Type       = ''  
						,@i_Child_Entity_Gid         = ''  
						,@i_Child_Entity_Type        = ''  
						,@i_Relationship_Code        = ''  
						,@i_Inv_Gid_Where_Posted     = ''  
						,@i_key_9_field              = ''  
						,@i_key_10_field             = ''  
						,@i_date_modified            = ''  
						,@i_action                   = ''  
						,@iUserID                    = @i_user  
						,@o_status                   = @o_status     OUTPUT  
						,@o_message                  = @o_message    OUTPUT;

					FETCH NEXT FROM CensusDelete_Cursor
					 INTO @census_gid

				END

			CLOSE CensusDelete_Cursor
			DEALLOCATE CensusDelete_Cursor

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @i_Member_ID, @i_Group_ID, @i_Show_Dep, @status, @err_num, @err_msg

		FETCH NEXT FROM MassCensusTransactionDelete_Cursor
		 INTO @SearchID
		     ,@i_MemberID_Starts
			 ,@i_Member_ID
			 ,@i_GroupID_Starts
			 ,@i_Group_ID
			 ,@i_DT_Range_BEGIN_Date
			 ,@i_DT_Range_END_Date
			 ,@i_Show_Dep
			 ,@record_id
			 ,@static_gid
	END

CLOSE MassCensusTransactionDelete_Cursor
DEALLOCATE MassCensusTransactionDelete_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#CensusError') IS NOT NULL
	DROP TABLE #CensusError

IF OBJECT_ID('tempdb.dbo.#MassCensusTransactionDelete') IS NOT NULL
	DROP TABLE #MassCensusTransactionDelete

IF OBJECT_ID('tempdb.dbo.#CensusRecords') IS NOT NULL
	DROP TABLE #CensusRecords

END
GO