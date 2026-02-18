<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        02/28/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Script will display a formatted Configurator error

    
    .DESCRIPTION

        Script to standardize the reporting of a terminating error
    
    
    .PARAMETER script_name
        
        What portion of the code the error occured in


    .PARAMETER script_location

        A description of where in the code the error occurred


    .PARAMETER error_message

        The error message being reported

#>


[CmdletBinding()]
[OutputType([Array])]
Param(

    [Parameter(Mandatory=$True)]
    [string]$script_name,

    [Parameter(Mandatory=$True)]
    [string]$script_location,

    [Parameter(Mandatory=$True)]
    [string]$error_message


)
Write-Host ""
Write-Host "--Configurator Error-------------------------------------------------------------------------"
Write-Host ""
Write-Host "    Script...." $script_name
Write-Host "    Location.." $script_location
Write-Host "    Error....." $error_message 
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------"
Write-Host ""