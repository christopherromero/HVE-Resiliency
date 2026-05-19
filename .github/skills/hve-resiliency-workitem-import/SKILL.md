---
name: hve-resiliency-workitem-import
description: Use for bulk-creating Azure DevOps work items from a resiliency export CSV using the ADO REST API with field mapping for Basic, Agile, and Scrum process templates.
---

# HVE Resiliency Work Item Import

Bulk-create Azure DevOps work items in a target organization and project from a CSV produced by the `hve-resiliency-workitem-export` skill.

## Overview

This skill consumes an ADO-format CSV (Title, Work Item Type, Priority, Severity, State, Description, Acceptance Criteria, Tags) and posts each row to Azure DevOps as a new work item using the REST API directly (`POST .../_apis/wit/workitems/${type}`). It maps source types and fields based on the destination project's process template.

By default the skill also creates a single **parent work item** that summarizes the application and findings, and links every imported row to it as a child via `System.LinkTypes.Hierarchy-Reverse`. The parent type defaults to `Epic` for all processes and can be overridden.

Optionally, with `-GroupByPriority`, the skill inserts an intermediate layer of **priority group** work items (one per `P0`/`P1`/`P2`/`P3` bucket present in the CSV) between the parent and the individual findings, producing this hierarchy:

```
Parent (Epic / User Story / PBI)
├── P0 - Critical Priority Findings (N)   ← grouping work item
│   └── individual P0 findings
├── P1 - High Priority Findings (N)
├── P2 - Medium Priority Findings (N)
└── P3 - Low Priority Findings (N)
```

Group work item type defaults to `Issue` for Basic, `User Story` for Agile, and `Product Backlog Item` for Scrum; override with `-GroupType`.

Field mapping by process:

| Process | Default parent type | Default group type (with `-GroupByPriority`) | Bug rows become | Severity | Acceptance Criteria | State |
|---|---|---|---|---|---|---|
| `Basic` | `Epic` | `Issue` | `Issue` | dropped (no field) | dropped (no field) | defaults to `To Do` |
| `Agile` | `Epic` | `User Story` | `Bug` | `Microsoft.VSTS.Common.Severity` | `Microsoft.VSTS.Common.AcceptanceCriteria` | from CSV |
| `Scrum` | `Epic` | `Product Backlog Item` | `Bug` | `Microsoft.VSTS.Common.Severity` | `Microsoft.VSTS.Common.AcceptanceCriteria` | from CSV |

Task rows are always created as `Task`. Priority maps to `Microsoft.VSTS.Common.Priority`. Tags maps to `System.Tags`. The CSV `Description` and `Acceptance Criteria` columns are converted from plain text to HTML before posting (bold `Key:` prefixes, inline `<code>` for backticked terms, `<pre><code>` for fenced code blocks). For `Bug` rows on Agile and Scrum projects the same HTML is also written to `Microsoft.VSTS.TCM.ReproSteps` (the field the Bug form displays as primary content).

### Parent work item content

When `-AssessmentPath` is provided, the script auto-builds the parent from the assessment markdown:

* **Title**: `Resiliency Assessment: <App name> (<N> findings)`
* **Description** (HTML): Application Overview paragraph + Findings Summary (P0/P1/P2/P3 counts) + Assessment Themes
* **Tag**: `resiliency-assessment`

Override with `-ParentTitle`, `-ParentDescription`, `-ParentType`, link to an existing parent with `-ParentId`, or skip parent linkage entirely with `-NoParent`.

When `-AssessmentPath` is provided and a new parent is created, the assessment markdown file is also uploaded and attached to the parent as an `AttachedFile`. Suppress with `-NoAttachment`.

## Prerequisites

* PowerShell 7 or later
* Azure CLI 2.60 or later, signed in (`az login`) with permission to create work items in the target project
* An ADO export CSV from the `hve-resiliency-workitem-export` skill
* The destination org URL (e.g., `https://dev.azure.com/contoso`) and project name
* Knowledge of the destination project's process template (`Basic`, `Agile`, or `Scrum`)

## Quick Start

Preferred slash command flow in Copilot Chat:

