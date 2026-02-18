IF OBJECT_ID('dbo.spDCAuto_CreateServiceLocationsServicesOffered') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spDCAuto_CreateServiceLocationsServicesOffered AS SELECT 1')
GO
/**************************************************************************************************
Name:       spDCAuto_CreateServiceLocationsServicesOffered
Purpose:    Create servicelocationsservicesoffered data from CorderAutomation
Method:     ServiceLocationsServicesOffered
Screen GID: 0
Procedure:  dbo.prServicesOffered_AddModify

Date        User            Change
---------------------------------------------------------------------------------------------
11/19/2019	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
EXEC spDCAuto_CreateServiceLocationsServicesOffered '100-Config%', 22, 'ServiceLocationsServicesOffered'
***************************************************************************************************/
ALTER PROCEDURE dbo.spDCAuto_CreateServiceLocationsServicesOffered
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

	   ,@provider_id				VARCHAR(200)
	   ,@location_id				VARCHAR(200)
	   ,@business_id				VARCHAR(200)
	   ,@services					VARCHAR(2000)
	   ,@service_location_count		INT

SELECT @pattern				= @i_pattern
	  ,@log_id				= @i_log_id
	  ,@method				= @i_method
	  ,@test_case_name		= @i_test_case_name
	  ,@user				= @i_user

DECLARE @iEntity_name      VARCHAR(50)
       ,@iProviderGid      INT
       ,@iBusUnitGid       INT
       ,@iLocationGid      INT
       ,@iKey4Field        VARCHAR(50)
       ,@iKey5Field        VARCHAR(50)
       ,@iKey6Field        VARCHAR(50)
       ,@iKey7Field        VARCHAR(50)
       ,@iKey8Field        VARCHAR(50)
       ,@iKey9Field        VARCHAR(50)
       ,@iKey10Field       VARCHAR(50)
       ,@iAction           VARCHAR(10)
       ,@iDateTimeModified VARCHAR(20)
       ,@iUserID           VARCHAR(25)
       ,@iScreenXml        XML
	   ,@Service1		   VARCHAR(200)
	   ,@Service2		   VARCHAR(200)
	   ,@Service3		   VARCHAR(200)
	   ,@Service4		   VARCHAR(200)
	   ,@Service5		   VARCHAR(200)
       ,@o_status          INT
       ,@o_message         VARCHAR(255)
       ,@iDebug            INT

--*************************************************************************************************
-- Create a table for all of the inbound parameters
--*************************************************************************************************
IF OBJECT_ID('tempdb.dbo.#ServiceLocationsServicesOffered') IS NOT NULL
	DROP TABLE #ServiceLocationsServicesOffered

CREATE TABLE #ServiceLocationsServicesOffered
      (SearchID          VARCHAR(200)
      ,iEntity_name      VARCHAR(50)       DEFAULT('Services_Offered')
      ,iProviderGid      INT			   DEFAULT('0')
      ,iBusUnitGid       INT			   DEFAULT('0')
      ,iLocationGid      INT			   DEFAULT('0')
      ,iKey4Field        VARCHAR(50)       DEFAULT('0')
      ,iKey5Field        VARCHAR(50)       DEFAULT('0')
      ,iKey6Field        VARCHAR(50)       DEFAULT('0')
      ,iKey7Field        VARCHAR(50)       DEFAULT('0')
      ,iKey8Field        VARCHAR(50)       DEFAULT('0')
      ,iKey9Field        VARCHAR(50)       DEFAULT('0')
      ,iKey10Field       VARCHAR(50)       DEFAULT('0')
      ,iAction           VARCHAR(10)       DEFAULT('ADD')
      ,iDateTimeModified VARCHAR(20)       DEFAULT('')
      ,iUserID           VARCHAR(25)       DEFAULT('')
      ,iScreenXml        XML
      ,o_status          INT
      ,o_message         VARCHAR(255)
      ,iDebug            INT
	  ,Service1			 VARCHAR(200)
	  ,Service2			 VARCHAR(200)
	  ,Service3			 VARCHAR(200)
	  ,Service4			 VARCHAR(200)
	  ,Service5			 VARCHAR(200)
      ,record_id         INT
      ,static_gid        INT)

