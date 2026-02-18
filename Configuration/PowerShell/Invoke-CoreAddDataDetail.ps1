<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        02/26/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script adds data to Core for a given method. For example, when passed BenefitStrategy
        it will load all of the benefit strategis from the data.BenefitStrategy table that match
        the config_id that has been passed in.

    
    .DESCRIPTION

        This script will add configuration to the target Core system. The Configuration database is 
        used to determine what configuration to add to the target based on the ConfigID.
    
    
    .PARAMETER method_name
        
        Specifies the type of data to be added to the Core system (e.g. BenefitStrategy)


    .PARAMETER parameters

        Specifies the number of parameters required by the add stored procedure that is being used
        to add the data in Core


    .PARAMETER add_procedure

        Specifies the name of the stored procedure that will be called in Core to add the data


    .PARAMETER add_id

        Specifies the id from the cfg.ActionAddDetail id to use to gather the necessary parameters to
        call the add_procedure

    
    .PARAMETER confid_id

        Specifies the configuration ID pattern to use to match records in the corresponding table. Any
        matching records will be processed (e.g. Bright% will add any records where the ConfigurationID 
        begins with Bright)


    .PARAMETER core_server

        Specifies the abbreviation of the system to gather the Core data from (e.g. QR06 for aldqadbqr06)


    .PARAMETER database

        Specifies the databae name of the target Core system where the data will be added


    .PARAMETER user_id

        Specifies the user_id to be used when creating the data in the Core system. This value will be 
        populated in the user_id_created field and user_id fields in Core to help identify data that
        has been added using this process


    .PARAMETER log_id

        Specifies the log ID that is to be used for logging the activity

#>


[CmdletBinding()]
[OutputType([Array])]
Param(

    [Parameter(Mandatory=$True)]
    [string]$method_name,

    [Parameter(Mandatory=$True)]
    [int16]$parameters,

    [Parameter(Mandatory=$True)]
    [string]$add_procedure,

    [Parameter(Mandatory=$True)]
    [int16]$add_id,

    [Parameter(Mandatory=$True)]
    [string]$config_id,

    [Parameter(Mandatory=$True)]
    [string]$core_server,

    [Parameter(Mandatory=$True)]
    [string]$database,

    [Parameter(Mandatory=$True)]
    [string]$user_id,

    [Parameter(Mandatory=$True)]
    [int32]$log_id

)

$script_name = $MyInvocation.MyCommand.Name

#**************************************************************************************************
# Set up some intial values
#**************************************************************************************************
$status = "Add"
$err_num = 0
$err_msg = "Success"
$key_data_1 = ""
$key_data_2 = ""
$key_data_3 = ""

#**************************************************************************************************
# Create connection object to the Configuration database
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
    $location = "Attempting to connect to the target system database"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
   
