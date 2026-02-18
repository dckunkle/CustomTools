<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/25/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script saves the plan data, that was selected, from the Benefit Grid

    
    .DESCRIPTION

        This script saves the plan data, that was selected, from the Benefit Grid
    

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
    [string]$HIOSID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$PlanID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$PlanName,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$PlanState,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$DeductibleID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$OutOfPocketID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$CoInsuranceID

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
        $sql_command.CommandText = "dbo.spConfig_GridSavePlan"
        $sql_command.Connection  = $config_connection

        $sql_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@sheet_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@row", [Data.SQLDBType]::Int) >> $null

        $sql_command.Parameters.Add("@hios_id", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@plan_id", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@plan_name", [Data.SQLDBType]::VarChar, 500) >> $null
        $sql_command.Parameters.Add("@plan_state", [Data.SQLDBType]::VarChar, 10) >> $null
        $sql_command.Parameters.Add("@deductible_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@out_of_pocket_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@copay_id", [Data.SQLDBType]::Int) >> $null

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

        $sql_command.Parameters["@hios_id"].Value = $HIOSID
        $sql_command.Parameters["@plan_id"].Value = $PlanID
        $sql_command.Parameters["@plan_name"].Value = $PlanName
        $sql_command.Parameters["@plan_state"].Value = $PlanState
        $sql_command.Parameters["@deductible_id"].Value = $DeductibleID
        $sql_command.Parameters["@out_of_pocket_id"].Value = $OutOfPocketID
        $sql_command.Parameters["@copay_id"].Value = $CoInsuranceID


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