---
name: hve-resiliency-workitem-jira-import
description: Use for bulk-creating Jira Cloud issues from a resiliency export CSV using the Jira REST API v3, with parent Epic, priority-grouped Stories, ADF descriptions, and assessment attachment.
---

# HVE Resiliency Work Item Import (Jira)

Bulk-create Jira Cloud issues in a target project from a CSV produced by the `hve-resiliency-workitem-export` skill.

## Overview

This skill consumes a Jira-format CSV (`Summary`, `Issue Type`, `Priority`, `Description`, `Labels`, `Components`) and posts each row to Jira Cloud as a new issue via `POST /rest/api/3/issue`. Descriptions are converted into [Atlassian Document Format (ADF)](https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/) so that `Key:` prefixes are rendered as bold, backticked terms become inline `code`, and fenced code blocks become `codeBlock` nodes.

By default the skill creates a single **parent issue** (`Epic` by default) that summarizes the application and findings, and links every imported row to it via the `parent` field. Optionally, with `-GroupByPriority`, the skill inserts an intermediate layer of **priority group** issues (one per `P0`/`P1`/`P2`/`P3` bucket present in the CSV) between the parent Epic and the individual findings, producing this hierarchy:

```
Parent Epic
├── P0 - Critical Priority Findings (N)   ← Story (group)
│   └── individual P0 findings (Bug)
├── P1 - High Priority Findings (N)
├── P2 - Improvement Priority Findings (N)
└── P3 - Code Consistency Priority Findings (N)
```

Group issue type defaults to `Story`; override with `-GroupType`. The individual issue type is taken from the CSV `Issue Type` column (`Bug` for P0/P1, `Task` for P2/P3 by default), or you can force a single type with `-ChildType`.

### Parent issue content

When `-AssessmentPath` is provided, the script auto-builds the parent from the assessment markdown:

* **Summary**: `Resiliency Assessment: <App name> (<N> findings)`
* **Description** (ADF): Application Overview paragraph + Findings Summary bullet list (P0/P1/P2/P3 counts) + Assessment Themes
* **Labels**: `resiliency-assessment`

Override with `-ParentTitle`, `-ParentDescription`, `-ParentType`, link to an existing parent with `-ParentKey`, or skip parent creation entirely with `-NoParent`.

When `-AssessmentPath` is provided and a new parent is created, the assessment markdown file is also uploaded and attached to the parent via `POST /rest/api/3/issue/{key}/attachments`. Suppress with `-NoAttachment`.

## Prerequisites

