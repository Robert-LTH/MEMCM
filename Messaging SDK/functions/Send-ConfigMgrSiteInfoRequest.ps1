function Send-ConfigMgrSiteInfoRequest {
	param(
		[Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
		[string] $ClientSMSID,
		[Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
		[string] $SiteCode
	)
	$ConfigMgrSiteInfoRequest=[Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrSiteInfoRequest]::new()
	if (-not $ConfigMgrSiteInfoRequest) {
		throw "Failed to init ConfigMgrSiteInfoRequest"
	}
	
	$ConfigMgrSiteInfoRequest.Discover()
	$ConfigMgrSiteInfoRequest.SmsId = $ClientSMSID
	$ConfigMgrSiteInfoRequest.Settings.CloneSettings($MessageSettings)
	$ConfigMgrSiteInfoRequest.SiteCode = $SiteCode
	if ($SigningCertificate) {
        $ConfigMgrSiteInfoRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrSiteInfoRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
	}

	$ConfigMgrSiteInfoRequest.Validate()
	$ConfigMgrSiteInfoRequest.SendMessage($HttpSender) | Select-Object -ExpandProperty SiteInfoReply
}