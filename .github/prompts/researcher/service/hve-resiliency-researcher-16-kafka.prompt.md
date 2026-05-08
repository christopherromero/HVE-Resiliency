---
description: Run Prompt 16 Kafka resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 16 Kafka

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are analyzing an application that produces to and/or consumes from Kafka deployed in a multi-region architecture with:
- Independent Kafka clusters per region
- Active-passive regional failover
- Cluster Linking
- DNS-based bootstrap switching
- Client reconnect required on failover

Analyze this codebase and configuration for region resiliency.

Your output MUST include:
1) Gaps vs Region-Resilient Design
- Identify violations of Kafka multi-region best practices
- Call out hard-coded brokers, region affinity, or unsafe assumptions
- Highlight producer, consumer, or offset management risks
2) Remediation Recommendations
- Provide concrete, Kafka-specific fixes aligned to THIS architecture
- Reference exact configs, files, or code paths where possible
- Include examples (producer configs, consumer settings, retry behavior)

Focus specifically on:
- Kafka bootstrap and DNS usage
- Producer idempotence and retry safety
- Consumer offset handling and replay tolerance
- Behavior during broker disconnects and rebalances
- Assumptions about active region availability
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
