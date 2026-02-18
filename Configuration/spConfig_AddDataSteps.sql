/**************************************************************************************************
Name:       spConfig_AddDataSteps
Purpose:    Return all of the steps and related data that will need to be processed by the
            Configurator

Date        User            Change
---------------------------------------------------------------------------------------------
02/27/2022	DK				Original procedure

---------------------------------------------------------------------------------------------
EXEC spConfig_AddDataSteps 'Bright Copay Test'
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spConfig_AddDataSteps
     (@config_id		VARCHAR(500))
AS
BEGIN

SET NOCOUNT ON

--*************************************************************************************************
-- Assuming there is a good SQL query, replace the config ID and execute it
--*************************************************************************************************
SELECT C.ConfigID
      ,C.ConfigOrder
	  ,CS.ConfigUser
	  ,CS.ConfigStepOrder
	  ,CS.ConfigStep
	  ,CS.ConfigIDPattern
	  ,CASE WHEN ISNULL(AA.CoreProcedure, '') = '' THEN 'Not Defined' 
	        ELSE AA.CoreProcedure END CoreProcedure
  FROM cfg.Config			C
  JOIN cfg.ConfigStep		CS
    ON C.ConfigID			= CS.ConfigID
  LEFT JOIN cfg.ActionAdd	AA
    ON CS.ConfigStep		= AA.MethodName
 WHERE C.ConfigID			LIKE @config_id
   AND C.Status				= 'A'
   AND CS.Status			= 'A'
   AND AA.Status			= 'A'
 GROUP BY C.ConfigID
         ,C.ConfigOrder
		 ,CS.ConfigUser
		 ,CS.ConfigStepOrder
		 ,CS.ConfigStep
		 ,CS.ConfigIDPattern
		 ,CASE WHEN ISNULL(AA.CoreProcedure, '') = '' THEN 'Not Defined' 
	        ELSE AA.CoreProcedure END 
 ORDER BY C.ConfigOrder
         ,CS.ConfigStepOrder

--*************************************************************************************************
-- Cleanup
--*************************************************************************************************
CLEANUP:

END
GO