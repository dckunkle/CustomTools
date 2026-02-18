<#
    .NOTESS
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/18/2023	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script is responsible for importing all of the RFF Interest files in a target folder

    
    .DESCRIPTION

        This script is responsible for importing all of the RFF Interest files in a target folder
    

    .PARAMETER Path

        Specifies the path where the RFF Interest files reside


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory)]
    [string]$Path

)

#**************************************************************************************************
# Create connection object to the Configuration database
#**************************************************************************************************
try
{
    $config_instance = 'wqadbhpauto01'
    $config_database = 'APIAutomation'
    $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

    # Create the command to start the file log
    $file_command = New-Object System.Data.SqlClient.SqlCommand
    $file_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $file_command.CommandText = "dbo.spAPIAuto_RFFInterestLogFile"
    $file_command.Connection  = $config_connection

    $file_command.Parameters.Add("@fullname", [Data.SQLDBType]::VarChar, 2000) >> $null
    $file_command.Parameters.Add("@file_directory", [Data.SQLDBType]::VarChar, 1000) >> $null
    $file_command.Parameters.Add("@filename", [Data.SQLDBType]::VarChar, 1000) >> $null
    $file_command.Parameters.Add("@file_date", [Data.SQLDBType]::VarChar, 100) >> $null
    $file_command.Parameters.Add("@file_size", [Data.SQLDBType]::Int) >> $null

    # Add the output parmeter @file_id
    $file_parameter = New-Object System.Data.SqlClient.SqlParameter
    $file_parameter.ParameterName = "@file_id"
    $file_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $file_parameter.DbType = [System.Data.DBType]'Int16'

    $file_command.Parameters.Add($file_parameter) >> $null

    # Create the command to end the log
    $file_end_command = New-Object System.Data.SqlClient.SqlCommand
    $file_end_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $file_end_command.CommandText = "dbo.spAPIAuto_RFFInterestLogFileEnd"
    $file_end_command.Connection  = $config_connection

    $file_end_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null

}
catch
{
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Clear the tables that will receive the data in the SQL database
#**************************************************************************************************
try
{
   # Create the command to clear the tables
    $clear_command = New-Object System.Data.SqlClient.SqlCommand
    $clear_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $clear_command.CommandText = "dbo.spAPIAuto_RFFInterestResetTables"
    $clear_command.Connection  = $config_connection

    $clear_command.ExecuteNonQuery() >> $null
    $clear_command.Dispose()
}
catch
{
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Output processing details
#**************************************************************************************************
try
{   

}
catch
{
    Write-Host 'Update State: '$_

    $workbook.Close($false)
    $excel.Quit()

    Exit 1
}

#**************************************************************************************************
# Save each plan to the Configuration database
#**************************************************************************************************
try
{
    $files = Get-ChildItem -Path $Path -Attributes !Directory
    foreach ($file in $files)
    {
        Write-Host ""
        Write-Host ""
        Write-Host "--------------------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host " RFF INTEREST FILE PROCESSING"
        Write-Host "--------------------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host ""
        Write-Host ""
        Write-Host "     -File ID--Date--------Filename---------------------------------------------------------------------------------------------------------------"
        Write-Host ""

        $fullname = $file.Fullname
        $archive_name = $Path + '\Archive\' + $file.Name
        $today = Get-Date -Format "MM/dd/yyyy"

        $file_command.Parameters["@fullname"].Value = $fullname
        $file_command.Parameters["@file_directory"].Value = $file.DirectoryName
        $file_command.Parameters["@filename"].Value = $file.Name
        $file_command.Parameters["@file_date"].Value = $file.LastWriteTime
        $file_command.Parameters["@file_size"].Value = $file.Length

        $file_command.ExecuteNonQuery() >> $null
        $file_id = $file_command.Parameters["@file_id"].Value
        $file_id_str = [string]$file_id

        Write-Host "     " $file_id_str.PadRight(8) $today.PadRight(11) $fullname 
        Write-Host ""
        Write-Host ""

        .\Select-RFFInterestDetail.ps1 -File $fullname -FileID $file_id | .\Import-RFFInterestDetail.ps1

        # Complete the log
        $file_end_command.Parameters["@file_id"].Value = $file_id
        $file_end_command.ExecuteNonQuery() >> $null

        .\Select-RFFInterestErrors.ps1 -FileID $file_id

        Move-Item -Path $fullname -Destination $archive_name
    }
}
catch
{
    Write-Host $_
    Exit 1
}


$file_command.Dispose()
$file_end_command.Dispose()
$config_connection.Close()
