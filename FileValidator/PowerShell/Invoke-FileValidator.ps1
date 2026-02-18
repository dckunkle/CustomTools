<# ***************************************************************************************************
Purpose:    Used by Jenkins to invoke the File Validator with the parameters provided
Parameters: 
    
    url           - the URL of the target systems UI, used to determine the target database
    test_case     - the testcase(s) that the File Validator will execute
    email_address - the email address(es) where results will be sent
    build         - the build number from Jenkins, stored in the log for reference
    project_name  - name of the Jenkins project, stored in the log for reference


Date        User            Change
---------------------------------------------------------------------------------------------
05/18/2021	DK				Original script
06/21/2021  DK              Changed connection string to use batch credentials
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$url,

    [Parameter(Mandatory=$True)]
    [string]$test_case,
    
    [Parameter(Mandatory=$True)]
    [string]$email_address,

    [Parameter(Mandatory=$True)]
    [int]$build_number,

    [Parameter(Mandatory=$True)]
    [string]$job_name

)

#**************************************************************************************************
# Output the File Validator header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " FILE VALIDATOR"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log ID---Date Time-------------Server Name----------Test Case--------------------------------Email Address------------------------------"

#**************************************************************************************************
# Convert the passed in URL to a server name
#**************************************************************************************************
try
{

    $server_name = .\Common\PowerShell\Get-CoreServerFromUrl.ps1 -url $url

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the server name for the passed in URL: " $Error[0]
    Exit 1
}
#**************************************************************************************************
# Configure the connection and run the File Validator
#**************************************************************************************************
try
{

    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $SQLConnection.Open()
  
    $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
    $SQLCommand.Connection = $SQLConnection
    $SQLCommand.CommandText = "EXEC spFVAuto_ValidateTestCases '" + $test_case + "', '" + $email_address + "','" + $build_number + "','" + $job_name + "'"
    $SQLCommand.CommandTimeout = 0

    $SQLReader = $SQLCommand.ExecuteReader() 

    #Cleanup
    $SQLReader.Close()
    $SQLCommand.Dispose()
    $SQLConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to run the File Validator: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Determine the log id that was created and output the results of the File Validator run
#**************************************************************************************************
try
{
    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
    $SQLConnection.Open()

    $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
    $SQLCommand.Connection = $SQLConnection
    $SQLCommand.CommandText = "SELECT log_id FROM FVLog WITH (NOLOCK)WHERE build_id=" + $build_number + " AND job_name ='" + $job_name + "'"
    $SQLReader = $SQLCommand.ExecuteReader()

    while ($SQLReader.Read())
    {
        $log_id = $SQLReader.Item("log_id")
    }

    #Cleanup
    $SQLReader.Close()
    $SQLCommand.Dispose()
    $SQLConnection.Dispose()
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the File Validator log: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Output the header information to the Jenkins console
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
# Output the details of the Data Creator run to the Jenkins Console
#**************************************************************************************************
./FileValidator/PowerShell/Output-FileValidatorLog.ps1 -server_name $server_name -log_id $log_id

#Cleanup
$SQLCommand.Dispose()
$SQLConnection.Dispose()
