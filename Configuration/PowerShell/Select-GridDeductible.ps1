<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/26/2022	DK				Original script
        09/30/2022  DK              Changes for client agnostic benefit grid
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script imports deductible data from the Benefit Grid into the Configuration database

    
    .DESCRIPTION

        This script imports deductible data from the Benefit Grid into the Configuration database
    

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
    $worksheet_name = "Deductible Variations"

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
    # Open the file and verify there is a Plan Master worksheet
    #**************************************************************************************************
    try
    {
        $excel = New-Object -comobject Excel.Application
        $workbook = $excel.Workbooks.Open($File)

        $worksheet = $workbook.Worksheets.Item($worksheet_name)
        $worksheet.Activate()

    }
    catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Validate the Plan Master tab headings
    #**************************************************************************************************
    try
    {   
        $location = "Validating " + $worksheet_name + " worksheet"
        $err_msg = ""

        $headings = @()
        $headings = @('DED_ID'
                     ,'Medical Deductible Individual - INN T1'
                     ,'Medical Deductible Individual - INN T2'
                     ,'Medical Deductible Individual - OON'
                     ,'Medical Deductible Family - INN T1'
                     ,'Medical Deductible Family - INN T2'
                     ,'Medical Deductible Family - OON'
                     ,'Drug Deductible Individual - INN T1'
                     ,'Drug Deductible Individual - INN T2'
                     ,'Drug Deductible Individual - OON'
                     ,'Drug Deductible Family - INN T1'
                     ,'Drug Deductible Family - INN T2'
                     ,'Drug Deductible Family - OON'
                     ,'Medical and Drug Deductible Individual - INN T1'
                     ,'Medical and Drug Deductible Individual - INN T2'
                     ,'Medical and Drug Deductible Individual - OON'
                     ,'Medical and Drug Deductible Family - INN T1'
                     ,'Medical and Drug Deductible Family - INN T2'
                     ,'Medical and Drug Deductible Family - OON'
                     ,'DED_KEY'
                     ,'DED_ID')

        for ($i=1; $i -le $headings.Count; $i++)
        {

            $worksheet_heading = $worksheet.Cells.Item(1,$i).Text
            $heading = $headings[$i-1]

            if ($worksheet_heading -ne $heading)
            {
                $status = "The heading, $worksheet_heading, from the $worksheet_name worksheet does not match $heading."
            }
        }
    }
    catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Ouptut the deductible details
    #**************************************************************************************************
    try
    {
        if ($status -eq "")
        {
            $row = 2
            $deductible_id = $worksheet.Cells.Item($row,1).Text


            while ($deductible_id -ne "")
            {
                #Get the individual deductible from either the Medical or Medical and Drug 
                $individual_deductible = $worksheet.Cells.Item($row,2).Text
                if ($individual_deductible -eq '$0') { $individual_deductible = $worksheet.Cells.Item($row,14).Text }

                #Get the individual oon deductible from either the Medical or Medical and Drug 
                $individual_oon_deductible = $worksheet.Cells.Item($row,4).Text
                if ($individual_oon_deductible -eq '$0') { $individual_oon_deductible = $worksheet.Cells.Item($row,16).Text }

                #Get the family deductible form either the Medical or Medical and Drug
                $family_deductible = $worksheet.Cells.Item($row,5).Text
                if ($family_deductible -eq '$0') { $family_deductible = $worksheet.Cells.Item($row,17).Text }

                #Get the family oon deductible from either the Medical or Medical and Drug 
                $family_oon_deductible = $worksheet.Cells.Item($row,7).Text
                if ($family_oon_deductible -eq '$0') { $family_oon_deductible = $worksheet.Cells.Item($row,19).Text }

                [PSCustomObject]@{
                    FileID = $file_id
                    SheetID = $sheet_id
                    Row = $row

                    DeductibleID = $worksheet.Cells.Item($row,1).Text
                    IndividualDeductible = $individual_deductible
                    IndividualOONDeductible = $individual_oon_deductible
                    FamilyDeductible = $family_deductible
                    FamilyOONDeductible = $family_oon_deductible
                }

                $row++
                $deductible_id = $worksheet.Cells.Item($row,1).Text
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