[CmdletBinding()]
param(
    [string]$LogPath = ".copilot-tracking/workitems/import-ado-log.csv",
    [string]$AssessmentPath = "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md",
    [string]$CsvPath = "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-ADO-WorkItems.csv",
    [string]$Organization = "https://dev.azure.com/hve-test",
    [string]$Project = "hve-resiliency",
    [string]$ParentType = "Epic",
    [int]$ExistingParentId = 114
)

$ErrorActionPreference = 'Stop'

# Reuse the skill's helper functions by dot-sourcing? Easier: duplicate the small bits we need.
function Get-PriorityCounts {
    param([object[]]$Rows)
    $counts = [ordered]@{ P0 = 0; P1 = 0; P2 = 0; P3 = 0 }
    foreach ($r in $Rows) {
        if ($r.Title -match '^(P[0-3])-') {
            $counts[$Matches[1]] = $counts[$Matches[1]] + 1
        }
    }
    return $counts
}

function Get-AssessmentOverview {
    param([string]$Path)
    $content = Get-Content -LiteralPath $Path -Raw
    $appName = $null
    $boldMatch = [regex]::Match($content, '(?m)^\*\*(.+?)\*\*\s*$')
    if ($boldMatch.Success) { $appName = $boldMatch.Groups[1].Value.Trim() }
    $overviewMatch = [regex]::Match($content, '(?ms)^#\s+1\.\s+Assessment Overview\s*\n+(.+?)(?=\n\s*\n)')
    $overviewParagraph = if ($overviewMatch.Success) { $overviewMatch.Groups[1].Value.Trim() } else { $null }
    $themesMatch = [regex]::Match($content, '(?ms)^##\s+Assessment Themes\s*\n+(.+?)(?=\n##\s+)')
    $themesBlock = if ($themesMatch.Success) { $themesMatch.Groups[1].Value.Trim() } else { $null }
    return [PSCustomObject]@{ AppName = $appName; Overview = $overviewParagraph; Themes = $themesBlock }
}

function ConvertTo-Html {
    param([string]$Markdown)
    if (-not $Markdown) { return '' }
    $lines = $Markdown -split "`r?`n"
    $sb = [System.Text.StringBuilder]::new()
    $inList = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*-\s+(.*)$' -or $line -match '^\s*\d+\.\s+(.*)$') {
            if (-not $inList) { [void]$sb.AppendLine('<ul>'); $inList = $true }
            [void]$sb.AppendLine(('<li>{0}</li>' -f $Matches[1]))
        }
        elseif ([string]::IsNullOrWhiteSpace($line)) {
            if ($inList) { [void]$sb.AppendLine('</ul>'); $inList = $false }
        }
        else {
            if ($inList) { [void]$sb.AppendLine('</ul>'); $inList = $false }
            [void]$sb.AppendLine(('<p>{0}</p>' -f $line))
        }
    }
    if ($inList) { [void]$sb.AppendLine('</ul>') }
    return $sb.ToString()
}

$rows = Import-Csv -LiteralPath $CsvPath
$total = $rows.Count
$counts = Get-PriorityCounts -Rows $rows
$overview = Get-AssessmentOverview -Path $AssessmentPath
$parentTitle = ('Resiliency Assessment: {0} ({1} findings)' -f $overview.AppName, $total)

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('<h3>Application Overview</h3>')
[void]$sb.AppendLine((ConvertTo-Html $overview.Overview))
[void]$sb.AppendLine('<h3>Findings Summary</h3>')
[void]$sb.AppendLine('<ul>')
[void]$sb.AppendLine(('<li><b>Total findings:</b> {0}</li>' -f $total))
[void]$sb.AppendLine(('<li><b>P0 (Critical):</b> {0}</li>' -f $counts['P0']))
[void]$sb.AppendLine(('<li><b>P1 (High):</b> {0}</li>' -f $counts['P1']))
[void]$sb.AppendLine(('<li><b>P2 (Improvement):</b> {0}</li>' -f $counts['P2']))
[void]$sb.AppendLine(('<li><b>P3 (Code Consistency):</b> {0}</li>' -f $counts['P3']))
[void]$sb.AppendLine('</ul>')
[void]$sb.AppendLine('<h3>Assessment Themes</h3>')
[void]$sb.AppendLine((ConvertTo-Html $overview.Themes))
$parentDescription = $sb.ToString()

