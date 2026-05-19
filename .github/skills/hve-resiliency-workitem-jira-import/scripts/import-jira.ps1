[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [Parameter(Mandatory = $true)]
    [string]$BaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$ProjectKey,

    [string]$Email = $env:JIRA_EMAIL,

    [string]$ApiToken = $env:JIRA_API_TOKEN,

    [string]$LogPath,

    [string]$AssessmentPath,

    [string]$ParentTitle,

    [string]$ParentDescription,

    [string]$ParentType = 'Epic',

    [string]$ParentKey,

    [switch]$NoParent,

    [switch]$GroupByPriority,

    [string]$GroupType = 'Story',

    [string]$ChildType,

    [string]$EpicNameField,

    [switch]$NoAttachment,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw ('CSV not found: {0}' -f $CsvPath)
}

if (-not $DryRun) {
    if (-not $Email) { throw 'Missing -Email or $env:JIRA_EMAIL.' }
    if (-not $ApiToken) { throw 'Missing -ApiToken or $env:JIRA_API_TOKEN. Generate one at https://id.atlassian.com/manage-profile/security/api-tokens.' }
}

if (-not $LogPath) {
    $csvDir = Split-Path -Path $CsvPath -Parent
    $csvBase = [System.IO.Path]::GetFileNameWithoutExtension($CsvPath)
    $LogPath = Join-Path -Path $csvDir -ChildPath ('{0}-jira-import-log.csv' -f $csvBase)
}

$rows = Import-Csv -LiteralPath $CsvPath
$total = $rows.Count
$baseTrimmed = $BaseUrl.TrimEnd('/')

Write-Host ('Loaded {0} rows from {1}' -f $total, $CsvPath)
Write-Host ('Target: {0} / project {1}' -f $baseTrimmed, $ProjectKey)
if ($DryRun) { Write-Host 'DryRun: no issues will be created.' }

# --- Helpers ---------------------------------------------------------------

function Get-PriorityKey {
    param([string]$Summary)
    if ($Summary -match '^\s*\[?(P[0-3])') { return $Matches[1] }
    return $null
}

function Group-RowsByPriority {
    param([object[]]$Rows)
    $buckets = [ordered]@{ P0 = @(); P1 = @(); P2 = @(); P3 = @() }
    foreach ($r in $Rows) {
        $key = Get-PriorityKey -Summary $r.Summary
        if ($key) { $buckets[$key] += , $r }
    }
    return $buckets
}

function Get-PriorityCounts {
    param([object[]]$Rows)
    $counts = [ordered]@{ P0 = 0; P1 = 0; P2 = 0; P3 = 0 }
    foreach ($r in $Rows) {
        $key = Get-PriorityKey -Summary $r.Summary
        if ($key) { $counts[$key] = $counts[$key] + 1 }
    }
    return $counts
}

function Get-AssessmentOverview {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path -LiteralPath $Path)) { return $null }
    $content = Get-Content -LiteralPath $Path -Raw

    $appName = $null
    $titleMatch = [regex]::Match($content, '(?m)^#\s+(.+?)\s*$')
    if ($titleMatch.Success) { $appName = $titleMatch.Groups[1].Value.Trim() }
    $boldMatch = [regex]::Match($content, '(?m)^\*\*(.+?)\*\*\s*$')
    if ($boldMatch.Success) { $appName = $boldMatch.Groups[1].Value.Trim() }

    $overviewParagraph = $null
    $overviewMatch = [regex]::Match($content, '(?ms)^#\s+1\.\s+Assessment Overview\s*\n+(.+?)(?=\n\s*\n)')
    if ($overviewMatch.Success) { $overviewParagraph = $overviewMatch.Groups[1].Value.Trim() }

    $themesBlock = $null
    $themesMatch = [regex]::Match($content, '(?ms)^##\s+Assessment Themes\s*\n+(.+?)(?=\n##\s+)')
    if ($themesMatch.Success) { $themesBlock = $themesMatch.Groups[1].Value.Trim() }

    return [PSCustomObject]@{
        AppName  = $appName
        Overview = $overviewParagraph
        Themes   = $themesBlock
    }
}

# --- ADF builders ---------------------------------------------------------

function New-AdfText {
    param([string]$Text, [object[]]$Marks)
    $node = [ordered]@{ type = 'text'; text = $Text }
    if ($Marks -and $Marks.Count -gt 0) { $node['marks'] = $Marks }
    return $node
}

