---
description: Run Prompt 13 SQL Server resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 13 SQL Server

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are a cloud reliability and data consistency expert focusing on Azure SQL Server.

Analyze this application that uses:
- Azure SQL with zone redundancy and Failover Groups
- Managed Identity authentication

Evaluate the application's ability to:
1) Survive zonal failures with zero data loss
2) Fail over regionally with controlled write safety
3) Prevent data corruption or split-brain during failover

Focus on these elements:
- Database access: use of Failover Group RW listener vs direct endpoints
- Write safety during regional failover (write blocking, fencing, maintenance mode)
- Retry, timeout, and circuit breaker behavior (client + app)
- Transaction idempotency and duplicate write prevention
- Connection pooling behavior during SQL role changes
- State handling (stateless pods, externalized sessions, queues)
- Are health probes aligned between GLB and backend services?

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
