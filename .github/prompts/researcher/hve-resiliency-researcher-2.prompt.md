---
description: Run Prompt 2 region and zone assumptions analysis for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 2

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt — Region & Zone Assumptions

You are acting as a Senior Cloud Application Architect performing a resiliency assessment for a microservice.

## OBJECTIVE
Identify all region- or zone-specific assumptions embedded in the codebase.

Evaluate these assumptions specifically for a failover from the primary region to the secondary region.

For each finding include:
- Evidence (file path + line number)
- Brief description of how it is used
- Whether it materially impacts zone or region failover (Yes/No + description of why this could impact zone or region failover)
- Existing mitigations present (if any): retries/timeouts/fallbacks/feature flags/runbooks, with evidence (file path + line number)
- Constraints/limitations (if any): dependency/platform capabilities or configuration/operational constraints that shape failover behavior, with evidence (file path + line number) when present

This includes hardcoded region names, security values, credentials that are hard-coded or stored in files, zone-pinned resources, implicit defaults, or logic that assumes a single active region, and other hard-coded values that could impact zone or region failover.
```
