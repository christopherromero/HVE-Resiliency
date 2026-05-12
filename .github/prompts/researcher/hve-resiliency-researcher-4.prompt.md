---
description: Run Prompt 4 state data and consistency characteristics for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 4

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt - State, Data & Consistency

You are acting as a Senior Cloud Application Architect performing a resiliency assessment for a microservice.

## OBJECTIVE
Analyze how application state and data are managed.

Identify assumptions related to:
- Read/write regions
- Preferred locations
- Caching behavior
- Event ordering
- Idempotency or lack thereof

Explicitly identify data loss potential (facts only): where loss could occur, under what failure condition (zone loss, regional failover, partial dependency outage), and which writes/messages/records could be dropped.

Cite file and line-level evidence.

Record any existing mitigations already present (idempotency guards, retry/timeout policies, fallback logic, feature flags), with file + line evidence.

Record any constraints/limitations (dependency consistency model, replication lag, write restrictions, operational failover steps, or other platform limits) that affect correctness during zone/region failure, with evidence when present.

Document risks that could surface during zone or regional failover.
Do not propose fixes.
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.