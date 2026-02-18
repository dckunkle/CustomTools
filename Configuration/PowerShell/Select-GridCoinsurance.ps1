<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/28/2022	DK				Original script
        09/30/2022  DK              Changes for client agnostic benefit grid
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script imports coinsurance data from the Benefit Grid into the Configuration database

    
    .DESCRIPTION

        This script imports coinsurance data from the Benefit Grid into the Configuration database
    

    .PARAMETER File

        Specifies the full filename of the Benefit Grid that is being imported


    .PARAMETER FileID

        Specifies the file ID of the Benefit Grid being imported


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory)]
    [string]$File,

    [Parameter(Mandatory)]
    [Int16]$FileID

)

begin
{
    $worksheet_name = "Coinsurance & CoPay Variations"

    #**************************************************************************************************
    # Create connection object to the Configuration database
    #**************************************************************************************************
    try
    {
        $config_instance = 'wqadbhpauto01'
        $config_database = 'Configuration'
        $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

        $status = ""

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
    # Create connection object to the Configuration database
    #**************************************************************************************************
    try
    {
        $file_command = New-Object System.Data.SqlClient.SqlCommand
        $file_command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $file_command.CommandText = "dbo.spConfig_GridSaveFileStart"
        $file_command.Connection  = $config_connection

        $file_command.Parameters.AddWithValue("@file_id",  $FileID)    >> $null
        $file_command.Parameters.AddWithValue("@worksheet", $worksheet_name) >> $null

        # Add the output parmeter @file_id
        $file_parameter = New-Object System.Data.SqlClient.SqlParameter
        $file_parameter.ParameterName = "@sheet_id"
        $file_parameter.Direction = [System.Data.ParameterDirection]'Output'
        $file_parameter.DbType = [System.Data.DBType]'Int16'

        $file_command.Parameters.Add($file_parameter) >> $null

        $file_command.ExecuteNonQuery() >> $null
        $sheet_id = $file_command.Parameters["@sheet_id"].Value

        $file_command.Dispose()
    }
    catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Open the file and verify there is a Coinsurance & CoPay Variations worksheet
    #**************************************************************************************************
    try
    {
        $excel = New-Object -comobject Excel.Application
        $workbook = $excel.Workbooks.Open($File)

        #Determine the first benefit name to find out where to begin importing coinsurance
        $worksheet = $workbook.Worksheets.Item("Master Benefit List")
        $worksheet.Activate()

        # This should be the first beneift name, will use this to find the corresponding value on the coinsurance sheet
        $first_benefit_name = $worksheet.Cells.Item(2,3).Text

        # Determine how many benefits there are
        $total_benefits = 2
        $benefit_id = $worksheet.Cells.Item($total_benefits, 1)

        while ($benefit_id -ne "")
        {
            $total_benefits++
            $benefit_id = $worksheet.Cells.Item($total_benefits, 1).Text
        }

        $total_benefits = $total_benefits - 2

        $worksheet = $workbook.Worksheets.Item($worksheet_name)
        $worksheet.Activate()

    }
    catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Determine which cell to start loading, look at the top 3 rows and the first 10 columns
    #**************************************************************************************************
    try
    {
        $start_row = 0
        $start_col = 0

        for ($row = 1; $row -le 5; $row++)
        {

            for ($col = 1; $col -le 10; $col++)
            {
                $cell_value = $worksheet.Cells.Item($row,$col).Text

                if ($first_benefit_name -eq $cell_value)
                {
                    $start_row = $row + 1
                    $start_col = $col
                }
            }
        }

        if (($start_row -eq 0) -or ($start_col -eq 0))
        {
            $status = "The start of the benefits could not be determined on the " + $worksheet_name + " worksheet."
        }
    }
    catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Ouptut the coinsurance details
    #**************************************************************************************************
    try
    {
        if ($status -eq "")
        {

            # Determine the last column to look in
            $last_col = $start_col + $total_benefits - 1
            #$last_col = 7

            Write-Host $start_row
            write-Host $start_col

            for ($col = $start_col; $col -le $last_col; $col++)
            {
                $row = $start_row
                $coinsurance_id = $worksheet.Cells.Item($row,1).Text

                Write-Host $coinsurance_id
                Write-Host $row
                Write-Host $col

                while ($coinsurance_id -ne "")
                {
        
                    [PSCustomObject]@{
                        FileID = $file_id
                        SheetID = $sheet_id
                        Row = $row
                        Column = $col

                        CoinsuranceID = $coinsurance_id
                        BenefitID = $col - $start_col + 1
                        CoinsuranceValue = $worksheet.Cells.Item($row,$col).Text
                    }

                    $row++
                    $coinsurance_id = $worksheet.Cells.Item($row,1).Text
                }
            }
        }
    }
    catch
    {
        Write-Host $_
        Exit 1
    }
}
end
{
    #**************************************************************************************************
    # Finish the log and close the Benefit Grid
    #**************************************************************************************************
    if ($status -eq ""){ $status = "Processed" }

    $file_command = New-Object System.Data.SqlClient.SqlCommand
    $file_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $file_command.CommandText = "dbo.spConfig_GridSaveFileFinish"
    $file_command.Connection  = $config_connection

    $file_command.Parameters.AddWithValue("@file_id", $file_id) >> $null
    $file_command.Parameters.AddWithValue("@sheet_id", $sheet_id) >> $null
    $file_command.Parameters.AddWithValue("@status", $status)  >> $null

    $file_command.ExecuteNonQuery() >> $null
    $file_command.Dispose()

    #**************************************************************************************************
    # Close the spreadsheet
    #**************************************************************************************************
    $workbook.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) >> $null
}