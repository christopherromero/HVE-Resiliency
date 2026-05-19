[CmdletBinding()]
param(
    [string]$CsvPath = "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-ADO-WorkItems.csv",
    [string]$LogPath = ".copilot-tracking/workitems/import-ado-log.csv",
    [string]$Organization = "https://dev.azure.com/hve-test",
    [string]$Project = "hve-resiliency"
)

$ErrorActionPreference = 'Continue'

$rows = Import-Csv -LiteralPath $CsvPath
$logRows = Import-Csv -LiteralPath $LogPath
$failedIndices = $logRows | Where-Object { $_.Status -eq 'FAIL' } | ForEach-Object { [int]$_.Index }

Write-Host ("Retrying {0} failed items via REST API..." -f $failedIndices.Count)

# Get access token for ADO
$token = az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query accessToken -o tsv
if (-not $token) { throw "Failed to acquire ADO access token" }

$retryCreated = 0
$retryFailed = 0
$updates = @{}

foreach ($idx in $failedIndices) {
    $row = $rows[$idx - 1]
    $sourceType = $row.'Work Item Type'
    $targetType = if ($sourceType -eq 'Bug') { 'Issue' } else { 'Task' }
    $title = $row.Title
    $priority = $row.Priority
    $description = $row.Description
    $tags = $row.Tags

    $priorityInt = 2
    if ($priority -match '^\d+$') { $priorityInt = [int]$priority }

    $patch = @(
        @{ op = 'add'; path = '/fields/System.Title'; value = $title }
        @{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.Priority'; value = $priorityInt }
        @{ op = 'add'; path = '/fields/System.Description'; value = $description }
        @{ op = 'add'; path = '/fields/System.Tags'; value = $tags }
    )
    $body = $patch | ConvertTo-Json -Depth 10 -Compress

    $uri = "{0}/{1}/_apis/wit/workitems/`${2}?api-version=7.0" -f $Organization, $Project, $targetType

    try {
        $resp = Invoke-RestMethod -Uri $uri -Method Post `
            -Headers @{ Authorization = "Bearer $token" } `
            -ContentType 'application/json-patch+json' `
            -Body $body
        $retryCreated++
        $updates[$idx] = @{ Status = 'OK'; Id = $resp.id }
        Write-Host ("OK {0}: id={1} {2}" -f $idx, $resp.id, $title)
    }
    catch {
        $retryFailed++
        $updates[$idx] = @{ Status = 'FAIL'; Id = $null }
        Write-Host ("FAIL {0}: {1}" -f $idx, $title)
        Write-Host $_.Exception.Message
    }
}

# Rewrite log
$newLog = foreach ($r in $logRows) {
    $i = [int]$r.Index
    if ($updates.ContainsKey($i)) {
        [PSCustomObject]@{
            Index  = $r.Index
            Status = $updates[$i].Status
            Id     = $updates[$i].Id
            Type   = $r.Type
            Title  = $r.Title
        }
    } else { $r }
}
$newLog | Export-Csv -LiteralPath $LogPath -NoTypeInformation -Encoding utf8

Write-Host ""
Write-Host ("Retry complete. Created: {0} | Failed: {1}" -f $retryCreated, $retryFailed)
$okCount = ($newLog | Where-Object { $_.Status -eq 'OK' }).Count
$failCount = ($newLog | Where-Object { $_.Status -eq 'FAIL' }).Count
Write-Host ("Overall: OK={0} FAIL={1} TOTAL={2}" -f $okCount, $failCount, $newLog.Count)
