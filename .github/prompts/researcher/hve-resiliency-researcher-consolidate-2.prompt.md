---
description: Consolidation Part C - append Shared Dependencies, Hard-coded values, Other findings, and the authoritative Research Findings Index, then run the quality bar
agent: Task Researcher
---

# HVE Resiliency Researcher Consolidate - Part C (Sections 6-9)

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

Run `/hve-resiliency-researcher-consolidate-0` and `/hve-resiliency-researcher-consolidate-1` first. This pass finishes the research file and is the final consolidation step before Phase 4 (Planning).

```text
# HVE Task Researcher Prompt - Consolidation Part C (Sections 6-9 and Index)

You are acting as a Senior Cloud Application Architect completing the final consolidation of resiliency research.

## OBJECTIVE

Append Sections 6 through 8, then the authoritative Research Findings Index (Section 9), to the existing research file, and run the quality bar. After this pass the research file is complete and ready for the Planner.

Read first:
- `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-findings-manifest.md` - the authoritative finding IDs, groups, and target sections.
- `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-research.md` - the research file with Sections 1-5 already written (do NOT rewrite existing sections).
- The upstream Phase 1 and Phase 2 research artifacts that supply the evidence for these findings.

## NON-NEGOTIABLE RULES

- Evidence-only: do NOT provide remediation steps or design changes.
- Every finding MUST include the REQUIRED FINDINGS FORMAT below in full.
- Do NOT use advisory language ("should", "recommend").
- If a section has no applicable findings, state "None found".
- Use the finding IDs from the manifest **unchanged**. Do not renumber, reorder, or invent IDs.

## FINDING ORDER

Within each section, emit findings in ascending `PX-NNN` order. Place each finding under the section named by its manifest `Target Section`.

## REQUIRED FINDINGS FORMAT

### Finding P0-001 (example heading; replace with the actual PX-NNN from the manifest)

- **Priority:** P0 / P1 / P2 / P3
- **Description:** Evidence-based statement of current behavior
- **Evidence:** `file.ext:L123-146`

#### Why this is a risk to app, zone or region failover

- {{Reason 1}}
- {{Reason N}}

#### Impact(s) if this is not changed

- {{Operational impact}}
- {{Data or financial impact}}
- {{Customer-visible impact (if applicable)}}

#### Existing Mitigations

- {{Mitigation 1 (if any)}}
- _None identified_ (explicitly state if empty)

#### Constraints

- {{Technical constraint}}
- {{Organizational / business constraint}}
- {{Regulatory or architectural constraint}}

If none found, state: "None found".

## SECTIONS TO APPEND (use this exact structure and heading order)

------------------------------------------------------------

## 6. Shared and Cross-Repository Dependencies

For each finding with `Target Section` 6, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## 7. Hard-coded values or secrets in code or files

For each finding with `Target Section` 7, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## 8. Other Findings Not Categorized Above

For each finding with `Target Section` 8, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## 9. Research Findings Index (Authoritative)

Build this table directly from the manifest so it lists **every** finding across Sections 2-8. Order by priority tier (P0, P1, P2, P3) then ascending `NNN`.

| Finding ID | Priority | Category | Short Description | Evidence (File:Line) |
|-----------|----------|----------|-------------------|---------------------|

------------------------------------------------------------

## QUALITY BAR CHECK

- No remediation text present anywhere in the research file.
- Every finding has a priority and code evidence.
- Every manifest finding appears exactly once in the body (Sections 2-8) and once in the Section 9 index, with the same ID.
- Findings are in ascending `PX-NNN` order within each section and in the index.
- Sections are complete even if empty ("None found").
- Findings are internally consistent.
```

## Next Step

After completing this prompt:

> **Next step:** Run `/clear`, then `/hve-resiliency-planner-0` to begin Phase 4 (Planning).

## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.
