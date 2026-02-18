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
    $details_command = New-Object System.Data.SqlClient.SqlCommand
    $details_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $details_command.CommandText = "dbo.spConfig_LoadEntityDetails"
    $details_command.Connection  = $config_connection

    $details_command.Parameters.AddWithValue("@entity_name", $entity)   >> $null

    # Add the output parmeter @method_name
    $method_parameter = New-Object System.Data.SqlClient.SqlParameter
    $method_parameter.ParameterName = "@method_name"
    $method_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $method_parameter.DbType = [System.Data.DBType]'String'
    $method_parameter.Size = 100

    # Add the output parmeter @core_entity
    $core_entity_parameter = New-Object System.Data.SqlClient.SqlParameter
    $core_entity_parameter.ParameterName = "@core_entity"
    $core_entity_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $core_entity_parameter.DbType = [System.Data.DBType]'String'
    $core_entity_parameter.Size = 100

    # Add the output parmeter @screen_gid
    $screen_gid_parameter = New-Object System.Data.SqlClient.SqlParameter
    $screen_gid_parameter.ParameterName = "@screen_gid"
    $screen_gid_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $screen_gid_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @table_name
    $table_parameter = New-Object System.Data.SqlClient.SqlParameter
    $table_parameter.ParameterName = "@table_name"
    $table_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $table_parameter.DbType = [System.Data.DBType]'String'
    $table_parameter.Size = 100

    # Add the output parmeter @err_num
    $err_num_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_num_parameter.ParameterName = "@err_num"
    $err_num_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_num_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @err_msg
    $err_msg_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_msg_parameter.ParameterName = "@err_msg"
    $err_msg_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_msg_parameter.DbType = [System.Data.DBType]'String'
    $err_msg_parameter.Size = 4000

    $details_command.Parameters.Add($method_parameter)      >> $null
    $details_command.Parameters.Add($core_entity_parameter) >> $null
    $details_command.Parameters.Add($screen_gid_parameter)  >> $null
    $details_command.Parameters.Add($table_parameter)       >> $null
    $details_command.Parameters.Add($err_num_parameter)     >> $null
    $details_command.Parameters.Add($err_msg_parameter)     >> $null

    $details_command.ExecuteNonQuery() >> $null

    # Get the values returned from the stored procedure
    $method = $method_parameter.Value.ToString()
    $core_entity = $core_entity_parameter.Value.ToString()
    $screen_gid = $screen_gid_parameter.Value
    $destination_table = $table_parameter.Value.ToString()

    $err_num = $err_num_parameter.Value
    $err_msg = $err_msg_parameter.Value.ToString()

    if ($err_num -ne 0)
    {
        $location = "Attempting to call spConfig_LoadEntityDetails to get entity details"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }
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
    $field_results = .\Get-EntityScreenFields.ps1 -entity $core_entity -screen_gid $screen_gid -sql_connection $core_connection

    if (($field_results.procedure_name -eq "Not Found") -or ($field_results.screen_fields -eq 0))
    {
        #Log the error
        $location = "Attempting to get the current number of fields from the Core database"
        $err_msg = "Could not retrieve the populate procedure name or the number of fields from the Core database"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }
    else
    {
        $screen_fields  = $field_results.screen_fields
        $load_procedure = $field_results.procedure_name
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
try
{
    $validate_command = New-Object System.Data.SqlClient.SqlCommand
    $validate_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $validate_command.CommandText = "dbo.spConfig_LoadSettings"
    $validate_command.Connection  = $config_connection

    $validate_command.Parameters.AddWithValue("@method", $method)                 >> $null
    $validate_command.Parameters.AddWithValue("@screen_fields", $screen_fields)   >> $null
    $validate_command.Parameters.AddWithValue("@load_procedure", $load_procedure) >> $null

    # Add the output parmeter @parameter_count
    $parameter_count_parameter = New-Object System.Data.SqlClient.SqlParameter
    $parameter_count_parameter.ParameterName = "@parameter_count"
    $parameter_count_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $parameter_count_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @populte_sql
    $populate_sql_parameter = New-Object System.Data.SqlClient.SqlParameter
    $populate_sql_parameter.ParameterName = "@populate_sql"
    $populate_sql_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $populate_sql_parameter.DbType = [System.Data.DBType]'String'
    $populate_sql_parameter.Size = 4000

    # Add the output parmeter @load_id
    $load_id_parameter = New-Object System.Data.SqlClient.SqlParameter
    $load_id_parameter.ParameterName = "@load_id"
    $load_id_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $load_id_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @err_num
    $err_num_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_num_parameter.ParameterName = "@err_num"
    $err_num_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_num_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @err_msg
    $err_msg_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_msg_parameter.ParameterName = "@err_msg"
    $err_msg_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_msg_parameter.DbType = [System.Data.DBType]'String'
    $err_msg_parameter.Size = 4000

    $validate_command.Parameters.Add($parameter_count_parameter) >> $null
    $validate_command.Parameters.Add($populate_sql_parameter)    >> $null
    $validate_command.Parameters.Add($load_id_parameter)         >> $null
    $validate_command.Parameters.Add($err_num_parameter)         >> $null
    $validate_command.Parameters.Add($err_msg_parameter)         >> $null

    $validate_command.ExecuteNonQuery() >> $null

    # Get the values returned from the stored procedure
    $parameter_count = $parameter_count_parameter.Value
    $populate_sql = $populate_sql_parameter.Value.ToString()
    $load_id = $load_id_parameter.Value
    $err_num = $err_num_parameter.Value
    $err_msg = $err_msg_parameter.Value.ToString()

    if ($err_num -ne 0)
    {
        $location = "Attempting to call spConfig_LoadSettings to get load settings"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }
}
catch
{
    $location = "Attempting to get load settings and validate the load configuration"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Gather the parameters and build the command to add the data to Core
#**************************************************************************************************
try
{
    $parameter_command = New-Object System.Data.SqlClient.SqlCommand
    $parameter_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $parameter_command.CommandText = "dbo.spConfig_LoadDataParameters"
    $parameter_command.Connection  = $config_connection

    $parameter_command.Parameters.AddWithValue("@load_id", $load_id) >> $null

    # Add the output parmeter @err_num
    $err_num_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_num_parameter.ParameterName = "@err_num"
    $err_num_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_num_parameter.DbType = [System.Data.DBType]'Int16'

    # Add the output parmeter @err_msg
    $err_msg_parameter = New-Object System.Data.SqlClient.SqlParameter
    $err_msg_parameter.ParameterName = "@err_msg"
    $err_msg_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $err_msg_parameter.DbType = [System.Data.DBType]'String'
    $err_msg_parameter.Size = 4000

    $parameter_command.Parameters.Add($err_num_parameter) >> $null
    $parameter_command.Parameters.Add($err_msg_parameter) >> $null

    # Load any data into a data table to begin processing
    $parameter_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $parameter_adapter.SelectCommand = $parameter_command
    
    $parameter_data_set = New-Object System.Data.DataSet
    $parameter_adapter.Fill($parameter_data_set) >> $null

    $parameter_data = New-Object System.Data.DataTable
    $parameter_data = $parameter_data_set.Tables[0]

    # Get the error message and evaluate it
    $err_num = $err_num_parameter.Value
    $err_msg = $err_msg_parameter.Value.ToString()

    if ($err_num -ne 0)
    {
        $location = "Attempting to get a list of the parameters for the load stored procedure"
        .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
        Exit 1
    }
}
catch
{
    $location = "Attempting to get a list of the parameters for the stored procedure"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
#**************************************************************************************************
# Loop through the parameters and build the command that will call the populate stored procedure
#**************************************************************************************************
try
{
    $populate_command = New-Object System.Data.SqlClient.SqlCommand
    $populate_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $populate_command.CommandText = $load_procedure
    $populate_command.Connection  = $core_connection

    foreach($parameter_row in $parameter_data)
    {

        if ($parameter_row.IsOutput -ne 'Yes')
        {
            $input_parameter = New-Object System.Data.SqlClient.SqlParameter
            $input_parameter.ParameterName = $parameter_row.ParameterName
            $input_parameter.DbType = $parameter_row.DBType
            $input_parameter.Direction = [System.Data.ParameterDirection]'Input'

            if ($parameter_row.UseLength -eq 'Yes')
            {
                $input_parameter.Size = $parameter_row.SQLLength
            }
        }
        else
        {
            $input_parameter = New-Object System.Data.SqlClient.SqlParameter
            $input_parameter.ParameterName = $parameter_row.ParameterName
            $input_parameter.DbType = $parameter_row.DBType
            $input_parameter.Direction = [System.Data.ParameterDirection]'Output'

            if ($parameter_row.UseLength -eq 'Yes')
            {
                $input_parameter.Size = $parameter_row.SQLLength
            }
        }

        $populate_command.Parameters.Add($input_parameter) >> $null
    }
}
catch
{
    $location = "Attempting to build the command that will be used to call the stored procedure"
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
    $mapping_command.CommandText = "SELECT OutputOrder AS field_order, FieldName AS field_name FROM cfg.ActionLoadField WHERE LoadID = " + $load_id + ' AND LoadField = 1 AND SkipField = 0'

    $mapping_reader = $mapping_command.ExecuteReader()

    $sql_insert = "INSERT INTO [data].[" + $destination_table + "]([ConfigurationID],[ParentID],"
    $mapped_fields = @()

    while ($mapping_reader.Read())
    {
        # Add any fields to the INSERT sql and make note of the field that was mapped (for later use)
        $sql_insert += "[" + $mapping_reader.Item("field_name") + "],"
        $mapped_fields += $mapping_reader.Item("field_Order")
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
    $populate_sql_command = New-Object System.Data.SqlClient.SqlCommand
    $populate_sql_command.Connection = $core_connection
    $populate_sql_command.CommandText = $populate_sql
    $populate_sql_command.CommandTimeout = 0
    
    $populate_sql_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $populate_sql_adapter.SelectCommand = $populate_sql_command
    
    $populate_data_set = New-Object System.Data.DataSet
    $populate_sql_adapter.Fill($populate_data_set) >> $null

    $populate_data_table = New-Object System.Data.DataTable
    $populate_data_table = $populate_data_set.Tables[0]

    $count = 1

    $populate_results_command = New-Object System.Data.SqlClient.SqlCommand
    $populate_results_command.Connection = $core_connection
    $populate_results_command.CommandTimeout = 0

    $populate_results_adapter    = New-Object System.Data.SqlClient.SqlDataAdapter
    $populate_results_dataset    = New-Object System.Data.DataSet
    $populate_results_data_table = New-Object System.Data.DataTable

    $non_query_command = New-Object System.Data.SqlClient.SqlCommand
    $non_query_command.Connection = $config_connection

    foreach($populate_data_row in $populate_data_table)
    {
        # Generate the configuration ID and make sure there is no conflicting data in the desitnation
        $config_id = $configuration_id + $count.ToString().PadLeft(5,"0")
        $sql_delete = "DELETE FROM [data].[" + $destination_table + "] WHERE ConfigurationID = '" + $config_id + "'"
        $non_query_command.CommandText = $sql_delete
        $non_query_command.ExecuteNonQuery() >> $null

        # Loop through the stored procedure parameters setting the values
        for ($parameter_counter = 0; $parameter_counter -lt $parameter_count-1; $parameter_counter++)
        {
            $populate_command.Parameters[$parameter_counter].Value = $populate_data_row.Item($parameter_counter)
        }

        # Get the results back from the populate stored procedure
        $populate_results_adapter.SelectCommand = $populate_command
        $populate_results_adapter.Fill($populate_results_dataset) >> $null
        $populate_results_data_table = $populate_results_dataset.Tables[0]

        $parent_id = $populate_data_row.Item("parent_id")
        $sql_select = "SELECT " + "'" + $config_id + "','" + $parent_id + "',"

        # Loop through the results, adding only the fields that need to be mapped
        foreach ($field in $mapped_fields)
        {
            $sql_select = $sql_select + "'" + $populate_results_data_table.Rows[0].Item($field-1) + "',"
        }

            
        # Trim off the trailing comma
        $sql_select = $sql_select.Substring(0,$sql_select.Length-1)
        $sql = $sql_insert + " " + $sql_select
        
        # Insert the data into the Configuration table
        $non_query_command.CommandText = $sql
        $rowsInserted = $non_query_command.ExecuteNonQuery()

        $count += 1

        $populate_results_data_table.Clear()
        #$populate_data_set.Disopose()
        #$populate_command.Dispose()
    }

    $populate_data_table.Dispose()
    $populate_data_set.Dispose()
    $populate_sql_adapter.Dispose()

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