$token = az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query accessToken -o tsv
if (-not $token) { throw "Failed to acquire ADO access token" }

$orgTrimmed = $Organization.TrimEnd('/')
$projectEncoded = [System.Uri]::EscapeDataString($Project)
$headers = @{ Authorization = ('Bearer {0}' -f $token) }

# 1. Create parent OR reuse existing
if ($ExistingParentId) {
    $lookupUri = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $ExistingParentId
    $parentResp = Invoke-RestMethod -Uri $lookupUri -Method Get -Headers $headers
    $parentId = $parentResp.id
    $parentUrl = $parentResp.url
    Write-Host ('Reusing existing parent {0} id={1}' -f $ParentType, $parentId)
}
else {
    $parentPatch = @(
        @{ op = 'add'; path = '/fields/System.Title'; value = $parentTitle },
        @{ op = 'add'; path = '/fields/System.Description'; value = $parentDescription },
        @{ op = 'add'; path = '/fields/System.Tags'; value = 'resiliency-assessment' }
    )
    $parentBody = $parentPatch | ConvertTo-Json -Depth 10 -Compress -AsArray
    $parentTypeEncoded = [System.Uri]::EscapeDataString($ParentType)
    $parentUri = '{0}/{1}/_apis/wit/workitems/${2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $parentTypeEncoded
    $parentResp = Invoke-RestMethod -Uri $parentUri -Method Post -Headers $headers -ContentType 'application/json-patch+json' -Body $parentBody
    $parentId = $parentResp.id
    $parentUrl = $parentResp.url
    Write-Host ('Created parent {0} id={1}: {2}' -f $ParentType, $parentId, $parentTitle)
}

# 2. Link existing children
$log = Import-Csv -LiteralPath $LogPath
$childIds = $log | Where-Object { $_.Status -eq 'OK' -and $_.Id } | ForEach-Object { [int]$_.Id }
Write-Host ('Linking {0} existing children to parent {1}...' -f $childIds.Count, $parentId)

$linked = 0
$linkFailed = 0
$failures = [System.Collections.Generic.List[object]]::new()

foreach ($cid in $childIds) {
    $linkPatch = @(
        @{
            op    = 'add'
            path  = '/relations/-'
            value = @{ rel = 'System.LinkTypes.Hierarchy-Reverse'; url = $parentUrl }
        }
    )
    $linkBody = $linkPatch | ConvertTo-Json -Depth 10 -Compress -AsArray
    $linkUri = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $cid
    try {
        $null = Invoke-RestMethod -Uri $linkUri -Method Patch -Headers $headers -ContentType 'application/json-patch+json' -Body $linkBody
        $linked++
    }
    catch {
        $linkFailed++
        $failures.Add([PSCustomObject]@{ Id = $cid; Error = $_.Exception.Message })
        Write-Host ('FAIL link id={0}: {1}' -f $cid, $_.Exception.Message)
    }
    if (($linked + $linkFailed) % 20 -eq 0) {
        Write-Host ('Progress: {0}/{1} (linked {2}, failed {3})' -f ($linked + $linkFailed), $childIds.Count, $linked, $linkFailed)
    }
}

Write-Host ''
Write-Host ('Parent {0} id={1}' -f $ParentType, $parentId)
Write-Host ('Linked: {0} | Failed: {1} | Total children: {2}' -f $linked, $linkFailed, $childIds.Count)
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host ('  - id={0}: {1}' -f $_.Id, $_.Error) }
}
