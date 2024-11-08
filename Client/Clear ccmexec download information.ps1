Get-CimInstance -Namespace ROOT\ccm\DataTransferService -ClassName CCM_DTS_JobEx | Remove-CimInstance
Get-CimInstance -Namespace ROOT\ccm\DataTransferService -ClassName CCM_DTS_JobItemEx | Remove-CimInstance
Get-CimInstance -Namespace root\ccm\SoftMgmtAgent -ClassName DownloadInfoEx2 | Remove-CimInstance
Get-CimInstance -Namespace root\ccm\SoftMgmtAgent -ClassName ContentRequestEx2 | Remove-CimInstance
Get-CimInstance -Namespace root\ccm\SoftMgmtAgent -ClassName DownloadContentRequestEx2 | Remove-CimInstance
Get-CimInstance -Namespace ROOT\ccm\ContentTransferManager -ClassName CCM_CTM_ContentLocationEx | Remove-CimInstance
Get-CimInstance -Namespace ROOT\ccm\ContentTransferManager -ClassName CCM_CTM_JobStateEx4 | Remove-CimInstance
Get-CimInstance -Namespace ROOT\ccm\LocationServices -ClassName LocationRequestEx | Remove-CimInstance
Get-Service ccmexec | Restart-Service
