---
description: Run Prompt 15 Azure Storage resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 15 Azure Storage

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
Analyze this application's Azure Storage architecture and usage for regional resiliency and failover readiness.

Focus on:
1. How writes are handled across regions (concurrent vs single-region).
2. Idempotency, retries, and conflict resolution (ETags, metadata, versioning).
3. Behavior during regional storage or service failure (read/write fallback).
4. Implications for both synchronous and asynchronous replication paths.
5. Dependencies on Blob vs Azure Files and any unsupported DR assumptions.
6. Required operational steps for failover and failback (runbook gaps).
7. Are health probes aligned between GLB and backend services?

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
