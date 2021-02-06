$ErrorActionPreference = "Stop"

. "$PSScriptRoot\functions\Load-MessagingSDKDLLs.ps1"
. "$PSScriptRoot\functions\Write-CMLogEntry.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrPolicyAssignmentRequest.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrPolicyBodyDownloadRequest.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrRegistrationRequest.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrDcmCIDownloadRequest.ps1"
. "$PSScriptRoot\functions\New-MEMCMHttpSender.ps1"
. "$PSScriptRoot\functions\New-MessageSettings.ps1"
. "$PSScriptRoot\functions\New-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSMSID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMManagementPoint.ps1"
. "$PSScriptRoot\functions\Get-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSiteCode.ps1"
. "$PSScriptRoot\functions\Get-MEMCMBaselineSettings.ps1"
. "$PSScriptRoot\functions\Set-MEMCMBaselineSetting.ps1"
. "$PSScriptRoot\functions\Get-MEMCMHardwareID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMComputerName.ps1"
. "$PSScriptRoot\functions\ShowActionProgress.ps1"
. "$PSScriptRoot\functions\Get-ModelFromPolicy.ps1"

Load-MessagingSDKDLLs

$StartDatetime = Get-Date

try {
    if (-not $Script:TsEnv) {
        $Script:TsEnv=New-Object -ComObject Microsoft.SMS.TSEnvironment
    }
}
catch {
    Write-Host "Failed to init TSEnv"
    Write-CMLogEntry -Severity 2 -Value "Failed to init TSEnv"
}

try {
    if (-not $Script:TsProgressUI) {
        $Script:TsProgressUI = New-Object -ComObject Microsoft.SMS.TsProgressUI
    }
}
catch {
    Write-Host "Failed to init TSProgressUI"
    Write-CMLogEntry -Severity 2 -Value "Failed to init TSProgressUI"
}

Write-CMLogEntry -Severity 1 -Value "FetchAndApplyBaselineSettings start"

$HttpSender = New-MEMCMHttpSender
$ClientSMSID = Get-MEMCMSMSID
$SiteCode = Get-MEMCMSiteCode
$ManagementPoint = Get-MEMCMManagementPoint
$ComputerName = Get-MEMCMComputerName
$HardwareID = Get-MEMCMHardwareID
$MessageSettings = New-MessageSettings -ManagementPointHostname $ManagementPoint
    
$Register = $false

$SigningCertificate = Get-MEMCMCertificate -Purpose 'Signing'
if (-not $SigningCertificate) {
    # If no certificate was found, try to create and store a new certificate
    try {
        Write-CMLogEntry -Severity 1 -Value ("Create and store signing certificate for {0}" -f $ComputerName)
        $SigningCertificate = New-MEMCMCertificate -Signing -SaveInStore -ComputerName $ComputerName
    } catch {
        # If the previous attempt failed, return a new certificate without trying to store it
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $SigningCertificate = New-MEMCMCertificate -Signing -ComputerName $ComputerName
    }
    Write-CMLogEntry -Severity 1 -Value "A new signing certificate was created, a client registration is needed."
    $Register = $true
}
Write-CMLogEntry -Severity 1 -Value ("Certificate (Signing) thumbprint: {0}" -f $SigningCertificate.Thumbprint)

$EncryptionCertificate = Get-MEMCMCertificate -Purpose 'Encryption'
if (-not $EncryptionCertificate) {
    # If no certificate was found, try to create and store a new certificate
    try {
        Write-CMLogEntry -Severity 1 -Value ("Create and store encryption certificate for {0}" -f $ComputerName)
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -SaveInStore -ComputerName $ComputerName
    } catch {
        # If the previous attempt failed, return a new certificate
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -ComputerName $ComputerName
    }
    Write-CMLogEntry -Severity 1 -Value "A new encryption certificate was created, a client registration is needed."

    # If a new certificate was created a registration with the site should be done
    $Register = $true
}
Write-CMLogEntry -Severity 1 -Value ("Certificate (Encryption) thumbprint: {0}" -f $EncryptionCertificate.Thumbprint)

$Parameters = @{
    HttpSender = $HttpSender
    ClientSMSID = $ClientSMSID
    SiteCode = $SiteCode
    MessageSettings = $MessageSettings
    SigningCertificate = $SigningCertificate
}

$ConfigMgrRegistrationRequestParameters = @{
    EncryptionCertificate = $EncryptionCertificate
    HardwareID = $HardwareID
    ComputerName = $ComputerName
}

