function Get-CCMActualPolicyUpdateTimestamp {
    $Parameters = @{
        Namespace = "ROOT\ccm\PolicyAgent"
        ClassName = "CCM_ActualConfigUpdateInfo"
    }
    Get-CimInstance @Parameters | ForEach-Object { 
        @{
            NamespaceSID = $_.NamespaceSID
            UpdatedTime = [Datetime]::FromFileTime($_.UpdatedTime) 
        }
    }
}
