IF OBJECT_ID('dbo.fnAPICommon_GetReferenceDescription') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnAPICommon_GetReferenceDescription() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnAPICommon_GetReferenceDescription
Purpose:    Return the description for the System Action Value

Date        User            Change
---------------------------------------------------------------------------------------------
02/23/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT dbo.fnAPICommon_GetReferenceDescription('*CLMTP','3')
***************************************************************************************************/
ALTER FUNCTION dbo.fnAPICommon_GetReferenceDescription
     (@reference_type	VARCHAR(50)
	 ,@short_desc		VARCHAR(40))

RETURNS VARCHAR(200)
AS
BEGIN
	
	DECLARE @description		VARCHAR(100)

	SELECT @description				= SAV.Description
	  FROM dbo.System_Action_Values	SAV
	 WHERE SAV.record_status		= 'A'
	   AND SAV.Reference_Type		= @reference_type
	   AND SAV.Short_Desc			= @short_desc

	RETURN @description
END
GO