if ($Register) {
    # A registration requests returns a SmsClientId if was successful. Save that Id for later.
    Write-CMLogEntry -Severity 1 -Value "Sending registration request"
    $Global:ClientSMSID = Send-ConfigMgrRegistrationRequest @Parameters @ConfigMgrRegistrationRequestParameters

    # If a SmsClientId was returned and its different from the one retrieved before, it has registered as new device object
    if ($Global:ClientSMSID -ne $Parameters.ClientSMSID) {
        Write-CMLogEntry -Severity 1 -Value ("Client was registered with a new SmsId: {0}" -f $Global:ClientSMSID)
    }

    # Let the server do it's thing for a few seconds
    StartDatetime-sleep -Seconds 10
}

ShowActionProgress -Message "Fetch policy assignments" -Step 1 -MaxStep 100

Write-CMLogEntry -Severity 1 -Value "Sending policy assignment request"
$PolicyAssignments = Send-ConfigMgrPolicyAssignmentRequest @Parameters

if (-not $PolicyAssignments) {
    Write-CMLogEntry -Severity 2 -Value "Failed to retrieve policy assignments."
    return
}

Write-CMLogEntry -Severity 1 -Value ("Recieved {0} assignments" -f $PolicyAssignments.ReplyAssignments.PolicyAssignments.Count)
    
ShowActionProgress -Message "Fetch policy bodies" -Step 1 -MaxStep 100

$ConfigMgrPolicyBodyDownloadRequestParameters = @{
    AssignmentReply = $PolicyAssignments
}

Write-CMLogEntry -Severity 1 -Value "Sending policy body download request"
$PolicyBodies = Send-ConfigMgrPolicyBodyDownloadRequest @Parameters @ConfigMgrPolicyBodyDownloadRequestParameters

if (-not $PolicyBodies) {
    Write-CMLogEntry -Severity 2 -Value "Failed to retrieve any PolicyBodies"
    return
}

Write-CMLogEntry -Severity 1 -Value ("Recieved {0} policy bodies" -f $PolicyBodies.Count)

ShowActionProgress -Message "Fetch baseline CIs" -Step 1 -MaxStep 100

$BaselinePolicyBodies = ($PolicyBodies.XMLFromRawPolicyText | Where-Object { $_.ModelName -match 'Baseline' })
if ($BaselinePolicyBodies.Count -le 0) {
    Write-CMLogEntry -Severity 3 -Value "No baselines to process!"
    return
}

$ConfigMgrDcmCIDownloadRequestParameters = @{
    DcmCIDownloadRequestList = $BaselinePolicyBodies
    GetReferecencedDocuments = $true
}

$DcmDocumentCIs = Send-ConfigMgrDcmCIDownloadRequest @Parameters @ConfigMgrDcmCIDownloadRequestParameters
if ($null -eq $DcmDocumentCIs.ReplyDcmCIs) {
    Write-CMLogEntry -Severity 3 -Value "No DcmCIs to process!"
    return
}

$DcmDocumentCIs.ReplyDcmCIs | ForEach-Object -Begin {
    # Count how many settings the baselines references
    $BaselineSettingsCount = ($DcmDocumentCIs.ReplyDcmCIs | ForEach-Object { ([xml]$_.Document.Payload).ConfigurationItemManifest.ConfigurationItemReferences.ConfigurationItemReference }).Count
    $i = 1
} -Process {
    $CurrentDcm = $_

    Get-MEMCMBaselineSettings -ManagementPoint $ManagementPoint -Policy $CurrentDcm.VersionInfo -List $PolicyBodies.XMLFromRawPolicyText | ForEach-Object -Begin {        
        Write-CMLogEntry -Severity 1 -Value "StartDatetime processing baselinesettings"
    } -Process {

        Write-CMLogEntry -Severity 1 -Value ("Applying {0} ({1}) with {2} settings." -f $_.DisplayName, $_.Purpose, $_.Settings.Count)
        Set-MEMCMBaselineSetting -BaselineSetting $_

        ShowActionProgress -Message "Applying settings" -Step $i -MaxStep $BaselineSettingsCount
        
        $i++
    } -end {
        Write-CMLogEntry -Severity 1 -Value "Done processing settings"
    }
}

Write-CMLogEntry -Severity 1 -Value "Operation took $((Get-Date).Subtract($StartDatetime).TotalSeconds) seconds"
Write-CMLogEntry -Severity 1 -Value "FetchAndApplySettings end"