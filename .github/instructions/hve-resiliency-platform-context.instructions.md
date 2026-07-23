---
description: Platform context and evidence-only rules for resiliency research prompts
applyTo: '.github/prompts/researcher/hve-resiliency-researcher-*.prompt.md, .github/prompts/researcher/service/hve-resiliency-researcher-*.prompt.md'
---

# Resiliency Research Platform Context

Apply this context to all resiliency research prompts.

* Validating readiness for zone failure within either region
* Validating readiness for full active/active regional failover between West US and West US 2 in either direction
* Scope is the current repository

## Region Context

The application is transitioning from an active-passive (DR) posture - a single-region production deployment in West US with West US 2 as a passive disaster recovery target - to an active/active deployment across West US and West US 2. Name these two regions when referring to them and do not use primary/secondary role labels.

* **West US** - one of the two active/active regions (currently the production region)
* **West US 2** - the other active/active region (the peer being added)
* **Both regions** - when referring to symmetric requirements
* Target state is active/active, so failover is symmetric: either region can absorb the other's traffic. Validate readiness for failover in both directions (West US to West US 2 and West US 2 to West US).
* HVE Task Researcher rules: evidence only, no remediation, no code examples
* All findings must cite file and line-level evidence
* Classify every finding using the priority framework: P0 (Blocking/Critical), P1 (High Priority), P2 (Improvement/Best Practice), P3 (Non-Blocking Code Consistency)
* Output research artifacts to `.copilot-tracking/research/` and use the repository name as the prefix for all output files (e.g., `<repo-name>-research-output.md`).

## Priority Definitions

* P0: Critical / Blocking. Causes outage, data loss, duplicate transactions, or inability to fail over safely during zone or regional failure.
* P1: Required, Non-Blocking. Does not fully block failover but materially increases application risk, data risk, or customer impact during failure.
* P2: Improvement / Best Practice. Does not materially impact correctness during failover but weakens resilience posture or operational clarity.
* P3: Non-Blocking Code Consistency. Captures maintainability, readability, duplication, or inconsistent pattern issues that are non-blocking.

## Service Exclusion Rule

* After Prompts 1a and 1b complete, dependencies classified in Section 2 (Checked But Not Present) and Section 3 (Not Applicable) are excluded from analysis in Prompts 2-7 and service-specific prompts (8-19)
* Prompts 2-7 and service-specific prompts (8-19) analyze only dependencies confirmed as used in Section 1 of the Prompt 1a and 1b outputs

## Next Step Suggestions

After completing each research prompt output, end the response with a next-step suggestion the user can click. Format as:

> **Next step:** Run `/clear`, then `/command-name`

Follow this sequence:

| Current Prompt                              | Next Step                                                                                                                |
|---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `/hve-resiliency-researcher-0`              | `/hve-resiliency-researcher-1a`                                                                                          |
| `/hve-resiliency-researcher-1a`             | `/hve-resiliency-researcher-1b` (review Section 1 results first)                                                         |
| `/hve-resiliency-researcher-1b`             | `/hve-resiliency-researcher-2` (review Section 1 results from 1a and 1b; Sections 2-3 are excluded from here on)         |
| `/hve-resiliency-researcher-2`              | `/hve-resiliency-researcher-3`                                                                                           |
| `/hve-resiliency-researcher-3`              | `/hve-resiliency-researcher-4`                                                                                           |
| `/hve-resiliency-researcher-4`              | `/hve-resiliency-researcher-5`                                                                                           |
| `/hve-resiliency-researcher-5`              | `/hve-resiliency-researcher-6`                                                                                           |
| `/hve-resiliency-researcher-6`              | `/hve-resiliency-researcher-7-logging`                                                                                   |
| `/hve-resiliency-researcher-7-logging`      | First applicable service-specific prompt from Phase 2, or `/hve-resiliency-researcher-consolidate-0` if none apply         |
| Service-specific prompts (8-19)             | Next applicable service prompt for a Prompt 1 Section 1 dependency, or `/hve-resiliency-researcher-consolidate-0` when complete |
| `/hve-resiliency-researcher-consolidate-0`  | `/hve-resiliency-researcher-consolidate-1`                                                                               |
| `/hve-resiliency-researcher-consolidate-1`  | `/hve-resiliency-researcher-consolidate-2`                                                                               |
| `/hve-resiliency-researcher-consolidate-2`  | `/hve-resiliency-planner-0`                                                                                              |
