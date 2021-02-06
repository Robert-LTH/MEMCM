# If the content is converted to UTF8 or read correctly, this funtion is not needed!
function Get-XMLFromWebContent {
    param(
        [string]$Content,
        [switch]$Skip
    )
    if ([string]::IsNullOrEmpty($Content)) {
        throw "Get-XMLFromWebContent: Content was null or empty!"
    }
    $SkipNum = 0
    if ($skip.isPresent) {
        $SkipNum = 4
    }
    $ContentBytes = ([System.Text.Encoding]::UTF8).GetBytes($Content) |Select-object -skip $SkipNum | Where-Object { $_ -ne 0x0 -and $_ -ne 0x1D }
    $ContentString = [string]::new($ContentBytes)
    Write-Output ([xml]$ContentString)
}