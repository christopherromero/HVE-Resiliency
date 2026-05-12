---
name: hve-resiliency-research
description: Use for resiliency research covering zone failure within a primary region and regional failover to a secondary region with the task-researcher workflow, evidence-only outputs, and P0-P3 priority classification.
---

# HVE Resiliency Research

Use this skill when you need the full resiliency research sequence for this repository.

Use [Resiliency Research Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

## Activation Guidance

Auto-load this skill only for requests that explicitly mention one or more of the following: Azure zone failure, Azure availability zone resiliency, regional failover, multi-region active/active, zone survivability, the `/hve-resiliency-research` command, or a request to run the resiliency researcher workflow on this repository. Do not auto-load for general reliability, performance, or unrelated Azure questions.

## Activation Behavior

When this skill is activated (via `/hve-resiliency-research` or by matching the Activation Guidance), the agent MUST follow this fixed startup sequence:

1. Ask the user one question only: which execution mode to use (Mode A or Mode B, see Execution Modes below). This is the sole permitted user-facing question at activation.
2. After receiving the mode selection, begin executing the Required Workflow starting at Phase 1, Prompt 0, in the order defined by the Phase 1 Sequence.
3. Do not ask the user to choose which workflow prompt to run, do not offer prompt-selection menus, and do not skip ahead to service-specific prompts (8-19) without completing Prompts 0-7 first. Recommending the single next prompt in a Mode A stop message (per the Phase 1 / Phase 2 Mode A Rules) is required and does not count as a selection menu.

### Execution Modes (Phase 1 and Phase 2)

Before starting Phase 1, the agent MUST ask the user to pick one of the following modes. The same mode applies to both Phase 1 and Phase 2 unless the user requests otherwise.

* **Mode A - Interactive (`/clear`-gated, default).** The agent runs one prompt at a time. After each prompt completes, the agent presents a short summary of the produced artifact and STOPS the turn with an instruction for the user to run `/clear` and then either re-invoke the skill or send `proceed` to continue with the next prompt. This mode preserves a clean context window between prompts and lets the user review each artifact.
* **Mode B - Autonomous (no `/clear`).** The agent runs every prompt in the phase end-to-end without pausing. To replicate the context-isolation benefit of `/clear`, the agent dispatches each prompt as an isolated subagent invocation. This mode is faster but skips per-prompt user review.

In both modes, the agent MUST stop between Phase 1 and Phase 2, and between Phase 2 and Phase 3. Phases 3-5 are always user-gated by `/clear` regardless of the selected mode.

## Required Workflow

Phases are strictly sequential: each phase must complete before the next phase begins, and the agent must not start a later phase while any prompt of the current phase is still pending. Within a single phase, the agent may dispatch multiple prompts in parallel only when the phase's mode rules explicitly allow it (currently only Phase 2 Mode B, up to three concurrent subagents). Cross-phase parallelism is never permitted.

### Workflow Quick Reference

Use this table as the authoritative summary of per-phase behavior. The detailed rules below take precedence if any conflict appears.

| Phase | Prompts | Mode A behavior | Mode B behavior | Stop at end of phase? | `/clear` required between phases? |
|-------|---------|-----------------|-----------------|-----------------------|-----------------------------------|
| 1. Core Research | 0-7 (sequential) | One prompt per turn; summarize, then stop with next-prompt recommendation | All prompts run back-to-back as isolated subagents | Yes | Yes |
| 2. Service Research | 8-19 (filtered to applicable services) | One prompt per turn; summarize, then stop with next-prompt recommendation | Up to 3 concurrent subagents per batch | Yes (never auto-dispatch Phase 3) | Yes |
| 3. Consolidation | `consolidate` | User-gated only (no mode split) | User-gated only (no mode split) | Yes | Yes |
| 4. Planning | `planner-0`, `planner-1`, `planner-0`, `planner-2` | User-gated only (no mode split) | User-gated only (no mode split) | Yes | Yes (between each step) |
| 5. Assessment | `assessment-builder-0` through final | User-gated only (no mode split) | User-gated only (no mode split) | Yes | Yes (between each step) |

Key invariants:

* Mode selection only affects Phases 1 and 2. Phases 3-5 are always user-gated by `/clear`.
* The agent must never skip ahead to service-specific prompts (8-19) without completing Prompts 0-7.
* The agent must never auto-dispatch Phase 3 from Phase 2 (the consolidation prompt is long-running and times out under autonomous orchestration).

### Phase 1: Core Research (Prompts 0-7) - Start Here

Phase 1 runs in the execution mode the user selected during activation (see Execution Modes above).

#### Phase 1 Mode A Rules (Interactive, `/clear`-gated)

* The agent runs exactly one Phase 1 prompt per turn, in the order listed in the Phase 1 Sequence below.
* The agent executes the prompt directly (or via a single subagent invocation) and writes the artifact to `.copilot-tracking/research/`.
* After the prompt completes, the agent presents a short inline summary of the produced artifact and STOPS the turn with an explicit next-prompt recommendation in this exact form: "Run `/clear`, then reply `proceed` (or re-invoke `/hve-resiliency-research`) to continue with `<next-prompt-slug>` (`<short description>`)." The `<next-prompt-slug>` MUST be the immediately following entry in the Phase 1 Sequence (for example, after `/hve-resiliency-researcher-1b` the recommendation is `/hve-resiliency-researcher-2`). If the just-completed prompt is the last in the sequence, follow the Phase 1 Sequence step 12 stop instead.
* The agent MUST NOT dispatch the next Phase 1 prompt in the same turn.
* If a prompt fails or produces no artifact, the agent retries once with a more explicit instruction; if it fails again, surface the error and stop Phase 1.
* After Prompt 7 completes, present the Phase 1 completion summary and STOP per the Phase 1 Sequence step 12.

#### Phase 1 Mode B Rules (Autonomous, no `/clear`)

* The agent MUST execute all Phase 1 prompts in order without prompting the user and without inserting `/clear` between them.
* To replicate the context-isolation benefit of `/clear`, the agent MUST dispatch each Phase 1 prompt as an isolated subagent invocation (one subagent per prompt). The subagent reads the relevant prompt file under `.github/prompts/researcher/` and executes it, writing its output artifact to `.copilot-tracking/research/`.
* After each subagent completes, the orchestrating agent reads the produced artifact, summarizes the result inline (one short paragraph), then immediately dispatches the next subagent.
* If a subagent fails or produces no artifact, the orchestrating agent retries once with a more explicit instruction; if it fails again, surface the error and stop Phase 1.
* The user is informed at the start that Phase 1 will run autonomously and at the end with a Phase 1 completion summary that lists every artifact produced.

#### Phase 1 Sequence

1. Dispatch subagent for `/hve-resiliency-researcher-0` (repository context frame).
2. Dispatch subagent for `/hve-resiliency-researcher-1a`.
3. Dispatch subagent for `/hve-resiliency-researcher-1b`.
4. Lock in Section 1 dependencies from the 1a/1b artifacts. Section 2 and Section 3 entries are excluded from all subsequent prompts.
5. Dispatch subagent for `/hve-resiliency-researcher-2`.
6. Dispatch subagent for `/hve-resiliency-researcher-3`.
7. Dispatch subagent for `/hve-resiliency-researcher-4`.
8. Dispatch subagent for `/hve-resiliency-researcher-5`.
9. Dispatch subagent for `/hve-resiliency-researcher-6` when shared dependency risk analysis is needed.
10. Dispatch subagent for `/hve-resiliency-researcher-7-logging`.
11. After Prompt 7 completes, present the Phase 1 completion summary listing every artifact produced.
12. **STOP and wait for user confirmation before starting Phase 2.** End the turn with a Phase 2 readiness summary that lists the applicable Phase 2 prompts (computed by mapping Section 1 dependencies to the Phase 2 Prompt-to-Service Map) and explicitly recommends the first one in this form: "Reply `proceed` to begin Phase 2 starting with `<first-applicable-phase-2-slug>` (`<service name>`), or run `/clear` first if you want a fresh context." Do not auto-dispatch any Phase 2 prompt in the same turn as the Phase 1 summary.

### Phase 2: Service-Specific Research (Prompts 8-19, Circumstantial) - Runs After User Confirmation

Phase 2 runs only after Phase 1 is complete **and the user has confirmed in a subsequent turn** (per Phase 1 Sequence step 12). Run only the prompts matching dependencies confirmed in Prompt 1 Section 1. Skip services not found.

Phase 2 is triggered by an affirmative user reply (e.g., `proceed`, `yes`, `continue`, `go`, or by re-invoking the skill after `/clear`). Once triggered, Phase 2 runs in the same execution mode the user selected for Phase 1 unless the user requests a different mode at the confirmation step.

In both modes, the agent MUST first compute the applicable prompt set by mapping each Section 1 dependency from the Prompt 1a/1b artifacts to the corresponding service-specific prompt below. Skip every prompt whose service is not in Section 1.

#### Phase 2 Mode A Rules (Interactive, `/clear`-gated)

* The agent runs exactly one applicable Phase 2 prompt per turn, in the order of the Phase 2 Prompt-to-Service Map below (filtered to applicable services).
* The agent executes the prompt directly (or via a single subagent invocation) and writes the artifact to `.copilot-tracking/research/`.
* After the prompt completes, the agent presents a short inline summary of the produced artifact and STOPS the turn with an explicit next-prompt recommendation in this exact form: "Run `/clear`, then reply `proceed` (or re-invoke `/hve-resiliency-research`) to continue with `<next-prompt-slug>` (`<service name>`)." The `<next-prompt-slug>` MUST be the next applicable entry from the filtered Phase 2 Prompt-to-Service Map. If no applicable prompts remain, follow the Phase 2 Stop Rule instead.
* The agent MUST NOT dispatch the next Phase 2 prompt in the same turn.
* If a prompt fails or produces no artifact, retry once with a more explicit instruction; if it fails again, surface the error, skip that service, and continue on the next user turn with the remaining applicable prompts.
* After the final applicable prompt completes, present a Phase 2 completion summary listing every artifact produced and every service skipped (with reason), then STOP per the Phase 2 stop rule below.

#### Phase 2 Mode B Rules (Autonomous, no `/clear`)

* The agent MUST execute all applicable Phase 2 prompts without prompting the user and without inserting `/clear` between them.
* The agent MUST dispatch each applicable prompt as an isolated subagent invocation (one subagent per prompt) to preserve context isolation in lieu of `/clear`. Where service-specific prompts are independent (no shared state), the agent MAY dispatch up to three subagents in parallel.
* After each subagent completes, the orchestrating agent reads the produced artifact, summarizes the result inline (one short paragraph), then dispatches the next.
* If a subagent fails or produces no artifact, retry once with a more explicit instruction; if it fails again, surface the error, skip that service, and continue with the remaining applicable prompts.
* Present a Phase 2 completion summary listing every artifact produced and every service skipped (with reason).

#### Phase 2 Stop Rule (Both Modes)

* **STOP at the end of Phase 2.** Do not auto-dispatch Phase 3 (`/hve-resiliency-researcher-consolidate`) - that prompt is long-running and times out under autonomous orchestration. End the turn with the explicit next-step recommendation: "Run `/clear`, then `/hve-resiliency-researcher-consolidate` to begin Phase 3 (Consolidation)."

#### Phase 2 Prompt-to-Service Map

* `/hve-resiliency-researcher-8-appgw` (App Gateway)
* `/hve-resiliency-researcher-9-functions` (Azure Functions)
* `/hve-resiliency-researcher-10-keyvault` (Key Vault)
* `/hve-resiliency-researcher-11-aks-istio` (AKS and Istio)
* `/hve-resiliency-researcher-12-cosmosdb` (Cosmos DB)
* `/hve-resiliency-researcher-13-sql` (SQL Server)
* `/hve-resiliency-researcher-14-redis` (Redis)
* `/hve-resiliency-researcher-15-storage` (Azure Storage)
* `/hve-resiliency-researcher-16-kafka` (Kafka)
* `/hve-resiliency-researcher-17-networking` (Networking)
* `/hve-resiliency-researcher-18-entraid` (Entra ID)
* `/hve-resiliency-researcher-19-apim` (APIM)

### Phase 3: Consolidation

* Run `/clear`, then `/hve-resiliency-researcher-consolidate` to merge all research outputs into a single consolidated research document at `.copilot-tracking/research/`.

### Phase 4: Planning

* Run `/clear`, then `/hve-resiliency-planner-0` (planning context frame).
* Run `/hve-resiliency-planner-1` (produces `<repo-name>-Master.md` in `.copilot-tracking/plans/`).
* Inspect or modify the Master report before continuing if needed.
* Run `/clear`, then `/hve-resiliency-planner-0` again (re-establish planning context).
* Run `/hve-resiliency-planner-2` (produces `<repo-name>-Developer-Guide.md` in `.copilot-tracking/plans/`).

### Phase 5: Code-Level Resiliency Assessment Report

* Run `/clear`, then `/hve-resiliency-assessment-builder-0` (header, TOC, Assessment Overview).
* Run `/clear`, then `/hve-resiliency-assessment-builder-1` (P0 and P1 resiliency findings).
* Run `/clear`, then `/hve-resiliency-assessment-builder-2` (P2/P3 resiliency and Non-Resiliency sections).
* Run `/clear`, then `/hve-resiliency-assessment-builder-3` (IaC Gap Analysis, Full Finding Matrix, Microsoft Standards Alignment, validation).
* Review the completed report at `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`.

## Execution Rules

* Keep research findings (Phases 1-3) evidence-only and forensic
* Do not include remediation recommendations in research phases
* Do not include code examples in research phases
* Classify every finding using P0 / P1 / P2 / P3 priorities
* Cite file and line-level evidence for every substantive claim
* Write each research output to `.copilot-tracking/research/` and use the repository name as the prefix for all output files
* Planning outputs (Phase 4 and 5) may include remediation and code examples
* Do not use em dashes (`—`) in any generated artifact, heading, label, table cell, or prose. Use a hyphen (`-`) or restructure the sentence with a comma, colon, or parentheses instead. This rule applies to all phases and all output files.

## Priority Definitions

* P0: Critical / Blocking. Causes outage, data loss, duplicate transactions, or inability to fail over safely.
* P1: Required, Non-Blocking. Materially increases application risk, data risk, or customer impact during failure.
* P2: Improvement / Best Practice. Does not materially impact correctness but weakens resilience posture.
* P3: Non-Blocking Code Consistency. Maintainability, readability, duplication, or inconsistent patterns that are non-blocking.

## Service Exclusion Rule

* After Prompt 1 completes, dependencies in Section 2 (Checked But Not Present) and Section 3 (Not Applicable) are dropped from scope
* Prompts 2-7, service-specific prompts (8-19), and the consolidation report analyze only Section 1 dependencies (evidence-confirmed)
* In Phase 2, run only the service-specific prompts for dependencies found in Section 1

## Output Review

> **Review notice:** Every artifact produced by this workflow - research outputs, consolidated reports, planning documents, and the final assessment - must be reviewed by a qualified engineer before it is shared, acted on, or treated as authoritative. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified priorities, fabricated citations, or internal inconsistencies across phases. Validate every claim against the cited file and line references, confirm dependency scoping decisions, reconcile contradictions between artifacts, and correct any errors before advancing to the next phase or delivering results.