function New-AdfInlineFromMarkdown {
    param([string]$Text)
    # Tokenize **bold**, `code`, and plain text. Returns an array of inline nodes.
    $nodes = [System.Collections.Generic.List[object]]::new()
    if (-not $Text) { return @() }
    $pattern = '(\*\*[^*]+?\*\*|`[^`]+?`)'
    $parts = [regex]::Split($Text, $pattern)
    foreach ($p in $parts) {
        if (-not $p) { continue }
        if ($p -match '^\*\*(.+?)\*\*$') {
            $nodes.Add((New-AdfText -Text $Matches[1] -Marks @(@{ type = 'strong' })))
        }
        elseif ($p -match '^`(.+?)`$') {
            $nodes.Add((New-AdfText -Text $Matches[1] -Marks @(@{ type = 'code' })))
        }
        else {
            $nodes.Add((New-AdfText -Text $p))
        }
    }
    return $nodes.ToArray()
}

function New-AdfParagraph {
    param([object[]]$Inline)
    if (-not $Inline -or $Inline.Count -eq 0) { return $null }
    return [ordered]@{ type = 'paragraph'; content = $Inline }
}

function New-AdfHeading {
    param([int]$Level, [string]$Text)
    return [ordered]@{
        type    = 'heading'
        attrs   = @{ level = $Level }
        content = @((New-AdfText -Text $Text))
    }
}

function New-AdfCodeBlock {
    param([string]$Text)
    return [ordered]@{
        type    = 'codeBlock'
        attrs   = @{ language = '' }
        content = @((New-AdfText -Text $Text))
    }
}

function New-AdfBulletList {
    param([string[]]$Items)
    $listItems = foreach ($it in $Items) {
        [ordered]@{
            type    = 'listItem'
            content = @((New-AdfParagraph -Inline (New-AdfInlineFromMarkdown -Text $it)))
        }
    }
    return [ordered]@{ type = 'bulletList'; content = $listItems }
}

function ConvertTo-AdfDoc {
    param([object[]]$Content)
    $filtered = $Content | Where-Object { $_ -ne $null }
    return [ordered]@{
        type    = 'doc'
        version = 1
        content = @($filtered)
    }
}

function ConvertTo-FindingAdfContent {
    param([string]$Text)
    # Mirror of ADO importer's ConvertTo-FindingHtml, emitting ADF nodes.
    if (-not $Text) { return @() }
    $normalized = $Text -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = $normalized -split "`n"
    $blocks = [System.Collections.Generic.List[object]]::new()
    $inCode = $false
    $codeLines = [System.Collections.Generic.List[string]]::new()
    $paraLines = [System.Collections.Generic.List[string]]::new()
    $knownKeys = '^(Finding ID|Finding|Resiliency Related|Issue|Evidence|File|Recommended Fix|Priority):\s*'

    $flushPara = {
        if ($paraLines.Count -eq 0) { return }
        $joined = ($paraLines -join ' ').Trim()
        $paraLines.Clear()
        if (-not $joined) { return }
        if ($joined -match '^([A-Z][A-Za-z ]{1,30}):\s*(.*)$') {
            $key = $Matches[1]
            $rest = $Matches[2]
            $inline = [System.Collections.Generic.List[object]]::new()
            $inline.Add((New-AdfText -Text ('{0}: ' -f $key) -Marks @(@{ type = 'strong' })))
            foreach ($n in (New-AdfInlineFromMarkdown -Text $rest)) { $inline.Add($n) }
            $p = New-AdfParagraph -Inline $inline.ToArray()
            if ($p) { $blocks.Add($p) }
        }
        else {
            $p = New-AdfParagraph -Inline (New-AdfInlineFromMarkdown -Text $joined)
            if ($p) { $blocks.Add($p) }
        }
    }

    foreach ($line in $lines) {
        if ($line -match '^\s*```') {
            if ($inCode) {
                $blocks.Add((New-AdfCodeBlock -Text ($codeLines -join "`n")))
                $codeLines.Clear()
                $inCode = $false
            }
            else {
                & $flushPara
                $inCode = $true
            }
            continue
        }
        if ($inCode) { $codeLines.Add($line); continue }
        if ([string]::IsNullOrWhiteSpace($line)) { & $flushPara; continue }
        if ($paraLines.Count -gt 0 -and $line -match $knownKeys) { & $flushPara }
        $paraLines.Add($line.Trim())
    }
    & $flushPara
    if ($inCode -and $codeLines.Count -gt 0) {
        $blocks.Add((New-AdfCodeBlock -Text ($codeLines -join "`n")))
    }
    return $blocks.ToArray()
}

