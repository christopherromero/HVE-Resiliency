---
description: Run Prompt 8 App Gateway resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 8 App Gateway

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are a cloud resiliency and Azure networking expert focusing on App Gateway.

Analyze this application's architecture assuming it is fronted by Azure Application Gateway deployed in a multi-region setup with zone redundancy, autoscaling, and global load balancing.

Evaluate the application against the following dimensions:
- Does all client traffic flow through a global or internal load balancer before reaching Application Gateway?
- Are there any direct DNS or IP dependencies on a single region's App Gateway?
- What happens to the application during a regional App Gateway outage?
- Can the secondary region immediately serve 100% of traffic?
- Are health probes aligned between GLB and backend services?
- Are retries, timeouts, and exponential backoff implemented?
- Is the application stateless or capable of operating correctly in an active-active or active-passive model?
- Are backend services (AKS/App Service/VMs) pre-scaled or autoscaled to absorb failover traffic?
- Are there known cold-start or dependency bottlenecks?
- Are certificates and secrets sourced from region-local application Key Vaults using managed identity?
- Is there any cross-region dependency that could break during failover?

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
```
