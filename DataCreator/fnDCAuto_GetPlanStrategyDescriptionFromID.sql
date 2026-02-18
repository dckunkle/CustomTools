IF OBJECT_ID('dbo.fnDCAuto_GetPlanStrategyDescriptionFromID') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetPlanStrategyDescriptionFromID() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetPlanStrategyDescriptionFromID
Purpose:    Return the plan strategy description given the id

Date        User            Change
---------------------------------------------------------------------------------------------
12/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetPlanStrategyDescriptionFromID
     (@i_plan_strategy_id	VARCHAR(200))
RETURNS VARCHAR(300)
AS
BEGIN
	
	DECLARE @plan_strategy_id		VARCHAR(300) = ''
	       ,@plan_strategy_desc		VARCHAR(300) = ''

	SET @plan_strategy_id = @i_plan_strategy_id

	SELECT @plan_strategy_desc		= PSN.plan_strategy_desc
	  FROM Plan_Strategy_Names		PSN
	 WHERE PSN.record_status		= 'A'
       AND PSN.plan_strategy_id		= @plan_strategy_id
				
	RETURN @plan_strategy_desc
	
END
GO