<#
.SYNOPSIS
    Create a new post file under _posts.

.PARAMETER DateArg
    Date in yyyymmdd format, 8 digits (first argument)

.PARAMETER NumArg
    Post number as an integer, any number of digits (second argument)

.PARAMETER RecDateArg
    Recording date in yyyy-mm-dd format (third argument, optional).
    Defaults to today's date if not specified.

.EXAMPLE
    ./new_post.ps1 20260706 350
    -> creates ./_posts/2026-07-06-350.md with today's date as rec_date

.EXAMPLE
    ./new_post.ps1 20260706 350 2026-07-04
    -> creates ./_posts/2026-07-06-350.md with rec_date: 2026-07-04
#>

param(
    [string]$DateArg,
    [string]$NumArg,
    [string]$RecDateArg
)

$ErrorActionPreference = 'Stop'

# --- Argument validation ---

if ([string]::IsNullOrEmpty($DateArg) -or [string]::IsNullOrEmpty($NumArg)) {
    Write-Error "Usage: ./new_post.ps1 <yyyymmdd> <xxx> [yyyy-mm-dd]"
    exit 1
}

if ($DateArg -notmatch '^\d{8}$') {
    Write-Error "First argument must be in yyyymmdd format (8 digits): $DateArg"
    exit 1
}

if ($NumArg -notmatch '^\d+$') {
    Write-Error "Second argument must be an integer: $NumArg"
    exit 1
}

if ([string]::IsNullOrEmpty($RecDateArg)) {
    $RecDateArg = Get-Date -Format 'yyyy-MM-dd'
}
elseif ($RecDateArg -notmatch '^\d{4}-\d{2}-\d{2}$') {
    Write-Error "Third argument must be in yyyy-mm-dd format: $RecDateArg"
    exit 1
}

$yyyy = $DateArg.Substring(0, 4)
$mm   = $DateArg.Substring(4, 2)
$dd   = $DateArg.Substring(6, 2)

# --- Path setup ---

$scriptRoot   = $PSScriptRoot
$templatePath = Join-Path $scriptRoot 'yyyy-mm-dd-xxx.md'
$destDir      = Join-Path $scriptRoot '_posts'
$destPath     = Join-Path $destDir "$yyyy-$mm-$dd-$NumArg.md"
$audioDir     = Join-Path $scriptRoot '..\audio'
$audioPath    = Join-Path $audioDir "aozorafm_${DateArg}_01.mp3"

if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    Write-Error "Template file not found: $templatePath"
    exit 1
}

if (Test-Path -LiteralPath $destPath) {
    Write-Error "A file with the same name already exists: $destPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $audioPath -PathType Leaf)) {
    Write-Error "Audio file not found: $audioPath"
    exit 1
}

# --- Read audio file size and duration ---

$audioPath = (Resolve-Path -LiteralPath $audioPath).Path
$audioBytes = (Get-Item -LiteralPath $audioPath).Length
$audioFileSize = [Math]::Floor($audioBytes / 1024) * 1000

$shell = New-Object -ComObject Shell.Application
$audioFolder = $shell.Namespace((Split-Path $audioPath -Parent))
$audioItem = $audioFolder.ParseName((Split-Path $audioPath -Leaf))
$lengthStr = $audioFolder.GetDetailsOf($audioItem, 27)

$timeParts = $lengthStr -split ':'
$ss = [int]$timeParts[$timeParts.Count - 1]
$mi = [int]$timeParts[$timeParts.Count - 2]
$hh2 = if ($timeParts.Count -ge 3) { [int]$timeParts[$timeParts.Count - 3] } else { 0 }

if ($hh2 -gt 0) {
    $duration = "{0:D2}:{1:D2}:{2:D2}" -f $hh2, $mi, $ss
}
else {
    $duration = "{0:D2}:{1:D2}" -f $mi, $ss
}

# --- Copy ---

Copy-Item -LiteralPath $templatePath -Destination $destPath

# --- Replace placeholders ---
# Read/write raw bytes directly to preserve the template's line endings (LF)
# and encoding (UTF-8, no BOM).

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($destPath, $utf8NoBom)

$content = $content -replace '(?m)(^audio_file_path:.*)yyyymmdd', ('${1}' + $DateArg)
$content = $content -replace '(?m)(^audio_file_size:\s*)$', ('${1}' + $audioFileSize)
$content = $content -replace '(?m)(^date:\s*)yyyy-mm-dd', ('${1}' + "$yyyy-$mm-$dd")
$content = $content -replace '(?m)^rec_date:.*$', ('rec_date: ' + $RecDateArg)
$content = $content -replace '(?m)^duration:.*$', ('duration: "' + $duration + '"')
$content = $content -replace '(?m)(^title:.*?)xxx', ('${1}' + $NumArg)

[System.IO.File]::WriteAllText($destPath, $content, $utf8NoBom)

Write-Output "Created: $destPath"
