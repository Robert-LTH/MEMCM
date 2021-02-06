function Get-CISetting {
	param (
		$CI,
		$Purpose
	)

	$obj = [PSCustomObject] @{
		DisplayName = $CI.Annotation.DisplayName.Text
		Description = $CI.Annotation.Description.Text
		Settings = [System.Collections.ArrayList]::new()
		Purpose = $Purpose
	}

	$CI.Settings.RootComplexSetting.SimpleSetting | ForEach-Object {
		$settingsObj = [PSCustomObject]@{
			DisplayName = $_.Annotation.DisplayName.Text
			Description = $_.Annotation.Description.Text
			LogicalName = $_.LogicalName
            DataType = $_.DataType
		}
		
		if ($_.ScriptDiscoverySource) {
			$settingsObj | Add-Member Is64Bit $_.ScriptDiscoverySource.Is64Bit
			$settingsObj | Add-Member SettingType "Script"
			$settingsObj | Add-Member DiscoveryScript ([PSCustomObject]@{
				ScriptType = $_.ScriptDiscoverySource.DiscoveryScriptBody.ScriptType
				ScriptBody = $_.ScriptDiscoverySource.DiscoveryScriptBody."#text"
			})
			$settingsObj | Add-Member RemediationScript ([PSCustomObject]@{
				ScriptType = $_.ScriptDiscoverySource.RemediationScriptBody.ScriptType
				ScriptBody = $_.ScriptDiscoverySource.RemediationScriptBody."#text"
			})
		}

		if ($_.RegistryDiscoverySource) {
			$settingsObj | Add-Member Is64Bit $_.RegistryDiscoverySource.Is64Bit
			$settingsObj | Add-Member Hive $_.RegistryDiscoverySource.Hive
			$settingsObj | Add-Member SettingType "Registry"
			$settingsObj | Add-Member Depth $_.RegistryDiscoverySource.Depth
			$settingsObj | Add-Member CreateMissingPath $_.RegistryDiscoverySource.CreateMissingPath
			$settingsObj | Add-Member Key $_.RegistryDiscoverySource.Key
            $settingsObj | Add-Member ValueName $_.RegistryDiscoverySource.ValueName
		}
		
		# The expected value is stored as a rule
        $Rule = $CI.Rules.Rule | Where-Object { $_.Expression.Operands.SettingReference.SettingLogicalName -eq $settingsObj.LogicalName }
        $settingsObj | Add-Member Value $Rule.Expression.Operands.ConstantValue.Value
		$settingsObj | Add-Member ValueDataType $Rule.Expression.Operands.ConstantValue.DataType
		
		$obj.Settings.Add($settingsObj) | Out-Null
	}
    Write-Output $obj
}