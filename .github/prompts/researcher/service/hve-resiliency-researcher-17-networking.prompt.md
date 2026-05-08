---
description: Run Prompt 17 Networking resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 17 Networking

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are reviewing an application deployed on a multi-region Azure networking architecture.

Architecture assumptions:
- Public L7 traffic via a single edge (e.g., CDN/WAF)
- Public and private L4 traffic via DNS-based GLB
- Low TTL (approximately 30s) DNS records
- Private Endpoints are regional and IPs do not change
- Regional failover is DNS-name based, not IP-based
- Some PaaS services require application-level failover
- Cross-region traffic may occur during failover

1. Identify gaps relative to a region-resilient application design:
- DNS dependency assumptions (caching, hardcoded IPs, TTL handling)
- Connection retry and timeout behavior
- Session state handling across regions
- Dependency on region-specific endpoints or FQDNs
- Handling of stalled or half-open connections during regional failure
- Awareness of platform vs app-driven failover
- Are health probes aligned between GLB and backend services?

2. Provide concrete remediation recommendations that align with this architecture:
- Changes to DNS usage, retry logic, timeout values
- Recommended libraries, patterns, or configurations
- Observability improvements to detect partial regional failure
- Defensive coding for DNS-based failover and Private Endpoint behavior

3. Identify the exact area in the codebase where the issue exists:
- File/module/class/function name
- Configuration vs runtime logic vs dependency layer

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
