<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/12/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Using the human friendly entity name, look up and return the screen gid, core entity, method and table name.

    
    .DESCRIPTION

        This function returns information from the cfg.Catalog table based on the entity name. The following items are returned:
            - screen gid
            - core entity name
            - method name
            - destination table name


    .PARAMETER entity

        Specifies the human readable entity name (e.g. Type of Bill vs Core entity Type_of_Bill)
    

    .PARAMETER sql_connection

        The SQL connection object to use to connect to the Configuration database

#>


[CmdLetBinding()]
[OutputType([object])]

Param(

    [Parameter(Mandatory=$True)]
    [string]$entity,

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
    $sql_command.CommandText = "SELECT MethodName AS method_name, CoreScreen AS screen_gid, CoreEntity AS entity, TableName AS destination_table FROM cfg.Catalog WITH (NOLOCK) WHERE EntityName = '" + $entity + "'"
    $sql_reader = $sql_command.ExecuteReader()

    while ($sql_reader.Read())
    {

        $function_results = [PSCustomObject]@{
            method_name       = ""
            screen_gid        = 0
            entity            = ""
            destination_table = "Not Found"
            error_message     = ""
        }

        $function_results.method_name       = $sql_reader.Item("method_name")
        $function_results.screen_gid        = $sql_reader.Item("screen_gid")
        $function_results.entity            = $sql_reader.Item("entity")
        $function_results.destination_table = $sql_reader.Item("destination_table")
    }

    $sql_reader.Close()
    $sql_command.Dispose()
    return $function_results

}

catch
{
    $function_results = [PSCustomObject]@{
            method_name       = ""
            screen_gid        = 0
            entity            = ""
            destination_table = "Not Found"
            error_message     = $Error[0]
    }

    return $function_results
}
