function Send-ConfigMgrPolicyBodyDownloadRequest {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
        $ClientSMSID,
        $SiteCode,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File] $EncryptionCertificate,
        $AssignmentReply,
        $Assignments
    )
    if ($AssignmentReply) {
        $ConfigMgrPolicyBodyDownloadRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrPolicyBodyDownloadRequest]::new($AssignmentReply)
    }
    else {
        $ConfigMgrPolicyBodyDownloadRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrPolicyBodyDownloadRequest]::new()
        $Assignments | ForEach-Object {
            $ConfigMgrPolicyBodyDownloadRequest.AddPolicyAssignment($_)
        }
    }
	$ConfigMgrPolicyBodyDownloadRequest.Discover()
    $ConfigMgrPolicyBodyDownloadRequest.DownloadDcmCIs = $true	
    $ConfigMgrPolicyBodyDownloadRequest.SmsId = $ClientSMSID
	$ConfigMgrPolicyBodyDownloadRequest.Settings.CloneSettings($MessageSettings)
	$ConfigMgrPolicyBodyDownloadRequest.SiteCode = $SiteCode
	if ($SigningCertificate) {
        $ConfigMgrPolicyBodyDownloadRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrPolicyBodyDownloadRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

	$ConfigMgrPolicyBodyDownloadRequest.Validate()
    $ConfigMgrPolicyBodyDownloadReply = $ConfigMgrPolicyBodyDownloadRequest.SendMessage($HttpSender)

	$ConfigMgrPolicyBodyDownloadReply.ReplyPolicyBodies | ForEach-Object -Process {
        $_ | Add-Member XMLFromRawPolicyText ([Microsoft.ConfigurationManagement.Messaging.Messages.CIVersionInfoPolicyInstance]::CreateFromXML($_.RawPolicyText))
        $_
    }
}