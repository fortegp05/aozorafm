<#
.SYNOPSIS
    Stage all changes, commit with an auto-generated message, and push to gh-pages.

.DESCRIPTION
    Runs `git add .`, then inspects the staged changes to decide the commit message:
      - Only new files staged      -> "add ep"
      - Only modified files staged -> "fix ep"
      - Both new and modified      -> "add and fix ep"
    Deleted/renamed files count as "modified" for this purpose.
    Then commits and pushes to origin/gh-pages.

.EXAMPLE
    ./commit_and_push.ps1
#>

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

git add .

$statusLines = git diff --cached --name-status

if (-not $statusLines) {
    Write-Output "No changes to commit."
    exit 0
}

$hasAdd = $false
$hasFix = $false

foreach ($line in $statusLines) {
    $code = ($line -split "`t")[0]
    if ($code -match '^A') {
        $hasAdd = $true
    }
    elseif ($code -match '^[MDRC]') {
        $hasFix = $true
    }
}

if ($hasAdd -and $hasFix) {
    $message = "add and fix ep"
}
elseif ($hasAdd) {
    $message = "add ep"
}
else {
    $message = "fix ep"
}

git commit -m $message
git push origin gh-pages
