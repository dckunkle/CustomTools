<# ***************************************************************************************************
Purpose:    Maintain the Temp folders for certain users on the Jenkins server to make sure they do not
            run out of disk space


Date        User            Change
---------------------------------------------------------------------------------------------
08/18/2021	DK				Original script
12/06/2022  DK              Rewrite logging to avoid using Invoke-Sqlcmd
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
[CmdletBinding()]
Param(
 
    [Parameter()]
    [string]$email_address

)

#--------------------------------------------------------------------------------------------------
# Important Values
#--------------------------------------------------------------------------------------------------
$cutoff_days          = -10  
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"

$log_type             = "Jenkins Temp Folder Maintenance"
$log_type_description = "Delete files in the Temp folder, for the Jenkins service accounts, that are older than " + $cutoff_days.ToString() + " days old"
$server               = $env:COMPUTERNAME
$source               = "Task Scheduler on " + $server.ToLower()
$err_msg              = ""

#--------------------------------------------------------------------------------------------------
# Create SQL Connection to SystemAudit
#--------------------------------------------------------------------------------------------------
$connection_string = "Server=wqadbhpauto01.chicago.local;Database=SystemAudit;Integrated Security=True;"
 
$sql_connection = New-Object System.Data.SqlClient.SqlConnection
$sql_connection.ConnectionString = $connection_string
$sql_connection.Open()

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
              ,'" + $source + "'
              ,GETDATE()
              ,''
              ,''
              ,'" + $email_address + "') 
        
        SELECT @@IDENTITY AS log_id"

    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandText = $sql
    $log_command.Connection  = $sql_connection

    $log_reader = $log_command.ExecuteReader()

    if ($log_reader.HasRows)
    {
        $log_reader.Read() >> $null
        $log_id = $log_reader.Item('log_id')
    }

    $log_reader.Close()
    
}
catch
{
    $err_msg = "An error occured while attempting to log to the log.Log table: " + $Error[0]
}

#--------------------------------------------------------------------------------------------------
# Start a detail log for the server
#--------------------------------------------------------------------------------------------------
$sql = "INSERT INTO log.LogDetail
                (log_id
                ,instance_name
                ,begin_date
                ,err_num
                ,err_msg)
        VALUES (
                '" + $log_id + "'
                ,'" + $server + "'
                ,GETDATE()
                ,0
                ,'')
                      
        SELECT @@IDENTITY AS detail_log_id"
        
$log_command = New-Object System.Data.SqlClient.SqlCommand
$log_command.CommandText = $sql
$log_command.Connection  = $sql_connection

$log_detail_reader = $log_command.ExecuteReader()

if ($log_detail_reader.HasRows)
{
    $log_detail_reader.Read() >> $null
    $log_detail_id = $log_detail_reader.Item('detail_log_id')
}

$log_detail_reader.Close()

#--------------------------------------------------------------------------------------------------
# Create a list of users to maintain
#--------------------------------------------------------------------------------------------------
$users = @()
$users += "Jenkins_Build"
$users += "svcJenkinsQA"

