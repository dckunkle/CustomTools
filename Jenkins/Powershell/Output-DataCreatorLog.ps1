<# ***************************************************************************************************
Purpose:    Output Data Creator log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Creator log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/11/2021	DK				Original script
05/27/2021  DK              Added special handling for NULLs in the log
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$server_name,

    [Parameter(Mandatory=$True)]
    [int]$log_id
)

#Create the connection to the proper server
$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
$SQLConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;Trusted_Connection=True;"

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
$SQLCommand.Connection = $SQLConnection
$SQLCommand.CommandText = "SELECT * FROM DCLogDetail WHERE log_id=" + $log_id + " ORDER BY log_sid"
$SQLCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the Data Creator detail header
#**************************************************************************************************
Write-Host ""
Write-Host "       -Test Case-----------Method--------------Record ID-Key1------------------------Key2------------------------Error Message-----------------"

try
{
    #Try opening the connection to the database
    $SQLConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $SQLReader = $SQLCommand.ExecuteReader()

    while ($SQLReader.Read())
    {

        $test_case     = $SQLReader.Item("testcase")
        if ($test_case -ne [DBNull]::Value) {
        $test_case     = $test_case.PadRight(19).Substring(0,19)}

        $method        = $SQLReader.Item("method")
        if ($method -ne [DBNull]::Value) {
        $method        = $method.PadRight(19).Substring(0,19)}

        $key1          = $SQLReader.Item("key_data_1")
        if ($key1 -ne [DBNull]::Value) { 
        $key1          = $key1.PadRight(27).Substring(0,27)}

        $key2          = $SQLReader.Item("key_data_2")
        if ($key2 -ne [DBNull]::Value){
        $key2          = $key2.PadRight(27).Substring(0,27)}

        $record_id     = $SQLReader.Item("record_id").ToString()
        if ($key2 -ne [DBNull]::Value){
        $record_id_str = $record_id.PadRight(9).Substring(0,9)}

        $status        = $SQLReader.Item("status")
        $err_num       = $SQLReader.Item("err_num").ToString()
        $err_msg       = $SQLReader.Item("err_msg")
        if ($err_msg -eq [DBNull]::Value) {
        $err_msg       = "" }

        $status        = Switch ($status)
        {
            "Add"   {""                ;break}
            "Skip"  {"Record skipped." ;break}
            "Error" {$err_num + ": " + $err_msg ;break}
            Default {"Unknown"}
        }
        $status        = $status.PadRight(30).Substring(0,30)

        Write-Host "       " $test_case $method $record_id_str $key1 $key2 $status

    }

    Write-Host "       -----------------------------------------------------------------------------------------------------------------------------------------"
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