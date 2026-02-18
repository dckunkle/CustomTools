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

    .\Move-FileToAzureStorage.ps1 -Filename C:\Azure\CMT_MemDemoD_20230101.txt -Container data-sources -Blob DEMOGRAPHICS/IB/COREQR09/CMT/Staging/CMT_MemDemoD_20230101.txt -StorageAccount hpsqaidmstoragetrans02 -StorageKey /iYUOLgwwAzLbglBTpILMLhZa7N3OVeyh6s3ZpQrxUZJimjfNizDFN6Qj+pHUrN5xycQCP3vs417H9w3qSIzxA==
    .\Move-FileToAzureStorage.ps1 -Filename C:\Azure\CMT_MemDemoD_20230101.txt -Container data-sources -Blob DEMOGRAPHICS/IB/COREQR09/CMT/Staging/CMT_MemDemoD_20230101.txt -StorageAccount hpsqaidmstoragetrans02 -StorageKey /iYUOLgwwAzLbglBTpILMLhZa7N3OVeyh6s3ZpQrxUZJimjfNizDFN6Qj+pHUrN5xycQCP3vs417H9w3qSIzxA==
    .\Move-FileToAzureStorage.ps1 -Filename C:\Azure\FC_RiskScores_20230414.txt -Container data-sources -Blob RiskScores/COREQR09/Staging/FC_RiskScores_20230414.txt -StorageAccount hpsqaidmstoragetrans02 -StorageKey /iYUOLgwwAzLbglBTpILMLhZa7N3OVeyh6s3ZpQrxUZJimjfNizDFN6Qj+pHUrN5xycQCP3vs417H9w3qSIzxA==
    .\Move-FileToAzureStorage.ps1 -Filename C:\Azure\FC_834_EB_IdentifiMember_UpdateDetails_20230519.edi -Container data-sources -Blob 834/IB/COREQR09/Staging/FC_834_EB_IdentifiMember_UpdateDetails_20230519.edi -StorageAccount hpsqaidmstoragetrans02 -StorageKey /iYUOLgwwAzLbglBTpILMLhZa7N3OVeyh6s3ZpQrxUZJimjfNizDFN6Qj+pHUrN5xycQCP3vs417H9w3qSIzxA==
 
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

