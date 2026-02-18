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
07/19/2021  DK              Add logging server variable to quickly change SQL Server source
10/25/2021  DK              Move the cutoff days logic out of the loop
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
$cutoff_days          = -60
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"
$cutoff_date          = (Get-Date).AddDays($cutoff_days).ToString("MM/dd/yyyy")

$log_type             = "Batch Folder Maintenance"
$log_type_description = "Delete files in the BATCH folder that were created before " + $cutoff_date

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
Write-Host " BATCH FOLDER MAINTENANCE"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "       Review the following folders for files that were last modified before" $cutoff_date
Write-Host ""
Write-Host "         Folders: ..\OutData\Extracts"
Write-Host "                  ..\OutData\PRINTFILES"
Write-Host "                  ..\SubSystems\SSIS\FILELOAD\..\Archive"
Write-Host "                  ..\SubSystems\SSIS\FILELOAD\LOGFILES"
Write-Host "                  ..\SubSystems\AboveHealth\Archive"
Write-Host ""
Write-Host ""
Write-Host "     -Server Name----------Batch Folder------------Elapsed Time--------Files Deleted---------------Total File Size (MB)-------------------------"

#--------------------------------------------------------------------------------------------------
# Gather a list of the servers that will be reviewed
#--------------------------------------------------------------------------------------------------
try
{

    $sql = "SELECT server_name
                  ,batch_folder
              FROM Server
             WHERE status = 'A'
               AND delete_batch = 'Yes'"

    $servers = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while getting a list of servers to review: " $Error[0]
    Exit 1
}

#--------------------------------------------------------------------------------------------------
# For each server, gather a list of the folders to review
#--------------------------------------------------------------------------------------------------
try
{
    foreach($server in $servers)
    {
        $total_files     = 0
        $total_file_size = 0
        $begin_date      = Get-Date

        #Start logging the detail
        $sql = "INSERT INTO log.LogDetail
                      (log_id
                      ,instance_name
                      ,begin_date
                      ,err_num
                      ,err_msg)
                VALUES (
                       '" + $log_id + "'
                      ,'" + $server.server_name + "'
                      ,'" + $begin_date + "'
                      ,0
                      ,'');
                      
                SELECT @@IDENTITY AS detail_log_id;"
        
        $log_detail_id_result = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
        $log_detail_id = $log_detail_id_result.detail_log_id

        $all_folders=@()

        #Gather all of the folders where SSIS log files could be saved
        $fullpath = "\\" + $server.server_name + "\" + $server.batch_folder + "\SubSystems\SSIS\FILELOAD\LOGFILES"
        $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Fullname 
        $all_folders += $folders

        #Gather all of the extract folders
        $fullpath = "\\" + $server.server_name + "\" + $server.batch_folder + "\OutData\Extracts"
        $all_folders += $fullpath
        $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Fullname
        $all_folders += $folders

        #Gather all of the extract folders
        $fullpath = "\\" + $server.server_name + "\" + $server.batch_folder + "\OutData\PRINTFILES"
        $all_folders += $fullpath
        $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Fullname
        $all_folders += $folders

        #Gather the Archive folders for Data Imports and On Demand Jobs (only look in the Archive folders)
        $fullpath = "\\" + $server.server_name + "\" + $server.batch_folder + "\SubSystems\SSIS\FILELOAD"
        $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object name -eq "Archive" | Select-Object -ExpandProperty Fullname
        $all_folders += $folders

        #Gather the Archive folders for Data Imports and On Demand Jobs (only look in the Archive folders)
        $fullpath = "\\" + $server.server_name + "\" + $server.batch_folder + "\SubSystems\AboveHealth\Archive"
        $folders = Get-ChildItem -Path $fullpath -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object name -eq "Archive" | Select-Object -ExpandProperty Fullname
        $all_folders += $folders

        foreach($folder in $all_folders)
        {

            $files = Get-ChildItem -Path $folder -File | Where-Object {($_.LastWriteTime -lt $cutoff_date)} | Select-Object Name, Length, LastWriteTime

            foreach($file in $files)
            {
                $file_size_gb = $file.Length/1KB

                $total_files += 1
                $total_file_size += $file.Length
 
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
                Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql

                $file_name = $folder + "\" + $file.Name
                Remove-Item $file_name -ErrorAction SilentlyContinue
            }
        }

        $end_date = Get-Date
        $time_difference = New-TimeSpan -Start $begin_date -End $end_date 
        $elapsed_time = $time_difference.Minutes.ToString() + "m " + $time_difference.Seconds.ToString() + "s"

        #Convert bytes to MB and round to two decimal places
        $total_file_size = [Math]::Round($total_file_size /1MB, 2,[MidPointRounding]::AwayFromZero)

        Write-Host "     " $server.server_name.PadRight(20) $server.batch_folder.PadRight(20) $elapsed_time.PadLeft(15) $total_files.ToString().PadLeft(20) $total_file_size.ToString().PadLeft(34)

        $sql = "UPDATE log.LogDetail SET end_date = '" + $end_date + "' WHERE log_detail_id = " + $log_detail_id
        Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql
    }

    Write-Host "     -------------------------------------------------------------------------------------------------------------------------------------------"
}
catch
{
    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while gathering a list of folders to review for the" $server.server_name" and folder " $folder": " $Error[0]
    Exit 1
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