function New-ParentAdfContent {
    param(
        [PSCustomObject]$Overview,
        [System.Collections.Specialized.OrderedDictionary]$Counts,
        [int]$Total
    )
    $blocks = [System.Collections.Generic.List[object]]::new()
    if ($Overview -and $Overview.Overview) {
        $blocks.Add((New-AdfHeading -Level 3 -Text 'Application Overview'))
        foreach ($para in ($Overview.Overview -split '\r?\n\s*\r?\n')) {
            $trimmed = $para.Trim()
            if ($trimmed) {
                $blocks.Add((New-AdfParagraph -Inline (New-AdfInlineFromMarkdown -Text $trimmed)))
            }
        }
    }
    $blocks.Add((New-AdfHeading -Level 3 -Text 'Findings Summary'))
    $items = @(
        ('Total findings: {0}' -f $Total),
        ('P0 (Critical): {0}' -f $Counts['P0']),
        ('P1 (High): {0}' -f $Counts['P1']),
        ('P2 (Improvement): {0}' -f $Counts['P2']),
        ('P3 (Code Consistency): {0}' -f $Counts['P3'])
    )
    $blocks.Add((New-AdfBulletList -Items $items))
    if ($Overview -and $Overview.Themes) {
        $blocks.Add((New-AdfHeading -Level 3 -Text 'Assessment Themes'))
        $themeLines = $Overview.Themes -split '\r?\n' | Where-Object { $_ -match '^\s*-\s+' } | ForEach-Object { ($_ -replace '^\s*-\s+', '').Trim() }
        if ($themeLines.Count -gt 0) {
            $blocks.Add((New-AdfBulletList -Items $themeLines))
        }
        else {
            foreach ($para in ($Overview.Themes -split '\r?\n\s*\r?\n')) {
                $trimmed = $para.Trim()
                if ($trimmed) {
                    $blocks.Add((New-AdfParagraph -Inline (New-AdfInlineFromMarkdown -Text $trimmed)))
                }
            }
        }
    }
    return ConvertTo-AdfDoc -Content $blocks.ToArray()
}

function New-SimpleAdfDoc {
    param([string]$Text)
    return ConvertTo-AdfDoc -Content @((New-AdfParagraph -Inline (New-AdfInlineFromMarkdown -Text $Text)))
}

# --- Build issue field bodies --------------------------------------------

function ConvertTo-LabelArray {
    param([string]$Value)
    if (-not $Value) { return @() }
    # Jira labels cannot contain spaces; replace and split
    $clean = ($Value -split '[,;]') | ForEach-Object { ($_ -replace '\s+', '_').Trim('_') } | Where-Object { $_ }
    return @($clean)
}

function New-IssueFields {
    param(
        [string]$Summary,
        [string]$IssueType,
        [object]$DescriptionAdf,
        [string]$Priority,
        [string[]]$Labels,
        [string]$ParentIssueKey
    )
    $fields = [ordered]@{
        project   = [ordered]@{ key = $ProjectKey }
        summary   = $Summary
        issuetype = [ordered]@{ name = $IssueType }
    }
    if ($DescriptionAdf) { $fields['description'] = $DescriptionAdf }
    if ($Priority) { $fields['priority'] = [ordered]@{ name = $Priority } }
    if ($Labels -and $Labels.Count -gt 0) { $fields['labels'] = @($Labels) }
    if ($ParentIssueKey) { $fields['parent'] = [ordered]@{ key = $ParentIssueKey } }
    if ($IssueType -eq 'Epic' -and $EpicNameField) { $fields[$EpicNameField] = $Summary }
    return $fields
}

# --- Auth ----------------------------------------------------------------

$headers = @{}
if (-not $DryRun) {
    $authBytes = [System.Text.Encoding]::UTF8.GetBytes(('{0}:{1}' -f $Email, $ApiToken))
    $authB64 = [System.Convert]::ToBase64String($authBytes)
    $headers = @{
        Authorization = ('Basic {0}' -f $authB64)
        Accept        = 'application/json'
    }
}

