function Get-RegistryValueType {
    param(
        $DataType
    )
    # Translate CI setting datatype to registry datatype
    switch ($DataType) {
        'Int64' { 'DWord' }
        Default { $DataType }
    }
}