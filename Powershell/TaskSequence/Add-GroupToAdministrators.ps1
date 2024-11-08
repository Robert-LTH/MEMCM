# Add a group, which name is stored in a TSEnv var, to Administrators
try {
    $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
    if (-not ([string]::IsNullOrEmpty($tsenv.Value("MMALocalAdminGroup")))) {
        $group=Get-LocalGroup -SID 'S-1-5-32-544'
        Start-Process -FilePath "net" -ArgumentList "localgroup Administrators `"$($tsenv.Value("MMALocalAdminGroup"))`" /add"
        #Add-LocalGroupMember -Member $tsenv.Value("MMALocalAdminGroup") -Group $group
        Write-Host ("Added '{1}' to '{0}'" -f $group.Name,$tsenv.Value("MMALocalAdminGroup"))
    }
} catch {
    Write-Host "failed to add member"
}
