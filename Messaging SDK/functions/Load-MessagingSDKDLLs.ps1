function Load-MessagingSDKDLLs {
    @(
        'Microsoft.ConfigurationManagement.Messaging.dll'
        'Microsoft.ConfigurationManagement.Security.Cryptography.dll'
    ) | ForEach-Object {
        $FilePath = Join-Path $PSScriptRoot -ChildPath $_

        if (-not (Test-Path -Path $FilePath)) {
            throw "The required DLL '$_' is not availabe in '$PSScriptRoot'"
        }

        if ($FilePath -notin ([AppDomain]::CurrentDomain.GetAssemblies().Location)) {
            Add-Type -Path $FilePath
        }
    }
}