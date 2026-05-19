param(
    [string]$AssessmentPath = "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md",
    [ValidateSet("ado", "jira")]
    [string]$Tool,
    [string]$OutputPath
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonScript = Join-Path $scriptDir "export-workitems.py"

$argsList = @("$pythonScript", "--assessment-path", "$AssessmentPath")

if ($Tool) {
    $argsList += @("--tool", "$Tool")
}

if ($OutputPath) {
    $argsList += @("--output-path", "$OutputPath")
}

python @argsList
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