* PowerShell 7 or later
* A Jira Cloud site URL (e.g., `https://your-tenant.atlassian.net`)
* A Jira API token (generate at <https://id.atlassian.com/manage-profile/security/api-tokens>)
* Permission to create issues, link parents, and add attachments in the target project
* A Jira export CSV from the `hve-resiliency-workitem-export` skill
* The target project **key** (e.g., `RES`)

Credentials may be passed inline with `-Email` and `-ApiToken`, or set in the environment as `JIRA_EMAIL` and `JIRA_API_TOKEN`.

> **Project type:** This skill uses the `parent` field for hierarchy, which works for team-managed projects and for sub-task relationships in company-managed projects. For company-managed projects that require the legacy Epic Link custom field, set `-EpicNameField` and link via your project's Epic Link field manually after import. Most modern Jira Cloud projects accept `parent` for all issue types.

## Quick Start

Preferred slash command flow in Copilot Chat:

1. Run `/hve-resiliency-workitem-jira-import`.
2. Provide base URL, project key, email, API token, and CSV path when prompted.
3. Review the completion summary for created/failed counts and log path.

Direct script flow (full example with priority groups and assessment attachment):

```powershell
$env:JIRA_EMAIL = 'you@example.com'
$env:JIRA_API_TOKEN = '<api-token>'

pwsh .github/skills/hve-resiliency-workitem-jira-import/scripts/import-jira.ps1 `
  -CsvPath "Microsoft-Assessment/exports/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment-Jira-WorkItems.csv" `
  -BaseUrl "https://your-tenant.atlassian.net" `
  -ProjectKey "RES" `
  -AssessmentPath "Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md" `
  -GroupByPriority
```

Produces an `Epic` parent (with the assessment markdown attached), four `Story` priority groups, and one `Bug`/`Task` per finding linked to its priority group.

Use `-DryRun` to validate the CSV and bucketing logic without making any API calls.

## Parameters Reference

| Parameter | Required | Default | Description |
|---|---|---|---|
| `CsvPath` | Yes | None | Path to Jira-format CSV from the export skill |
| `BaseUrl` | Yes | None | Jira Cloud site URL, for example `https://your-tenant.atlassian.net` |
| `ProjectKey` | Yes | None | Target Jira project key (e.g., `RES`) |
| `Email` | Conditional | `$env:JIRA_EMAIL` | Atlassian account email |
| `ApiToken` | Conditional | `$env:JIRA_API_TOKEN` | Atlassian API token |
| `LogPath` | No | `<csv-dir>/<csv-name>-jira-import-log.csv` | Per-row outcome log |
| `AssessmentPath` | No | None | Assessment markdown used to auto-build the parent summary and description |
| `ParentTitle` | No | Auto from assessment or `Resiliency Assessment (<N> findings)` | Override parent summary |
| `ParentDescription` | No | Auto from assessment | Override parent description (plain text wrapped in ADF) |
| `ParentType` | No | `Epic` | Override parent issue type |
| `ParentKey` | No | None | Link children to an existing parent issue key instead of creating a new one |
| `NoParent` | No | `$false` | Skip parent creation and linking entirely |
| `GroupByPriority` | No | `$false` | Insert one priority group issue (P0/P1/P2/P3) under the parent and link findings to the matching group |
| `GroupType` | No | `Story` | Issue type used for priority group items when `-GroupByPriority` is set |
| `ChildType` | No | From CSV `Issue Type` | Force a specific issue type for all child rows |
| `EpicNameField` | No | None | Custom field id (e.g., `customfield_10011`) for "Epic Name" on legacy company-managed projects |
| `NoAttachment` | No | `$false` | Skip uploading the assessment markdown file as an attachment on the parent |
| `DryRun` | No | `$false` | Parse and validate the CSV without creating issues |

## Outputs

* One parent issue (unless `-NoParent` or `-ParentKey` is used) summarizing the app and findings
* The assessment markdown file uploaded and attached to the parent (when `-AssessmentPath` is provided and `-NoAttachment` is not set)
* Optional priority group issues (one per non-empty P0–P3 bucket) when `-GroupByPriority` is set
* New child issues in the target Jira project, one per CSV row, each linked to its priority group (if grouped) or directly to the parent
* A log CSV with columns: `Index`, `Status` (`OK` or `FAIL`), `Key`, `ParentKey`, `Type`, `Summary`, `Error`
* A summary line: `Import complete. Created: N | Failed: N | Total: N`

## Script Reference

| Script | Purpose |
|---|---|
| [scripts/import-jira.ps1](scripts/import-jira.ps1) | Bulk-import the CSV into Jira Cloud via REST API v3 |

## Troubleshooting

* **`Missing -Email` / `Missing -ApiToken`**: Either pass `-Email` and `-ApiToken` on the command line or set `$env:JIRA_EMAIL` and `$env:JIRA_API_TOKEN`.
* **401 Unauthorized**: The API token is invalid, expired, or doesn't match the email. Regenerate at <https://id.atlassian.com/manage-profile/security/api-tokens>.
* **403 Forbidden**: The account lacks Create Issue or Add Attachment permission for the target project.
* **400 with `issuetype: 'Story' is not valid'`**: The target project doesn't include the default `Story` type. Pass `-GroupType <Type>` matching a type that exists in the project (e.g., `Task`, `User Story`).
* **400 with `parent: Field 'parent' cannot be set'`**: The project is company-managed and doesn't allow `parent` for the given issue type. Either drop `-GroupByPriority` and use `-NoParent`, or import without parent and link via Epic Link manually.
* **400 with `Epic Name is required`**: A legacy company-managed project requires Epic Name. Pass `-EpicNameField customfield_10011` (or your project's Epic Name field id).
* **Attachment upload fails silently**: Verify that the API token has the `write:jira-work` scope and the project allows attachments.

## Related Skills

* [hve-resiliency-workitem-export](../hve-resiliency-workitem-export/SKILL.md): Produces the CSV consumed by this skill.
* [hve-resiliency-workitem-import](../hve-resiliency-workitem-import/SKILL.md): The Azure DevOps equivalent of this skill.
