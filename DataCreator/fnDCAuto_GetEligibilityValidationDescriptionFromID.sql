IF OBJECT_ID('dbo.fnDCAuto_GetEligibilityValidationDescriptionFromID') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetEligibilityValidationDescriptionFromID() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetEligibilityValidationDescriptionFromID
Purpose:    Return the plan strategy description given the id

Date        User            Change
---------------------------------------------------------------------------------------------
12/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetEligibilityValidationDescriptionFromID
     (@i_elig_val_id	VARCHAR(200))
RETURNS VARCHAR(300)
AS
BEGIN
	
	DECLARE @elig_val_id		VARCHAR(300) = ''
	       ,@elig_val_desc		VARCHAR(300) = ''

	SET @elig_val_id = @i_elig_val_id

	SELECT @elig_val_desc			= EN.entity_user_name
	  FROM Entity_Names				EN
	 WHERE EN.record_status			= 'A'
       AND EN.entity_user_id		= @elig_val_id
	   AND EN.entity_identifier		= 'Eligibility_Validation'
				
	RETURN @elig_val_desc
	
END
GO