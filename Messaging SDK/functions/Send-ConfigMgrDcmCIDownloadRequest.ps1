function Send-ConfigMgrDcmCIDownloadRequest {
	param(
        $DcmCIDownloadRequestList,
        [switch] $GetReferecencedDocuments,
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        $ClientSMSID,
        $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate
    )
    $ConfigMgrDcmCIDownloadRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrDcmCIDownloadRequest]::new()
    if (-not $ConfigMgrDcmCIDownloadRequest) {
        throw "Failed to init ConfigMgrDcmCIDownloadRequest"
    }
    $ConfigMgrDcmCIDownloadRequest.Discover()

    $DcmCIDownloadRequestList | ForEach-Object {
        $ConfigMgrDcmCIDownloadRequest.AddCIVersionInfoPolicyInstance($_)
    }

    $ConfigMgrDcmCIDownloadRequest.SmsId = $ClientSMSID
    $ConfigMgrDcmCIDownloadRequest.SiteCode = $SiteCode
    $ConfigMgrDcmCIDownloadRequest.Settings.CloneSettings($MessageSettings)

    if ($SigningCertificate) {
        $ConfigMgrDcmCIDownloadRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }

    if ($EncryptionCertificate) {
        $ConfigMgrDcmCIDownloadRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

    $ConfigMgrDcmCIDownloadReply = $ConfigMgrDcmCIDownloadRequest.SendMessage($HttpSender)
    
    if ($ConfigMgrDcmCIDownloadReply) {
        $zlib = New-Object Microsoft.ConfigurationManagement.Messaging.Framework.ZlibCompression
        
        $ConfigMgrDcmCIDownloadReply.ReplyDcmCIs | ForEach-Object {
            $_.Document.Decompress($zlib.GetType())
            $_.Document.StripUnicodeBom()
        }
    }
    
    Write-Output $ConfigMgrDcmCIDownloadReply
}