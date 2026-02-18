<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/12/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This function returns stored procedure and the SQL that is needed to collect the Core data for the method that is provided

    
    .DESCRIPTION

        The function returns the populate stored procedure for the given method. The stored procedure along with the SQL will be used to iterate through the Core data.


    .PARAMETER method

        Specifies the method name used to look up the stored procedure and SQL statement
    

    .PARAMETER screen_fields

        Specifies the number of fields the current Core screen has. Used primarily for version detection.


    .PARAMETER sql_connection

        The SQL connection object to use to connect to the Configuration database

#>


[CmdLetBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$method,

    [Parameter(Mandatory=$True)]
    [string]$screen_fields,

    [Parameter(Mandatory=$True)]
    [object]$sql_connection

)

#**************************************************************************************************
# Try to connect to the database and retrieve the screen and entity
#**************************************************************************************************
try
{
    $Error.Clear()
    
    #Create the SQL Command to query the database for the entity
    $sql_command = New-Object System.Data.SqlClient.SqlCommand
    $sql_command.Connection = $sql_connection
    $sql_command.CommandText = "SELECT LoadID AS load_id FROM cfg.ActionLoad WHERE MethodName = '" + $method + "' AND FieldCount = " + $screen_fields
    $sql_reader = $sql_command.ExecuteReader()


    while ($sql_reader.Read())
    {
        $function_results = [PSCustomObject]@{
            load_id            = 0
            error_message      = ""
        }

        $function_results.load_id = $sql_reader.Item("load_id")
    }

    $sql_reader.Close()
    $sql_command.Dispose()
    return $function_results
}

catch
{
    $function_results = [PSCustomObject]@{

        load_id            = 0
        error_message      = $Error[0]
    }
    return $function_results
}
