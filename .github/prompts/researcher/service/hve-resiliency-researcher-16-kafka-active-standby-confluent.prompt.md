
---
description: Run Prompt 16 Kafka Active-Standby-Confluent resiliency analysis
agent: Task Researcher
---
# HVE Resiliency Researcher 16 Kafka Active-Standby-Confluent

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
Context:

The application is currently deployed in a single-region setup in West US.

Target Architecture:

- Primary Region: West US2
- Secondary Region: West US
- The application is being redesigned for multi-region resiliency.
- Confluent Kafka will run on VMs in both regions and will be configured in an Active-Standby topology.
- Primary Kafka topics will be hosted in West US2.
- Topics will be replicated to West US using Confluent Cluster Linking.
- Use Confluent Kafka and Confluent Cluster Linking documentation as the authoritative sources for platform and replication guidance.
- Do not recommend Apache Kafka platform replication features, Apache Kafka MirrorMaker, or MirrorMaker 2. Do not propose replacing Confluent Cluster Linking with another replication mechanism.
- A unified DNS endpoint will be placed in front of both Kafka clusters.
- Applications will connect only to the DNS endpoint and not to region-specific Kafka brokers.
- During a regional failover, the platform team will perform the DNS switch.
- The expectation from the target design is that failover is transparent to applications with no application-level routing changes required.
- Kafka client version 3.8 or later is required. If the application uses an earlier version, assess the impact and recommend the necessary upgrade actions.

Assessment Objective:

Analyze the application codebase, configuration, infrastructure dependencies, and runtime behavior to determine the application's readiness for the target Kafka Active-Standby multi-region architecture.

As part of the assessment:

- Identify all application code, configuration, dependency, connectivity, resiliency, deployment, monitoring, and operational changes required to support the target multi-region architecture.
- Assess whether the application can seamlessly handle Kafka DNS failover without code changes.
- Validate Kafka producer and consumer behavior during failover scenarios.
- Review the consumer implementation and determine whether message processing is idempotent.
- If the consumer is not idempotent, classify the finding as P2 and recommend the required code and design changes to make message processing idempotent and resilient to duplicate message delivery during failover and recovery scenarios. This finding must be rated P2 regardless of the general priority criteria below.
- Identify risks, assumptions, limitations, and dependencies that could impact regional failover and recovery.
- If the application is not using Kafka client version 3.8 or later, recommend the required upgrade along with the code, configuration, testing, and deployment changes needed.

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
