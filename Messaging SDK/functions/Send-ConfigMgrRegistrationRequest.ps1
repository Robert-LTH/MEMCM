function Send-ConfigMgrRegistrationRequest {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        [string] $AgentIdentity = "SomeAgent",
        [string] $HardwareID,
        [string] $ComputerName,
        [string] $ClientSMSID,
        [string] $ClientFqdn,
        [string] $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate
    )

    if (-not $SigningCertificate -or -not $EncryptionCertificate) {
        throw "Signing or encryption certificate is missing!"
    }

    $ConfigMgrRegistrationRequest = New-Object Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrRegistrationRequest
    $ConfigMgrRegistrationRequest.Discover()
    $ConfigMgrRegistrationRequest.Settings.CloneSettings($MessageSettings)

    if ($HardwareID) {
        $ConfigMgrRegistrationRequest.HardwareId = $HardwareID
    }
    
    $ConfigMgrRegistrationRequest.ClientFqdn = $ClientFqdn
    $ConfigMgrRegistrationRequest.AgentIdentity = $AgentIdentity
    $ConfigMgrRegistrationRequest.NetBiosName = $ComputerName
    
    if ($ClientSMSID) {
        $ConfigMgrRegistrationRequest.RequestedSmsId = $ClientSMSID
        $ConfigMgrRegistrationRequest.SmsId = $ClientSMSID
    }
    
    if ($SigningCertificate) {
        $ConfigMgrRegistrationRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrRegistrationRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

    $ConfigMgrRegistrationRequest.Validate()
    $SMSID = $ConfigMgrRegistrationRequest.RegisterClient($HttpSender, [TimeSpan]::FromMinutes(5))
    
    Write-Output $SMSID
}