function Invoke-JiraCreate {
    param([hashtable]$Fields)
    $payload = @{ fields = $Fields } | ConvertTo-Json -Depth 30 -Compress
    $uri = '{0}/rest/api/3/issue' -f $baseTrimmed
    return Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType 'application/json' -Body $payload
}

# --- Resolve parent + groups ---------------------------------------------

$priorityLabels = [ordered]@{ P0 = 'Critical'; P1 = 'High'; P2 = 'Medium'; P3 = 'Low' }
$counts = Get-PriorityCounts -Rows $rows
$overview = Get-AssessmentOverview -Path $AssessmentPath

if (-not $ParentTitle) {
    if ($overview -and $overview.AppName) {
        $ParentTitle = ('Resiliency Assessment: {0} ({1} findings)' -f $overview.AppName, $total)
    }
    else {
        $ParentTitle = ('Resiliency Assessment ({0} findings)' -f $total)
    }
}

$parentDescAdf = $null
if ($ParentDescription) {
    $parentDescAdf = New-SimpleAdfDoc -Text $ParentDescription
}
else {
    $parentDescAdf = New-ParentAdfContent -Overview $overview -Counts $counts -Total $total
}

if ($DryRun) {
    if (-not $NoParent) {
        if ($ParentKey) {
            Write-Host ('Parent: existing key={0}' -f $ParentKey)
        }
        else {
            Write-Host ('Parent type: {0}' -f $ParentType)
            Write-Host ('Parent title: {0}' -f $ParentTitle)
        }
        if ($GroupByPriority) {
            $dryBuckets = Group-RowsByPriority -Rows $rows
            foreach ($p in $dryBuckets.Keys) {
                if ($dryBuckets[$p].Count -gt 0) {
                    Write-Host ('  Priority group: {0} {1} - {2} Priority Findings ({3})' -f $GroupType, $p, $priorityLabels[$p], $dryBuckets[$p].Count)
                }
            }
        }
    }
    for ($i = 0; $i -lt $total; $i++) {
        $row = $rows[$i]
        $type = if ($ChildType) { $ChildType } else { $row.'Issue Type' }
        Write-Host ('OK row {0}: type={1} summary={2}' -f ($i + 1), $type, $row.Summary)
    }
    Write-Host ('DryRun complete. {0} child rows would be created.' -f $total)
    return
}

