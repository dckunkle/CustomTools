/**************************************************************************************************
Name:       spDCAuto_CreatePlanBenefitDesign
Purpose:    Create planbenefitdesign data from CorderAutomation

Screen:     11024
Method:     PlanBenefitDesign
Procedure:  dbo.prPlanBenefitDesignAdd
Entity:     PlanBenefitDesign

Date        User            Change
---------------------------------------------------------------------------------------------
10/12/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreatePlanBenefitDesign 'IDCards-TestCase-101', 22, 'IDCards-TestCase-101', 'PlanBenefitDesign', 'dkunkle'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spDCAuto_CreatePlanBenefitDesign
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

DECLARE @iEntityName                          VARCHAR(50)
       ,@iKeyPlanBenefitDesignSID             VARCHAR(50)
       ,@iKeyPlanBenefitDesignGID             VARCHAR(50)
       ,@iKeyVisitDTMs                        VARCHAR(200)
       ,@i_key_4_field                        VARCHAR(200)
       ,@i_key_5_field                        VARCHAR(200)
       ,@i_key_6_field                        VARCHAR(200)
       ,@i_key_7_field                        VARCHAR(200)
       ,@i_key_8_field                        VARCHAR(200)
       ,@i_key_9_field                        VARCHAR(200)
       ,@i_key_10_field                       VARCHAR(200)
       ,@i_action                             VARCHAR(10)
       ,@i_Date_Time_Modified                 VARCHAR(30)
       ,@iUserID                              VARCHAR(25)
       ,@iEffectiveDate                       VARCHAR(50)
       ,@iTerminationDate                     VARCHAR(50)
       ,@iPlanStrategyID                      VARCHAR(50)
       ,@iPlanStrategyDesc                    VARCHAR(150)
       ,@iCostShareTier                       VARCHAR(50)
       ,@iDEDFamily                           VARCHAR(50)
       ,@iOOPFamily                           VARCHAR(50)
       ,@iDEDIndividual                       VARCHAR(50)
       ,@iOOPIndividual                       VARCHAR(50)
       ,@iPCPOfficeCopayAmount                VARCHAR(50)
       ,@iPCPOfficeCoinsuranceAmount          VARCHAR(50)
       ,@iPCPOfficeInitialVisitIndicator      VARCHAR(50)
       ,@iPCPOfficeInitialVisitAmount         VARCHAR(50)
       ,@iPCPOfficeInitialVisitAllowedUnits   VARCHAR(50)
       ,@iPCPOfficePostVisitIndicator         VARCHAR(50)
       ,@iPCPOfficePostVisitAmount            VARCHAR(50)
       ,@iSpecialPCPCopayAmount               VARCHAR(50)
       ,@iSpecialPCPCoinsuranceAmount         VARCHAR(50)
       ,@iSpecialPCPInitialVisitIndicator     VARCHAR(50)
       ,@iSpecialPCPInitialVisitAmount        VARCHAR(50)
       ,@iSpecialPCPInitialVisitAllowedUnits  VARCHAR(50)
       ,@iSpecialPCPPostVisitIndicator        VARCHAR(50)
       ,@iSpecialPCPPostVisitAmount           VARCHAR(50)
       ,@iERCopayAmount                       VARCHAR(50)
       ,@iERCoinsuranceAmount                 VARCHAR(50)
       ,@iERInitialVisitIndicator             VARCHAR(50)
       ,@iERInitialVisitAmount                VARCHAR(50)
       ,@iERInitialVisitAllowedUnits          VARCHAR(50)
       ,@iERPostVisitIndicator                VARCHAR(50)
       ,@iERPostVisitAmount                   VARCHAR(50)
       ,@iUrgentCopayAmount                   VARCHAR(50)
       ,@iUrgentCoinsuranceAmount             VARCHAR(50)
       ,@iUrgentInitialVisitIndicator         VARCHAR(50)
       ,@iUrgentInitialVisitAmount            VARCHAR(50)
       ,@iUrgentInitialVisitAllowedUnits      VARCHAR(50)
       ,@iUrgentPostVisitIndicator            VARCHAR(50)
       ,@iUrgentPostVisitAmount               VARCHAR(50)
       ,@iInpatientCopayAmount                VARCHAR(50)
       ,@iInpatientCoinsuranceAmount          VARCHAR(50)
       ,@iInpatientInitialVisitIndicator      VARCHAR(50)
       ,@iInpatientInitialVisitAmount         VARCHAR(50)
       ,@iInpatientInitialVisitAllowedUnits   VARCHAR(50)
       ,@iInpatientPostVisitIndicator         VARCHAR(50)
       ,@iInpatientPostVisitAmount            VARCHAR(50)
       ,@iConvenienceCopayAmount              VARCHAR(50)
       ,@iConvenienceCoinsuranceAmount        VARCHAR(50)
       ,@iConvenienceInitialVisitIndicator    VARCHAR(50)
       ,@iConvenienceInitialVisitAmount       VARCHAR(50)
       ,@iConvenienceInitialVisitAllowedUnits VARCHAR(50)
       ,@iConveniencePostVisitIndicator       VARCHAR(50)
       ,@iConveniencePostVisitAmount          VARCHAR(50)
       ,@oStatus                              INT
       ,@oMessage                             VARCHAR(200)

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#PlanBenefitDesign') IS NOT NULL
	DROP TABLE #PlanBenefitDesign

CREATE TABLE #PlanBenefitDesign
      (SearchID                             VARCHAR(200)
      ,iEntityName                          VARCHAR(50)       DEFAULT('PlanBenefitDesign')
      ,iKeyPlanBenefitDesignSID             VARCHAR(50)       DEFAULT('0')
      ,iKeyPlanBenefitDesignGID             VARCHAR(50)       DEFAULT('0')
      ,iKeyVisitDTMs                        VARCHAR(200)      DEFAULT('0')
      ,i_key_4_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_5_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_6_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_7_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_8_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_9_field                        VARCHAR(200)      DEFAULT('0')
      ,i_key_10_field                       VARCHAR(200)      DEFAULT('0')
      ,i_action                             VARCHAR(10)       DEFAULT('ADD')
      ,i_Date_Time_Modified                 VARCHAR(30)       DEFAULT('')
      ,iUserID                              VARCHAR(25)       DEFAULT('')
      ,iEffectiveDate                       VARCHAR(50)
      ,iTerminationDate                     VARCHAR(50)
      ,iPlanStrategyID                      VARCHAR(50)
      ,iPlanStrategyDesc                    VARCHAR(150)
      ,iCostShareTier                       VARCHAR(50)
      ,iDEDFamily                           VARCHAR(50)
      ,iOOPFamily                           VARCHAR(50)
      ,iDEDIndividual                       VARCHAR(50)
      ,iOOPIndividual                       VARCHAR(50)
      ,iPCPOfficeCopayAmount                VARCHAR(50)
      ,iPCPOfficeCoinsuranceAmount          VARCHAR(50)
      ,iPCPOfficeInitialVisitIndicator      VARCHAR(50)
      ,iPCPOfficeInitialVisitAmount         VARCHAR(50)
      ,iPCPOfficeInitialVisitAllowedUnits   VARCHAR(50)
      ,iPCPOfficePostVisitIndicator         VARCHAR(50)
      ,iPCPOfficePostVisitAmount            VARCHAR(50)
      ,iSpecialPCPCopayAmount               VARCHAR(50)
      ,iSpecialPCPCoinsuranceAmount         VARCHAR(50)
      ,iSpecialPCPInitialVisitIndicator     VARCHAR(50)
      ,iSpecialPCPInitialVisitAmount        VARCHAR(50)
      ,iSpecialPCPInitialVisitAllowedUnits  VARCHAR(50)
      ,iSpecialPCPPostVisitIndicator        VARCHAR(50)
      ,iSpecialPCPPostVisitAmount           VARCHAR(50)
      ,iERCopayAmount                       VARCHAR(50)
      ,iERCoinsuranceAmount                 VARCHAR(50)
      ,iERInitialVisitIndicator             VARCHAR(50)
      ,iERInitialVisitAmount                VARCHAR(50)
      ,iERInitialVisitAllowedUnits          VARCHAR(50)
      ,iERPostVisitIndicator                VARCHAR(50)
      ,iERPostVisitAmount                   VARCHAR(50)
      ,iUrgentCopayAmount                   VARCHAR(50)
      ,iUrgentCoinsuranceAmount             VARCHAR(50)
      ,iUrgentInitialVisitIndicator         VARCHAR(50)
      ,iUrgentInitialVisitAmount            VARCHAR(50)
      ,iUrgentInitialVisitAllowedUnits      VARCHAR(50)
      ,iUrgentPostVisitIndicator            VARCHAR(50)
      ,iUrgentPostVisitAmount               VARCHAR(50)
      ,iInpatientCopayAmount                VARCHAR(50)
      ,iInpatientCoinsuranceAmount          VARCHAR(50)
      ,iInpatientInitialVisitIndicator      VARCHAR(50)
      ,iInpatientInitialVisitAmount         VARCHAR(50)
      ,iInpatientInitialVisitAllowedUnits   VARCHAR(50)
      ,iInpatientPostVisitIndicator         VARCHAR(50)
      ,iInpatientPostVisitAmount            VARCHAR(50)
      ,iConvenienceCopayAmount              VARCHAR(50)
      ,iConvenienceCoinsuranceAmount        VARCHAR(50)
      ,iConvenienceInitialVisitIndicator    VARCHAR(50)
      ,iConvenienceInitialVisitAmount       VARCHAR(50)
      ,iConvenienceInitialVisitAllowedUnits VARCHAR(50)
      ,iConveniencePostVisitIndicator       VARCHAR(50)
      ,iConveniencePostVisitAmount          VARCHAR(50)
      ,oStatus                              INT
      ,oMessage                             VARCHAR(200)
      ,record_id                            INT
      ,static_gid                           INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
BEGIN TRY

    INSERT INTO #PlanBenefitDesign
          (SearchID
          ,iEffectiveDate
          ,iTerminationDate
          ,iPlanStrategyID
          ,iCostShareTier
          ,iDEDFamily
          ,iOOPFamily
          ,iDEDIndividual
          ,iOOPIndividual
          ,iPCPOfficeCopayAmount
          ,iPCPOfficeCoinsuranceAmount
          ,iPCPOfficeInitialVisitIndicator
		  ,iPCPOfficeInitialVisitAmount
          ,iPCPOfficeInitialVisitAllowedUnits
          ,iPCPOfficePostVisitIndicator
          ,iPCPOfficePostVisitAmount
		  ,iSpecialPCPCopayAmount               
      	  ,iSpecialPCPCoinsuranceAmount         
      	  ,iSpecialPCPInitialVisitIndicator     
      	  ,iSpecialPCPInitialVisitAmount        
      	  ,iSpecialPCPInitialVisitAllowedUnits  
      	  ,iSpecialPCPPostVisitIndicator        
      	  ,iSpecialPCPPostVisitAmount           
      	  ,iERCopayAmount                       
      	  ,iERCoinsuranceAmount                 
      	  ,iERInitialVisitIndicator             
      	  ,iERInitialVisitAmount                
      	  ,iERInitialVisitAllowedUnits          
      	  ,iERPostVisitIndicator                
      	  ,iERPostVisitAmount                   
      	  ,iUrgentCopayAmount                   
      	  ,iUrgentCoinsuranceAmount             
      	  ,iUrgentInitialVisitIndicator         
     	  ,iUrgentInitialVisitAmount            
      	  ,iUrgentInitialVisitAllowedUnits      
      	  ,iUrgentPostVisitIndicator            
      	  ,iUrgentPostVisitAmount               
      	  ,iInpatientCopayAmount                
      	  ,iInpatientCoinsuranceAmount          
      	  ,iInpatientInitialVisitIndicator      
      	  ,iInpatientInitialVisitAmount         
      	  ,iInpatientInitialVisitAllowedUnits   
      	  ,iInpatientPostVisitIndicator         
      	  ,iInpatientPostVisitAmount            
      	  ,iConvenienceCopayAmount              
      	  ,iConvenienceCoinsuranceAmount        
      	  ,iConvenienceInitialVisitIndicator    
      	  ,iConvenienceInitialVisitAmount       
      	  ,iConvenienceInitialVisitAllowedUnits 
      	  ,iConveniencePostVisitIndicator       
      	  ,iConveniencePostVisitAmount          
	  	  ,record_id
          ,static_gid)
    SELECT SearchID
	      ,ISNULL([*Common_EffectiveDate], CONVERT(VARCHAR(10), GETDATE(), 101))
          ,ISNULL([*Common_TerminationDate], '12/31/9999')
          ,ISNULL([*Common_PlanStrategyID], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([*Common_CostShareTier]), '')
          ,ISNULL([Common_FamilyDeductible], '')
          ,ISNULL([Common_FamilyOutOfPocket], '')
          ,ISNULL([Common_IndividualDeductible], '')
          ,ISNULL([Common_IndividualOutOfPocket], '')
          ,ISNULL([PCP_CopayAmount], '')
          ,ISNULL([PCP_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PCP_InitialVisitIndicator]), '')
          ,ISNULL([PCP_InitialVisitAmount], '')
          ,ISNULL([PCP_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([PCP_PostVisitIndicator]), '')
          ,ISNULL([PCP_PostVisitAmount], '')
          ,ISNULL([Specialist_CopayAmount], '')
          ,ISNULL([Specialist_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialist_InitialVisitIndicator]), '')
          ,ISNULL([Specialist_InitialVisitAmount], '')
          ,ISNULL([Specialist_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Specialist_PostVisitIndicator]), '')
          ,ISNULL([Specialist_PostVisitAmount], '')
          ,ISNULL([ER_CopayAmount], '')
          ,ISNULL([ER_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ER_InitialVisitIndicator]), '')
          ,ISNULL([ER_InitialVisitAmount], '')
          ,ISNULL([ER_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([ER_PostVisitIndicator]), '')
          ,ISNULL([ER_PostVisitAmount], '')
          ,ISNULL([Urgent_CopayAmount], '')
          ,ISNULL([Urgent_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Urgent_InitialVisitIndicator]), '')
          ,ISNULL([Urgent_InitialVisitAmount], '')
          ,ISNULL([Urgent_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Urgent_PostVisitIndicator]), '')
          ,ISNULL([Urgent_PostVisitAmount], '')
          ,ISNULL([Inpatient_CopayAmount], '')
          ,ISNULL([Inpatient_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Inpatient_InitialVisitIndicator]), '')
          ,ISNULL([Inpatient_InitialVisitAmount], '')
          ,ISNULL([Inpatient_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Inpatient_PostVisitIndicator]), '')
          ,ISNULL([Inpatient_PostVisitAmount], '')
          ,ISNULL([Convenience_CopayAmount], '')
          ,ISNULL([Convenience_CoInsuranceAmount], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Convenience_InitialVisitIndicator]), '')
          ,ISNULL([Convenience_InitialVisitAmount], '')
          ,ISNULL([Convenience_InitialVisitAllowedUnit], '')
          ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Convenience_PostVisitIndicator]), '')
          ,ISNULL([Convenience_PostVisitAmount], '')
          ,ISNULL([RecordID], '')
		  ,ISNULL([gid], 0)
      FROM COREAUTO.CoreAutomation.dbo.TD_PlanBenefitDesign
     WHERE TCID				LIKE @pattern
       AND ActiveTestCase	= 'A'

    --*************************************************************************************************
    -- Update the user
    --*************************************************************************************************
    UPDATE #PlanBenefitDesign
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
DECLARE PlanBenefitDesign_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntityName
       ,iKeyPlanBenefitDesignSID
       ,iKeyPlanBenefitDesignGID
       ,iKeyVisitDTMs
       ,i_key_4_field
       ,i_key_5_field
       ,i_key_6_field
       ,i_key_7_field
       ,i_key_8_field
       ,i_key_9_field
       ,i_key_10_field
       ,i_action
       ,i_Date_Time_Modified
       ,iUserID
       ,iEffectiveDate
       ,iTerminationDate
       ,iPlanStrategyID
       ,iPlanStrategyDesc
       ,iCostShareTier
       ,iDEDFamily
       ,iOOPFamily
       ,iDEDIndividual
       ,iOOPIndividual
       ,iPCPOfficeCopayAmount
       ,iPCPOfficeCoinsuranceAmount
       ,iPCPOfficeInitialVisitIndicator
       ,iPCPOfficeInitialVisitAmount
       ,iPCPOfficeInitialVisitAllowedUnits
       ,iPCPOfficePostVisitIndicator
       ,iPCPOfficePostVisitAmount
       ,iSpecialPCPCopayAmount
       ,iSpecialPCPCoinsuranceAmount
       ,iSpecialPCPInitialVisitIndicator
       ,iSpecialPCPInitialVisitAmount
       ,iSpecialPCPInitialVisitAllowedUnits
       ,iSpecialPCPPostVisitIndicator
       ,iSpecialPCPPostVisitAmount
       ,iERCopayAmount
       ,iERCoinsuranceAmount
       ,iERInitialVisitIndicator
       ,iERInitialVisitAmount
       ,iERInitialVisitAllowedUnits
       ,iERPostVisitIndicator
       ,iERPostVisitAmount
       ,iUrgentCopayAmount
       ,iUrgentCoinsuranceAmount
       ,iUrgentInitialVisitIndicator
       ,iUrgentInitialVisitAmount
       ,iUrgentInitialVisitAllowedUnits
       ,iUrgentPostVisitIndicator
       ,iUrgentPostVisitAmount
       ,iInpatientCopayAmount
       ,iInpatientCoinsuranceAmount
       ,iInpatientInitialVisitIndicator
       ,iInpatientInitialVisitAmount
       ,iInpatientInitialVisitAllowedUnits
       ,iInpatientPostVisitIndicator
       ,iInpatientPostVisitAmount
       ,iConvenienceCopayAmount
       ,iConvenienceCoinsuranceAmount
       ,iConvenienceInitialVisitIndicator
       ,iConvenienceInitialVisitAmount
       ,iConvenienceInitialVisitAllowedUnits
       ,iConveniencePostVisitIndicator
       ,iConveniencePostVisitAmount
       ,oStatus
       ,oMessage
       ,record_id
       ,static_gid
   FROM #PlanBenefitDesign

   OPEN PlanBenefitDesign_Cursor
  FETCH NEXT FROM PlanBenefitDesign_Cursor
   INTO @SearchID
       ,@iEntityName
       ,@iKeyPlanBenefitDesignSID
       ,@iKeyPlanBenefitDesignGID
       ,@iKeyVisitDTMs
       ,@i_key_4_field
       ,@i_key_5_field
       ,@i_key_6_field
       ,@i_key_7_field
       ,@i_key_8_field
       ,@i_key_9_field
       ,@i_key_10_field
       ,@i_action
       ,@i_Date_Time_Modified
       ,@iUserID
       ,@iEffectiveDate
       ,@iTerminationDate
       ,@iPlanStrategyID
       ,@iPlanStrategyDesc
       ,@iCostShareTier
       ,@iDEDFamily
       ,@iOOPFamily
       ,@iDEDIndividual
       ,@iOOPIndividual
       ,@iPCPOfficeCopayAmount
       ,@iPCPOfficeCoinsuranceAmount
       ,@iPCPOfficeInitialVisitIndicator
       ,@iPCPOfficeInitialVisitAmount
       ,@iPCPOfficeInitialVisitAllowedUnits
       ,@iPCPOfficePostVisitIndicator
       ,@iPCPOfficePostVisitAmount
       ,@iSpecialPCPCopayAmount
       ,@iSpecialPCPCoinsuranceAmount
       ,@iSpecialPCPInitialVisitIndicator
       ,@iSpecialPCPInitialVisitAmount
       ,@iSpecialPCPInitialVisitAllowedUnits
       ,@iSpecialPCPPostVisitIndicator
       ,@iSpecialPCPPostVisitAmount
       ,@iERCopayAmount
       ,@iERCoinsuranceAmount
       ,@iERInitialVisitIndicator
       ,@iERInitialVisitAmount
       ,@iERInitialVisitAllowedUnits
       ,@iERPostVisitIndicator
       ,@iERPostVisitAmount
       ,@iUrgentCopayAmount
       ,@iUrgentCoinsuranceAmount
       ,@iUrgentInitialVisitIndicator
       ,@iUrgentInitialVisitAmount
       ,@iUrgentInitialVisitAllowedUnits
       ,@iUrgentPostVisitIndicator
       ,@iUrgentPostVisitAmount
       ,@iInpatientCopayAmount
       ,@iInpatientCoinsuranceAmount
       ,@iInpatientInitialVisitIndicator
       ,@iInpatientInitialVisitAmount
       ,@iInpatientInitialVisitAllowedUnits
       ,@iInpatientPostVisitIndicator
       ,@iInpatientPostVisitAmount
       ,@iConvenienceCopayAmount
       ,@iConvenienceCoinsuranceAmount
       ,@iConvenienceInitialVisitIndicator
       ,@iConvenienceInitialVisitAmount
       ,@iConvenienceInitialVisitAllowedUnits
       ,@iConveniencePostVisitIndicator
       ,@iConveniencePostVisitAmount
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

			EXEC dbo.prPlanBenefitDesignAdd
                 @iEntityName
                ,@iKeyPlanBenefitDesignSID
                ,@iKeyPlanBenefitDesignGID
                ,@iKeyVisitDTMs
                ,@i_key_4_field
                ,@i_key_5_field
                ,@i_key_6_field
                ,@i_key_7_field
                ,@i_key_8_field
                ,@i_key_9_field
                ,@i_key_10_field
                ,@i_action
                ,@i_Date_Time_Modified
                ,@iUserID
                ,@iEffectiveDate
                ,@iTerminationDate
                ,@iPlanStrategyID
                ,@iPlanStrategyDesc
                ,@iCostShareTier
                ,@iDEDFamily
                ,@iOOPFamily
                ,@iDEDIndividual
                ,@iOOPIndividual
                ,@iPCPOfficeCopayAmount
                ,@iPCPOfficeCoinsuranceAmount
                ,@iPCPOfficeInitialVisitIndicator
                ,@iPCPOfficeInitialVisitAmount
                ,@iPCPOfficeInitialVisitAllowedUnits
                ,@iPCPOfficePostVisitIndicator
                ,@iPCPOfficePostVisitAmount
                ,@iSpecialPCPCopayAmount
                ,@iSpecialPCPCoinsuranceAmount
                ,@iSpecialPCPInitialVisitIndicator
                ,@iSpecialPCPInitialVisitAmount
                ,@iSpecialPCPInitialVisitAllowedUnits
                ,@iSpecialPCPPostVisitIndicator
                ,@iSpecialPCPPostVisitAmount
                ,@iERCopayAmount
                ,@iERCoinsuranceAmount
                ,@iERInitialVisitIndicator
                ,@iERInitialVisitAmount
                ,@iERInitialVisitAllowedUnits
                ,@iERPostVisitIndicator
                ,@iERPostVisitAmount
                ,@iUrgentCopayAmount
                ,@iUrgentCoinsuranceAmount
                ,@iUrgentInitialVisitIndicator
                ,@iUrgentInitialVisitAmount
                ,@iUrgentInitialVisitAllowedUnits
                ,@iUrgentPostVisitIndicator
                ,@iUrgentPostVisitAmount
                ,@iInpatientCopayAmount
                ,@iInpatientCoinsuranceAmount
                ,@iInpatientInitialVisitIndicator
                ,@iInpatientInitialVisitAmount
                ,@iInpatientInitialVisitAllowedUnits
                ,@iInpatientPostVisitIndicator
                ,@iInpatientPostVisitAmount
                ,@iConvenienceCopayAmount
                ,@iConvenienceCoinsuranceAmount
                ,@iConvenienceInitialVisitIndicator
                ,@iConvenienceInitialVisitAmount
                ,@iConvenienceInitialVisitAllowedUnits
                ,@iConveniencePostVisitIndicator
                ,@iConveniencePostVisitAmount
                ,@oStatus     = @err_num OUTPUT
                ,@oMessage    = @err_msg OUTPUT

       -- Update the Contact GID
		IF ISNULL(@static_gid, 0) > 0
			BEGIN

				-- Get the current contact gid
				SELECT @current_gid				= PBD.PlanBenefitDesignGID
				  FROM dbo.PlanBenefitDesign	PBD
				  JOIN dbo.Plan_Strategy_Names	PSN
				    ON PBD.PlanStrategyGID		= PSN.plan_strategy_gid
				 WHERE PBD.RecordStatus			= 'A'
				   AND PSN.record_status		= 'A'
				   AND PBD.UserIDCreated		= @iUserID
				   AND PSN.plan_strategy_id		= @iPlanStrategyID
				   AND PBD.EffectiveDate		= @iEffectiveDate
				   AND PBD.CostShareTier		= @iCostShareTier

				-- Update to the static gid
				UPDATE dbo.PlanBenefitDesign 
				   SET PlanBenefitDesignGID		= @static_gid 
				 WHERE RecordStatus				= 'A'
				   AND PlanBenefitDesignGID		= @current_gid

				UPDATE dbo.PlanBenefitDesignVisit 
				   SET PlanBenefitDesignGID		= @static_gid 
				 WHERE RecordStatus				= 'A'
				   AND PlanBenefitDesignGID		= @current_gid

			END

        END TRY
		BEGIN CATCH

			SELECT @err_num = ERROR_NUMBER()
				  ,@err_msg	= ERROR_MESSAGE()

		END CATCH


		SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
        EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @iPlanStrategyID, @iEffectiveDate, @iCostShareTier, @status, @err_num, @err_msg

		WAITFOR DELAY '00:00:00.100';

        FETCH NEXT FROM PlanBenefitDesign_Cursor
         INTO @SearchID
             ,@iEntityName
             ,@iKeyPlanBenefitDesignSID
             ,@iKeyPlanBenefitDesignGID
             ,@iKeyVisitDTMs
             ,@i_key_4_field
             ,@i_key_5_field
             ,@i_key_6_field
             ,@i_key_7_field
             ,@i_key_8_field
             ,@i_key_9_field
             ,@i_key_10_field
             ,@i_action
             ,@i_Date_Time_Modified
             ,@iUserID
             ,@iEffectiveDate
             ,@iTerminationDate
             ,@iPlanStrategyID
             ,@iPlanStrategyDesc
             ,@iCostShareTier
             ,@iDEDFamily
             ,@iOOPFamily
             ,@iDEDIndividual
             ,@iOOPIndividual
             ,@iPCPOfficeCopayAmount
             ,@iPCPOfficeCoinsuranceAmount
             ,@iPCPOfficeInitialVisitIndicator
             ,@iPCPOfficeInitialVisitAmount
             ,@iPCPOfficeInitialVisitAllowedUnits
             ,@iPCPOfficePostVisitIndicator
             ,@iPCPOfficePostVisitAmount
             ,@iSpecialPCPCopayAmount
             ,@iSpecialPCPCoinsuranceAmount
             ,@iSpecialPCPInitialVisitIndicator
             ,@iSpecialPCPInitialVisitAmount
             ,@iSpecialPCPInitialVisitAllowedUnits
             ,@iSpecialPCPPostVisitIndicator
             ,@iSpecialPCPPostVisitAmount
             ,@iERCopayAmount
             ,@iERCoinsuranceAmount
             ,@iERInitialVisitIndicator
             ,@iERInitialVisitAmount
             ,@iERInitialVisitAllowedUnits
             ,@iERPostVisitIndicator
             ,@iERPostVisitAmount
             ,@iUrgentCopayAmount
             ,@iUrgentCoinsuranceAmount
             ,@iUrgentInitialVisitIndicator
             ,@iUrgentInitialVisitAmount
             ,@iUrgentInitialVisitAllowedUnits
             ,@iUrgentPostVisitIndicator
             ,@iUrgentPostVisitAmount
             ,@iInpatientCopayAmount
             ,@iInpatientCoinsuranceAmount
             ,@iInpatientInitialVisitIndicator
             ,@iInpatientInitialVisitAmount
             ,@iInpatientInitialVisitAllowedUnits
             ,@iInpatientPostVisitIndicator
             ,@iInpatientPostVisitAmount
             ,@iConvenienceCopayAmount
             ,@iConvenienceCoinsuranceAmount
             ,@iConvenienceInitialVisitIndicator
             ,@iConvenienceInitialVisitAmount
             ,@iConvenienceInitialVisitAllowedUnits
             ,@iConveniencePostVisitIndicator
             ,@iConveniencePostVisitAmount
             ,@oStatus
             ,@oMessage
             ,@record_id
             ,@static_gid
	END

CLOSE PlanBenefitDesign_Cursor
DEALLOCATE PlanBenefitDesign_Cursor

--*************************************************************************************************
-- Cleanup data
--*************************************************************************************************
CLEANUP:
IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

IF OBJECT_ID('tempdb.dbo.#PlanBenefitDesign') IS NOT NULL
	DROP TABLE #PlanBenefitDesign

END
GO

