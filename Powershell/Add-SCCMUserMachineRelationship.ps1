function Add-SCCMUserMachineRelationship {
    param(
        [ValidateNotNullOrEmpty()]
        [string]$ResourceID,
        [ValidateNotNullOrEmpty()]
        [string]$UserName,
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-zA-Z]{3}")]
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$SiteCode,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteServer
    )
    $Method = 'CreateRelationship'
    $MethodClass = Get-WmiObject -Namespace "root\sms\site_$SiteCode" -ComputerName $SiteServer -List -Class SMS_UserMachineRelationship
    if ($MethodClass) {
        $InParams = $MethodClass.psbase.GetMethodParameters($Method)
        $InParams.MachineResourceId = $ResourceID
        $InParams.UserAccountName = $UserName
        <#
            enum UserMachineAffinitySource
            {
                None,
                SoftwareCatalog,
                Administrator,
                User,
                UsageAgent,
                DeviceManagement,
                OSD,
                FastInstall,
                ExchangeServerConnector,
            }
        #>
        $InParams.SourceId = 2
        <#
            enum UserDeviceAffinityType
            {
                DoNotUse,
                AllowWithManualApproval,
                AllowWithAutomaticApproval,
            }
        #>
        $InParams.TypeId = 1
        $Result = $MethodClass.InvokeMethod($Method, $InParams, $null)
        if ($Result.ReturnValue -ne '0') {
            throw "Failed to add relationship!"
        }
    }
    else {
        Write-Error -Message "Failed to get WmiClass 'SMS_ObjectContainerItem'. Parameters: ResourceID  = '$ResourceID', UserName = '$UserName'"
    }
}
