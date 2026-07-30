---
description: HVE non-Azure dependency discovery scope contract
agent: Task Researcher
---

# HVE Researcher 1b - Non-Azure Dependency Scope Contract

## Role

Identify external, third-party, SaaS, internal platform, and non-Azure dependencies actually used by this repository.

## Required Input

Read first:

`.copilot-tracking/research/repository-evidence-index.md`

If the evidence index is missing or malformed, stop and output:

`Non-Azure scope contract not generated: repository-evidence-index.md is missing or malformed. Run Prompt 0 first.`

## Source Rule

Use only candidate files from the evidence index.

Do not rescan all code, configuration, IaC, or pipelines.

Do not require GLB linkage proof for every dependency unless health or routing evidence exists in the index. If health linkage is not visible, record an Evidence Gap, not a finding.

## Objective

Produce a definitive external dependency scope contract.

## Evidence Rules

List a dependency as Used only when explicitly referenced with file/line evidence.

Do not infer usage.

Do not assign P0/P1/P2/P3.
Do not recommend fixes.

## Output File

Write:

`.copilot-tracking/research/non-azure-scope-contract.md`

## Output Schema

# Non-Azure Dependency Scope Contract

## 1. Scope Gate Result

- Evidence index used:
- Non-Azure dependency evidence confirmed: Yes/No
- Health/routing evidence confirmed: Yes/No/Unclear
- Analysis stopped early: Yes/No
- Reason if stopped early:

## 2. Used External Dependencies

| Dependency | Evidence | How it is used | Region/failover sensitivity | Existing mitigations | Constraints |
|---|---|---|---|---|---|

## 3. Dependency Health and GLB Signal Evidence

| Dependency | Health check evidence | Health determination | Surfaced to GLB/readiness? | Evidence gap |
|---|---|---|---|---|

## 4. Checked but Not Present

| Dependency | Reason checked | Evidence result |
|---|---|---|

## 5. Not Applicable Categories

| Category | Reason not applicable |
|---|---|

## 6. Non-Azure Evidence Index

| Dependency | Evidence ID | File | Lines |
|---|---|---|---|

## Stop Condition

End with:

Next step: Run /clear, then run Prompt 2 after Azure and Non-Azure scope contracts are complete.