. "$PSScriptRoot\Get-XMLFromWebContent.ps1"

function Get-CIDocument {
	param(
		$DocumentID,
        [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate,
        $ManagementPoint,
		$RequestType = '.sms_dcm',
		$Protocol = 'http'
	)
	# RequestType can be .sms_dcm or .sms_pol 
	# Uncertain which is used when but .sms_dcm hasn't let me down so far!

	$Uri = ("{0}://{1}:80/SMS_MP/{2}?Id&DocumentId={3}" -f $Protocol,$ManagementPoint,$RequestType,$DocumentID)

	$Parameters = @{
        UseDefaultCredentials = $true
        UseBasicParsing = $true
        Uri = $Uri
    }

	if ($Certificate) {
        $Parameters.Add('Certificate',$Certificate)
    }

	# TODO check response
	$content = Invoke-WebRequest @Parameters | Select-Object -ExpandProperty Content 

	# TODO Check encoding and convert to UTF8
	# Until then, try to convert to XML and if it fails skip first few bytes and try again
	if (-not [string]::IsNullOrEmpty($content)) {
	    try {
		    Get-XMLFromWebContent -Content $content
	    } catch {
		    Get-XMLFromWebContent -Content $content -Skip
	    }
    }
}