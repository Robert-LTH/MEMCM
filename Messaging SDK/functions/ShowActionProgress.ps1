function ShowActionProgress {
    param(
        $Message,
        $Step,
        $MaxStep
    )
    Write-CMLogEntry -Severity 1 -Value "[PROGRESS] $Message : $Step / $MaxStep"
    if ($Script:TsProgressUI -and $Script:TsEnv) {
        $Script:TsProgressUI.ShowActionProgress(`
        $Script:TsEnv.Value("_SMSTSOrgName"),`
        $Script:TsEnv.Value("_SMSTSPackageName"),`
        $Script:TsEnv.Value("_SMSTSCustomProgressDialogMessage"),`
        $Script:TsEnv.Value("_SMSTSCurrentActionName"),`
        [Convert]::ToUInt32($Script:TsEnv.Value("_SMSTSNextInstructionPointer")),`
        [Convert]::ToUInt32($Script:TsEnv.Value("_SMSTSInstructionTableSize")),`
        $Message,`
        $Step,`
        $MaxStep)
    }
    else {
        if ($Step -eq $MaxStep) {
            Write-Progress -Activity $Message -Completed
        }
        else {
            Write-Progress -Activity $Message -PercentComplete (($Step / $MaxStep)*100)
        }
    }
}