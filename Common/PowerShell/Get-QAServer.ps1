<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        07/27/2022	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will return a listing of QA database servers that are current configured. 

    
    .DESCRIPTION

        This script will return the name of the server, the category of the server, the abbreviation of
        the server for each QA server that is currently configured. The number of servers returned in the
        list can be controlled by specifying a Name, Category or Abbreviation fo the server(s) that are 
        needed.
    

    .PARAMETER Name

        Specifies the name of the server to return information for. Using this parameter will limit results
        to a single server. Excluding this and the other parameters will return all of the servers.


    .PARAMETER Category

        Specifies the category of the servers to be returned. For example, Automation, will return a listing of
        all of the automation servers


    .PARAMETER Abbreviation

        Specifies the abbreviation of the server. For example QR06 will return the server information for 
        aldqadbqr06


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$false)]
    [string]$Name,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Automation","Client","CoreA","CoreB","CoreC","CoreD","CoreE","SaaS")]
    [string]$Category,

    [Parameter(Mandatory=$false)]
    [string]$Abbreviation

)

Begin
{

    #**************************************************************************************************
    # Create connection object to the SystemAudit database
    #**************************************************************************************************
    Try
    {
        $server = 'wqadbhpauto01'
        $database = 'SystemAudit'
        $connection = .\New-SQLConnection.ps1 -instance_name $server -database $database

    }
    Catch
    {
        Write-Host $_
        Exit 1
    }

}
Process
{
    #**************************************************************************************************
    # Retrieve the servers fr the given parameters
    #**************************************************************************************************
    Try
    {
        $server_command = New-Object System.Data.SqlClient.SqlCommand
        $server_command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $server_command.CommandText = "dbo.spAudit_GetQAServers"
        $server_command.Connection  = $connection

        $server_command.Parameters.AddWithValue("@server_name",  $Name)    >> $null
        $server_command.Parameters.AddWithValue("@server_category", $Category) >> $null
        $server_command.Parameters.AddWithValue("@server_abbreviation", $Abbreviation) >> $null

        # Load any data into a data table to begin processing
        $server_adapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $server_adapter.SelectCommand = $server_command
    
        $server_data_set = New-Object System.Data.DataSet
        $server_adapter.Fill($server_data_set)  >> $null

        $server_data = New-Object System.Data.DataTable
        $server_data = $server_data_set.Tables[0]

    }
    Catch
    {
        Write-Host $_
        Exit 1
    }

    #**************************************************************************************************
    # Output the servers to be used downstream
    #**************************************************************************************************
    Try
    {
        foreach($server_row in $server_data)
        {
        
            [PSCustomObject]@{
                Instance = $server_row.Instance_Name
                Server = $server_row.Server_Name
                Category = $server_row.Category
                Abbreviation = $server_row.Abbreviation
            }
        }
    }
    Catch
    {
        Write-Host $_
        Exit 1
    }
}
End
{
    #**************************************************************************************************
    # Cleanup
    #**************************************************************************************************
    $server_data.Dispose()
    $server_data_set.Dispose()
    $server_adapter.Dispose()
    $server_command.Dispose()
}