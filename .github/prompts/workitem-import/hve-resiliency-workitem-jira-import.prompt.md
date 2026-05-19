---
description: "Bulk-imports a Jira export CSV into Jira Cloud issues via REST API v3"
argument-hint: "[csvPath=...] [baseUrl=...] [projectKey=...] [groupByPriority=true|false]"
---

# HVE Resiliency Work Item Import (Jira)

Run this prompt to bulk-create Jira Cloud issues from a CSV produced by `/hve-resiliency-workitem-export` (with `Jira` as the target tool).

## Inputs

* ${input:csvPath}: (Optional) Path to the Jira export CSV. If omitted, ask the user.
* ${input:baseUrl}: (Optional) Jira Cloud site URL, for example `https://your-tenant.atlassian.net`. If omitted, ask the user.
* ${input:projectKey}: (Optional) Target Jira project key (e.g., `RES`). If omitted, ask the user.
* ${input:assessmentPath}: (Optional) Path to the assessment markdown used to build the parent summary, description, and attachment.
* ${input:groupByPriority:true}: (Optional) `true` to insert priority group issues (P0/P1/P2/P3) between the parent Epic and the findings. Defaults to `true`.

## Required Steps

1. Confirm `$env:JIRA_EMAIL` and `$env:JIRA_API_TOKEN` are set. If not, instruct the user to set them (token at <https://id.atlassian.com/manage-profile/security/api-tokens>) and stop.
2. For any missing input above, ask the user for that value in a single batched question.
3. Run the importer script. Append `-GroupByPriority` when `${input:groupByPriority}` is `true`:

```powershell
pwsh .github/skills/hve-resiliency-workitem-jira-import/scripts/import-jira.ps1 -CsvPath "${input:csvPath}" -BaseUrl "${input:baseUrl}" -ProjectKey "${input:projectKey}" -AssessmentPath "${input:assessmentPath}" -GroupByPriority
```

4. Return a concise completion summary with:
* Parent issue key and type (or note that `-NoParent` was used)
* Confirmation that the assessment markdown was attached to the parent (when `${input:assessmentPath}` was provided)
* Priority group keys (when `-GroupByPriority` was used)
* Created child count and failed count
* Path to the import log CSV
* Direct link to the Jira backlog: `${input:baseUrl}/jira/software/c/projects/${input:projectKey}/issues`

## Rules

* Do not ask additional setup questions beyond base URL, project key, CSV path, and assessment path.
* Do not modify or delete existing issues.
* Use the credentials from `$env:JIRA_EMAIL` / `$env:JIRA_API_TOKEN`; never display the token in chat.
* If the target project rejects `parent` for non-subtask types (company-managed projects), tell the user to retry with `-NoParent` and link via Epic Link manually.
* If any rows fail, list the first three failure messages and point to the log CSV for the rest.
