<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/20/2023	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script imports plan data from the RFF Interest into the API Automation database

    
    .DESCRIPTION

        This script imports plan data from the RFF Interest into the API Automation database


    .PARAMETER FileID

        Specifies the file ID of the RFF Interest being imported


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory)]
    [Int16]$FileID
)

#**************************************************************************************************
# Create connection object to the API Automation database
#**************************************************************************************************
try
{
    $api_instance = 'wqadbhpauto01'
    $api_database = 'APIAutomation'
    $api_connection = .\New-SQLConnection.ps1 -instance_name $api_instance -database $api_database

    # Create the command to gather all of the errors for a file
    $errors_command = New-Object System.Data.SqlClient.SqlCommand
    $errors_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $errors_command.CommandText = "dbo.spAPIAuto_RFFInterestSelectErrors"
    $errors_command.Connection  = $api_connection

    $errors_command.Parameters.Add("@FileID", [Data.SQLDBType]::VarChar, 2000) >> $null

    $errors_command.Parameters["@FileID"].Value = $FileID
    $errors_reader = $errors_command.ExecuteReader()

}
catch
{
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Report any errors that were found during the processing of the file
#**************************************************************************************************
try
{
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host " RFF INTEREST FILE PROCESSING ERRORS"
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host ""
    Write-Host "     --Row----Column--Type-----Number--Error-Message----------------------------------------------------------------------------------------------"
    Write-Host ""

    if ($errors_reader.HasRows)
    {
        while($errors_reader.Read())
        {
            $row         = [string]$errors_reader.Item("RowID")
            $column      = [string]$errors_reader.Item("ColumnID")
            $error_level = $errors_reader.Item("ErrorLevel")
            $error_num   = [string]$errors_reader.Item("ErrorNumber")
            $error_msg   = $errors_reader.Item("ErrorMessage")
         
            Write-Host "      " $row.PadRight(6) $column.PadRight(7) $error_level.PadRight(8) $error_num.PadRight(7) $error_msg
        }
    }
    else
    {
        Write-Host "        No errors reported."
    }
    
    Write-Host ""
    Write-Host ""
    Write-Host "     ---------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host ""

}
catch
{
    Write-Host $_
    Exit 1
}

$errors_reader.Close()
$errors_command.Dispose()
$api_connection.Close()