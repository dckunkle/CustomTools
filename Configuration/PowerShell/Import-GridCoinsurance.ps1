<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/29/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script saves the coinsurance data, that was selected, from the Benefit Grid

    
    .DESCRIPTION

        This script saves the coinsurance data, that was selected, from the Benefit Grid
    

    .PARAMETER FileID

        Specifies the file name for the Benefit Grid to get plans from


    .PARAMETER SheetID

        Specifies the file name for the Benefit Grid to get plans from


    .PARAMETER Row

        Specifies the file name for the Benefit Grid to get plans from


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$FileID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$SheetID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$Row,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$Column,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$CoinsuranceID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$BenefitID,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$CoinsuranceValue

)
begin
{
    #**************************************************************************************************
    # Create connection object to the Configuration database
    #**************************************************************************************************
    try
    {
        $config_instance = 'wqadbhpauto01'
        $config_database = 'Configuration'
        $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

        $sql_command = New-Object System.Data.SqlClient.SqlCommand
        $sql_command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $sql_command.CommandText = "dbo.spConfig_GridSaveCoinsurance"
        $sql_command.Connection  = $config_connection

        $sql_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@sheet_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@row", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@column", [Data.SQLDBType]::Int) >> $null

        $sql_command.Parameters.Add("@coinsurance_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@benefit_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@coinsurance_value", [Data.SQLDBType]::VarChar, 100) >> $null
    }
    catch
    {
        Write-Host $_
        Exit 1
    }
}
process
{
    #**************************************************************************************************
    # Save each plan to the Configuration database
    #**************************************************************************************************
    try
    {
        if ($status -eq ""){ $status = "Processed" }

        $sql_command.Parameters["@file_id"].Value = $FileID
        $sql_command.Parameters["@sheet_id"].Value = $SheetID
        $sql_command.Parameters["@row"].Value = $Row
        $sql_command.Parameters["@column"].Value = $Column

        $sql_command.Parameters["@coinsurance_id"].Value = $CoinsuranceID
        $sql_command.Parameters["@benefit_id"].Value = $BenefitID
        $sql_command.Parameters["@coinsurance_value"].Value = $CoinsuranceValue

        $sql_command.ExecuteNonQuery() >> $null
    }
    catch
    {
        Write-Host $_
        Exit 1
    }
}
end
{
    $sql_command.Dispose()
    $config_connection.Close()
}