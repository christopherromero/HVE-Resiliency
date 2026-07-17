---
description: Consolidation Part A - read all research, deduplicate, assign authoritative logical finding IDs to a manifest, and write the research file header and Repository Context
agent: Task Researcher
---

# HVE Resiliency Researcher Consolidate - Part A (Manifest and Context)

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

This is the first of three consolidation passes. Part A does the heavy read-and-number work once, up front, so the later passes only write per-finding detail and never time out. Run `/hve-resiliency-researcher-consolidate-1` and `/hve-resiliency-researcher-consolidate-2` after this.

```text
# HVE Task Researcher Prompt - Consolidation Part A (Findings Manifest and Context)

You are acting as a Senior Cloud Application Architect beginning the final consolidation of all resiliency research for a microservice.

## OBJECTIVE

Read every completed research artifact for this repository, deduplicate the findings, assign the authoritative finding IDs once, and write the two foundation files the later passes depend on.

Read ALL upstream research artifacts from `.copilot-tracking/research/`:
- Phase 1 core research (Prompts 0-7): repository context, Azure and external dependency inventory, region/zone assumptions, dependency survivability, state and data characteristics, failure and degraded-mode behavior, shared and cross-repository dependencies, logging and observability.
- Phase 2 service-specific research (Prompts 8-19): every per-service deep-dive artifact that was produced.

## NON-NEGOTIABLE RULES

- Evidence-only: do NOT provide remediation steps or design changes.
- Do NOT use advisory language ("should", "recommend").
- Priority represents **failover impact**, not implementation effort.
- If a finding was evaluated and not found, that is recorded later; in this pass, only catalog findings that have evidence.
- Do not duplicate findings; merge duplicates from different source artifacts into a single finding and cite the strongest evidence.

## PRIORITY DEFINITIONS (USE EXACTLY)

- P0 - Blocking/Critical Risk: causes outage, data loss, duplicate transactions, or inability to fail over safely during zone or regional failure.
- P1 - High Priority (Potential for Blocking): does not fully block failover but materially increases MTTR, data risk, or customer impact during failure.
- P2 - Improvement/Best Practice (Non-Blocking): does not materially impact correctness during failover but weakens resilience posture or operational clarity.
- P3 - Non-Blocking Code Consistency (Best Practices / Maintainability): just a good practice.

## FINDING IDS AND AUTHORITATIVE LOGICAL ORDERING

Finding IDs use the format `PX-NNN`, where `PX` is the priority tier (P0, P1, P2, P3) and `NNN` is a zero-padded sequence number that restarts at `001` within each priority tier.

**This pass assigns every finding ID for the whole workflow, once.** Within each priority tier, order findings logically so related items sit next to each other - group by shared dependency, service, or theme (for example: all Cosmos findings together, then all Key Vault findings, then all health/GLB findings) - then assign the `NNN` sequence in that final logical order. Because the logical grouping spans the whole finding set here, a service's findings receive a contiguous, ascending ID range even when their evidence lives in different research categories (inventory, failure modes, hard-coded values, etc.).

This numbering is the single authoritative sequence for the entire workflow. Consolidation Parts B and C, the Planner, and the Assessment Builder all reuse these IDs unchanged and present findings in ascending ID order within each priority tier. They never reorder or renumber.

## OUTPUT 1 - Findings Manifest (write this file)

Write `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-findings-manifest.md` containing the complete, numbered finding set. Use today's date and the repository name. This manifest is the coordination artifact the later passes read to know every finding's ID and target section.

```markdown
# Findings Manifest - <repo-name>

- Generated: YYYY-MM-DD
- Purpose: authoritative finding IDs and target sections for consolidation Parts B and C. Not a deliverable.

| Finding ID | Priority | Group (service/theme) | Target Section | Short Description | Evidence (file:line) |
|-----------|----------|-----------------------|----------------|-------------------|----------------------|
```

Manifest rules:
- One row per unique finding, ordered by priority tier (P0, P1, P2, P3) then ascending `NNN`.
- `Group (service/theme)` is the logical grouping used to assign the ID order (for example: `Cosmos DB`, `Key Vault`, `Health / GLB`).
- `Target Section` is the research-report section (2-8) where the full finding detail will be written in Parts B and C:
  - 2 = Dependency Inventory
  - 3 = Region and Zone Assumptions
  - 4 = State and Data Characteristics
  - 5 = Failure and Degraded-Mode Behavior
  - 6 = Shared and Cross-Repository Dependencies
  - 7 = Hard-coded values or secrets in code or files
  - 8 = Other Findings Not Categorized Above
- Every finding must have code evidence (`file.ext:Lstart-Lend`).

## OUTPUT 2 - Research File Header and Section 1 (write this file)

Create `.copilot-tracking/research/YYYY-MM-DD-<repo-name>-research.md` containing ONLY the header block and Section 1. Consolidation Parts B and C append Sections 2-9.

```text
# HVE Task Research - <repo-name>

Assessment Scope:
- Repository: <repo-name>
- Focus: Zone survivability and regional failover for the application
- Regions Evaluated: Primary region → Secondary region
- Assessment Date: YYYY-MM-DD
- Generated By: Researcher

Notes:
- This document is an evidence-only research artifact.
- It includes resiliency severity (P0/P1/P2/P3) but no remediation.
- This file is the sole authoritative input to the Planner.

------------------------------------------------------------

## 1. Repository Context

- Service purpose
- Application Overview
- Execution model (API, async worker, job, library)
- Runtime environment (AKS, App Service, Functions, VM)
- Explicit boundaries (what this repo does NOT handle)
- Key Business Processes and the flows for those processes

------------------------------------------------------------
```

## COMPLETION CHECK

- The manifest lists every unique finding with an authoritative `PX-NNN` ID, a group, a target section, and code evidence.
- IDs are contiguous and ascending within each priority tier, grouped logically by service/theme.
- The research file contains the header and a complete Section 1 only.
```

## Next Step

After completing this prompt:

> **Next step:** Run `/clear`, then `/hve-resiliency-researcher-consolidate-1`

## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.
