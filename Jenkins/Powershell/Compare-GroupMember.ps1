<# ***************************************************************************************************
Purpose:    Maintain the BATCH folders on all of our QA servers by deleting old files. Designed to 
            be called from Jenkins 
Parameters: 
    
    delete_data     - determines whether or not existing data should be deleted before creating the data
    email_address   - the email address(es) where results will be sent
    jenkins_build   - the build number from Jenkins, stored in the log for reference
    jenkins_project - name of the Jenkins project, stored in the log for reference


Date        User            Change
---------------------------------------------------------------------------------------------
07/11/2021	DK				Original script
08/02/2021  DK              Use group ID instead of group name
11/03/2022  DK              Translate the SID when it is returned as the member's name
06/26/2023  DK              Added -Server to Get-ADGroupMember to get the right membership
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
 
    [Parameter()]
    [string]$email_address,

    [Parameter()]
    [int]$jenkins_build,

    [Parameter()]
    [string]$jenkins_project

)
#--------------------------------------------------------------------------------------------------
# Important Values
#--------------------------------------------------------------------------------------------------
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"

$log_type             = "Active Directory Group Membership Review"
$log_type_description = "Review Active Directory groups and send an email alert when new members are added or removed"

$new_members          = 0
$removed_members      = 0

#--------------------------------------------------------------------------------------------------
# Start logging activity
#--------------------------------------------------------------------------------------------------
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
              ,'" + $log_type_description + "'
              ,SYSTEM_USER
              ,'Jenkins'
              ,GETDATE()
              ,'" + $jenkins_build + "'
              ,'" + $jenkins_project + "'
              ,'" + $email_address + "') 
        
        SELECT @@IDENTITY AS log_id"

    $log_id_result = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
    $log_id = $log_id_result.log_id
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while starting the log: " $Error[0]
    Exit 1
}

#--------------------------------------------------------------------------------------------------
# Start writing information to the console for the user
#--------------------------------------------------------------------------------------------------
Write-Host ""
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " ACTIVE DIRECTORY GROUP MEMBERSHIP REVIEW"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       Review Active Directory group membership and report on new or removed members"
Write-Host ""

#--------------------------------------------------------------------------------------------------
# Gather a list of the AD groups that will be reviewed
#--------------------------------------------------------------------------------------------------
try
{

    $sql = "SELECT group_name
                  ,domain_name
                  ,group_id
              FROM ref.ADGroup
             WHERE review_group = 'Yes'"

    $groups = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while getting a list of servers to review: " $Error[0]
    Exit 1
}

