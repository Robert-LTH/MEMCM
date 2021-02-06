function Send-ConfigMgrContentLocationRequest {
	param(
		[string] $PackageID,
		[string] $PackageVersion,
		[Microsoft.ConfigurationManagement.Messaging.Messages.LocationType] $PackageType,
		[Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender] $HttpSender,
		[string] $ActiveDirectorySiteName,
		[string] $SiteCode,
		[string] $ClientSMSID,
		[Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings] $MessageSettings,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$SigningCertificate,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]$EncryptionCertificate
	)

	# A ConfigMgrContentLocationRequest initialized with $true will automatically discovery systeminformation, this fails if done in WinPE
	# Create the object and run Discover() later
	$ConfigMgrContentLocationRequest = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrContentLocationRequest]::new($false)
	if (-not $ConfigMgrContentLocationRequest) {
		throw "Failed to init ConfigMgrContentLocationRequest"
	}
	# Try Discover(), will fail in WinPE because of it can't discover ADSiteName
	try {
		$ConfigMgrContentLocationRequest.Discover() | Out-Null
	} catch {
		
		# Dicover() failed, run DiscoverIPAddresses() and set the ADSiteName "manually"
		$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.IPAddresses.DiscoverIPAddresses() | Out-Null
		if (-not [string]::IsNullOrEmpty($ActiveDirectorySiteName)) {
			$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.ADSite.ADSiteName = $ActiveDirectorySiteName
		}
	}

	$ConfigMgrContentLocationRequest.SiteCode = $SiteCode
	$ConfigMgrContentLocationRequest.Settings.CloneSettings($MessageSettings)
	$ConfigMgrContentLocationRequest.SmsId = $ClientSMSID

	if ($SigningCertificate) {
        $ConfigMgrContentLocationRequest.AddCertificateToMessage($SigningCertificate, 'Signing')
	}
    if ($EncryptionCertificate) {
        $ConfigMgrContentLocationRequest.AddCertificateToMessage($EncryptionCertificate, 'Encryption')
    }

	$ConfigMgrContentLocationRequest.LocationRequest.AssignedSite.SiteCode = $SiteCode

	$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.AllowHttp = 1
	$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.AllowCaching = 1
	$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.AllowSmb = 1
	$ConfigMgrContentLocationRequest.LocationRequest.ContentLocationInfo.LocationType = $PackageType

	$ConfigMgrContentLocationRequest.LocationRequest.Package.PackageId = $PackageID
	$ConfigMgrContentLocationRequest.LocationRequest.Package.Version = $PackageVersion

	$ConfigMgrContentLocationRequest.Validate()
	$ConfigMgrContentLocationRequest.SendMessage($HttpSender) | Select-Object -ExpandProperty LocationReply
}