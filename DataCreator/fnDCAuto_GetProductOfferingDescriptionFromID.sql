IF OBJECT_ID('dbo.fnDCAuto_GetProductOfferingDescriptionFromID') IS NULL
    EXEC ('CREATE FUNCTION dbo.fnDCAuto_GetProductOfferingDescriptionFromID() RETURNS VARCHAR(128) AS BEGIN RETURN ''CORE'' END')
GO
/**************************************************************************************************
Name:       fnDCAuto_GetProductOfferingDescriptionFromID
Purpose:    Return the network search description given the id

Date        User            Change
---------------------------------------------------------------------------------------------
12/17/2019	DK				Original script

---------------------------------------------------------------------------------------------

***************************************************************************************************/
ALTER FUNCTION dbo.fnDCAuto_GetProductOfferingDescriptionFromID
     (@i_product_offering	VARCHAR(200))
RETURNS VARCHAR(300)
AS
BEGIN
	
	DECLARE @product_offering			VARCHAR(300) = ''
	       ,@product_offering_desc		VARCHAR(300) = ''

	SET @product_offering = @i_product_offering

	SELECT @product_offering_desc			= PO.product_offering_desc
	  FROM dbo.Product_Offering				PO
	 WHERE PO.record_status					= 'A'
       AND PO.product_offering_id			= @i_product_offering
				
	RETURN @product_offering_desc
	
END
GO