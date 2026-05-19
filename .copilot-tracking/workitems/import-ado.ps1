[CmdletBinding()]
param(
    [string]$CsvPath = "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-ADO-WorkItems.csv",
    [string]$Organization = "https://dev.azure.com/hve-test",
    [string]$Project = "hve-resiliency"
)

$ErrorActionPreference = 'Continue'

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw ('CSV not found: {0}' -f $CsvPath)
}

$rows = Import-Csv -LiteralPath $CsvPath
$total = $rows.Count
$created = 0
$failed = 0
$log = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $total; $i++) {
    $row = $rows[$i]
    $sourceType = $row.'Work Item Type'
    $targetType = if ($sourceType -eq 'Bug') { 'Issue' } else { 'Task' }

    $title = $row.Title
    $priority = $row.Priority
    $description = $row.Description
    $tags = $row.Tags

    $fieldArgs = @(
        ('Microsoft.VSTS.Common.Priority={0}' -f $priority),
        ('System.Description={0}' -f $description),
        ('System.Tags={0}' -f $tags)
    )

    $result = az boards work-item create `
        --title $title `
        --type $targetType `
        --organization $Organization `
        --project $Project `
        --fields @fieldArgs `
        --only-show-errors `
        --output json 2>&1

    if ($LASTEXITCODE -eq 0) {
        $created++
        try {
            $obj = $result | ConvertFrom-Json
            $log.Add([PSCustomObject]@{ Index = $i + 1; Status = 'OK'; Id = $obj.id; Type = $targetType; Title = $title })
        }
        catch {
            $log.Add([PSCustomObject]@{ Index = $i + 1; Status = 'OK'; Id = $null; Type = $targetType; Title = $title })
        }
    }
    else {
        $failed++
        $log.Add([PSCustomObject]@{ Index = $i + 1; Status = 'FAIL'; Id = $null; Type = $targetType; Title = $title })
        Write-Host ("FAIL {0}: {1}" -f ($i + 1), $title)
        Write-Host $result
    }

    if ((($i + 1) % 10) -eq 0) {
        Write-Host ("Progress: {0}/{1} (created {2}, failed {3})" -f ($i + 1), $total, $created, $failed)
    }
}

$logPath = ".copilot-tracking/workitems/import-ado-log.csv"
$log | Export-Csv -LiteralPath $logPath -NoTypeInformation -Encoding utf8

Write-Host ""
Write-Host ("Import complete. Created: {0} | Failed: {1} | Total: {2}" -f $created, $failed, $total)
Write-Host ("Log: {0}" -f $logPath)
