<# ***************************************************************************************************
Purpose:    Output File Creator Preprocessor log for the Jenkins console
Parameters: 
    
    server_name   - name of the server where the Data Creator log is
    log_id        - the log id of the log to display


Date        User            Change
---------------------------------------------------------------------------------------------
05/21/2021	DK				Original script
05/27/2021  DK              Added code to handle NULLs from the database
06/21/2021  DK              Changed connection string to use batch credentials
04/14/2023  DK              Modified for RiskScores
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

#Create the connection to the proper server
$PreprocessorMethodConnection = New-Object System.Data.SqlClient.SqlConnection
$PreprocessorMethodConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"

$PreprocessorMethodCommand = New-Object System.Data.SqlClient.SqlCommand
$PreprocessorMethodCommand.Connection = $PreprocessorMethodConnection
$PreprocessorMethodCommand.CommandText = "SELECT * FROM PPLogMethod WHERE log_id=" + $log_id + " ORDER BY log_id"
$PreprocessorMethodCommand.CommandTimeout = 0

#**************************************************************************************************
# Output the File Creator Preprocessor detail header
#**************************************************************************************************

try
{
    #Try opening the connection to the database
    $PreprocessorMethodConnection.Open()
    
    #Get the data from the log and begin outputting it to the screen
    $PreprocessorMethodReader = $PreprocessorMethodCommand.ExecuteReader()

    while ($PreprocessorMethodReader.Read())
    {

        $detail_records = $true
        $method_name = $PreprocessorMethodReader.Item("method_name")

        #Output the test case header
        Write-Host ""
        Write-Host "        Method: "$PreprocessorMethodReader.Item("method_name")
        Write-Host "        Table:  "$PreprocessorMethodReader.Item("table_name")
        Write-Host "        Action: "$PreprocessorMethodReader.Item("action")

        $method_id = $PreprocessorMethodReader.Item("method_id")

        #For each method, output the details of what is being processed
        Write-Host ""

        if ($method_name -eq "RiskScores")
        {
            Write-Host "        -Record ID--Member ID------------Member GID----------------------------------------------------------------------------------------------"
        }
        else
        {
            Write-Host "        -Record ID--Claim Number---------Line Number----Date Submitted----------------------Claim SID--------------------------------------------"
        }

        $PreprocessorMethodDetailConnection = New-Object System.Data.SqlClient.SqlConnection
        $PreprocessorMethodDetailConnection.ConnectionString = "Server=" + $server_name + ";Database=QA;User ID=user;Password=password"
        $PreprocessorMethodDetailConnection.Open()

        $PreprocessorMethodDetailCommand = New-Object System.Data.SqlClient.SqlCommand
        $PreprocessorMethodDetailCommand.Connection = $PreprocessorMethodDetailConnection
        $PreprocessorMethodDetailCommand.CommandText = "SELECT * FROM PPLogMethodDetail WHERE method_id=" + $method_id + " ORDER BY detail_id"
        $PreprocessorMethodDetailCommand.CommandTimeout = 0

        $PreprocessorMethodDetailReader = $PreprocessorMethodDetailCommand.ExecuteReader()
                
        while ($PreprocessorMethodDetailReader.Read())
        {
            $record_id      = $PreprocessorMethodDetailReader.Item("record_id").ToString()
            if ($record_id -ne [DBNull]::Value) {
            $record_id      = $record_id.PadRight(10).Substring(0,10)}

            $claim_number   = $PreprocessorMethodDetailReader.Item("claim_number")
            if ($claim_number -ne [DBNull]::Value) {
            $claim_number   = $claim_number.PadRight(20).Substring(0,20)}

            $line_number    = $PreprocessorMethodDetailReader.Item("line_number").ToString()
            if ($line_number -ne [DBNull]::Value) {
            $line_number    = $line_number.PadRight(14).Substring(0,14)}

            $date_submitted = $PreprocessorMethodDetailReader.Item("date_submitted").ToString()
            if ($date_submitted -ne [DBNull]::Value) {
            $date_submitted = $date_submitted.PadRight(35).Substring(0,35)}

            $claim_sid      = $PreprocessorMethodDetailReader.Item("claim_sid").ToString()
            if ($claim_sid -ne [DBNull]::Value) {
            $claim_sid      = $claim_sid.PadRight(20).Substring(0,20)}

            $status         = $PreprocessorMethodDetailReader.Item('status')

            #If the claim was not found during processing then show the error message instead
            if (-not($date_submitted=""))
            {
                $date_submitted = $status.PadRight(50).Substring(0,50)
                $claim_sid = ""
            }

            if ($method_name -eq "RiskScores")
            {
                $claim_sid      = $PreprocessorMethodDetailReader.Item("claim_sid").ToString()
                if ($claim_sid -ne [DBNull]::Value) {
                $claim_sid      = $claim_sid.PadRight(20).Substring(0,20)}

                Write-Host "        "$record_id $claim_number $claim_sid
            }
            else
            {
                Write-Host "        "$record_id $claim_number $line_number $date_submitted $claim_sid
            }
        }


        #Output the footer for the validation details
        Write-Host "        -----------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host ""


        #Cleanup validation details so it can be reused
        $PreprocessorMethodDetailReader.Close()
        $PreprocessorMethodDetailReader.Dispose()
        $PreprocessorMethodDetailCommand.Dispose()
        $PreprocessorMethodDetailConnection.Close()
        $PreprocessorMethodDetailConnection.Dispose()

    }

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host "There was an error while trying to output the log: " $Error[0]
    Exit 1
}

if (-not($detail_records))
{
    Write-Host "        ----------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host "           Nothing for the preprocessor to process"
    Write-Host ""
    Write-Host "        ----------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
}

#Cleanup
$PreprocessorMethodReader.Close()
$PreprocessorMethodReader.Dispose()
$PreprocessorMethodCommand.Dispose()
$PreprocessorMethodConnection.Close()
