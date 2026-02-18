<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/26/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script saves the deductible data, that was selected, from the Benefit Grid

    
    .DESCRIPTION

        This script saves the deductible data, that was selected, from the Benefit Grid
    

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
    [string]$DeductibleID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$IndividualDeductible,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$FamilyDeductible,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$IndividualOONDeductible,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$FamilyOONDeductible

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
        $sql_command.CommandText = "dbo.spConfig_GridSaveDeductible"
        $sql_command.Connection  = $config_connection

        $sql_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@sheet_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@row", [Data.SQLDBType]::Int) >> $null

        $sql_command.Parameters.Add("@deductible_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@individual_deductible", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@family_deductible", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@individual_oon_deductible", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@family_oon_deductible", [Data.SQLDBType]::VarChar, 50) >> $null
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

        $sql_command.Parameters["@deductible_id"].Value = $DeductibleID
        $sql_command.Parameters["@individual_deductible"].Value = $IndividualDeductible
        $sql_command.Parameters["@family_deductible"].Value = $FamilyDeductible

        $sql_command.Parameters["@individual_oon_deductible"].Value = $IndividualOONDeductible
        $sql_command.Parameters["@family_oon_deductible"].Value = $FamilyOONDeductible

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