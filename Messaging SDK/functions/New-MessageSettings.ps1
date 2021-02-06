function New-MessageSettings {
    param(
        $ManagementPointHostname,
        [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSourceType]$MessageSourceType,
        [switch]$UseCompression
    )
    $MessageSettings = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageSettings]::new()
    $MessageSettings.HostName = $ManagementPointHostname
    
    if ($UseCompression.IsPresent) {
        $MessageSettings.ReplyCompression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
        $MessageSettings.Compression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
    }
    
    if ($MessageSourceType) {
        $MessageSettings.MessageSourceType = $MessageSourceType
    }
    
    Write-Output $MessageSettings
}