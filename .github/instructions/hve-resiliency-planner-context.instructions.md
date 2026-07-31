---
description: Planner and assessment-builder context, evidence lock rules, resiliency classification, source fidelity, and report-generation guidance
applyTo: '.github/prompts/planner/hve-resiliency-planner-*.prompt.md, .github/prompts/assessment-builder/hve-resiliency-assessment-builder-*.prompt.md'
---

## HVE Resiliency Planner and Assessment Context

Apply this context to all HVE resiliency Task Planner and assessment-builder prompts.

### Core Contract

The consolidated research artifact is the immutable source of truth.

Planner and assessment-builder prompts must:

- Treat the consolidated research artifact as fixed evidence.
- Use canonical finding IDs exactly as provided by consolidation.
- Inherit priority, resiliency classification, confidence, evidence, mitigations, constraints, and evidence gaps from consolidated research.
- Never create new findings.
- Never promote evidence gaps into findings.
- Never change P0/P1/P2/P3 severity unless the user explicitly instructs a manual correction after engineer review.
- Never invent file paths, line numbers, code identifiers, counts, owners, regions, dependencies, or failover behavior.
- Use repository source only to verify cited code blocks, identifiers, and counts when a prompt has repository read access.
- Do not reinterpret service scope. Use the scope decisions from consolidated research.

### Inputs

Planner and assessment-builder prompts may read:

- The authoritative consolidated research artifact at `.copilot-tracking/research/YYYY-MM-DD--research.md`.
- Planner outputs in `.copilot-tracking/plans/`.
- Assessment-builder outputs in `Microsoft Assessment/`.
- Static report templates, if the assessment-builder prompt references them.
- Cited source files only when needed to verify verbatim code, identifiers, or counts.

Do not read source files to discover new findings.

### Default Engagement Context

Default architecture profile:

- Default target: multi-region active-active between West US and West US 2.
- Default failover controller: GLB or equivalent global routing layer.
- Default health model: services expose health or readiness signals used by routing or operational decisions.
- Default code ownership: customer developers own code changes.
- Default deliverable posture: reports must be actionable enough for customer developers to implement independently.

### Architecture Profile Overrides

The default active-active profile applies unless consolidated research declares a service-specific target architecture.

Examples of service-specific override profiles:

- Kafka Active-Standby: use active-standby terminology, not active-passive. Evaluate DNS bootstrap failover, client reconnect, offset continuity, duplicate processing, and standby readiness.
- Kafka Active-Active: evaluate mirror-topic plus consumer feature-flag architecture.
- Azure Storage: active-active writes in West US and West US 2 are the target when research says so.
- Azure Functions: detect active-active, active-standby, warm standby, single-region, or unknown posture from evidence.
- APIM, App Gateway, Networking, AKS/Istio, Key Vault, SQL, Cosmos DB, Redis, Entra ID, and other services: use the service-specific posture and constraints recorded in research.

Do not force every service into active-active wording when research identifies a different target architecture.

### Region Naming Rule

For default active-active outputs:

- Use West US.
- Use West US 2.
- Use Both regions for symmetric requirements.
- Avoid primary/secondary terminology unless quoting source evidence or describing a service-specific architecture that requires role labels.

For service-specific profiles:

- Use the terminology from consolidated research.
- Use Active-Standby for Kafka active-standby.
- Use active-active only when the research artifact says the service target is active-active.

### Prose Conventions

Apply these conventions to all planning and assessment output:

- Do not use em dashes or en dashes. Use a hyphen, colon, comma, or separate sentence.
- Avoid decorative contrast such as "not X, but Y" unless the distinction is required.
- Avoid redundant classification tails. If a finding is in the Non-Resiliency section, do not append phrases such as "not a runtime resiliency one."
- Use concise, engineering-focused language.
- Separate evidence, impact, and recommendation clearly.
- Keep customer-facing language professional and actionable.

---

## Resiliency Classification

### Generalized Litmus Test

