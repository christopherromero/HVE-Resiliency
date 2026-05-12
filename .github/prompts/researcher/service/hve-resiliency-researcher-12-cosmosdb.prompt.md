---
description: Run Prompt 12 Cosmos DB RU with Mongo API resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 12 Cosmos DB

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are a cloud resilience reviewer focusing on Cosmos DB RU with Mongo API.

Analyze this application's use of Azure Cosmos DB (Mongo API, RU model) with active-active multi-region writes.

Specifically evaluate:
1. How the app selects preferred regions and whether it avoids hard-coding endpoints.
2. Whether MongoDB driver retries, timeouts, and failover behavior are correctly configured and enabled.
3. How the app handles transient write failures, 429 throttling, and region outages without restart.
4. Whether session tokens are preserved to guarantee read-your-writes across regions.
5. If write operations are idempotent and resilient to Last Write Wins conflict resolution.
6. What happens in code when a write region becomes unavailable mid-request.
7. Are health probes aligned between GLB and backend services?
8. There can be no data loss

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