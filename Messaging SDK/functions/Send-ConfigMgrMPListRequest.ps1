function Send-ConfigMgrMPListRequest {
	param(
		[Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
		[string] $ClientSMSID,
		[Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
		[string] $ManagementPoint
	)
	$ConfigMgrMPListRequest=[Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrMPListRequest]::new()
	if (-not $ConfigMgrMPListRequest) {
		throw "Failed to init ConfigMgrMPListRequest"
	}
	
	$ConfigMgrMPListRequest.Discover()
	$ConfigMgrMPListRequest.SmsId = $ClientSMSID
	$ConfigMgrMPListRequest.Settings.CloneSettings($MessageSettings)
	if ($SigningCertificate) {
        $ConfigMgrMPListRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
    }
    if ($EncryptionCertificate) {
        $ConfigMgrMPListRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
	}
	
	$ConfigMgrMPListRequest.Validate()
	$ConfigMgrMPListRequest.SendMessage($HttpSender) | Select-Object -ExpandProperty MPList | Select-Object -ExpandProperty ManagementPoints

}