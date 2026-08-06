<#
.SYNOPSIS
    Verifies an evidence ledger against the workspace, and optionally verifies a report against the ledger.

.DESCRIPTION
    Deterministic citation checker for multi-phase workflows. Performs no interpretation:
    it compares recorded bytes to actual bytes and reports every mismatch.

    Checks per ledger entry:
      present  - file exists, range in bounds, range width equals snippet span, snippet matches file bytes
      absent   - no line range, no snippet, search block present, and the query still returns nothing
      external - no line range, owner recorded
      remote   - no line range, url and retrievedAt recorded

    With -ReportPath, also confirms every evidence-marked fenced block in the report
    matches its ledger entry exactly.

.PARAMETER LedgerPath
    Path to the evidence ledger JSON file.

.PARAMETER WorkspaceRoot
    Root the ledger paths resolve against. Defaults to the current directory.

.PARAMETER ReportPath
    Optional markdown report to verify against the ledger.

.PARAMETER Quiet
    Suppress per-entry pass output.

.EXAMPLE
    ./Test-EvidenceLedger.ps1 -LedgerPath .copilot-tracking/research/evidence.json

.EXAMPLE
    ./Test-EvidenceLedger.ps1 -LedgerPath evidence.json -ReportPath ".github/Assessment.md"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$LedgerPath,
    [string]$WorkspaceRoot = (Get-Location).Path,
    [string]$ReportPath,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$failures = New-Object System.Collections.ArrayList
$passCount = 0

function Add-Failure {
    param([string]$Id, [string]$Message)
    [void]$failures.Add([pscustomobject]@{ Id = $Id; Message = $Message })
}

function Get-NormalizedLines {
    param([string]$Text)
    $normalized = $Text -replace "`r`n", "`n" -replace "`r", "`n"
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    return , ($normalized -split "`n", -1)
}

if (-not (Test-Path -LiteralPath $LedgerPath)) {
    Write-Error "Ledger not found: $LedgerPath"
    exit 2
}

$ledger = Get-Content -Raw -LiteralPath $LedgerPath | ConvertFrom-Json

if ($ledger.source.type -eq 'git' -and [string]::IsNullOrWhiteSpace($ledger.source.commit)) {
    Add-Failure -Id '(ledger)' -Message 'source.type is git but source.commit is not recorded. Observations are not pinned to a known state.'
}

if ($ledger.source.type -eq 'git' -and $ledger.source.commit) {
    $head = (& git -C $WorkspaceRoot rev-parse HEAD 2>$null)
    if ($LASTEXITCODE -eq 0 -and $head -and -not $head.StartsWith($ledger.source.commit)) {
        Write-Warning "Ledger pinned to $($ledger.source.commit) but HEAD is $head. Line numbers may have drifted."
    }
}

$seenIds = @{}
$entryMap = @{}

