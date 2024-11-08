function Convert-MEMCMSchedule {
    <#
        .EXAMPLE
            Convert-MEMCMSchedule -ScheduleString '75B5AC8000080001'
    #>
    param(
        [string] $ScheduleString
    )
    $Date = [Convert]::ToInt32($ScheduleString.Substring(0, 8), 16)
    $Flags = [Convert]::ToUInt32($ScheduleString.Substring(8), 16)
    $Minute = ($Date -shr 26) -band 63
    $Hour = ($Date -shr 21) -band 31
    $Day = ($Date -shr 16) -band 31
    $Month = ($Date -shr 12) -band 15
    $Year = (($Date -shr 6) -band 63) + 1970
    $IsGMT = $Flags -band 1
    if ($IsGMT) {
        $DatetimeKind = [DateTimeKind]::Utc
    }
    else {
        $DatetimeKind = [DateTimeKind]::local
    }
    $StartTime = [Datetime]::new($Year, $Month, $Day, $Hour, $Minute, 0, $DatetimeKind)
    
    $DurationMinutes = $Date -band 63
    $DurationHours = ($Flags -shr 27) -band 31
    $DurationDays = ($Flags -shr 22) -band 31
    $Duration = [TimeSpan]::new($DurationDays, $DurationHours, $DurationMinutes, 0)
    
    $dayOfWeek = 0
    $numOfWeeks = 0
    $weekOrder = 0
    $numOfMonths = 0
    $dateOfMonth = 0
    $RecurrenceFlags = ($Flags -shr 19) -band 7

    # Interval
    if ($RecurrenceFlags -eq 2) {
        $Recurrence = [TimeSpan]::new((($Flags -shr 3) -band 31), (($Flags -shr 8) -band 31), (($Flags -shr 13) -band 63), 0)
    }
    # Weekly
    elseif ($RecurrenceFlags -eq 3) {
        $dayOfWeek = (($Flags -shr 16) -band 7)
        $numOfWeeks = (($Flags -shr 13) -band 7)
        $Recurrence = [TimeSpan]::new(0)
    }
    # MonthlyByWeekday
    elseif ($RecurrenceFlags -eq 4) {
        $dayOfWeek = (($Flags -shr 16) -band 7)
        $numOfMonths = (($Flags -shr 12) -band 15)
        $weekOrder = (($Flags -shr 9) -band 7)
        $Recurrence = [TimeSpan]::new(0)
    }
    # MonthlyByDate
    elseif ($RecurrenceFlags -eq 5) {
        $dateOfMonth = (($Flags -shr 14) -band 31)
        $numOfMonths = (($Flags -shr 10) -band 15)
        $Recurrence = [TimeSpan]::new(0)
    }
    # NoneRecur (1) and else
    else {
        $Recurrence = [TimeSpan]::new(0)
    }
    [PSCustomObject] @{
        StartTime = $StartTime
        IsGMT = [bool]$IsGMT
        Duration = $Duration
        Reccurence = $Recurrence
        dayOfWeek = $dayOfWeek
        numOfWeeks = $numOfWeeks
        weekOrder = $weekOrder
        numOfMonths = $numOfMonths
        dateOfMonth = $dateOfMonth
    }
}
