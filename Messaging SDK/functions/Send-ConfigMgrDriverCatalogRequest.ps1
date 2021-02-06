function Send-ConfigMgrDriverCatalogRequest {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        $ClientSMSID,
        $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate,
        $Devices
    )
    $ConfigMgrDriverCatalogRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrDriverCatalogRequest]::new()
    if (-not $ConfigMgrDriverCatalogRequest) {
        throw "Failed to create request object"
    }
    $ConfigMgrDriverCatalogRequest.Discover()

    $ConfigMgrDriverCatalogRequest.SiteCode = $SiteCode
    $ConfigMgrDriverCatalogRequest.Settings.CloneSettings($MessageSettings)
    $ConfigMgrDriverCatalogRequest.SmsId = $ClientSMSID
    if ($SigningCertificate) {
        $ConfigMgrDriverCatalogRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrDriverCatalogRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

    # Add the supplied (Win32_PnPEntity) devices
    $Devices | ForEach-Object { 
        $ConfigMgrDriverCatalogRequest.AddDevice($_.DeviceID,$_.HardwareID)
        $Entity=$_
        $_.HardwareID | ForEach-Object {
            $ConfigMgrDriverCatalogRequest.AddDevice($Entity.DeviceID,$_,$true) 
        }
    }

    $ConfigMgrDriverCatalogRequest.Validate()
    $ConfigMgrDriverCatalogRequest.SendMessage($HttpSender)
}