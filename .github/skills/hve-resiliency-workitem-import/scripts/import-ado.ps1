[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [string]$Project,

    [ValidateSet('Basic', 'Agile', 'Scrum')]
    [string]$Process = 'Basic',

    [string]$LogPath,

    [string]$AssessmentPath,

    [string]$ParentTitle,

    [string]$ParentDescription,

    [string]$ParentType,

    [int]$ParentId,

    [switch]$NoParent,

    [switch]$GroupByPriority,

    [string]$GroupType,

    [switch]$NoAttachment,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw ('CSV not found: {0}' -f $CsvPath)
}

if (-not $LogPath) {
    $csvDir = Split-Path -Path $CsvPath -Parent
    $csvBase = [System.IO.Path]::GetFileNameWithoutExtension($CsvPath)
    $LogPath = Join-Path -Path $csvDir -ChildPath ('{0}-import-log.csv' -f $csvBase)
}

$rows = Import-Csv -LiteralPath $CsvPath
$total = $rows.Count
Write-Host ('Loaded {0} rows from {1}' -f $total, $CsvPath)
Write-Host ('Target: {0} / {1} (process: {2})' -f $Organization, $Project, $Process)

if ($DryRun) {
    Write-Host 'DryRun: no work items will be created.'
}

function Get-DefaultParentType {
    param([string]$Process)
    switch ($Process) {
        'Basic' { return 'Epic' }
        'Agile' { return 'Epic' }
        'Scrum' { return 'Epic' }
    }
}

function Get-DefaultGroupType {
    param([string]$Process)
    switch ($Process) {
        'Basic' { return 'Issue' }
        'Agile' { return 'User Story' }
        'Scrum' { return 'Product Backlog Item' }
    }
}

function Group-RowsByPriority {
    param([object[]]$Rows)
    $buckets = [ordered]@{ P0 = @(); P1 = @(); P2 = @(); P3 = @() }
    foreach ($r in $Rows) {
        if ($r.Title -match '^(P[0-3])-') {
            $buckets[$Matches[1]] += , $r
        }
    }
    return $buckets
}

function Get-TargetType {
    param([string]$SourceType, [string]$Process)
    if ($Process -eq 'Basic' -and $SourceType -eq 'Bug') { return 'Issue' }
    return $SourceType
}

function ConvertTo-PriorityInt {
    param([string]$Value)
    if ($Value -match '^\d+$') { return [int]$Value }
    return 2
}

