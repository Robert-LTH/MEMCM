function Send-ConfigMgrPolicyAssignmentRequest {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        $ClientSMSID,
        $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate
    )

    $SystemInformation = [Microsoft.ConfigurationManagement.Messaging.Framework.SystemInformation]::new($true)
    
    $PolicyAssignmentRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrPolicyAssignmentRequest]::new()
    $PolicyAssignmentRequest.Discover()
    $PolicyAssignmentRequest.SmsId = $ClientSMSID
    $PolicyAssignmentRequest.Settings.CloneSettings($MessageSettings)
    $PolicyAssignmentRequest.SiteCode = $SiteCode
    if ($SigningCertificate) {
        $PolicyAssignmentRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $PolicyAssignmentRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }
    $PolicyAssignmentRequest.SystemInformation = $SystemInformation

    $PolicyAssignmentRequest.Validate()
    $PolicyAssignmentReply = $PolicyAssignmentRequest.SendMessage($HttpSender)
    Write-Output $PolicyAssignmentReply
}