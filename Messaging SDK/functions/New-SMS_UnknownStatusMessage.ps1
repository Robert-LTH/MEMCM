function New-SMS_UnknownStatusMessage {
    param(
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute400,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute401,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute402,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute403,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute404,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute408,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute410,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute412,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute413,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$Attribute419,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString1,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString2,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString3,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString4,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString5,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString6,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString7,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString8,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString9,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$InsertionString10,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ComponentName,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        #[ValidateRange(0,65535)]
        [int]$MessageId,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$ModuleName,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$MachineName
    )
    $UnknownStatusMessage = New-Object Microsoft.ConfigurationManagement.Messaging.StatusMessages.UnknownStatusMessage

    # Set the properties of UnknownStatusMessage with the value of the supplied parameter
    $PSBoundParameters.Keys | ForEach-Object {
        if ($PSBoundParameters.ContainsKey($_) -and -not [string]::IsNullOrEmpty($PSBoundParameters.Item($_))) {
            $UnknownStatusMessage."$($_)" = $PSBoundParameters.Item($_)
        }
    }

    Write-Output $UnknownStatusMessage
}