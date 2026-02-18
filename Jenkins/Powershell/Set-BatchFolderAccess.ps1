<# ***************************************************************************************************
Purpose:    Grant permissions to BATCH folders remotely 


Date        User            Change
---------------------------------------------------------------------------------------------
07/15/2021	DK				Original script
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>

$computerName = "aldqadbqr04"
$folder       = "H:\BATCH"
$user         = "CHICAGO\svcJenkinsQA"
$permission   = "FullControl"


#Create a remote session
$session = New-PSSession -ComputerName $computerName

Invoke-Command -Session $session -Args $folder, $user, $permission -ScriptBlock {

    param([string]$folder, [string]$user, [string]$permission)

    $acl = Get-Acl $folder;

    #Create the access rule that needs to be added
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $permission, "ContainerInherit, ObjectInherit", "None", "Allow");

    if ($accessRule -eq $null)
    {
        Throw "Unable to create the Access Rule giving $permission permission to $user on $folder"
    }
        
    $acl.AddAccessRule($accessRule)
    Set-Acl -aclobject $acl $folder

};

Remove-PSSession $session;