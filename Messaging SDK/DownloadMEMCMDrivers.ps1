<#
  NOT FINISHED
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\functions\Load-MessagingSDKDLLs.ps1"
. "$PSScriptRoot\functions\Write-CMLogEntry.ps1"
. "$PSScriptRoot\functions\New-MEMCMHttpSender.ps1"
. "$PSScriptRoot\functions\New-MessageSettings.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrDriverCatalogRequest.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSMSID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMManagementPoint.ps1"
. "$PSScriptRoot\functions\Get-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSiteCode.ps1"
. "$PSScriptRoot\functions\Get-MEMCMHardwareID.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrContentLocationRequest.ps1"
. "$PSScriptRoot\functions\New-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-CIDocument.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrBitsDownloadRequest.ps1"
. "$PSScriptRoot\functions\Get-ADSiteName.ps1"

Load-MessagingSDKDLLs

$ActiveDirectorySiteName = Get-ADSiteName

$HttpSender = New-MEMCMHttpSender
$ClientSMSID = Get-MEMCMSMSID
$SiteCode = Get-MEMCMSiteCode
$ManagementPoint = Get-MEMCMManagementPoint
$SigningCertificate = Get-MEMCMCertificate -Purpose 'Signing'
$EncryptionCertificate = Get-MEMCMCertificate -Purpose 'Encryption'
$MessageSettings = New-MessageSettings -ManagementPointHostname $ManagementPoint

$Devices = Get-CimInstance -ClassName Win32_PnPEntity

if (-not $CatalogReply) {
    $CatalogReply = Send-ConfigMgrDriverCatalogRequest -Devices $Devices -HttpSender $HttpSender -ClientSMSID $ClientSMSID -SiteCode $SiteCode -MessageSettings $MessageSettings -SigningCertificate $SigningCertificate
}

if (-not $DriverDocuments) {
    $DriverDocuments = $CatalogReply.DriverDevices | ForEach-Object {
        try {
            $_.CompatibleDrivers.Drivers | ForEach-Object {
                $PolicyDocument = Get-CIDocument -ManagementPoint $ManagementPoint -DocumentID $_.PackageName
                $PolicyDocument.DesiredConfigurationDigest.Driver.ConfigurationMetadata.Provider.Operation | Where-Object { $_.Name -eq 'Install'} | ForEach-Object {
                    Write-Host $_.Content.ContentId
                    Write-Host $_.Content.Version

                    Send-ConfigMgrContentLocationRequest -HttpSender $HttpSender -EncryptionCertificat $EncryptionCertificate -SigningCertificate $SigningCertificate -SiteCode $SiteCode -ClientSMSID $ClientSMSID -MessageSettings $MessageSettings -PackageID $_.Content.ContentId -PackageVersion $_.Content.Version -PackageType Unknown
                }
            }
        } catch {}
    }
}

$DriverDocuments
