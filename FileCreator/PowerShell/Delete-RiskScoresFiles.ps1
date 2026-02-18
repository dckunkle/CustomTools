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


    .PARAMETER LogId

        Specifies the log id to be used to log the deleted data


    EXAMPLE
    .\Delete-IdentifiMemberFileData.ps1" -Filename "CMT_MemDemoD_20230101.txt" -ClientKey "10606" -Database "mdsd-auto-001" -UserId "md_readwrite_user" -Password "QcjoFfdtimmKHP4by4HQ" -LogId "0" 


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Server,

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
    [int32]$LogId


)

#memberdomain-database-conn-str
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-qa-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-auto-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-reg-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"


$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=" + $Database + ";Persist Security Info=False;User ID=" + $UserId + ";Password=" + $Password + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

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
    $sql_conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
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

            C:\PowerShell\Delete-RiskScoresFileData.ps1 -Server $Server -Filename $Filename -ClientKey $ClientKey -Database $Database -UserId $UserId -Password $Password -LogId $LogId
        }
    }
    else
    {
        Write-Host
        Write-Host "             No data found to delete"
    }

    $sql_reader.Close()
    $sql_conn.Close()
}
catch
{
    Write-Host $_
}
