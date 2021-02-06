. "$PSScriptRoot\Get-CIDocument.ps1"
function Get-ModelFromPolicy {
    param(
        $Policy,
        $ManagementPoint,
        $Type
    )
    
    if ($Type -eq 'Manifest') {
        $DocumentType = 1
        $DocumentProperty = 'ConfigurationItemManifest'
    }
    elseif ($Type -eq 'Properties') {
        $DocumentType = 2
        $DocumentProperty = 'ConfigurationItemProperties'
    }
    else {
        throw "Unknown type."
    }

    $DocumentId = $Policy.Documents | Where-Object { $_.DocumentType -eq $DocumentType } |Select-Object -ExpandProperty Id
    $BaselinePolicy = Get-CIDocument -ManagementPoint $ManagementPoint -DocumentID $DocumentId | Select-Object -ExpandProperty "$DocumentProperty"
    
    if ($DocumentType -eq 1) {
        $BaselineCIModel = Get-CIDocument -ManagementPoint $ManagementPoint -DocumentID $BaselinePolicy.VersionLatestImpl.SmlIfDocument.DocumentName."#text"
        ($BaselineCIModel.model.instances.document | Where-Object { $_.DocumentType -eq 0 }).data
    }
    elseif ($DocumentType -eq 2) {
        $BaselinePolicy
    }
}