Ask:

"Does this issue affect the target resiliency architecture recorded in consolidated research?"

The target may be default active-active, Kafka Active-Standby, Kafka Active-Active, Storage active-active writes, or another service-specific architecture.

- If yes, the issue is resiliency-related.
- If no, the issue is non-resiliency unless consolidated research already classifies it otherwise.
- If the answer is unclear, preserve the classification from consolidated research. Do not reclassify.

### Resiliency Impact Statement

Every resiliency finding must articulate:

- Triggering failure scenario.
- Observed or expected behavior from research.
- Impact on failover, zone survival, regional operation, data correctness, duplicate processing, customer access, or recovery.
- The affected capability or workflow.

Use this pattern:

"If [condition from research] occurs during [failure scenario], then [impact] can occur, which affects [business or technical capability]."

Do not write "your logic is broken" or "you need to fix this" as the primary explanation.

### Evidence Gap Rule

Evidence gaps are not findings.

Planner and assessment-builder prompts may include evidence gaps in an "Evidence Gaps" or "Assessment Constraints" section, but must not:

- Assign P0/P1/P2/P3 to evidence gaps.
- Convert evidence gaps into remediation items unless the Planner clearly labels them as validation work.
- Count evidence gaps as findings.

---

## Priority Definitions

Use the priority from consolidated research as authoritative.

If a prompt must restate priority definitions, use the following:

### P0 - Failover-Blocking or Critical Resiliency Risk

A P0 finding blocks the target resiliency architecture, renders the failover design ineffective, causes outage, creates unsafe failover, creates unrecoverable data loss, causes duplicate irreversible business action, or keeps traffic routed to an unsafe region.

### P1 - Material Resiliency Gap

A P1 finding materially degrades the target resiliency architecture but does not fully block it. Workarounds, manual recovery, lower blast radius, detectability, or reversibility may exist.

### P2 - Non-Blocking Resiliency Improvement

A P2 finding improves resiliency, observability, testability, or operational confidence but does not prove failover blockage or material data/customer risk.

### P3 - Maintainability or Consistency

A P3 finding is naming, documentation, consistency, duplication, cleanup, or maintainability with no proven functional failover impact.

### Severity Guardrails

- A finding marked Resiliency Related: No must never be P0 or P1.
- Missing documentation alone is not P0 or P1.
- Generic best practices are not P0 or P1 unless failover impact is directly evidenced.
- Security-only items are not P0 or P1 unless research proves resiliency or availability impact.
- Planner must not invent a prerequisite finding that does not exist in research. If a recommendation has a prerequisite, attach it to the existing canonical finding or mark it as an implementation dependency.

### Ordering Rule

Order findings and recommendations by:

1. P0
2. P1
3. P2
4. P3

Within each priority, preserve the ordering from consolidated research unless the prompt explicitly asks for grouping by service, component, or theme.

---

## Canonical Finding Contract

Every planner and assessment-builder output must preserve:

- Finding ID
- Title
- Priority
- Resiliency Related: Yes/No
- Confidence
- Source research artifact
- Evidence locations
- Existing mitigations
- Constraints
- Duplicate evidence locations, if any

Do not rename finding IDs.

Do not split one canonical finding into multiple findings.

Do not merge two canonical findings unless consolidated research already marks them as duplicates.

If a recommendation covers multiple findings, list all related canonical finding IDs.

---

## Confidence Inheritance

Use confidence exactly as provided by consolidated research.

Definitions:

- High: direct evidence proves behavior and failover impact.
- Medium: direct evidence proves behavior, but impact depends on a stated constraint.
- Low: partial evidence or limited visibility.

Planner may tailor recommendation detail based on confidence:

- High: produce direct remediation guidance.
- Medium: include assumptions and validation checks.
- Low: frame as validation-first work, not as a certain defect.

Do not upgrade confidence.

Do not use low-confidence findings to justify high-certainty claims.

---

## Source Fidelity and Evidence Verification

