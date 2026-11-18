<#
.SYNOPSIS
    Print new_post.ps1 command lines for every date in a date range (does not run them).

.PARAMETER StartDateArg
    Start date in yyyymmdd format, 8 digits (first argument, required)

.PARAMETER StartNumArg
    Episode number for the start date, as an integer (second argument, required).
    Incremented by 1 for each subsequent day.

.PARAMETER EndDateArg
    End date in yyyymmdd format, 8 digits (third argument, optional).
    Defaults to today's date if not specified.

.PARAMETER RecDateArg
    Recording date in yyyymmdd format, 8 digits (fourth argument, optional).
    Defaults to today's date if not specified.

.EXAMPLE
    ./new_post_commands.ps1 20261117 448 20261119 20261003
    -> prints:
       ./new_post.ps1 20261117 448 20261003 -Title "" -Description ""
       ./new_post.ps1 20261118 449 20261003 -Title "" -Description ""
       ./new_post.ps1 20261119 450 20261003 -Title "" -Description ""

.EXAMPLE
    ./new_post_commands.ps1 20261117 448
    -> end date and recording date both default to today's date
#>

param(
    [string]$StartDateArg,
    [string]$StartNumArg,
    [string]$EndDateArg,
    [string]$RecDateArg
)

$ErrorActionPreference = 'Stop'

# --- Argument validation ---

if ([string]::IsNullOrEmpty($StartDateArg) -or [string]::IsNullOrEmpty($StartNumArg)) {
    Write-Error "Usage: ./new_post_commands.ps1 <start yyyymmdd> <start number> [end yyyymmdd] [rec_date yyyymmdd]"
    exit 1
}

if ($StartDateArg -notmatch '^\d{8}$') {
    Write-Error "First argument must be in yyyymmdd format (8 digits): $StartDateArg"
    exit 1
}

if ($StartNumArg -notmatch '^\d+$') {
    Write-Error "Second argument must be an integer: $StartNumArg"
    exit 1
}

$today = Get-Date

if ([string]::IsNullOrEmpty($EndDateArg)) {
    $EndDateArg = $today.ToString('yyyyMMdd')
}
elseif ($EndDateArg -notmatch '^\d{8}$') {
    Write-Error "Third argument must be in yyyymmdd format (8 digits): $EndDateArg"
    exit 1
}

if ([string]::IsNullOrEmpty($RecDateArg)) {
    $RecDateArg = $today.ToString('yyyyMMdd')
}
elseif ($RecDateArg -notmatch '^\d{8}$') {
    Write-Error "Fourth argument must be in yyyymmdd format (8 digits): $RecDateArg"
    exit 1
}

try {
    $startDate = [datetime]::ParseExact($StartDateArg, 'yyyyMMdd', $null)
}
catch {
    Write-Error "First argument is not a valid date: $StartDateArg"
    exit 1
}

try {
    $endDate = [datetime]::ParseExact($EndDateArg, 'yyyyMMdd', $null)
}
catch {
    Write-Error "Third argument is not a valid date: $EndDateArg"
    exit 1
}

try {
    [void][datetime]::ParseExact($RecDateArg, 'yyyyMMdd', $null)
}
catch {
    Write-Error "Fourth argument is not a valid date: $RecDateArg"
    exit 1
}

if ($startDate -gt $endDate) {
    Write-Error "Start date must not be after end date: $StartDateArg > $EndDateArg"
    exit 1
}

# --- Print one command per date ---

$num = [int]$StartNumArg
$date = $startDate
while ($date -le $endDate) {
    $dateArg = $date.ToString('yyyyMMdd')
    Write-Output "./new_post.ps1 $dateArg $num $RecDateArg -Title `"`" -Description `"`""
    $num++
    $date = $date.AddDays(1)
}