IF OBJECT_ID('tempdb.dbo.#Tokens') IS NOT NULL
	DROP TABLE #Tokens

CREATE TABLE #Tokens
      (token			VARCHAR(200)
	  ,token_order		INT				IDENTITY(1,1))

--*************************************************************************************************
-- Populate the table with data from CoreAutomation to be created
--*************************************************************************************************
INSERT INTO #ServiceLocationsServicesOffered
      (SearchID
	  ,Service1
	  ,Service2
	  ,Service3
	  ,Service4
	  ,Service5
      ,iScreenXml
      ,record_id
      ,static_gid)
SELECT SearchID
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Service1]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Service2]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Service3]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Service4]), '')
      ,ISNULL(dbo.fnDCAuto_GetDropdownValue([Service5]), '')
	  , dbo.fnDCAuto_GetOfferedServicesXML(Service1, Service2, Service3, Service4, Service5)
	  ,ISNULL([RecordID], '')
      ,ISNULL([gid], '')
  FROM COREAUTO.CoreAutomation.dbo.TD_ServiceLocationOfferedServices
 WHERE TCID				LIKE @pattern
   AND ActiveTestCase	= 'A'

--*************************************************************************************************
-- Update the user
--*************************************************************************************************
UPDATE #ServiceLocationsServicesOffered
   SET iUserID  = @user

--*************************************************************************************************
-- Create the data
--*************************************************************************************************
DECLARE ServiceLocationsServicesOffered_Cursor CURSOR FOR
 SELECT SearchID
       ,iEntity_name
       ,iProviderGid
       ,iBusUnitGid
       ,iLocationGid
       ,iKey4Field
       ,iKey5Field
       ,iKey6Field
       ,iKey7Field
       ,iKey8Field
       ,iKey9Field
       ,iKey10Field
       ,iAction
       ,iDateTimeModified
       ,iUserID
       ,iScreenXml
	   ,Service1
	   ,Service2
	   ,Service3
	   ,Service4
	   ,Service5
       ,o_status
       ,o_message
       ,iDebug
       ,record_id
       ,static_gid
   FROM #ServiceLocationsServicesOffered

   OPEN ServiceLocationsServicesOffered_Cursor
  FETCH NEXT FROM ServiceLocationsServicesOffered_Cursor
   INTO @SearchID
       ,@iEntity_name
       ,@iProviderGid
       ,@iBusUnitGid
       ,@iLocationGid
       ,@iKey4Field
       ,@iKey5Field
       ,@iKey6Field
       ,@iKey7Field
       ,@iKey8Field
       ,@iKey9Field
       ,@iKey10Field
       ,@iAction
       ,@iDateTimeModified
       ,@iUserID
       ,@iScreenXml
	   ,@Service1
	   ,@Service2
	   ,@Service3
	   ,@Service4
	   ,@Service5
       ,@o_status
       ,@o_message
       ,@iDebug
       ,@record_id
       ,@static_gid

