<#
    .NOTESS
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/28/2022	DK				Original script
        09/30/2022  DK              Changes for client agnostic benefit grid
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script is responsible for importing all of the Benefit Grids in a target folder

    
    .DESCRIPTION

        This script is responsible for importing all of the Benefit Grids in a target folder
    

    .PARAMETER Path

        Specifies the path where the Benefit Grids reside


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
    $config_database = 'Configuration'
    $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

    # Create the command to start the file log
    $file_command = New-Object System.Data.SqlClient.SqlCommand
    $file_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $file_command.CommandText = "dbo.spConfig_GridLogFile"
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
    $file_end_command.CommandText = "dbo.spConfig_GridLogFileEnd"
    $file_end_command.Connection  = $config_connection

    $file_end_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null
}
catch
{
    Write-Host $_
    Exit 1
}


#**************************************************************************************************
# Save each plan to the Configuration database
#**************************************************************************************************
try
{
    $files = Get-ChildItem -Path $Path
    foreach ($file in $files)
    {
        $fullname = $file.Fullname

        $file_command.Parameters["@fullname"].Value = $fullname
        $file_command.Parameters["@file_directory"].Value = $file.DirectoryName
        $file_command.Parameters["@filename"].Value = $file.Name
        $file_command.Parameters["@file_date"].Value = $file.LastWriteTime
        $file_command.Parameters["@file_size"].Value = $file.Length

        $file_command.ExecuteNonQuery() >> $null
        $file_id = $file_command.Parameters["@file_id"].Value

        .\Select-GridPlan.ps1 -File $fullname -FileID $file_id | .\Import-GridPlan.ps1
        .\Select-GridDeductible.ps1 -File $fullname -FileID $file_id  | .\Import-GridDeductible.ps1
        .\Select-GridOutOfPocket.ps1 -File $fullname -FileID $file_id | .\Import-GridOutOfPocket.ps1
        .\Select-GridBenefit.ps1 -File $fullname -FileID $file_id | .\Import-GridBenefit.ps1
        .\Select-GridBenefitCrosswalk.ps1 -File $fullname -FileID $file_id | .\Import-GridBenefitCrosswalk.ps1
        .\Select-GridCoinsurance.ps1 -File $fullname -FileID $file_id | .\Import-GridCoinsurance.ps1

        # Complete the log
        $file_end_command.Parameters["@file_id"].Value = $file_id
        $file_end_command.ExecuteNonQuery() >> $null
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
