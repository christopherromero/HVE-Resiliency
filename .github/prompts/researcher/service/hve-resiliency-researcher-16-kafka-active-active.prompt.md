---
description: Run Prompt 16 Kafka Active-Active resiliency analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 16 Kafka Active-Active

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are analyzing an application that produces to and/or consumes from Kafka deployed in a multi-region active-active architecture with:
- Independent Kafka clusters per region
- Each region hosts its own writable topic (region-local writes in steady state)
- Each region's writable topic is mirrored one-way into the peer region as a mirror topic via Cluster Linking (topic mirror)
- A feature flag (FF) is at the consumer level while reading from mirrored topics; it governs regional cutover by controlling the consumer read source. Writes always take place to the respective region-local writable topic, not the mirror topic
- In steady state: producers write to their region-local writable topic; consumers do a primary read from the region-local writable topic and read the peer region's mirror topic for the cross-region view
- On regional failover the feature flag is flipped: consumers switch to the mirror read (FF) of the failed region's mirror topic (hosted in the surviving region); producers redirected to the surviving region write to that region's region-local writable topic, not the mirror or promoted topic
- DNS-based bootstrap for cluster connectivity
- GLB routing policy with health-probe checks
- Client reconnect required on failover

Analyze this codebase and configuration for region resiliency.

The mirror topic model plus the feature flag are the central design details. Every finding must be evaluated against these invariants:
- Code that ignores the flag or hard-codes a single topic/region for the current state is a violation
- Producers write to their region-local writable topic in steady state; a producer writing cross-region outside the flag-driven cutover is a violation
- Consumers must read both the region-local writable topic (primary read) and the peer region's mirror topic (mirror read, FF) so no events are missed across the cutover; consuming only one source when the flag requires both is a completeness gap
- Consumer offsets differ between a source writable topic and its mirror (and its promoted form); offset handling must account for the mirror topic, topic promotion, and consumer-group offset synchronization across regions
- Reading across the writable topic and the mirror/promoted topic during a flag transition must not cause duplicate business processing

Your output MUST include:
1) Gaps vs Active-Active Mirror-Topic + Feature-Flag Design
- Identify violations of the Kafka active-active mirror-topic model and its feature-flag-driven cutover
- Call out hard-coded brokers, single-topic/single-region assumptions, consumer read source that ignores the feature flag, producer writes targeting a mirror or promoted topic, or missing mirror-topic consumption
- Highlight feature-flag handling, producer routing, consumer completeness, offset management, and duplicate-processing risks
2) Remediation Recommendations
- Provide concrete, Kafka-specific fixes aligned to THIS active-active mirror-topic + feature-flag architecture
- Reference exact configs, files, or code paths where possible
- Include examples (feature-flag-gated consumer read-source selection, region-local write path, dual-topic consumer subscription, offset sync, idempotent/deduplicated consumption)

Focus specifically on:
- Kafka bootstrap and DNS usage
- Feature flag (FF) handling: is the consumer read source (mirror read) driven by the feature flag, and does the app cut over correctly when it flips?
- Producer routing: producers always write to their region-local writable topic in steady state and after failover redirection, never a mirror or promoted topic (region affinity in steady state is REQUIRED, not a defect)
- Mirror topic write path: producers never write to a mirror or promoted topic; any producer write targeting a mirror topic is a defect (writes always target the region-local writable topic)
- Mirror topic consumption: does the consumer read both the local writable topic and the peer mirror topic as required by the feature flag?
- Consumer offset handling across writable, mirror, and promoted topics, including consumer-group offset synchronization between regions
- Duplicate/idempotent processing when consuming across writable and mirror/promoted sources during and after a feature-flag cutover
- Promotion/failover behavior when a region is lost and its mirror is promoted to the surviving read source for consumers
- Producer idempotence and retry safety
- Consumer replay tolerance and rebalance behavior
- Assumptions about a single active region, a single topic name, or a static topic target that ignores the feature flag
- Cross-region replication dependencies: identify dependencies on near-real-time cross-region replication and describe the changes required to tolerate replication lag, stale mirror topics, delayed mirror-topic delivery, or temporary mirror-topic unavailability
- Event ordering dependencies: identify business workflows, state transitions, or transactional flows that depend on strict event ordering and describe the changes required to tolerate delayed, replayed, or out-of-order events
- Non-idempotent operations: identify business operations that are not idempotent and describe the changes required to prevent duplicate business outcomes when events are replayed, replicated, retried, or consumed more than once
- Runtime cutover readiness: identify producer or consumer routing configuration that is loaded only at startup or cached for the lifetime of the process and describe the changes required to support runtime cutover without application restart
- Failback and regional recovery: analyze failback and regional recovery behavior after a failed region is restored, including producer routing, consumer routing, offset synchronization, mirror-topic rebuild, replay handling, backlog processing, and restoration of normal active-active processing
- Are health probes aligned between GLB and backend services?

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
