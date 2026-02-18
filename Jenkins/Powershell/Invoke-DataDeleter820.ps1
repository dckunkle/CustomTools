<# ***************************************************************************************************
Purpose:    Used by Jenkins to invoke the Data Deleter (820) with the parameters provided
Parameters: 
    
    url           - the URL of the target systems UI, used to determine the target database
    user_id       - the user id that will be deleted. All data created by this user will be targeted
    email_address - the email address(es) where results will be sent
    build         - the build number from Jenkins, stored in the log for reference
    project_name  - name of the Jenkins project, stored in the log for reference


Date        User            Change
--------------------------------------------------------------------------------------------
12/08/2021	DK				Original script

---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$url,

    [Parameter()]
    [string]$filename,
    
    [Parameter()]
    [string]$test_case,

    [Parameter(Mandatory=$True)]
    [string]$action,

    [Parameter()]
    [string]$email_address,

    [Parameter(Mandatory=$True)]
    [int]$build_number,

    [Parameter(Mandatory=$True)]
    [string]$job_name

)

$log_id = 0
$detail_records = $false
$eoc_records = "No"

if ($filename.Length -eq 0)      {$filename = ""}
if ($test_case.Length -eq 0)     {$test_case = ""}
if ($email_address.Length -eq 0) {$email_address = ""}


#**************************************************************************************************
# Output the Data Creator header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " DATA DELETER - 820"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log---Date Time----------Server Name----------Action----------Test Case---------------------------Filename------------------------------"
 
#**************************************************************************************************
# Convert the passed in URL to a server name
#**************************************************************************************************
try
{

    $server_name = .\jenkins\powershell\Get-CoreServerFromUrl.ps1 -url $url
    
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the server name for the passed in URL: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Configure the connection and run the Data Deleter, if necessary
#**************************************************************************************************
if ($action -ne "List Files")
{
    try
    {

        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
        $SQLConnection.Open()
  
        $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
        $SQLCommand.Connection = $SQLConnection
        $SQLCommand.CommandText = "EXEC spDDAuto_DeleteFileData820Wrapper  '" + $filename + "', '" + $test_case + "','" + $action + "','" + $email_address + "','" + $build_number + "','" + $job_name + "'"
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
        Write-Host "       There was an error while trying to run the Data Deleter: " $Error[0]
        Exit 1
    }

    #**************************************************************************************************
    # Determine the log id that was created and output the results of the Data Deleter run
    #**************************************************************************************************
    try
    {
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
        $SQLConnection.Open()

        $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
        $SQLCommand.Connection = $SQLConnection
        $SQLCommand.CommandText = "SELECT log_id FROM DDLog WITH (NOLOCK)WHERE build_id=" + $build_number + " AND job_name ='" + $job_name + "'"
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
        Write-Host "       There was an error while trying to get the Data Deleter log: " $Error[0]
        Exit 1
    }

}

#**************************************************************************************************
# Output the header information to the Jenkins console
#**************************************************************************************************
$pad_log_id          = $log_id.ToString().PadRight(5).Substring(0,5)
$date                = Get-Date -Format "yyyy/MM/dd HH:mm"
$date                = $date.ToString().PadRight(18).Substring(0,18)
$pad_server_name     = $server_name.PadRight(20).Substring(0.20)
$pad_action          = $action.PadRight(15).Substring(0,15)
$pad_test_case       = $test_case.PadRight(35).Substring(0,35)
$pad_filename        = $filename.PadRight(38).Substring(0,38)
$pad_email_address   = $email_address.PadRight(30).Substring(0,30)


Write-Host "       " $pad_log_id $date $pad_server_name $pad_action $pad_test_case $pad_filename 
Write-Host ""

#**************************************************************************************************
# List Files if the user selected to only list the files
#**************************************************************************************************

if ($action -eq "List Files")
{
    Write-Host ""
    Write-Host "       -Filename--------------------------------------------------------------------------------------------------File Date---------------------"

    try
    {
        $FilesConnection = New-Object System.Data.SqlClient.SqlConnection
        $FilesConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
        $FilesConnection.Open()

        $FilesCommand = New-Object System.Data.SqlClient.SqlCommand
        $FilesCommand.Connection = $FilesConnection
        $FilesCommand.CommandText = "SELECT DISTINCT TOP 50 file_name, CONVERT(VARCHAR(10), MAX(date_process_start), 101) AS str_file_date, MAX(date_process_start) AS file_date FROM File_Receive_Log WITH (NOLOCK) WHERE file_type = '820' GROUP BY file_name ORDER BY MAX(date_process_start) DESC"
        $FilesReader = $FilesCommand.ExecuteReader()

        while ($FilesReader.Read())
        {
            $detail_records = $true

            $file_name = $FilesReader.Item("file_name")
            if ($file_name -ne [DBNull]::Value) {
            $file_name = $file_name.PadRight(105).Substring(0,105)}

            $file_date = $FilesReader.Item("str_file_date")
            if ($file_date -ne [DBNull]::Value) {
            $file_date = $file_date.PadRight(30).Substring(0,30)}

            Write-Host "       " $file_name $file_date
        }

        Write-Host ""

        #Cleanup
        $FilesReader.Close()
        $FilesCommand.Dispose()
        $FilesConnection.Dispose()
    }
    catch
    {
        #Let the user know something went wrong and fail the script
        Write-Host ""
        Write-Host "       There was an error while trying to list the files: " $Error[0]
        Exit 1
    }

    if (-NOT($detail_records))
    {
        Write-Host "          No 820 files have been loaded previously."
        Write-Host ""
    }

}
#**************************************************************************************************
# Output the details of the Data Creator run to the Jenkins Console
#**************************************************************************************************
if ($action -ne "List Files")
{
    .\jenkins\powershell\Output-DataDeleter820Log.ps1 -server_name $server_name -log_id $log_id
}

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " "
Write-Host " "

