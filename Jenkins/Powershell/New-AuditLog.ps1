<# ***************************************************************************************************
Purpose:    Write to the log.Log table 

Date        User            Change
---------------------------------------------------------------------------------------------
08/02/2021	DK				Original script
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
 
    [Parameter(Mandatory=$True)]
    [string]$log_type,

    [Parameter(Mandatory=$True)]
    [string]$log_type_desc,

    [Parameter()]
    [string]$source,

    [Parameter()]
    [string]$jenkins_build,

    [Parameter()]
    [string]$jenkins_project,

    [Parameter()]
    [string]$email_address
)

#--------------------------------------------------------------------------------------------------
# Important Values
#--------------------------------------------------------------------------------------------------
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"

#--------------------------------------------------------------------------------------------------
# Create the new log
#--------------------------------------------------------------------------------------------------
$error.Clear()

try
{

    $sql = "INSERT INTO log.Log
              (log_type
              ,type_description
              ,user_name
              ,source
              ,begin_date
              ,jenkins_build
              ,jenkins_project
              ,email_address) 
        VALUES 
              ('" + $log_type + "'
              ,'" + $log_type_desc + "'
              ,SYSTEM_USER
              ,'" + $source + "'
              ,GETDATE()
              ,'" + $jenkins_build + "'
              ,'" + $jenkins_project + "'
              ,'" + $email_address + "') 
        
        SELECT @@IDENTITY AS log_id"

    $log_id_result = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql -OutputSqlErrors $true -ErrorAction SilentlyContinue

    #Check for SQL Server errors
    if ($error -ne $null) 
        {[PSCustomObject]@{
            log_id = 0
            err_num = 0
            err_msg = $error[0]
            }
        }
    else
        {[PSCustomObject]@{
            log_id = $log_id_result.log_id
            err_num = 0
            err_msg = ""
            }
        }
}
catch
{

    [PSCustomObject]@{
        log_id = 0
        err_num = 100
        err_msg = $error[0]
        }
}