WHILE @@FETCH_STATUS = 0
	BEGIN
			
		-- Split the search criteria into the provider and location IDs
		TRUNCATE TABLE #Tokens
		INSERT INTO #Tokens (token) SELECT token FROM dbo.fnAuto_SplitTokens(@SearchID, ';')

		SELECT @provider_id = token FROM #Tokens WHERE token_order = 1
		SELECT @location_id	= token FROM #Tokens WHERE token_order = 2
		SELECT @business_id	= token FROM #Tokens WHERE token_order = 3

		SELECT @provider_id	= ISNULL(@provider_id, '')
		SELECT @location_id = ISNULL(@location_id, '')
		SELECT @business_id	= ISNULL(@business_id, '')

		-- Make sure there is only one service location 
		SELECT @service_location_count = COUNT(*)
		  FROM Provider_Link			PL
		  JOIN Provider					P
			ON PL.provider_gid			= P.provider_gid
		  JOIN Locations				L
			ON PL.location_gid			= L.location_gid
		  JOIN Business_Units			BU
		    ON PL.business_gid			= BU.business_gid
		  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
			              WHEN provider_id = @provider_id		THEN 1
					      ELSE 0 END)
			AND 1 = (CASE WHEN @location_id = ''				THEN 1 
			              WHEN location_id = @location_id		THEN 1
				          ELSE 0 END)
			AND 1 = (CASE WHEN @business_id = ''				THEN 1 
			              WHEN business_unit_id = @business_id	THEN 1
				          ELSE 0 END)
			AND PL.record_status		= 'A'
			AND P.record_status			= 'A'
			AND L.record_status			= 'A'
			AND BU.record_status		= 'A'

		IF @service_location_count != 1
			BEGIN

				SELECT @status	= 'Error' 
					    ,@err_num	= 16
						,@err_msg	= 'The search criteria, SearchID, does not match to a single service location. Cannot add specialty record.'
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @Service1, @status, @err_num, @err_msg
					
			END
		ELSE
			BEGIN
			
				SELECT @iScreenXml = dbo.fnDCAuto_GetOfferedServicesXML(@Service1, @Service2, @Service3, @Service4, @Service5)
				SELECT @services = @Service1 + ';' + @Service2 + ';' + @Service3 + ';' + @Service4 + ';' + @Service5

				BEGIN TRY

					SELECT @iProviderGid			= PL.provider_gid
						  ,@iLocationGid			= PL.location_gid
						  ,@iBusUnitGid				= PL.business_gid
					  FROM Provider_Link			PL
					  JOIN Provider					P
						ON PL.provider_gid			= P.provider_gid
					  JOIN Locations				L
						ON PL.location_gid			= L.location_gid
					  JOIN Business_Units			BU
						ON PL.business_gid			= BU.business_gid
					  WHERE 1 = (CASE WHEN @provider_id = ''				THEN 1 
									  WHEN provider_id = @provider_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @location_id = ''				THEN 1 
									  WHEN location_id = @location_id		THEN 1
									  ELSE 0 END)
						AND 1 = (CASE WHEN @business_id = ''				THEN 1 
									  WHEN business_unit_id = @business_id	THEN 1
									  ELSE 0 END)
						AND PL.record_status		= 'A'
						AND P.record_status			= 'A'
						AND L.record_status			= 'A'
						AND BU.record_status		= 'A'

					EXEC dbo.prServicesOffered_AddModify
					 @iEntity_name
					,@iProviderGid
					,@iBusUnitGid
					,@iLocationGid
					,@iKey4Field
					,@iKey5Field
					,@iKey6Field
					,@iKey7Field
					,@iKey8Field
					,@iKey9Field
					,@iKey10Field
					,@iAction
					,@iDateTimeModified
					,@iUserID
					,@iScreenXml
					,@o_status     = @err_num OUTPUT
					,@o_message    = @err_msg OUTPUT

				END TRY
				BEGIN CATCH

					SELECT @err_num = ERROR_NUMBER()
						  ,@err_msg	= ERROR_MESSAGE()

				END CATCH

				SELECT @status = CASE WHEN @err_num != 0 THEN 'Error' ELSE 'Add' END
				EXEC spDCAuto_LogEvent @log_id, @test_case_name, @method, @record_id, @provider_id, @location_id, @services, @status, @err_num, @err_msg

			END

        FETCH NEXT FROM ServiceLocationsServicesOffered_Cursor
         INTO @SearchID
             ,@iEntity_name
             ,@iProviderGid
             ,@iBusUnitGid
             ,@iLocationGid
             ,@iKey4Field
             ,@iKey5Field
             ,@iKey6Field
             ,@iKey7Field
             ,@iKey8Field
             ,@iKey9Field
             ,@iKey10Field
             ,@iAction
             ,@iDateTimeModified
             ,@iUserID
             ,@iScreenXml
			 ,@Service1
			 ,@Service2
			 ,@Service3
			 ,@Service4
			 ,@Service5
             ,@o_status
             ,@o_message
             ,@iDebug
             ,@record_id
             ,@static_gid
	END

CLOSE ServiceLocationsServicesOffered_Cursor
DEALLOCATE ServiceLocationsServicesOffered_Cursor

END
GO