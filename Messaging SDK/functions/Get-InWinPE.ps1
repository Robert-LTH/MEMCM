function Get-InWinPE {
    $InWinPE = (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE")
    Write-Output $InWinPE
}