function Get-MEMCMComputerName {
    param(
        $TsEnv
    )

    if ($TsEnv) {
        if (-not [string]::IsNullOrEmpty($TsEnv.Value("OSDComputerName"))) {
            $ComputerName = $TsEnv.Value("OSDComputerName")
        }
        elseif (-not [string]::IsNullOrEmpty($TsEnv.Value("_SMSTSMachineName"))) {
            $ComputerName = $TsEnv.Value("_SMSTSMachineName")
        }
        else {
            $ComputerName = $env:COMPUTERNAME
        }
    }
    else {
        $ComputerName = $env:COMPUTERNAME
    }
    Write-Output $ComputerName
}