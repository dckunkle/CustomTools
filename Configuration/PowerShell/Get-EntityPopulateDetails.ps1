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
    

    .PARAMETER sql_connection

        The SQL connection object to use to connect to the Configuration database

#>


[CmdLetBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$method, 

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
    $sql_command.CommandText = "SELECT CoreProcedure AS populate_procedure, SQL AS populate_sql FROM cfg.ActionLoad WITH (NOLOCK) WHERE MethodName = '" + $method + "'"
    $sql_reader = $sql_command.ExecuteReader()

    while ($sql_reader.Read())
    {
        $function_results = [PSCustomObject]@{

            populate_procedure = "Not Found"
            populate_sql       = "Not Found"
            error_message      = ""
        }

        $function_results.populate_procedure = $sql_reader.Item("populate_procedure")
        $function_results.populate_sql       = $sql_reader.Item("populate_sql")
    }

    $sql_reader.Close()
    $sql_command.Dispose()
    return $function_results
}

catch
{
    $function_results = [PSCustomObject]@{

        populate_procedure = "Not Found"
        populate_sql       = "Not Found"
        error_message      = $Error[0]
    }
    
    return $function_results
}
