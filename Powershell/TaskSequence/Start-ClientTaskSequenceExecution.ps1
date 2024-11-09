param (
    [string]$PackageID
)

$UIResourceMgr = New-Object -ComObject "UIResource.UIResourceMgr"
$UIResourceMgr.GetAvailableApplications() | Where-Object { $_.PackageId -eq $PackageID } | ForEach-Object {
    Write-Host "Initiating task sequence with PackageID $($_.PackageID)"
    $UIResourceMgr.ExecuteProgram($_.Id,$_.PackageId,$true)
}
