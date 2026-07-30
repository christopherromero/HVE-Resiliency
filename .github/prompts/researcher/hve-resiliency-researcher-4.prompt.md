---
description: HVE shared dependency and ownership boundary analyzer
agent: Task Researcher
---

# HVE Researcher 4 - Shared Dependency Boundary Analysis

## Run Condition

Run only if `repository-evidence-index.md` lists shared libraries, platform utilities, generated clients, shared Helm charts, central configuration, shared pipelines, or external ownership boundaries.

If no shared boundary evidence exists, output:

`Shared dependency analysis skipped: no candidate shared dependency evidence found.`

## Role

Analyze shared or centrally managed components that may introduce zone or regional failover risk.

Do not rescan the repository.
Do not recommend fixes.

## Required Inputs

- `.copilot-tracking/research/repository-evidence-index.md`
- Scope contracts and prior research artifacts, if present

## Finding Gate

Create findings only when repository evidence proves:

1. Shared component use.
2. Ownership or deployment boundary.
3. Region, zone, failover, or operational impact.

Missing ownership proof is an Evidence Gap.

## Severity Rules

Use the shared P0/P1/P2/P3 rubric. Do not assign P0/P1 to evidence gaps or non-resiliency items.

## Output File

Write:

`.copilot-tracking/research/shared-dependency-boundary-research.md`

## Output Schema

# Shared Dependency Boundary Research

## 1. Scope Gate

- Shared evidence confirmed: Yes/No
- Candidate files reviewed:
- Analysis stopped early: Yes/No

## 2. Confirmed Findings

### Finding SDB-###

- Priority:
- Resiliency Related: Yes/No
- Confidence:
- Evidence:
- Shared dependency:
- Ownership boundary:
- Failover impact:
- Existing mitigations:
- Constraints:

## 3. Evidence Gaps

- Gap:
- Why it matters:
- Evidence needed:

## Stop Condition

End with:

Next step: Run /clear, then run consolidation.