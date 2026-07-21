---
description: Run Prompt 16 Kafka cross-service topic dependency and coordinated cutover analysis
agent: Task Researcher
---

# HVE Resiliency Researcher 16 Kafka Topic Dependencies

> **DRAFT - DO NOT USE YET.** This prompt explores a cross-service topic dependency and coordinated-cutover scenario that is still under team discussion and pending stakeholder confirmation of the approach. Do not run it in an assessment, and do not add it to the skill map or workflow docs until the approach is approved.

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are analyzing an application that shares Kafka topics with other services in a multi-region active-active architecture with:
- Independent Kafka clusters per region
- Region-local writable topics mirrored one-way into the peer region as mirror topics via Cluster Linking (topic mirror)
- A feature flag (FF) that governs regional cutover by selecting the producer write target and the consumer read source
- The SAME writable and mirror topics may be produced to and/or consumed by services OUTSIDE the one under analysis (other applications, teams, or repositories)

The focus of THIS analysis is cross-service topic dependency and coordinated cutover. When a regional failover occurs, every producer and consumer of a shared topic must cut over consistently. If one service flips its feature flag while another does not, writes and reads fragment across the region-local writable topic and the promoted (former mirror) topic, causing split-brain, data fragmentation, missed events, duplicate processing, or broken ordering.

Analyze this codebase and configuration for cross-service topic dependency and coordinated failover. Base every finding on evidence in this repository; where the behavior of an external producer/consumer cannot be confirmed from this repository, state the dependency and the unverified assumption explicitly as a risk.

Every finding must be evaluated against these invariants:
- Cutover must be coordinated across ALL producers and consumers of a shared topic; a service that cuts over independently of its topic peers is a split-brain risk
- The feature flag that drives topic selection should resolve from a single shared source of truth for every service on the topic; a flag that is local to one service, with no shared/global coordination, cannot guarantee lockstep cutover
- Producers and consumers on a shared topic must agree on topic naming for both the region-local writable topic and the mirror topic; divergent or hard-coded topic names break coordinated cutover
- During cutover no subset of producers may keep writing to the region-local topic while others write to the promoted mirror topic; split writes fragment the event stream and lose completeness
- Consumers across services must have a defined offset and consumer-group strategy for the shared topic so a coordinated cutover does not drop, replay, or double-process events

Your output MUST include:
1) Gaps vs Coordinated Cross-Service Cutover
- Identify topics that this service produces to or consumes from that are (or appear to be) shared with services outside this repository
- Identify where this service assumes it is the sole producer or consumer of a topic
- Identify feature-flag scope (local vs shared/global), topic-name resolution, and any missing coordination signal that would let an external topic peer know to fail over
- Highlight split-brain, data-fragmentation, missed-event, duplicate-processing, and ordering risks that arise when topic peers cut over independently
2) Remediation Recommendations
- Provide concrete, Kafka-specific fixes for coordinating cutover across all producers and consumers of a shared topic
- Reference exact configs, files, or code paths where possible
- Include examples (shared/global feature-flag source, externalized topic-name resolution, coordinated cutover signaling, shared consumer-group and offset strategy)

Focus specifically on:
- Topic sharing surface: which topics does this service produce to and consume from, and what evidence (shared topic names, shared schemas/contracts, shared config, cross-team references) indicates a topic is also used by an external service?
- Cutover signaling: how would an external producer or consumer of the same topic learn that failover has occurred and that it must switch topics - a shared control plane, a global feature-flag service, GLB/DNS signal, or manual runbook?
- Feature-flag scope: is the flag a single shared source of truth consumed by all topic peers, or does each service own an independent flag? Independent, uncoordinated flags are a split-brain risk
- Split-writes / split-brain: what happens if a subset of producers writes to the region-local writable topic while others write to the promoted mirror topic, and where would events be lost, fragmented, or duplicated?
- Topic-name resolution: does this service hard-code topic names, or resolve them from shared config that topic peers also use? Mismatched naming breaks coordinated cutover
- Consumer coordination: shared vs independent consumer groups across services, offset ownership, and offset synchronization for a shared topic across regions
- Ordering and idempotence across services on a shared topic during and after cutover
- Ownership and runbook: is there a defined owner and runbook for coordinating cutover of a shared topic across all of its producers and consumers?
- Assumptions that this service is the only producer or the only consumer of a topic
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
