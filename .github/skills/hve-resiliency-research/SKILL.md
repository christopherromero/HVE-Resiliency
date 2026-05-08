---
name: hve-resiliency-research
description: Use for resiliency research covering zone failure within a primary region and regional failover to a secondary region with the task-researcher workflow, evidence-only outputs, and P0-P3 priority classification.
---

# HVE Resiliency Research

Use this skill when you need the full resiliency research sequence for this repository.

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

## Activation Guidance

Auto-load this skill for requests related to application resiliency, Azure zone survivability, or regional failover research.

## Activation Behavior

When this skill is activated (via `/hve-resiliency-research` or by matching the activation guidance), the agent MUST immediately begin executing the Required Workflow starting at Phase 1, Prompt 0. Do not prompt the user for which prompt to run. Do not skip to service-specific prompts (8-19) without completing Prompts 0-7 first.

**Phase 1 runs autonomously end-to-end and STOPS for user confirmation before Phase 2.** Phase 2 then runs autonomously end-to-end and STOPS before Phase 3. The agent MUST NOT pause for `/clear` or any user confirmation between prompts *within* Phase 1 or *within* Phase 2, but MUST stop between Phase 1 and Phase 2, and between Phase 2 and Phase 3. Phases 3-5 remain user-gated by `/clear` because they introduce remediation content and benefit from user review checkpoints.

## Required Workflow

Phases are strictly sequential. Each phase must complete before the next phase begins.

### Phase 1: Core Research (Prompts 0-7) — Start Here, Runs Autonomously

#### Phase 1 Autonomy Rules

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
12. **STOP and wait for user confirmation before starting Phase 2.** End the turn with a clear prompt asking the user to confirm proceeding to Phase 2 (e.g., "Reply `proceed` to begin Phase 2 service-specific research, or `/clear` first if you want a fresh context."). Do not auto-dispatch any Phase 2 prompt in the same turn as the Phase 1 summary.

### Phase 2: Service-Specific Research (Prompts 8-19, Circumstantial) — Runs Autonomously After User Confirmation

Phase 2 runs only after Phase 1 is complete **and the user has confirmed in a subsequent turn** (per Phase 1 Sequence step 12). Run only the prompts matching dependencies confirmed in Prompt 1 Section 1. Skip services not found.

Phase 2 is triggered by an affirmative user reply (e.g., `proceed`, `yes`, `continue`, `go`, or by re-invoking the skill after `/clear`). Once triggered, the entire phase runs without further user input.

#### Phase 2 Autonomy Rules

* The agent MUST execute all applicable Phase 2 prompts without prompting the user and without inserting `/clear` between them.
* The agent MUST first compute the applicable prompt set by mapping each Section 1 dependency from the Prompt 1a/1b artifacts to the corresponding service-specific prompt below. Skip every prompt whose service is not in Section 1.
* The agent MUST dispatch each applicable prompt as an isolated subagent invocation (one subagent per prompt) to preserve context isolation in lieu of `/clear`. Where service-specific prompts are independent (no shared state), the agent MAY dispatch up to three subagents in parallel.
* After each subagent completes, the orchestrating agent reads the produced artifact, summarizes the result inline (one short paragraph), then dispatches the next.
* If a subagent fails or produces no artifact, retry once with a more explicit instruction; if it fails again, surface the error, skip that service, and continue with the remaining applicable prompts.
* Present a Phase 2 completion summary listing every artifact produced and every service skipped (with reason).
* **STOP at the end of Phase 2.** Do not auto-dispatch Phase 3 (`/hve-resiliency-researcher-consolidate`) — that prompt is long-running and times out under autonomous orchestration. End the turn with a next-step suggestion that the user run `/clear`, then `/hve-resiliency-researcher-consolidate` themselves.

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

* Run `/hve-resiliency-planner-0`, then `/hve-resiliency-planner-1`, then `/clear` and `/hve-resiliency-planner-0` again, then `/hve-resiliency-planner-2`. This produces both `<repo-name>-Master.md` and `<repo-name>-Developer-Guide.md` in `.copilot-tracking/plans/`.
* Inspect or modify the Master report between Step 2 and Step 4 if needed.

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

## Priority Definitions

* P0: Critical / Blocking. Causes outage, data loss, duplicate transactions, or inability to fail over safely.
* P1: Required, Non-Blocking. Materially increases application risk, data risk, or customer impact during failure.
* P2: Improvement / Best Practice. Does not materially impact correctness but weakens resilience posture.
* P3: Non-Blocking Code Consistency. Maintainability, readability, duplication, or inconsistent patterns that are non-blocking.

## Service Exclusion Rule

* After Prompt 1 completes, dependencies in Section 2 (Checked But Not Present) and Section 3 (Not Applicable) are dropped from scope
* Prompts 2-7, service-specific prompts (8-19), and the consolidation report analyze only Section 1 dependencies (evidence-confirmed)
* In Phase 2, run only the service-specific prompts for dependencies found in Section 1
