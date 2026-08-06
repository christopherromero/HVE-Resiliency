---
description: Assemble section fragments, resolve overlaps, reconcile finding IDs, set status once, and build the Section 9 index for the consolidated resiliency research document
agent: "Task Researcher"
argument-hint: "[manifestPath=...] [consolidatedDocPath=...] [verifyReports=...]"
---

# HVE Resiliency Consolidate 9 - Finalize

Follow the [Consolidation Shared Contract](../../instructions/hve-resiliency-consolidation-shared.instructions.md) for the manifest contract, sanitization, line-number integrity, the Required Finding Schema, schema-safe values, and evidence-only prohibitions. This prompt closes the pipeline: it assembles fragments into the consolidated document, resolves cross-section overlaps, reconciles IDs, sets terminal status exactly once, and builds the Section 9 index.

## Inputs

* ${input:manifestPath}: (Optional) Workspace-relative path to the frozen manifest sidecar emitted by the scaffold prompt. When omitted, auto-locate it per the Manifest Auto-Location rule in the Consolidation Shared Contract.
* ${input:consolidatedDocPath}: (Optional) Path to the consolidated scaffold document to finalize. Defaults to the manifest's companion document.
* ${input:verifyReports}: (Optional) Paths to the Section 1-4 and Section 5-8 verify audit reports; used to aggregate per-section signals for status.

## Scope

Read the frozen manifest, the consolidated scaffold document, all section fragment files (`sections/section-1.md` through `section-8.md`), and any supplied verify reports. Do not re-run discovery and do not read source artifacts except for a single bounded corrective reread tied to a named verification defect.

## Finalize Protocol

1. Assemble each section fragment into its reserved placeholder in the scaffold, in Section 1-9 order.
2. Run an index-level dedup reconciliation pass across the assembled fragments to catch any cross-section duplicate finding on the shared canonical-tuple identity, before numbering.
3. Apply the deterministic section-precedence tie-break when the same canonical tuple appears in more than one fragment: Section 7 retains any secret finding; otherwise the lowest section number retains the finding; Section 8 provisional residual candidates are dropped whenever any of Sections 1-7 already claimed the tuple. This preserves the invariant that each finding renders in exactly one section.
4. Sort retained findings by section number, then priority P0 through P3, then dependency or category, scenario, normalized evidence path and line, and record ID. Reconcile section-scoped IDs (`F-<section>-00X`) into the authoritative sequential `F-00X` scheme in this sorted order.
5. Apply the conflict matrix, then set exactly one terminal status by precedence:
   * `Blocked` for a missing, unreadable, or empty research root; any required prompt ID with zero admitted candidates; unsafe evidence; required artifacts that are unreadable, malformed, or fail body-schema validation; disagreement on repository identity; or any unresolved required conflict.
   * `Incomplete` only for missing, rejected, unreadable, unresolved, or hard-limit-truncated applicable optional artifacts or records after required core coverage succeeds, or unresolved optional conflicts, when no `Blocked` condition exists.
   * `Complete` only after every fragment is assembled, every retained record has a terminal disposition, no conflicts remain, all citations validate, and the Section 9 index reconciles.
   Accepted applicable service artifacts and permitted nullable prose values remain compatible with `Complete`.
6. Build Section 9 Research Findings Index with columns `Finding ID | Priority | Category | Short Description | Evidence (File:Line)`; include source record IDs in the `Evidence (File:Line)` cell. Every index entry maps to exactly one rendered finding.
7. Update the Assessment Scope header: set `Consolidation Status`, `Status Reasons`, `Coverage`, and `Processing Metrics` (candidates, accepted, normalized, rendered, duplicates, citation results, conflicts, hard-limit state).
8. Run one final bounded verification pass; permit at most one corrective render for a named defect, then stop.

## Output

Write the assembled, numbered, status-set consolidated document to `consolidatedDocPath`. Do not add assessment domains or additional numbered sections.

## Completion

Report the terminal status with reasons, coverage and processing metrics, the reconciled finding count, and the Section 9 entry count. End with a next-step suggestion to run `/hve-resiliency-planner-0`.