foreach ($user in $users)
{

#--------------------------------------------------------------------------------------------------
# For the server, gather a list of the folders to review
#--------------------------------------------------------------------------------------------------

    #Create an array of folders to look into
    $all_folders = @()
    $keep_folders = @()

    #Add the root folder, makre sure that the folder i not deleted
    $all_folders += "C:\Users\" + $user + "\AppData\Local\Temp"
    $keep_folders += "C:\Users\" + $user + "\AppData\Local\Temp"

    #Add any relevant subfolders
    $fullpath = "C:\Users\" + $user + "\AppData\Local\Temp"
    $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object name -like "scoped_dir*" | Select-Object -ExpandProperty Fullname
    $all_folders += $folders

    $fullpath = "C:\Users\" + $user + "\AppData\Local\Temp"
    $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object name -like "chrome_url_fetcher*" | Select-Object -ExpandProperty Fullname
    $all_folders += $folders

    $fullpath = "C:\Users\" + $user + "\AppData\Local\Temp"
    $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object name -like "chrome_BITS*" | Select-Object -ExpandProperty Fullname
    $all_folders += $folders

    try
    {


#--------------------------------------------------------------------------------------------------
# Loop through all of the subfolders and delete the files
#--------------------------------------------------------------------------------------------------

        foreach($folder in $all_folders)
        {

            $files = Get-ChildItem -Path $folder -File | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($cutoff_days))} | Select-Object Name, Length, LastWriteTime

            foreach($file in $files)
            {
                $delete_file = "No"

                #Selectively delete files based on their naming
                if (($keep_folders -contains $folder) -and ($file.name.Substring(0,6) -eq "testng")) {$delete_file = "Yes"}
                if (($keep_folders -contains $folder) -and ($file.name.Substring(0,6) -eq "screen")) {$delete_file = "Yes"}
                if (($keep_folders -contains $folder) -and ($file.name.Substring(0,3) -eq "IED")) {$delete_file = "Yes"}
                if (($keep_folders -contains $folder) -and ($file.name.Substring(0,4) -eq "+~JF")) {$delete_file = "Yes"}

                if ($keep_folders -notcontains $folder) {$delete_file = "Yes"}

               $file_size_gb = $file.Length/1KB
 
                if ($delete_file -eq "Yes")
                {
                    #Log the files that are being deleted
                    $sql = "INSERT INTO log.FileDetail
                                  (log_detail_id
                                  ,file_action
                                  ,file_folder
                                  ,file_name
                                  ,file_size_byte
                                  ,file_size_kb
                                  ,file_timestamp
                                  ,err_num
                                  ,err_msg)
                            SELECT " + $log_detail_id + "
                                  ,'Delete'
                                  ,'" + $folder + "'
                                  ,'" + $file.Name.Replace("'","") + "'
                                  ,'" + $file.Length + "'
                                  ," + $file_size_gb + "
                                  ,'" + $file.LastWriteTime + "'
                                  ,0
                                  ,''"

                    $log_command.CommandText = $sql
                    $log_command.ExecuteNonQuery() >> $null

                    $file_name = $folder + "\" + $file.Name
                    Remove-Item $file_name
                }
            }

            $folder_last_access = $(Get-Item $folder).LastAccessTime
        
            #If the folder should be deleted, log the folder and delete it
            if ($folder_last_access -lt (Get-Date).AddDays($cutoff_days))
            {

                # Only delete the folder if it is not the root folder
               if($keep_folders -notcontains $folder)
               {

                    #Log the folder being deleted
                    $sql = "INSERT INTO log.FileDetail
                                  (log_detail_id
                                  ,file_action
                                  ,file_folder
                                  ,file_name
                                  ,file_size_byte
                                  ,file_size_kb
                                  ,file_timestamp
                                  ,err_num
                                  ,err_msg)
                            SELECT " + $log_detail_id + "
                                  ,'Delete'
                                  ,'" + $folder + "'
                                  ,''
                                  ,0
                                  ,0
                                  ,'" + $folder_last_access + "'
                                  ,0
                                     ,''"
                    
                    $log_command.CommandText = $sql
                    $log_command.ExecuteNonQuery() >> $null

                    Remove-Item $folder -Recurse
                }

            }
        
        }

    }

    catch
    {
        $err_msg = "An error occurred while deleting files: " + $Error[0]

    }

}

#--------------------------------------------------------------------------------------------------
# Complete the log
#--------------------------------------------------------------------------------------------------
try
{

    $sql = "UPDATE log.LogDetail SET end_date = GETDATE() WHERE log_detail_id = " + $log_detail_id
    $log_command.CommandText = $sql
    $log_command.ExecuteNonQuery() >> $null

}
catch
{
    $err_msg = "An error occurred while attempting to update the detail log: " + $Error[0]

}

#--------------------------------------------------------------------------------------------------
# Complete the log by setting the end_date for the log
#--------------------------------------------------------------------------------------------------
try
{

    $sql = "UPDATE log.Log
               SET end_date = GETDATE()
             WHERE log_id = " + $log_id.ToString()

    $log_command.CommandText = $sql
    $log_command.ExecuteNonQuery() >> $null

}
catch
{
    $err_msg = "An error occurred while attempting to update the log: " + $Error[0]
}

#--------------------------------------------------------------------------------------------------
# Send an email to those that are monitoring this process
#--------------------------------------------------------------------------------------------------
if ($err_msg -eq "")
{
    $results = E:\PowerShell\Send-MailJenkinsMaintenance.ps1 -log_id $log_id -email_address $email_address 
}
else
{
    #Send an error email with details about the error
    $results = E:\PowerShell\Send-MailGenericError.ps1 -process_name "Remove-JenkinsAutomationFiles.ps1" -err_num 100 -err_msg $err_msg -email_address $email_address
}
#--------------------------------------------------------------------------------------------------
# Cleanup
#--------------------------------------------------------------------------------------------------
$sql_connection.Close()