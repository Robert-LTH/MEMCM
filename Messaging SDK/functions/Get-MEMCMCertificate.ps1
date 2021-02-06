function Get-MEMCMCertificate {
    param(
        [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]$Purpose = 'Signing'
    )
    # MessageCertificateX509File::new() doesn't work unless running as admin
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "User is not an administrator!"
    
    }
    # Get the certificate from the certificate store
    try {
        $_Certificate = Get-ChildItem -ErrorAction SilentlyContinue -Path "Cert:\LocalMachine\SMS" | Where-Object { $_.FriendlyName -eq "SMS $Purpose Certificate" } |
                        Sort-Object -Property NotBefore -Descending | 
                            Select-Object -First 1
        # If no certificate is found there is no need to continue
        if (-not $_Certificate) {
            return $null
        }
        $Certificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]::new('SMS', $_Certificate.Thumbprint)
        return $Certificate
    } catch {
        throw "Failed to get the clients certificate, purpose $Purpose. $_"
    }
}