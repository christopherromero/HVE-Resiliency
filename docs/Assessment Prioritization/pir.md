        # Priority Classification Decision Tree

**OSPG Digital Payments — OSPG-PaymentTokenVault**

**Companion to:** OSPG-PaymentTokenVault-Code-Level-Resiliency-Assessment.md

**Purpose:** Document the reasoning and decision logic used to assign P0 / P1 / P2 / P3 priorities and to categorize findings as Resiliency vs Non-Resiliency across the entire assessment.

**Version:** 1.0.0

---

<a id="top"></a>

## Table of Contents

1. [Overview](#1-overview)
2. [Engagement Framing That Drives Severity](#2-engagement-framing-that-drives-severity)
3. [The Litmus Test and Four Rules](#3-the-litmus-test-and-four-rules)
4. [Priority Definitions](#4-priority-definitions)
5. [Classification Decision Tree](#5-classification-decision-tree)
6. [Resiliency vs Non-Resiliency Determination](#6-resiliency-vs-non-resiliency-determination)
7. [Precedence and Ordering Rules](#7-precedence-and-ordering-rules)
8. [Pipeline: Where Priorities Are Decided, Locked, and Rendered](#8-pipeline-where-priorities-are-decided-locked-and-rendered)
9. [The HVE Issue-Finding Process](#9-the-hve-issue-finding-process)
10. [Rule Provenance: HVE Framework vs OSPG Prompts](#10-rule-provenance-hve-framework-vs-ospg-prompts)
11. [Source Authority](#11-source-authority)

---

## 1. Overview

This document explains the classification methodology applied uniformly to all 122 findings in the assessment. It is not the reasoning for any single finding; it is the repeatable decision procedure every finding was passed through.

Every finding was evaluated through one lens: the transition from a single-region passive-DR deployment (West US, with East US DR) to an active/active deployment (West US + West US 2). A finding's priority reflects its **failover impact**, not the effort required to fix it.

The classification logic is sourced from the prompt and instruction artifacts in the `.github` folder. The authoritative classifier is the decision tree in `.github/instructions/ospg-planner-context.instructions.md`; the researcher, skill, and consolidation prompts carry phase-specific restatements of the same definitions.

### Provenance Legend

Two authorship sources shaped this methodology. Throughout this document, rules carry a tag showing where each originates:

- **[HVE]** — inherited from the generic HVE (High Velocity Engineering) framework (`microsoft/hve-core`): reusable, engagement-agnostic workflow mechanics with no resiliency semantics.
- **[OSPG]** — authored specifically for this engagement in the repository `.github` prompts and instructions: all priority and resiliency classification content.
- **[Hybrid]** — an HVE base behavior that OSPG deliberately tightened or overrode for this engagement.

A full-text search of the HVE-core framework for any priority (P0–P3), litmus, failover, or resiliency term returns zero matches. The framework supplies only the workflow shell (research → plan handoff, subagent delegation, `/clear` resets, evidence discipline, authoring standards); every classification decision in this document is OSPG-authored.

[Back to Top](#top)

---

## 2. Engagement Framing That Drives Severity

The customer is not adding a second region for capacity. They are moving from a passive DR model to active/active. Findings that block or degrade this transition are the highest priority. Several architectural constraints are baked directly into the priority criteria:

- **The Global Load Balancer (GLB) is the failover controller.** The application cannot fail itself over; the GLB reads health probes and redirects traffic. Health probes that are blind to dependencies make failover decisions meaningless.
- **Dependencies must exist in both regions.** Any single-region dependency with no plan for the second region is flagged P0 — failing over gains nothing if the dependency is absent in the target region.
- **Abstracted endpoints are required.** Configuration must use a single failover-aware listener/endpoint that routes to whichever region is active, not hard-coded per-region FQDNs or IPs.

[Back to Top](#top)

---

## 3. The Litmus Test and Four Rules

The Litmus Test, the Four Rules, and the active/active framing they reference are entirely **[OSPG]**-authored (`ospg-planner-context.instructions.md`). The HVE framework contributes none of this content.

### The Litmus Test (the entry gate) — [OSPG]

> **"Does going from single-region (West US with East US DR) to active/active (West US + West US 2) introduce or change this issue?"**

- **YES** — the issue is resiliency-related. Categorize as a resiliency finding.
- **NO** — the behavior is identical in single-region and multi-region. It is a code-quality or logic issue, unless it can be reframed in resiliency terms (Rule 2).

### The Four Rules — [OSPG]

| Rule | Name | Effect on Classification |
| ---- | ---- | ------------------------ |
| **Rule 1** | Failover is the central pillar | Failover mechanics (GLB routing, health probes, region-aware config, cross-region dependency availability) are the lens for every resiliency finding. |
| **Rule 2** | Resiliency wording is required | Every resiliency finding must state impact as: *"If you don't fix [X], then during a [failure scenario], [Y impact] occurs, which affects [client goal Z]."* No statement, no resiliency bucket. |
| **Rule 3** | Failure-triggered issues qualify | If an issue only surfaces during a failure event (zone loss, regional loss, GLB failover), it counts as a resiliency finding. A workaround lowers priority (P1 vs P0), not category. |
| **Rule 4** | Include everything; the customer decides | Every finding stays in the report regardless of expected acceptance. The customer may decline any recommendation; keeping the record means it is available if the issue resurfaces. |

[Back to Top](#top)

---

## 4. Priority Definitions

The P0–P3 legend and the detailed failover criteria below are **[OSPG]**-authored (`ospg-planner-context.instructions.md`). HVE provides no priority scheme of its own.

| Priority | Label | Definition |
| -------- | ----- | ---------- |
| **P0** | Failover-Blocking Risk | Blocks failover from functioning or renders the active/active deployment meaningless. Without the fix, the second region provides no benefit. Includes: single-region dependencies, missing GLB health probes, hard-coded region-specific values, and prerequisites for other P0 fixes. |
| **P1** | Multi-Region Resiliency Gap | Resiliency-related (passes the litmus test) but has a procedural workaround, lower blast radius, or does not fully block failover. Includes failure-only issues that are manually remediable, detectable/reversible data integrity issues, and missing retry/error handling that degrades but does not prevent operation. |
| **P2** | Code Quality / Best Practice | A valid code issue that behaves identically in single-region and active/active. Reported, but not prioritized above P0/P1 resiliency items. May be reframed to P1 only if a credible resiliency impact statement exists (Rule 2). |
| **P3** | Code Consistency / Noted for Completeness | No functional resiliency impact and no effect on failover mechanics. Retained per Rule 4: configuration hygiene, naming, referential entries, and cross-domain observations. |

> A `Resiliency Related: No` finding can never be P0 or P1. By construction, the decision tree only reaches P0/P1 through the resiliency branch or a Rule 2 reframe. This is why the assessment Summary Findings Table has no Non-Resiliency P0 or P1 rows.

[Back to Top](#top)

---

## 5. Classification Decision Tree

The decision tree (Q1–Q6) is **[OSPG]**-authored (`ospg-planner-context.instructions.md`). The following is the exact algorithm applied to every finding. The rendered decision tree diagram is in the companion diagrams document: OSPG-PaymentTokenVault-Priority-Classification-Diagrams.md (Section 1).

### Step-by-Step Narrative

1. **Q1 — Litmus Test.** Does the single-region to active/active transition introduce or change the issue? **YES** routes to the resiliency branch (Q2). **NO** routes to the non-resiliency branch (Q5).
2. **Q2.** Does the fix block failover from working at all? **YES → P0.**
3. **Q3.** (Reached only when Q2 = NO.) Does the issue only manifest during a failure event? **NO → P1.** **YES → Q4.**
4. **Q4.** Is there a procedural workaround? **YES → P1** (workaround lowers priority, not category). **NO → P0** (a failure-only issue with no workaround escalates back to P0).
5. **Q5.** (Reached only when Q1 = NO.) Can the impact be credibly reframed in resiliency terms per Rule 2? **YES → P1** (reword the impact statement and move into the resiliency bucket).
6. **Q6.** (Reached only when Q5 = NO.) Does the finding have functional or operational impact? **YES → P2.** **NO → P3.**

### Special Case: Prerequisite Findings

If a finding is not itself a resiliency issue but is a required prerequisite for another resiliency fix, it inherits the priority of the dependent finding. A prerequisite for a P0 fix is itself P0.

[Back to Top](#top)

---
 
 ## 6. Resiliency vs Non-Resiliency Determination

The `Resiliency Related: Yes / No` field decides whether a finding appears in Section 2 (Resilient Focused Recommendations) or Section 3 (Non-Resilient Focused Recommendations) of the assessment. The rendered diagram is in the companion diagrams document: OSPG-PaymentTokenVault-Priority-Classification-Diagrams.md (Section 2).

- **Resiliency Related: Yes** — the finding passed the Litmus Test (Q1 = YES) or was credibly reframed under Rule 2 (Q5 = YES). It must carry a `Resiliency Impact` statement framed in zone-failure or regional-failover terms.
- **Resiliency Related: No** — the finding failed the Litmus Test and could not be reframed. These are security, code-consistency, or hygiene items. They use a plain `Impact` statement and are limited to P2 or P3.

[Back to Top](#top)

---

## 7. Precedence and Ordering Rules

All precedence and ordering rules below are **[OSPG]**-authored (`ospg-planner-context.instructions.md`, `ospg-hve-researcher-consolidate.prompt.md`). These tie-breakers and ordering constraints were applied consistently across all findings:

- **Impact over effort.** Priority represents failover impact, not implementation effort. A low-effort fix with high failover impact remains P0.
- **Resiliency over non-resiliency.** Non-resiliency P2 items are never prioritized above P0/P1 resiliency items.
- **Single-region dependency = P0.** A dependency present in only one region is a hard-coded P0 criterion.
- **Missing GLB health probes = P0.** Dependency-aware health probes are net-new work required for the GLB to make informed failover decisions.
- **Prerequisite inheritance.** A prerequisite inherits the priority of the finding that depends on it.
- **Mandatory ordering.** Any list of findings is grouped and ordered P0 first, then P1, P2, P3. The Full Finding Matrix is sorted in this order.

[Back to Top](#top)

---

## 8. Pipeline: Where Priorities Are Decided, Locked, and Rendered

Classification is decided during research, finalized and de-duplicated during consolidation, locked before planning, and rendered into the final assessment. Planning phases cannot reclassify or add findings. The rendered pipeline diagram is in the companion diagrams document: OSPG-PaymentTokenVault-Priority-Classification-Diagrams.md (Section 3).

The pipeline **shape** — a research → consolidate → plan handoff with `/clear` resets and subagent delegation — is **[HVE]** framework mechanics. What flows through each stage (priorities, resiliency categorization, finding IDs) is **[OSPG]**. The evidence lock-in and the strict "cannot add or reclassify findings" rule are **[Hybrid]**: HVE grounds plans in research, and OSPG hardened that into an enforced freeze re-applied before every planner output.

| Stage | Responsibility | Classification Effect | Provenance |
| ----- | -------------- | --------------------- | ---------- |
| Researcher prompts | Evidence-only, file + line citations, no remediation | Each finding receives a provisional P0–P3 and Resiliency Yes/No. | Hybrid (HVE research shell; OSPG evidence-only override + P0–P3 tagging) |
| Consolidation | Merge all outputs into one authoritative artifact | De-duplicates findings, finalizes priorities, builds the Findings Index. | Hybrid (HVE consolidation; OSPG de-dup by Finding ID + final priorities) |
| planner-0 | Evidence lock-in | Freezes research as fixed constraints; no reinterpretation or new findings. | Hybrid (HVE grounding; OSPG hardened freeze) |
| planner-1 / planner-2 | Master report and Developer Guide | Render remediation and code; cannot change priorities. | OSPG (`F-###` IDs, Developer Guide format) |
| planner-3 | Assessment generator | Splits Resiliency vs Non-Resiliency, assigns `PX-NNN` IDs, validates Summary Findings Table counts. | OSPG (Section 2/3 split, `PX-NNN`, count validation) |

### De-Duplication

- **Consolidation** is the primary de-duplication point: findings are not duplicated across sections; cross-references use the Finding ID.
- The **Service Exclusion Rule** narrows deep analysis to dependencies confirmed present (Section 1 of the discovery scope), preventing re-analysis of out-of-scope services.
- The **assessment generator** validates that every `PX-NNN` ID is unique and that Summary Findings Table counts match per section and priority.

This pipeline produced the 122 de-duplicated findings recorded in the assessment: 36 P0, 34 P1, 14 resiliency P2, 4 resiliency P3, 17 non-resiliency P2, and 17 non-resiliency P3.

[Back to Top](#top)

---




## 9. The HVE Issue-Finding Process

**[HVE]** is a prompt library. It is distributed as the `microsoft/hve-core` VS Code extension and used through GitHub Copilot Chat. Selecting an agent (Task Researcher, Task Planner) loads that agent's `.agent.md` markdown file as the system prompt for the LLM behind Copilot, which then uses the IDE's tools (search, read, web fetch, subagent calls) to read the workspace and write its output files.

OSPG plugged in by adding more markdown files in `.github/prompts/` and `.github/instructions/`. When the user invoked an OSPG prompt, Copilot loaded the HVE agent file plus the OSPG prompt plus any matching `.instructions.md` files. The combined text became the model's system prompt for that turn. Every finding in the assessment was produced this way.

**Source files (HVE framework, under `ise-hve-essentials.hve-core` and `microsoft/hve-core`):** `task-researcher.agent.md`, `task-planner.agent.md`, `subagents/researcher-subagent.agent.md`, `subagents/plan-validator.agent.md`, `prompts/hve-core/{task-research,task-plan,rpi}.prompt.md`.

[Back to Top](#top)

---

## 10. Rule Provenance: HVE Framework vs OSPG Prompts

This section consolidates the attribution applied throughout the document. The HVE-core framework (`microsoft/hve-core`) is a reusable engineering accelerator that contains **no** priority or resiliency vocabulary; a full-text search of the installed framework for `P0|P1|P2|P3|litmus|failover|active/active|resiliency` returns zero matches. Every classification semantic is OSPG-authored. The framework's contribution is the workflow shell that carries those semantics.

### A. HVE-Generic Framework Mechanics

Reusable, engagement-agnostic, no resiliency meaning:

| Element | Source |
| ------- | ------ |
| Research → Plan two-agent workflow and handoff | HVE Task Researcher / Task Planner agents |
| `/clear` context reset between phases | HVE agent guidance |
| Subagent delegation (parallel research) | HVE Task Researcher |
| Base evidence / verified-findings discipline; line-numbered references as a norm | HVE Task Researcher |
| `.copilot-tracking/research/` location, naming, `markdownlint-disable-file` header | HVE Task Researcher |
| Generic consolidation and "ground plans in research" base lock-in | HVE Task Planner |
| Markdown, writing-style, commit-message, pull-request, git-merge, prompt-builder standards | `instructions/hve-core/*` |

### B. OSPG-Authored Resiliency Content

Exists only in the workspace `.github` prompts and instructions:

| Element | Source |
| ------- | ------ |
| P0–P3 legend and detailed failover criteria (single-region dependency = P0, GLB probes = P0) | `ospg-planner-context.instructions.md` |
| The Litmus Test, the Four Rules, the Q1–Q6 decision tree | `ospg-planner-context.instructions.md` |
| Resiliency vs Non-Resiliency split (Section 2 vs Section 3); `PX-NNN` IDs; region-agnostic output rule; GLB / health-probe constraints | `ospg-hve-planner-3.prompt.md` |
| `F-###` ID scheme; "priority = failover impact, not implementation effort"; de-dup by Finding ID | `ospg-hve-researcher-consolidate.prompt.md` |
| Service Exclusion Rule (analyze only confirmed Section-1 dependencies); P0-first ordering; West US + West US 2 framing | `ospg-platform-context.instructions.md`, `ospg-resiliency-research/SKILL.md` |

### C. Hybrid (HVE Base, OSPG Override)

| Element | HVE Base | OSPG Override |
| ------- | -------- | ------------- |
| Evidence-only research | HVE researcher normally authors code examples and "actionable next steps" | OSPG strips code and remediation from research and defers them to the planner Developer Guide |
| Evidence lock-in | HVE grounds plans in research and tracks deviations | OSPG hardens to "cannot challenge, reinterpret, or add findings" and re-runs planner-0 to re-lock before each output |
| File + line citation | HVE authoring norm | OSPG elevates to a mandatory per-finding gate |
| Research → plan with `/clear` | HVE single handoff | OSPG expands into the full multi-prompt pipeline with `/clear` between every step |

[Back to Top](#top)

---

## 11. Source Authority

The classification logic in this document is derived from the following artifacts. The HVE column marks whether the artifact is OSPG-authored or part of the HVE framework.

| Artifact | Provenance | Role in Classification |
| -------- | ---------- | ---------------------- |
| .github/instructions/ospg-planner-context.instructions.md | OSPG | Authoritative classifier: Litmus Test, Four Rules, priority criteria, decision tree, ordering rules. |
| .github/instructions/ospg-platform-context.instructions.md | OSPG | Researcher-side priority definitions, evidence-only rules, Service Exclusion Rule, workflow sequence. |
| .github/skills/ospg-resiliency-research/SKILL.md | OSPG | Workflow orchestration, priority definitions, deliverable templates. |
| .github/prompts/researcher/ospg-hve-researcher-consolidate.prompt.md | OSPG | "USE EXACTLY" priority definitions, de-duplication rule, impact-over-effort rule. |
| .github/prompts/planner/ospg-hve-planner-0.prompt.md | OSPG | Evidence lock-in seed (hardens the HVE grounding base). |
| .github/prompts/planner/ospg-hve-planner-1.prompt.md | OSPG | Master report, `F-###` Finding IDs. |
| .github/prompts/planner/ospg-hve-planner-2.prompt.md | OSPG | Developer Guide, code-level remediation. |
| .github/prompts/planner/ospg-hve-planner-3.prompt.md | OSPG | Assessment generator: Resiliency vs Non-Resiliency split, `PX-NNN` IDs, Summary Findings Table. |
| .github/prompts/researcher/ospg-hve-researcher-*.prompt.md | OSPG | Core evidence-gathering prompts (0, 0a, 1a, 1b, 2-6, 7-logging). |
| .github/prompts/service/ospg-hve-researcher-*.prompt.md | OSPG | Per-service evidence prompts (8-19), run only for confirmed dependencies. |
| HVE Task Researcher / Task Planner agents (`ise-hve-essentials.hve-core`) | HVE | Generic research → plan workflow, subagent delegation, `/clear` resets, base evidence discipline, lock-in base. |
| instructions/hve-core/*.instructions.md (`ise-hve-essentials.hve-core`) | HVE | Markdown, writing-style, commit-message, pull-request, git-merge, and prompt-builder authoring standards. |

[Back to Top](#top)
 