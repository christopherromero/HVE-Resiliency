---
description: Run Prompt 3 dependency survivability analysis for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 3

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt - Dependency Survivability

You are acting as a Senior Cloud Application Architect performing a resiliency assessment for a microservice.

## OBJECTIVE
Analyze all Azure and non-Azure services used in this code repository for survivability.

Identify whether endpoints, credentials, or identities assume a single region and whether any fallback or multi-region logic exists in code or configuration.

For each finding include:
- Evidence (file path + line number)
- Brief description of how it is used
- Whether it materially impacts zone or region failover (Yes/No + description of why this could impact zone or region failover)
- Existing mitigations present (if any): retries/timeouts/fallbacks/multi-region selection/failover logic, with evidence (file path + line number)
- Constraints/limitations (if any): dependency/platform capabilities or configuration/operational constraints that shape failover behavior, with evidence (file path + line number) when present
- For each Azure service dependency, explicitly verify whether the application implements a health check for that dependency and whether the resulting health state is reflected in the service's readiness/health endpoints that drive GLB routing decisions (cite file + line evidence). If no health-to-GLB linkage exists, record that as a finding with evidence.
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.