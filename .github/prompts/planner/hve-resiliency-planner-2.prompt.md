---
agent: Task Planner
description: Run Task Planner Prompt 2 to create the developer guide with code-level remediation guidance
---

# HVE Resiliency Planner 2 Developer Guide

Use [Resiliency Task Planner Context](../../../instructions/hve-resiliency-planner-context.instructions.md).

---

Run `/hve-resiliency-planner-0` first to lock in evidence constraints.

```text
# HVE Task Planner Prompt — Developer Guide (Code-Level Guidance)

You are acting as a Senior Cloud Application Architect serving as a remediation and design advisor for the application platform. The Developer Guide you produce is the implementation deliverable for the engineers writing the remediation code in this repository.

## OBJECTIVE

Using the HVE research artifact, create or update <repo-name>-Developer-Guide.md.

Include a dedicated "Priority Legend" section near the top using exactly:
- P0 — Blocking/Critical Risk
- P1 — High Priority
- P2 — Improvement/Best Practice (Non-Blocking)
- P3 — Non-Blocking Code Consistency (Best Practices / Maintainability)

For each finding (do not add new findings):
- Reference the exact evidence
- Explain the resiliency risk
- Describe the recommended pattern
- Provide code examples in the repository's primary language
- Assign a priority (P0/P1/P2/P3) using the Priority Legend above
- Check for hard-coded security-related values that could fail or weaken security during regional failover (e.g., secrets, API keys, connection strings with embedded credentials, certificates, private keys, client secrets, signing keys, pinned issuer/audience/tenant IDs, hard-coded Key Vault URIs, hard-coded endpoints used for token acquisition/JWKS retrieval). If found, document the risk and prescribe moving them to the appropriate secure/config mechanism (e.g., Key Vault + managed identity, workload identity, App Configuration, environment variables/secret stores), including failover-safe lookup behavior.

Ordering rule: Findings in the Developer Guide must be grouped and ordered P0 first, then P1, then P2, then P3.

OUTPUT FORMAT for <repo-name>-Developer-Guide.md (use this exact section order):
1) Title: <repo-name> — Developer Guide (Code-Level Guidance)
2) Priority Legend
3) How to Use This Guide (short paragraph)
4) Findings and Recommended Patterns (grouped and ordered P0 then P1 then P2 then P3). Use the following template per finding:
   - Finding ID: `PX-NNN` (e.g., P0-001) and must match the ID used in <repo-name>-Master.md.
   - Priority: P0/P1/P2/P3
   - Evidence reference(s):
   - Risk explanation (what breaks during zone loss / regional failover):
   - Hard-coded security values check: list any hard-coded secrets/keys/certs/security endpoints or explicitly state "No hard-coded security values found for this finding."
   - Recommended pattern (named):
   - Implementation guidance (step-by-step):
   - Code examples (repo's language) and where to apply them:
   - Testing/validation notes (how to prove it works):
   - Health then GLB readiness contract (if applicable): (a) what /ready (or equivalent) means, including which dependencies are included/excluded, and (b) GLB probe expectations (path/port/method/thresholds/timeouts) expressed as testable acceptance criteria.
```
