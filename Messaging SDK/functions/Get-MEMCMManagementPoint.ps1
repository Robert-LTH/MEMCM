function Get-MEMCMManagementPoint {
    param(
        $TsEnv
    )

    if ($TsEnv) {
        $MPHostname = $TsEnv.Value("_SMSTSMP").Replace("http://","").Replace("https://","")
    }
    else {
        $MPHostname = (Get-CimInstance -ErrorAction SilentlyContinue -Class SMS_Authority -Namespace root/ccm -Property CurrentManagementPoint | Select-Object -ExpandProperty CurrentManagementPoint)
    }

    Write-Output $MPHostname
}