---
description: HVE region endpoint and dependency survivability analyzer
agent: Task Researcher
---

# HVE Researcher 2 - Region, Endpoint, and Dependency Survivability

## Role

Analyze confirmed region, endpoint, identity, and dependency evidence from prior artifacts.

Do not rediscover dependencies.
Do not rescan the repository.
Do not recommend fixes.

## Required Inputs

- `.copilot-tracking/research/repository-evidence-index.md`
- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`

If any required input is missing, stop and list the missing artifact.

## Objective

Identify evidence-backed region, zone, endpoint, identity, and dependency survivability risks.

Evaluate:

- Hardcoded region names
- Single-region endpoints
- Direct IPs or region-pinned FQDNs
- Region-pinned credentials, identities, certificates, or secrets
- Dependency endpoint selection
- Fallback or multi-region selection logic
- Health/readiness linkage only where evidence exists

## Bounded Validation Rule

Open only files listed in the evidence index and scope contracts.

## Finding Gate

Create a finding only when:

1. Direct file/line evidence proves current behavior.
2. The behavior is tied to a confirmed endpoint, dependency, identity, or region assumption.
3. The behavior has concrete zone or regional failover impact.

Missing evidence is an Evidence Gap, not a finding.

## Severity Rules

- P0: evidence proves failover is blocked, traffic cannot move safely, or active-active benefit is nullified.
- P1: evidence proves material failover degradation with workaround, manual step, or lower blast radius.
- P2: non-blocking resiliency improvement.
- P3: maintainability or consistency with no functional failover impact.

Do not assign P0/P1 to evidence gaps or items marked Resiliency Related: No.

## Confidence Rules

- High: direct evidence proves behavior and failover impact.
- Medium: direct evidence proves behavior, but impact depends on one stated constraint.
- Low: partial evidence; normally use Evidence Gap instead of finding. Do not use Low for P0.

## Output File

Write:

`.copilot-tracking/research/region-endpoint-dependency-survivability.md`

## Output Schema

# Region, Endpoint, and Dependency Survivability Research

## 1. Scope Inputs

- Evidence index used:
- Azure scope contract used:
- Non-Azure scope contract used:
- Files reviewed:
- Analysis stopped early: Yes/No

## 2. Confirmed Findings

### Finding RED-###

- Priority:
- Resiliency Related: Yes/No
- Confidence:
- Evidence:
- Current behavior:
- Failover impact:
- Existing mitigations:
- Constraints:
- Duplicate evidence locations:

## 3. Evidence Gaps

- Gap:
- Files/patterns checked:
- What evidence is needed:

## 4. Checked but Safe

List only meaningful safe checks with evidence.

## Stop Condition

End with:

Next step: Run /clear, then run Prompt 3.