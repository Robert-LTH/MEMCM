function Get-ADSiteName {
    # Return the name of the current Active Directory site
    $ADSiteName = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name
    if ([string]::IsNullOrEmpty($ADSiteName)) {
        throw "Failed to get ADSiteName"
    }
    Write-Output $ADSiteName
}