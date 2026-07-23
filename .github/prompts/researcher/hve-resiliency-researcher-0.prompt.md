---
description: Run Prompt 0 repository context frame for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 0

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt - Repository Context

You are acting as a Senior Cloud Application Architect performing a resiliency context assessment for a microservice.

## OBJECTIVE
Systematically examine the repository's source code, configuration files, infrastructure-as-code templates, and dependency manifests to understand the application's architecture and resiliency posture.

Region context (name the two active/active regions; do not use primary/secondary role labels):
- **West US** - one of the two active/active regions (currently the production region)
- **West US 2** - the other active/active region (the peer being added)
- The application is transitioning from an active-passive (DR) posture - a single-region production deployment in West US with West US 2 as a passive disaster recovery target - to an active/active deployment across West US and West US 2. Failover is symmetric: either region can absorb the other's traffic.

Validate readiness for:
- Zone failure within either region
- Full active/active regional failover between West US and West US 2 in either direction (West US to West US 2 and West US 2 to West US)

Begin by analyzing the application architecture for this code base, then characterize current implementation behavior, application flow, assumptions, constraints, the risks, why each is a risk to application resiliency during a zone or region failover, and the impacts if not changed.

Analyze region, zone, and application failover risk for each gap/finding:
- P0 - Blocking/Critical Risk
- P1 - High Priority (Potential for Blocking)
- P2 - Improvement/Best Practice (Non-Blocking)
- P3 - Non-Blocking Code Consistency (Best Practices / Maintainability)
- Provide an explanation why each issue is rated at that level
- Identify the area in the code where the issue is located (file + line #)

Capture existing mitigations already present (retries/timeouts/fallbacks/feature flags/runbooks), with evidence (file + line).
Capture constraints/limitations that affect failover (platform constraints, dependency capabilities, configuration constraints, operational constraints), with evidence (file + line) when present.
If the repository does not contain infrastructure-as-code or deployment configuration, explicitly note which resiliency aspects cannot be assessed from the codebase alone and flag them as requiring external validation.
Do not recommend changes.

## OUTPUT FORMAT
Produce the output as the following numbered sections, in this order:
1. Architecture Overview - application walkthrough and high-level architecture for this microservice.
2. Findings - table with columns: ID, Description, Priority (P0-P3), File, Line, Explanation.
3. Existing Mitigations - table with columns: ID, Mitigation, File, Line, Notes.
4. Constraints/Limitations - table with columns: ID, Constraint, Category, File, Line, Notes. Include rows for aspects that cannot be assessed from the codebase alone (mark Category as "External validation required").
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.