### Verbatim Current-Code Quoting

Any code presented as current or existing code must be a verbatim quote from the cited source file and line range.

Do not paraphrase, reformat, normalize, or reconstruct current code from memory or upstream summaries.

If repository read access is available, reopen the cited source before quoting.

If the cited source does not match the upstream artifact, correct the quote and note the discrepancy.

### Identifier Fidelity

Existing identifiers must match source exactly, including:

- Config keys
- YAML keys
- Environment variables
- Method signatures
- Function names
- Class names
- Bean names
- Annotation names
- Property names
- Topic names
- Consumer groups
- Endpoint names

Do not tidy, expand, abbreviate, rename, or normalize existing identifiers.

New identifiers introduced in fix examples must be clearly new.

### Count Fidelity

Any stated count must come from one of:

- Consolidated research artifact.
- Master plan.
- Fresh repository verification, if the prompt has repository access.

If counts disagree, stop and surface a count reconciliation note. Do not silently choose a number.

### Fix-Level Dependency Inversion

A P0 or P1 recommendation must not depend on a library, annotation, framework feature, or shared component introduced only by a lower-priority item.

If a recommendation requires a prerequisite:

- Use an existing finding if one exists.
- Raise the prerequisite in the same recommendation when research supports it.
- Otherwise state it as an implementation dependency, not a new finding.

---

## Planner Output Rules

Planner prompts may produce:

- Master plan
- Developer guide
- Remediation strategy
- Implementation sequencing
- Validation plan
- Testing guidance
- Backlog-ready work items

Planner prompts must not:

- Create new findings.
- Change canonical IDs.
- Reclassify severity without explicit human correction.
- Omit P0 or P1 findings unless the user explicitly asks for a scoped subset.
- Present evidence gaps as defects.
- Claim implementation certainty when confidence is Medium or Low.

### Recommendation Format

Each recommendation should include:

- Related Finding ID
- Priority
- Confidence
- Summary
- Evidence basis
- Recommended change
- Implementation notes
- Validation or test approach
- Dependencies or prerequisites
- Constraints

### Planning Sequence Guidance

Recommended planner sequence:

1. `/hve-resiliency-planner-0`
2. `/hve-resiliency-planner-1`
3. Review Master report
4. `/hve-resiliency-planner-2`
5. `/clear`
6. `/hve-resiliency-planner-3a`
7. `/clear`
8. `/hve-resiliency-planner-3b`
9. `/clear`
10. `/hve-resiliency-planner-3c`
11. `/clear`
12. `/hve-resiliency-planner-3d`

---

## Assessment-Builder Output Rules

Assessment-builder prompts create customer-facing report sections.

Assessment Builder must:

- Use consolidated research, Master plan, and Developer Guide as inputs.
- Preserve canonical finding IDs.
- Preserve severity and confidence.
- Reconcile counts before writing summary tables.
- Use anchor manifests or deterministic anchor rules when linking findings.
- Keep static reference tables or standard callouts in external templates when available.
- Clearly separate resiliency findings from non-resiliency findings.
- Include evidence gaps and constraints when relevant.

Assessment Builder must not:

- Discover new findings.
- Read source files for new analysis.
- Change severity.
- Inflate P2/P3 items into P0/P1.
- Duplicate findings across sections.

### Count Reconciliation Rule

Summary counts must reconcile to canonical findings.

If a count cannot be reconciled:

- Stop.
- Output a count reconciliation issue.
- Identify the conflicting artifacts.
- Do not publish the report section until corrected.

### Anchor Rule

Finding anchors must be deterministic:

1. Use canonical finding ID.
2. Use canonical title.
3. Lowercase.
4. Replace spaces with hyphens.
5. Remove punctuation.
6. Collapse repeated hyphens.

Do not generate separate anchors for duplicate evidence locations.

### Assessment Builder Sequence Guidance

The assessment-builder sequence is a legacy alternative to Planner 3a through 3d.
Do not run both report-generation workflows for the same assessment.

