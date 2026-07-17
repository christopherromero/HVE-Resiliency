---
description: Consolidation Part B - append Dependency Inventory, Region/Zone Assumptions, State and Data, and Failure/Degraded-Mode findings using the authoritative manifest IDs
agent: Task Researcher
---

# HVE Resiliency Researcher Consolidate - Part B (Sections 2-5)

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

Run `/hve-resiliency-researcher-consolidate-0` first. This pass appends Sections 2-5 to the research file it created. Run `/hve-resiliency-researcher-consolidate-2` after this.

```text
# HVE Task Researcher Prompt - Consolidation Part B (Sections 2-5)

You are acting as a Senior Cloud Application Architect continuing the final consolidation of resiliency research.

## OBJECTIVE

Append Sections 2 through 5 to the existing research file, writing the full detail for every finding whose `Target Section` in the manifest is 2, 3, 4, or 5.

Read first:
- `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-findings-manifest.md` - the authoritative finding IDs, groups, and target sections from Part A.
- `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-research.md` - the research file Part A created (do NOT rewrite the header or Section 1).
- The upstream Phase 1 and Phase 2 research artifacts that supply the evidence for these findings.

## NON-NEGOTIABLE RULES

- Evidence-only: do NOT provide remediation steps or design changes.
- Every finding MUST include the REQUIRED FINDINGS FORMAT below in full.
- Do NOT use advisory language ("should", "recommend").
- Priority represents **failover impact**, not implementation effort.
- If a section has no applicable findings, state "None found".
- Use the finding IDs from the manifest **unchanged**. Do not renumber, reorder, or invent IDs.

## FINDING ORDER

Within each section, emit findings in ascending `PX-NNN` order (P0 first, then P1, P2, P3; ascending `NNN` within each tier). Place each finding under the section named by its manifest `Target Section`.

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

## 2. Dependency Inventory

### 2.1 Used Dependencies (Evidence Found)

For each finding with `Target Section` 2, use the REQUIRED FINDINGS FORMAT.

### 2.2 Checked but Not Present

| Dependency | Reason Checked | Evidence Result |

### 2.3 Not Applicable Dependency Categories

| Category | Reason Not Applicable |

------------------------------------------------------------

## 3. Region and Zone Assumptions

For each finding with `Target Section` 3, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## 4. State and Data Characteristics

For each finding with `Target Section` 4, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## 5. Failure and Degraded-Mode Behavior

For each finding with `Target Section` 5, use the REQUIRED FINDINGS FORMAT.

------------------------------------------------------------

## COMPLETION CHECK

- Every manifest finding with `Target Section` 2-5 appears exactly once, under the correct section, with its manifest ID unchanged.
- Findings within each section are in ascending `PX-NNN` order.
- No remediation text present; every finding has code evidence.
```

## Next Step

After completing this prompt:

> **Next step:** Run `/clear`, then `/hve-resiliency-researcher-consolidate-2`

## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.
