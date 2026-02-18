<# ***************************************************************************************************
Purpose:    Used by Jenkins to invoke the Data Deleter (Member Conversion) with the parameters provided
Parameters: 
    
    url           - the URL of the target systems UI, used to determine the target database
    user_id       - the user id that will be deleted. All data created by this user will be targeted
    email_address - the email address(es) where results will be sent
    build         - the build number from Jenkins, stored in the log for reference
    project_name  - name of the Jenkins project, stored in the log for reference


Date        User            Change
--------------------------------------------------------------------------------------------
05/11/2021	DK				Original script
06/21/2021  DK              Changed connection string to use batch credentials
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$url,

    [Parameter()]
    [string]$filename,

    [Parameter(Mandatory=$True)]
    [string]$list_files,
    
    [Parameter(Mandatory=$True)]
    [string]$email_address,

    [Parameter(Mandatory=$True)]
    [int]$build_number,

    [Parameter(Mandatory=$True)]
    [string]$job_name

)

$log_id = 0
$detail_records = $false

#**************************************************************************************************
# Output the Data Creator header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " DATA DELETER - MEMBER"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log ID---Date Time-------------Server Name----------Filename-------------------------------List--Email Address--------------------------"

#**************************************************************************************************
# Convert the passed in URL to a server name
#**************************************************************************************************
try
{

    $server_name = .\jenkins\powershell\Get-CoreServerFromUrl.ps1 -url $url
    #$server_name = .\Get-CoreServerFromUrl.ps1 -url $url
    
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the server name for the passed in URL: " $Error[0]
    Exit 1
}

#**************************************************************************************************
# Configure the connection and run the Data Deleter
#**************************************************************************************************
if ($list_files -eq "No")
{

    try
    {

        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
        $SQLConnection.Open()
  
        $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
        $SQLCommand.Connection = $SQLConnection
        $SQLCommand.CommandText = "EXEC spDDAuto_DeleteFileData  '" + $filename + "', 'false','" + $email_address + "','" + $build_number + "','" + $job_name + "'"
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
        $SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
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
        Write-Host "       There was an error while trying to get the Data Creator log: " $Error[0]
        Exit 1
    }

}

#**************************************************************************************************
# Output the header information to the Jenkins console
#**************************************************************************************************
$pad_log_id        = $log_id.ToString().PadRight(8)
$date              = Get-Date -Format "yyyy/MM/dd HH:mm"
$date              = $date.ToString().PadRight(21)
$pad_server_name   = $server_name.PadRight(20)
$pad_filename      = $filename.PadRight(38)
$pad_list_files    = $list_files.PadRight(5)
$pad_email_address = $email_address.PadRight(40)


Write-Host "       " $pad_log_id $date $pad_server_name $pad_filename $pad_list_files $pad_email_address
Write-Host ""

#**************************************************************************************************
# List Files if the user selected to only list the files
#**************************************************************************************************

if ($list_files -eq "Yes")
{
    Write-Host ""
    Write-Host "       -Filename--------------------------------------------------------------------------------------------------File Date---------------------"

    try
    {
        $FilesConnection = New-Object System.Data.SqlClient.SqlConnection
        $FilesConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
        $FilesConnection.Open()

        $FilesCommand = New-Object System.Data.SqlClient.SqlCommand
        $FilesCommand.Connection = $FilesConnection
        $FilesCommand.CommandText = "SELECT DISTINCT TOP 50 file_name, CONVERT(VARCHAR(10), file_date, 101) AS str_file_date, file_date FROM Elig_Load_Run_Log WITH (NOLOCK) WHERE record_status = 'A' ORDER BY file_date DESC"
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
        Write-Host "          No eligibility files were found to delete."
        Write-Host ""
    }

}

#**************************************************************************************************
# Output the details of the Data Creator run to the Jenkins Console
#**************************************************************************************************
if ($list_files -eq "No")
{
    .\jenkins\powershell\Output-DataDeleterMemberLog.ps1 -server_name $server_name -log_id $log_id
    #.\Output-DataDeleterMemberLog.ps1 -server_name $server_name -log_id $log_id
}

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " "
Write-Host " "


