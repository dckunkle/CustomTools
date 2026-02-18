<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/12/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This function returns the number of fields that are defined for a Core screen as well as the current stored procedure used to populate the screen

    
    .DESCRIPTION

        This function is used to determine the number of fields for a screen as well as the current populate stored procdure. The information is used to determine if the Configuration database supports the combination of fields and stored procedure. When screens are updated in Core, a new field is typically added. Therefore the number of fields is being used to determine the "version" of the screen.


    .PARAMETER entity

        Specifies the Core entity name that is used in the Entity_Screen_Action table
    

    .PARAMETER screen_gid

        Specifies the screen_gid used for the screen data being loaded. 
        

    .PARAMETER sql_connection

        The SQL connection object to use to connect to the Configuration database

#>


[CmdLetBinding()]
[OutputType([object])]

Param(

    [Parameter(Mandatory=$True)]
    [string]$entity,

    [Parameter(Mandatory=$True)]
    [int16]$screen_gid,

    [Parameter(Mandatory=$False)]
    [string]$action,

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
    $sql_command.CommandText = "SELECT COUNT(*) + 5 AS screen_fields FROM dbo.Screen_Details WITH (NOLOCK) WHERE screen_gid = " + $screen_gid + " AND Data_Type NOT IN ('SPACE','EXPAND')"
    $sql_reader = $sql_command.ExecuteReader()

    $function_results = [PSCustomObject]@{

        procedure_name = "Not Found"
        screen_fields  = 0
        error_message  = ""
    }

    if ($sql_reader.HasRows)
    {
        while ($sql_reader.Read())
        {
            $function_results.screen_fields = $sql_reader.Item("screen_fields")
        }
    }

    $sql_reader.Close()
    $sql_command.CommandText = "SELECT populate_stored_proc AS procedure_name FROM dbo.Entity_Screen_Action WITH (NOLOCK) WHERE screen_gid = " + $screen_gid + " AND entity = '" + $entity + "' AND action IN ('ADD','MODIFY') AND ISNULL(populate_stored_proc, '') <> ''"
    $sql_reader = $sql_command.ExecuteReader()

    if ($sql_reader.HasRows)
    {
        while ($sql_reader.Read())
        {
            $function_results.procedure_name = $sql_reader.Item("procedure_name")
        }
    }

    $sql_reader.Close()
    $sql_command.Dispose()
    return $function_results
}

catch
{
    $function_results = [PSCustomObject]@{
        procedure_name = "Not Found"
        screen_fields  = 0
        error_message  = $Error[0]
    }

    return $function_results
}

