---
description: "Reorders resiliency assessment findings into a GLB-first sequential order"
argument-hint: "assessmentFile=path/to/assessment.md"
---

# Reorder Assessment Findings

You are reordering findings in a resiliency assessment so each priority tier is
sequential and GLB health-probe issues appear first in the P0 section if it appears in the findings.

Input file: ${input:assessmentFile}

## Method

Follow these steps in waves:

1. Wave 1 - Inventory and plan:
   * Parse every H4 finding matching the pattern `#### P0-001: ...` through P3.
   * Capture each complete finding block and every reference to its ID.
    * Identify every finding that directly addresses the GLB, Front Door,
       `/healthz`, readiness, or health-probe configuration across all tiers.
    * Plan those findings for promotion to the top of P0 before assigning any
       new IDs.
   * Build the full old ID to new ID mapping before editing.
2. Wave 2 - Promote GLB findings and order P0:
    * Move all direct GLB health-probe findings identified in Wave 1 to the top
       of P0, regardless of their original tier.
   * Order that group by dependency: truthful readiness signal first, GLB probe
     and routing configuration second, then supporting integration findings.
    * Place the remaining P0 findings after that group in their current relative
       order.
    * Renumber P0 sequentially from `001` with no gaps or duplicates.
3. Wave 3 - Order the remaining P1, P2, and P3 findings without further tier
    promotion. Preserve their relative order and renumber each tier
    sequentially from `001` with no gaps or duplicates.
4. Wave 4 - Synchronize and validate:
   * Update every old finding ID in cross-references, tables, summaries, links,
     and Notes using the completed mapping.
   * Update tier counts in headings and summaries when needed.
   * Confirm every finding appears exactly once and every finding-ID reference
     resolves to an existing heading.

Complete and validate each wave before starting the next one.

## Rules

* Reorder complete finding blocks. Do not split a finding from its body.
* Preserve each non-GLB finding's tier. Direct GLB health-probe findings are the
   only findings promoted to P0.
* Preserve every finding's title, evidence, code blocks, recommendation, Notes,
   and prose exactly. Change only order, IDs, references, links, and counts.
* Do not merge, delete, or create findings.
* Classify a finding as GLB health-probe work only when its title, Issue, or
  Recommended Fix directly addresses the GLB, routing probe, readiness endpoint,
  or health signal. A passing mention of GLB is insufficient.
* Apply the ID mapping atomically so an old ID cannot collide with a new ID.
* Do not edit cited source files.

## Deliverables

1. A Markdown mapping table:

   | Wave | Old ID | New ID | Title | Move Reason |
   |------|--------|--------|-------|-------------|

2. A one-line summary of findings reordered and references updated.
3. Validation results for sequential IDs, unique findings, and resolved
   cross-references.
