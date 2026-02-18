<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/26/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script saves the out-of-pocket data, that was selected, from the Benefit Grid

    
    .DESCRIPTION

        This script saves the out-of-pocket data, that was selected, from the Benefit Grid
    

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
    [string]$OutOfPocketID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$IndividualOutOfPocket,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$FamilyOutOfPocket

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
        $sql_command.CommandText = "dbo.spConfig_GridSaveOutOfPocket"
        $sql_command.Connection  = $config_connection

        $sql_command.Parameters.Add("@file_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@sheet_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@row", [Data.SQLDBType]::Int) >> $null

        $sql_command.Parameters.Add("@out_of_pocket_id", [Data.SQLDBType]::Int) >> $null
        $sql_command.Parameters.Add("@individual_out_of_pocket", [Data.SQLDBType]::VarChar, 50) >> $null
        $sql_command.Parameters.Add("@family_out_of_pocket", [Data.SQLDBType]::VarChar, 50) >> $null
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

        $sql_command.Parameters["@out_of_pocket_id"].Value = $OutOfPocketID
        $sql_command.Parameters["@individual_out_of_pocket"].Value = $IndividualOutOfPocket
        $sql_command.Parameters["@family_out_of_pocket"].Value = $FamilyOutOfPocket

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