<# ***************************************************************************************************
Purpose:    Send an email with the results of the Jenkins Automation maintenance that cleans up
            temporary files on the C:\Users drive 

Date        User            Change
---------------------------------------------------------------------------------------------
08/18/2021	DK				Original script
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
 
    [Parameter(Mandatory=$True)]
    [int]$log_id,

    [Parameter(Mandatory=$True)]
    [string]$email_address

)

#--------------------------------------------------------------------------------------------------
# Important Values
#--------------------------------------------------------------------------------------------------
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"
$server               = $env:COMPUTERNAME.ToLower()

$To                   = $email_address.Split(",")
$From                 = "QA_Maintenance_Tools@evolenthealth.com"
$Subject              = "Jenkins Server File Maintenance (" + $server + ")"
$SmtpServer           = "smtp.valencehealth.com"

$table_styling        = "cellspacing=`"0`" style=`"font-family: Calibri, Arial, Helvetica, sans-serif;`""
$td_styling           = "style=`"border: 1px solid #dddddd;padding: 4px;`""
$th_styling           = "style=`"background-color:#0099cc;color:white;padding:4px;border: 1px solid #dddddd;`""

$Body += "<html><head><title>Active Directory Group Changes</title></head><body>"
$Body += "<p>The following is a summary of the temporary files and folders that were deleted from the Temp folder on the " + $server + " server.</p>"
$Body += "<table " +$table_styling + ">"

$Body +=       "<th " + $th_styling + ">Log ID</th>"
$Body +=       "<th " + $th_styling + ">Start Time</th>"
$Body +=       "<th " + $th_styling + ">Files Deleted</th>"
$Body +=       "<th " + $th_styling + ">Folders Deleted</th>"
$Body +=       "<th " + $th_styling + ">Disk Space Saved (MB)</th>"
$Body +=       "<th " + $th_styling + ">Files Range</th>"

#--------------------------------------------------------------------------------------------------
# Create SQL Connection to SystemAudit
#--------------------------------------------------------------------------------------------------
$connection_string = "Server=wqadbhpauto01.chicago.local;Database=SystemAudit;Integrated Security=True;"
 
$sql_connection = New-Object System.Data.SqlClient.SqlConnection
$sql_connection.ConnectionString = $connection_string
$sql_connection.Open()

#--------------------------------------------------------------------------------------------------
# Get any errors that were logged and construct the body of the email to be sent
#--------------------------------------------------------------------------------------------------
$error.Clear()

try
{


    $sql = "SELECT L.log_id
                  ,FORMAT(L.begin_date,'yyyy-MM-dd HH:MM:ss')	AS begin_date
	              ,FORMAT(L.end_date,'yyyy-MM-dd HH:MM:ss')		AS end_date
                  ,COUNT(CASE WHEN ISNULL(FD.file_name, '') <> '' THEN 1 ELSE NULL END )	AS files_deleted
	              ,COUNT(CASE WHEN ISNULL(FD.file_name, '') <> '' THEN 1 ELSE NULL END )	AS folders_deleted
	              ,SUM(ISNULL(FD.file_size_byte,0))		AS total_file_size
	              ,CONVERT(VARCHAR(10), MAX(ISNULL(FD.file_timestamp, '')),121)		AS newest_file
	              ,CONVERT(VARCHAR(10), MIN(ISNULL(FD.file_timestamp, '')),121)		AS oldest_file
              FROM log.Log			L
              JOIN log.LogDetail	LD
                ON L.log_id			= LD.log_id
              LEFT JOIN log.FileDetail	FD
                ON LD.log_detail_id	= FD.log_detail_id
             WHERE L.log_id			= " + $log_id + "
             GROUP BY L.log_id
                     ,L.begin_date
		             ,L.end_date"

    
    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandText = $sql
    $log_command.Connection  = $sql_connection

    $delete_data = $log_command.ExecuteReader()
    $delete_data.Read() >> $null
        
    if(($delete_data.Item('oldest_file') -eq "1900-01-01") -and ($delete_data.Item('newest_file') -eq "1900-01-01"))
    {
        $range = ""
    }
    else
    {
        $range = $delete_data.Item('oldest_file') + " - " + $delete_data.Item('newest_file')
    }

    $total_size = [Math]::Round($delete_data.Item('total_file_size') /1MB, 2,[MidPointRounding]::AwayFromZero)

    #Check for SQL Server errors
    if ($error -ne $null) 
        {[PSCustomObject]@{
            err_num = 100
            err_msg = $error[0]
            }
        }

    else
    {

        $Body += "<tr>" 
        $Body +=      "<td " + $td_styling + ">" + $delete_data.Item('log_id') + "</td>"
        $Body +=      "<td " + $td_styling + ">" + $delete_data.Item('begin_date')   + "</td>"
        $Body +=      "<td " + $td_styling + ">" + $delete_data.Item('files_deleted') + "</td>"
        $Body +=      "<td " + $td_styling + ">" + $delete_data.Item('folders_deleted')    + "</td>"
        $Body +=      "<td " + $td_styling + ">" + $total_size + "</td>"
        $Body +=      "<td " + $td_styling + ">" + $range + "</td>"
        $Body += "</tr>"

        $Body += "</table></body></html>"

        Send-MailMessage -Body $Body -To $To -From $From -Subject $Subject -SmtpServer $SmtpServer -BodyAsHtml -ErrorAction SilentlyContinue

        #See if there were any errors sending the email
        if ($error -ne $null) 
        {[PSCustomObject]@{
            err_num = 100
            err_msg = $error[0]
            }
        }
        else
        {
        [PSCustomObject]@{
            err_num = 0
            err_msg = ""
            }
        }
    }

    $delete_data.Close()
}
catch
{

    [PSCustomObject]@{
        err_num = 100
        err_msg = $error[0]
        }
}
