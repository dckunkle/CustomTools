IF OBJECT_ID('dbo.fnAPIProvider_ServicesOffered') IS NOT NULL
    BEGIN 
		DROP FUNCTION dbo.fnAPIProvider_ServicesOffered 
	END
GO
/**************************************************************************************************
Name:       fnAPIProvider_ServicesOffered
Purpose:    Return the formatted address of the service location

Date        User            Change
---------------------------------------------------------------------------------------------
02/12/2021	DK				Original script
---------------------------------------------------------------------------------------------

SELECT * FROM dbo.fnAPIProvider_ServicesOffered(520060050,520500003,520050003)
***************************************************************************************************/
CREATE FUNCTION dbo.fnAPIProvider_ServicesOffered
     (@provider_gid	INT
	 ,@business_gid	INT
	 ,@location_gid	INT)

RETURNS @Offered_Services TABLE
       (offered_service				VARCHAR(200)
	   ,offered_service_description	VARCHAR(200))
AS
BEGIN
	
	IF EXISTS(SELECT TOP 1 * FROM Location_Services WHERE provider_gid = @provider_gid AND business_gid = @business_gid AND location_gid = @location_gid)
		BEGIN
			INSERT INTO @Offered_Services
			      (offered_service
				  ,offered_service_description)
			SELECT LS.offered_services		
			      ,X.Description			
			  FROM dbo.Location_Services	LS
			 OUTER APPLY (SELECT SAV.Description
			                FROM System_Action_Values	SAV
						   WHERE SAV.Reference_Type		= 'SVCOFD'
						     AND SAV.record_status		= 'A'
							 AND SAV.Short_Desc			= LS.offered_services) X
			 WHERE LS.provider_gid			= @provider_gid
			   AND LS.business_gid			= @business_gid
			   AND LS.location_gid			= @location_gid
			   AND LS.record_status			= 'A'
		END
	ELSE
		BEGIN
			INSERT INTO @Offered_Services
			      (offered_service
				  ,offered_service_description)
			SELECT null
			      ,null
			
		END
	
	RETURN
END
GO