function Get-PriorityCounts {
    param([object[]]$Rows)
    $counts = [ordered]@{ P0 = 0; P1 = 0; P2 = 0; P3 = 0 }
    foreach ($r in $Rows) {
        if ($r.Title -match '^(P[0-3])-') {
            $key = $Matches[1]
            $counts[$key] = $counts[$key] + 1
        }
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
    if ($overviewMatch.Success) {
        $overviewParagraph = $overviewMatch.Groups[1].Value.Trim()
    }

    $themesBlock = $null
    $themesMatch = [regex]::Match($content, '(?ms)^##\s+Assessment Themes\s*\n+(.+?)(?=\n##\s+)')
    if ($themesMatch.Success) {
        $themesBlock = $themesMatch.Groups[1].Value.Trim()
    }

    return [PSCustomObject]@{
        AppName  = $appName
        Overview = $overviewParagraph
        Themes   = $themesBlock
    }
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

function Convert-InlineMarkdown {
    param([string]$Text)
    if (-not $Text) { return '' }
    # HTML-escape first
    $escaped = $Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
    # Bold **x**
    $escaped = [regex]::Replace($escaped, '\*\*(.+?)\*\*', '<strong>$1</strong>')
    # Inline code `x`
    $escaped = [regex]::Replace($escaped, '`([^`]+?)`', '<code>$1</code>')
    return $escaped
}

function ConvertTo-FindingHtml {
    param([string]$Text)
    if (-not $Text) { return '' }
    # Normalize line endings
    $normalized = $Text -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = $normalized -split "`n"
    $sb = [System.Text.StringBuilder]::new()
    $inCode = $false
    $codeLines = [System.Collections.Generic.List[string]]::new()
    $paraLines = [System.Collections.Generic.List[string]]::new()
    $knownKeys = '^(Finding ID|Finding|Resiliency Related|Issue|Evidence|File|Recommended Fix|Priority):\s*'

    function Flush-Paragraph {
        param([System.Text.StringBuilder]$Sb, [System.Collections.Generic.List[string]]$Lines)
        if ($Lines.Count -eq 0) { return }
        $joined = ($Lines -join ' ').Trim()
        if (-not $joined) { $Lines.Clear(); return }
        # Detect leading "Key:" prefix and bold it
        if ($joined -match '^([A-Z][A-Za-z ]{1,30}):\s*(.*)$') {
            $key = $Matches[1]
            $rest = Convert-InlineMarkdown $Matches[2]
            [void]$Sb.AppendLine(('<p><strong>{0}:</strong> {1}</p>' -f $key, $rest))
        }
        else {
            [void]$Sb.AppendLine(('<p>{0}</p>' -f (Convert-InlineMarkdown $joined)))
        }
        $Lines.Clear()
    }

    foreach ($line in $lines) {
        if ($line -match '^\s*```') {
            if ($inCode) {
                $codeHtml = ($codeLines -join "`n").Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
                [void]$sb.AppendLine(('<pre><code>{0}</code></pre>' -f $codeHtml))
                $codeLines.Clear()
                $inCode = $false
            }
            else {
                Flush-Paragraph $sb $paraLines
                $inCode = $true
            }
            continue
        }
        if ($inCode) {
            $codeLines.Add($line)
            continue
        }
        if ([string]::IsNullOrWhiteSpace($line)) {
            Flush-Paragraph $sb $paraLines
            continue
        }
        # New "Key:" line starts a new paragraph
        if ($paraLines.Count -gt 0 -and $line -match $knownKeys) {
            Flush-Paragraph $sb $paraLines
        }
        $paraLines.Add($line.Trim())
    }
    Flush-Paragraph $sb $paraLines
    if ($inCode -and $codeLines.Count -gt 0) {
        $codeHtml = ($codeLines -join "`n").Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
        [void]$sb.AppendLine(('<pre><code>{0}</code></pre>' -f $codeHtml))
    }
    return $sb.ToString()
}

function New-ParentDescription {
    param(
        [PSCustomObject]$Overview,
        [System.Collections.Specialized.OrderedDictionary]$Counts,
        [int]$Total
    )
    $sb = [System.Text.StringBuilder]::new()
    if ($Overview -and $Overview.Overview) {
        [void]$sb.AppendLine('<h3>Application Overview</h3>')
        [void]$sb.AppendLine((ConvertTo-Html $Overview.Overview))
    }
    [void]$sb.AppendLine('<h3>Findings Summary</h3>')
    [void]$sb.AppendLine('<ul>')
    [void]$sb.AppendLine(('<li><b>Total findings:</b> {0}</li>' -f $Total))
    [void]$sb.AppendLine(('<li><b>P0 (Critical):</b> {0}</li>' -f $Counts['P0']))
    [void]$sb.AppendLine(('<li><b>P1 (High):</b> {0}</li>' -f $Counts['P1']))
    [void]$sb.AppendLine(('<li><b>P2 (Improvement):</b> {0}</li>' -f $Counts['P2']))
    [void]$sb.AppendLine(('<li><b>P3 (Code Consistency):</b> {0}</li>' -f $Counts['P3']))
    [void]$sb.AppendLine('</ul>')
    if ($Overview -and $Overview.Themes) {
        [void]$sb.AppendLine('<h3>Assessment Themes</h3>')
        [void]$sb.AppendLine((ConvertTo-Html $Overview.Themes))
    }
    return $sb.ToString()
}

function New-ChildPatchDocument {
    param(
        [PSCustomObject]$Row,
        [string]$Process,
        [string]$ParentUrl
    )
    $patch = [System.Collections.Generic.List[object]]::new()
    $patch.Add(@{ op = 'add'; path = '/fields/System.Title'; value = $Row.Title })
    $patch.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.Priority'; value = (ConvertTo-PriorityInt $Row.Priority) })

    $descHtml = $null
    if ($Row.Description) {
        $descHtml = ConvertTo-FindingHtml -Text $Row.Description
        $patch.Add(@{ op = 'add'; path = '/fields/System.Description'; value = $descHtml })
    }
    $targetType = Get-TargetType -SourceType $Row.'Work Item Type' -Process $Process
    if ($Process -ne 'Basic' -and $targetType -eq 'Bug' -and $descHtml) {
        # Agile/Scrum Bug forms show ReproSteps as the primary descriptive field
        $patch.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.TCM.ReproSteps'; value = $descHtml })
    }
    if ($Row.Tags) {
        $patch.Add(@{ op = 'add'; path = '/fields/System.Tags'; value = $Row.Tags })
    }

    if ($Process -ne 'Basic') {
        if ($Row.Severity) {
            $patch.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.Severity'; value = $Row.Severity })
        }
        if ($Row.'Acceptance Criteria') {
            $acHtml = ConvertTo-FindingHtml -Text $Row.'Acceptance Criteria'
            $patch.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.AcceptanceCriteria'; value = $acHtml })
        }
        if ($Row.State) {
            $patch.Add(@{ op = 'add'; path = '/fields/System.State'; value = $Row.State })
        }
    }

    if ($ParentUrl) {
        $patch.Add(@{
                op    = 'add'
                path  = '/relations/-'
                value = @{
                    rel = 'System.LinkTypes.Hierarchy-Reverse'
                    url = $ParentUrl
                }
            })
    }

    return $patch.ToArray()
}

# Resolve parent type and content
if (-not $ParentType) { $ParentType = Get-DefaultParentType -Process $Process }
if (-not $GroupType) { $GroupType = Get-DefaultGroupType -Process $Process }
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
if (-not $ParentDescription) {
    $ParentDescription = New-ParentDescription -Overview $overview -Counts $counts -Total $total
}

if ($DryRun) {
    if (-not $NoParent) {
        if ($ParentId) {
            Write-Host ('Parent: existing id={0}' -f $ParentId)
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
        $targetType = Get-TargetType -SourceType $row.'Work Item Type' -Process $Process
        $null = New-ChildPatchDocument -Row $row -Process $Process -ParentUrl 'https://dryrun/_apis/wit/workItems/0'
        Write-Host ('OK row {0}: type={1} title={2}' -f ($i + 1), $targetType, $row.Title)
    }
    Write-Host ('DryRun complete. {0} child rows would be created.' -f $total)
    return
}

$token = az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query accessToken -o tsv 2>$null
if (-not $token) {
    throw 'Failed to acquire ADO access token. Run "az login" and retry.'
}

$orgTrimmed = $Organization.TrimEnd('/')
$projectEncoded = [System.Uri]::EscapeDataString($Project)
$headers = @{ Authorization = ('Bearer {0}' -f $token) }

# Create or resolve parent
$parentUrl = $null
$parentResolvedId = $null
if (-not $NoParent) {
    if ($ParentId) {
        $parentResolvedId = $ParentId
        $parentLookupUri = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $ParentId
        try {
            $parentResp = Invoke-RestMethod -Uri $parentLookupUri -Method Get -Headers $headers
            $parentUrl = $parentResp.url
            Write-Host ('Linking children to existing parent id={0}' -f $ParentId)
        }
        catch {
            throw ('Failed to look up existing parent id={0}: {1}' -f $ParentId, $_.Exception.Message)
        }
    }
    else {
        $parentPatch = @(
            @{ op = 'add'; path = '/fields/System.Title'; value = $ParentTitle },
            @{ op = 'add'; path = '/fields/System.Description'; value = $ParentDescription },
            @{ op = 'add'; path = '/fields/System.Tags'; value = 'resiliency-assessment' }
        )
        $parentBody = $parentPatch | ConvertTo-Json -Depth 10 -Compress -AsArray
        $parentTypeEncoded = [System.Uri]::EscapeDataString($ParentType)
        $parentUri = '{0}/{1}/_apis/wit/workitems/${2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $parentTypeEncoded
        try {
            $parentResp = Invoke-RestMethod -Uri $parentUri -Method Post `
                -Headers $headers `
                -ContentType 'application/json-patch+json' `
                -Body $parentBody
            $parentUrl = $parentResp.url
            $parentResolvedId = $parentResp.id
            Write-Host ('Created parent {0} id={1}: {2}' -f $ParentType, $parentResolvedId, $ParentTitle)
        }
        catch {
            throw ('Failed to create parent work item: {0}' -f $_.Exception.Message)
        }
    }

    # Attach the source assessment to the parent (if available and not suppressed)
    if (-not $NoAttachment -and $AssessmentPath -and (Test-Path -LiteralPath $AssessmentPath) -and $parentResolvedId -and $parentUrl) {
        try {
            $attachFileName = Split-Path -Path $AssessmentPath -Leaf
            $attachBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $AssessmentPath).Path)
            $attachUri = '{0}/{1}/_apis/wit/attachments?fileName={2}&api-version=7.0' -f $orgTrimmed, $projectEncoded, [System.Uri]::EscapeDataString($attachFileName)
            $attachResp = Invoke-RestMethod -Uri $attachUri -Method Post -Headers $headers -ContentType 'application/octet-stream' -Body $attachBytes
            $linkPatch = @(
                @{ op = 'add'; path = '/relations/-'; value = @{ rel = 'AttachedFile'; url = $attachResp.url; attributes = @{ comment = 'Source assessment markdown' } } }
            )
            $linkBody = $linkPatch | ConvertTo-Json -Depth 10 -Compress -AsArray
            $linkUri = '{0}/{1}/_apis/wit/workitems/{2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $parentResolvedId
            $null = Invoke-RestMethod -Uri $linkUri -Method Patch -Headers $headers -ContentType 'application/json-patch+json' -Body $linkBody
            Write-Host ('Attached assessment to parent id={0}: {1}' -f $parentResolvedId, $attachFileName)
        }
        catch {
            Write-Host ('WARN: Failed to attach assessment to parent: {0}' -f $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

# Create priority group parents (if requested)
$priorityGroupUrls = @{}
$priorityGroupIds = @{}
if ($GroupByPriority -and -not $NoParent) {
    $buckets = Group-RowsByPriority -Rows $rows
    $groupTypeEncoded = [System.Uri]::EscapeDataString($GroupType)
    foreach ($p in $buckets.Keys) {
        $bucketRows = $buckets[$p]
        if (-not $bucketRows -or $bucketRows.Count -eq 0) { continue }
        $label = $priorityLabels[$p]
        $gTitle = '{0} - {1} Priority Findings ({2})' -f $p, $label, $bucketRows.Count
        $gDesc = '<p>Grouping of all <strong>{0}</strong> ({1}) priority resiliency findings from this assessment. Total: <strong>{2}</strong>.</p>' -f $p, $label, $bucketRows.Count
        $gPatch = @(
            @{ op = 'add'; path = '/fields/System.Title'; value = $gTitle },
            @{ op = 'add'; path = '/fields/System.Description'; value = $gDesc },
            @{ op = 'add'; path = '/fields/System.Tags'; value = ('resiliency-assessment; {0}' -f $p) }
        )
        if ($parentUrl) {
            $gPatch += @{ op = 'add'; path = '/relations/-'; value = @{ rel = 'System.LinkTypes.Hierarchy-Reverse'; url = $parentUrl } }
        }
        $gBody = $gPatch | ConvertTo-Json -Depth 10 -Compress -AsArray
        $gUri = '{0}/{1}/_apis/wit/workitems/${2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $groupTypeEncoded
        try {
            $gResp = Invoke-RestMethod -Uri $gUri -Method Post -Headers $headers -ContentType 'application/json-patch+json' -Body $gBody
            $priorityGroupUrls[$p] = $gResp.url
            $priorityGroupIds[$p] = $gResp.id
            Write-Host ('Created {0} group id={1}: {2}' -f $GroupType, $gResp.id, $gTitle)
        }
        catch {
            throw ('Failed to create priority group {0}: {1}' -f $p, $_.Exception.Message)
        }
    }
}

$created = 0
$failed = 0
$log = [System.Collections.Generic.List[object]]::new()

for ($i = 0; $i -lt $total; $i++) {
    $row = $rows[$i]
    $targetType = Get-TargetType -SourceType $row.'Work Item Type' -Process $Process
    $title = $row.Title

    $childParentUrl = $parentUrl
    if ($GroupByPriority -and $row.Title -match '^(P[0-3])-' -and $priorityGroupUrls.ContainsKey($Matches[1])) {
        $childParentUrl = $priorityGroupUrls[$Matches[1]]
    }

    $patch = New-ChildPatchDocument -Row $row -Process $Process -ParentUrl $childParentUrl
    $body = $patch | ConvertTo-Json -Depth 10 -Compress -AsArray
    $typeEncoded = [System.Uri]::EscapeDataString($targetType)
    $uri = '{0}/{1}/_apis/wit/workitems/${2}?api-version=7.0' -f $orgTrimmed, $projectEncoded, $typeEncoded

    try {
        $resp = Invoke-RestMethod -Uri $uri -Method Post `
            -Headers $headers `
            -ContentType 'application/json-patch+json' `
            -Body $body
        $created++
        $log.Add([PSCustomObject]@{
                Index    = $i + 1
                Status   = 'OK'
                Id       = $resp.id
                ParentId = $parentResolvedId
                Type     = $targetType
                Title    = $title
                Error    = ''
            })
    }
    catch {
        $failed++
        $errMsg = $_.Exception.Message
        $log.Add([PSCustomObject]@{
                Index    = $i + 1
                Status   = 'FAIL'
                Id       = $null
                ParentId = $parentResolvedId
                Type     = $targetType
                Title    = $title
                Error    = $errMsg
            })
        Write-Host ('FAIL {0}: {1}' -f ($i + 1), $title)
        Write-Host $errMsg
    }

    if ((($i + 1) % 10) -eq 0) {
        Write-Host ('Progress: {0}/{1} (created {2}, failed {3})' -f ($i + 1), $total, $created, $failed)
    }
}

$log | Export-Csv -LiteralPath $LogPath -NoTypeInformation -Encoding utf8

Write-Host ''
if ($parentResolvedId) {
    Write-Host ('Parent {0} id={1}' -f $ParentType, $parentResolvedId)
}
if ($priorityGroupIds.Count -gt 0) {
    Write-Host 'Priority groups:'
    foreach ($p in 'P0', 'P1', 'P2', 'P3') {
        if ($priorityGroupIds.ContainsKey($p)) {
            Write-Host ('  {0} {1} id={2}' -f $GroupType, $p, $priorityGroupIds[$p])
        }
    }
}
Write-Host ('Import complete. Created: {0} | Failed: {1} | Total: {2}' -f $created, $failed, $total)
Write-Host ('Log: {0}' -f $LogPath)
