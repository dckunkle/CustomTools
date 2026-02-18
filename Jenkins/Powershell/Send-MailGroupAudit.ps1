<# ***************************************************************************************************
Purpose:    Send AD Group Audit email to the email address that was passed in for the audit log id 

Date        User            Change
---------------------------------------------------------------------------------------------
08/02/2021	DK				Original script
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

$To                   = $email_address.Split(",")
$From                 = "QA_Audit_Tools@evolenthealth.com"
$Subject              = "Changes Detected in QA AD Groups"
$SmtpServer           = "smtp.valencehealth.com"

$table_styling        = "cellspacing=`"0`" style=`"font-family: Calibri, Arial, Helvetica, sans-serif;`""
$td_styling           = "style=`"border: 1px solid #dddddd;padding: 4px;`""
$th_styling           = "style=`"background-color:#0099cc;color:white;padding:4px;border: 1px solid #dddddd;`""

$Body += "<html><head><title>Active Directory Group Changes</title></head><body>"
$Body += "<p>Changes have been detected in the active directory groups that are used by the QA department. The table below lists the changes that have been detected.</p>"
$Body += "<table " +$table_styling + ">"

$Body +=       "<th " + $th_styling + ">Member Status</th>"
$Body +=       "<th " + $th_styling + ">Member Name</th>"
$Body +=       "<th " + $th_styling + ">Member Domain</th>"
$Body +=       "<th " + $th_styling + ">Group Name</th>"
$Body +=       "<th " + $th_styling + ">Group Domain</th>"

#--------------------------------------------------------------------------------------------------
# Get any errors that were logged and construct the body of the email to be sent
#--------------------------------------------------------------------------------------------------
$error.Clear()

try
{


    $sql = "SELECT G.group_name
                  ,LOWER(G.domain_name)    AS group_domain
                  ,GM.member_name
                  ,GM.member_status
                  ,LOWER(GM.member_domain) AS member_domain
              FROM log.ADGroupMember GM
              JOIN log.LogDetail     LD
                ON GM.log_detail_id  = LD.log_detail_id
              JOIN ref.ADGroup G
                ON LD.detail_value   = G.group_id
             WHERE LD.log_id         = " + $log_id + "
               AND GM.member_status <> 'Active'"

    $changes = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql -OutputSqlErrors $true -ErrorAction SilentlyContinue
        
    #Check for SQL Server errors
    if ($error -ne $null) 
        {[PSCustomObject]@{
            err_num = 100
            err_msg = $error[0]
            }
        }

    else{

        foreach($change in $changes)
        { 
            $Body += "<tr>" 
            $Body +=      "<td " + $td_styling + ">" + $change.member_status + "</td>"
            $Body +=      "<td " + $td_styling + ">" + $change.member_name   + "</td>"
            $Body +=      "<td " + $td_styling + ">" + $change.member_domain + "</td>"
            $Body +=      "<td " + $td_styling + ">" + $change.group_name    + "</td>"
            $Body +=      "<td " + $td_styling + ">" + $change.group_domain + "</td>"
            $Body += "</tr>"
        }

        $Body += "</table></body></html>"

        Send-MailMessage -Body $Body -To $To -From $From -Subject $Subject -SmtpServer $SmtpServer -BodyAsHtml -ErrorAction SilentlyContinue

        #See if there were any errors sending the email
        if ($error -ne $null) 
        {[PSCustomObject]@{
            err_num = 100
            err_msg = $error[0]
            }
        }
        else{
        [PSCustomObject]@{
            err_num = 0
            err_msg = ""
            }
        }
    }

}
catch
{

    [PSCustomObject]@{
        err_num = 100
        err_msg = $error[0]
        }
}
