<# ***************************************************************************************************
Purpose:    Get information about our servers 


Date        User            Change
---------------------------------------------------------------------------------------------
07/11/2021	DK				Original script
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>
$logging_server       = "wqadbhpauto01"
$logging_database     = "SystemAudit"

$sql = "SELECT server_name
          FROM Server
         WHERE server_group IN ('Client','Automation')"

$servers = Invoke-Sqlcmd -ServerInstance $logging_server -Database $logging_database -Query $sql 

foreach($server in $servers)
{
    #Write-Host $server.server_name

    #$ram = Get-CimInstance -Class CIM_PhysicalMemory -ComputerName $server.server_name | Select-Object Capacity 
    #$free_ram = Get-CimInstance Win32_OperatingSystem -ComputerName $server.server_name | Select-Object FreePhysicalMemory
    #$ram = $ram.capacity/1KB
    #$percent_used = 100 - (($free_ram.FreePhysicalMemory/ $ram) * 100)
    #$percent_used = [math]::Round($percent_used,0)

    #Get share information from each server
    $cim = New-CimSession -ComputerName $server.server_name
    #Get-SmbShare -CimSession $cim -Special $false -Name BATCH
    Get-SmbShareAccess -CimSession $cim -Name BATCH

    Write-Host ""

    (Get-Acl -Path C:\Junk).Access

    $cim.Close()
    $cim.Dispose()

    #Write-Host $server.server_name.PadRight(30) -NoNewline
    #Write-Host $ram    $free_ram.FreePhysicalMemory    $percent_used.ToString()"%"
}