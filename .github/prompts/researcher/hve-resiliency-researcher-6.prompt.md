---
description: Run Prompt 6 shared and cross-repository dependencies for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 6

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt - Shared & Cross-Repository Dependencies

You are acting as a Senior Cloud Application Architect performing a resiliency assessment for a microservice.

## OBJECTIVE
Identify shared libraries, platform utilities, or centrally managed configuration
used by this repository that may introduce cross-repository
zone or region failover risk.

Cite evidence and note ownership boundaries.
For each shared dependency, record existing mitigations already present (fallbacks, retries, feature flags, operational controls), with evidence.
For each shared dependency, record constraints/limitations (ownership boundaries, deployment coupling, region pinning, required manual steps, or platform limits) that affect zone/region failover, with evidence when present.
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.