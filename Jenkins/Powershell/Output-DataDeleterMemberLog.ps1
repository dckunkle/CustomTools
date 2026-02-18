<# ***************************************************************************************************
Purpose:    Output Data Deleter Member log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Deleter log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/20/2021	DK				Original script
05/27/2021  DK              Added handling for NULLs in log
06/21/2021  DK              Changed connection string to use batch credentials
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$server_name,

    [Parameter(Mandatory=$True)]
    [int]$log_id
)

$detail_records = $false
$total_records = 0

#Create the connection to the proper server
$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
$SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
$SQLCommand.Connection = $SQLConnection
$SQLCommand.CommandText = "SELECT * FROM DDLogDetail WHERE log_id=" + $log_id + " ORDER BY log_sid"
$SQLCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the Data Deleter detail header
#**************************************************************************************************
Write-Host ""
Write-Host "       -Table Name--------------------------------------------------------------------Records--Error Message------------------------------------"

try
{
    #Try opening the connection to the database
    $SQLConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $SQLReader = $SQLCommand.ExecuteReader()

    while ($SQLReader.Read())
    {
        $detail_records = $true
        $records        = $SQLReader.Item("record_count")

        $total_records = $total_records + $records

        $table_name     = $SQLReader.Item("table_name")
        if ($table_name -ne [DBNull]::Value) {
        $table_name     = $table_name.PadRight(77).Substring(0,77)}

        $records        = $records.ToString()
        if ($records -ne [DBNull]::Value) {
        $records        = $records.PadLeft(7).Substring(0,7)}

        $status         = $SQLReader.Item("status")
        $err_num        = $SQLReader.Item("err_num")
        $err_msg        = $SQLReader.Item("err_msg")

        $status         = Switch ($err_num)
        {
            "0"   {""                ;break}
            Default {$err_msg}
        }

        $status        = $status.PadRight(30).Substring(0,30)

        Write-Host "       " $table_name $records  $status

    }

    if (-not($detail_records))
    {
        Write-Host ""
        Write-Host "          No records found to delete"
        Write-Host ""
    }


    Write-Host "       -----------------------------------------------------------------------------------------------------------------------------------------"

    if ($detail_records)
    {
        $total_records = $total_records.ToString().PadLeft(8)
        Write-Host "                                                                      Total Records:" $total_records
    }

    Write-Host ""

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host "There was an error while trying to output the log: " $Error[0]
    Exit 1
}

#Cleanup
$SQLCommand.Dispose()
$SQLConnection.Dispose()