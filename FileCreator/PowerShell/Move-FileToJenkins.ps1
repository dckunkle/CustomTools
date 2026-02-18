<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        05/30/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script moves file(s) to the Jenkins server to moved to the cloud

    
    .DESCRIPTION

        Given the file type and the file name, the file will be moved to the proper Azure storage account.
        The script assumes the file will be local to the wqadbhpauto01 server.
    

    .PARAMETER Filename

        Specifies the file name to be moved to the Jenkins serve


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

#**************************************************************************************************
# Create connection object to the File Creator database
#**************************************************************************************************
$destination = "\\wqaapehjsauto02" + $Filename.Substring(3)
Move-Item $Filename -Destination $destination -Force

try
{
     $command = "E:\PowerShell\Move-FileToAzureStorage.ps1 -Filename " + $destination + " -Container " + $Container + " -Blob " + $Blob + " -StorageAccount " + $StorageAccount + " -StorageKey " + $StorageKey
     Invoke-Command -ComputerName wqaapehjsauto02 -ScriptBlock {$command}
}
catch
{
    Write-Host "Error moving file to Jenkins"
    Write-Host $_
    Exit 1
}

