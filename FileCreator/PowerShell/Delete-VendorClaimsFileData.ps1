<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        10/21/2022	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will remove any Vendor Claims files that have been loaded into the environment

    
    .DESCRIPTION

        For any Vendor Claims files that have been loaded for the Vendor Claims service, delete any
        files that begin with FC_ (those created by the File Creator). The files need to be cleaned
        up so they can be reloaded multiple times
    

    .PARAMETER ConnectionString

        Specify the connection string to the Azure database to connect to



#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$ConnectionString
)

$ConnectionString = "Server=tcp:ine1qa-csss-001.database.windows.net,1433;Initial Catalog=assd-auto-001;Persist Security Info=False;User ID=as_readwrite_user;Password=eyesWJd0enVnX2P6bYn1;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

#**************************************************************************************************
# Set the SQL commands to be executed
#**************************************************************************************************
$sql_delete_raw_error = "DELETE E
                           FROM dbo.VendorClaimsRawError	E
                           JOIN dbo.VendorClaimsRaw		R
                             ON E.VendorClaimsRawId		= R.Id
                          WHERE R.FileName				LIKE 'FC_%'"

$sql_delete_claims    = "DELETE V
                           FROM dbo.VendorClaims			V
                           JOIN dbo.VendorClaimsRaw		R
                             ON V.CorrelationId			= R.CorrelationId
                          WHERE R.FileName				LIKE 'FC_%'"

$sql_delete_raw       = "DELETE R
                           FROM dbo.VendorClaimsRaw		R
                          WHERE R.FileName				LIKE 'FC_%'"

$sql_delete_file      = "DELETE F
                           FROM dbo.FileProcessorInfo	F
                          WHERE F.FileName				LIKE 'FC_%'"

$sql_delete_raw_error_count = 0
$sql_delete_claims_count    = 0
$sql_delete_raw_count       = 0
$sql_delete_file_count      = 0

#**************************************************************************************************
# Create the connection and delete the data
#**************************************************************************************************
try
{
    $sql_conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $sql_conn.Open()

    $sql_cmd  = New-Object System.Data.SqlClient.SqlCommand
    $sql_cmd.Connection = $sql_conn
    
    $sql_cmd.CommandText = $sql_delete_raw_error
    $sql_delete_raw_error_count = $sql_cmd.ExecuteNonQuery();
    Write-Host "$sql_delete_raw_error_count rows deleted from dbo.VendorClaimsRawError";

    $sql_cmd.CommandText = $sql_delete_claims
    $sql_delete_claims_count = $sql_cmd.ExecuteNonQuery();
    Write-Host "$sql_delete_claims_count rows deleted from dbo.VendorClaims";
        
    $sql_cmd.CommandText = $sql_delete_raw
    $sql_delete_raw_count = $sql_cmd.ExecuteNonQuery();
    Write-Host "$sql_delete_raw_count rows deleted from dbo.VendorClaimsRaw";

    $sql_cmd.CommandText = $sql_delete_file
    $sql_delete_file_count = $sql_cmd.ExecuteNonQuery();
    Write-Host "$sql_delete_file_count rows deleted from dbo.FileProcessorInfo";

    $connection.Close();
}
catch
{
}

#**************************************************************************************************
# Log the results of the delete
#**************************************************************************************************