foreach ($entry in $ledger.entries) {
    $id = $entry.id
    if (-not $id) { Add-Failure -Id '(unknown)' -Message 'Entry has no id.'; continue }
    if ($seenIds.ContainsKey($id)) { Add-Failure -Id $id -Message 'Duplicate entry id.'; continue }
    $seenIds[$id] = $true
    $entryMap[$id] = $entry

    $hasRange = ($null -ne $entry.startLine) -or ($null -ne $entry.endLine)

    switch ($entry.kind) {

        'present' {
            if (-not $entry.path) { Add-Failure -Id $id -Message 'kind=present requires path.'; break }
            if (-not $hasRange) { Add-Failure -Id $id -Message 'kind=present requires startLine and endLine.'; break }
            if ($null -eq $entry.snippet) { Add-Failure -Id $id -Message 'kind=present requires snippet.'; break }

            $full = Join-Path $WorkspaceRoot $entry.path
            if (-not (Test-Path -LiteralPath $full)) { Add-Failure -Id $id -Message "File not found: $($entry.path)"; break }

            $fileLines = Get-NormalizedLines ([System.IO.File]::ReadAllText($full))
            $snipLines = Get-NormalizedLines $entry.snippet

            if ($entry.startLine -lt 1 -or $entry.endLine -lt $entry.startLine) {
                Add-Failure -Id $id -Message "Invalid range $($entry.startLine)-$($entry.endLine)."; break
            }
            if ($entry.endLine -gt $fileLines.Count) {
                Add-Failure -Id $id -Message "Range ends at line $($entry.endLine) but $($entry.path) has $($fileLines.Count) lines."; break
            }

            $rangeWidth = $entry.endLine - $entry.startLine + 1
            if ($rangeWidth -ne $snipLines.Count) {
                Add-Failure -Id $id -Message "Citation range is $rangeWidth lines but the snippet is $($snipLines.Count) lines. A range wider than the quotation is unfalsifiable."
                break
            }

            $redacted = @{}
            if ($entry.redactions) { foreach ($r in $entry.redactions) { $redacted[[int]$r.offset] = $r.placeholder } }

            $mismatch = $null
            for ($i = 0; $i -lt $snipLines.Count; $i++) {
                $actual = $fileLines[$entry.startLine - 1 + $i]
                if ($redacted.ContainsKey($i)) {
                    if ($snipLines[$i] -notlike "*$($redacted[$i])*") {
                        $mismatch = "line offset $i is marked redacted but the snippet does not contain the placeholder."
                        break
                    }
                    continue
                }
                if ($snipLines[$i] -cne $actual) {
                    $mismatch = "line $($entry.startLine + $i) differs.`n      ledger: $($snipLines[$i])`n      file:   $actual"
                    break
                }
            }
            if ($mismatch) { Add-Failure -Id $id -Message $mismatch; break }
            $passCount++
        }

        'absent' {
            if ($hasRange) { Add-Failure -Id $id -Message 'kind=absent must not carry a line range. Absence has no location.'; break }
            if ($entry.snippet) { Add-Failure -Id $id -Message 'kind=absent must not carry a snippet.'; break }
            if (-not $entry.search -or -not $entry.search.query) { Add-Failure -Id $id -Message 'kind=absent requires a search block recording the query and its null result.'; break }

            $scope = if ($entry.search.scope) { Join-Path $WorkspaceRoot $entry.search.scope } else { $WorkspaceRoot }
            if (-not (Test-Path -LiteralPath $scope)) {
                Add-Failure -Id $id -Message "Search scope does not exist: $($entry.search.scope). The absence claim cannot be reproduced."
                break
            }
            if (Test-Path -LiteralPath $scope -PathType Container) {
                $targets = Get-ChildItem -LiteralPath $scope -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
            }
            else {
                $targets = @($scope)
            }
            if ($targets) {
                $hits = @(Select-String -Path $targets -Pattern $entry.search.query -SimpleMatch -List -ErrorAction SilentlyContinue)
                if ($hits.Count -gt 0) {
                    Add-Failure -Id $id -Message "Absence claim is false. '$($entry.search.query)' matches in $($hits[0].Path):$($hits[0].LineNumber)."
                    break
                }
            }
            $passCount++
        }

        'external' {
            if ($hasRange) { Add-Failure -Id $id -Message 'kind=external must not carry a line range. The artifact is not in this workspace.'; break }
            if (-not $entry.owner) { Add-Failure -Id $id -Message 'kind=external requires owner.'; break }
            $passCount++
        }

        'remote' {
            if ($hasRange) { Add-Failure -Id $id -Message 'kind=remote must not carry a line range.'; break }
            if (-not $entry.url -or -not $entry.retrievedAt) { Add-Failure -Id $id -Message 'kind=remote requires url and retrievedAt.'; break }
            $passCount++
        }

        default { Add-Failure -Id $id -Message "Unknown kind '$($entry.kind)'." }
    }
}

if ($ReportPath) {
    if (-not (Test-Path -LiteralPath $ReportPath)) {
        Add-Failure -Id '(report)' -Message "Report not found: $ReportPath"
    }
    else {
        $reportLines = Get-NormalizedLines ([System.IO.File]::ReadAllText($ReportPath))
        for ($i = 0; $i -lt $reportLines.Count; $i++) {
            if ($reportLines[$i] -match '^\s*<!--\s*evidence:\s*(EV-\d{3,})\s*-->\s*$') {
                $refId = $Matches[1]
                $j = $i + 1
                while ($j -lt $reportLines.Count -and $reportLines[$j].Trim() -eq '') { $j++ }
                if ($j -ge $reportLines.Count -or $reportLines[$j] -notmatch '^\s*```') {
                    Add-Failure -Id $refId -Message "Report line $($i + 1): evidence marker is not followed by a fenced block."
                    continue
                }
                $blockStart = $j + 1
                $k = $blockStart
                while ($k -lt $reportLines.Count -and $reportLines[$k] -notmatch '^\s*```\s*$') { $k++ }
                $block = ($reportLines[$blockStart..($k - 1)]) -join "`n"

                if (-not $entryMap.ContainsKey($refId)) {
                    Add-Failure -Id $refId -Message "Report line $($i + 1) references an entry that does not exist in the ledger."
                    continue
                }
                $expected = (Get-NormalizedLines $entryMap[$refId].snippet) -join "`n"
                if ($block -cne $expected) {
                    Add-Failure -Id $refId -Message "Report line $($blockStart + 1): quoted block does not match the ledger entry. The report re-authored the quotation."
                    continue
                }
                $passCount++
            }
        }
    }
}

if (-not $Quiet) { Write-Host "Checks passed: $passCount" -ForegroundColor Green }

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Evidence verification FAILED ($($failures.Count) issue(s)):" -ForegroundColor Red
    foreach ($f in $failures) { Write-Host "  [$($f.Id)] $($f.Message)" -ForegroundColor Red }
    exit 1
}

Write-Host "Evidence verification passed." -ForegroundColor Green
exit 0
