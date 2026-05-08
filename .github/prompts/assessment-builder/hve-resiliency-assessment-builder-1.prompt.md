---
agent: Task Planner
description: "Appends Section 2 P0 and P1 Resilient Focused Recommendations to the Code-Level Resiliency Assessment report"
argument-hint: "serviceName=..."
---

# Resiliency Report Generator — Part B: P0 and P1 Findings

Use [Resiliency Task Planner Context](../../../instructions/hve-resiliency-planner-context.instructions.md).

## Inputs

* ${input:serviceName}: (Required) Service name matching the repo name.

## Source Artifacts

Read **only** the following before generating. Keep context minimal.

* `.copilot-tracking/plans/` — locate `{serviceName}-Master.md`. Read the P0 and P1 sections only (skip P2, P3, Open Questions, and External Provider Considerations).
* `.copilot-tracking/plans/` — locate `{serviceName}-Developer-Guide.md`. Read the P0 and P1 sections only (skip P2 and P3). This is the primary source for all code blocks.
* `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` — read the existing file to understand the current state and append after the last line.

Do **not** read the consolidated research, subagent files, or the Developer Guide P2/P3 sections for this prompt.

## Critical Context

This report serves an application transitioning from a single-region deployment with a passive DR target to an active/active deployment across two regions. Use the classification rules from `hve-resiliency-planner-context.instructions.md` for all priority assignments.

All section headers, H3 group names, finding titles, and repo references must use `{serviceName}` (the repo name), not hardcoded service names.

## Region-Agnostic Language Rule

The generated report must use region-agnostic terms throughout. Never reference specific Azure region names. Use:

* **Primary region** — the current production region
* **Secondary region** or **failover region** — the target active/active peer
* **Both regions** — when referring to symmetric requirements

In code examples and fix blocks, use placeholder values like `{primaryRegion}`, `{secondaryRegion}`, or generic names rather than region-specific hostnames.

## What to Generate

**Append** the following to the existing `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` file. Do not overwrite or regenerate the header or Section 1.

### Section 2 — Resilient Focused Recommendations (P0 and P1 only)

Begin with `# 2. Resilient Focused Recommendations`.

This prompt generates **only P0 and P1** findings under Section 2. P2 and P3 resiliency findings will be added by the next prompt (3c).

#### Hierarchy

* **H2** — priority block with finding count: `## P0 — Critical Resiliency Risks (N)` and `## P1 — High Priority Resiliency (N)`.
* **H3** — shared-service group derived from findings: `### Azure SQL / Data Integrity`, `### Azure Key Vault / Secrets Sync`, `### Deployment Infrastructure / CI-CD`, `### Health Probes / GLB Readiness`, `### Resilience Patterns / Connection Management`, `### Shared Dependencies / Cross-Team Coordination`, `### AKS / Pod Lifecycle`, etc. Use generic names; do not hardcode vendor names in H3 headings. Derive group names from the actual dependency categories found in the Master Report.
* **H4** — individual finding: `#### P0-001: Short Title`

#### Finding ID Assignment

Use the `PX-NNN` IDs from the Master Report **directly and unchanged**. Do not renumber.

* The `PX-NNN` namespace is **per priority tier** and **shared across Section 2 (Resilient) and Section 3 (Non-Resilient)**. Section assignment is driven by the active/active litmus test (`Resiliency Related: Yes` → Section 2; `No` → Section 3); it does **not** reset or partition the numbering.
* All P0 and P1 findings are `Resiliency Related: Yes` by definition, so every P0 and P1 ID appears under Section 2 in this prompt. The P0 and P1 sequences therefore run contiguously here (e.g., `P0-001`, `P0-002`, … then `P1-001`, `P1-002`, …).
* P2 and P3 IDs continue this same per-priority sequence in the next prompt (`assessment-builder-2`), split between Section 2 and Section 3 by the litmus test. Example: if a P2 finding is `P2-003` in the Master Report, it stays `P2-003` regardless of which section it lands in.

#### Individual Finding Template

Every P0 and P1 finding uses this exact format (field order must be preserved):

1. `#### PX-NNN: Short Title` — H4 heading
2. `**Priority: PX — {Priority Label}**` — on its own line
3. `**Resiliency Related:** Yes`
4. `**Issue:**` — description of the problem. For P0/P1: explain how the issue is introduced or worsened by the transition from single-region to active/active.
5. `**What does this solve:**` — one sentence, the outcome achieved
6. `**Resiliency Impact:**` — 1–3 sentences framed in terms of zone failure or regional failover impact
7. `**Recommended Fix:**` — concrete narrative action, specific enough for the application's developers to implement independently
8. `**File:** file/path.ext:line` — followed by a fenced code block with the current problematic code (must include a language identifier). Pull from Developer Guide.
9. `**Fix:**` — followed by a separate fenced code block with the corrected implementation (must include a language identifier). Pull from Developer Guide.
10. `**Notes:**` — context, rationale, or implementation guidance
11. `<span style="font-size: 14px;">**MSFT Reference:** [Pattern Name](URL)</span>` — when a WAF pattern or Azure guidance page applies

Priority labels:

* P0: `Failover-Blocking Risk`
* P1: `Multi-Region Resiliency Gap`

#### Finding Rules

* Separate findings with `---` (horizontal rule).
* Always use **two separate** fenced code blocks — one under `**File:**` and one under `**Fix:**` — each with a language identifier (`java`, `yaml`, `properties`, `sql`, `xml`, `dockerfile`, `text`). Pull samples from the Developer Guide. Never combine both into one block.
* For findings that are infrastructure/coordination items with no code, use `**File:**` with the relevant Helm values or config and `**Fix:**` with the target state.
* Configurable values in code use `// e.g., 3` comments.
* `Resiliency Related: Yes` for all P0 and P1 findings.
* `What does this solve` is required on all findings, one sentence.
* `Resiliency Impact` is required on all findings.
* Include MSFT Reference when a WAF pattern or Azure guidance page applies.
* When a finding references cross-dependencies to other findings, use the `PX-NNN` format.

#### Ending

Do **not** add `[Back to Top](#top)` at the end of Section 2 yet — that will be added by `assessment-builder-2` after P2/P3 findings are appended.

## Formatting Conventions

* Aligned pipe tables — all pipes vertically aligned across all rows.
* Blank lines before and after tables, code blocks, headings, and lists.
* `---` horizontal rules between individual findings within a group.
* `**Priority: PX — Label**` on its own line (no `| Repos:` inline).
* All code blocks have a language identifier.
* Inline code for env vars, function names, file paths, and config keys.
* All repo references use `{serviceName}`, never a hardcoded service name.
* No references to specific Azure region names.

## Output Location

**Append** to the existing file at:

`Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`

Do not overwrite the existing content.

## Next Step

After completing this prompt:

> **Next step:** Run `/clear`, then `/hve-resiliency-assessment-builder-2`
