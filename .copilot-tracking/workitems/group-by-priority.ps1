[CmdletBinding()]
param(
    [string]$LogPath = ".copilot-tracking/workitems/import-ado-log.csv",
    [string]$Organization = "https://dev.azure.com/hve-test",
    [string]$Project = "hve-resiliency",
    [int]$EpicId = 114,
    [string]$GroupType = "Issue"
)

$ErrorActionPreference = 'Stop'

$orgTrimmed = $Organization.TrimEnd('/')
$projectEncoded = [System.Uri]::EscapeDataString($Project)
$groupTypeEncoded = [System.Uri]::EscapeDataString($GroupType)

$token = az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query accessToken -o tsv
if (-not $token) { throw 'Failed to obtain ADO access token.' }
$headers = @{ Authorization = "Bearer $token" }

# 1. Load log and classify by priority from title
$log = Import-Csv -LiteralPath $LogPath
$priorityNames = [ordered]@{
    P0 = 'Critical'
    P1 = 'High'
    P2 = 'Medium'
    P3 = 'Low'
}
$byPriority = [ordered]@{ P0 = @(); P1 = @(); P2 = @(); P3 = @() }
foreach ($row in $log) {
    if ($row.Status -ne 'OK') { continue }
    if ($row.Title -match '^(P[0-3])-') {
        $byPriority[$Matches[1]] += [int]$row.Id
    }
}

# 2. Get Epic url (parent for the priority groups)
$epicLookup = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $EpicId
$epic = Invoke-RestMethod -Uri $epicLookup -Method Get -Headers $headers
$epicUrl = $epic.url
Write-Host ('Epic {0}: {1}' -f $EpicId, $epic.fields.'System.Title')

# 3. Create one priority parent per non-empty bucket
$priorityParents = [ordered]@{}
foreach ($p in $priorityNames.Keys) {
    $ids = $byPriority[$p]
    if (-not $ids -or $ids.Count -eq 0) { continue }
    $label = $priorityNames[$p]
    $title = '{0} - {1} Priority Findings ({2})' -f $p, $label, $ids.Count
    $desc = '<p>Grouping of all <strong>{0}</strong> ({1}) priority resiliency findings from this assessment. Total: <strong>{2}</strong>.</p>' -f $p, $label, $ids.Count
    $patch = @(
        @{ op = 'add'; path = '/fields/System.Title'; value = $title },
        @{ op = 'add'; path = '/fields/System.Description'; value = $desc },
        @{ op = 'add'; path = '/fields/System.Tags'; value = ('resiliency-assessment; {0}' -f $p) },
        @{ op = 'add'; path = '/relations/-'; value = @{ rel = 'System.LinkTypes.Hierarchy-Reverse'; url = $epicUrl } }
    )
    $body = $patch | ConvertTo-Json -Depth 10 -Compress -AsArray
    $uri = '{0}/{1}/_apis/wit/workitems/${2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $groupTypeEncoded
    $resp = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType 'application/json-patch+json' -Body $body
    $priorityParents[$p] = [PSCustomObject]@{ Id = $resp.id; Url = $resp.url; Title = $title }
    Write-Host ('Created {0} parent id={1}: {2}' -f $p, $resp.id, $title)
}

# 4. Re-parent each finding: remove existing Hierarchy-Reverse, add new one to priority parent
$linked = 0
$failed = 0
$failures = @()
$totalChildren = ($byPriority.Values | ForEach-Object { $_ } | Measure-Object).Count
Write-Host ('Re-parenting {0} findings...' -f $totalChildren)
$i = 0
foreach ($p in $byPriority.Keys) {
    $parent = $priorityParents[$p]
    if (-not $parent) { continue }
    foreach ($cid in $byPriority[$p]) {
        $i++
        try {
            $childUri = '{0}/{1}/_apis/wit/workitems/{2}?$expand=relations&api-version=7.0' -f $orgTrimmed, $projectEncoded, $cid
            $child = Invoke-RestMethod -Uri $childUri -Method Get -Headers $headers
            $ops = @()
            if ($child.relations) {
                for ($idx = $child.relations.Count - 1; $idx -ge 0; $idx--) {
                    if ($child.relations[$idx].rel -eq 'System.LinkTypes.Hierarchy-Reverse') {
                        $ops += @{ op = 'remove'; path = ('/relations/{0}' -f $idx) }
                    }
                }
            }
            $ops += @{ op = 'add'; path = '/relations/-'; value = @{ rel = 'System.LinkTypes.Hierarchy-Reverse'; url = $parent.Url } }
            $patchUri = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $cid
            $body = $ops | ConvertTo-Json -Depth 10 -Compress -AsArray
            $null = Invoke-RestMethod -Uri $patchUri -Method Patch -Headers $headers -ContentType 'application/json-patch+json' -Body $body
            $linked++
        }
        catch {
            $failed++
            $msg = $_.Exception.Message
            if ($_.ErrorDetails.Message) { $msg = $_.ErrorDetails.Message }
            $failures += [PSCustomObject]@{ Id = $cid; Priority = $p; Error = $msg }
            Write-Host ('FAIL re-parent id={0}: {1}' -f $cid, $msg) -ForegroundColor Yellow
        }
        if ($i % 20 -eq 0) {
            Write-Host ('Progress: {0}/{1} (linked {2}, failed {3})' -f $i, $totalChildren, $linked, $failed)
        }
    }
}

Write-Host ''
Write-Host 'Priority parents:'
foreach ($p in $priorityParents.Keys) {
    Write-Host ('  {0} -> id={1}' -f $p, $priorityParents[$p].Id)
}
Write-Host ('Re-parented: {0} | Failed: {1} | Total: {2}' -f $linked, $failed, $totalChildren)
if ($failures.Count -gt 0) {
    Write-Host 'Failures:'
    $failures | ForEach-Object { Write-Host ('  - id={0} ({1}): {2}' -f $_.Id, $_.Priority, $_.Error) }
}
