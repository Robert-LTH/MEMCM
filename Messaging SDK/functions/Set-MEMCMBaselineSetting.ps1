. "$PSScriptRoot\Get-RegistryValueType.ps1"
function Set-MEMCMBaselineSetting {
	param(
		$BaselineSetting
	)

	$BaselineSetting.Settings.GetEnumerator() | ForEach-Object {
		
		$CurrentSetting = $_

		Switch ($CurrentSetting.SettingType) {
			"Script" {
				Write-CMLogEntry -Severity 1 -Value "Setting type is Script"
				if (-not ([string]::IsNullOrEmpty($CurrentSetting.RemediationScript.ScriptBody))) {

					try {
						Write-CMLogEntry -Severity 1 -Value "Executing discovery script"
						$DiscoveryResult = Invoke-Expression -Command $CurrentSetting.DiscoveryScript.ScriptBody
					} catch {
						Write-CMLogEntry -Severity 2 -Value "Something went wrong when running discoveryscript: $_"
					}
					Write-CMLogEntry -Severity 1 -Value "Discovered value: $DiscoveryResult"

					if ($DiscoveryResult -ne $CurrentSetting.Value) {
						Write-CMLogEntry -Severity 1 -Value "'$DiscoveryResult' -ne $($CurrentSetting.Value). Executing remediation script."
						try {
							$RemediationResult = Invoke-Expression -Command $CurrentSetting.RemediationScript.ScriptBody
						} catch {
							Write-CMLogEntry -Severity 2 -Value "Something went wrong when running discoveryscript: $_"
						}

						if ($RemediationResult -eq $CurrentSetting.Value) {
							Write-CMLogEntry -Severity 1 -Value "Remediation was successful!"
						}
						else {
							Write-CMLogEntry -Severity 2 -Value "Failed to remediate!`n'$RemediationResult' -ne '$($CurrentSetting.Value)'"
						}
					}
					else {
						Write-CMLogEntry -Severity 1 -Value "Discovered expected result."
					}
				}
				else {
					Write-CMLogEntry -Severity 1 -Value "Remediation script is missing, skip setting."
				}
			}

			"Registry" {
				if ($CurrentSetting.Hive -eq 'HKEY_CURRENT_USER') {
					Write-CMLogEntry -Severity 1 -Value "User setting, should write to default."
				}
				else {
					$RegPath = "Registry::{0}\{1}" -f $CurrentSetting.Hive,$CurrentSetting.Key

					if ($CurrentSetting.CreateMissingPath -and -not (Test-Path -ErrorAction Ignore -Path $RegPath)) {
						Write-CMLogEntry -Severity 1 -Value "$RegPath does not exist and CreateMissingPath is set, creating it."
						New-Item -Force -ItemType Container -Path $RegPath | Out-Null
					}

					$CurrentValue = Get-ItemProperty -ErrorAction Ignore -Path $RegPath -Name $CurrentSetting.ValueName | Select-Object -ExpandProperty "$($CurrentSetting.ValueName)"
					if ($CurrentValue) {
						Write-CMLogEntry -Severity 1 -Value "$RegPath - $($CurrentSetting.ValueName) - $CurrentValue"
					}

					if ([string]::IsNullOrEmpty("$CurrentValue")) {
						Write-CMLogEntry -Severity 1 -Value "Could not get the current value, set it to $($CurrentSetting.Value) with type $($CurrentSetting.ValueType)"
						New-ItemProperty -Path $RegPath -Name $CurrentSetting.ValueName -Value $CurrentSetting.Value -PropertyType (Get-RegistryValueType -DataType $CurrentSetting.ValueDataType) | Out-Null
					}
					elseif ($CurrentValue -ne $CurrentSetting.Value) {
						Write-CMLogEntry -Severity 1 -Value "$CurrentValue != $($CurrentSetting.Value)"
						Set-ItemProperty -Path $RegPath -Name $CurrentSetting.ValueName -Value $CurrentSetting.Value
					}
					else {
						Write-CMLogEntry -Severity 1 -Value ("{0} already has the value {1}" -f $CurrentSetting.Valuename,$CurrentSetting.Value)
					}
				}
			}
		}
	}
}