1. Run `/hve-resiliency-workitem-import`.
2. Provide org URL, project name, process template, and CSV path when prompted.
3. Review the completion summary for created/failed counts and log path.

Direct script flow (full Agile example with priority groups and assessment attachment):

```powershell
pwsh .github/skills/hve-resiliency-workitem-import/scripts/import-ado.ps1 `
  -CsvPath "Microsoft-Assessment/exports/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-ADO-WorkItems.csv" `
  -Organization "https://dev.azure.com/hve-test" `
  -Project "hve-resiliency" `
  -Process Agile `
  -AssessmentPath "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md" `
  -GroupByPriority
```

Produces an `Epic` parent (with the assessment markdown attached), four `User Story` priority groups, and one `Bug` per finding linked to its priority group.

## Parameters Reference

| Parameter | Required | Default | Description |
|---|---|---|---|
| `CsvPath` | Yes | None | Path to ADO-format CSV from the export skill |
| `Organization` | Yes | None | ADO org URL, for example `https://dev.azure.com/<org>` |
| `Project` | Yes | None | ADO project name |
| `Process` | No | `Basic` | Process template: `Basic`, `Agile`, or `Scrum` |
| `LogPath` | No | `<csv-dir>/<csv-name>-import-log.csv` | Per-row outcome log |
| `AssessmentPath` | No | None | Assessment markdown used to auto-build the parent title and description |
| `ParentTitle` | No | Auto from assessment or `Resiliency Assessment (<N> findings)` | Override parent title |
| `ParentDescription` | No | Auto from assessment | Override parent description (HTML) |
| `ParentType` | No | `Epic` (all processes) | Override parent work item type |
| `ParentId` | No | None | Link children to an existing parent instead of creating a new one |
| `NoParent` | No | `$false` | Skip parent creation and linking entirely |
| `GroupByPriority` | No | `$false` | Insert one priority group work item (P0/P1/P2/P3) under the parent and link findings to the matching group |
| `GroupType` | No | `Issue` (Basic) / `User Story` (Agile) / `Product Backlog Item` (Scrum) | Work item type used for priority group items when `-GroupByPriority` is set |
| `NoAttachment` | No | `$false` | Skip uploading the assessment markdown file as an attachment on the parent |
| `DryRun` | No | `$false` | Parse and validate the CSV without creating work items |

## Outputs

* One parent work item (unless `-NoParent` or `-ParentId` is used) summarizing the app and findings
* The assessment markdown file uploaded and attached to the parent (when `-AssessmentPath` is provided and `-NoAttachment` is not set)
* Optional priority group work items (one per non-empty P0–P3 bucket) when `-GroupByPriority` is set
* New child work items in the target ADO project, one per CSV row, each linked to its priority group (if grouped) or directly to the parent
* A log CSV with columns: `Index`, `Status` (`OK` or `FAIL`), `Id`, `ParentId`, `Type`, `Title`, `Error`
* A summary line: `Import complete. Created: N | Failed: N | Total: N`

## Script Reference

| Script | Purpose |
|---|---|
| [scripts/import-ado.ps1](scripts/import-ado.ps1) | Bulk-import the CSV into Azure DevOps via REST API |

## Troubleshooting

* **`Failed to acquire ADO access token`**: Run `az login` and confirm the signed-in account has access to the target organization.
* **`TF401320: Rule Error for field`**: A field value is not allowed by the target process. Check `Priority` (must be 1–4) and that `Process` parameter matches the actual project process.
* **`VS402625: The work item type does not exist`**: The `Process` parameter does not match the project's process template. Confirm via `az devops project show --project <name>` and the `_settings/process` page in ADO.
* **Authentication 401**: The acquired token does not have ADO scope. Re-run `az login --scope 499b84ac-1321-427f-aa17-267ca6975798/.default`.
* **Slow throughput**: Each item is one synchronous REST call. For very large backlogs (>500), run during off-peak or batch by priority.

## Related Skills

* [hve-resiliency-workitem-export](../hve-resiliency-workitem-export/SKILL.md): Produces the CSV consumed by this skill.
* [hve-resiliency-workitem-jira-import](../hve-resiliency-workitem-jira-import/SKILL.md): The Jira Cloud equivalent of this skill.
