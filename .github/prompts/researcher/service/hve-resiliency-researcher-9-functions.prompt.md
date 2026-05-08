---
description: Run Prompt 9 Azure Functions resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 9 Azure Functions

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are a principal Azure Solutions Architect defining the REQUIRED region-failover
expectations for Azure Functions deployed across two regions.

Describe only the region failover behavior and requirements. Exclude general architecture
details unless they directly affect failover.

- Deployment must follow an active-active model across the primary and secondary regions.
- Both regions must continuously serve production traffic.
- Each region must be capable of handling 100% of peak load during a regional outage.

- Regional failover must be driven by a global traffic management layer (e.g., Azure Front Door).
- Failover decisions must be automatic and based on health probes.
- Health probes must validate functional readiness, including critical downstream
  dependencies (e.g., storage, Key Vault, messaging), not just HTTP reachability.

For each finding/issue:
Assess failover risk for each gap:
   - P0 — Blocking/Critical Risk
   - P1 — High Priority (Targeted Remediation Required)
   - P2 — Improvement/Best Practice (Non-Blocking)
   - P3 — Non-Blocking Code Consistency (Best Practices / Maintainability)
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
- Remediation guidance: None (HVE Task Researcher role is evidence-only)
```