#**************************************************************************************************
# Get a list of all of the data to be added to the Core system
#**************************************************************************************************
try
{
    $config_command = New-Object System.Data.SqlClient.SqlCommand
    $config_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $config_command.CommandText = "dbo.spConfig_AddData"
    $config_command.Connection  = $config_connection

    $config_command.Parameters.AddWithValue("@method",        $method_name)   >> $null
    $config_command.Parameters.AddWithValue("@add_procedure", $add_procedure) >> $null
    $config_command.Parameters.AddWithValue("@parameters",    $parameters)    >> $null
    $config_command.Parameters.AddWithValue("@config_id",     $config_id)     >> $null
    $config_command.Parameters.AddWithValue("@user_id",       $user_id)       >> $null

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

    $config_command.Parameters.Add($err_num_parameter) >> $null
    $config_command.Parameters.Add($err_msg_parameter) >> $null

    # Load any data into a data table to begin processing
    $config_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $config_adapter.SelectCommand = $config_command
    
    $config_data_set = New-Object System.Data.DataSet
    $config_adapter.Fill($config_data_set)  >> $null

    $config_data = New-Object System.Data.DataTable
    $config_data = $config_data_set.Tables[0]

    # TODO: Do something if an error is returned
    #Write-Host $config_command.Parameters["@err_num"].Value.ToString()
    #Write-Host $config_command.Parameters["@err_msg"].Value.ToString()

}
Catch
{
    $location = "Attempting to get a list of all the data to add into Core for " + $method_name
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
    $parameter_command.CommandText = "dbo.spConfig_AddDataParameters"
    $parameter_command.Connection  = $config_connection

    $parameter_command.Parameters.AddWithValue("@method",        $method_name)   >> $null
    $parameter_command.Parameters.AddWithValue("@add_procedure", $add_procedure) >> $null
    $parameter_command.Parameters.AddWithValue("@parameters",    $parameters)    >> $null
    $parameter_command.Parameters.AddWithValue("@add_id",        $add_id)        >> $null

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

}
catch
{
    $location = "Attempting to get a list of the parameters for the stored procedure"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Get the Parent SQL that will be used to get the proper gid for the parent object
#**************************************************************************************************
try
{
    $parentSql_command = New-Object System.Data.SqlClient.SqlCommand
    $parentSql_command.Connection = $config_connection
    $parentSql_command.CommandTimeout = 0
    $parentSql_command.CommandText = "SELECT ParentSQL, DuplicateSQL, DuplicateFields FROM cfg.ActionAdd WHERE MethodName = @method AND CoreProcedure = @procedure AND ParameterCount = @parameters"

    $parentSql_command.Parameters.Add('@method', $method_name) >> $null
    $parentSql_command.Parameters.Add('@procedure', $add_procedure) >> $null
    $parentSql_command.Parameters.Add('@parameters', $parameters) >> $null

    $parentSql_reader = $parentSql_command.ExecuteReader()

    if ($parentSql_reader.HasRows)
    {
        $parentSql_reader.Read() >> $null
        $parent_sql       = $parentSql_reader.Item("ParentSQL")
        $duplicate_sql    = $parentSql_reader.Item("DuplicateSQL")
        $dupe_fields      = $parentSql_reader.Item("DuplicateFields")
        $duplicate_fields = $dupe_fields.Split(";")
        #Write-Host $parent_sql
    }

    $parentSql_reader.Close()
    $parentSql_command.Dispose()
}
catch
{
    $location = "Attempting to retrieve the SQL command to find the parent object"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Loop through the parameters and build the command
#**************************************************************************************************
try
{
    # Variables used to capture the name of the @o_status and @o_message variables
    $status_variable = ""
    $message_variable = ""

    $procedure_command = New-Object System.Data.SqlClient.SqlCommand
    $procedure_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $procedure_command.CommandText = $add_procedure
    $procedure_command.Connection  = $core_connection

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

            if ($status_variable -eq ""){ $status_variable = $parameter_row.ParameterName}
            if ($status_variable -ne ""){ $message_variable = $parameter_row.ParameterName}
        }

        $procedure_command.Parameters.Add($input_parameter) >> $null

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
# Build the command that will be used to log the detail
#**************************************************************************************************
try
{

    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $log_command.CommandText = "dbo.spConfig_LogEventDetail"
    $log_command.Connection  = $config_connection

    $log_command.Parameters.Add("@log_id",     [Data.SQLDBType]::Int)          >> $null
    $log_command.Parameters.Add("@config_id",  [Data.SQLDBType]::VarChar, 200) >> $null
    $log_command.Parameters.Add("@method",     [Data.SQLDBType]::VarChar, 100) >> $null
    $log_command.Parameters.Add("@record_id",  [Data.SQLDBType]::Int)          >> $null
    $log_command.Parameters.Add("@key_data_1", [Data.SQLDBType]::VarChar, 100) >> $null
    $log_command.Parameters.Add("@key_data_2", [Data.SQLDBType]::VarChar, 100) >> $null
    $log_command.Parameters.Add("@key_data_3", [Data.SQLDBType]::VarChar, 100) >> $null
    $log_command.Parameters.Add("@status",     [Data.SQLDBType]::VarChar, 10)  >> $null
    $log_command.Parameters.Add("@err_num",    [Data.SQLDBType]::Int)          >> $null
    $log_command.Parameters.Add("@err_msg",    [Data.SQLDBType]::VarChar, 200) >> $null

    $config_command.ExecuteNonQuery() >> $null

}
catch
{
    $location = "Attempting to build the command that will be used to log activity"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
#**************************************************************************************************
# Loop through all of the data that should be added to the Core system
#**************************************************************************************************
try
{
    $log_count = 0
    $sql_text = "INSERT INTO log.ConfigDetail(log_id, config_id, method, record_id, key_data_1, key_data_2, key_data_3, status, err_num, err_msg) VALUES "

    foreach($config_row in $config_data)
    {

        # Gather the data for logging
        $key_data_1 = $config_row.log1
        $key_data_2 = $config_row.log2
        $key_data_3 = $config_row.log3
        $record_id  = $config_row.record_id
        $config_id  = $config_row.ConfigurationID
        $parent_id  = $config_row.ParentID

        $status     = 'Add'
        $err_num    = 0
        $err_msg    = 'Successful'

        # The number of parameters does not include the status and message fields
        $procedure_parameters = $procedure_command.Parameters.Count - 3

        # Add values to the command before making the call to the stored procedure
        for ($counter = 0; $counter -le $procedure_parameters; $counter++)
        {
            #Write-Host $procedure_command.Parameters[$counter].ParameterName " - " $config_row.Item($counter + 5)
            $procedure_command.Parameters[$counter].Value = $config_row.Item($counter + 5)
        }

        # Determine if there is a custom duplicate check, if so check
        if ($duplicate_sql -ne "")
        {
            $duplicate_command = New-Object System.Data.SqlClient.SqlCommand
            $duplicate_command.CommandText = $duplicate_sql
            $duplicate_command.Connection  = $core_connection

            for ($d = 0; $d -le $duplicate_fields.Count-1; $d++)
            {
                $v = $d + 1
                $variable_name = '@var' + $v
                $duplicate_command.Parameters.Add($variable_name, $config_row[$duplicate_fields[$d]]) >> $null
            }
            
            $duplicate_reader = $duplicate_command.ExecuteReader()

            if ($duplicate_reader.HasRows)
            {
                $err_num = 5002
                $err_msg = "Custom duplictae record found."
            }


            $duplicate_reader.Close()
        }

        # Determine if there is a parent ID and if data needs to be looked up for it
        if (($parent_id -ne ""))
        {   
            $core_command = New-Object System.Data.SqlClient.SqlCommand
            $core_command.CommandText = $parent_sql
            $core_command.Connection  = $core_connection

            $core_command.Parameters.Add('@ParentID', $parent_id) >> $null
            $parentID_reader = $core_command.ExecuteReader()

            if ($parentID_reader.HasRows)
            {
                $parentID_reader.Read() >> $null
        
        #$key_values = .\Get-CoreParentKeys.ps1 -core_instance $core_instance -core_database $core_database -method_name $method_name -add_procedure $add_procedure -parameters $parameters -parent_id $parent_id

                # Update the keys values for the stored procedure call
                $procedure_command.Parameters[1].Value = $parentID_reader.Item("key1")
                $procedure_command.Parameters[2].Value = $parentID_reader.Item("key2")
                $procedure_command.Parameters[3].Value = $parentID_reader.Item("key3")
                $procedure_command.Parameters[4].Value = $parentID_reader.Item("key4")
                $procedure_command.Parameters[5].Value = $parentID_reader.Item("key5")
                $procedure_command.Parameters[6].Value = $parentID_reader.Item("key6")
                $procedure_command.Parameters[7].Value = $parentID_reader.Item("key7")
                $procedure_command.Parameters[8].Value = $parentID_reader.Item("key8")
                $procedure_command.Parameters[9].Value = $parentID_reader.Item("key9")
                $procedure_command.Parameters[10].Value = $parentID_reader.Item("key10")
            }
            else
            {
                $err_num = 4002
                $err_msg = "ParentID, " + $parent_id + ", could not be found in the target database. Unable to add data."
            }

            $parentID_reader.close()
        }

        # If there are no errors execute the stored procedure to add the data to Core
        if ($err_num -eq 0)
        {
            # Execute the stored procedure to add the data to Core
            $procedure_command.ExecuteNonQuery() >> $null

            $err_num = $procedure_command.Parameters[$status_variable].Value.ToString()
            $err_msg = $procedure_command.Parameters[$message_variable].Value.ToString()

        }

        #**************************************************************************************************
        # Log the results 10 at a time to improve performance
        #**************************************************************************************************
        if ($log_count -le 10)
        {
            $log_count++

            $sql_text = $sql_text + "('" + $log_id + "','" + $config_id + "','" + $method_name + "','" + $record_id + "','" + $key_data_1 + "','"
            $sql_text = $sql_text + $key_data_2 + "','" + $key_data_3 + "','" + $status + "','" + $err_num + "','" + $err_msg + "'),"
        }
        else
        {
            # Remove the trailing comma
            $sql_text = $sql_text.Substring(0, $sql_text.Length - 1)

            # Save the log, reset the counter and reset the SQL statement
            Invoke-Sqlcmd -Query $sql_text -ServerInstance "wqadbhpauto01" -Database "Configuration"

            $log_count = 0
            $sql_text = "INSERT INTO log.ConfigDetail(log_id, config_id, method, record_id, key_data_1, key_data_2, key_data_3, status, err_num, err_msg) VALUES "
            $sql_text = $sql_text + "('" + $log_id + "','" + $config_id + "','" + $method_name + "','" + $record_id + "','" + $key_data_1 + "','"
            $sql_text = $sql_text + $key_data_2 + "','" + $key_data_3 + "','" + $status + "','" + $err_num + "','" + $err_msg + "'),"
        }

    }

    # If no records were found to execute then skip logging
    if($log_count -ne 0)
    {
        # Make sure to log the last entries
        $sql_text = $sql_text.Substring(0, $sql_text.Length - 1)
        Invoke-Sqlcmd -Query $sql_text -ServerInstance "wqadbhpauto01" -Database "Configuration"
    }
}
catch
{
    $location = "Attempting to execute the command that calls the stored procedure"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}
