---
name: hve-resiliency-workitem-export
description: Use for converting Microsoft Assessment resiliency findings into Excel-compatible CSV files for Azure DevOps or Jira work item import with target-specific field mapping.
---

# HVE Resiliency Work Item Export

Convert resiliency findings from a Microsoft Assessment markdown report into an Excel-compatible CSV file that can be imported into Azure DevOps or Jira.

## Overview

This skill extracts findings from assessment sections such as P0 through P3 and maps them to import columns based on the selected destination platform.

The first action in this workflow is always to ask the user which destination they want:

* ADO
* Jira

After the user chooses a destination, generate only the destination-specific export format.

## Prerequisites

* PowerShell 7 or later
* A completed assessment markdown file under `Microsoft-Assessment/`
* The destination import template for your ADO org or Jira project

## Quick Start

Preferred simple flow in Copilot Chat:

1. Run `/hve-resiliency-workitem-export`.
2. Answer with one word: `ADO` or `Jira`.
3. Review the completion summary for exported row count and output path.

Direct script flow:

1. Ask the user: "Which tool should I prepare the export for: ADO or Jira?"
2. Use the selected value as `-TargetTool`.
3. Run the exporter script.
4. Open the generated CSV in Excel to review and adjust optional fields.
5. Import the CSV into the selected platform.

Example command:

```powershell
pwsh .github/skills/hve-resiliency-workitem-export/scripts/export-workitems.ps1 \
  -AssessmentPath "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md" \
  -TargetTool ADO \
  -OutputPath "Microsoft-Assessment/exports/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-ADO-WorkItems.csv"
```

## Parameters Reference

| Parameter | Required | Default | Description |
|---|---|---|---|
| `AssessmentPath` | Yes | None | Path to the assessment markdown file |
| `TargetTool` | Yes | None | Destination tool: `ADO` or `Jira` |
| `OutputPath` | No | Auto-generated in assessment folder | Output CSV path |

## Script Reference

Script path: `.github/skills/hve-resiliency-workitem-export/scripts/export-workitems.ps1`

The script performs these actions:

1. Parses finding blocks that start with headers like `#### P0-001: ...`
2. Extracts key metadata fields including Priority, Resiliency Related, Issue, Recommended Fix, and File
3. Maps each finding into destination-specific columns
4. Writes a UTF-8 CSV file that opens directly in Excel

Destination mapping summary:

* ADO columns: `Title`, `Work Item Type`, `Priority`, `Severity`, `State`, `Description`, `Acceptance Criteria`, `Tags`
* Jira columns: `Summary`, `Issue Type`, `Priority`, `Description`, `Labels`, `Components`

The `Description` column preserves the original assessment structure: `Finding`, `Priority`, `Resiliency Related`, `Issue`, `File`, and `Recommended Fix` sections are kept on separate lines (separated by blank lines), and internal markdown such as fenced code blocks (` ``` `) and inline backticks are kept intact. The import skill converts this to HTML on the way into ADO.

## Required Behavior for Agent Runs

When this skill is active, follow this behavior every time:

1. Ask exactly one setup question first: `Which tool should I prepare this export for: ADO or Jira?`
2. Do not generate output before the user answers.
3. Use only the selected destination schema.
4. Confirm the output file path and record count after export.

## Troubleshooting

* No findings exported:
  * Confirm the report contains finding headers in the form `#### Pn-###: Title`
* Import rejects CSV:
  * Download the latest import template from your ADO org or Jira project and align optional columns
* Description field too long:
  * Keep the full details in the assessment and add a short summary in the imported work item

## Attribution

This skill is part of the HVE Resiliency workflow and extends assessment outputs into backlog-import artifacts for Azure DevOps and Jira.
