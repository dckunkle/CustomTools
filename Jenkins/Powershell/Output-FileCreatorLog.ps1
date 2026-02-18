<# ***************************************************************************************************
Purpose:    Output File Creator log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Creator log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/21/2021	DK				Original script
05/27/2021  DK              Added code to handle NULLs from the database
06/21/2021  DK              Changed connection string to use batch credentials
07/19/2021  DK              Add logging server variable to quickly change SQL Server source
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$server_name,

    [Parameter(Mandatory=$True)]
    [int]$log_id
)

#**************************************************************************************************
# Important variables
#**************************************************************************************************
$logging_server = "wqadbhpauto01"


#Create the connection to the proper server
$FileCreatorLogConnection = New-Object System.Data.SqlClient.SqlConnection
$FileCreatorLogConnection.ConnectionString = "Server=" + $logging_server + ";Database=CoreFileCreator;User ID=user;Password=password"

$FileCreatorLogCommand = New-Object System.Data.SqlClient.SqlCommand
$FileCreatorLogCommand.Connection = $FileCreatorLogConnection
$FileCreatorLogCommand.CommandText = "SELECT * FROM fw.FCLogDetail WHERE log_id=" + $log_id + " ORDER BY log_id"
$FileCreatorLogCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the Data Creator detail header
#**************************************************************************************************

try
{
    #Try opening the connection to the database
    $FileCreatorLogConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $FileCreatorLogReader = $FileCreatorLogCommand.ExecuteReader()

    #Output the test case header
    Write-Host ""
    Write-Host "       -Method Name----------------------------------------Filename----------------------------Exp--Act--Folder---------------------------------"


    while ($FileCreatorLogReader.Read())
    {

        $status = $FileCreatorLogReader.Item("status")

        if ($status -ne "Success") {

            #Get the information about the test case being validated
            $method           = $FileCreatorLogReader.Item("method")
            $err_num          = $FileCreatorLogReader.Item("err_num")
            $err_msg          = $FileCreatorLogReader.Item("err_msg")

            #Output the test case details
            Write-Host "       " $method 
            Write-Host "         " $status":" $err_msg

        }else {

            #Get the information about the test case being validated
            $method           = $FileCreatorLogReader.Item("method")
            if ($method -ne [DBNull]::Value) {
            $method           = $method.PadRight(50).Substring(0,50)}

            $filename         = $FileCreatorLogReader.Item("filename")
            if ($filename -ne [DBNull]::Value) {
            $filename         = $filename.PadRight(35).Substring(0,35)}

            $expected_records = $FileCreatorLogReader.Item("expected_records").ToString()
            if ($expected_records -ne [DBNull]::Value) {
            $expected_records = $expected_records.PadRight(4).Substring(0,4)}

            $actual_records   = $FileCreatorLogReader.Item("actual_records").ToString()
            if ($actual_records -ne [DBNull]::Value) {
            $actual_records   = $actual_records.PadRight(4).Substring(0,4)}

            #Get the folder where the file was placed, but only show the most important portion after Batch
            $folder           = $FileCreatorLogReader.Item("folder")
            if ($folder -ne [DBNull]::Value)
            {

                if($folder.Substring(0,2) -ne "H:")
                {
                    $from         = $folder.IndexOf("BATCH") + 6
                    $to           = $folder.Length - $from
                    $folder       = $folder.Substring($from,$to)
                }

                $folder       = $folder.PadRight(42).Substring(0,42)

            }else 
            {
                $folder       = " " * 42
            }

            #Output the test case details
            Write-Host "       " $method $filename $expected_records $actual_records $folder
        }

    }

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host "There was an error while trying to output the File Creator log: " $Error[0]
    Exit 1
}

#Output the footer for the File Creator details
Write-Host ""
Write-Host "       -----------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""

#Cleanup
$FileCreatorLogReader.Close()
$FileCreatorLogReader.Dispose()
$FileCreatorLogCommand.Dispose()
$FileCreatorLogConnection.Close()
$FileCreatorLogConnection.Dispose()
