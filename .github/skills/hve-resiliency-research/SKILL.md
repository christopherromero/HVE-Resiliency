---
name: hve-resiliency-research
description: Use for HVE resiliency research covering Azure zone failure, regional failover, active-active, active-standby, and service-specific resiliency review using the new repository-evidence-index workflow.
---

## HVE Resiliency Research

Use this skill when you need the full evidence-first HVE resiliency research workflow for a source code repository.

Use [Resiliency Research Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

### Activation Guidance

Auto-load this skill only for requests that explicitly mention one or more of the following:

- Azure zone failure
- Azure availability zone resiliency
- regional failover
- multi-region active-active
- active-standby
- zone survivability
- HVE resiliency research
- /hve-resiliency-research
- run the HVE researcher workflow
- repository resiliency assessment

Do not auto-load this skill for general reliability, performance, cost, security, or unrelated Azure questions.

### Activation Behavior

When this skill is activated:

1. Do not ask the user to choose an execution mode.
2. Use the guided `/clear`-gated workflow defined in this skill file.
3. Run exactly one prompt per turn.
4. Start with Phase 1, Step 1: Repository Evidence Index Builder.
5. After each prompt completes, summarize the produced artifact and stop.
6. End every stop message with the exact next prompt to run.
7. Do not skip to service-specific prompts until Phase 1 is complete.
8. Do not run remediation, planning, or assessment-builder prompts during research phases.

### Core Operating Model

This workflow uses one broad repository discovery pass followed by bounded evidence consumers.

The repository evidence index is the required source contract for all downstream researcher prompts.

All research prompts must:

- Use direct file and line evidence.
- Reuse `.copilot-tracking/research/repository-evidence-index.md`.
- Use scope gates.
- Record evidence gaps separately from findings.
- Assign P0/P1/P2/P3 only to confirmed findings.
- Include confidence: High, Medium, or Low.
- Deduplicate by root cause.
- Avoid remediation, code examples, and implementation guidance.
- Stop when required input artifacts are missing.
- Write outputs to `.copilot-tracking/research/`.

### Required Workflow

The workflow is strictly sequential.

Do not start a later phase until the current phase is complete.

Run `/clear` between every prompt.

Artifacts on disk carry context forward. Chat history must not be treated as the source of truth.

---

## Phase 1: Core Research

Phase 1 creates the reusable evidence index and bounded core research artifacts.

### Phase 1 Step 1: Repository Evidence Index Builder

Run:

`/hve-resiliency-researcher-0`

Expected output:

`.copilot-tracking/research/repository-evidence-index.md`

Purpose:

- Performs the only broad repository discovery pass.
- Indexes entry points, dependencies, endpoints, regions, state paths, write paths, health paths, telemetry paths, shared libraries, and evidence gaps.
- Does not assign severity.
- Does not create findings.
- Does not recommend fixes.

Stop after completion.

Next message:

`Run /clear, then reply proceed to continue with /hve-resiliency-researcher-1a (Azure Scope Contract).`

### Phase 1 Step 2: Azure Scope Contract

Run:

`/hve-resiliency-researcher-1a`

Required input:

`.copilot-tracking/research/repository-evidence-index.md`

Expected output:

`.copilot-tracking/research/azure-scope-contract.md`

Purpose:

- Identifies Azure services actually used by the repository.
- Classifies services as Explicit Use, Implicit Dependency, Referenced/Assumed but Not Found, or Not Present.
- Produces the Azure service scope contract for service-specific prompts.
- Does not assign severity.
- Does not recommend fixes.

Stop after completion.

Next message:

`Run /clear, then reply proceed to continue with /hve-resiliency-researcher-1b (Non-Azure Scope Contract).`

### Phase 1 Step 3: Non-Azure Scope Contract

Run:

`/hve-resiliency-researcher-1b`

Required input:

`.copilot-tracking/research/repository-evidence-index.md`

Expected output:

`.copilot-tracking/research/non-azure-scope-contract.md`

Purpose:

- Identifies external, SaaS, internal platform, third-party, and non-Azure dependencies.
- Records health/readiness linkage only where repository evidence exists.
- Produces the non-Azure dependency scope contract.
- Does not assign severity.
- Does not recommend fixes.

Stop after completion.

Next message:

`Run /clear, then reply proceed to continue with /hve-resiliency-researcher-2 (Region, Endpoint, and Dependency Survivability).`

### Phase 1 Step 4: Region, Endpoint, and Dependency Survivability

Run:

`/hve-resiliency-researcher-2`

Required inputs:

- `.copilot-tracking/research/repository-evidence-index.md`
- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`

Expected output:

`.copilot-tracking/research/region-endpoint-dependency-survivability.md`

Purpose:

- Replaces legacy region-assumption and dependency-survivability prompts.
- Evaluates hardcoded regions, single-region endpoints, direct IPs, identity assumptions, dependency endpoint selection, fallback logic, and multi-region selection logic.
- Uses only indexed candidate files and scope-contract evidence.

Stop after completion.

Next message:

`Run /clear, then reply proceed to continue with /hve-resiliency-researcher-3 (State, Failure, and Health Behavior).`

### Phase 1 Step 5: State, Failure, and Health Behavior

Run:

`/hve-resiliency-researcher-3`

Required inputs:

- `.copilot-tracking/research/repository-evidence-index.md`
- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`
- `.copilot-tracking/research/region-endpoint-dependency-survivability.md`

Expected output:

`.copilot-tracking/research/state-failure-health-behavior.md`

Purpose:

- Replaces legacy state/data and failure/degraded-mode prompts.
- Evaluates state, writes, caching, idempotency, retries, timeouts, failure behavior, health/readiness, GLB health relevance, and detection signals.
- Uses only indexed candidate files.

Stop after completion.

Next message:

`Run /clear, then reply proceed to continue with /hve-resiliency-researcher-4 (Shared Dependency Boundary Analysis), or skip it if the evidence index shows no shared dependency candidates.`

### Phase 1 Step 6: Shared Dependency Boundary Analysis

Run only if `repository-evidence-index.md` lists shared libraries, platform utilities, generated clients, shared Helm charts, centralized config, shared pipelines, or external ownership boundaries.

Run:

`/hve-resiliency-researcher-4`

Expected output:

`.copilot-tracking/research/shared-dependency-boundary-research.md`

If not applicable, write a skipped artifact at the same path with:

`Shared dependency analysis skipped: no candidate shared dependency evidence found.`

Purpose:

- Evaluates shared libraries, platform utilities, generated clients, centralized configuration, shared pipelines, and ownership boundaries.
- Runs only when the index proves candidate shared-boundary evidence exists.

Stop after completion.

Next message:

`Run /clear, then reply proceed to begin Phase 2 Service-Specific Research.`

---

## Phase 2: Service-Specific Research

Phase 2 runs only service prompts that match services confirmed in:

- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`
- `.copilot-tracking/research/repository-evidence-index.md`

Do not run service prompts for services not confirmed by evidence.

Each service-specific prompt must consume `repository-evidence-index.md` and must use its own scope gate.

### Phase 2 Service Prompt Map

Use this map:

- Application Gateway: `/hve-resiliency-researcher-8-appgw`
- Azure Functions: `/hve-resiliency-researcher-9-functions`
- Azure Key Vault: `/hve-resiliency-researcher-10-keyvault`
- AKS and Istio: `/hve-resiliency-researcher-11-aks-istio`
- Cosmos DB: `/hve-resiliency-researcher-12-cosmosdb`
- Azure SQL: `/hve-resiliency-researcher-13-sql`
- Redis: `/hve-resiliency-researcher-14-redis`
- Azure Storage: `/hve-resiliency-researcher-15-storage`
- Kafka Active-Standby: `/hve-resiliency-researcher-16-kafka-active-standby-confluent`
- Kafka Active-Active: `/hve-resiliency-researcher-16-kafka-active-active`
- Networking: `/hve-resiliency-researcher-17-networking`
- Microsoft Entra ID: `/hve-resiliency-researcher-18-entraid`
- API Management: `/hve-resiliency-researcher-19-apim`

### Kafka Routing Rule

Select exactly one Kafka prompt per assessment unless the user explicitly requests separate analysis for two distinct Kafka architectures:

- Use Kafka Active-Standby when the target architecture is active-standby.
- Use Kafka Active-Active when the target architecture is active-active mirror-topic plus feature flag.
- Do not run both Kafka prompts for the same Kafka architecture.

### Phase 2 Execution Rule

Run one applicable service prompt per turn.

After each service prompt completes:

1. Summarize the produced artifact.
2. State whether P0/P1/P2/P3 findings were produced.
3. State the next applicable service prompt.
4. Stop.

If no applicable service prompts remain, stop with:

`Run /clear, then /hve-resiliency-researcher-consolidate to begin Phase 3 Consolidation.`

---

## Phase 3: Consolidation

Run only after Phase 1 and Phase 2 are complete.

Run:

`/hve-resiliency-researcher-consolidate`

Required inputs:

- `.copilot-tracking/research/repository-evidence-index.md`
- `.copilot-tracking/research/azure-scope-contract.md`
- `.copilot-tracking/research/non-azure-scope-contract.md`
- `.copilot-tracking/research/region-endpoint-dependency-survivability.md`
- `.copilot-tracking/research/state-failure-health-behavior.md`
- `.copilot-tracking/research/shared-dependency-boundary-research.md`, if present
- all completed service-specific research artifacts

Expected output:

`.copilot-tracking/research/YYYY-MM-DD--research.md`

Purpose:

- Creates the sole authoritative research artifact for HVE Task Planner.
- Deduplicates findings by root cause.
- Preserves source-artifact traceability.
- Includes evidence gaps and assessment constraints.
- Assigns canonical finding IDs.
- Produces a planner-friendly research findings index.

Do not read source repository files during consolidation.

Stop after completion.

Next message:

`Run /clear, then /hve-resiliency-planner-0 using the consolidated research artifact.`

---

## Optional Phase 4: Planning

Planning is outside research and uses Task Planner.

Run only after Phase 3 is reviewed.

Recommended commands:

1. `/hve-resiliency-planner-0`
2. `/hve-resiliency-planner-1`
3. Review the Master report.
4. `/hve-resiliency-planner-2`

Planning may include remediation and code guidance.

---

## Optional Phase 5: Code-Level Assessment Report

Assessment building is outside research and uses the batched Task Planner report prompts.

Run after planning artifacts are reviewed.

Recommended commands:

1. `/clear`
2. `/hve-resiliency-planner-3a`
3. `/clear`
4. `/hve-resiliency-planner-3b`
5. `/clear`
6. `/hve-resiliency-planner-3c`
7. `/clear`
8. `/hve-resiliency-planner-3d`

Expected final report:

`Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`

---

## Research Governance Rules

These rules apply to all research phases:

- Research is evidence-only.
- Do not include remediation recommendations.
- Do not include code examples.
- Do not use advisory wording such as should, recommend, implement, or fix.
- Every finding must include file and line evidence.
- Every finding must include P0/P1/P2/P3 severity.
- Every finding must include confidence.
- Evidence gaps must not receive severity.
- Missing documentation alone is not P0 or P1.
- Generic best practices are not P0 or P1 unless failover impact is directly evidenced.
- Deduplicate repeated issues by root cause.
- Preserve duplicate evidence locations under the canonical finding.
- Use existing mitigations only when evidenced.
- Use constraints only when evidenced.
- If required input artifacts are missing, stop and report the missing artifact.
- Do not use em dashes in generated artifacts. Use a hyphen or rewrite the sentence.

## Priority Definitions

- P0: Failover-blocking risk. Blocks regional failover, renders the second region ineffective, causes outage, data loss, duplicate business action, or unsafe failover.
- P1: Material multi-region resiliency gap. Does not fully block failover but materially increases customer impact, data risk, recovery risk, or operational risk.
- P2: Non-blocking resiliency improvement. Valid resiliency or observability improvement that does not prove failover blockage or material data risk.
- P3: Maintainability or consistency issue. No proven functional failover impact.

A finding marked `Resiliency Related: No` must never be P0 or P1.

## Output Review Notice

Every artifact produced by this workflow must be reviewed by a qualified engineer before it is shared, acted on, or treated as authoritative.

AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified priorities, fabricated citations, or internal inconsistencies.

Validate every claim against cited file and line references. Confirm scope decisions, reconcile contradictions, and correct errors before advancing to planning or assessment.