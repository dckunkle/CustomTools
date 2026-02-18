<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        05/30/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will delete one or more files that match the file pattern that is passed in

    
    .DESCRIPTION

        Given a file name pattern, this script will delete all of the files in the Identifi Member
        database that match the pattern provided.

    
    .PARAMETER Server

        Specify the server where the data to delete resides


    .PARAMETER LogServer

        Specify the server where logging will take place


    .PARAMETER Filename

        Specify the file name pattern to be deleted (zero to many files could be deleted)


    .PARAMETER ClientKey

        Specify the client that the file was loaded for (e.g. 10606, 10609)


    .PARAMETER Database

        Specify the database name to connect to (e.g. automation, regression, etc.)


    .PARAMETER UserId

        Specify the user id for connecting to the database


    .PARAMETER Password

        Specify the password for connecting to the database


    .PARAMETER TypeId

        Specifies the type id to be used to log the deleted data


    EXAMPLE
    .\Delete-IdentifiMemberFiles.ps1 -Server "ipe1qa-hpss-001.database.windows.net" -LogServer "aldqrdb09" -Filename "CMT_MemDemoD_%" -ClientKey "10609" -Database "mdsd-auto-001" -UserId "md_readwrite_user" -Password "QcjoFfdtimmKHP4by4HQ" -TypeId 80



#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Server,

    [Parameter(Mandatory=$True)]
    [string]$LogServer,

    [Parameter(Mandatory=$True)]
    [string]$Filename,

    [Parameter(Mandatory=$True)]
    [string]$ClientKey,

    [Parameter(Mandatory=$True)]
    [string]$Database,

    [Parameter(Mandatory=$True)]
    [string]$UserId,

    [Parameter(Mandatory=$True)]
    [string]$Password,

    [Parameter(Mandatory=$True)]
    [int32]$TypeId

)

$data_server       = $Server
$log_server        = $LogServer
$connection_string = "Server=tcp:" + $data_server + ",1433;Initial Catalog=" + $Database + ";Persist Security Info=False;User ID=" + $UserId + ";Password=" + $Password + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

#**************************************************************************************************
# Set the SQL commands to be executed
#**************************************************************************************************
$sql = "SELECT FileName
          FROM DataFile
         WHERE FileName		LIKE @filename
           AND Client_Key	= @client_key"

#**************************************************************************************************
# Create the connection and delete the data
#**************************************************************************************************
try
{
    $sql_conn = New-Object System.Data.SqlClient.SqlConnection($connection_string)
    $sql_conn.Open()

    $sql_cmd  = New-Object System.Data.SqlClient.SqlCommand
    $sql_cmd.Connection = $sql_conn
    $sql_cmd.CommandTimeout = 30
    $sql_cmd.CommandText = $sql

    $sql_cmd.Parameters.Add('@filename', $Filename) >> $null
    $sql_cmd.Parameters.Add('@client_key', $ClientKey) >> $null

    $sql_reader = $sql_cmd.ExecuteReader()

#**************************************************************************************************
# Loop through the files deleting each one
#**************************************************************************************************
    if ($sql_reader.HasRows)
    {
        
        while ($sql_reader.Read())
        {
            $filename = $sql_reader.Item("Filename")

            C:\PowerShell\Delete-IdentifiMemberFileData.ps1 -Server $data_server -LogServer $log_server -Filename $Filename -ClientKey $ClientKey -Database $Database -UserId $UserId -Password $Password -TypeId $TypeId
        }
    }
    
    $sql_reader.Close()
    $sql_conn.Close()
}
catch
{
    Write-Host $_
}

