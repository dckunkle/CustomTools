<# ***************************************************************************************************
Purpose:    Used by Jenkins to invoke the File Creator with the parameters provided
Parameters: 
    
    url           - the URL of the target systems UI, used to determine the target database
    test_case     - the testcase(s) that the Data Creator will execute
    delete_data   - determines whether or not existing data should be deleted before creating the data
    email_address - the email address(es) where results will be sent
    build         - the build number from Jenkins, stored in the log for reference
    project_name  - name of the Jenkins project, stored in the log for reference


Date        User            Change
---------------------------------------------------------------------------------------------
05/11/2021	DK				Original script
06/21/2021  DK              Changed connection string to use batch credentials
07/19/2021  DK              Add logging server variable to quickly change SQL Server source
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$url,

    [Parameter(Mandatory=$True)]
    [string]$test_case,

    [Parameter(Mandatory=$True)]
    [string]$delete_data,
    
    [Parameter(Mandatory=$True)]
    [string]$email_address,

    [Parameter(Mandatory=$True)]
    [int]$build_number,

    [Parameter(Mandatory=$True)]
    [string]$job_name

)

#**************************************************************************************************
# Important variables
#**************************************************************************************************
$logging_server = "wqadbhpauto01"

#**************************************************************************************************
# Convert the passed in URL to a server name
#**************************************************************************************************
try
{

    $server_name = .\Jenkins\Powershell\Get-CoreServerFromUrl.ps1 -url $url
    $server_name = $server_name.Trim()
    Write-Host "["$server_name"]"

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the server name for the passed in URL: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Output the File Creator Preprocessor header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " PREPROCESSOR"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log ID---Date Time-------------Server Name----------Test Case--------------------------------Email Address------------------------------"


#**************************************************************************************************
# Configure the connection and run the File Creator Preprocessor
#**************************************************************************************************
try
{

    $PreprocessorConnection = New-Object System.Data.SqlClient.SqlConnection
    #$PreprocessorConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;Trusted_Connection=True;"
    $PreprocessorConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $PreprocessorConnection.Open()
  
    $PreprocessorCommand = New-Object System.Data.SqlClient.SqlCommand
    $PreprocessorCommand.Connection = $PreprocessorConnection
    $PreprocessorCommand.CommandText = "EXEC spFCAuto_Preprocessor '" + $test_case + "', '" + $server_name + "','" + $build_number + "','" + $job_name + "'"
    $PreprocessorCommand.CommandTimeout = 0

    $PreprocessorReader = $PreprocessorCommand.ExecuteReader() 

    #Cleanup
    $PreprocessorReader.Close()
    $PreprocessorCommand.Dispose()
    $PreprocessorConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to run the File Creator Preprocessor: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Determine the log id that was created and output the results of the File Creator Preprocessor run
#**************************************************************************************************
try
{
    $PreprocessorLogConnection = New-Object System.Data.SqlClient.SqlConnection
    $PreprocessorLogConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $PreprocessorLogConnection.Open()

    $PreprocessorLogCommand = New-Object System.Data.SqlClient.SqlCommand
    $PreprocessorLogCommand.Connection = $PreprocessorLogConnection
    $PreprocessorLogCommand.CommandText = "SELECT log_id FROM PPLog WITH (NOLOCK)WHERE build_id=" + $build_number + " AND job_name ='" + $job_name + "'"
    $PreprocessorLogReader = $PreprocessorLogCommand.ExecuteReader()

    while ($PreprocessorLogReader.Read())
    {
        $log_id = $PreprocessorLogReader.Item("log_id")
    }

    #Cleanup
    $PreprocessorLogReader.Close()
    $PreprocessorLogCommand.Dispose()
    $PreprocessorLogConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the File Creator Preprocessor log: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Output the header information to the Jenkins console
#**************************************************************************************************
$str_log_id      = $log_id.ToString().PadRight(8)
$date            = Get-Date -Format "MM/dd/yyyy HH:mm"
$date            = $date.ToString().PadRight(21)
$server_name     = $server_name.PadRight(20)
$test_case       = $test_case.PadRight(40)
$email_address   = $email_address.PadRight(40)


Write-Host "       " $str_log_id $date $server_name $test_case $email_address
Write-Host ""

#**************************************************************************************************
# Output the details of the File Creator Preprocessor run to the Jenkins Console
#**************************************************************************************************
.\Jenkins\Powershell\Output-FileCreatorPreprocessorLog.ps1 -server_name $server_name -log_id $log_id


#**************************************************************************************************
# Output the File Creator header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " FILE CREATOR"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log ID---Date Time-------------Server Name----------Test Case--------------------------------Email Address------------------------------"


#**************************************************************************************************
# Configure the connection and run the File Creator 
#**************************************************************************************************
try
{

    $FileCreatorConnection = New-Object System.Data.SqlClient.SqlConnection
    $FileCreatorConnection.ConnectionString = "Server=" + $logging_server + ";Database=CoreFileCreator;User ID=user;Password=password"
    $FileCreatorConnection.Open()
  
    $FileCreatorCommand = New-Object System.Data.SqlClient.SqlCommand
    $FileCreatorCommand.Connection = $FileCreatorConnection
    $FileCreatorCommand.CommandText = "EXEC spFCAuto_CreateFiles '" + $server_name + "', '" + $test_case + "','" + $email_address + "','" + $build_number + "','" + $job_name + "'"
    $FileCreatorCommand.CommandTimeout = 0

    $FileCreatorReader = $FileCreatorCommand.ExecuteReader() 

    #Cleanup
    $FileCreatorReader.Close()
    $FileCreatorCommand.Dispose()
    $FileCreatorConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to run the File Creator: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Determine the log id that was created and output the results of the File Creator run
#**************************************************************************************************
try
{
    $FileCreatorLogConnection = New-Object System.Data.SqlClient.SqlConnection
    $FileCreatorLogConnection.ConnectionString = "Server=" + $logging_server + ";Database=CoreFileCreator;User ID=user;Password=password"
    $FileCreatorLogConnection.Open()

    $FileCreatorLogCommand = New-Object System.Data.SqlClient.SqlCommand
    $FileCreatorLogCommand.Connection = $FileCreatorLogConnection
    $FileCreatorLogCommand.CommandText = "SELECT log_id FROM fw.FCLog WITH (NOLOCK)WHERE build_id=" + $build_number + " AND job_name ='" + $job_name + "'"
    $FileCreatorLogReader = $FileCreatorLogCommand.ExecuteReader()

    while ($FileCreatorLogReader.Read())
    {
        $log_id = $FileCreatorLogReader.Item("log_id")
    }

    #Cleanup
    $FileCreatorLogReader.Close() 
    $FileCreatorLogCommand.Dispose()
    $FileCreatorLogConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the File Creator log: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Output the File Creator header information to the Jenkins console
#**************************************************************************************************
$str_log_id      = $log_id.ToString().PadRight(8)
$date            = Get-Date -Format "yyyy/MM/dd HH:mm"
$date            = $date.ToString().PadRight(21)
$server_name     = $server_name.PadRight(20)
$test_case       = $test_case.PadRight(40)
$email_address   = $email_address.PadRight(40)


Write-Host "       " $str_log_id $date $server_name $test_case $email_address
Write-Host ""

#**************************************************************************************************
# Output the details of the File Creator run to the Jenkins Console
#**************************************************************************************************
.\Jenkins\Powershell\Output-FileCreatorLog.ps1 -server_name $server_name -log_id $log_id

#**************************************************************************************************
# Output the Data Deleter header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " DATA DELETER"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log ID---Date Time-------------Server Name----------Test Case--------------------------------Email Address------------------------------"


#**************************************************************************************************
# Configure the connection and run the Data Deleter
#**************************************************************************************************
try
{

    $DataDeleterConnection = New-Object System.Data.SqlClient.SqlConnection
    $DataDeleterConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $DataDeleterConnection.Open()
  
    $DataDeleterCommand = New-Object System.Data.SqlClient.SqlCommand
    $DataDeleterCommand.Connection = $DataDeleterConnection
    $DataDeleterCommand.CommandText = "EXEC spFCAuto_DeleteData '" + $server_name + "', '" + $test_case + "','" + $delete_data + "','" + $email_address + "','" + $build_number + "','" + $job_name + "'"
    $DataDeleterCommand.CommandTimeout = 0

    $DataDeleterReader = $DataDeleterCommand.ExecuteReader() 

    #Cleanup
    $DataDeleterReader.Close()
    $DataDeleterCommand.Dispose()
    $DataDeleterConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to run the Data Deleter: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Determine the log id that was created and output the results of the Data Deleter run
#**************************************************************************************************
try
{
    $DataDeleterLogConnection = New-Object System.Data.SqlClient.SqlConnection
    $DataDeleterLogConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $DataDeleterLogConnection.Open()

    $DataDeleterLogCommand = New-Object System.Data.SqlClient.SqlCommand
    $DataDeleterLogCommand.Connection = $DataDeleterLogConnection
    $DataDeleterLogCommand.CommandText = "SELECT log_id FROM FDLog WITH (NOLOCK)WHERE build_id=" + $build_number + " AND job_name ='" + $job_name + "'"
    $DataDeleterLogReader = $DataDeleterLogCommand.ExecuteReader()

    while ($DataDeleterLogReader.Read())
    {
        $log_id = $DataDeleterLogReader.Item("log_id")
    }

    #Cleanup
    $DataDeleterLogReader.Close()
    $DataDeleterLogCommand.Dispose()
    $DataDeleterLogConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the Data Deleter log: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Run the Post Processor
#**************************************************************************************************
try
{

    $PostProcessorConnection = New-Object System.Data.SqlClient.SqlConnection
    $PostProcessorConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $PostProcessorConnection.Open()
  
    $PostProcessorCommand = New-Object System.Data.SqlClient.SqlCommand
    $PostProcessorCommand.Connection = $PostProcessorConnection
    $PostProcessorCommand.CommandText = "EXEC spFCAuto_Postprocessor '" + $test_case + "', '" + $server_name + "','" + $build_number + "','" + $job_name + "'"
    $PostProcessorCommand.CommandTimeout = 0

    $PostProcessorReader = $PostProcessorCommand.ExecuteReader() 

    #Cleanup
    $PostProcessorReader.Close()
    $PostProcessorCommand.Dispose()
    $PostProcessorConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to run the Post Processor: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Output the Data Deleter header information to the Jenkins console
#**************************************************************************************************
$str_log_id      = $log_id.ToString().PadRight(8)
$date            = Get-Date -Format "yyyy/MM/dd HH:mm"
$date            = $date.ToString().PadRight(21)
$server_name     = $server_name.PadRight(20)
$test_case       = $test_case.PadRight(40)
$email_address   = $email_address.PadRight(40)


Write-Host "       " $str_log_id $date $server_name $test_case $email_address
Write-Host ""

#**************************************************************************************************
# Output the details of the File Creator run to the Jenkins Console
#**************************************************************************************************
.\Jenkins\Powershell\Output-FileCreatorDataDeleterLog.ps1 -server_name $server_name -log_id $log_id
