function Get-MEMCMSiteCode {
	param(
		$TsEnv,
		$ManagementPoint
	)

	if ($TsEnv) {
		$SiteCode = $TsEnv.Value("_SMSTSSiteCode")
    }
    else {
		if ($ManagementPoint) {
			$SiteCode = Get-CimInstance -Namespace root/ccm/LocationServices -ClassName SMS_MPInformation -Filter "MP = '$ManagementPoint'" | Select-Object -ExpandProperty SiteCode
		}
        else {
			$SiteCode = Get-CimInstance -Namespace root/ccm/LocationServices -ClassName SMS_MPInformation | Select-Object -ExpandProperty SiteCode -First 1
		}
    }

	Write-Output $SiteCode
}