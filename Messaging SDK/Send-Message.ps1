$ErrorActionPreference = "Stop"

. "$PSScriptRoot\functions\Get-MEMCMSMSID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMManagementPoint.ps1"
. "$PSScriptRoot\functions\Get-MEMCMHardwareID.ps1"
. "$PSScriptRoot\functions\Get-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Get-MEMCMComputerName.ps1"
. "$PSScriptRoot\functions\New-MEMCMHttpSender.ps1"
. "$PSScriptRoot\functions\Get-MEMCMSiteCode.ps1"
. "$PSScriptRoot\functions\New-MessageSettings.ps1"
. "$PSScriptRoot\functions\Write-CMLogEntry.ps1"
. "$PSScriptRoot\functions\Load-MessagingSDKDLLs.ps1"
. "$PSScriptRoot\functions\New-MEMCMCertificate.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrRegistrationRequest.ps1"
. "$PSScriptRoot\functions\New-SMS_UnknownStatusMessage.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrStatusMessage.ps1"
. "$PSScriptRoot\functions\Get-InWinPE.ps1"
. "$PSScriptRoot\functions\Send-ConfigMgrDataDiscoveryRecordMessage.ps1"

Load-MessagingSDKDLLs

$MessageSeverity = "Info"
$SMSModuleName = 'SMS Provider'
$SMSComponent = 'SMSComponent'

$HttpSender = New-MEMCMHttpSender
$HardwareID = Get-MEMCMHardwareID
$ComputerName = Get-MEMCMComputerName
$DomainName = "ENTER A SUITEABLE DOMAINNAME HERE"
$ClientFqdn = ("{0}.{1}" -f $ComputerName,$DomainName)
$ClientSMSID = Get-MEMCMSMSID
$ManagementPoint = Get-MEMCMManagementPoint
$SiteCode = Get-MEMCMSiteCode
$MessageSettings = New-MessageSettings -ManagementPointHostname $ManagementPoint

$ShouldRegister = $false

$SigningCertificate = Get-MEMCMCertificate -Purpose 'Signing'
if (-not $SigningCertificate) {
    try {
        $SigningCertificate = New-MEMCMCertificate -Signing -SaveInStore -ComputerName $ComputerName
    } catch {
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $SigningCertificate = New-MEMCMCertificate -Signing -ComputerName $ComputerName
    }
    $ShouldRegister = $true
}

$EncryptionCertificate = Get-MEMCMCertificate -Purpose 'Encryption'
if (-not $EncryptionCertificate) {
    try {
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -SaveInStore -ComputerName $ComputerName
    } catch {
        Write-CMLogEntry -Severity 2 -Value "Failed to create and store certificate, creating a volatile certificate"
        $EncryptionCertificate = New-MEMCMCertificate -Encryption -ComputerName $ComputerName
    }
    $ShouldRegister = $true
}

try
{
    $TsEnv=New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch
{
	Write-Host "Failed to init TSEnv"
}

function Get-MessageSeverity {
    param(
        $Severity
    )
    Switch($Severity)
    {
    "Info"      {1073741824}
    "Warning"   {2147483648}
    "Error"     {3221225472}
    }
}

$Parameters = @{
    HttpSender = $HttpSender
    ClientSMSID = $ClientSMSID
    MessageSettings = $MessageSettings
    SigningCertificate = $SigningCertificate
    SiteCode = $SiteCode
}

$RegisterMEMCMClient = @{
    HardwareID = $HardwareID
    ComputerName = $ComputerName
    ClientFqdn = $ClientFqdn
    EncryptionCertificate = $EncryptionCertificate
}

if ($ShouldRegister) {
    $Global:ClientSMSID = Send-ConfigMgrRegistrationRequest @Parameters @RegisterMEMCMClient
}

Start-Sleep -Seconds 10

$DDRParameters = @{
    AdSiteName = $AdSiteName
    DomainName = $DomainName
    ComputerName = $ComputerName
}

if ($ShouldRegister) {
    Send-ConfigMgrDataDiscoveryRecordMessage @Parameters @DDRParameters
}

$ActiveComputerName = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name 'ComputerName'

$NewSMSUnknownStatusMessageParameters = @{
    Attribute408 = $ClientSMSID
    InsertionString1 = ""
    InsertionString9 = $ClientSMSID
    InsertionString10 = $HardwareID
    InsertionString2 = ""
    InsertionString3 = ""
    InsertionString4 = ""
    InsertionString5 = ""
    InsertionString6 = ""
    InsertionString7 = $ActiveComputerName
    ComponentName = $SMSComponent
    MessageID = (Get-MessageSeverity -Severity 'Info') + 60000
    ModuleName = $SMSModuleName
    MachineName = $ComputerName
}

if ($TsEnv) {
    $NewSMSUnknownStatusMessageParameters.InsertionString1 = $TsEnv.Value("SelectedOrganisation")
    $NewSMSUnknownStatusMessageParameters.InsertionString2 = $TsEnv.Value("XHWChassisType")
    $NewSMSUnknownStatusMessageParameters.InsertionString3 = $TsEnv.Value("_SMSTSModel")
    $NewSMSUnknownStatusMessageParameters.InsertionString4 = $TsEnv.Value("_SMSTSMake")
    $NewSMSUnknownStatusMessageParameters.InsertionString5 = $TsEnv.Value("_SMSTSMacAddresses")
    $NewSMSUnknownStatusMessageParameters.InsertionString6 = $TsEnv.Value("_SMSTSUUID")
}

$StatusMessage = New-SMS_UnknownStatusMessage @NewSMSUnknownStatusMessageParameters

$SendConfigMgrStatusMessageParameters = @{
    StatusMessage = $StatusMessage
}

Send-ConfigMgrStatusMessage @Parameters @SendConfigMgrStatusMessageParameters