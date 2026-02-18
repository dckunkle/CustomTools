<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        07/25/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will delete data in the Identifi Member database given a list of member IDs or 
        member ID patterns

    
    .DESCRIPTION

        Given a file name pattern, this script will delete all of the files in the Identifi Member
        database that match the pattern provided.

    
    .PARAMETER Application

        Specify the name of the application that the data is associated with (e.g. Identifi Member)


    .PARAMETER TargetUrl

        Specify the URL that represents the environment the data is in (e.g. [109] https://qr09-qa.core.valence.care/)


    .PARAMETER MemberIdList

        Specify a list of member IDs to cleanup. Can use a delimited list and/or wildcrad character %


    .PARAMETER Email

        Specify the email address to send the results to


    .PARAMETER BuildId

        Specify the Jenkins build ID


    .PARAMETER JobName

        Specify the Jenkins job name


    EXAMPLE
    .\Delete-IMDataMemberList.ps1 -Application "IdentifiMember" -TargetUrl "[109] https://qr09-qa.core.valence.care/" -MemberIdList "EB-2500%" 

#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Application = 'IdentifiMember',

    [Parameter(Mandatory=$True)]
    [string]$TargetUrl,

    [Parameter(Mandatory=$True)]
    [string]$MemberIdList,

    [Parameter(Mandatory=$False)]
    [string]$Email,

    [Parameter(Mandatory=$False)]
    [string]$BuildId,

    [Parameter(Mandatory=$False)]
    [string]$JobName
)

#**************************************************************************************************
# Get the Environment ID from the Target URL
#**************************************************************************************************
if ($TargetUrl.Substring(0,1) = "[")
{
    $from     = $TargetUrl.IndexOf("]") + 2
    $to       = $TargetUrl.Length - $from
    $url_only = $TargetUrl.Substring($from,$to)
}
else
{
    $url_only = $TargetUrl
}

#**************************************************************************************************
# Connect to the automation server and get the target server name for logging
#**************************************************************************************************
try
{
    $system_connection = New-Object System.Data.SqlClient.SqlConnection
    $system_connection.ConnectionString = "Server=wqadbhpauto01;Database=SystemAudit;Trusted_Connection=True;"
    $system_connection.Open()

    $server_command = New-Object System.Data.SqlClient.SqlCommand
    $server_command.Connection = $system_connection
    $server_command.CommandText = "SELECT instance_name FROM Server WITH (NOLOCK) WHERE system_url = '" + $url_only + "'"
    $server_reader = $server_command.ExecuteReader()

    while ($server_reader.Read())
    {
        $log_server = $server_reader.Item("instance_name")
        $log_server = $log_server.Trim()
    }

    #Cleanup
    $server_reader.Close()
    $server_command.Dispose()
    $system_connection.Dispose()
}
catch
{
    Write-Host $_
}

#**************************************************************************************************
# Create the log that will be used to log deleted data
#**************************************************************************************************
try
{
    $entity_type = 'Member'

    $log_connection = New-Object System.Data.SqlClient.SqlConnection
    $log_connection.ConnectionString = "Server=" + $log_server + ";Database=QA;Trusted_Connection=True;"
    $log_connection.Open()

    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $log_command.CommandText = "dbo.spDDAuto_CreateLog"
    $log_command.Connection  = $log_connection

    $log_command.Parameters.AddWithValue("@entity_to_delete", $MemberIdList)  >> $null
    $log_command.Parameters.AddWithValue("@entity_type",      $entity_type)   >> $null
    $log_command.Parameters.AddWithValue("@email_address",    $Email)         >> $null
    $log_command.Parameters.AddWithValue("@build_id",         $BuildId)       >> $null
    $log_command.Parameters.AddWithValue("@job_name",         $JobName)       >> $null

    # Add the output parmeter @log_id
    $log_parameter = New-Object System.Data.SqlClient.SqlParameter
    $log_parameter.ParameterName = "@log_id"
    $log_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $log_parameter.DbType = [System.Data.DBType]'Int16'

    $log_command.Parameters.Add($log_parameter) >> $null

    $log_command.ExecuteNonQuery() >> $null
    $log_id = $log_command.Parameters["@log_id"].Value

    $log_command.Dispose()

}
catch
{
    Write-Host $_
}
Write-Host $log_id
#**************************************************************************************************
# Output the Data Creator header to the Jenkins console
#**************************************************************************************************
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " DATA DELETER - IM MEMBER ID"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       -Log---Date Time----------Server Name----------Member IDs--------------------------------------------------------------------------------"

#**************************************************************************************************
# Output the header information to the Jenkins console
#**************************************************************************************************
$pad_log_id          = $log_id.ToString().PadRight(5).Substring(0,5)
$date                = Get-Date -Format "yyyy/MM/dd HH:mm"
$date                = $date.ToString().PadRight(18).Substring(0,18)
$pad_server_name     = $log_server.PadRight(20).Substring(0.20)
$pad_member_list     = $MemberIdList.PadRight(90).Substring(0,90)

Write-Host "       " $pad_log_id $date $pad_server_name $pad_member_list
Write-Host ""

#**************************************************************************************************
# Collect connection data for the target database
#**************************************************************************************************
try
{
    $file_creator_connection = New-Object System.Data.SqlClient.SqlConnection
    $file_creator_connection.ConnectionString = "Server=wqadbhpauto01;Database=CoreFileCreator;Trusted_Connection=True;"
    $file_creator_connection.Open()

    $target_command = New-Object System.Data.SqlClient.SqlCommand
    $target_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $target_command.CommandText = "dbo.spFCAuto_GetDatabaseDetails"
    $target_command.Connection  = $file_creator_connection

    $target_command.Parameters.AddWithValue("@application", $Application)  >> $null
    $target_command.Parameters.AddWithValue("@url",         $TargetUrl)    >> $null

    $target_reader = $target_command.ExecuteReader()

    if ($target_reader.HasRows)
    {
        $target_reader.Read() >> $null

        $server_name   = $target_reader.Item("server_name")
        $client_key    = $target_reader.Item("client_key")
        $database_name = $target_reader.Item("database_name")
        $user_id       = $target_reader.Item("user_id")
        $password      = $target_reader.Item("password")
    }

    $target_reader.Close()
    $target_command.Dispose()
    $file_creator_connection.Close()

}
catch
{
    Write-Host $_
}

#**************************************************************************************************
# Loop through the Member ID List and delete each member ID
#**************************************************************************************************
$member_ids = $MemberIdList.Split(";")

foreach ($member_id in $member_ids)
{
    .\DataDeleter\PowerShell\Delete-IMDataMember.ps1 -Server $server_name -MemberId $member_id -ClientKey $client_key -Database $database_name -UserId $user_id -Password $password -LogId $log_id -LogServer $log_server
}

#**************************************************************************************************
# Complete logging
#**************************************************************************************************
try
{
    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $log_command.CommandText = "dbo.spDDAuto_LogEventFinish"
    $log_command.Connection  = $log_connection

    $log_command.Parameters.AddWithValue("@log_id", $log_id) >> $null
    $log_command.ExecuteNonQuery() >> $null

    $log_command.Dispose()
    $log_connection.Close()

}
catch
{
    Write-Host $_
}
#**************************************************************************************************
# Output log data to the Console Output
#**************************************************************************************************
.\DataDeleter\PowerShell\Output-IMDataMemberLog.ps1 -Server $log_server -LogId $log_id

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " "
Write-Host " "