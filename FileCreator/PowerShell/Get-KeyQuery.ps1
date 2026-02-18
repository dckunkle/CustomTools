<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        07/08/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Returns the Key Values SQL that will be run on the target Core system for any MODIFY or
        DELETE records needing key values (SIDs, modified_date, etc.)

    
    .DESCRIPTION

        This script retrieves a SQL query from the File Creator database that will be used to get the
        key values from the destination database. The key values are needed for MODIFY and DELETE 
        functions in the Import Spreadsheet


    .PARAMETER Method

        Specifies the method (e.g. ImportXLSXDiagnosisCode) in the File Creator database. Used to look
        up details for the key SQL statement


    .PARAMETER RecordID

        Specifies the RecordID from the table in the File Creator database. Uniquely identifies a record
        in the TD_ table where the data is. The RecordID will be used to get specific values to add to 
        the SQL that will be used to get the Key values from the target system.

#>


[CmdletBinding()]
Param(
   
    [Parameter(Mandatory=$True)]
    [string]$Method,

    [Parameter(Mandatory=$True)]
    [Int32]$RecordID

)

#**************************************************************************************************
# Create connection object to the File Creator database
#**************************************************************************************************
try
{
    $connection_string = "Server=wqadbhpauto01;Database=CoreFileCreator;Integrated Security=True;"
 
    $fc_connection = New-Object System.Data.SqlClient.SqlConnection
    $fc_connection.ConnectionString = $connection_string
    $fc_connection.Open()

    Write-Debug "File Creator connection created"
}
catch
{
    Write-Host "FC Connection"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Get the data to add to the spreadsheet
#**************************************************************************************************
try
{
    $data_command = New-Object System.Data.SqlClient.SqlCommand
    $data_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $data_command.CommandText = "dbo.spFCAuto_GetImportXLSXQuery"
    $data_command.Connection  = $fc_connection

    $data_command.Parameters.AddWithValue("@i_method_name", $Method) >> $null
    $data_command.Parameters.AddWithValue("@i_record_id", $RecordID) >> $null

    # Load any data into a data table to begin processing
    $data_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $data_adapter.SelectCommand = $data_command
    
    $data_set = New-Object System.Data.DataSet
    $data_adapter.Fill($data_set)  >> $null

    $data_table = New-Object System.Data.DataTable
    $data_table = $data_set.Tables[0]

    $key_sql = $data_table.Rows[0].("key_sql")
    
    $key_sql
}
catch
{

    Write-Host $_
    Exit 1
}