Recommended assessment-builder sequence:

1. `/hve-resiliency-assessment-builder-0`
2. `/clear`
3. `/hve-resiliency-assessment-builder-1`
4. `/clear`
5. `/hve-resiliency-assessment-builder-2`
6. `/clear`
7. `/hve-resiliency-assessment-builder-3`

---

## Architecture Constraints

Use architecture constraints only when supported by consolidated research.

Default active-active constraints:

- GLB or equivalent routing layer controls failover.
- Applications expose health or readiness signals used by routing or operations.
- Dependencies required for failover must exist in both regions or have an evidenced failover mechanism.
- Region-aware configuration must support the target architecture.
- Abstracted endpoints are preferred when the target architecture uses abstracted endpoints.

Service-specific constraints:

- Kafka Active-Standby uses active-standby wording, unified DNS/bootstrap, Confluent Cluster Linking, client reconnect, offset continuity, duplicate tolerance, and standby readiness when supported by research.
- Kafka Active-Active uses mirror-topic plus consumer feature-flag wording when supported by research.
- Azure Storage active-active write assessments must evaluate both-region writes, conflict handling, and failback safety when research identifies that target.
- Entra ID, Key Vault, APIM, App Gateway, AKS/Istio, Azure SQL, Cosmos DB, Redis, Networking, and Azure Functions must use their service-specific research constraints.

Do not impose constraints that the research artifact did not establish.

---

## Report Delivery Strategy

- Deliver reports in reviewable batches.
- Make P0 and P1 clearly distinguishable from P2 and P3.
- Map recommendations to validation or test scenarios when research supports it.
- Preserve evidence gaps and constraints so reviewers understand uncertainty.
- Treat reports as the permanent record for tracking.
- Expect customer prioritization discussions, but do not remove findings solely because they may be declined.

---

## Output File Naming Rule

Use the current repository name or user-supplied service name as the output prefix.

Do not hardcode customer names, repository names, or service names unless they come from the input artifacts.

Examples:

- `.copilot-tracking/plans/<repo-name>-Master.md`
- `.copilot-tracking/plans/<repo-name>-Developer-Guide.md`
- `Microsoft Assessment/<serviceName>-Code-Level-Resiliency-Assessment.md`

---

## Next Step Suggestions

After completing each planner or assessment-builder prompt, end with the next step.

Use this sequence:

| Current prompt | Next step |
|---|---|
| `/hve-resiliency-planner-0` | `/hve-resiliency-planner-1` |
| `/hve-resiliency-planner-1` | `/hve-resiliency-planner-2` |
| `/hve-resiliency-planner-2` | `Run /clear, then /hve-resiliency-planner-3a` |
| `/hve-resiliency-planner-3a` | `Run /clear, then /hve-resiliency-planner-3b` |
| `/hve-resiliency-planner-3b` | `Run /clear, then /hve-resiliency-planner-3c` |
| `/hve-resiliency-planner-3c` | `Run /clear, then /hve-resiliency-planner-3d` |
| `/hve-resiliency-planner-3d` | `Workflow complete` |
| `/hve-resiliency-assessment-builder-0` | `Run /clear, then /hve-resiliency-assessment-builder-1` |
| `/hve-resiliency-assessment-builder-1` | `Run /clear, then /hve-resiliency-assessment-builder-2` |
| `/hve-resiliency-assessment-builder-2` | `Run /clear, then /hve-resiliency-assessment-builder-3` |
| `/hve-resiliency-assessment-builder-3` | `Workflow complete` |

### Required Review Notice

Every planner and assessment-builder artifact must be reviewed by a qualified engineer before it is shared, acted on, or treated as authoritative.

AI-assisted output may contain inaccuracies, omitted evidence, misclassified priorities, fabricated citations, or internal inconsistencies.

Validate every claim against cited file and line references. Confirm scope decisions, reconcile contradictions, and correct errors before delivery.