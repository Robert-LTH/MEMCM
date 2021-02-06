. "$PSScriptRoot\Get-ModelFromPolicy.ps1"
. "$PSScriptRoot\Get-CISetting.ps1"

function Get-MEMCMBaselineSettings {
	param(
		$Policy,
        $ManagementPoint,
		$List
	)

	if ($null -eq $List) {
		throw "List is empty, can not proceed!"
		return
	}

	Get-ModelFromPolicy -Policy $Policy -ManagementPoint $ManagementPoint -Type 'Manifest' | ForEach-Object {
		$baseline = $_.DesiredConfigurationDigest.Baseline
			
		if ($baseline.RequiredItems) {
			$baseline.RequiredItems.ApplicationReference | ForEach-Object {
				$appref = $_
				$List | Where-Object { $_.ModelName -eq ("$($appref.AuthoringScopeId)/$($appref.LogicalName)") } | ForEach-Object {
					$CI = Get-ModelFromPolicy -Policy $_ -ManagementPoint $ManagementPoint -Type 'Manifest'
					Get-CISetting  -Purpose 'Required' -CI $CI.DesiredConfigurationDigest.Application
				}
			}
		}
		if ($baseline.OperatingSystems) {
			$baseline.OperatingSystems.OperatingSystemReference | ForEach-Object {
				$appref = $_
				$List | Where-Object { $_.ModelName -eq ("$($appref.AuthoringScopeId)/$($appref.LogicalName)") } | ForEach-Object {
					$CI = Get-ModelFromPolicy -Policy $_ -ManagementPoint $ManagementPoint -Type 'Manifest'
					Get-CISetting -Purpose 'Required' -CI $CI.DesiredConfigurationDigest.OperatingSystem
				}
			}
		}
        if ($baseline.ProhibitedItems) {
            # TODO
        }
        if ($baseline.OptionalItems) {
            # TODO
        }
        if ($baseline.SoftwareUpdates) {
            <#
            # TODO
            # Get content URL from MP and install it
            #>
        }
        if ($baseline.Baselines) {
            $baseline.Baselines.BaselineReference | ForEach-Object {
                $appref = $_
                $List | Where-Object { $_.ModelName -eq ("$($appref.AuthoringScopeId)/$($appref.LogicalName)") } | ForEach-Object {
                    Get-MEMCMBaselineSettings -Policy $_ -ManagementPoint $ManagementPoint -List $List
                }
            }
        }    
    }
}