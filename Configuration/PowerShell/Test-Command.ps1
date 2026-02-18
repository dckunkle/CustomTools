<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        02/26/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This is a test script to work with stored procedures and ADO.NET

    
    .DESCRIPTION

        This is a test script to work with stored procedures and ADO.NET


    .PARAMETER config_id

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)

#>


[CmdletBinding()]
[OutputType([Array])]
Param(

    [Parameter(Mandatory=$True)]
    [string]$configuration_id

)

try
{

    $config_instance = 'wqagdbhpauto01'
    $config_database = 'Configuration'
    $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database
}
catch
{
    $PSItem.Exception.Message
}