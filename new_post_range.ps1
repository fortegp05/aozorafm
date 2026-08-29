<#
.SYNOPSIS
    Run new_post.ps1 for every date in a date range.

.PARAMETER StartDateArg
    Start date in yyyymmdd format, 8 digits (first argument, required)

.PARAMETER EndDateArg
    End date in yyyymmdd format, 8 digits (second argument, required)

.PARAMETER RecDateArg
    Recording date in yyyymmdd format, 8 digits (third argument, optional).
    Passed through as-is to every new_post.ps1 call. If omitted, new_post.ps1
    falls back to its own default (today's date).

.DESCRIPTION
    The post number for the start date is determined by looking at the
    post file for the day before the start date (yyyy-mm-dd-nnn.md under
    _posts) and incrementing nnn by 1. The number is then incremented by
    1 for each subsequent day.

.EXAMPLE
    ./new_post_range.ps1 20260816 20260830
    -> runs (rec_date defaults to today's date in each call):
       ./new_post.ps1 20260816 397
       ./new_post.ps1 20260817 398
       ...
       ./new_post.ps1 20260830 411

.EXAMPLE
    ./new_post_range.ps1 20260816 20260830 20260828
    -> runs:
       ./new_post.ps1 20260816 397 20260828
       ./new_post.ps1 20260817 398 20260828
       ...
       ./new_post.ps1 20260830 411 20260828
#>

param(
    [string]$StartDateArg,
    [string]$EndDateArg,
    [string]$RecDateArg
)

$ErrorActionPreference = 'Stop'

# --- Argument validation ---

if ([string]::IsNullOrEmpty($StartDateArg) -or [string]::IsNullOrEmpty($EndDateArg)) {
    Write-Error "Usage: ./new_post_range.ps1 <start yyyymmdd> <end yyyymmdd> [rec_date yyyymmdd]"
    exit 1
}

if ($StartDateArg -notmatch '^\d{8}$') {
    Write-Error "First argument must be in yyyymmdd format (8 digits): $StartDateArg"
    exit 1
}

if ($EndDateArg -notmatch '^\d{8}$') {
    Write-Error "Second argument must be in yyyymmdd format (8 digits): $EndDateArg"
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
    Write-Error "Second argument is not a valid date: $EndDateArg"
    exit 1
}

if ($startDate -gt $endDate) {
    Write-Error "Start date must not be after end date: $StartDateArg > $EndDateArg"
    exit 1
}

if (-not [string]::IsNullOrEmpty($RecDateArg) -and $RecDateArg -notmatch '^\d{8}$') {
    Write-Error "Third argument must be in yyyymmdd format (8 digits): $RecDateArg"
    exit 1
}

# --- Determine the starting post number from the previous day's post file ---

$scriptRoot  = $PSScriptRoot
$postsDir    = Join-Path $scriptRoot '_posts'
$prevDate    = $startDate.AddDays(-1)
$prevDateStr = $prevDate.ToString('yyyy-MM-dd')

$prevFiles = Get-ChildItem -LiteralPath $postsDir -Filter "$prevDateStr-*.md" -File -ErrorAction SilentlyContinue

if (-not $prevFiles -or $prevFiles.Count -eq 0) {
    Write-Error "No post file found for the previous day: $prevDateStr-*.md in $postsDir"
    exit 1
}

if ($prevFiles.Count -gt 1) {
    Write-Error "Multiple post files found for the previous day, cannot determine post number: $($prevFiles.Name -join ', ')"
    exit 1
}

if ($prevFiles[0].BaseName -notmatch '^\d{4}-\d{2}-\d{2}-(\d+)$') {
    Write-Error "Could not parse post number from file name: $($prevFiles[0].Name)"
    exit 1
}

$num = [int]$Matches[1] + 1

# --- Run new_post.ps1 for each date in the range ---

$newPostScript = Join-Path $scriptRoot 'new_post.ps1'

if (-not (Test-Path -LiteralPath $newPostScript -PathType Leaf)) {
    Write-Error "new_post.ps1 not found: $newPostScript"
    exit 1
}

$date = $startDate
while ($date -le $endDate) {
    $dateArg = $date.ToString('yyyyMMdd')

    try {
        $LASTEXITCODE = 0
        if ([string]::IsNullOrEmpty($RecDateArg)) {
            Write-Output "Running: new_post.ps1 $dateArg $num"
            & $newPostScript $dateArg $num
        }
        else {
            Write-Output "Running: new_post.ps1 $dateArg $num $RecDateArg"
            & $newPostScript $dateArg $num $RecDateArg
        }
        if ($LASTEXITCODE -ne 0) {
            throw "exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Error "new_post.ps1 failed for date $dateArg (num $num): $_"
        exit 1
    }

    $num++
    $date = $date.AddDays(1)
}

Write-Output "Done."
