function New-MEMCMHttpSender {
    param(
        $UserAgent,
        $ContentType
    )
    
    $HttpSender = New-Object Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender
    if (-not $HttpSender) {
        throw "Failed to create HttpSender"
    }

    if (-not [string]::IsNullOrEmpty($UserAgent)) {
        $HttpSender.UserAgent = $UserAgent
    }
    if (-not [string]::IsNullOrEmpty($ContentType)) {
        $HttpSender.ContentType = $ContentType
    }

    Write-Output $HttpSender
}