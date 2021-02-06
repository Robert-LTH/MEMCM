function Send-ConfigMgrDataDiscoveryRecordMessage {
    param(
        $ClientSMSID,
        $SiteCode,
        $AdSiteName,
        $DomainName,
        $ComputerName,
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender]$HttpSender,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings]$MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$EncryptionCertificate
    )

	$ConfigMgrDataDiscoveryRecordMessage = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrDataDiscoveryRecordMessage]::new()
	$ConfigMgrDataDiscoveryRecordMessage.Discover()

    $CCMSystem = [Microsoft.ConfigurationManagement.Messaging.Messages.InventoryInstanceElementCcmSystem]::new($ComputerName)
    
    $CCMSystem.ClientId = $ClientSMSID
    $ConfigMgrDataDiscoveryRecordMessage.DdrInstances.Add([Microsoft.ConfigurationManagement.Messaging.Messages.InventoryInstance]::new($CCMSystem))
    
    $ConfigMgrDataDiscoveryRecordMessage.AdSiteName = $AdSiteName
    $ConfigMgrDataDiscoveryRecordMessage.DomainName = $DomainName
    $ConfigMgrDataDiscoveryRecordMessage.SiteCode = $SiteCode
    $ConfigMgrDataDiscoveryRecordMessage.SmsId = $ClientSMSID
    $ConfigMgrDataDiscoveryRecordMessage.Settings.CloneSettings($MessageSettings)
    if ($SigningCertificate) {
        $ConfigMgrStatusMessage.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrStatusMessage.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

    $ConfigMgrDataDiscoveryRecordMessage.Validate()
    $ConfigMgrDataDiscoveryRecordMessage.SendMessage($HttpSender)
}