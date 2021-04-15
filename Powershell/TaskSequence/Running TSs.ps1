<#
  Quick and dirty - List TSs (since today -1) where the client have not reported a status message saying it finished the TS.
#>

$CIMParameters = @{
    Namespace = 'root\sms\site_SiteCode'
    ComputerName = 'siteserver.domain.tld'
}

$Now = Get-Date
Get-CimInstance @CIMParameters -ClassName SMS_TaskSequenceExecutionStatus -Filter "ExecutionTime > '$($Now.AddDays(-1).ToShortDateString())'" | Group-Object -Property ResourceID | Where-Object { '11143' -notin $_.Group.LastStatusMsgID } | ForEach-Object {
    $LastStep = $_.Group | Sort-Object -Property ExecutionTime | Select-Object -Last 1
    $Resource = Get-CimInstance @CIMParameters -ClassName 'SMS_R_System' -Filter "ResourceID = '$($LastStep.ResourceID)'"
    $TS = Get-CimInstance @CIMParameters -ClassName SMS_TaskSequencePackage -Filter "PackageID = '$($LastStep.PackageID)'"
    [PSCustomObject]@{
        ComputerName = $Resource.Name
        LastStep = $LastStep.Step
        LastStepName = $LastStep.ActionName
        ExecutionTime = $LastStep.ExecutionTime
        TS = $TS.Name
        TSRefreshTime = $TS.LastRefreshTime
    }
} | Out-GridView
