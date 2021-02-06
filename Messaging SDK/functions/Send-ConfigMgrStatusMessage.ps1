function Send-ConfigMgrStatusMessage {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender]$HttpSender,
        $StatusMessage,
        $SiteCode,
        $ClientSMSID,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings]$MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$EncryptionCertificate
    )
    $ConfigMgrStatusMessage = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrStatusMessage]::new()
    $ConfigMgrStatusMessage.Discover()
    $ConfigMgrStatusMessage.InitializeOnParse = $true
    $ConfigMgrStatusMessage.ParseStatusMessage($StatusMessage)
    $ConfigMgrStatusMessage.SiteCode = $SiteCode
    $ConfigMgrStatusMessage.SmsId = $ClientSMSID
    $ConfigMgrStatusMessage.Settings.CloneSettings($MessageSettings)
    $ConfigMgrStatusMessage.Settings.MessageSourceType = 'Client'
    if ($SigningCertificate) {
        $ConfigMgrStatusMessage.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrStatusMessage.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

    $ConfigMgrStatusMessage.Validate()
    $ConfigMgrStatusMessage.SendMessage($HttpSender)
}