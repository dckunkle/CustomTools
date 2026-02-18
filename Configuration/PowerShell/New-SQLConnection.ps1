<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/12/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Given the SQL Instance name and the database, return a SQL connection object

    
    .DESCRIPTION

        This function returns a SQL Connection object that can be used to connect to the server and database that has been provided.


    .PARAMETER instance_name

        Specifies the SQL instance to connect to
    

    .PARAMETER database

        Specifies the database to connect to

#>

[CmdletBinding()]
[OutputType([object])]
  
param
(
    [Parameter(Mandatory=$True)]
    [string]$instance_name,

    [Parameter(Mandatory=$True)]
    [string]$database
)
 
try 
{

    $connection_string = "Server=$instance_name;Database=$database;Integrated Security=True;"
 
    $sql_connection = New-Object System.Data.SqlClient.SqlConnection
    $sql_connection.ConnectionString = $connection_string
    $sql_connection.Open()

    return $sql_connection
}
catch
{
    Throw $_.Message
}
