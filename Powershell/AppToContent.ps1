# Has PackageID
Get-CimInstance -ComputerName sccm.pc.lu.se -Namespace root\sms\site_pls -ClassName SMS_ApplicationLatest -Filter "LocalizedDisplayName = 'Notepad++'"

# Can refreshpkgsrc
Get-CimInstance -ComputerName sccm.pc.lu.se -Namespace root\sms\site_pls -ClassName SMS_ContentPackage -Filter "Name = 'Notepad++'"

# Has path to content source
Get-CimInstance -ComputerName sccm.pc.lu.se -Namespace root\sms\site_pls -ClassName SMS_Content -Filter "SecurityKey = 'ScopeId_ABCD/Application_EFGH'"
