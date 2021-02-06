$ErrorActionPreference = "Stop"

. "$PSScriptRoot\functions\Load-MessagingSDKDLLs.ps1"
. "$PSScriptRoot\functions\Write-CMLogEntry.ps1"
. "$PSScriptRoot\functions\New-MEMCMHttpSender.ps1"
. "$PSScriptRoot\functions\New-MessageSettings.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSMSID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMManagementPoint.ps1"
. "$PSScriptRoot\functions\Get-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSiteCode.ps1"
. "$PSScriptRoot\functions\Get-MEMCMHardwareID.ps1"
. "$PSScriptRoot\functions\New-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrPolicyAssignmentRequest.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrPolicyBodyDownloadRequest.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrDcmCIDownloadRequest.ps1"
. "$PSScriptRoot\functions\Get-CIDocument.ps1"
. "$PSScriptRoot\functions\Get-AssignmentProperties.ps1"
. "$PSScriptRoot\functions\New-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrRegistrationRequest.ps1"

Load-MessagingSDKDLLs

try {
    $Script:TsEnv=New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch {
    Write-Host "Failed to init TSEnv"
}


# This variable name will have a following number based on how many applications are assigned
# If there are less than 100 applications the base variable name to use is $BaseVariableName and a following 0
# If there are 100-199 applications you need two steps, one with $BaseVariableName and a following 0 and one with $BaseVariableName and a following 1
# Example Apps0 and Apps1
$BaseVariableName = "Apps"

$HttpSender = New-MEMCMHttpSender
$ClientSMSID = Get-MEMCMSMSID
$HardwareID = Get-MEMCMHardwareID
$SiteCode = Get-MEMCMSiteCode
$ManagementPoint = Get-MEMCMManagementPoint
$MessageSettings = New-MessageSettings -ManagementPointHostname $ManagementPoint

$Register = $false
$SigningCertificate = Get-MEMCMCertificate -Purpose 'Signing'
if (-not $SigningCertificate) {
    try {
        $SigningCertificate = New-MEMCMCertificate -Signing -SaveInStore -ComputerName $ComputerName
    } catch {
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $SigningCertificate = New-MEMCMCertificate -Signing -ComputerName $ComputerName
    }
    $Register = $true
}

$EncryptionCertificate = Get-MEMCMCertificate -Purpose 'Encryption'
if (-not $EncryptionCertificate) {
    try {
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -SaveInStore -ComputerName $ComputerName
    } catch {
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -ComputerName $ComputerName
    }
    $Register = $true
}    

$Parameters =  @{
    HttpSender = $HttpSender
    ClientSMSID = $ClientSMSID 
    SiteCode = $SiteCode
    MessageSettings = $MessageSettings 
    SigningCertificate = $SigningCertificate
}

if ($Register) {
    $Global:ClientSMSID = Send-ConfigMgrRegistrationRequest @Parameters -HardwareID $HardwareID -ComputerName $ComputerName -EncryptionCertificate $EncryptionCertificate
    Start-sleep -Seconds 10
    # Should send data discovery record
    # Server should add client to collections which has deployed application
}


$PolicyAssignments = Send-ConfigMgrPolicyAssignmentRequest @Parameters

$AppDeploymentCategory = $PolicyAssignments.ReplyAssignments.PolicyAssignments | ? { $_.Policy.Category -eq 'ApplicationDeployment' }


$PolicyBodies = Send-ConfigMgrPolicyBodyDownloadRequest @Parameters -Assignments $AppDeploymentCategory

$RequiredApplications = $PolicyBodies | ? { $_.XMLFromRawPolicyText.InstanceClass -eq 'CCM_ApplicationCIAssignment' -and $_.RawPolicyText -match 'AssignmentAction\" type=\"19\"><value><!\[CDATA\[0' } | % {
    $Properties = Get-AssignmentProperties -Assignment $_.XMLFromRawPolicyText
    $AssignmentName = $Properties.AssignmentName.Trim()
    
    [PSCustomObject]@{
        AssignmentName = $AssignmentName
        ApplicationName = ""
        AssignedCIs = $Properties.AssignedCIs | % { ([xml]$_.Trim()).CI.ModelName }
        AltAssignedCIs = $Properties.AssignedCIs | % { ([xml]$_.Trim()).CI.ModelName -replace 'Required' }
    }
}

$VersionInfos =  $PolicyAssignments.ReplyAssignments.PolicyAssignments | ? {$_.Policy.Category -eq 'VersionInfo' }

$ReqAppsVIs = $RequiredApplications.AssignedCIs | % {
    $CurrentCI = $_
    $VersionInfos | ? { $_.Policy.Id -eq "$($CurrentCI)/VI/VS" }
}

$AppDcmCIs = Send-ConfigMgrPolicyBodyDownloadRequest @Parameters -Assignments $ReqAppsVIs -GetReferecencedDocuments


$CIDocs = $AppDcmCIs.XMLFromRawPolicyText.Documents | ? {$_.DocumentType -eq 1 } | Select-Object -ExpandProperty 'Id' | % {
    Get-CIDocument -DocumentID $_ -ManagementPoint $ManagementPoint | ? {
        $_.OuterXml -match 'AppModel'
    } | % {
        Get-CIDocument -DocumentID $_.ConfigurationItemManifest.VersionSpecificImpl.SmlIfDocument.DocumentName."#text" -ManagementPoint $ManagementPoint | ?  { 
            ($_.model.instances.document | ? { $_.DocumentType -eq 0 } | Select-Object -ExpandProperty data).AppMgmtDigest.Application.AutoInstall
        } | % {
            $CurrentDocument = $_
            ($_.model.instances.document | ? { $_.DocumentType -eq 0 }).data.AppMgmtDigest.Application.Title."#text"
        }
    }
} | ForEach-Object -Begin {
        $GroupNum = 0
        $i = 1
    } -Process {
        $VariableName = ("{0}{1}{2:d2}" -f $BaseVariableName,$GroupNum,$i)
        Write-Host ("{0} = '{1}'" -f $VariableName,$_)
        #if (-not (Get-Variable -ErrorAction Ignore -Name $VariableName)) {
        #    New-Variable -Name $VariableName -Value $_
        #}
        #else {
        #    Set-Variable -Name $VariableName -Value $_
        #}
        if ($Script:TsEnv) {
            $Script:TsEnv.Value($VariableName) = $_
        }
    
        if ($i -eq 99 ) {
            $GroupNum++
            $i=0
        }

        $i++
}