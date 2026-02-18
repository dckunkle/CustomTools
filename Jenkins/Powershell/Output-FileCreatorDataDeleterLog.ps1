<# ***************************************************************************************************
Purpose:    Output File Deleter log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Creator log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/24/2021	DK				Original script
05/27/2021  DK              Added code to handle NULLs
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

$type_records = $false

#Create the connection to the proper server
$TypeConnection = New-Object System.Data.SqlClient.SqlConnection
$TypeConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"

$TypeCommand = New-Object System.Data.SqlClient.SqlCommand
$TypeCommand.Connection = $TypeConnection
$TypeCommand.CommandText = "SELECT * FROM FDLogType WHERE log_id=" + $log_id + " ORDER BY log_id"
$TypeCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the File Deleter detail header
#**************************************************************************************************

try
{
    #Try opening the connection to the database
    $TypeConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $TypeReader = $TypeCommand.ExecuteReader()

    while ($TypeReader.Read())
    {

        $type_records = $true
        $detail_records = $false

        #Output the test case header
        Write-Host ""
        Write-Host "        -Type-------Name----------------------Data---Table Name--------------------------------------------------Records------------------------"

        #Get the information about the test case being validated
        $type_id        = $TypeReader.Item("type_id")

        $delete_type   = $TypeReader.Item("delete_type")
        if ($delete_type -ne [DBNull]::Value) {
        $delete_type   = $delete_type.PadRight(10).Substring(0,10)}

        $delete_name   = $TypeReader.Item("delete_name")
        if ($delete_name -ne [DBNull]::Value) {
        $delete_name   = $delete_name.PadRight(25).Substring(0,25)}

        $delete_data   = $TypeReader.Item("delete_data")
        if ($delete_data -ne [DBNull]::Value) {
        $delete_data   = $delete_data.PadRight(6).Substring(0,6)}

        #Output the type details
        Write-Host "        " $delete_type $delete_name $delete_data
        
        #Open a reader for the validation details
        $TypeDetailConnection = New-Object System.Data.SqlClient.SqlConnection
        $TypeDetailConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
        $TypeDetailConnection.Open()

        $TypeDetailCommand = New-Object System.Data.SqlClient.SqlCommand
        $TypeDetailCommand.Connection = $TypeDetailConnection
        $TypeDetailCommand.CommandTimeout = 0
        $TypeDetailCommand.CommandText = "SELECT * FROM FDLogTypeDetail WHERE type_id =" + $type_id + " ORDER BY record_id"

        $TypeDetailReader = $TypeDetailCommand.ExecuteReader()
                
        while ($TypeDetailReader.Read())
        {
            $detail_records = $true

            $table_name    = $TypeDetailReader.Item('table_name')
            if ($table_name -ne [DBNull]::Value) {
            $table_name    = $table_name.PadRight(59).Substring(0,59)}

            $record_count  = $TypeDetailReader.Item('record_count').ToString()
            if ($record_count -ne [DBNull]::Value) {
            $record_count  = $record_count.PadRight(10).Substring(0,10)}

            $status      = $TypeDetailReader.Item('status')
            $err_num     = $TypeDetailReader.Item('err_num')
            $err_msg     = $TypeDetailReader.Item('err_msg')

            if ($status -eq "Error")
            {
                $table_name = $err_msg
            }

            Write-Host "                                                    " $table_name $record_count
        }

        if ($detail_records -eq $false)
        {
            Write-Host "                                                     No data found to delete"
        }
        #Cleanup validation details so it can be reused
        $TypeDetailReader.Close()
        $TypeDetailReader.Dispose()
        $TypeDetailCommand.Dispose()
        $TypeDetailConnection.Close()
        $TypeDetailConnection.Dispose()

    }

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host "There was an error while trying to output the log: " $Error[0]
    Exit 1
}

if ($type_records -eq $false)
{

    Write-Host "           No data found to delete" 

}
#Display the File Deleter footer
Write-Host ""
Write-Host "        ----------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""

#Cleanup
$TypeReader.Close()
$TypeReader.Dispose()
$TypeCommand.Dispose()
$TypeConnection.Close()