#--------------------------------------------------------------------------------------------------
# For each group, get a list of the users that should be in the group
#--------------------------------------------------------------------------------------------------
try
{
    foreach($group in $groups)
    {
        Write-Host "       Group: " $group.group_name.ToLower()
        Write-Host "       Domain:" $group.domain_name.ToLower()
        Write-Host ""

        #Start logging the detail
        $sql = "INSERT INTO log.LogDetail
                      (log_id
                      ,instance_name
                      ,detail_type
                      ,detail_value
                      ,begin_date
                      ,err_num
                      ,err_msg)
                VALUES (
                       '" + $log_id + "'
                      ,'" + $group.domain_name.ToLower() + "'
                      ,'AD Group'
                      ,'" + $group.group_id + "'
                      ,GETDATE()
                      ,0
                      ,'')
                      
                SELECT @@IDENTITY AS detail_log_id"
        
        $log_detail_id_result = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
        $log_detail_id = $log_detail_id_result.detail_log_id

        $sql = "SELECT member_type
                      ,member_domain
                      ,member_name
                      ,member_sid
                  FROM ref.ADGroupMember
                 WHERE group_id = '" + $group.group_id +"'"

        $expected_members = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql

        $current_members = (Get-ADGroup -Identity $group.group_name -Server $group.domain_name -Properties Members).Members | 
                                ForEach-Object -Process { 
                                    Get-ADObject -Identity $_ -Properties SamAccountName, ObjectSID |
                                    Select-Object -Property distinguishedName, name, objectClass, objectGUID, SamAccountName, @{ Name = 'SID'; Expression = {$_.ObjectSID} }
                                }  

        Write-Host "           -Member-------------------------Status-----Type-----------------Domain---------------Member SID--------------------------------------"

        #Loop through all the expected members and make sure they are still in the group
        foreach($member in $expected_members)
        {

            if($current_members.SID -contains $member.member_sid)
            {
                $status = 'Active'
            } 
            else
            {
                $status = 'Removed'
                $removed_members += 1
            }

            $sql = "INSERT INTO log.ADGroupMember
                          (log_detail_id
                          ,member_name
                          ,member_status
                          ,member_type
                          ,member_domain
                          ,member_sid)
                    SELECT " + $log_detail_id + "
                          ,'" + $member.member_name + "'
                          ,'" + $status + "'
                          ,'" + $member.member_type + "'
                          ,'" + $member.member_domain + "'
                          ,'" + $member.member_sid + "'"
                        
            Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
                          
            Write-Host "           " $member.member_name.Substring(0,[System.Math]::Min(30,$member.member_name.Length)).PadRight(30) $status.PadRight(10) $member.member_type.ToLower().PadRight(20) $member.member_domain.ToLower().PadRight(20) $member.member_sid.PadRight(20)

        }

        #Loop through all the current members looking for any members that may have been added
        foreach($member in $current_members)
        {

            if($expected_members.member_sid -notcontains $member.SID)
            {
                $status = 'New'
                $new_members += 1

                $member_domain = ""
                if ($member.distinguishedName -like "*,DC=evolenthealth,*") { $member_domain = "evolenthealth"}
                if ($member.distinguishedName -like "*,DC=chicago,*") { $member_domain = "chicago"}
                if ($member.distinguishedName -like "*,DC=aldera,*") { $member_domain = "aldera"}

                # Get the member's actual name if the SID was returned
                if ($member.objectClass -eq 'foreignSecurityPrincipal') {
                    $objSID = New-Object System.Security.Principal.SecurityIdentifier($member.name)
                    $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
                    $member.name = $objUser.Value
                }

                $sql = "INSERT INTO log.ADGroupMember
                              (log_detail_id
                              ,member_name
                              ,member_status
                              ,member_type
                              ,member_domain
                              ,member_sid)
                        SELECT " + $log_detail_id + "
                              ,'" + $member.name + "'
                              ,'" + $status + "'
                              ,'" + $member.objectClass + "'
                              ,'" + $member_domain + "'
                              ,'" + $member.SID + "'"
                        
                Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
                          

                Write-Host "           " $member.name.Substring(0,[System.Math]::Min(30,$member.name.Length)).PadRight(30) $status.PadRight(10) $member.objectClass.Substring(0,[System.Math]::Min(20,$member.objectClass.Length)).PadRight(20) $member_domain.PadRight(20).ToLower() $member.SID
            }

        }

        $sql = "UPDATE log.LogDetail
                   SET end_date = GETDATE()
                 WHERE log_id = " + $log_id.ToString() + "
                   AND log_detail_id = " + $log_detail_id.ToString() + "
                   AND instance_name = '" + $group.domain_name + "'
                   AND detail_value = '" + $group.group_id + "'"

    
        Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql

        Write-Host ""
        Write-Host ""
    }


}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while gathering a list of members to review for the group," $group.group_name": " $Error[0]
    Exit 1
}

#--------------------------------------------------------------------------------------------------
# Check to see if there were any new or removed members and if so, send an email
#--------------------------------------------------------------------------------------------------

if (($new_members -gt 0) -OR ($removed_members -gt 0))
{

    try
    {
    
        .\jenkins\powershell\Send-MailGroupAudit.ps1 -log_id $log_id -email_address $email_address

    }
    catch
    {
        #Let the user know something went wrong and fail the script
        Write-Host ""
        Write-Host "       There was an error while trying to send an email: " $Error[0]
        Exit 1
    }

}
#--------------------------------------------------------------------------------------------------
# Complete the log by setting the end_date for the log
#--------------------------------------------------------------------------------------------------
try
{

    $sql = "UPDATE log.Log
               SET end_date = GETDATE()
             WHERE log_id = " + $log_id.ToString()

    Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql

}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while completing the log: " $Error[0]
    Exit 1
}