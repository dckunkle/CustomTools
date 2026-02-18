<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/25/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will load a properly formatted Benefit Grid into tables in the Configuration
        database

    
    .DESCRIPTION

        This script imports data from a standard Benefit Grid into the Configuration database in 
        preparation for the data to be converted to configuration for the plan
    

    .PARAMETER grid_path

        Specifies the Excel spreadsheet full filename to load


#>


[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$grid_path

)

$script_name = $MyInvocation.MyCommand.Name

#**************************************************************************************************
# Open the file
#**************************************************************************************************
try
{
    $excel = New-Object -comobject Excel.Application
    $workbook = $excel.Workbooks.Open($grid_path)

}
catch
{
    $location = "Attempting to open the Benefit Grid"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Create connection object to the Configuration database
#**************************************************************************************************
try
{
    $config_instance = 'wqadbhpauto01'
    $config_database = 'Configuration'
    $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

    Write-Debug "Configuration connection created"
}
catch
{
    $location = "Attempting to connect to the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Validate the Plan Master tab headings
#**************************************************************************************************
try
{
    $worksheet_name = "Plan Master"
    $plan_worksheet = $workbook.Worksheets.Item($worksheet_name)
    $plan_worksheet.Activate()

    $headings = @()
    $headings = @('HIOS ID','Plan Strategy ID','Plan Marketing Name','State','DED_ID','OOP_ID','Coin_CoPay_ID')
    $err_msg = ""

    for ($i=1; $i -le $headings.Count; $i++)
    {
        $heading = $plan_worksheet.Cells.Item(1,$i)

        if ($heading.Text -ne $headings[$i-1])
        {
            $err_msg = "The headings for the " + $worksheet_name + " worksheet do not match what is expected."
        }
    }

    if ($err_msg -ne "")
    {
        $location = "Validating " + $worksheet_name + " worksheet"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }

}
catch
{
    $location = "Validating " + $worksheet_name + " worksheet"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Validate the Deductible Variations tab headings
#**************************************************************************************************
try
{
    $worksheet_name = "Deductible Variations"
    $deductible_worksheet = $workbook.Worksheets.Item($worksheet_name)
    $deductible_worksheet.Activate()

    $headings = @()
    $headings = @('DED_ID','Individual Deductible','Family Deductible','DED_OOP_KEY','DED_OOP_ID')
    $err_msg = ""

    for ($i=1; $i -le $headings.Count; $i++)
    {
        $heading = $deductible_worksheet.Cells.Item(1,$i)

        if ($heading.Text -ne $headings[$i-1])
        {
            $err_msg = "The headings for the " + $worksheet_name + " worksheet do not match what is expected (" + $heading.Text + ")"
        }
    }

    if ($err_msg -ne "")
    {
        $location = "Validating " + $worksheet_name + " worksheet"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }

}
catch
{
    $location = "Validating " + $worksheet_name + " worksheet"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Validate the OOP Variations tab headings
#**************************************************************************************************
try
{
    $worksheet_name = "Out of Pocket Variations"
    $oop_worksheet = $workbook.Worksheets.Item($worksheet_name)
    $oop_worksheet.Activate()

    $headings = @()
    $headings = @('OOP_ID','Individual Out Of Pocket','Family Out Of Pocket','OOP_KEY','OOP_ID')
    $err_msg = ""

    for ($i=1; $i -le $headings.Count; $i++)
    {
        $heading = $oop_worksheet.Cells.Item(1,$i)

        if ($heading.Text -ne $headings[$i-1])
        {
            $err_msg = "The headings for the " + $worksheet_name + " worksheet do not match what is expected (" + $heading.Text + ")"
        }
    }

    if ($err_msg -ne "")
    {
        $location = "Validating " + $worksheet_name + " worksheet"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }

}
catch
{
    $location = "Validating " + $worksheet_name + " worksheet"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
#**************************************************************************************************
# Close the Benefit Grid
#**************************************************************************************************
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) >> $null
