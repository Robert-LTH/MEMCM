function Send-ConfigMgrBitsDownloadRequest {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrContentLocationReply] $ContentLocationReply,
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        $ClientSMSID,
        $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate,
        [string] $Destination
    )

    # A ConfigMgrBitsDownloadRequest needs a contentlocationreply
    $ConfigMgrBitsDownloadRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrBitsDownloadRequest]::new($ContentLocationReply)
    if (-not $ConfigMgrBitsDownloadRequest) {
        throw "Failed to create a ConfigMgrBitsDownloadRequest object"
    }
    
    # Discover() sometimes sets properties needed to continue, always call it before setting more properties
    $ConfigMgrBitsDownloadRequest.Discover()
    
    # Copy settings from the supplied messagesettings
    $ConfigMgrBitsDownloadRequest.Settings.CloneSettings($MessageSettings)

    # Set the destination folder of the download. It will be created automatically.
    $ConfigMgrBitsDownloadRequest.LocalDownloadPath = $Destination
    
    # Set the SmsId of the request
    $ConfigMgrBitsDownloadRequest.SmsId = $ClientSMSID

    # If a signing certificate was supplied, add it to the request
    if ($SigningCertificate) {
        $ConfigMgrBitsDownloadRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }

    # If an encryption certificate was supplied, add it to the request
    if ($EncryptionCertificate) {
        $ConfigMgrBitsDownloadRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }
    
    # sanity check = Validate()
    $ConfigMgrBitsDownloadRequest.Validate()

    # Send using the supplied HttpSender
    $ConfigMgrBitsDownloadRequest.SendMessage($HttpSender)
}