function Get-MEMCMSMSID {
    param(
        $TsEnv
    )

    if ($TsEnv -and $TsEnv.Value("_SMSTSClientGuid") -ne $TsEnv.Value("_SMSTSx64UnknownMachineGUID") -and $TsEnv.Value("_SMSTSClientGuid") -ne $TsEnv.Value("_SMSTSx86UnknownMachineGUID")) {
        if ($TsEnv.Value("_SMSTSClientIdentity")) {
            $SMSID = $TsEnv.Value("_SMSTSClientIdentity")
        }
        elseif ($TsEnv.Value("_SMSTSClientGuid")) {
            $SMSID = $TsEnv.Value("_SMSTSClientGuid")
        }
    }

    # the global variable ClientSMSID is used if the client is handed a new guid during registration 
    elseif ($Global:ClientSMSID) {
            $SMSID = $Global:ClientSMSID
    }
    else {
        $SMSID = Get-CimInstance -ErrorAction SilentlyContinue -Namespace root/ccm -ClassName CCM_Client -Property ClientID | Select-Object -ExpandProperty ClientID
    }

    # if no guid were retrieved, return a new instance of SmsClientId which has a guid as follows: GUID:00000000-0000-0000-0000-000000000000
    if ([string]::IsNullOrEmpty($SMSID)) {
            $SMSID = [Microsoft.ConfigurationManagement.Messaging.Framework.SmsClientId]::new()
    }
    Write-Output $SMSID
}