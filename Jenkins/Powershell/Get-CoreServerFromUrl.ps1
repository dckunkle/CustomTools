<# ***************************************************************************************************
Purpose:    Used to get the SQL Server instance name from a URL 
Parameters: 
    
    url           - the URL is assumed to be in the following format
         
                    [25] https://qr06-qa.core.valence.care/

                    where [25] corresponds to an Environment ID and will be ignored and the 
                    url will be used to look up the SQL Server instance


Date        User            Change
---------------------------------------------------------------------------------------------
05/19/2021	DK				Original script
06/21/2021  DK              Change fro server_name to instance_name for Core C, D and E env
07/19/2021  DK              Add logging server variable to quickly change SQL Server source
---------------------------------------------------------------------------------------------

*************************************************************************************************** #>

[CmdLetBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$url
)

#**************************************************************************************************
# Important variables
#**************************************************************************************************
$logging_server = "wqadbhpauto01"


try
{

    #If the URL begins with [xx] then strip it off
    if ($url.Substring(0,1) = "[")
        {
            $from     = $url.IndexOf("]") + 2
            $to       = $url.Length - $from
            $url_only = $url.Substring($from,$to)
        }

    else
        {
            $url_only = $url
        }

    #Create the connection to the SQL Server
    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = "Server=" + $logging_server + ";Database=SystemAudit;Trusted_Connection=True;"
    $SQLConnection.Open()

    $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
    $SQLCommand.Connection = $SQLConnection
    $SQLCommand.CommandText = "SELECT instance_name FROM Server WITH (NOLOCK) WHERE system_url = '" + $url_only + "'"
    $SQLReader = $SQLCommand.ExecuteReader()

    while ($SQLReader.Read())
    {
        $server_name = $SQLReader.Item("instance_name")
        $server_name = $server_name.Trim()
    }

    #Cleanup
    $SQLReader.Close()
    $SQLCommand.Dispose()
    $SQLConnection.Dispose()
}
catch
{

    #Let the user know something went wrong and fail the script
    Write-Host ""
    Write-Host "       There was an error while trying to get the server name for the passed in URL: " $Error[0]
    Exit 1
}

$server_name