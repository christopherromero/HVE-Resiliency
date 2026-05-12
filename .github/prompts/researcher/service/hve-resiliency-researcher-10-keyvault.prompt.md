---
description: Run Prompt 10 Key Vault resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 10 Key Vault

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are validating and refining a multi-region Azure Key Vault architecture deployed across the primary and secondary regions.

Focus on region resiliency and failover expectations. Assume:
- Two independent Azure Key Vaults (one per region), no automatic Azure failover
- Private Endpoints are regional and do not fail over
- Applications and pipelines are responsible for resiliency behavior

Produce clear, enterprise-grade expectations covering:
1. Region model (active-active vaults, no built-in platform failover)
2. How secrets, keys, and certificates must remain consistent between regions
3. Required application behavior during a regional outage (retry logic, fallback order, error handling)
4. Explicit failover triggers and timing expectations (no DNS or PE changes)
5. What Azure Key Vault does NOT do during a regional failure
6. Guardrails to prevent data drift or accidental writes during outages
7. Are health probes aligned between GLB and backend services?

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