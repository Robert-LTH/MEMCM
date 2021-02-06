function Get-IsChassisTypeLaptop {
    param(
        [uint32]$ChassisType
    )
    Write-Output (($ChassisType - 8) -ge 0 -and (($ChassisType - 8) -lt 5) -or $ChassisType -eq 0xe)
}