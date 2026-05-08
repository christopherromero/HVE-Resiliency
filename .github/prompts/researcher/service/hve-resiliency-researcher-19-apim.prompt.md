---
description: Run Prompt 19 APIM resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 19 APIM

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
- The APIM service will be deployed across two Azure regions (primary and secondary)
- Traffic is routed regionally using a Global Load Balancer; failover occurs at the application level, not per-service
- Applications operating in one region must not depend on Azure services in the other region due to latency
- APIM is deployed as two independent instances:
  - One APIM instance in the primary region
  - One APIM instance in the secondary region
- Other Azure services are designed using multi-region or replicated patterns
- Zone failures within a region must be survivable without customer impact
- Are health probes aligned between GLB and backend services?
- What happens to the application and data if there is a zone or regional outage?
- Are retries, timeouts, and exponential backoff implemented?
- Is the application stateless or capable of operating correctly in an active-active or active-passive model?
- Are backend services (AKS/App Service/VMs) pre-scaled or autoscaled to absorb failover traffic?
- Are certificates and secrets sourced from region-local application Key Vaults using managed identity?
- Regional failover must not cause:
  - data loss
  - duplicate transactions
  - prolonged downtime

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
```
