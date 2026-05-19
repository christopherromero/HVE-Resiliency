[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AssessmentPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('ADO', 'Jira')]
    [string]$TargetTool,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-CleanText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ''
    }

    $value = $Text -replace '\r?\n', ' '
    $value = $value -replace '\s{2,}', ' '
    return $value.Trim()
}

function ConvertTo-NormalizedText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ''
    }

    # Preserve line breaks; only collapse horizontal whitespace within each line
    $normalized = $Text -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = $normalized -split "`n"
    $cleaned = foreach ($line in $lines) { ($line -replace '[ \t]+', ' ').TrimEnd() }
    # Collapse runs of blank lines into a single blank line
    $collapsed = New-Object System.Collections.Generic.List[string]
    $prevBlank = $false
    foreach ($line in $cleaned) {
        $isBlank = [string]::IsNullOrWhiteSpace($line)
        if ($isBlank -and $prevBlank) { continue }
        [void]$collapsed.Add($line)
        $prevBlank = $isBlank
    }
    return (($collapsed -join "`n").Trim())
}

function Get-FieldValue {
    param(
        [string]$Block,
        [string]$FieldName
    )

    $escapedField = [Regex]::Escape($FieldName)
    $pattern = "(?ms)\*\*" + $escapedField + ":\*\*\s*(.*?)(?=\r?\n\*\*[A-Za-z][^\r\n]*:\*\*|\r?\n####\s+P[0-3]-\d{3}:|\z)"
    $fieldResult = [Regex]::Match($Block, $pattern)
    if (-not $fieldResult.Success) {
        return ''
    }

    return ConvertTo-NormalizedText -Text $fieldResult.Groups[1].Value
}

function Get-AdoPriority {
    param([string]$PriorityTag)

    switch -Regex ($PriorityTag) {
        '^P0' { return '1' }
        '^P1' { return '2' }
        '^P2' { return '3' }
        '^P3' { return '4' }
        default { return '3' }
    }
}

function Get-AdoSeverity {
    param([string]$PriorityTag)

    switch -Regex ($PriorityTag) {
        '^P0' { return '1 - Critical' }
        '^P1' { return '2 - High' }
        '^P2' { return '3 - Medium' }
        '^P3' { return '4 - Low' }
        default { return '3 - Medium' }
    }
}

function Get-JiraPriority {
    param([string]$PriorityTag)

    switch -Regex ($PriorityTag) {
        '^P0' { return 'Highest' }
        '^P1' { return 'High' }
        '^P2' { return 'Medium' }
        '^P3' { return 'Low' }
        default { return 'Medium' }
    }
}

function Get-WorkItemType {
    param([string]$PriorityTag)

    switch -Regex ($PriorityTag) {
        '^P0|^P1' { return 'Bug' }
        default { return 'Task' }
    }
}

if (-not (Test-Path -LiteralPath $AssessmentPath)) {
    throw ('Assessment file not found: {0}' -f $AssessmentPath)
}

$assessmentFullPath = (Resolve-Path -LiteralPath $AssessmentPath).Path
$assessmentDirectory = Split-Path -Path $assessmentFullPath -Parent
$assessmentBaseName = [IO.Path]::GetFileNameWithoutExtension($assessmentFullPath)

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $suffix = if ($TargetTool -eq 'ADO') { 'ADO' } else { 'Jira' }
    $OutputPath = Join-Path -Path $assessmentDirectory -ChildPath ('{0}-{1}-WorkItems.csv' -f $assessmentBaseName, $suffix)
}

$content = Get-Content -LiteralPath $assessmentFullPath -Raw -Encoding utf8
$blockPattern = '(?ms)^####\s+(P[0-3]-\d{3}):\s*(.+?)\r?\n(.*?)(?=^####\s+P[0-3]-\d{3}:|\z)'
$findingBlocks = [Regex]::Matches($content, $blockPattern)

if ($findingBlocks.Count -eq 0) {
    throw 'No findings matched the expected header format: #### Pn-###: Title'
}

$rows = New-Object System.Collections.Generic.List[object]

foreach ($findingBlock in $findingBlocks) {
    $findingId = ConvertTo-CleanText -Text $findingBlock.Groups[1].Value
    $findingTitle = ConvertTo-CleanText -Text $findingBlock.Groups[2].Value
    $block = $findingBlock.Groups[3].Value

    $priorityLine = Get-FieldValue -Block $block -FieldName 'Priority'
    if ([string]::IsNullOrWhiteSpace($priorityLine)) {
        $priorityLine = $findingId.Split('-')[0]
    }

    $resiliencyRelated = Get-FieldValue -Block $block -FieldName 'Resiliency Related'
    $issue = Get-FieldValue -Block $block -FieldName 'Issue'
    $recommendedFix = Get-FieldValue -Block $block -FieldName 'Recommended Fix'
    $fileRef = Get-FieldValue -Block $block -FieldName 'File'

    $summary = '{0}: {1}' -f $findingId, $findingTitle
    $description = ConvertTo-NormalizedText -Text @"
Finding: $summary

Priority: $priorityLine

Resiliency Related: $resiliencyRelated

Issue: $issue

File: $fileRef

Recommended Fix: $recommendedFix
"@

    if ($TargetTool -eq 'ADO') {
        $rows.Add([PSCustomObject]@{
            Title = $summary
            'Work Item Type' = (Get-WorkItemType -PriorityTag $findingId)
            Priority = (Get-AdoPriority -PriorityTag $findingId)
            Severity = (Get-AdoSeverity -PriorityTag $findingId)
            State = 'New'
            Description = $description
            'Acceptance Criteria' = $recommendedFix
            Tags = ('resiliency;{0}' -f $findingId)
        })
    }
    else {
        $rows.Add([PSCustomObject]@{
            Summary = $summary
            'Issue Type' = (Get-WorkItemType -PriorityTag $findingId)
            Priority = (Get-JiraPriority -PriorityTag $findingId)
            Description = $description
            Labels = ('resiliency,{0}' -f $findingId)
            Components = 'Resiliency'
        })
    }
}

$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

Write-Host "Export complete."
Write-Host ('Target tool: {0}' -f $TargetTool)
Write-Host ('Findings exported: {0}' -f $rows.Count)
Write-Host ('Output file: {0}' -f $OutputPath)
