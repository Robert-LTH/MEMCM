$SiteServerFqdn = ""
$CollectionID = ""
$SiteCode = ""

$Parameters = @{
  ComputerName = $SiteServerFqdn
  MethodName = 'MachinesToWakeup'
  ClassName = "SMS_SleepServer"
  Arguments = @{ CollectionID = $CollectionID }
  Namespace = "root/sms/site_$SiteCode"
}

Invoke-CimMethod @Parameters
