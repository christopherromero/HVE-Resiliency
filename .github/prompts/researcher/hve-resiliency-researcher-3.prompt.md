---
description: HVE state failure and health behavior analyzer
agent: Task Researcher
---

# HVE Researcher 3 - State, Failure, and Health Behavior

## Role

Analyze stateful paths, write paths, failure behavior, and health/readiness from candidate evidence only.

Do not rediscover dependencies.
Do not reclassify Azure or non-Azure scope.
Do not recommend fixes.

## Required Inputs

- `.copilot-tracking/research/repository-evidence-index.md`
- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`
- `.copilot-tracking/research/region-endpoint-dependency-survivability.md`

If any required input is missing, stop and list the missing artifact.

## Objective

Evaluate:

- Stateful vs stateless behavior
- Read/write region assumptions
- Caching behavior
- Event ordering
- Idempotency, replay, duplicate, and out-of-order risk
- Startup failure and degraded-mode behavior
- Retries, timeouts, circuit breakers, fallback, and retry amplification
- Detection signals
- Health/readiness signals affecting GLB/backend routing
- Existing mitigations and constraints

## Bounded Analysis Rule

Open only files listed in the evidence index under:

- State, Write, Message, Cache, and Idempotency Paths
- Health, Readiness, Telemetry, and GLB Signal Paths
- Candidate dependency client or wrapper files

## Finding Gate

Create a finding only when file/line evidence proves:

1. Observed state, failure, or health behavior.
2. Triggering failure condition.
3. Concrete zone or regional failover impact.

Do not classify missing tests, missing logs, or missing documentation as P0/P1 unless failover impact is directly evidenced.

## Severity Rules

- P0: outage, data loss, duplicate business action, unsafe failover, or health routing to broken region.
- P1: material customer, recovery, or data risk with workaround or lower blast radius.
- P2: non-blocking resilience or observability improvement.
- P3: maintainability or consistency only.

## Confidence Rules

- High: direct evidence proves behavior and failover impact.
- Medium: direct evidence proves behavior, but impact depends on one stated constraint.
- Low: partial evidence; normally use Evidence Gap. Do not use Low for P0.

## Output File

Write:

`.copilot-tracking/research/state-failure-health-behavior.md`

## Output Schema

# State, Failure, and Health Behavior Research

## 1. Scope Inputs

- Evidence paths reviewed:
- Analysis stopped early: Yes/No

## 2. Confirmed Findings

### Finding SFH-###

- Priority:
- Resiliency Related: Yes/No
- Confidence:
- Evidence:
- Triggering failure:
- Observed behavior:
- User/customer-visible impact:
- Business/data impact:
- Blast radius:
- Detection signal:
- Existing mitigations:
- Constraints:
- Duplicate evidence locations:

## 3. Evidence Gaps

- Gap:
- Why it matters:
- Evidence needed:

## 4. Non-Findings / Checked Safe

List only meaningful safe behavior with evidence.

## Stop Condition

End with:

Next step: Run /clear, then run Prompt 4 if shared dependencies are present, otherwise run consolidation.