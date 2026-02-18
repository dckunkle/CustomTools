<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        03/31/2022	DK				Original script

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
[OutputType([Array])]
Param(

    [Parameter(Mandatory=$True)]
    [string]$core_instance,

    [Parameter(Mandatory=$True)]
    [string]$core_database,

    [Parameter(Mandatory=$True)]
    [string]$method_name,

    [Parameter(Mandatory=$True)]
    [string]$add_procedure,

    [Parameter(Mandatory=$True)]
    [Int16]$parameters,

    [Parameter(Mandatory=$True)]
    [string]$parent_id
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
# Get the Parent SQL that will be used to get the proper gid for the parent object
#**************************************************************************************************
try
{
    $parentSql_command = New-Object System.Data.SqlClient.SqlCommand
    $parentSql_command.Connection = $config_connection
    $parentSql_command.CommandTimeout = 0
    $parentSql_command.CommandText = "SELECT ParentSql FROM cfg.ActionAdd WHERE MethodName = @method AND CoreProcedure = @procedure AND ParameterCount = @parameters"

    $parentSql_command.Parameters.Add('@method', $method_name) >> $null
    $parentSql_command.Parameters.Add('@procedure', $add_procedure) >> $null
    $parentSql_command.Parameters.Add('@parameters', $parameters) >> $null

    $parentSql_reader = $parentSql_command.ExecuteReader()

    if ($parentSql_reader.HasRows)
    {
        $parentSql_reader.Read() >> $null
        $parent_sql = $parentSql_reader.Item("ParentSQL")
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
# Create connection object to the Core system and get the key fields for the parent ID
#**************************************************************************************************
try
{
    $core_connection = .\New-SQLConnection.ps1 -instance_name $core_instance -database $core_database

    $core_command = New-Object System.Data.SqlClient.SqlCommand
    $core_command.CommandText = $parent_sql
    $core_command.Connection  = $core_connection

    $core_command.Parameters.Add('@ParentID', $parent_id) >> $null
    $parentID_reader = $core_command.ExecuteReader()

    if ($parentID_reader.HasRows)
    {
        $parentID_reader.Read() >> $null
        
        [PSCustomObject]@{
            Key1  = $parentID_reader.Item("key1")
            Key2  = $parentID_reader.Item("key2")
            Key3  = $parentID_reader.Item("key3")
            Key4  = $parentID_reader.Item("key4")
            Key5  = $parentID_reader.Item("key5")
            Key6  = $parentID_reader.Item("key6")
            Key7  = $parentID_reader.Item("key7")
            Key8  = $parentID_reader.Item("key8")
            Key9  = $parentID_reader.Item("key9")
            Key10 = $parentID_reader.Item("key10")
        }
    }
    else
    {

        [PSCustomObject]@{
            Key1  = "Not Found"
            Key2  = ""
            Key3  = ""
            Key4  = ""
            Key5  = ""
            Key6  = ""
            Key7  = ""
            Key8  = ""
            Key9  = ""
            Key10 = ""
        }

    }

    $parentID_reader.Close()

    $core_command.Dispose()
    $core_connection.Close()
}
catch
{
    $location = "Attempting to get parent ID key values from the Core system"
    $err_msg = $_
    .\Write-ConfigError.ps1 -script_name $script_name -script_location $location -error_message $err_msg
    Exit 1
}