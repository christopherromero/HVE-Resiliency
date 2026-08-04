---
description: Deprecated - the monolithic Prompt 7 Logging has been split into a scaffold-fill-verify-finalize pipeline. Redirects to the new scaffold entry point.
agent: Task Researcher
---

# Application HVE Researcher 7 Logging (Deprecated Redirect)

The single monolithic `hve-resiliency-researcher-7-logging` prompt has been replaced with a bounded, staged pipeline that mirrors the split Researcher 5 and split consolidation pipelines. Run the new pipeline instead. Do not attempt to reconstruct the prior schema or run any evidence collection from this file.

## Pipeline Entry

The new pipeline is:

1. `/hve-resiliency-researcher-7-logging-0-scaffold` - validate Prompt 1a and 1b Section 1 prerequisites, freeze the eligible-dependency inventory, freeze payment applicability, and emit the Prompt 7 skeleton plus a frozen manifest sidecar.
2. `/hve-resiliency-researcher-7-logging-1-startup-health` - fill the startup, readiness, liveness, dependency-health, retries, and capacity fragment.
3. `/hve-resiliency-researcher-7-logging-2-transactions` - fill the transaction and payment lifecycle fragment.
4. `/hve-resiliency-researcher-7-logging-3-correlation-context` - fill the inbound correlation, log context, and propagation fragment.
5. `/hve-resiliency-researcher-7-logging-4-log-hygiene` - fill the log structure, redaction, secrets, and PII fragment.
6. `/hve-resiliency-researcher-7-logging-5-silent-outage-diagnostics` - fill the health-diagnostics and silent-outage detection fragment.
7. `/hve-resiliency-researcher-7-logging-verify` - audit the five category fragments against the manifest and workspace source.
8. `/hve-resiliency-researcher-7-logging-finalize` - assemble the fragments into the single Prompt 7 research artifact, build the Section 3 planning handoff, and set the pipeline status once.

The shared contract for the split pipeline is defined in [Researcher 7 Logging Split Contract](../../instructions/hve-resiliency-researcher-7-logging-split.instructions.md). Platform inheritance is unchanged and continues to come from [Application Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

Do not render inventory rows or findings from this file. Do not read Prompt 1a or Prompt 1b from this file. Do not modify any downstream fragment, manifest, skeleton, or verify audit from this file.

## Completion

Report that the monolithic Prompt 7 Logging is deprecated and direct the operator to the pipeline entry point.

> **Next step:** Run `/clear`, then `/hve-resiliency-researcher-7-logging-0-scaffold`
