<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/12/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Collect Core data from a target system for the provided entity name

    
    .DESCRIPTION

        This script will gather and format the data for a specific entity in Core and copy the data into the Configuration database. The data can then be distributed to other Core systems.


    .PARAMETER entity

        Specifies the human readable entity name (e.g. Type of Bill vs Core entity Type_of_Bill)
    

    .PARAMETER core_server

        Specifies the abbreviation of the system to gather the Core data from (e.g. QR06 for aldqadbqr06)


    .PARAMETER configuration_id

        Specifies the string that will be used as the root to construct the configuration ids for the data being loaded


    .PARAMETER filter

        Currently not supported. In the future, will allow a user to filter specific entities to load. (e.g. 400% would load any Price Schedule beginning with 400)

#>


[CmdletBinding()]
[OutputType([Array])]
Param(

    [Parameter(Mandatory=$True)]
    [string]$entity,

    [Parameter(Mandatory=$True)]
    [string]$core_server,

    [Parameter(Mandatory=$True)]
    [string]$configuration_id,

    [Parameter(Mandatory=$False)]
    [string]$filter
)

$script_name = $MyInvocation.MyCommand.Name

#**************************************************************************************************
# Create connection object for the Configuration database
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
# Create connection object for the Core database
#**************************************************************************************************
try
{
    $server_results = .\Get-SourceServer.ps1 -server_abbreviation $core_server

    if (($server_results.core_database -eq "Not Found") -or ($server_results.sql_instance -eq "Not Found")) 
    {
        #Log the error
        Write-Host "Error: Could not retrieve the Core server details from the System database"
        Write-Host $server_results.error_message
        Exit 1
    }
    else
    {
        $core_instance   = $server_results.sql_instance
        $core_database   = $server_results.core_database
    }

    $core_connection = .\New-SQLConnection.ps1 -instance_name $core_instance -database $core_database

    Write-Debug "Core connection created"
}
catch
{
    $location = "Attempting to connect to the Core database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Lookup the core entity name and screen gid for the given $entity
#**************************************************************************************************
try
{
    $entity_results = .\Get-EntityDetails.ps1 -entity $entity -sql_connection $config_connection

    if (($entity_results.error_message -ne "") -or ($entity_results.screen_gid -eq $null))
    {
        #Log the error
        Write-Host "Error: Could not retrieve the entity and/or screen gid from the Configuration database"
        Write-Host $entity_results.error_message
        Exit 1
    }
    else
    {
        $method            = $entity_results.method_name
        $entity            = $entity_results.entity
        $screen_gid        = $entity_results.screen_gid
        $destination_table = $entity_results.destination_table
    }

    Write-Debug "Entity details retrieved"

}
catch
{
    $location = "Attempting to get screen gid and entity name from the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Determine the current number of fields defined for the screen in the Core database
#**************************************************************************************************
try
{
    $field_results = .\Get-EntityScreenFields.ps1 -entity $entity -screen_gid $screen_gid -sql_connection $core_connection

    if (($field_results.procedure_name -eq "Not Found") -or ($field_results.screen_fields -eq 0))
    {
        #Log the error
        Write-Host 'Error: Could not retrieve the populate procedure name or the number of fields from the Core database'
        Write-Host $entity_results.error_message
        Exit 1
    }
    else
    {
        $screen_fields  = $field_results.screen_fields
        $procedure_name = $field_results.procedure_name
    }

    Write-Debug "Screen details retrieved"

}
catch
{
    $location = "Attempting to get the number of fields currently defined in the Core database for the screen"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
#**************************************************************************************************
# Verify that the Configuration database has been set up to support loading this entity
#**************************************************************************************************


#**************************************************************************************************
# Get the configuration details for calling the populate stored procedure for the entity
#**************************************************************************************************
try
{
    $populate_results = .\Get-EntityPopulateDetails.ps1 -method $method -sql_connection $config_connection 

    if (($populate_results.error_message -ne "") -or ($populate_results.populate_sql -eq "Not Found")) 
    {
        #Log the error
        Write-Host "Error: Could not retrieve populate details from the Configuration database"
        Exit 1
    }
    else
    {
        $populate_sql       = $populate_results.populate_sql
        $populate_procedure = $populate_results.populate_procedure
    }
    
}
catch
{
    $location = "Attempting to get the populate details for the entity from the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Determine the Load ID for the combination of entity, screen_gid and number of fields
#**************************************************************************************************
try 
{
    $load_results = .\Get-ConfigurationLoadID.ps1 -method $method -screen_fields $screen_fields -sql_connection $config_connection

    if (($load_results.error_message -ne "") -or ($load_results.load_id -eq 0)) 
    {
        #Log the error
        Write-Host "Error: Could not retrieve the load id for the combination of screen gid, entity and fields"
        Write-Host $load_results.error_message
        Exit 1
    }
    else
    {
        $load_id = $load_results.load_id
    }

}
catch
{
    $location = "Attempting to get the load id for the entity and screen from the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Get the field mapping for the entity and screen combination
#**************************************************************************************************
try
{
    $mapping_command = New-Object System.Data.SqlClient.SqlCommand
    $mapping_command.Connection = $config_connection
    $mapping_command.CommandTimeout = 0
    $mapping_command.CommandText = "SELECT ColumnOrder AS column_order, ColumnName AS column_name FROM cfg.ActionLoadDetail WHERE LoadID = " + $load_id + ' AND LoadColumn = 1'

    $mapping_reader = $mapping_command.ExecuteReader()

    $sql_insert = "INSERT INTO [data].[" + $destination_table + "]([ConfigurationID],[ParentID],"
    $mapping_fields = 0

    while ($mapping_reader.Read())
    {
        $sql_insert += "[" + $mapping_reader.Item("column_name") + "],"
        $mapping_fields += 1
    }

    $sql_insert = $sql_insert.Substring(0,$sql_insert.Length-1) + ")"

    $mapping_reader.Close()
    $mapping_command.Dispose()
}
catch
{
    $location = "Attempting to get field mapping details from the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Now we are ready to start getting the data to submit to Core to retrieve the data
#**************************************************************************************************
try
{
    $sql_command = New-Object System.Data.SqlClient.SqlCommand
    $sql_command.Connection = $core_connection
    $sql_command.CommandText = $populate_sql
    $sql_command.CommandTimeout = 0
    
    $sql_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $sql_adapter.SelectCommand = $sql_command
    
    $data_set = New-Object System.Data.DataSet
    $return_value = $sql_adapter.Fill($data_set) 

    $data_table = New-Object System.Data.DataTable
    $data_table = $data_set.Tables[0]

    $count = 1

    $populate_command = New-Object System.Data.SqlClient.SqlCommand
    $populate_command.Connection = $core_connection
    $populate_command.CommandTimeout = 0

    $populate_adapter    = New-Object System.Data.SqlClient.SqlDataAdapter
    $populate_dataset    = New-Object System.Data.DataSet
    $populate_data_table = New-Object System.Data.DataTable

    $non_query_command = New-Object System.Data.SqlClient.SqlCommand
    $non_query_command.Connection = $config_connection

    foreach($data_row in $data_table)
    {
        $config_id = $configuration_id + $count.ToString().PadLeft(5,"0")

        $key1      = $data_row.key1
        $key2      = $data_row.key2
        $key3      = $data_row.key3
        $key4      = $data_row.key4
        $key5      = $data_row.key5
        $key6      = $data_row.key6
        $key7      = $data_row.key7
        $key8      = $data_row.key8
        $key9      = $data_row.key9
        $key10     = $data_row.key10
        $parent_id = $data_row.parent_id

        $populate_sql = "EXEC " + $populate_procedure + "'" + $entity + "','" + $key1  + "','" + $key2 +"','" + $key3 +"','" + $key4 +"','" + $key5 +"','" + $key6 +"','" + $key7 +"','" + $key8 +"','" +$key9+"','" +$key10+"','', 0, ''"
        
        $sql_select = "SELECT " + "'" + $config_id + "','" + $parent_id + "',"
        $sql_delete = "DELETE FROM [data].[" + $destination_table + "] WHERE ConfigurationID = '" + $config_id + "'"

        # Get the results back from the populate stored procedure
        $populate_command.CommandText = $populate_sql
        $populate_adapter.SelectCommand = $populate_command
        [void]$populate_adapter.Fill($populate_dataset) 

        $populate_data_table = $populate_dataset.Tables[0]

        for ($item_count = 0; $item_count -lt $mapping_fields; $item_count++)
        {
            $sql_select = $sql_select + "'" + $populate_data_table.Rows[0].Item($item_count) + "',"
        }

            
        # Trim off the trailing comma
        $sql_select = $sql_select.Substring(0,$sql_select.Length-1)
        $sql = $sql_insert + " " + $sql_select

        # Delete any existing data for this configuration ID
        $non_query_command.CommandText = $sql_delete
        $rowsDeleted = $non_query_command.ExecuteNonQuery()

        $non_query_command.CommandText = $sql
        $rowsInserted = $non_query_command.ExecuteNonQuery()

        $count += 1

        $populate_data_table.Clear()
        #$populate_data_set.Disopose()
        #$populate_command.Dispose()
    }

    $data_table.Dispose()
    $data_set.Dispose()
    $sql_adapter.Dispose()

    #**************************************************************************************************
    # Close the databae connections
    #**************************************************************************************************
    $config_connection.Close()
    $core_connection.Close()
}

catch
{
    $location = "Attempting to load the Core data onto the Configuration database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}