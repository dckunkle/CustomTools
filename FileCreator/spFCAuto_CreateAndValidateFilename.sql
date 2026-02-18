/**************************************************************************************************
Name:       spFCAuto_CreateAndValidateFilename
Purpose:    Used to export a fixed length file

Date        User            Change
---------------------------------------------------------------------------------------------
06/08/2022	DK				Original procedure
---------------------------------------------------------------------------------------------

***************************************************************************************************
DECLARE @folder		VARCHAR(8000)
       ,@filename	VARCHAR(8000)
	   ,@err_num	INT
	   ,@err_msg	VARCHAR(8000)

EXEC spFCAuto_CreateAndValidateFilename 'Vendor%', 'VendorAccumulator', 'aldqadbqr06', @folder OUTPUT, @filename OUTPUT, @err_num OUTPUT, @err_msg OUTPUT

SELECT @folder, @filename, @err_num, @err_msg
***************************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.spFCAuto_CreateAndValidateFilename
     (@i_tcid			VARCHAR(200)
	 ,@i_method_name	VARCHAR(400)
	 ,@server			VARCHAR(200)
	 ,@folder			VARCHAR(8000)	OUTPUT
	 ,@filename			VARCHAR(8000)	OUTPUT
	 ,@err_num			INT				OUTPUT
	 ,@err_msg			VARCHAR(8000)	OUTPUT)
AS
BEGIN

SET NOCOUNT ON

--***************************************************************************************************
-- Declare variables to be used later
--***************************************************************************************************
DECLARE @filename_delimiter		VARCHAR(1)
	   ,@export_folder			VARCHAR(1000)
	   ,@file_extension			VARCHAR(100)
	   ,@filename_prefix		VARCHAR(200)
	   ,@batch_folder			VARCHAR(200)
	   ,@instance_name			VARCHAR(200)

	   -- Used to build the date portion of the file, if required
	   ,@include_date			VARCHAR(10)
	   ,@file_date				VARCHAR(100)
	   ,@file_date_format		VARCHAR(100)	= 'YYYYMMDD'

	   -- Used to build the time portion of the file, if required
	   ,@include_time			VARCHAR(10)
	   ,@file_time				VARCHAR(100)
	   ,@file_time_format		VARCHAR(100)	= 'HHMMSS'

	   ,@datetime_stamp			VARCHAR(50)

	   -- Set inbound parameters to variables to be used later
	   ,@method_name			VARCHAR(400)	= @i_method_name
	   ,@tcid					VARCHAR(200)	= @i_tcid

--***************************************************************************************************
-- Get details about te that needs to be created
--***************************************************************************************************
SELECT @filename			= ISNULL(C.filename, '')
      ,@filename_delimiter	= ISNULL(C.filename_delimiter, '')
	  ,@file_extension		= ISNULL(C.file_extension, '')
	  ,@export_folder		= ISNULL(C.export_folder, '')
	  ,@datetime_stamp		= ISNULL(C.datetime_stamp, '')
  FROM fw.Catalog			C
 WHERE C.Method_Name		= @i_method_name

 -- Determine the instance name for the server and get the corresponding batch folder name
 SELECT @instance_name		= dbo.fnFCAuto_GetServerName(@server)
 SELECT @batch_folder		= dbo.fnFCAuto_GetFolderName(@instance_name)

 SELECT @err_num			= 0
       ,@err_msg			= ''

--***************************************************************************************************
-- Validate the pieces of the filename to make sure nothing is missing
--***************************************************************************************************
IF NOT EXISTS(SELECT TOP 1 Method_Name FROM fw.Catalog WHERE Method_Name = @method_name)
	BEGIN
		SELECT @err_num	= 100
		      ,@err_msg	= 'The method name, ' + @method_name + ', is not defined in the fw.Catalog table. The file cannot be created.'
		GOTO LOG_ERROR
	END

IF @filename = ''
	BEGIN
		SELECT @err_num	= 101
		      ,@err_msg	= 'The filename field is a required field and cannot be blank. Please review the filename field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
		GOTO LOG_ERROR
	END

IF @file_extension = ''
	BEGIN
		SELECT @err_num	= 102
		      ,@err_msg	= 'The file_extension field is a required field and cannot be blank. Please review the file_extension field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
		GOTO LOG_ERROR
	END

IF @export_folder = ''
	BEGIN
		SELECT @err_num	= 103
		      ,@err_msg	= 'The export_folder field is a required field and cannot be blank. Please review the export_folder field, for the Method_Name, ' + @method_name + ', in the fw.Catalog table.'
		GOTO LOG_ERROR
	END

IF @batch_folder = ''
	BEGIN
		SELECT @err_num	= 104
		      ,@err_msg	= 'The batch_folder field is a required field and cannot be blank. Please review the batch_folder field, for the server, ' + @server + ', in the dbo.Server table.'
		GOTO LOG_ERROR
	END

--***************************************************************************************************
-- Determine if the file should have a timestamp and what the format should be
--***************************************************************************************************
IF @datetime_stamp <> '' SELECT @datetime_stamp = @filename_delimiter + FORMAT(GETDATE(), @datetime_stamp)

SELECT @file_date = CASE WHEN @include_date = 'Yes' THEN CASE WHEN @file_date_format = 'YYYYMMDD' THEN @filename_delimiter + CONVERT(VARCHAR(10), GETDATE(), 112)
                                                              ELSE @filename_delimiter + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 102), '.',' ')
														  END
						 ELSE '' 
					END

SELECT @file_time = CASE WHEN @include_time = 'Yes' THEN CASE WHEN @file_date_format = 'HHMMSS' THEN @filename_delimiter + FORMAT(GETDATE(), 'hhmmss') 
                                                              ELSE @filename_delimiter + FORMAT(GETDATE(), 'hhmmss')
														  END
						 ELSE '' 
					END

--***************************************************************************************************
-- Determine if the file should include any art of the TCID or not
--***************************************************************************************************
SELECT @filename_prefix = CASE WHEN RIGHT(@tcid, 1) = '%' THEN LEFT(@tcid, LEN(@tcid) -1)
                               ELSE @tcid
						   END

SELECT @filename_prefix = CASE WHEN @method_name = 'InstamedLockbox' THEN @filename_delimiter + @filename_prefix
                               ELSE ''
						   END

--***************************************************************************************************
-- Build the file name with or without the time stamp
--***************************************************************************************************
IF @datetime_stamp = ''
	BEGIN
		SELECT @filename = @filename + @filename_prefix + @file_date + @file_time + @file_extension
	END
ELSE
	BEGIN
		SELECT @filename = @filename + @filename_prefix + @datetime_stamp + @file_extension
	END

--***************************************************************************************************
-- Build the fully qualified folder name
--***************************************************************************************************
SELECT @folder = CASE WHEN RIGHT(@export_folder, 1) = '\' THEN @export_folder 
                      ELSE @export_folder + '\' 
				  END

SELECT @folder = '\\' + @server + '\' + @batch_folder + '\' + @folder

--***************************************************************************************************
-- Build the fully qualified folder name
--***************************************************************************************************
LOG_ERROR:

END
GO