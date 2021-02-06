# https://github.com/MSEndpointMgr/ConfigMgr
function Write-CMLogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the smsts.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$true, HelpMessage="Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("1", "2", "3")]
        [string]$Severity,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "MessageSDK.log",

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath = "$($env:SystemRoot)\Logs"
    )
    # Determine log file location
    try {
        $LogFilePath = Join-Path -Path $Script:TSEnv.Value("_SMSTSLogPath") -ChildPath $FileName
    } catch {
        $LogFilePath = Join-Path -Path $LogPath -ChildPath $FileName
    }

    # Construct time stamp for log entry
    $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), "+", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))

    # Construct date for log entry
    $Date = (Get-Date -Format "MM-dd-yyyy")

    # Construct context for log entry
    $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

    # Construct final log entry
    $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""Out of band baseline application"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"

    # Add value to log file
    try {
        Add-Content -Value $LogText -LiteralPath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $FileName file"
    }
}