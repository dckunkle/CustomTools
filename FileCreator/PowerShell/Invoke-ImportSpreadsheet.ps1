<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        07/08/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Build an Excel spreadsheet used for import in Core

    
    .DESCRIPTION

        This script will add configuration to the target Core system. The Configuration database is 
        used to determine what configuration to add to the target based on the ConfigID.
    

    .PARAMETER Server

        Specifies the abbreviation of the system to gather the Core data from (e.g. QR06 for aldqadbqr06)


    .PARAMETER Method

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)


    .PARAMETER Pattern

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)


    .PARAMETER Filename

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)


    .PARAMETER Path

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)

#>


[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Server,

    [Parameter(Mandatory=$True)]
    [string]$Database,
    
    [Parameter(Mandatory=$True)]
    [string]$Method,

    [Parameter(Mandatory=$True)]
    [string]$Pattern,

    [Parameter(Mandatory=$True)]
    [string]$Filename,

    [Parameter(Mandatory=$True)]
    [string]$Path

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
    $data_command.CommandText = "dbo.spFCAuto_GetImportXLSXData"
    $data_command.Connection  = $fc_connection

    $data_command.Parameters.AddWithValue("@i_method_name", $Method) >> $null
    $data_command.Parameters.AddWithValue("@i_pattern", $Pattern) >> $null

    # Load any data into a data table to begin processing
    $data_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $data_adapter.SelectCommand = $data_command
    
    $data_set = New-Object System.Data.DataSet
    $data_adapter.Fill($data_set)  >> $null

    $data_table = New-Object System.Data.DataTable
    $data_table = $data_set.Tables[0]

    $column_count = $data_table.Columns.Count - 1

    $entity_table = New-Object System.Data.DataTable
    $entity_table = $data_set.Tables[1]

    $screen_gid = $entity_table.Rows[0].("screen_gid")
    $entity_name = $entity_table.Rows[0].("entity_name")
}
catch
{
    Write-Host "FC Data"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Create connection object to the destination database
#**************************************************************************************************
try
{
    $connection_string = "Server=$Server;Database=$Database;User ID=user;Password=password"

    $core_connection = New-Object System.Data.SqlClient.SqlConnection
    $core_connection.ConnectionString = $connection_string
    $core_connection.Open()

    Write-Debug "File Creator connection created"
}
catch
{
    Write-Host "Core Connection"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Connect to the Core database and retrieve the headers 
#**************************************************************************************************
try
{
    $sql = "SELECT SD.Field_Order		      Sort
                  ,REPLACE(SD.Label,':','')   Label			
	              ,SD.Data_Type			      Type
	              ,CASE WHEN LEFT(SD.Field_Tag, 1) = 'R' 
                        THEN 'Y' 
                        ELSE 'N' 
                    END                       Required
	              ,CASE WHEN SD.Field_Locked = 1 
                        THEN 'Y'
                        ELSE 'N'
                    END		                  Locked
	              ,IE.ImportExportEnabled	  Enabled
                  ,ESA.screen_title           Title
              FROM Screen_Details		      SD
              JOIN Entity_Screen_Action	      ESA
                ON SD.Screen_GID		      = ESA.screen_gid
               AND ESA.entity			      = '$entity_name'
              JOIN ImportExportEnabled	      IE
                ON ESA.entity			      = IE.Screen_Entity
             WHERE ESA.action			      = 'ADD'
               AND SD.Data_Type			      NOT IN ('DUMMY','SPACE','EXPAND','PLACE')"

    $header_command = New-Object System.Data.SqlClient.SqlCommand
    $header_command.Connection = $core_connection
    $header_command.CommandTimeout = 0
    $header_command.CommandText = $sql

    $header_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $header_adapter.SelectCommand = $header_command

    $header_data_set = New-Object System.Data.DataSet
    $header_adapter.Fill($header_data_set)  >> $null

    $header_table = New-Object System.Data.DataTable
    $header_table = $header_data_set.Tables[0]

    $import_enabled = $header_table.Rows[0].Item("Enabled")
    $title = $header_table.Rows[0].Item("Title")

}
catch
{
    Write-Host "Core Headers"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Create a new Excel spreadsheet
#**************************************************************************************************
try
{

    # Load the EPPlus.dll
    $DLLPath = "C:\PowerShell\EPPlus.dll"
    [Reflection.Assembly]::LoadFile($DLLPath) | Out-Null

    $excel_file = "C:\Powershell\" + $Filename
    $ExcelPackage = New-Object OfficeOpenXML.ExcelPackage($excel_file)

    $workbook = $excelPackage.Workbook

    $workbook.Properties.Author = "File Creator"
    $Workbook.Properties.Title = "Import Spreadsheet"

    # Create a worksheet and create a reference to it
    $workbook.Worksheets.Add("Sheet1") | Out-Null
    $worksheet = $workbook.Worksheets[1]

    #Make all cells Text format
    $worksheet.Cells.Style.Numberformat.Format = "@"

}
catch
{
    Write-Host "Create Spreadsheet"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Loop through the data and build the Import Spreadsheet
#**************************************************************************************************
try
{
    if($import_enabled -eq 'Y'){$column_count = $column_count + 12}

    $worksheet.Cells[1,1].Value = "$Title (GID:$screen_gid)"
    $worksheet.Cells.Item(1,1).Style.Font.Bold = $true

    $worksheet.Cells[1,2].Value = $screen_gid
    $worksheet.Cells[1,3].Value = $column_count

    $worksheet.Cells[3,1].Value = "MODIFYING THE LAYOUT OF THIS SPREADSHEET MAY CAUSE IMPORT ERRORS"

    $column = 1
    foreach($header_row in $header_table)
    {
        $worksheet.Cells[4,$column].Value = $header_row.Label
        if($header_row.Required -eq "Y"){$worksheet.Cells[4,$column].Style.Font.Bold = $true}
        if($header_row.Locked -eq "Y"){$worksheet.Cells.Item(4,$column).Style.Font.Italic = $true}
        $column++
    }

    $worksheet.Cells[4, $column].Value = "Action"
    $hidden_column_start = $column + 1

    if($import_enabled -eq "Y")
    {
        $column++; $worksheet.Cells[4, $column].Value  = "Entity"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 1"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 2"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 3"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 4"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 5"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 6"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 7"
        $column++; $worksheet.Cells[4, $column].Value  = "Key 8"
        $column++; $worksheet.Cells[4, $column].Value = "Key 9"
        $column++; $worksheet.Cells[4, $column].Value = "Key 10"
        $column++; $worksheet.Cells[4, $column].Value = "DateTimeModified"
    }

    $hidden_column_end = $column
     
    $row = 5
    $columns = $data_table.Columns.Count - 1

    foreach($data_row in $data_table)
    {

        $record_id = $data_row.Item(0)
        $key_sql = .\Get-KeyQuery.ps1 -Method $Method -RecordID $record_id

        for ($column = 1; $column -le $columns; $column++)
        {
            $worksheet.Cells[$row,$column].Value = $data_row.Item($column)
        }

        #Get the Action column in the last column
        $action = $data_row.Item($columns)

        #If Action is either Modify or Delete then get the key fields and add them to the spreadsheet
        if (($action -eq "Modify") -or ($action -eq "Delete"))
        {

            #Get the column where we left off
            $key_column = $columns

            $key_command = New-Object System.Data.SqlClient.SqlCommand
            $key_command.Connection = $core_connection
            $key_command.CommandTimeout = 0
            $key_command.CommandText = $key_sql

            $key_reader = $key_command.ExecuteReader()

            if ($key_reader.HasRows)
            {
                $key_reader.Read() >> $null

                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Entity")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key1")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key2")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key3")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key4")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key5")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key6")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key7")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key8")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key9")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("Key10")
                $key_column++; $worksheet.Cells[$row,$key_column].Value = $key_reader.Item("DateTimeModified")
            }

            $key_reader.Close()
            $key_command.Dispose()
        }

        $row++
    }

    $worksheet.Cells.AutoFitColumns()

    for ($d = $hidden_column_start; $d -le $hidden_column_end; $d++)
    {
        $worksheet.Column($d).Hidden = $true
    }
    
}
catch
{
    Write-Host "Template"
    Write-Host $_
    Exit 1
}

#**************************************************************************************************
# Save the Excel spreadsheet
#**************************************************************************************************
try
{
    $import_file = $Path + "\" + $Filename

    if (Test-Path $import_file)
    {
        Remove-Item $import_file
    }

    $excelPackage.SaveAs($import_file)
    $excelPackage.Dispose()
}
catch
{
    Write-Host "Save"
    Write-Host $_
    Exit 1
}