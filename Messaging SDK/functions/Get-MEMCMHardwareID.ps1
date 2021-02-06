. "$PSScriptRoot\Get-HashFromString.ps1"
. "$PSScriptRoot\Get-HexAsString.ps1"
. "$PSScriptRoot\Get-IsChassisTypeLaptop.ps1"
function Get-MEMCMHardwareID {
    $SystemEnclosureInformation = Get-CimInstance -Namespace "root/cimv2" -ClassName "Win32_SystemEnclosure"
    $SystemEnclosureSerialNumber = $SystemEnclosureInformation | Select-Object -ExpandProperty "SerialNumber"
    $SystemEnclosureChassisType = $SystemEnclosureInformation | Select-Object -ExpandProperty "ChassisTypes"
    $SystemEnclosureSMBIOSAssetTag = $SystemEnclosureInformation | Select-Object -ExpandProperty "SMBIOSAssetTag"
    $BaseBoardSerialNumber = Get-CimInstance -Namespace "root/cimv2" -ClassName "Win32_BaseBoard" | Select-Object -ExpandProperty "SerialNumber"
    $BIOSSerialNumber = Get-CimInstance -Namespace "root/cimv2" -ClassName "Win32_BIOS" | Select-Object -ExpandProperty "SerialNumber"
    
    # If the chassistype is known as a laptop the macaddress is replaced with <Not used on laptop>
    if (Get-IsChassisTypeLaptop -ChassisType $SystemEnclosureChassisType) {
        $MacAddress = "<Not used on laptop>"
    }
    else {
        # Macaddress of the first networkadapter with IPEnabled set to true is the one to be used
        $MacAddress = Get-CimInstance -Namespace "root/cimv2" -Query "SELECT Index, MACAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True" | Select-Object -First 1 -ExpandProperty MacAddress
    }

    $HashBytes = Get-HashFromString -String ("{0}!{1}!{2}!{3}!{4}" -f $SystemEnclosureSerialNumber,$SystemEnclosureSMBIOSAssetTag,$BaseBoardSerialNumber,$BIOSSerialNumber,$MacAddress)
    $HashString = Get-HexAsString -Bytes $HashBytes

    # MEMCM has 2: in front of the hash...
    Write-Output "2:$HashString"
}