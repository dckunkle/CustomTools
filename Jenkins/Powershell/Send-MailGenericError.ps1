<# ***************************************************************************************************
Purpose:    Send an email reporting an error 

Date        User            Change
---------------------------------------------------------------------------------------------
08/20/2021	DK				Original script
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
 
    [Parameter(Mandatory=$False)]
    [int]$err_num,

    [Parameter(Mandatory=$True)]
    [string]$err_msg,

    [Parameter(Mandatory=$True)]
    [string]$process_name,

    [Parameter(Mandatory=$True)]
    [string]$email_address

)

#--------------------------------------------------------------------------------------------------
# Important Values
#--------------------------------------------------------------------------------------------------
$To                   = $email_address.Split(",")
$From                 = "QA_Maintenance_Tools@evolenthealth.com"
$Subject              = "An Error Occurred During Processing"
$SmtpServer           = "smtp.valencehealth.com"

$table_styling        = "cellspacing=`"0`" style=`"font-family: Calibri, Arial, Helvetica, sans-serif;`""
$td_styling           = "style=`"border: 1px solid #dddddd;padding: 4px;`""
$th_styling           = "style=`"background-color:#0099cc;color:white;padding:4px;border: 1px solid #dddddd;text-align: left;`""

$Body += "<html><head><title>Processing Error</title></head><body>"
$Body += "<h2>An error occurred during the following process:</h2>"
$Body += "<table " +$table_styling + ">"

$Body +=       "<th " + $th_styling + ">Process Name</th>"
$Body +=       "<th " + $th_styling + ">Error Number</th>"
$Body +=       "<th " + $th_styling + ">Error Message</th>"

$Body += "<tr>" 
$Body +=      "<td " + $td_styling + ">" + $process_name + "</td>"
$Body +=      "<td " + $td_styling + ">" + $err_num   + "</td>"
$Body +=      "<td " + $td_styling + ">" + $err_msg + "</td>"
$Body += "</tr>"

$Body += "</table></body></html>"

#--------------------------------------------------------------------------------------------------
# Get any errors that were logged and construct the body of the email to be sent
#--------------------------------------------------------------------------------------------------
$error.Clear()

try
{

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
catch
{

    [PSCustomObject]@{
        err_num = 100
        err_msg = $error[0]
        }
}
