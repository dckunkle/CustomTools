<# ***************************************************************************************************
Purpose:    Output File Validator log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Creator log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/18/2021	DK				Original script
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

#Create the connection to the proper server
$TestCaseConnection = New-Object System.Data.SqlClient.SqlConnection
$TestCaseConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"

$TestCaseCommand = New-Object System.Data.SqlClient.SqlCommand
$TestCaseCommand.Connection = $TestCaseConnection
$TestCaseCommand.CommandText = "SELECT * FROM FVLogTestCase WHERE log_id=" + $log_id + " ORDER BY log_id"
$TestCaseCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the File Validator header
#**************************************************************************************************

try
{
    #Try opening the connection to the database
    $TestCaseConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $TestCaseReader = $TestCaseCommand.ExecuteReader()

    while ($TestCaseReader.Read())
    {

        #Output the test case header
        Write-Host ""
        Write-Host "-Method----------------------------------------------TCID--------------------------------------Record ID----------------------------------------------------"

        #Get the information about the test case being validated
        $method        = $TestCaseReader.Item("method")
        if ($method -ne [DBNull]::Value) {
        $method        = " " + $method.PadRight(52).Substring(0,52)}

        $TCID          = $TestCaseReader.Item("TCID")
        if ($TCID -ne [DBNull]::Value) {
        $TCID          = $TCID.PadRight(42).Substring(0,42)}

        $record_id     = $TestCaseReader.Item("record_id")
        if ($record_id -ne [DBNull]::Value) {
        $record_id     = $record_id.ToString().PadRight(15).Substring(0,15)}

        $search_keys   = $TestCaseReader.Item("search_keys")
        $array_keys    = $search_keys.Split("~")

        $search_values = $TestCaseReader.Item("search_values")
        $array_values  = $search_values.Split("~")

        $core_sid      = $TestCaseReader.Item("core_sid").ToString()

        $tc_log_id     = $TestCaseReader.Item("tc_log_id")

        $line          = "-"

        #Output the test case details
        Write-Host $method$TCID$record_id
        
        #Output a line after the test case information
        Write-Host $line.PadRight(156,"-")
        Write-Host ""
        Write-Host "    Matching Criteria"

        #Loop through the matching criteria and output to the console
        $count = 0

        ForEach($key In $array_keys)
        {

            $key = "      " + $key + ":"
            $key = $key.PadRight(43) + $array_values[$count]
            Write-Host $key

            $count = $count + 1
        }
        Write-Host "      core_sid:                           "$core_sid
        Write-Host " "
        Write-Host " "

        #Output the header for the validation details
        Write-Host "    Field Validations"
        Write-Host "      -Status-File Field------------------------File Value--------------------Core Field------------------------Core Value--------------------Default-------"

        #Open a reader for the validation details
        $ValidationConnection = New-Object System.Data.SqlClient.SqlConnection
        $ValidationConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
        $ValidationConnection.Open()

        $ValidationCommand = New-Object System.Data.SqlClient.SqlCommand
        $ValidationCommand.Connection = $ValidationConnection
        $ValidationCommand.CommandTimeout = 0
        $ValidationCommand.CommandText = "SELECT * FROM FVLogTestCaseValidation WHERE tc_log_id=" + $tc_log_id + " ORDER BY log_sid"

        $ValidationReader = $ValidationCommand.ExecuteReader()
                
        while ($ValidationReader.Read())
        {
            $status      = $ValidationReader.Item('status')
            $status      = Switch($status)
                           {
                                "Pass-Defaulted" {"Def";break}
                                Default{$status}
                           }
            $status      = "       " + $status.PadRight(6)

            $file_field  = $ValidationReader.Item('file_field')
            if ($file_field -ne [DBNull]::Value) {
            $file_field  = $file_field.PadRight(33).Substring(0,33)}
            else {$file_field = " " * 33 }

            $file_value  = $ValidationReader.Item('file_value')
            if ($file_value -ne [DBNull]::Value) {
            $file_value  = $file_value.PadRight(29).Substring(0,29)}
            else {$file_value = " " * 29 }

            $core_field  = $ValidationReader.Item('core_field')
            if ($core_field -ne [DBNull]::Value) {
            $core_field  = $core_field.PadRight(33).Substring(0,33)}
            else {$core_field = " " * 33 }

            $core_value  = $ValidationReader.Item('core_value')
            if ($core_value -ne [DBNull]::Value) {
            $core_value  = $core_value.PadRight(29).Substring(0,29)}
            else {$core_value = " " * 29 }

            $default_value  = $ValidationReader.Item('default_value')
            if ($default_value -ne [DBNull]::Value) {
            $default_value  = $default_value.PadRight(14).Substring(0,14)}

            Write-Host $status $file_field $file_value $core_field $core_value $default_value
        }

        #Output the footer for the validation details
        Write-Host "      ------------------------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host " "
        Write-Host " "
        Write-Host " "

        #Cleanup validation details so it can be reused
        $ValidationReader.Close()
        $ValidationReader.Dispose()
        $ValidationCommand.Dispose()
        $ValidationConnection.Close()
        $ValidationConnection.Dispose()

    }

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host "There was an error while trying to output the log: " $Error[0]
    Exit 1
}

#Cleanup
$TestCaseReader.Close()
$TestCaseReader.Dispose()
$TestCaseCommand.Dispose()
$TestCaseConnection.Close()
