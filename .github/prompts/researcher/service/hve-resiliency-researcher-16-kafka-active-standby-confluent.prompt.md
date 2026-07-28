
---
description: Run Prompt 16 Kafka Active-Standby-Confluent resiliency analysis
agent: Task Researcher
---
# HVE Resiliency Researcher 16 Kafka Active-Standby-Confluent

Use [Resiliency Research Platform Context](../../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
You are analyzing an application that produces to and/or consumes from Kafka deployed in a multi-region active-standby architecture with:
- Independent Kafka clusters per region
- One active cluster serving application traffic and one standby cluster available for regional failover
- Confluent Kafka already deployed and managing cross-region replication, Cluster Linking, mirror topics, consumer offset synchronization, cluster promotion, and failover
- Application configuration selects the available cluster through bootstrap endpoints; the application does not orchestrate Kafka platform failover
- Kafka clients must reconnect, refresh metadata, and resume producer and consumer activity when the active cluster flips
- Apache Kafka client version 3.8 or later is the minimum supported application client
- Confluent Cluster Linking documentation is the authoritative platform reference: https://docs.confluent.io/platform/current/multi-dc-deployments/cluster-linking/index.html

Analyze this codebase and configuration for application region resiliency.

The application's behavior before, during, and after the managed cluster flip is the central design detail. Do not assess Confluent provisioning or operations. Treat managed replication, promotion, mirror-topic state, and offset synchronization as fixed architecture assumptions. Use repository evidence to assess only how application clients interact with that platform behavior. Where the repository does not prove a required behavior, record the missing evidence or explicit assumption as an application risk. Do not create findings solely because Confluent operational configuration is absent from the application repository under the selected architecture. Every finding must be evaluated against these invariants:
- Code and configuration must bootstrap to the available cluster without hard-coded broker, IP, region, credential, or startup-only assumptions
- Producers must tolerate disconnects and uncertain delivery outcomes without losing messages or creating duplicate business effects
- Consumers must resume from the correct synchronized consumer-group position and tolerate replay, rebalance, duplicate delivery, and delayed records
- Retry, reconnect, timeout, metadata refresh, health, and backpressure behavior must tolerate the complete cluster-flip window without unsafe failure or manual recovery
- Application processing must remain correct when the managed platform preserves offsets but asynchronous replication leaves a recoverable lag or overlap
- Clients must not cache or hard-code broker-specific host:port addresses learned from cluster metadata; reconnect and metadata refresh must re-resolve through the bootstrap endpoint after a cluster flip rather than reusing stale direct-broker connections

Your output MUST include:
1) Gaps vs Active-Standby Application Design
- Identify application code and configuration that prevents safe bootstrap, disconnect handling, reconnect, resume, replay, or recovery after a cluster flip
- Call out hard-coded brokers, single-cluster assumptions, startup-only configuration, Kafka clients earlier than 3.8, unstable consumer-group identifiers, unsafe offset policies, or retry exhaustion
- Highlight producer delivery, consumer processing, duplicate-message handling, message-loss tolerance, connection recovery, offset continuity, and cluster-flip risks
2) Application-Level Assessment Evidence
- Identify exact configs, files, dependencies, classes, functions, and code paths that establish or weaken application failover behavior
- Distinguish application findings from fixed Confluent-managed platform assumptions
- Record existing mitigations, constraints, and unverified assumptions without assessing or redesigning the managed Kafka platform
3) Database-to-Kafka Pairing Alignment
- Identify the application's confirmed database resiliency model (for example Cosmos DB multi-region/multi-master writes vs Azure SQL single-master writes) from repository evidence or prior Prompt 12/13 research output
- Per the Database-to-Kafka Pairing Standard, an Active-Standby Kafka topology is expected to pair with an Active-Standby (single-master) database, or with an application that uses both an Active-Active and an Active-Standby database; flag a repository confirmed to use only an Active-Active (multi-master) database as a pairing mismatch, since that combination is expected to pair with the Kafka Active-Active prompt instead

Focus specifically on:
- Kafka bootstrap and DNS usage, including hard-coded brokers, cached IP addresses, endpoint refresh, region-specific settings, and startup-only client construction
- `advertised.listeners`-driven metadata caching: after the initial bootstrap connection, clients cache broker-specific addresses returned by cluster metadata; verify the application refreshes this metadata rather than persisting or reusing stale broker addresses that bypass the bootstrap endpoint after a cluster flip
- Kafka client version: verify direct and transitive runtime dependencies use Apache Kafka client version 3.8 or later
- Cluster flip tolerance: can producers, consumers, stream processors, admin clients, schema clients, and health checks recover without restart, redeployment, manual configuration, or cache clearing?
- Producer idempotence, acknowledgement settings, delivery callbacks, retry safety, local buffering, flush behavior, ambiguous send outcomes, and message-loss tolerance
- Consumer offset commit timing, stable group identity, synchronized-offset use, reset policy, replay tolerance, partition revocation, rebalance behavior, and duplicate-message handling
- Connection recovery: reconnect backoff, retry backoff, request timeout, delivery timeout, metadata refresh, retry limits, exhaustion behavior, cancellation, and exception handling
- Runtime cutover readiness: identify configuration or routing state loaded only at startup or cached for the process lifetime
- Duplicate/idempotent processing when records are retried, replayed, redelivered, or consumed again after a failover or rebalance
- Message loss dependencies: identify fire-and-forget sends, ignored failures, premature success, unsafe shutdown, commits before processing, and unhandled offset gaps
- Replication-lag tolerance: identify workflows that assume the standby has every latest record immediately when platform failover completes
- Event ordering dependencies: identify workflows, state transitions, or transactions that cannot tolerate delayed, replayed, duplicated, or out-of-order events
- Non-idempotent operations: identify business side effects that can create duplicate outcomes when processing is retried or resumed
- Schema, authentication, and authorization dependencies that use cluster-specific endpoints, credentials, certificates, trust stores, principals, ACLs, or cached state
- Backpressure and catch-up behavior, including bounded queues, poll starvation, max poll intervals, memory growth, dropped work, and downstream overload
- Application lifecycle behavior: inspect startup, dependency injection, singleton ownership, background worker cancellation, graceful shutdown, readiness transitions, and whether transient Kafka failures terminate the process, trigger restart loops, or leave producers and consumers permanently stopped
- Transaction and downstream consistency: inspect database writes, external API calls, Kafka transactions, outbox or inbox patterns, commit boundaries, poison-message handling, dead-letter behavior, and partial completion when a cluster flip interrupts in-flight work
- Failback and regional recovery behavior after the failed region returns, including reconnection, replay, offset continuity, backlog processing, and restored steady-state processing
- Configuration symmetry between West US and West US 2 for bootstrap endpoints, topics, group IDs, retry policies, credentials, client versions, and observability
- Database-to-Kafka pairing: does the repository's confirmed database resiliency model (single-master vs multi-master) match the Active-Standby Kafka topology assumed by this prompt?
- Are health probes aligned between GLB, application readiness, Kafka connectivity, and downstream processing health?

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
