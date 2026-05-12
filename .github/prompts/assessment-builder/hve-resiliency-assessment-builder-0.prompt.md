---
agent: Task Planner
description: "Creates the Code-Level Resiliency Assessment report header, Table of Contents, and Section 1 (Assessment Overview)"
argument-hint: "serviceName=... [reportTitle=...] [targetDeployment=...]"
---

# Resiliency Report Generator - Part A: Header and Assessment Overview

Use [Resiliency Task Planner Context](../../../instructions/hve-resiliency-planner-context.instructions.md).

## Inputs

* ${input:serviceName}: (Required) Service name matching the repo name; used to locate artifacts and populate all headers, sections, and repo references throughout the report.
* ${input:reportTitle}: (Optional) H1 title. Default: "Code-Level Resiliency Assessment".
* ${input:targetDeployment}: (Optional) Target deployment model. Default: "Active/Active".

## Source Artifacts

Read **only** the following before generating. Do **not** read the Developer Guide or subagent files for this prompt.

* `.copilot-tracking/plans/` - locate `{serviceName}-Master.md`. Read the Overview Summary, Priority Legend, Application Summary, Architecture and Dependency Map, the finding count per priority tier, and the Open Questions section. This is sufficient for the Assessment Overview.
* `.copilot-tracking/research/` - locate `*-{serviceName}-research.md`. Read only the Repository Context section (Section 1) for the opening paragraph.

## Critical Context

This report serves an application transitioning from a single-region deployment with a passive DR target to an active/active deployment across two regions. Every finding must be evaluated through this lens. Use the classification rules and decision tree defined in `hve-resiliency-planner-context.instructions.md` for all priority assignments.

All section headers, H3 group names, finding titles, and repo references must use `{serviceName}` (the repo name), not hardcoded service names.

## Region-Agnostic Language Rule

The generated report must use region-agnostic terms throughout. Never reference specific Azure region names. Use:

* **Primary region** - the current production region
* **Secondary region** or **failover region** - the target active/active peer
* **Both regions** - when referring to symmetric requirements

## What to Generate

Create a **new file** at `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` containing **only** the following sections. Subsequent prompts (3b, 3c, 3d) will append the remaining sections.

### 1. Document Header

```text
# Code-Level Resiliency Assessment

**{serviceName}**

**Assessment Date:** {date or date range}

**Repo Scope:** {serviceName}

**Current Deployment:** {current deployment from research}

**Target Deployment:** {targetDeployment}

**Version:** {semver}

---
```

### 2. Navigation and Table of Contents

Place `<a id="top"></a>` immediately after the header horizontal rule, then `## Table of Contents` with a numbered list of fragment links for every H1 section. No auto-generation markers. Fragment pattern: lowercase, hyphens, no special chars; number-prefixed.

```text
<a id="top"></a>

## Table of Contents

1. [Assessment Overview](#1-assessment-overview)
2. [Resilient Focused Recommendations](#2-resilient-focused-recommendations)
3. [Non-Resilient Focused Recommendations](#3-non-resilient-focused-recommendations)
4. [IaC Gap Analysis](#4-iac-gap-analysis)
5. [Full Finding Matrix](#5-full-finding-matrix)
6. [Microsoft Standards Alignment](#6-microsoft-standards-alignment)
```

### 3. Section 1 - Assessment Overview

Use `# 1. Assessment Overview` as the heading. Include all of the following sub-sections:

1. **Opening paragraph**: Describe what the service does, its tech stack, and the scope of the analysis. Reference the evidence-only methodology.

2. **Assessment Themes**: A numbered list of the top 3-5 themes that emerged from the research, each with a brief description and cross-references to the relevant finding IDs. Use the `PX-NNN` IDs from the Master Report directly (e.g., P0-001, P1-005); no re-mapping is needed.

3. **Summary Findings Table**: Counts broken down by Section and Priority. Derive counts from the Master Report finding tallies:

    | Section            | Priority  | Count | Description                                                                    |
    |--------------------|-----------|-------|--------------------------------------------------------------------------------|
    | **Resiliency**     | **P0**    | N     | Blocks failover from functioning or renders multi-region deployment meaningless |
    | **Resiliency**     | **P1**    | N     | Materially increases risk during failure; procedural workarounds or limited blast radius |
    | **Resiliency**     | **P2**    | N     | Weakens resilience posture; best-practice improvements for zone/region survivability |
    | **Resiliency**     | **P3**    | N     | Referential entries or compound interaction descriptions                       |
    | **Non-Resiliency** | **P2**    | N     | Code quality, security hygiene, observability, and configuration improvements  |
    | **Non-Resiliency** | **P3**    | N     | Security-only observations and configuration hygiene items                     |
    |                    | **Total** | **N** |                                                                                |

    To split findings between Resiliency and Non-Resiliency sections: all P0 and P1 findings are Resiliency. P2 and P3 findings are classified using the litmus test - findings that pass the active/active litmus test (behavior changes in multi-region) are Resiliency; findings with identical behavior regardless of topology are Non-Resiliency.

4. **IMPORTANT callout**: End with this exact blockquote:

    > **IMPORTANT:** Throughout this guidance, hard numbers used for retry counts, timeout settings, interval timings, thread pool sizes, and circuit breaker thresholds are provided as examples. In code, these should be configurable variables sourced from environment-specific configmaps. Treat all code snippets as illustrative patterns, not prescriptive implementations.

End the section with `[Back to Top](#top)`.

## Formatting Conventions

* Aligned pipe tables - all pipes vertically aligned across all rows.
* Blank lines before and after tables, code blocks, headings, and lists.
* `---` horizontal rules between major sections.
* All repo references use `{serviceName}`, never a hardcoded service name.
* Report file must NOT include `<!-- markdownlint-disable-file -->` - this is a deliverable.

## Output Location

Write the generated report to:

`Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`

Create the file new. Subsequent prompts (3b, 3c, 3d) will append to this file.

## Next Step

After completing this prompt:

> **Next step:** Run `/clear`, then `/hve-resiliency-assessment-builder-1`


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.