function Get-AssignmentProperties {
    param(
        $Assignment
    )
    $obj = New-Object PSCustomObject
    $Assignment.Properties | % {
        $obj | Add-Member -Force $_.PropertyName $_.Value
    }
    $obj
}   