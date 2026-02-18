<# ***************************************************************************************************
Purpose:      Lookup the details necessary to connect to the source server 
Parameters: 
    
    entity    - the URL is assumed to be in the following format
    server    - the name of the SQL Server where the configuration is stored
    database  - the name of the database in the configuration server

Date        User            Change
---------------------------------------------------------------------------------------------
01/12/2022	DK				Original script

---------------------------------------------------------------------------------------------

*************************************************************************************************** #>

[CmdLetBinding()]
[OutputType([object])]

Param(

    [Parameter(Mandatory=$True)]
    [string]$server_abbreviation

)

#**************************************************************************************************
# Try to connect to the database and retrieve the screen and entity
#**************************************************************************************************
try
{
    $Error.Clear()
    $connection_string = "Server=wqadbhpauto01;Database=SystemAudit;Trusted_Connection=True;"

    #Create the connection to the SQL Server
    $sql_connection = New-Object System.Data.SqlClient.SqlConnection
    $sql_connection.ConnectionString = $connection_string
    $sql_connection.Open()
    
    #Create the SQL Command to query the database for the entity
    $sql_command = New-Object System.Data.SqlClient.SqlCommand
    $sql_command.Connection = $sql_connection
    $sql_command.CommandText = "SELECT instance_name, core_database FROM dbo.Server WITH (NOLOCK) WHERE server_abbreviation = '" + $server_abbreviation + "'"
    $sql_reader = $sql_command.ExecuteReader()


    while ($sql_reader.Read())
    {
        $function_results = [PSCustomObject]@{

            sql_instance   = "Not Found"
            core_database  = "Not Found"
            error_message  = ""
        }

        $function_results.sql_instance = $sql_reader.Item("instance_name")
        $function_results.core_database = $sql_reader.Item("core_database")
    }

    $sql_reader.Close()
    $sql_command.Dispose()
    return $function_results
}

catch
{
    $function_results = [PSCustomObject]@{

        sql_instance   = "Not Found"
        core_database  = "Not Found"
        error_message  = $Error[0]
    }

    return $function_results 
}


