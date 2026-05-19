---
description: "Bulk-imports an ADO export CSV into Azure DevOps work items via REST API"
argument-hint: "[csvPath=...] [organization=...] [project=...] [process=Basic|Agile|Scrum]"
---

# HVE Resiliency Work Item Import

Run this prompt to bulk-create Azure DevOps work items from a CSV produced by `/hve-resiliency-workitem-export`.

## Inputs

* ${input:csvPath}: (Optional) Path to the ADO export CSV. If omitted, ask the user.
* ${input:organization}: (Optional) ADO organization URL, for example `https://dev.azure.com/contoso`. If omitted, ask the user.
* ${input:project}: (Optional) ADO project name. If omitted, ask the user.
* ${input:process:Basic}: (Optional) Process template of the target project: `Basic`, `Agile`, or `Scrum`.
* ${input:assessmentPath}: (Optional) Path to the assessment markdown used to build the parent title and description.
* ${input:groupByPriority:true}: (Optional) `true` to insert priority group work items (P0/P1/P2/P3) between the parent and the findings. Defaults to `true`.

## Required Steps

1. Confirm Azure CLI is signed in. If not, instruct the user to run `az login` and stop.
2. For any missing input above, ask the user for that value in a single batched question.
3. Run the importer script. Append `-GroupByPriority` when `${input:groupByPriority}` is `true`:

```powershell
pwsh .github/skills/hve-resiliency-workitem-import/scripts/import-ado.ps1 -CsvPath "${input:csvPath}" -Organization "${input:organization}" -Project "${input:project}" -Process ${input:process} -AssessmentPath "${input:assessmentPath}" -GroupByPriority
```

4. Return a concise completion summary with:
* Parent work item id and type (or note that `-NoParent` was used)
* Confirmation that the assessment markdown was attached to the parent (when `${input:assessmentPath}` was provided)
* Priority group ids (when `-GroupByPriority` was used)
* Created child count and failed count
* Path to the import log CSV
* Direct link to the ADO board: `${input:organization}/${input:project}/_workitems`

## Rules

* Do not ask additional setup questions beyond org, project, process, CSV path, and assessment path.
* Do not modify or delete existing work items.
* If `Process` is `Basic`, remind the user in the summary that the parent was created as `Epic`, the priority group items were created as `Issue` (Basic has no `User Story` type), source `Bug` rows were created as `Issue`, and Severity and Acceptance Criteria were dropped.
* If `Process` is `Agile`, the parent is `Epic` and priority group items are `User Story`. If `Process` is `Scrum`, the parent is `Epic` and priority group items are `Product Backlog Item`.
* If any rows fail, list the first three failure messages and point to the log CSV for the rest.
