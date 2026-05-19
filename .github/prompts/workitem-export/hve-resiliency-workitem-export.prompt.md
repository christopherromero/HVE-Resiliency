---
description: "Exports Microsoft Assessment findings into ADO or Jira import CSV format"
argument-hint: "[assessmentPath=...] [outputPath=...]"
---

# HVE Resiliency Work Item Export

Run this prompt to generate a backlog import CSV from a Microsoft Assessment markdown file.

## Inputs

* ${input:assessmentPath:Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md}: (Optional) Assessment markdown file to parse.
* ${input:outputPath}: (Optional) Output CSV file path. If omitted, defaults beside the assessment file.

## Required Steps

1. Ask exactly one setup question first: `Which import target do you want, ADO or Jira?`
2. Wait for the user answer and normalize to one of: `ADO` or `Jira`.
3. Run the exporter script:

```powershell
pwsh .github/skills/hve-resiliency-workitem-export/scripts/export-workitems.ps1 -AssessmentPath "${input:assessmentPath}" -TargetTool <ADO|Jira> [-OutputPath "${input:outputPath}"]
```

4. Return a concise completion summary with:
* Selected target
* Findings exported count
* Output file path

## Rules

* Do not ask any additional setup questions.
* Do not generate both targets in one run.
* If the command fails, show the error and suggest one corrective step.
