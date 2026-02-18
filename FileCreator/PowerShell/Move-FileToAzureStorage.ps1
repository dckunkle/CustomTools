<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        10/17/2022	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script moves file(s) to the proper Azure Blob Storage account

    
    .DESCRIPTION

        Given the file type and the file name, the file will be moved to the proper Azure storage account.
        The script assumes the file will be local to the wqadbhpauto01 server.
    

    .PARAMETER Filename

        Specifies the path where the Benefit Grids reside


    .PARAMETER Container

        Specifies the container where the file will be moved to


    .PARAMETER Blob

        Specifies the location and file name for the file being uploaded


    .PARAMETER StorageAccount

        Specifies storage account where the file will be moved to


    .PARAMETER StorageKey

        Specifies the key used for the storage account

    EXAMPLE
#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Filename,

    [Parameter(Mandatory=$True)]
    [string]$Container,

    [Parameter(Mandatory=$True)]
    [string]$Blob,

    [Parameter(Mandatory=$True)]
    [string]$StorageAccount,

    [Parameter(Mandatory=$True)]
    [string]$StorageKey
)

$connection_string = "DefaultEndpointsProtocol=https;"

#**************************************************************************************************
# Create connection object to the File Creator database
#**************************************************************************************************
try
{
     #$context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageKey

     $context = New-AzStorageContext -ConnectionString $connection_string
     Set-AzStorageBlobContent -Context $context -Container $Container -File $Filename -Blob $Blob
}
catch
{
    Write-Host "Error moving file to Azure"
    Write-Host $_
    Exit 1
}

