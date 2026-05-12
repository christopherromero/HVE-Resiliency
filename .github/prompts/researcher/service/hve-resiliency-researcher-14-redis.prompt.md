---
description: Run Prompt 14 Redis resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 14 Redis

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are reviewing an application that uses Azure Managed Redis Enterprise
in an ACTIVE-ACTIVE, multi-region configuration with eventual consistency.

Evaluate these areas:
1. Regional-first usage
- Does the app connect to a local Redis endpoint by default?
- Is region selection explicit and configurable?
- How does the app detect Redis failure (timeouts/errors)?
- Is there clear fallback logic to secondary/tertiary regions?
- Are retries bounded with backoff (no retry storms)?
- Does the app assume immediate cross-region consistency?
- On cache miss or stale data, does it safely fall back to the source of truth?
- Are hot keys or concurrent multi-region writes likely?
- Is Redis treated strictly as a cache (no durability assumptions)?
- Can the app start if Redis is unavailable?
- Does it fail back cleanly once the local region is healthy again?
- Are health probes aligned between GLB and backend services?

For each finding/issue:
Assess failover risk for each gap:
   - P0 - Blocking/Critical Risk
   - P1 - High Priority (Targeted Remediation Required)
   - P2 - Improvement/Best Practice (Non-Blocking)
   - P3 - Non-Blocking Code Consistency (Best Practices / Maintainability)
   - Provide an explanation why this is an issue, why each issue is rated at that level
- Identify the area in the code, impact if not fixed, where the issue is located (File + line #)

OUTPUT FORMAT (repeat per issue):
- Issue Description:
- Risk Level (P0/P1/P2/P3):
- Code location (file + line number):
- Why this is a risk to app, zone or region failover:
- Impact(s) if this is not changed:
- Existing mitigations present (evidence):
- Constraints/limitations (evidence):
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.