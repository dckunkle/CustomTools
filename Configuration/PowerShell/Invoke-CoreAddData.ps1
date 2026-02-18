<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        02/26/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        Add configuration data to the target Core system

    
    .DESCRIPTION

        This script will add configuration to the target Core system. The Configuration database is 
        used to determine what configuration to add to the target based on the ConfigID.
    

    .PARAMETER core_server

        Specifies the abbreviation of the system to gather the Core data from (e.g. QR06 for aldqadbqr06)


    .PARAMETER config_id

        Specifies the configuration ID used to add the data to the Core system. This could represent one 
        configuration ID or multiple if a wildcard is used. (e.g. Bright or Bright%)


    .PARAMETER email_address

        Specifies the email address(es) to send the results email to


    .PARAMETER build_id

        Specifies the build ID, from Jenkins, that started the process


    .PARAMETER job_name

        Specifies the Jenkins job name that was used to start the process

#>


[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$core_server,

    [Parameter(Mandatory=$True)]
    [string]$config_id,

    [Parameter(Mandatory=$false)]
    [string]$email_address,

    [Parameter(Mandatory=$false)]
    [int16]$build_id,

    [Parameter(Mandatory=$false)]
    [string]$job_name

)

$script_name = $MyInvocation.MyCommand.Name

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
# Start logging
#**************************************************************************************************
try
{
    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $log_command.CommandText = "dbo.spConfig_LogEvent"
    $log_command.Connection  = $config_connection

    $log_command.Parameters.AddWithValue("@target_system",   $core_instance) >> $null
    $log_command.Parameters.AddWithValue("@target_database", $core_database) >> $null
    $log_command.Parameters.AddWithValue("@config_id",       $config_id)     >> $null
    $log_command.Parameters.AddWithValue("@email_address",   $email_address) >> $null
    $log_command.Parameters.AddWithValue("@build_id",        $build_id)      >> $null
    $log_command.Parameters.AddWithValue("@job_name",        $job_name)      >> $null

    # Add the output parmeter @log_id
    $log_parameter = New-Object System.Data.SqlClient.SqlParameter
    $log_parameter.ParameterName = "@log_id"
    $log_parameter.Direction = [System.Data.ParameterDirection]'Output'
    $log_parameter.DbType = [System.Data.DBType]'Int16'

    $log_command.Parameters.Add($log_parameter) >> $null

    $log_command.ExecuteNonQuery() >> $null
    $log_id = $log_command.Parameters["@log_id"].Value

    $log_command.Dispose()

}
catch
{
    $location = "Attempting to create a new log"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Gather the steps to execute
#**************************************************************************************************
try
{
    $steps_command = New-Object System.Data.SqlClient.SqlCommand
    $steps_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $steps_command.CommandText = "dbo.spConfig_AddDataSteps"
    $steps_command.Connection  = $config_connection

    $steps_command.Parameters.AddWithValue("@config_id", $config_id) >> $null

    # Load any data into a data table to begin processing
    $steps_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $steps_adapter.SelectCommand = $steps_command
    
    $steps_data_set = New-Object System.Data.DataSet
    $steps_adapter.Fill($steps_data_set)  >> $null

    $steps_data = New-Object System.Data.DataTable
    $steps_data = $steps_data_set.Tables[0]

}
catch
{
    $location = "Gathering the steps to process on the target system"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Loop through the steps processing each
#**************************************************************************************************
try
{
    foreach($steps_row in $steps_data)
    {

        # Reset variables
        $procedure_name = $steps_row.CoreProcedure
        $error_found = 0
        $err_num = 0
        $err_msg = "Successful"
        $status = ""

        $step_config_id = $steps_row.ConfigIDPattern
        $method_name = $steps_row.ConfigStep
        $user_id = $steps_row.ConfigUser
        $add_id = 1

        Write-Host $method_name
        Write-Host $procedure_name

        # Make sure there is a stored procedure configured, if so
        if ($procedure_name -ne "Not Defined")
        {
            $parameters = 0
            # On the target system, determine how many parameters are required for the stored procedure
            $procedure_command = New-Object System.Data.SqlClient.SqlCommand
            $procedure_command.Connection = $core_connection
            $procedure_command.CommandTimeout = 0
            $procedure_command.CommandText = "SELECT COUNT(*) AS Count FROM sys.parameters P JOIN sys.procedures PR ON P.object_id	= PR.object_id WHERE PR.name = '" + $steps_row.CoreProcedure + "'" 

            $procedure_reader = $procedure_command.ExecuteReader()

            if ($procedure_reader.HasRows)
            {
                $procedure_reader.Read() >> $null
                $parameters = $procedure_reader.Item("Count")
            }

            $procedure_reader.Close()
        }
        else
        {
            $error_found = 1
            $status  = "Error"
            $err_num = 3001
            $err_msg = "The Core procedure has not been configured in the Configuration database"
        }

        if ($parameters -ne 0) # -and ($error_found -ne 1))
        {
            $add_id = 0

            # From the Configuration database, determine the AddID to use from the cfg.ActionAdd table
            $add_id_command = New-Object System.Data.SqlClient.SqlCommand
            $add_id_command.Connection = $config_connection
            $add_id_command.CommandTimeout = 0
            $add_id_command.CommandText = "SELECT AddID FROM cfg.ActionAdd WHERE MethodName = '" + $method_name + "' AND CoreProcedure = '" + $steps_row.CoreProcedure + "' AND ParameterCount = " + $parameters 

            $add_id_reader = $add_id_command.ExecuteReader()

            If ($add_id_reader.HasRows)
            {
                $add_id_reader.Read() >> $null
                $add_id = $add_id_reader.Item("AddID")
            }

            $add_id_reader.Close()
        }
        else
        {
            $error_found = 1
            $status = "Error"
            $err_num = 3002
            $err_msg = "The Core procedure, " + $procedure_name + ", configured for this step could not be found in the target system"
        }

        if ($add_id -eq 0)
        {
            $error_found = 1
            $status = "Error"
            $err_num = 3003
            $err_msg = "The AddID could not be determined (" + $procedure_name + "," + $method_name + "," + $parameters + ")"
            
        }

        # Check to see if there was an error, if not proceed, otherwise log the error
        if ($error_found -eq 0)
        {
            .\Invoke-CoreAddDataDetail.ps1 -method_name $method_name -parameters $parameters -config_id $step_config_id -core_server $core_server -database "QR06APP" -user_id $user_id -log_id $log_id -add_procedure $procedure_name -add_id $add_id
        }
        else
        {
        Write-Host $procedure_name + $parameters
            .\Write-ConfigLogDetail.ps1 -log_id $log_id -config_id $step_config_id -method_name $method_name -record_id $record_id -key_data_1 $key_data_1 -key_data_2 $key_data_2 -key_data_3 $key_data_3 -status $status -err_num $err_num -err_msg $err_msg
        }
    }

}
catch
{
    $location = "Looping through each step to process on the target system"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}

#**************************************************************************************************
# Complete logging
#**************************************************************************************************
try
{
    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $log_command.CommandText = "dbo.spConfig_LogEventFinish"
    $log_command.Connection  = $config_connection

    $log_command.Parameters.AddWithValue("@log_id", $log_id) >> $null
    $log_command.ExecuteNonQuery() >> $null

    $log_command.Dispose()

}
catch
{
    $location = "Completing the log"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}