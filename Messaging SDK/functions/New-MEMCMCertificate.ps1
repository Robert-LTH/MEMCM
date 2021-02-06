function New-MEMCMCertificate {
    param(
        [switch]$SaveInStore,
        [switch]$Encryption,
        $ComputerName
    )
    
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "User is not an administrator!"
    }
    
    $FriendlyName = "SMS Signing Certificate"
    $OID = "1.3.6.1.4.1.311.101"

    if ($Encryption.IsPresent) {
        $FriendlyName = "SMS Encryption Certificate"
        $OID = "1.3.6.1.4.1.311.101.2"
    }
    
    $SubjectName = "CN=$ComputerName,CN=SMS"
    
    $ValidFrom = (Get-Date).AddHours(-1)
    $ValidUntil = Get-Date -Year ($ValidFrom.Year+100)

    if ($SaveInStore.IsPresent) {
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509]::CreateAndStoreSelfSignedCertificate($SubjectName,$FriendlyName,"SMS",'LocalMachine',@($OID),$ValidFrom,$ValidUntil)
    }
    else {
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509]::CreateSelfSignedCertificate($SubjectName,$FriendlyName,@($OID),$ValidFrom,$ValidUntil)
    }
}