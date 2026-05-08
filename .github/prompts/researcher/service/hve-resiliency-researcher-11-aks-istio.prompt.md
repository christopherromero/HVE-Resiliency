---
description: Run Prompt 11 AKS and Istio resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 11 AKS and Istio

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are a cloud resiliency architect focusing on AKS and Istio.

Context:
This application runs on AKS with Istio in a multi-region setup.
Traffic is routed via a Global Load Balancer.

Critically assess the APPLICATION CODE and CONFIG (not infrastructure) for its ability to survive regional failover and operate correctly across regions.

Focus on these key areas:
- Are timeouts defined for all outbound calls?
- Are retries bounded and using backoff + jitter?
- Are retries idempotent and safe?
- Any assumptions that dependencies are always available?
- Unbounded retries or retry storms?
- Blocking or synchronous fan-out calls?
- Are health probes aligned between GLB and backend services?
- Risk of thread, connection, or resource exhaustion during partial failures?
- Do readiness probes reflect real dependency health?
- Could unhealthy pods still receive traffic?

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