$parentKeyResolved = $null
if (-not $NoParent) {
    if ($ParentKey) {
        $parentKeyResolved = $ParentKey
        Write-Host ('Linking children to existing parent key={0}' -f $ParentKey)
    }
    else {
        $parentFields = New-IssueFields -Summary $ParentTitle -IssueType $ParentType -DescriptionAdf $parentDescAdf -Labels @('resiliency-assessment')
        try {
            $parentResp = Invoke-JiraCreate -Fields $parentFields
            $parentKeyResolved = $parentResp.key
            Write-Host ('Created parent {0} key={1}: {2}' -f $ParentType, $parentKeyResolved, $ParentTitle)
        }
        catch {
            throw ('Failed to create parent issue: {0}' -f $_.Exception.Message)
        }
    }

    # Attach assessment markdown to parent
    if (-not $NoAttachment -and $AssessmentPath -and (Test-Path -LiteralPath $AssessmentPath) -and $parentKeyResolved) {
        try {
            $attachUri = '{0}/rest/api/3/issue/{1}/attachments' -f $baseTrimmed, $parentKeyResolved
            $attachHeaders = @{
                Authorization              = $headers.Authorization
                Accept                     = 'application/json'
                'X-Atlassian-Token'        = 'no-check'
            }
            $null = Invoke-RestMethod -Uri $attachUri -Method Post -Headers $attachHeaders -Form @{ file = Get-Item -LiteralPath $AssessmentPath }
            Write-Host ('Attached assessment to parent {0}: {1}' -f $parentKeyResolved, (Split-Path -Path $AssessmentPath -Leaf))
        }
        catch {
            Write-Host ('WARN: Failed to attach assessment to parent: {0}' -f $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

# Create priority groups
$priorityGroupKeys = @{}
if ($GroupByPriority -and -not $NoParent) {
    $buckets = Group-RowsByPriority -Rows $rows
    foreach ($p in $buckets.Keys) {
        $bucketRows = $buckets[$p]
        if (-not $bucketRows -or $bucketRows.Count -eq 0) { continue }
        $label = $priorityLabels[$p]
        $gTitle = '{0} - {1} Priority Findings ({2})' -f $p, $label, $bucketRows.Count
        $gDescText = 'Grouping of all {0} ({1}) priority resiliency findings from this assessment. Total: {2}.' -f $p, $label, $bucketRows.Count
        $gDescAdf = New-SimpleAdfDoc -Text $gDescText
        $gFields = New-IssueFields -Summary $gTitle -IssueType $GroupType -DescriptionAdf $gDescAdf -Labels @('resiliency-assessment', $p) -ParentIssueKey $parentKeyResolved
        try {
            $gResp = Invoke-JiraCreate -Fields $gFields
            $priorityGroupKeys[$p] = $gResp.key
            Write-Host ('Created {0} group key={1}: {2}' -f $GroupType, $gResp.key, $gTitle)
        }
        catch {
            throw ('Failed to create priority group {0}: {1}' -f $p, $_.Exception.Message)
        }
    }
}

# Create child issues
$created = 0
$failed = 0
$log = [System.Collections.Generic.List[object]]::new()

for ($i = 0; $i -lt $total; $i++) {
    $row = $rows[$i]
    $summary = $row.Summary
    $type = if ($ChildType) { $ChildType } else { $row.'Issue Type' }
    $priority = $row.Priority
    $labels = ConvertTo-LabelArray -Value $row.Labels

    $descAdf = $null
    if ($row.Description) {
        $descBlocks = ConvertTo-FindingAdfContent -Text $row.Description
        if ($descBlocks.Count -gt 0) { $descAdf = ConvertTo-AdfDoc -Content $descBlocks }
    }

    $childParentKey = $parentKeyResolved
    $pKey = Get-PriorityKey -Summary $summary
    if ($GroupByPriority -and $pKey -and $priorityGroupKeys.ContainsKey($pKey)) {
        $childParentKey = $priorityGroupKeys[$pKey]
    }

    $fields = New-IssueFields -Summary $summary -IssueType $type -DescriptionAdf $descAdf -Priority $priority -Labels $labels -ParentIssueKey $childParentKey

    try {
        $resp = Invoke-JiraCreate -Fields $fields
        $created++
        $log.Add([PSCustomObject]@{
                Index     = $i + 1
                Status    = 'OK'
                Key       = $resp.key
                ParentKey = $childParentKey
                Type      = $type
                Summary   = $summary
                Error     = ''
            })
    }
    catch {
        $failed++
        $errMsg = $_.Exception.Message
        # Try to read the body for richer Jira error
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            if ($stream) {
                $reader = New-Object System.IO.StreamReader($stream)
                $body = $reader.ReadToEnd()
                if ($body) { $errMsg = '{0} | {1}' -f $errMsg, $body }
            }
        }
        catch { }
        $log.Add([PSCustomObject]@{
                Index     = $i + 1
                Status    = 'FAIL'
                Key       = $null
                ParentKey = $childParentKey
                Type      = $type
                Summary   = $summary
                Error     = $errMsg
            })
        Write-Host ('FAIL {0}: {1}' -f ($i + 1), $summary)
        Write-Host $errMsg
    }

    if ((($i + 1) % 10) -eq 0) {
        Write-Host ('Progress: {0}/{1} (created {2}, failed {3})' -f ($i + 1), $total, $created, $failed)
    }
}

$log | Export-Csv -LiteralPath $LogPath -NoTypeInformation -Encoding utf8

Write-Host ''
if ($parentKeyResolved) { Write-Host ('Parent {0} key={1}' -f $ParentType, $parentKeyResolved) }
if ($priorityGroupKeys.Count -gt 0) {
    Write-Host 'Priority groups:'
    foreach ($p in 'P0', 'P1', 'P2', 'P3') {
        if ($priorityGroupKeys.ContainsKey($p)) {
            Write-Host ('  {0} {1} key={2}' -f $GroupType, $p, $priorityGroupKeys[$p])
        }
    }
}
Write-Host ('Import complete. Created: {0} | Failed: {1} | Total: {2}' -f $created, $failed, $total)
Write-Host ('Log: {0}' -f $LogPath)
